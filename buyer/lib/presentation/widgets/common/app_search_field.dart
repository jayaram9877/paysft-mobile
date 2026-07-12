import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import 'app_svg_icon.dart';

/// Reusable search field component
/// Used across multiple screens with consistent styling
class AppSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool showFilter;
  final double? height;
  final double borderRadius;
  final EdgeInsets? padding;

  const AppSearchField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.focusNode,
    this.autofocus = false,
    this.showFilter = true,
    this.height,
    this.borderRadius = 14,
    this.padding,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;
  String? _lastSubmittedText;
  DateTime? _lastSubmittedAt;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }
    // Listen to controller changes to update close icon visibility
    widget.controller.addListener(_onTextChanged);
    // Listen to focus changes to update UI
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _handleSubmit([String? value]) {
    final submitted = (value ?? widget.controller.text).trim();
    final now = DateTime.now();

    // Dedupe: some platforms fire both onSubmitted and onEditingComplete.
    if (_lastSubmittedText == submitted &&
        _lastSubmittedAt != null &&
        now.difference(_lastSubmittedAt!).inMilliseconds < 350) {
      return;
    }

    _lastSubmittedText = submitted;
    _lastSubmittedAt = now;
    widget.onSubmitted?.call(submitted);

    // Requirement: when user presses Search with empty input, dismiss keyboard.
    if (submitted.isEmpty) {
      _focusNode.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    final height = widget.height ?? 48.0;
    final padding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 12);

    // Build the TextField widget (reused in both states)
    final textField = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: _handleSubmit,
      onEditingComplete: _handleSubmit,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 16, color: AppColors.textDark, fontFamily: AppStrings.fontFamily),
      decoration: InputDecoration(
        hintText: widget.hintText ?? AppStrings.searchHint,
        border: InputBorder.none,
        isDense: true,
        hintStyle: TextStyle(fontSize: 16, color: AppColors.textGrayLight, fontFamily: AppStrings.fontFamily),
      ),
    );

    if (isFocused) {
      // Use gradient border when focused
      return Container(
        height: height,
        padding: const EdgeInsets.all(2), // Border width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: const LinearGradient(
            colors: [AppColors.primaryCyan, AppColors.primaryPurpleBright],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          height: height - 4,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius - 2),
            color: AppColors.backgroundWhite,
          ),
          child: Row(
            children: [
              AppSvgIcon(
                assetPath: 'assets/images/search.svg',
                width: 22,
                height: 22,
                color: AppColors.primaryPurpleBright,
              ),
              const SizedBox(width: 10),
              Expanded(child: textField),
              // Close icon when text is present
              if (widget.controller.text.isNotEmpty) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: AppColors.bluePrimary, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: AppColors.textWhite),
                  ),
                ),
              ],
              if (widget.showFilter && widget.onFilterTap != null) ...[
                Container(height: 24, width: 1, color: AppColors.borderGrayLight),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onFilterTap,
                  child: AppSvgIcon(
                    assetPath: 'assets/images/filter.svg',
                    width: 22,
                    height: 22,
                    color: AppColors.primaryPurpleBright,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      // Use solid border when not focused
      return GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
        },
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: AppColors.borderGrayLight, width: 1),
          ),
          child: Row(
            children: [
              AppSvgIcon(assetPath: 'assets/images/search.svg', width: 22, height: 22, color: AppColors.gray600),
              const SizedBox(width: 10),
              Expanded(child: textField),
              // Close icon when text is present
              if (widget.controller.text.isNotEmpty) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: AppColors.bluePrimary, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: AppColors.textWhite),
                  ),
                ),
              ],
              if (widget.showFilter && widget.onFilterTap != null) ...[
                Container(height: 24, width: 1, color: AppColors.borderGrayLight),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onFilterTap,
                  child: AppSvgIcon(
                    assetPath: 'assets/images/filter.svg',
                    width: 22,
                    height: 22,
                    color: AppColors.primaryPurpleBright,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }
}
