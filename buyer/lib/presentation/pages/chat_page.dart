import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../providers/chat_provider.dart';
import '../widgets/chat/chat_input_field.dart';
import '../widgets/rich_content_card.dart';
import '../widgets/chat/contact_card.dart';
import '../widgets/chat/document_card.dart';
import '../widgets/chat/link_preview_card.dart';
import '../widgets/chat/full_screen_image_viewer.dart';
import '../pages/contact_details_screen.dart';
import '../../domain/entities/message.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/services/location_service.dart';
import '../../core/di/injection_container.dart' as di;

class ChatPage extends StatefulWidget {
  final ChatContact contact;

  const ChatPage({super.key, required this.contact});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();

    // If there's an image, send image message (with or without text)
    if (_selectedImage != null) {
      context.read<ChatProvider>().sendImageMessage(text, _selectedImage!.path);
      setState(() {
        _selectedImage = null;
      });
      _messageController.clear();
      _scrollToBottom();
    } else if (text.isNotEmpty) {
      // Send text message only if there's text
      context.read<ChatProvider>().sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
    // Don't send empty messages without images
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: _buildAppBar(themeManager),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (chatProvider.messages.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    final showDate = _shouldShowDate(index > 0 ? chatProvider.messages[index - 1] : null, message);

                    return Column(
                      children: [if (showDate) _buildDateSeparator(message.timestamp), _buildMessageBubble(message)],
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(
            controller: _messageController,
            focusNode: _focusNode,
            onSend: _sendMessage,
            selectedImage: _selectedImage,
            onRemoveImage: () {
              setState(() {
                _selectedImage = null;
              });
            },
            onAttachmentTap: () {
              // Show attachment options
              _showAttachmentOptions(context);
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeManager themeManager) {
    return AppBar(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark, size: 24),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: InkWell(
        onTap: () {
          // Could navigate to contact details
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.avatarBackground,
              backgroundImage: widget.contact.profileImageUrl != null
                  ? NetworkImage(widget.contact.profileImageUrl!)
                  : null,
              child: widget.contact.profileImageUrl == null
                  ? Text(
                      widget.contact.name[0].toUpperCase(),
                      style: themeManager.titleMediumStyle.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.name,
                    style: themeManager.bodyMediumStyle.copyWith(color: AppColors.textPrimaryDark, letterSpacing: 0.15),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (widget.contact.isOnline) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.statusOnline, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.chatOnline,
                          style: themeManager.captionSmallStyle.copyWith(color: AppColors.textSecondaryGray),
                        ),
                      ] else if (widget.contact.lastSeen != null) ...[
                        Text(
                          widget.contact.lastSeen!,
                          style: themeManager.captionSmallStyle.copyWith(color: AppColors.textSecondaryGray),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: AppColors.textIconGray, size: 24),
          onPressed: () {
            // Handle video call
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: AppColors.textIconGray, size: 22),
          onPressed: () {
            // Handle phone call
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textIconGray, size: 22),
          onPressed: () {
            // Handle more options
          },
        ),
      ],
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final themeManager = ThemeManager();
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    String dateText;
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      dateText = AppStrings.chatToday;
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      dateText = AppStrings.chatYesterday;
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        dateText,
        style: themeManager.labelStyle.copyWith(fontSize: 12.5, color: AppColors.textSecondaryGray),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final themeManager = ThemeManager();
    final formattedTime = _formatTime(message.timestamp);

    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: message.isSent ? AppColors.chatSentMessageBubble : AppColors.chatReceivedMessageBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(7.5),
                  topRight: const Radius.circular(7.5),
                  bottomLeft: Radius.circular(message.isSent ? 7.5 : 0),
                  bottomRight: Radius.circular(message.isSent ? 0 : 7.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contact Card
                  if (message.type == MessageType.contact && message.sharedContact != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ContactDetailsScreen(contact: message.sharedContact!),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ContactCard(contact: message.sharedContact!, isSent: message.isSent),
                          ),
                        ),
                        // Timestamp for contact card
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            formattedTime,
                            style: themeManager.labelStyle.copyWith(
                              fontSize: 11,
                              color: message.isSent
                                  ? AppColors.chatSentMessageTimestamp
                                  : AppColors.chatReceivedMessageTimestamp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Document Card
                  if (message.type == MessageType.document && message.sharedDocument != null)
                    GestureDetector(
                      onTap: () async {
                        // Open document using system default viewer
                        final filePath = message.sharedDocument!.filePath;
                        try {
                          final uri = Uri.file(filePath);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open ${message.sharedDocument!.fileName}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error opening document: ${e.toString()}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: DocumentCard(document: message.sharedDocument!, isSent: message.isSent),
                      ),
                    ),
                  // Link Preview Card
                  if (message.type == MessageType.link && message.linkUrl != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LinkPreviewCard(url: message.linkUrl!, isSent: message.isSent),
                        ),
                        // Timestamp for link preview card
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            formattedTime,
                            style: themeManager.labelStyle.copyWith(
                              fontSize: 11,
                              color: message.isSent
                                  ? AppColors.chatSentMessageTimestamp
                                  : AppColors.chatReceivedMessageTimestamp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Rich Content Card
                  if (message.type == MessageType.richContent && message.richContent != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RichContentCard(content: message.richContent!),
                    ),
                  // Image
                  if (message.type == MessageType.image && message.imagePath != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => FullScreenImageViewer(imagePath: message.imagePath!)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7.5),
                          child: Image.file(
                            File(message.imagePath!),
                            width: MediaQuery.of(context).size.width * 0.6,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 200,
                                color: AppColors.errorBackground,
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  // Text content
                  if (message.text.isNotEmpty &&
                      message.type != MessageType.contact &&
                      message.type != MessageType.document &&
                      message.type != MessageType.link)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.text,
                          style: themeManager.bodySmallStyle.copyWith(
                            color: message.isSent ? AppColors.chatSentMessageText : AppColors.chatReceivedMessageText,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            formattedTime,
                            style: themeManager.labelStyle.copyWith(
                              fontSize: 11,
                              color: message.isSent
                                  ? AppColors.chatSentMessageTimestamp
                                  : AppColors.chatReceivedMessageTimestamp,
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (message.type != MessageType.contact &&
                      message.type != MessageType.document &&
                      message.type != MessageType.link)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formattedTime,
                        style: themeManager.labelStyle.copyWith(
                          fontSize: 11,
                          color: message.isSent
                              ? AppColors.chatSentMessageTimestamp
                              : AppColors.chatReceivedMessageTimestamp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  bool _shouldShowDate(Message? previousMessage, Message currentMessage) {
    if (previousMessage == null) return true;

    final prevDate = previousMessage.timestamp;
    final currDate = currentMessage.timestamp;

    return prevDate.year != currDate.year || prevDate.month != currDate.month || prevDate.day != currDate.day;
  }

  void _showAttachmentOptions(BuildContext context) {
    // Save provider reference before showing bottom sheet
    final chatProvider = context.read<ChatProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    // Estimated input field height
    final inputFieldHeight = mediaQuery.padding.bottom + 12 + 50 + 8;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite.withOpacity(0),
      isScrollControlled: true,
      useSafeArea: false,
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16, // 👈 LEFT GAP
          right: 16, // 👈 RIGHT GAP
          bottom: inputFieldHeight + bottomPadding,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Drag handle
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(4)),
                ),

                /// Attachment options with border & spacing
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderGrayLight, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, // space from left/right border
                      vertical: 16, // space from top/bottom border
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAttachmentOption(
                          bottomSheetContext,
                          'assets/images/chat_gallery.svg',
                          AppStrings.gallery,
                          () {
                            Navigator.pop(bottomSheetContext);
                            _pickImage(context);
                          },
                        ),
                        _buildAttachmentOption(
                          bottomSheetContext,
                          'assets/images/chat_contact.svg',
                          AppStrings.contact,
                          () {
                            Navigator.pop(bottomSheetContext);
                            _pickContactWithProvider(context, chatProvider, scaffoldMessenger);
                          },
                        ),
                        _buildAttachmentOption(
                          bottomSheetContext,
                          'assets/images/chat_location.svg',
                          AppStrings.location,
                          () {
                            Navigator.pop(bottomSheetContext);
                            _getCurrentLocationWithProvider(context, chatProvider, scaffoldMessenger);
                          },
                        ),
                        _buildAttachmentOption(
                          bottomSheetContext,
                          'assets/images/chat_document.svg',
                          AppStrings.document,
                          () {
                            Navigator.pop(bottomSheetContext);
                            _pickDocumentWithProvider(context, chatProvider, scaffoldMessenger);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                //  const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(BuildContext context, String iconPath, String label, VoidCallback onTap) {
    final themeManager = ThemeManager();
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderGrayLight, width: 1),
                color: AppColors.backgroundWhite,
              ),
              child: SvgPicture.asset(iconPath, width: 24, height: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: themeManager.labelStyle.copyWith(color: AppColors.gray700, fontSize: 11, height: 1.0),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    // Save ScaffoldMessenger reference before showing modal
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.attachmentChooseFromGallery),
              onTap: () async {
                Navigator.pop(modalContext);
                try {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (image != null && mounted) {
                    _handleImageSelected(File(image.path));
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('${AppStrings.messageErrorSelectingImage} ${e.toString()}'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text(AppStrings.attachmentTakePhoto),
              onTap: () async {
                Navigator.pop(modalContext);
                try {
                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                  if (image != null && mounted) {
                    _handleImageSelected(File(image.path));
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('${AppStrings.messageErrorTakingPhoto} ${e.toString()}'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageSelected(File imageFile) {
    setState(() {
      _selectedImage = imageFile;
    });
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    // Save references before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final chatProvider = context.read<ChatProvider>();
    return _getCurrentLocationWithProvider(context, chatProvider, scaffoldMessenger);
  }

  Future<void> _getCurrentLocationWithProvider(
    BuildContext context,
    ChatProvider chatProvider,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      // Show loading indicator
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final locationService = di.sl<LocationService>();

      // Check if location services are enabled
      final isEnabled = await locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them in settings.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Request permission and get current position
      final position = await locationService.getCurrentPosition();

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (position == null) {
        // Check if permission is permanently denied
        final isPermanentlyDenied = await locationService.isPermissionPermanentlyDenied();
        if (isPermanentlyDenied) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppStrings.locationPermissionRequired),
                content: Text(AppStrings.locationPermissionDeniedMessage),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.cancel)),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await locationService.openAppSettings();
                    },
                    child: Text(AppStrings.openSettings),
                  ),
                ],
              ),
            );
          }
        } else {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(AppStrings.unableToGetLocation), duration: const Duration(seconds: 3)),
            );
          }
        }
        return;
      }

      // Create Google Maps link
      final googleMapsLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      // Send location as a message
      if (mounted) {
        chatProvider.sendMessage(googleMapsLink);
        _scrollToBottom();

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(AppStrings.locationSharedSuccessfully), duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if still open
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    // Save references before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final chatProvider = context.read<ChatProvider>();
    return _pickDocumentWithProvider(context, chatProvider, scaffoldMessenger);
  }

  Future<void> _pickDocumentWithProvider(
    BuildContext context,
    ChatProvider chatProvider,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        final fileSize = result.files.single.size;
        final fileExtension = fileName.split('.').last.toLowerCase();

        // Create SharedDocument
        final sharedDocument = SharedDocument(
          fileName: fileName,
          filePath: filePath,
          fileType: fileExtension,
          fileSize: fileSize,
        );

        if (mounted) {
          chatProvider.sendDocumentMessage('📄 $fileName', sharedDocument);
          _scrollToBottom();

          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Document selected: $fileName'), duration: const Duration(seconds: 2)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error selecting document: ${e.toString()}'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Future<void> _pickContact(BuildContext context) async {
    // Save references before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final chatProvider = context.read<ChatProvider>();
    return _pickContactWithProvider(context, chatProvider, scaffoldMessenger);
  }

  Future<void> _pickContactWithProvider(
    BuildContext context,
    ChatProvider chatProvider,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      Contact? contact = await _contactPicker.selectContact();

      if (!mounted) return;

      if (contact != null) {
        try {
          // Format contact information
          final contactName = contact.fullName?.trim() ?? AppStrings.unknown;

          // Safely access phone numbers
          List<String> phoneNumbers = [];
          try {
            final phones = contact.phoneNumbers;
            if (phones != null && phones.isNotEmpty) {
              for (var phoneNumber in phones) {
                try {
                  final phone = phoneNumber.trim();
                  if (phone.isNotEmpty) {
                    phoneNumbers.add(phone);
                  }
                } catch (e) {
                  debugPrint('Error processing phone number: $e');
                }
              }
            }
          } catch (e) {
            debugPrint('Error accessing phone numbers: $e');
          }

          // Create SharedContact
          // Note: flutter_native_contact_picker doesn't provide email or avatar
          final sharedContact = SharedContact(
            name: contactName,
            primaryPhone: phoneNumbers.isNotEmpty ? phoneNumbers.first : null,
            phoneNumbers: phoneNumbers,
            email: null, // Contact picker doesn't provide email
            avatarUrl: null, // Contact picker doesn't provide avatar
          );

          // Send contact as message
          if (!mounted) return;

          chatProvider.sendContactMessage('👤 $contactName', sharedContact);

          // Use a small delay to ensure the message is added before scrolling
          await Future.delayed(const Duration(milliseconds: 100));

          if (!mounted) return;
          _scrollToBottom();

          if (!mounted) return;
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Contact shared: $contactName'), duration: const Duration(seconds: 2)),
          );
        } catch (e, stackTrace) {
          debugPrint('Error formatting contact: $e');
          debugPrint('Stack trace: $stackTrace');
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Error processing contact: ${e.toString()}'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error selecting contact: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error selecting contact: ${e.toString()}'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }
}
