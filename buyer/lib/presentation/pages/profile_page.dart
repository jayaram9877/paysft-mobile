import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/profile_provider.dart';
import '../widgets/common/app_svg_icon.dart';
import 'web_view_page.dart';
import 'notification_settings_page.dart';
import 'phone_login_page.dart';
import 'security_privacy_page.dart';
import 'documents_page.dart';
import 'transactions_page.dart';
import 'edit_profile_page.dart';
import 'contact_support_page.dart';
import 'help_center_page.dart';
import 'email_us_page.dart';
import 'about_paysft_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Summary metrics have no backend aggregate endpoint yet (placeholders).
  final int _propertiesCount = 3;
  final String _totalPaid = '₹75L';
  final String _pending = '₹12L';
  final int _utilitiesDue = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileProvider>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final profile = context.watch<ProfileProvider>().profile;

    final userName =
        (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName : 'Guest User';
    final userSubtitle = (profile?.mobile != null && profile!.mobile!.isNotEmpty)
        ? profile.mobile!
        : (profile?.email ?? '');
    final avatarUrl = profile?.avatarUrl;
    final isVerified =
        (profile?.mobileVerified ?? false) || (profile?.emailVerified ?? false);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildProfileHeader(
                  themeManager,
                  name: userName,
                  subtitle: userSubtitle,
                  avatarUrl: avatarUrl,
                  isVerified: isVerified,
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: null,
                  bottom: -65, // Overlap by 40px
                  child: _buildSummaryCard(themeManager),
                ),
              ],
            ),
            const SizedBox(height: 94), // 24px spacing + 40px for overlap
            _buildPropertyManagementSection(themeManager),
            const SizedBox(height: 24),
            _buildAccountSettingsSection(themeManager),
            const SizedBox(height: 24),
            _buildSupportSection(themeManager),
            const SizedBox(height: 24),
            _buildLegalSection(themeManager),
            const SizedBox(height: 32),
            _buildVersionInfo(themeManager),
            const SizedBox(height: 16),
            _buildLogoutButton(themeManager),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    ThemeManager themeManager, {
    required String name,
    required String subtitle,
    String? avatarUrl,
    required bool isVerified,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 0,
        bottom: 57, // 🔑 IMPORTANT: space for overlapping metrics card
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.blueProfileStart, AppColors.blueProfileEnd],
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),

            /// Profile label
            Text(AppStrings.profile, style: themeManager.profileLabelStyle),

            const SizedBox(height: 16),

            /// Profile icon + details
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    image: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: themeManager.profileAvatarInitialStyle,
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                /// Name + phone + chip
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: themeManager.profileNameStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      if (subtitle.isNotEmpty)
                        Text(subtitle, style: themeManager.profilePhoneStyle),

                      if (isVerified) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.textWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.textWhite.withOpacity(0.3)),
                          ),
                          child: Text(AppStrings.verifiedAccount, style: themeManager.verifiedAccountBadgeStyle),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.textBlack.withOpacity(0.05), blurRadius: 8, offset: const Offset(1, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(themeManager, value: _propertiesCount.toString(), label: AppStrings.properties),
          Container(width: 1, height: 40, color: AppColors.borderDivider),
          _buildSummaryItem(themeManager, value: _totalPaid, label: AppStrings.totalPaid),
          Container(width: 1, height: 40, color: AppColors.borderDivider),
          _buildSummaryItem(themeManager, value: _pending, label: AppStrings.pending),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(ThemeManager themeManager, {required String value, required String label}) {
    return Column(
      children: [
        Text(value, style: themeManager.summaryValueStyle),
        const SizedBox(height: 4),
        Text(label, style: themeManager.summaryLabelStyle),
      ],
    );
  }

  Widget _buildPropertyManagementSection(ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.propertyManagement, style: themeManager.sectionHeaderStyle),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDivider, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 204, 188, 188).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(1, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildPropertyManagementItem(
                  themeManager,
                  iconPath: 'assets/images/profile_documents.svg',
                  title: AppStrings.documents,
                  subtitle: AppStrings.documentsSubtitle,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsPage()));
                  },
                ),
                const Divider(height: 1, color: AppColors.borderDivider),
                _buildPropertyManagementItem(
                  themeManager,
                  iconPath: 'assets/images/profile_transactions.svg',
                  title: AppStrings.transactions,
                  subtitle: AppStrings.transactionsSubtitle,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
                  },
                ),
                const Divider(height: 1, color: AppColors.borderDivider),
                _buildPropertyManagementItem(
                  themeManager,
                  iconPath: 'assets/images/profile_utilities.svg',
                  title: AppStrings.utilities,
                  subtitle: AppStrings.utilitiesSubtitle,
                  badge: _utilitiesDue > 0 ? '$_utilitiesDue ${AppStrings.due}' : null,
                  isDue: true,
                  onTap: () {
                    // TODO: Navigate to utilities page
                    final themeManager = ThemeManager();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.utilitiesComingSoon, style: themeManager.snackBarTextStyle)),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyManagementItem(
    ThemeManager themeManager, {
    required String iconPath,
    required String title,
    required String subtitle,
    String? badge,
    bool isDue = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72), // Consistent minimum height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppSvgIcon(assetPath: iconPath, width: 36, height: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: themeManager.sectionItemMainStyle),
                  const SizedBox(height: 4),
                  Text(subtitle, style: themeManager.sectionItemTagStyle),
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDue ? AppColors.dueBackground : AppColors.primaryBlue,
                  border: isDue ? Border.all(color: AppColors.dueBorder, width: 1) : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge, style: isDue ? themeManager.badgeDueTextStyle : themeManager.badgeTextStyle),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: AppColors.textSecondaryGray, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsSection(ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.accountSettings, style: themeManager.sectionHeaderStyle),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDivider, width: 0.5),
              boxShadow: [
                BoxShadow(color: AppColors.textBlack.withOpacity(0.05), blurRadius: 8, offset: const Offset(1, 8)),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  themeManager,
                  iconPath: 'assets/images/profile_edit_profile.svg',
                  title: AppStrings.editProfile,
                  onTap: _editProfile,
                ),
                const Divider(height: 1, color: AppColors.borderDivider),
                _buildSettingsItem(
                  themeManager,
                  iconPath: 'assets/images/profile_notifications.svg',
                  title: AppStrings.notifications,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage()));
                  },
                ),
                const Divider(height: 1, color: AppColors.borderDivider),
                _buildSettingsItem(
                  themeManager,
                  iconPath: 'assets/images/profile_security_privacy.svg',
                  title: AppStrings.securityPrivacyTitle,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPrivacyPage()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.support, style: themeManager.sectionHeaderStyle),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDivider, width: 0.5),
              boxShadow: [
                BoxShadow(color: AppColors.textBlack.withOpacity(0.05), blurRadius: 8, offset: const Offset(1, 8)),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  themeManager,
                  iconPath: 'assets/images/profile_contact_support.svg',
                  title: AppStrings.contactSupport,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportPage()));
                  },
                ),
                const Divider(height: 1, color: AppColors.borderDivider),
                _buildSettingsItem(
                  themeManager,
                  iconPath: 'assets/images/profile_help_center.svg',
                  title: AppStrings.helpCenter,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()));
                  },
                ),
                const Divider(height: 1, color: AppColors.borderDivider),
                _buildEmailItem(themeManager),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.legal, style: themeManager.sectionHeaderStyle),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDivider, width: 0.5),
              boxShadow: [
                BoxShadow(color: AppColors.textBlack.withOpacity(0.05), blurRadius: 8, offset: const Offset(1, 8)),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  themeManager,
                  icon: null,
                  title: AppStrings.termsConditions,
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
                _buildSettingsItem(
                  themeManager,
                  icon: null,
                  title: AppStrings.privacyPolicyTitle,
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
                _buildSettingsItem(
                  themeManager,
                  icon: null,
                  title: AppStrings.aboutPaySFT,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPaySFTPage()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    ThemeManager themeManager, {
    IconData? icon,
    String? iconPath,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72), // Consistent minimum height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryGray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 26, color: AppColors.textSecondaryGray),
              ),
              const SizedBox(width: 16),
            ] else if (iconPath != null) ...[
              AppSvgIcon(assetPath: iconPath, width: 36, height: 36),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title,
                style: isDestructive ? themeManager.destructiveSectionItemStyle : themeManager.sectionItemMainStyle,
              ),
            ),
            if (!isDestructive) const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailItem(ThemeManager themeManager) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailUsPage()));
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 72), // Consistent minimum height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppSvgIcon(assetPath: 'assets/images/profile_emailus.svg', width: 36, height: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.emailUs, style: themeManager.sectionItemMainStyle),
                  const SizedBox(height: 4),
                  Text(AppStrings.supportEmail, style: themeManager.sectionItemTagStyle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(ThemeManager themeManager) {
    return Center(child: Text(AppStrings.versionNumber, style: themeManager.versionStyle));
  }

  Widget _buildLogoutButton(ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton(
        onPressed: () => _showLogoutConfirmation(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.logoutBorder, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with SVG when profile_logout.svg is added
            const Icon(Icons.logout, color: AppColors.logoutRed, size: 20),
            const SizedBox(width: 8),
            Text(AppStrings.logout, style: themeManager.logoutButtonTextStyle),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
  }
}

void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final themeManager = ThemeManager();
      return AlertDialog(
        title: Text(AppStrings.logoutTitle, style: themeManager.dialogTitleStyle),
        content: Text(AppStrings.logoutMessage, style: themeManager.dialogContentStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel, style: themeManager.dialogButtonTextStyle),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleLogout(context);
            },
            child: Text(AppStrings.logout, style: themeManager.errorTextStyle),
          ),
        ],
      );
    },
  );
}

void _showDeleteAccountConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final themeManager = ThemeManager();
      return AlertDialog(
        title: Text(AppStrings.deleteAccountTitle, style: themeManager.dialogTitleStyle),
        content: Text(AppStrings.deleteAccountMessage, style: themeManager.dialogContentStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel, style: themeManager.dialogButtonTextStyle),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleDeleteAccount(context);
            },
            child: Text(AppStrings.delete, style: themeManager.errorTextStyle),
          ),
        ],
      );
    },
  );
}

void _handleLogout(BuildContext context) {
  // Best-effort backend logout + clear local session (fire and forget).
  context.read<ProfileProvider>().logout();

  // Navigate to login page
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const PhoneLoginPage()), (route) => false);
}

void _handleDeleteAccount(BuildContext context) {
  context.read<ProfileProvider>().logout();

  // Navigate to login page
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const PhoneLoginPage()), (route) => false);

  final themeManager = ThemeManager();
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(AppStrings.accountDeletedSuccessfully, style: themeManager.snackBarTextStyle)));
}
