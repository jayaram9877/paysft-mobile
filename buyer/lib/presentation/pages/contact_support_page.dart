import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/common/app_svg_icon.dart';
import 'help_center_page.dart';
import 'email_us_page.dart';

class ContactSupportPage extends StatelessWidget {
  const ContactSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: AppSvgIcon(assetPath: 'assets/images/profile_back.svg', width: 24, height: 24),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
        leadingWidth: 40,
        title: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(AppStrings.contactSupport, style: themeManager.editProfileTitleStyle),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(color: AppColors.borderDivider, boxShadow: themeManager.appBarDividerShadowStyle),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildGetInTouchSection(context, themeManager),
            const SizedBox(height: 24),
            _buildOfficeHoursSection(themeManager),
            const SizedBox(height: 24),
            _buildQuickHelpSection(context, themeManager),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGetInTouchSection(BuildContext context, ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Get in Touch', style: themeManager.contactSupportSectionTitleStyle),
        const SizedBox(height: 16),
        _buildContactOption(
          context,
          themeManager,
          iconPath: 'assets/images/contact_support_call.svg',
          title: 'Call Us',
          subtitle: '1800-123-4567 (Toll Free)',
          description: 'Mon - Sat',
          time: '9 AM - 6 PM',
          onTap: () async {
            final uri = Uri.parse('tel:18001234567');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildContactOption(
          context,
          themeManager,
          iconPath: 'assets/images/contact_support_email.svg',
          title: 'Email Us',
          subtitle: 'support@paysft.com',
          description: 'We\'ll respond within 24 hours',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailUsPage()));
          },
        ),
        const SizedBox(height: 12),
        _buildContactOption(
          context,
          themeManager,
          iconPath: 'assets/images/contact_support_chat.svg',
          title: 'Live Chat',
          subtitle: 'Chat with our support team',
          isOnline: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live chat feature coming soon')));
          },
        ),
      ],
    );
  }

  Widget _buildContactOption(
    BuildContext context,
    ThemeManager themeManager, {
    required String iconPath,
    required String title,
    required String subtitle,
    String? description,
    String? time,
    bool isOnline = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGray20, width: 1),
          boxShadow: themeManager.contactSupportSectionShadowStyle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1️⃣ Top section — Icon + Title + Subtitle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSvgIcon(assetPath: iconPath, width: 36, height: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: themeManager.contactSupportPrimaryTextStyle),
                      const SizedBox(height: 4),
                      Text(subtitle, style: themeManager.contactSupportSecondaryTextStyle),
                    ],
                  ),
                ),
              ],
            ),

            /// 2️⃣ Divider (same leading edge as icon)
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderDivider),
            const SizedBox(height: 12),

            /// 3️⃣ Bottom section — Description / Time / Online badge
            Row(
              children: [
                if (description != null)
                  Expanded(child: Text(description, style: themeManager.contactSupportDescriptionTextStyle)),

                if (time != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(time, style: themeManager.contactSupportTimeTextStyle),
                  ),

                if (isOnline) ...[
                  if (description != null || time != null) const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.transactionGreen40, width: 1),
                      color: AppColors.transactionGreen10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.transactionGreenStart,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('Online now', style: themeManager.contactSupportBadgeTextStyle),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeHoursSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Office Hours', style: themeManager.contactSupportSectionTitleStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGray20, width: 1),
            boxShadow: themeManager.contactSupportSectionShadowStyle,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSvgIcon(assetPath: 'assets/images/contact_support_office_hours.svg', width: 20, height: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOfficeHoursItem(
                      themeManager,
                      day: 'Monday - Friday',
                      time: '9:00 AM - 6:00 PM',
                      isFirst: true,
                    ),
                    _buildOfficeHoursItem(themeManager, day: 'Saturday', time: '10:00 AM - 4:00 PM', isFirst: false),
                    _buildOfficeHoursItem(themeManager, day: 'Sunday', time: 'Closed', isFirst: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfficeHoursItem(
    ThemeManager themeManager, {
    required String day,
    required String time,
    required bool isFirst,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 4, bottom: 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 0),
        child: Row(
          children: [
            Expanded(child: Text(day, style: themeManager.contactSupportOfficeHoursDayStyle)),
            Text(time, style: themeManager.contactSupportOfficeHoursTimeStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpSection(BuildContext context, ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBlueLight, width: 1),
        color: AppColors.backgroundBlueLight,
        boxShadow: [
          BoxShadow(color: const Color(0xFF69BDEE).withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 1️⃣ Top section (Icon + content)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSvgIcon(assetPath: 'assets/images/contact_support_quick_help.svg', width: 20, height: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Help', style: themeManager.contactSupportQuickHelpTitleStyle),
                    const SizedBox(height: 12),
                    Text(
                      'For faster assistance, visit our Help Center for instant answers to common questions.',
                      style: themeManager.contactSupportQuickHelpDescriptionStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// 2️⃣ Button aligned with image leading edge
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()));
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.backgroundWhite,
                side: const BorderSide(color: AppColors.borderGray20, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Visit Help Center', style: themeManager.contactSupportQuickHelpButtonStyle),
            ),
          ),
        ],
      ),
    );
  }
}
