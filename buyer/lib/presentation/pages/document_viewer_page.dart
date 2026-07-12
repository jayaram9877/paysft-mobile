import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/document_model.dart';
import '../widgets/common/app_svg_icon.dart';
import '../widgets/common/app_loader_widget.dart';

class DocumentViewerPage extends StatefulWidget {
  final String filePath;
  final String documentTitle;

  const DocumentViewerPage({
    super.key,
    required this.filePath,
    required this.documentTitle,
  });

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _timeoutReached = false;
  bool _isSimulator = false;

  @override
  void initState() {
    super.initState();
    _checkIfSimulator();
    // Set a timeout to automatically open in external app if PDF doesn't load
    _startTimeout();
  }

  Future<void> _checkIfSimulator() async {
    // Check if running on iOS simulator
    if (Platform.isIOS) {
      // On iOS simulator, PDF viewer plugin often doesn't work
      // Check if path contains simulator identifier
      if (widget.filePath.contains('CoreSimulator') || 
          widget.filePath.contains('simulator')) {
        _isSimulator = true;
        debugPrint('Detected iOS Simulator - PDF viewer may have limited functionality');
        // On simulator, automatically open in external app after a brief delay
        // This provides a better user experience since the in-app viewer won't work
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && _isLoading) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = 'PDF viewer is not available on iOS Simulator. Opening in external app...';
            });
            // Automatically open in external app
            _openFile(context);
          }
        });
      }
    }
  }

  void _startTimeout() {
    // If PDF doesn't load within timeout, show option to open in external app
    // Use shorter timeout on simulator (5s) vs physical device (10s)
    final timeoutDuration = _isSimulator ? const Duration(seconds: 5) : const Duration(seconds: 10);
    
    Future.delayed(timeoutDuration, () {
      if (mounted && _isLoading && !_hasError && !_timeoutReached) {
        setState(() {
          _timeoutReached = true;
          _hasError = true;
          _errorMessage = _isSimulator 
              ? 'PDF viewer may not work on iOS Simulator. Please open in an external app to view.'
              : 'PDF is taking longer than expected to load. You can try opening it in an external app.';
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openFile(BuildContext context) async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        debugPrint('File does not exist: ${widget.filePath}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File not found')),
          );
        }
        return;
      }

      debugPrint('Attempting to open file: ${widget.filePath}');
      debugPrint('File size: ${await file.length()} bytes');
      
      // On iOS, use file:// URL scheme for local files
      final uri = Uri.file(widget.filePath);
      debugPrint('File URI: $uri');
      
      if (await canLaunchUrl(uri)) {
        debugPrint('Launching file in external app...');
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          debugPrint('File opened successfully in external app');
          // On simulator, close the viewer page after opening externally for better UX
          if (_isSimulator && context.mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        } else {
          debugPrint('Failed to launch file - launchUrl returned false');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open file')),
            );
          }
        }
      } else {
        debugPrint('Cannot launch URL: $uri');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open file')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final file = File(widget.filePath);
    final fileExtension = widget.filePath.split('.').last.toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: AppSvgIcon(
            assetPath: 'assets/images/profile_back.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
        leadingWidth: 40,
        title: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            widget.documentTitle,
            style: themeManager.titleMediumStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: AppColors.textDark),
            onPressed: () => _openFile(context),
            tooltip: 'Open in external app',
          ),
        ],
      ),
      body: _buildDocumentViewer(context, themeManager, fileExtension),
    );
  }

  Widget _buildDocumentViewer(
    BuildContext context,
    ThemeManager themeManager,
    String fileExtension,
  ) {
    switch (fileExtension.toLowerCase()) {
      case 'pdf':
        return _buildPdfViewer(context, themeManager);
      case 'doc':
      case 'docx':
        return _buildWordViewer(context, themeManager);
      case 'xls':
      case 'xlsx':
        return _buildExcelViewer(context, themeManager);
      default:
        return _buildUnsupportedViewer(context, themeManager, fileExtension);
    }
  }

  Widget _buildPdfViewer(BuildContext context, ThemeManager themeManager) {
    final file = File(widget.filePath);
    
    if (!file.existsSync()) {
      return _buildFileNotFoundView(context, themeManager);
    }

    // Check if file is empty (likely incomplete download)
    final fileSize = file.lengthSync();
    debugPrint('PDF file size: $fileSize bytes, path: ${widget.filePath}');
    debugPrint('Is Simulator: $_isSimulator');
    
    if (fileSize == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textGray,
            ),
            const SizedBox(height: 16),
            Text(
              'Invalid PDF file',
              style: themeManager.titleMediumStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The downloaded file appears to be empty. Please try downloading again.',
              style: themeManager.bodyStyle.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // On iOS simulator, try to load PDF but reduce timeout
    // The viewer may work on some simulators but not others

    // Show error if plugin failed or timeout reached
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textGray,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to display PDF',
              style: themeManager.titleMediumStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please open in external app',
              style: themeManager.bodyStyle.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openFile(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in External App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Show loader while loading
    if (_isLoading) {
      return const Center(child: AppLoaderWidget());
    }

    // Try to create PDF viewer with error handling
    // Use a wrapper to catch plugin exceptions
    return _PdfViewerWrapper(
      file: file,
      isLoading: _isLoading,
      onLoaded: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            // Clear any timeout errors if PDF loads successfully
            if (_timeoutReached) {
              _timeoutReached = false;
              _hasError = false;
              _errorMessage = null;
            }
          });
        }
      },
      onError: (String error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = error;
          });
        }
      },
    );
  }

  Widget _buildWordViewer(BuildContext context, ThemeManager themeManager) {
    final file = File(widget.filePath);
    
    if (!file.existsSync()) {
      return _buildFileNotFoundView(context, themeManager);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description,
            size: 64,
            color: AppColors.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            widget.documentTitle,
            style: themeManager.titleMediumStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Word documents can be viewed in external apps',
            style: themeManager.bodyStyle.copyWith(color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openFile(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in External App'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcelViewer(BuildContext context, ThemeManager themeManager) {
    final file = File(widget.filePath);
    
    if (!file.existsSync()) {
      return _buildFileNotFoundView(context, themeManager);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.table_chart,
            size: 64,
            color: AppColors.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            widget.documentTitle,
            style: themeManager.titleMediumStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Excel files can be viewed in external apps',
            style: themeManager.bodyStyle.copyWith(color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openFile(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in External App'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedViewer(
    BuildContext context,
    ThemeManager themeManager,
    String fileExtension,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.insert_drive_file,
            size: 64,
            color: AppColors.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            widget.documentTitle,
            style: themeManager.titleMediumStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'File type: ${fileExtension.toUpperCase()}',
            style: themeManager.bodyStyle.copyWith(color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openFile(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in External App'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileNotFoundView(BuildContext context, ThemeManager themeManager) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            'File not found',
            style: themeManager.titleMediumStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'The file may have been moved or deleted',
            style: themeManager.bodyStyle.copyWith(color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Wrapper widget to handle PDF viewer with error boundary
class _PdfViewerWrapper extends StatefulWidget {
  final File file;
  final bool isLoading;
  final VoidCallback onLoaded;
  final Function(String) onError;

  const _PdfViewerWrapper({
    required this.file,
    required this.isLoading,
    required this.onLoaded,
    required this.onError,
  });

  @override
  State<_PdfViewerWrapper> createState() => _PdfViewerWrapperState();
}

class _PdfViewerWrapperState extends State<_PdfViewerWrapper> {
  bool _hasError = false;
  bool _pluginErrorDetected = false;

  @override
  void initState() {
    super.initState();
    // Set up global error handler to catch MissingPluginException
    _setupErrorHandler();
  }

  void _setupErrorHandler() {
    // Store original error handler
    final originalOnError = FlutterError.onError;
    
    FlutterError.onError = (FlutterErrorDetails details) {
      // Check if it's a MissingPluginException related to PDF viewer
      final exception = details.exception;
      if (exception is MissingPluginException || 
          exception.toString().contains('MissingPluginException') ||
          exception.toString().contains('closeDocument') ||
          exception.toString().contains('syncfusion_flutter_pdfviewer')) {
        if (!_pluginErrorDetected && mounted) {
          _pluginErrorDetected = true;
          widget.onError('PDF viewer plugin not available. Opening in external app...');
          // Automatically open in external app after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _openInExternalApp();
            }
          });
        }
        return; // Suppress the error
      }
      // Let other errors be handled normally
      if (originalOnError != null) {
        originalOnError(details);
      } else {
        FlutterError.presentError(details);
      }
    };
  }

  Future<void> _openInExternalApp() async {
    try {
      final uri = Uri.file(widget.file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Pop the viewer page since we're opening externally
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Error opening file - already handled by onError
    }
  }

  @override
  void dispose() {
    // Reset error handler
    FlutterError.onError = FlutterError.presentError;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loader only if still loading and no errors detected
    if (widget.isLoading && !_pluginErrorDetected && !_hasError) {
      return const Center(child: AppLoaderWidget());
    }

    // If plugin error detected, show loader while opening external app
    if (_pluginErrorDetected) {
      return const Center(child: AppLoaderWidget());
    }

    // If there's an error but not a plugin error, the parent will handle it
    if (_hasError && !_pluginErrorDetected) {
      return const Center(child: AppLoaderWidget());
    }

    try {
      // Create PDF viewer - it will handle its own loading state
      // Use network URL if available, otherwise use file
      return SfPdfViewer.file(
        widget.file,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          // Always call onLoaded when document loads successfully
          debugPrint('PDF document loaded successfully. Pages: ${details.document.pages.count}');
          if (mounted) {
            widget.onLoaded();
          }
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          debugPrint('PDF document load failed: ${details.error}');
          if (!_pluginErrorDetected && mounted) {
            widget.onError('Failed to load PDF: ${details.error}');
          }
        },
      );
    } catch (e) {
      debugPrint('Exception creating PDF viewer: $e');
      // Handle synchronous exceptions
      if (e is MissingPluginException || 
          e.toString().contains('MissingPluginException') ||
          e.toString().contains('closeDocument')) {
        if (!_pluginErrorDetected && mounted) {
          _pluginErrorDetected = true;
          widget.onError('PDF viewer plugin not available. Please open in external app.');
          // Don't auto-open, let user choose
        }
        return const Center(child: AppLoaderWidget());
      }
      // For other exceptions, show error
      if (mounted && !_pluginErrorDetected) {
        setState(() {
          _hasError = true;
        });
        widget.onError(e.toString());
      }
      return const Center(child: AppLoaderWidget());
    }
  }
}

