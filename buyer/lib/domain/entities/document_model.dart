import 'package:equatable/equatable.dart';

enum DocumentType {
  residential,
  commercial,
  land,
}

enum FileType {
  pdf,
  doc,
  xls,
  image,
}

class DocumentModel extends Equatable {
  final String id;
  final String title;
  final String propertyName;
  final String propertyConfiguration;
  final DateTime date;
  final String fileSize;
  final FileType fileType;
  final DocumentType documentType;
  final String? downloadUrl;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.propertyName,
    required this.propertyConfiguration,
    required this.date,
    required this.fileSize,
    required this.fileType,
    required this.documentType,
    this.downloadUrl,
  });

  String get fullPropertyName => '$propertyName - $propertyConfiguration';

  String get fileTypeLabel {
    switch (fileType) {
      case FileType.pdf:
        return 'PDF';
      case FileType.doc:
        return 'DOC';
      case FileType.xls:
        return 'XLS';
      case FileType.image:
        return 'IMG';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        propertyName,
        propertyConfiguration,
        date,
        fileSize,
        fileType,
        documentType,
        downloadUrl,
      ];
}

