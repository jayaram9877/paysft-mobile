import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget that wraps a TextField/TextFormField with a gradient border
/// The gradient border appears when the field is focused/active
class GradientBorderInput extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color? defaultBorderColor;
  final Color? errorBorderColor;
  final bool hasError;
  final FocusNode? focusNode;

  const GradientBorderInput({
    super.key,
    required this.child,
    this.borderRadius = 14,
    this.defaultBorderColor,
    this.errorBorderColor,
    this.hasError = false,
    this.focusNode,
  });

  @override
  State<GradientBorderInput> createState() => _GradientBorderInputState();
}

class _GradientBorderInputState extends State<GradientBorderInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }
    _focusNode.addListener(_onFocusChange);
    // Check initial focus state
    _isFocused = _focusNode.hasFocus;
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always check the current focus state directly from the focus node
    final isCurrentlyFocused = _focusNode.hasFocus;
    
    final borderColor = widget.hasError
        ? (widget.errorBorderColor ?? AppColors.errorRed)
        : (isCurrentlyFocused
            ? null // Use gradient when focused
            : (widget.defaultBorderColor ?? AppColors.borderGrayMedium));

    if (borderColor == null && isCurrentlyFocused && !widget.hasError) {
      // Show gradient border when focused
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: const LinearGradient(
            colors: [AppColors.primaryCyan, AppColors.primaryPurpleBright],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(2), // Border width
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius - 2),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundWhite,
            ),
            child: widget.child,
          ),
        ),
      );
    } else {
      // Show solid border when not focused or has error
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: borderColor ?? AppColors.borderGrayMedium,
            width: widget.hasError ? 1 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: widget.child,
        ),
      );
    }
  }
}
