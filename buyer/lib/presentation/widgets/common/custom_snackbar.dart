import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';

/// Customizable snackbar widget with support for leading images, custom text, and styles
/// Uses custom overlay for full UI control with adaptive width and shadow effects
class CustomSnackbar {
  static OverlayEntry? _currentOverlay;

  /// Shows a customizable snackbar
  static void show(
    BuildContext context, {
    required String message,
    String? leadingImagePath,
    TextStyle? messageStyle,
    Color? backgroundColor,
    double? borderRadius,
    Duration? duration,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    // Remove existing overlay if any
    _hide();

    final overlay = OverlayEntry(
      builder: (context) => _CustomSnackbarOverlay(
        message: message,
        leadingImagePath: leadingImagePath,
        messageStyle: messageStyle,
        backgroundColor: backgroundColor ?? AppColors.backgroundWhite,
        borderRadius: borderRadius ?? 16.0,
        padding: padding,
        margin: margin,
        onDismiss: _hide,
      ),
    );

    _currentOverlay = overlay;
    Overlay.of(context).insert(overlay);

    // Auto dismiss after duration
    Future.delayed(duration ?? const Duration(seconds: 2), () {
      _hide();
    });
  }

  /// Hides the current snackbar
  static void _hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Shows the default "Added to Favorites" snackbar
  static void showAddedToFavorites(BuildContext context) {
    final themeManager = ThemeManager();
    show(
      context,
      message: AppStrings.addedToFavorites,
      leadingImagePath: 'assets/images/ic_heart.svg',
      messageStyle: themeManager.bodyMediumStyle.copyWith(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
      backgroundColor: AppColors.snackbarColor,
      borderRadius: 50.0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      margin: const EdgeInsets.only(bottom: 100),
      duration: const Duration(seconds: 2),
    );
  }

  /// Shows a success snackbar with custom message
  static void showSuccess(BuildContext context, {required String message, String? leadingImagePath}) {
    final themeManager = ThemeManager();
    show(
      context,
      message: message,
      leadingImagePath: leadingImagePath ?? 'assets/images/ic_heart.svg',
      messageStyle: themeManager.bodyMediumStyle.copyWith(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.backgroundWhite,
      borderRadius: 16.0,
    );
  }

  /// Shows an error snackbar with custom message
  static void showError(BuildContext context, {required String message, String? leadingImagePath}) {
    final themeManager = ThemeManager();
    show(
      context,
      message: message,
      leadingImagePath: leadingImagePath,
      messageStyle: themeManager.bodyMediumStyle.copyWith(
        color: AppColors.textWhite,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.errorRed,
      borderRadius: 16.0,
    );
  }
}

class _CustomSnackbarOverlay extends StatefulWidget {
  final String message;
  final String? leadingImagePath;
  final TextStyle? messageStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback onDismiss;

  const _CustomSnackbarOverlay({
    required this.message,
    this.leadingImagePath,
    this.messageStyle,
    required this.backgroundColor,
    required this.borderRadius,
    this.padding,
    this.margin,
    required this.onDismiss,
  });

  @override
  State<_CustomSnackbarOverlay> createState() => _CustomSnackbarOverlayState();
}

class _CustomSnackbarOverlayState extends State<_CustomSnackbarOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.margin?.bottom ?? 100,
      left: widget.margin?.left ?? 16,
      right: widget.margin?.right ?? 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: _CustomSnackbarContent(
              message: widget.message,
              leadingImagePath: widget.leadingImagePath,
              messageStyle: widget.messageStyle,
              backgroundColor: widget.backgroundColor,
              borderRadius: widget.borderRadius,
              padding: widget.padding,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomSnackbarContent extends StatelessWidget {
  final String message;
  final String? leadingImagePath;
  final TextStyle? messageStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets? padding;

  const _CustomSnackbarContent({
    required this.message,
    this.leadingImagePath,
    this.messageStyle,
    required this.backgroundColor,
    required this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.backgroundWhite),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBlack.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: AppColors.backgroundWhite.withOpacity(0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingImagePath != null) ...[_buildLeadingImage(), const SizedBox(width: 10)],
              Text(
                message,
                style: messageStyle ?? ThemeManager().bodyMediumStyle.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingImage() {
    // Check if it's an SVG or regular image
    if (leadingImagePath!.endsWith('.svg')) {
      final colorFilter = _getColorFilter();
      return Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        child: colorFilter != null
            ? ColorFiltered(colorFilter: colorFilter, child: SvgPicture.asset(leadingImagePath!, width: 20, height: 20))
            : SvgPicture.asset(leadingImagePath!, width: 20, height: 20),
      );
    } else {
      return Image.asset(leadingImagePath!, width: 20, height: 20, fit: BoxFit.contain);
    }
  }

  ColorFilter? _getColorFilter() {
    // Apply color filter based on background color
    // For white background, use blue color for heart icon (matching design - filled blue heart)
    if (backgroundColor == AppColors.backgroundWhite || backgroundColor.value == AppColors.backgroundWhite.value) {
      // Use primaryBlueIOS for filled blue heart effect
      return const ColorFilter.mode(AppColors.primaryBlueIOS, BlendMode.srcIn);
    }
    // For red/error backgrounds, use white
    if (backgroundColor == AppColors.errorRed || backgroundColor.value == AppColors.errorRed.value) {
      return const ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn);
    }
    // For dark backgrounds, use white
    if (backgroundColor.computeLuminance() < 0.5) {
      return const ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn);
    }
    // Default: use primary blue for light backgrounds
    return const ColorFilter.mode(AppColors.primaryBlueIOS, BlendMode.srcIn);
  }
}
