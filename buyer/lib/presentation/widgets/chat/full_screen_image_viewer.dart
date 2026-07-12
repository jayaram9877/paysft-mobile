import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imagePath;
  final String? networkImageUrl;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    this.networkImageUrl,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final TransformationController _transformationController = TransformationController();
  bool _showAppBar = true;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textBlack,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: AppColors.textBlack.withOpacity(0.5),
              iconTheme: const IconThemeData(color: AppColors.textWhite),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // TODO: Implement download functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleAppBar,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: widget.networkImageUrl != null
                ? Image.network(
                    widget.networkImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          color: AppColors.textWhite,
                          size: 48,
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          color: AppColors.textWhite,
                          size: 48,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

