import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/common/app_svg_icon.dart';
import 'web_view_page.dart';

class SecurityPrivacyPage extends StatefulWidget {
  const SecurityPrivacyPage({super.key});

  @override
  State<SecurityPrivacyPage> createState() => _SecurityPrivacyPageState();
}

class _SecurityPrivacyPageState extends State<SecurityPrivacyPage> {
  // Privacy Settings (Activity Status only)
  bool _activityStatus = true;

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
            child: Text(AppStrings.securityPrivacy, style: themeManager.editProfileTitleStyle),
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
            _buildAccountSecurityBanner(themeManager),
            const SizedBox(height: 24),
            _buildPrivacySettingsSection(themeManager),
            const SizedBox(height: 24),
            _buildDataPrivacySection(themeManager),
            const SizedBox(height: 24),
            _buildSecurityTipSection(themeManager),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSecurityBanner(ThemeManager themeManager) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.securityGreen10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.securityGreen40, width: 1),
        boxShadow: themeManager.accountSecureShadowStyle,
      ),
      child: Row(
        children: [
          AppSvgIcon(assetPath: 'assets/images/security_account_secure.svg', width: 36, height: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Account Secure', style: themeManager.accountSecureTitleStyle),
                const SizedBox(height: 4),
                Text('All security features are enabled', style: themeManager.accountSecureSubtitleStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettingsSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Privacy Settings', style: themeManager.notificationSectionTitleStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGray40, width: 1),
            boxShadow: themeManager.editProfileSectionShadowStyle,
          ),
          child: Column(
            children: [
              _buildPrivacyOption(
                themeManager,
                title: 'Activity Status',
                subtitle: 'Show when you\'re active',
                value: _activityStatus,
                onChanged: (value) => setState(() => _activityStatus = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyOption(
    ThemeManager themeManager, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: themeManager.notificationOptionPrimaryStyle),
                  const SizedBox(height: 4),
                  Text(subtitle, style: themeManager.notificationOptionSecondaryStyle),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.notificationToggleActive,
              activeThumbColor: AppColors.backgroundWhite,
              inactiveThumbColor: AppColors.backgroundWhite,
              inactiveTrackColor: AppColors.notificationToggleInactive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPrivacySection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data & Privacy', style: themeManager.notificationSectionTitleStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGray40, width: 1),
            boxShadow: themeManager.editProfileSectionShadowStyle,
          ),
          child: Column(
            children: [
              _buildDataPrivacyOption(
                themeManager,
                title: 'Download Your Data',
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Download data feature coming soon')));
                },
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildDataPrivacyOption(
                themeManager,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WebViewPage(title: AppStrings.privacyPolicyTitle, url: 'https://example.com/privacy'),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildDataPrivacyOption(
                themeManager,
                title: 'Delete Account',
                isDestructive: true,
                onTap: () {
                  // Show delete account confirmation
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text('Delete Account', style: themeManager.dialogTitleStyle),
                      content: Text(
                        'Are you sure you want to delete your account? This action cannot be undone.',
                        style: themeManager.dialogContentStyle,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text('Cancel', style: themeManager.dialogButtonTextStyle),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(const SnackBar(content: Text('Account deletion feature coming soon')));
                          },
                          child: Text('Delete', style: themeManager.errorTextStyle),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataPrivacyOption(
    ThemeManager themeManager, {
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: isDestructive
                      ? themeManager.deleteAccountTextStyle
                      : themeManager.notificationOptionPrimaryStyle,
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textGray70, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTipSection(ThemeManager themeManager) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.securityTipYellowBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.securityTipYellowBorder, width: 1),
        boxShadow: themeManager.securityTipShadowStyle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // keep start
        children: [
          AppSvgIcon(assetPath: 'assets/images/security_security_tip.svg', width: 32, height: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ❌ remove MainAxisAlignment.center
              children: [
                Text('Security Tip', style: themeManager.securityTipTitleStyle),
                const SizedBox(height: 4),
                Text(
                  'Enable two-factor authentication and use a strong password to keep your account secure.',
                  style: themeManager.securityTipDescriptionStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
