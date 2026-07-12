import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/broker_kyc_remote_data_source.dart';
import '../../data/models/broker_model.dart';

enum KycDestination { profile, documents, inProgress, verified }

/// A locally-selected document file, not yet uploaded.
class DocDraft {
  final String filePath;
  final String fileName;
  final int? fileSizeKb;
  DocDraft({required this.filePath, required this.fileName, this.fileSizeKb});
}

/// Drives the broker KYC flow. Profile data and document files are collected
/// LOCALLY across screens; nothing is sent to the API until [submitAll] is
/// called from the final Submit button. Verification status: pending = in
/// review, active = verified.
class BrokerKycProvider with ChangeNotifier {
  final BrokerKycRemoteDataSource remoteDataSource;

  BrokerKycProvider({required this.remoteDataSource});

  BrokerModel? _broker;
  bool _loading = false;
  String? _errorMessage;

  // ---- Collected-but-not-yet-submitted data -------------------------------
  String? _legalName;
  String _entityType = 'individual';
  String? _pan;
  String? _registeredAddress;
  String? _reraAgentNumber;
  String? _reraAgentState;
  String? _bankAccountNumber;
  String? _bankAccountHolderName;
  String? _bankIfsc;
  String? _bankName;
  // documentType -> selected file (held locally until submit)
  final Map<String, DocDraft> _docs = {};
  // documentType -> the number the user typed (UI only; API has no field)
  final Map<String, String> _docNumbers = {};
  // -------------------------------------------------------------------------

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  bool get hasProfileDraft => _legalName != null;

  bool hasDoc(String documentType) => _docs.containsKey(documentType);
  DocDraft? docOf(String documentType) => _docs[documentType];

  /// Document types the API requires for submit. Anything else (e.g. the RERA
  /// certificate) is uploaded best-effort so a server-side type rejection
  /// cannot break an otherwise-valid registration.
  static const Set<String> _requiredDocTypes = {
    'address_proof',
    'pan_card',
    'cancelled_cheque',
    'photo_id',
  };

  // Optional documents the server rejected during the last submit (e.g. an
  // unsupported document_type). Empty on full success.
  final List<String> _skippedDocs = [];
  List<String> get skippedDocs => List.unmodifiable(_skippedDocs);

  /// PAN validation rule matching the API (^[A-Z0-9]{10}$).
  static bool isValidPan(String pan) =>
      RegExp(r'^[A-Z0-9]{10}$').hasMatch(pan.trim().toUpperCase());

  void clearErrorIfAny() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Decides where a freshly-authenticated user should land.
  Future<KycDestination> resolveDestination() async {
    try {
      _broker = await remoteDataSource.getMyBroker();
      if (_broker == null) return KycDestination.profile;
      if (_broker!.isActive) return KycDestination.verified;
      final docs = await remoteDataSource.listDocuments();
      return docs.isEmpty
          ? KycDestination.documents
          : KycDestination.inProgress;
    } catch (_) {
      return KycDestination.profile;
    }
  }

  /// Step: save the profile details locally (NO API call yet).
  /// IFSC format: 4 letters, a 0, then 6 alphanumerics (e.g. HDFC0001234).
  static bool isValidIfsc(String ifsc) =>
      RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc.trim().toUpperCase());

  /// Bank account number: 9–18 digits.
  static bool isValidAccountNumber(String acc) =>
      RegExp(r'^\d{9,18}$').hasMatch(acc.trim());

  bool saveProfileDraft({
    required String legalName,
    required String entityType,
    required String pan,
    required String registeredAddress,
    String? reraAgentNumber,
    String? reraAgentState,
    String? bankAccountNumber,
    String? bankAccountHolderName,
    String? bankIfsc,
    String? bankName,
  }) {
    if (legalName.trim().isEmpty) {
      _errorMessage = 'Enter your legal name';
      notifyListeners();
      return false;
    }
    if (!isValidPan(pan)) {
      _errorMessage = 'Enter a valid 10-character PAN';
      notifyListeners();
      return false;
    }
    if (registeredAddress.trim().isEmpty) {
      _errorMessage = 'Enter your registered address';
      notifyListeners();
      return false;
    }
    // Bank details are optional, but validate the format when provided.
    final bankAcc = (bankAccountNumber ?? '').trim();
    final ifsc = (bankIfsc ?? '').trim().toUpperCase();
    if (bankAcc.isNotEmpty && !isValidAccountNumber(bankAcc)) {
      _errorMessage = 'Enter a valid bank account number (9–18 digits)';
      notifyListeners();
      return false;
    }
    if (ifsc.isNotEmpty && !isValidIfsc(ifsc)) {
      _errorMessage = 'Enter a valid IFSC code (e.g. HDFC0001234)';
      notifyListeners();
      return false;
    }
    _legalName = legalName.trim();
    _entityType = entityType;
    _pan = pan.trim().toUpperCase();
    _registeredAddress = registeredAddress.trim();
    _reraAgentNumber =
        (reraAgentNumber?.trim().isEmpty ?? true) ? null : reraAgentNumber!.trim();
    _reraAgentState =
        (reraAgentState?.trim().isEmpty ?? true) ? null : reraAgentState!.trim();
    _bankAccountNumber = bankAcc.isEmpty ? null : bankAcc;
    _bankIfsc = ifsc.isEmpty ? null : ifsc;
    _bankAccountHolderName =
        (bankAccountHolderName?.trim().isEmpty ?? true) ? null
            : bankAccountHolderName!.trim();
    _bankName =
        (bankName?.trim().isEmpty ?? true) ? null : bankName!.trim();
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Step: hold a selected document file locally (NO upload yet).
  void setDoc(String documentType, DocDraft draft) {
    _docs[documentType] = draft;
    notifyListeners();
  }

  void removeDoc(String documentType) {
    _docs.remove(documentType);
    notifyListeners();
  }

  void setDocNumber(String documentType, String number) {
    _docNumbers[documentType] = number;
  }

  /// Final step: create profile, upload every collected document, then submit
  /// for review — all in one go.
  Future<bool> submitAll() async {
    if (!hasProfileDraft) {
      _errorMessage = 'Please complete your profile first.';
      notifyListeners();
      return false;
    }
    _loading = true;
    _errorMessage = null;
    _skippedDocs.clear();
    notifyListeners();

    try {
      // 1) Create the broker profile if it doesn't exist yet.
      _broker ??= await remoteDataSource.getMyBroker();
      _broker ??= await remoteDataSource.createBroker(
        legalName: _legalName!,
        entityType: _entityType,
        pan: _pan!,
        registeredAddress: _registeredAddress!,
        reraAgentNumber: _reraAgentNumber,
        reraAgentState: _reraAgentState,
        bankAccountNumber: _bankAccountNumber,
        bankAccountHolderName: _bankAccountHolderName,
        bankIfsc: _bankIfsc,
        bankName: _bankName,
      );

      // 2) Upload every collected document. Required types must succeed;
      //    optional ones (e.g. RERA) are best-effort so a rejected type can't
      //    block submission.
      for (final entry in _docs.entries) {
        try {
          await remoteDataSource.uploadDocument(
            documentType: entry.key,
            filePath: entry.value.filePath,
            fileName: entry.value.fileName,
          );
        } on ServerException {
          if (_requiredDocTypes.contains(entry.key)) rethrow;
          _skippedDocs.add(entry.key);
        }
      }

      // 3) Submit for review.
      _broker = await remoteDataSource.submitForReview();

      _loading = false;
      notifyListeners();
      return true;
    } on ServerException catch (e) {
      _errorMessage = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Could not submit. Please try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Helper to compute a file's size in KB.
  static Future<int?> fileSizeKb(String path) async {
    try {
      return (await File(path).length() / 1024).round();
    } catch (_) {
      return null;
    }
  }
}
