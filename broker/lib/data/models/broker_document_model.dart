/// Mirrors an item from `GET /brokers/me/documents` — a KYC document the broker
/// has uploaded.
class BrokerDocumentModel {
  final String id;
  final String documentType;
  final String currentStatus; // pending_review | approved | rejected
  final String? originalFileName;
  final String? mimeType;
  final int? fileSizeBytes;
  final DateTime? uploadedAt;

  /// Document validity window from the API (e.g. a RERA certificate's expiry).
  final DateTime? validUntil;

  BrokerDocumentModel({
    required this.id,
    required this.documentType,
    required this.currentStatus,
    this.originalFileName,
    this.mimeType,
    this.fileSizeBytes,
    this.uploadedAt,
    this.validUntil,
  });

  static String? _s(dynamic v) => v?.toString();

  factory BrokerDocumentModel.fromJson(Map<String, dynamic> json) {
    return BrokerDocumentModel(
      id: _s(json['id']) ?? '',
      documentType: _s(json['document_type']) ?? '',
      currentStatus: _s(json['current_status']) ?? 'pending_review',
      originalFileName: _s(json['original_file_name']),
      mimeType: _s(json['mime_type']),
      fileSizeBytes:
          json['file_size_bytes'] is int ? json['file_size_bytes'] as int : null,
      uploadedAt: DateTime.tryParse(_s(json['uploaded_at']) ?? ''),
      validUntil: DateTime.tryParse(_s(json['valid_until']) ?? ''),
    );
  }

  bool get isApproved => currentStatus == 'approved';
  bool get isRejected => currentStatus == 'rejected';

  /// Friendly label for the broker document types.
  String get typeLabel {
    switch (documentType) {
      case 'address_proof':
        return 'Address Proof (Aadhaar)';
      case 'pan_card':
        return 'PAN Card';
      case 'cancelled_cheque':
        return 'Cancelled Cheque (DPDP)';
      case 'photo_id':
        return 'Photo ID / Selfie';
      case 'rera_agent_certificate':
        return 'RERA Certificate';
      default:
        return documentType
            .split(RegExp(r'[_\s]+'))
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  String get statusLabel {
    switch (currentStatus) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending review';
    }
  }
}
