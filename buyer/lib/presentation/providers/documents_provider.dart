import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/document_model.dart';
import '../pages/document_viewer_page.dart';

enum DateRangeFilter {
  all,
  lastWeek,
  lastMonth,
  last3Months,
  lastYear,
}

class DocumentsProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  DocumentsProvider() {
    _initializeDocuments();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<DocumentModel> _allDocuments = [];
  List<DocumentModel> _filteredDocuments = [];
  List<DocumentModel> get documents => _filteredDocuments;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // Filter states (temporary - for UI selection)
  FileType? _tempFileType;
  FileType? _selectedFileType;
  FileType? get selectedFileType => _tempFileType ?? _selectedFileType;
  FileType? get appliedFileType => _selectedFileType;

  DateRangeFilter _tempDateRange = DateRangeFilter.all;
  DateRangeFilter _selectedDateRange = DateRangeFilter.all;
  DateRangeFilter get selectedDateRange => _tempDateRange;
  DateRangeFilter get appliedDateRange => _selectedDateRange;

  String? _tempPropertyName;
  String? _selectedPropertyName;
  String? get selectedPropertyName => _tempPropertyName ?? _selectedPropertyName;
  String? get appliedPropertyName => _selectedPropertyName;

  // Get unique property names for filter
  List<String> get availablePropertyNames {
    return _allDocuments.map((doc) => doc.propertyName).toSet().toList()..sort();
  }

  static const List<String> tabs = ['All', 'Residential', 'Commercial', 'Lands'];

  String get selectedTab => tabs[_selectedTabIndex];

  int get documentCount => _filteredDocuments.length;

  bool get hasActiveFilters =>
      _selectedFileType != null || _selectedDateRange != DateRangeFilter.all || _selectedPropertyName != null;

  bool get hasPendingFilters =>
      _tempFileType != _selectedFileType ||
      _tempDateRange != _selectedDateRange ||
      _tempPropertyName != _selectedPropertyName;

  void _initializeDocuments() {
    // Initialize temporary filters to match applied filters
    _tempFileType = _selectedFileType;
    _tempDateRange = _selectedDateRange;
    _tempPropertyName = _selectedPropertyName;
    
    // Mock data - replace with actual API call
    _allDocuments = [
      DocumentModel(
        id: '1',
        title: 'Allotment Letter',
        propertyName: 'Prestige Lakeside Habitat',
        propertyConfiguration: '3BHK',
        date: DateTime(2024, 12, 10),
        fileSize: '245 KB',
        fileType: FileType.pdf,
        documentType: DocumentType.residential,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '2',
        title: 'Builder - Buyer Agreement',
        propertyName: 'Prestige Lakeside Habitat',
        propertyConfiguration: '3BHK',
        date: DateTime(2024, 11, 15),
        fileSize: '1.2 MB',
        fileType: FileType.pdf,
        documentType: DocumentType.residential,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '3',
        title: 'Payment Receipt - Token',
        propertyName: 'Prestige Lakeside Habitat',
        propertyConfiguration: '3BHK',
        date: DateTime(2024, 10, 20),
        fileSize: '180 KB',
        fileType: FileType.pdf,
        documentType: DocumentType.residential,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '4',
        title: 'Payment Receipt - Milestone 1',
        propertyName: 'Prestige Lakeside Habitat',
        propertyConfiguration: '3BHK',
        date: DateTime(2024, 9, 15),
        fileSize: '190 KB',
        fileType: FileType.pdf,
        documentType: DocumentType.residential,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '5',
        title: 'Floor Plan',
        propertyName: 'Prestige Lakeside Habitat',
        propertyConfiguration: '3BHK',
        date: DateTime(2024, 8, 10),
        fileSize: '3.5 MB',
        fileType: FileType.pdf,
        documentType: DocumentType.residential,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '6',
        title: 'Commercial Lease Agreement',
        propertyName: 'Tech Park Tower',
        propertyConfiguration: 'Office Space',
        date: DateTime(2024, 12, 5),
        fileSize: '2.1 MB',
        fileType: FileType.pdf,
        documentType: DocumentType.commercial,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '7',
        title: 'Land Sale Deed',
        propertyName: 'Greenfield Plot',
        propertyConfiguration: '5000 sqft',
        date: DateTime(2024, 11, 20),
        fileSize: '1.8 MB',
        fileType: FileType.pdf,
        documentType: DocumentType.land,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '8',
        title: 'Residential Agreement',
        propertyName: 'Sunset Apartments',
        propertyConfiguration: '2BHK',
        date: DateTime(2024, 10, 25),
        fileSize: '950 KB',
        fileType: FileType.pdf,
        documentType: DocumentType.residential,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '9',
        title: 'Commercial Tax Receipt',
        propertyName: 'Tech Park Tower',
        propertyConfiguration: 'Office Space',
        date: DateTime(2024, 9, 30),
        fileSize: '420 KB',
        fileType: FileType.pdf,
        documentType: DocumentType.commercial,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      DocumentModel(
        id: '10',
        title: 'Land Survey Report',
        propertyName: 'Greenfield Plot',
        propertyConfiguration: '5000 sqft',
        date: DateTime(2024, 8, 15),
        fileSize: '1.5 MB',
        fileType: FileType.pdf,
        documentType: DocumentType.land,
        downloadUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
    ];
    _applyFilters();
  }

  void onTabChanged(int index) {
    _selectedTabIndex = index;
    _applyFilters();
    notifyListeners();
  }

  void _onSearchChanged() {
    _applyFilters();
    notifyListeners();
  }

  void setFileTypeFilter(FileType? fileType) {
    _tempFileType = fileType;
    notifyListeners();
  }

  void setDateRangeFilter(DateRangeFilter dateRange) {
    _tempDateRange = dateRange;
    notifyListeners();
  }

  void setPropertyNameFilter(String? propertyName) {
    _tempPropertyName = propertyName;
    notifyListeners();
  }

  void applyFilters() {
    _selectedFileType = _tempFileType;
    _selectedDateRange = _tempDateRange;
    _selectedPropertyName = _tempPropertyName;
    _applyFilters();
    notifyListeners();
  }

  void clearAllFilters() {
    _tempFileType = null;
    _tempDateRange = DateRangeFilter.all;
    _tempPropertyName = null;
    notifyListeners();
  }

  void resetToAppliedFilters() {
    _tempFileType = _selectedFileType;
    _tempDateRange = _selectedDateRange;
    _tempPropertyName = _selectedPropertyName;
    notifyListeners();
  }

  void _applyFilters() {
    String searchQuery = searchController.text.toLowerCase().trim();
    DocumentType? typeFilter;

    switch (_selectedTabIndex) {
      case 1:
        typeFilter = DocumentType.residential;
        break;
      case 2:
        typeFilter = DocumentType.commercial;
        break;
      case 3:
        typeFilter = DocumentType.land;
        break;
      default:
        typeFilter = null;
    }

    final now = DateTime.now();
    DateTime? dateFilterStart;

    switch (_selectedDateRange) {
      case DateRangeFilter.lastWeek:
        dateFilterStart = now.subtract(const Duration(days: 7));
        break;
      case DateRangeFilter.lastMonth:
        dateFilterStart = DateTime(now.year, now.month - 1, now.day);
        break;
      case DateRangeFilter.last3Months:
        dateFilterStart = DateTime(now.year, now.month - 3, now.day);
        break;
      case DateRangeFilter.lastYear:
        dateFilterStart = DateTime(now.year - 1, now.month, now.day);
        break;
      case DateRangeFilter.all:
        dateFilterStart = null;
        break;
    }

    _filteredDocuments = _allDocuments.where((doc) {
      // Tab filter (document type)
      bool matchesType = typeFilter == null || doc.documentType == typeFilter;

      // Search filter
      bool matchesSearch = searchQuery.isEmpty ||
          doc.title.toLowerCase().contains(searchQuery) ||
          doc.propertyName.toLowerCase().contains(searchQuery);

      // File type filter (use applied filter, not temporary)
      bool matchesFileType = _selectedFileType == null || doc.fileType == _selectedFileType;

      // Date range filter (use applied filter, not temporary)
      bool matchesDateRange = dateFilterStart == null || doc.date.isAfter(dateFilterStart);

      // Property name filter (use applied filter, not temporary)
      bool matchesProperty = _selectedPropertyName == null || doc.propertyName == _selectedPropertyName;

      return matchesType && matchesSearch && matchesFileType && matchesDateRange && matchesProperty;
    }).toList();

    // Default sort: newest first
    _filteredDocuments.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> downloadDocument(DocumentModel document, BuildContext context) async {
    if (document.downloadUrl == null || document.downloadUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download URL not available')),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Show downloading snackbar (will be replaced by success/error message)
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Downloading...'),
          duration: Duration(seconds: 30), // Long duration, will be replaced
        ),
      );

      // Request storage permission (Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          // Try manage external storage for Android 11+
          final manageStorageStatus = await Permission.manageExternalStorage.request();
          if (!manageStorageStatus.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied')),
            );
            return;
          }
        }
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // Navigate to Downloads folder
        if (directory != null) {
          final downloadsPath = '${directory.path.split('Android')[0]}Download';
          final downloadsDir = Directory(downloadsPath);
          if (await downloadsDir.exists()) {
            directory = downloadsDir;
          }
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access download directory');
      }

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Download file
      final response = await http.get(Uri.parse(document.downloadUrl!));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      // Get file extension
      final extension = document.fileType == FileType.pdf
          ? 'pdf'
          : document.fileType == FileType.doc
              ? 'doc'
              : document.fileType == FileType.xls
                  ? 'xls'
                  : 'jpg';

      // Create file name (sanitize for file system)
      final sanitizedTitle = document.title.replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
      final fileName = '$sanitizedTitle.$extension';
      final filePath = '${directory.path}/$fileName';

      // Save file (overwrite if exists)
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Show success snackbar with View option
      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(
                  child: Text('Downloaded and stored in Files app'),
                ),
                GestureDetector(
                  onTap: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentViewerPage(
                          filePath: filePath,
                          documentTitle: document.title,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      debugPrint('File downloaded to: $filePath');
    } catch (e) {
      debugPrint('Error downloading file: $e');
      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

