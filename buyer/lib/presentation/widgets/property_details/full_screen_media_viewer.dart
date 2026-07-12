import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../common/app_loader_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';

/// Full-screen media viewer for images and videos
/// Supports swipe navigation with indicators showing current/next/previous
class FullScreenMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;
  final String categoryName;

  const FullScreenMediaViewer({
    super.key,
    required this.mediaUrls,
    required this.initialIndex,
    required this.categoryName,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  bool _isVideoInitializing = false;
  bool _showControls = true;
  String? _currentVideoUrl;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeMedia(_currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_videoController != null) {
      try {
        _videoController!.pause();
      } catch (e) {
        // Ignore errors during pause
      }
      try {
        _videoController!.dispose();
      } catch (e) {
        // Ignore errors during disposal
      }
      _videoController = null;
    }
    _currentVideoUrl = null;
    super.dispose();
  }

  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.endsWith('.mkv') ||
        lowerUrl.endsWith('.webm') ||
        lowerUrl.contains('/video/') ||
        lowerUrl.contains('video=true');
  }

  Future<void> _initializeMedia(int index) async {
    if (index < 0 || index >= widget.mediaUrls.length) return;

    final url = widget.mediaUrls[index];

    // Dispose previous video controller
    if (_videoController != null) {
      try {
        await _videoController!.pause();
        await _videoController!.dispose();
      } catch (e) {
        // Ignore errors during disposal
      }
      _videoController = null;
    }
    _currentVideoUrl = null;

    if (_isVideo(url)) {
      setState(() {
        _isVideoInitializing = true;
        _currentVideoUrl = url;
      });

      try {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url));
        await controller.initialize();

        // Check if this is still the current video (user might have swiped away)
        if (mounted && _currentVideoUrl == url) {
          // Add listener to update UI when video state changes
          controller.addListener(() {
            if (mounted && _currentVideoUrl == url) {
              setState(() {});
            }
          });

          setState(() {
            _videoController = controller;
            _isVideoInitializing = false;
          });

          // Auto-play video when initialized
          if (mounted && _currentVideoUrl == url) {
            controller.play();
          }
        } else {
          // User swiped away, dispose this controller
          await controller.dispose();
        }
      } catch (e) {
        if (mounted && _currentVideoUrl == url) {
          setState(() {
            _isVideoInitializing = false;
            _currentVideoUrl = null;
          });
        }
      }
    } else {
      setState(() {
        _isVideoInitializing = false;
        _currentVideoUrl = null;
      });
    }
  }

  void _onPageChanged(int index) {
    // Pause current video if playing
    if (_videoController != null) {
      try {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        }
      } catch (e) {
        // Ignore errors if controller is already disposed
      }
    }

    setState(() {
      _currentIndex = index;
    });
    _initializeMedia(index);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return Scaffold(
      backgroundColor: AppColors.textBlack,
      body: Stack(
        children: [
          // Media content
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaUrls.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _toggleControls,
                child: _buildMediaContent(widget.mediaUrls[index], index == _currentIndex),
              );
            },
          ),

          // Top bar with back button and category
          if (_showControls)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.textBlack.withOpacity(0.7), AppColors.backgroundWhite.withOpacity(0)],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.categoryName,
                        style: themeManager.bodyMediumStyle.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom indicators
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.textBlack.withOpacity(0.7), AppColors.backgroundWhite.withOpacity(0)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.mediaUrls.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentIndex ? AppColors.textWhite : AppColors.textWhite.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Current/Next/Previous indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentIndex > 0 && _currentIndex < widget.mediaUrls.length - 1) const SizedBox(width: 16),
                        _buildIndicatorItem(AppStrings.current, _currentIndex, AppColors.textWhite),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicatorItem(String label, int index, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Text(
          '${index + 1}/${widget.mediaUrls.length}',
          style: ThemeManager().captionStyle.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaContent(String url, bool isActive) {
    if (_isVideo(url)) {
      // Only show video player if this is the active page and controller matches
      if (!isActive || _currentVideoUrl != url) {
        return const Center(child: AppLoaderWidget());
      }

      if (_isVideoInitializing || _videoController == null) {
        return const Center(child: AppLoaderWidget());
      }

      // Check if controller is still valid
      try {
        if (!_videoController!.value.isInitialized) {
          return const Center(child: AppLoaderWidget());
        }
      } catch (e) {
        // Controller was disposed
        return const Center(child: AppLoaderWidget());
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)),
          ),
          if (isActive)
            Center(
              child: _showControls
                  ? IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        color: AppColors.textWhite,
                        size: 64,
                      ),
                      onPressed: () {
                        if (_videoController != null && _currentVideoUrl == url) {
                          try {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                              } else {
                                _videoController!.play();
                              }
                            });
                          } catch (e) {
                            // Ignore errors if controller is disposed
                          }
                        }
                      },
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      );
    } else {
      // Image
      return Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: AppLoaderWidget());
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.gray900,
                child: const Center(child: Icon(Icons.image_not_supported, color: AppColors.gray400, size: 64)),
              );
            },
          ),
        ),
      );
    }
  }
}
