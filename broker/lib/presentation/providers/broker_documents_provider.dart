import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/broker_kyc_remote_data_source.dart';
import '../../data/models/broker_document_model.dart';

/// Loads the broker's uploaded KYC documents for the "My Documents" screen.
class BrokerDocumentsProvider with ChangeNotifier {
  final BrokerKycRemoteDataSource remoteDataSource;

  BrokerDocumentsProvider({required this.remoteDataSource});

  bool _loading = false;
  String? _errorMessage;
  List<BrokerDocumentModel> _documents = [];

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  List<BrokerDocumentModel> get documents => _documents;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final raw = await remoteDataSource.listDocuments();
      _documents = raw
          .whereType<Map>()
          .map((e) =>
              BrokerDocumentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.typeLabel.compareTo(b.typeLabel));
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load documents.';
    }
    _loading = false;
    notifyListeners();
  }
}
