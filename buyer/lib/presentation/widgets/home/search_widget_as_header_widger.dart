import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../widgets/common/app_svg_icon.dart';
import '../../widgets/common/app_search_field.dart';

class AppBarSearchHeaderWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onBack;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const AppBarSearchHeaderWidget({
    super.key,
    required this.controller,
    required this.onBack,
    required this.onFilterTap,
    required this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<AppBarSearchHeaderWidget> createState() => _AppBarSearchHeaderWidgetState();
}

class _AppBarSearchHeaderWidgetState extends State<AppBarSearchHeaderWidget> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Material(
      color: AppColors.backgroundWhite,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              onPressed: widget.onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppSearchField(
                controller: widget.controller,
                hintText: AppStrings.searchHint,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                focusNode: _focusNode,
                autofocus: true,
                height: 48,
                borderRadius: 14,
                showFilter: false,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onFilterTap,
              child: AppSvgIcon(
                assetPath: 'assets/images/filter.svg',
                width: 22,
                height: 22,
                color: AppColors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
