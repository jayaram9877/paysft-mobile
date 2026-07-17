import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/property_details_model.dart';
import '../../widgets/common/app_svg_icon.dart';

/// Canonical public URL for a property. This is the App Links / Universal Links
/// domain: it opens the app when installed, and falls back to the web otherwise.
String _propertyShareUrl(String projectId) =>
    'https://links.paysft.com/projects/$projectId';

/// Share modal widget for sharing property details
/// Follows the existing architecture pattern with theme-aware design
class ShareModal extends StatelessWidget {
  final PropertyDetailsModel property;

  const ShareModal({super.key, required this.property});

  /// Opens the OS native share sheet (WhatsApp, Messages, Gmail, …).
  Future<void> _shareViaApps(BuildContext context) async {
    final url = _propertyShareUrl(property.id);
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      '${property.title} — ${property.location}\n$url',
      subject: property.title,
      sharePositionOrigin:
          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 60, offset: const Offset(6, 6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle (no side padding)
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 6,
            decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(50)),
          ),

          // 🔹 Top gap to title = 24px
          const SizedBox(height: 24),

          // 🔹 Title with only horizontal padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Share with Family & Friends', style: themeManager.titleStyle),
          ),

          const SizedBox(height: 16),

          // Primary action: native OS share sheet (covers WhatsApp, SMS, email…).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareViaApps(context),
                icon: const Icon(Icons.ios_share, size: 18),
                label: const Text('Share', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Share options (16px on all sides)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity, // 👈 KEY FIX
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.default200),
                color: AppColors.default50,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ShareOption.values.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 icons per row
                  crossAxisSpacing: 24, // horizontal gap
                  mainAxisSpacing: 24, // vertical gap
                  childAspectRatio: 1, // square cells
                ),
                itemBuilder: (context, index) {
                  final option = _ShareOption.values[index];
                  return _ShareOptionItem(option: option, property: property);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ShareOption { copyLink, facebook, instagram, linkedin, pinterest, twitter, telegram, discord }

class _ShareOptionItem extends StatelessWidget {
  final _ShareOption option;
  final PropertyDetailsModel property;

  const _ShareOptionItem({required this.option, required this.property});

  String get _iconPath {
    switch (option) {
      case _ShareOption.copyLink:
        return 'assets/images/ic_copylink.svg';
      case _ShareOption.facebook:
        return 'assets/images/ic_facebook.svg';
      case _ShareOption.instagram:
        return 'assets/images/ic_instagram.svg';
      case _ShareOption.linkedin:
        return 'assets/images/ic_linkedin.svg';
      case _ShareOption.pinterest:
        return 'assets/images/ic_pinterest.svg';
      case _ShareOption.twitter:
        return 'assets/images/ic_x.svg';
      case _ShareOption.telegram:
        return 'assets/images/ic_telegram.svg';
      case _ShareOption.discord:
        return 'assets/images/ic_discord.svg';
    }
  }

  String get _appName {
    switch (option) {
      case _ShareOption.copyLink:
        return AppStrings.shareClipboard;
      case _ShareOption.facebook:
        return AppStrings.shareFacebook;
      case _ShareOption.instagram:
        return AppStrings.shareInstagram;
      case _ShareOption.linkedin:
        return AppStrings.shareLinkedIn;
      case _ShareOption.pinterest:
        return AppStrings.sharePinterest;
      case _ShareOption.twitter:
        return 'X';
      case _ShareOption.telegram:
        return AppStrings.shareTelegram;
      case _ShareOption.discord:
        return AppStrings.shareDiscord;
    }
  }

  String _getShareUrl() => _propertyShareUrl(property.id);

  String _getShareText() {
    return '${property.title} - ${property.location}';
  }

  Future<String?> _getPlatformShareUrl() async {
    final shareUrl = _getShareUrl();
    final text = _getShareText();
    final encodedText = Uri.encodeComponent(text);
    final encodedUrl = Uri.encodeComponent(shareUrl);

    switch (option) {
      case _ShareOption.copyLink:
        return shareUrl;
      case _ShareOption.facebook:
        // Try native app first, fallback to web
        return 'fb://share?href=$encodedUrl';
      case _ShareOption.instagram:
        // Instagram doesn't support direct URL sharing via URL scheme
        // Will try to open app, fallback handled in launch logic
        return 'instagram://';
      case _ShareOption.linkedin:
        return 'linkedin://shareArticle?url=$encodedUrl';
      case _ShareOption.pinterest:
        return 'pinterest://pin/create/button/?url=$encodedUrl&description=$encodedText';
      case _ShareOption.twitter:
        // X/Twitter
        return 'twitter://post?message=$encodedText%20$encodedUrl';
      case _ShareOption.telegram:
        return 'tg://msg_url?url=$encodedUrl&text=$encodedText';
      case _ShareOption.discord:
        // Discord doesn't have a direct share URL scheme
        return 'discord://';
    }
  }

  String _getWebFallbackUrl() {
    final shareUrl = _getShareUrl();
    final text = _getShareText();
    final encodedText = Uri.encodeComponent(text);
    final encodedUrl = Uri.encodeComponent(shareUrl);

    switch (option) {
      case _ShareOption.copyLink:
        return shareUrl;
      case _ShareOption.facebook:
        return 'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl';
      case _ShareOption.instagram:
        // Instagram web doesn't support direct sharing, return null
        return '';
      case _ShareOption.linkedin:
        return 'https://www.linkedin.com/sharing/share-offsite/?url=$encodedUrl';
      case _ShareOption.pinterest:
        return 'https://pinterest.com/pin/create/button/?url=$encodedUrl&description=$encodedText';
      case _ShareOption.twitter:
        return 'https://twitter.com/intent/tweet?text=$encodedText&url=$encodedUrl';
      case _ShareOption.telegram:
        return 'https://t.me/share/url?url=$encodedUrl&text=$encodedText';
      case _ShareOption.discord:
        // Discord web doesn't support direct sharing
        return '';
    }
  }

  Future<void> _handleShare(BuildContext context) async {
    try {
      if (option == _ShareOption.copyLink) {
        // Copy to clipboard
        final shareUrl = _getShareUrl();
        await Clipboard.setData(ClipboardData(text: shareUrl));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.linkCopiedToClipboard), duration: const Duration(seconds: 2)),
          );
        }
        Navigator.of(context).pop();
        return;
      }

      // Try native app URL first
      final nativeUrl = await _getPlatformShareUrl();
      bool launched = false;

      if (nativeUrl != null && nativeUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(nativeUrl);
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          // Native app not available, try web fallback
          launched = false;
        }
      }

      // If native app failed, try web fallback
      if (!launched) {
        final webUrl = _getWebFallbackUrl();
        if (webUrl.isNotEmpty) {
          try {
            final uri = Uri.parse(webUrl);
            if (await canLaunchUrl(uri)) {
              launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            launched = false;
          }
        }
      }

      if (launched) {
        // Close modal after successful launch
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // App not installed or URL cannot be launched
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$_appName is not installed'), duration: const Duration(seconds: 2)));
        }
      }
    } catch (e) {
      // Handle any errors
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$_appName is not installed'), duration: const Duration(seconds: 2)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleShare(context),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: AppSvgIcon(assetPath: _iconPath, width: 24, height: 24, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
