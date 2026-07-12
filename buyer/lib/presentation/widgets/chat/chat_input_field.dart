import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback? onAttachmentTap;
  final File? selectedImage;
  final VoidCallback? onRemoveImage;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.onAttachmentTap,
    this.selectedImage,
    this.onRemoveImage,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _isEmojiVisible = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
    // Handle invalid selection by defaulting to end of text
    int start;
    int end;
    
    if (selection.isValid && selection.start >= 0 && selection.end >= 0) {
      start = selection.start;
      end = selection.end;
    } else {
      // Default to end of text if selection is invalid
      start = text.length;
      end = text.length;
    }
    
    // Ensure start and end are within valid range
    final safeStart = start.clamp(0, text.length);
    final safeEnd = end.clamp(0, text.length);
    
    final newText = text.replaceRange(
      safeStart,
      safeEnd,
      emoji.emoji,
    );
    
    final newOffset = safeStart + emoji.emoji.length;
    
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newOffset,
      ),
    );
    
    // Update hasText state
    _onTextChanged();
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
      if (_isEmojiVisible) {
        widget.focusNode.unfocus();
      } else {
        widget.focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image preview
        if (widget.selectedImage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.selectedImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: AppColors.textPrimaryDark.withOpacity(0.54),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: widget.onRemoveImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.backgroundWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: const BoxDecoration(
            color: AppColors.chatBackground,
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Emoji button
                Material(
                  color: AppColors.backgroundWhite.withOpacity(0),
                  child: InkWell(
                    onTap: _toggleEmojiPicker,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _isEmojiVisible
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: AppColors.textIconGray,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Text input field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                      decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: ThemeManager().bodyStyle.copyWith(
                        fontSize: 15,
                        color: AppColors.textPrimaryDark,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.chatTypeMessagePlaceholder,
                        hintStyle: ThemeManager().bodyStyle.copyWith(
                          fontSize: 15,
                          color: AppColors.textSecondaryGray,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (_) => widget.onSend(),
                      onTap: () {
                        if (_isEmojiVisible) {
                          setState(() {
                            _isEmojiVisible = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
                // Plus/Attachment button
                Material(
                  color: AppColors.backgroundWhite.withOpacity(0),
                  child: InkWell(
                    onTap: widget.onAttachmentTap,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.textIconGray,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Send button
                if (_hasText || widget.selectedImage != null)
                  Container(
                    margin: const EdgeInsets.only(left: 4, right: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlueLink,
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: AppColors.backgroundWhite.withOpacity(0),
                      child: InkWell(
                        onTap: widget.onSend,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.send_rounded,
                            color: AppColors.backgroundWhite,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Emoji picker
        if (_isEmojiVisible)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: _onEmojiSelected,
              config: Config(
                height: 250,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  emojiSizeMax: 28 * (1.0),
                  backgroundColor: AppColors.chatBackground,
                ),
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: const CategoryViewConfig(),
                bottomActionBarConfig: const BottomActionBarConfig(
                  enabled: false,
                ),
              ),
            ),
          ),
      ],
    );
  }
}