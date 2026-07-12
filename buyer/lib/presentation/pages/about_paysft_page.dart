import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/common/app_svg_icon.dart';

class AboutPaySFTPage extends StatelessWidget {
  const AboutPaySFTPage({super.key});

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
            child: Text(AppStrings.aboutPaySFT, style: themeManager.editProfileTitleStyle),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildTopSection(themeManager),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildOurMissionSection(themeManager),
                  const SizedBox(height: 24),
                  _buildWhyChoosePaySFTSection(themeManager),
                  const SizedBox(height: 24),
                  _buildOurImpactSection(themeManager),
                  const SizedBox(height: 24),
                  _buildCompanyInformationSection(themeManager),
                  const SizedBox(height: 24),
                  _buildGetInTouchSection(themeManager),
                  const SizedBox(height: 24),
                  _buildOurCommitmentSection(themeManager),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0), // 16 left/right, 24 top
      child: Container(
        width: double.infinity, // takes full width
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.10), width: 1),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blueProfileStart, AppColors.blueProfileEnd],
          ),
        ),
        child: Column(
          children: [
            AppSvgIcon(assetPath: 'assets/images/about_paysft_verion.svg', width: 80, height: 80),
            const SizedBox(height: 16),
            Text('PaySFT', style: themeManager.aboutPaySFTTitleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Secure. Fast. Transparent.',
              style: themeManager.aboutPaySFTSubtitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text('Version 1.0.0', style: themeManager.aboutPaySFTVersionStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildOurMissionSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Our Mission', style: themeManager.aboutPaySFTSectionTitleStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGray20, width: 1),
            boxShadow: themeManager.contactSupportSectionShadowStyle,
          ),
          child: Text(
            'PaySFT is revolutionizing real estate transactions in India by providing a secure, transparent, and buyer-friendly platform. We combine RERA compliance with cutting-edge technology to ensure every property purchase is safe, seamless, and stress-free.',
            style: themeManager.aboutPaySFTMissionTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildWhyChoosePaySFTSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why Choose PaySFT', style: themeManager.aboutPaySFTSectionTitleStyle),
        const SizedBox(height: 16),
        _buildFeatureCard(
          themeManager,
          iconPath: 'assets/images/about_paysft_escrowprotection.svg',
          title: 'ESCROW Protection',
          description:
              'Your funds are secured in RERA-compliant ESCROW accounts, released only when construction milestones are met.',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          themeManager,
          iconPath: 'assets/images/about_paysft_reracomplaince.svg',
          title: 'RERA Compliance',
          description: 'All properties are verified for RERA registration and compliance with regulatory standards.',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          themeManager,
          iconPath: 'assets/images/about_paysft_dedicatedsupport.svg',
          title: 'Dedicated Support',
          description:
              'Get assigned a relationship manager who guides you through every step of your property journey.',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          themeManager,
          iconPath: 'assets/images/about_paysft_fulltransparency.svg',
          title: 'Full Transparency',
          description: 'Track every payment, document, and construction update in real-time from your dashboard.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    ThemeManager themeManager, {
    required String iconPath,
    required String title,
    required String description,
  }) {
    return Container(
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
          AppSvgIcon(assetPath: iconPath, width: 36, height: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: themeManager.aboutPaySFTFeatureTitleStyle),
                const SizedBox(height: 4),
                Text(description, style: themeManager.aboutPaySFTFeatureDescriptionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOurImpactSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Our Impact', style: themeManager.aboutPaySFTSectionTitleStyle),
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
            children: [
              Expanded(
                child: _buildImpactItem(
                  themeManager,
                  value: '15,000+',
                  label: 'Happy Buyers',
                  color: AppColors.impactBlue,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.borderDivider),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImpactItem(
                  themeManager,
                  value: '₹2,500Cr+',
                  label: 'Secured in ESCROW',
                  color: AppColors.impactGreen,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.borderDivider),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImpactItem(
                  themeManager,
                  value: '500+',
                  label: 'Properties',
                  color: AppColors.impactPurple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactItem(
    ThemeManager themeManager, {
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: themeManager.aboutPaySFTImpactValueStyle.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: themeManager.aboutPaySFTImpactLabelStyle),
      ],
    );
  }

  Widget _buildCompanyInformationSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Company Information', style: themeManager.aboutPaySFTSectionTitleStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGray20, width: 1),
            boxShadow: themeManager.contactSupportSectionShadowStyle,
          ),
          child: Column(
            children: [
              _buildCompanyInfoItem(
                themeManager,
                label: 'Company Name',
                value: 'PaySFT Technologies Private Limited',
                isFirst: true,
              ),
              Divider(height: 1, color: Colors.black.withOpacity(0.10)),
              _buildCompanyInfoItem(themeManager, label: 'Founded', value: '2023'),
              Divider(height: 1, color: Colors.black.withOpacity(0.10)),
              _buildCompanyInfoItem(themeManager, label: 'Headquarters', value: 'Bangalore, Karnataka, India'),
              Divider(height: 1, color: Colors.black.withOpacity(0.10)),
              _buildCompanyInfoItem(
                themeManager,
                label: 'Regulatory',
                value: 'RERA Certified | RBI Registered Payment Gateway',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfoItem(
    ThemeManager themeManager, {
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 16 : 12, bottom: isLast ? 16 : 12, left: 0, right: 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: themeManager.aboutPaySFTCompanyLabelStyle),
              const SizedBox(height: 4),
              Text(value, style: themeManager.aboutPaySFTCompanyValueStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGetInTouchSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Get in Touch', style: themeManager.aboutPaySFTSectionTitleStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGray20, width: 1),
            boxShadow: themeManager.contactSupportSectionShadowStyle,
          ),
          child: Column(
            children: [
              _buildContactItem(
                themeManager,
                iconPath: 'assets/images/about_paysft_website.svg',
                label: 'Website',
                value: 'www.paysft.com',
                isFirst: true,
                isLast: true,
                onTap: () async {
                  final uri = Uri.parse('https://www.paysft.com');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              _buildContactItem(
                themeManager,
                iconPath: 'assets/images/about_paysft_email.svg',
                label: 'Email',
                value: 'info@paysft.com',
                isFirst: false,
                isLast: true,
                onTap: () async {
                  final uri = Uri(scheme: 'mailto', path: 'info@paysft.com');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    ThemeManager themeManager, {
    required String iconPath,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: isFirst ? 16 : 12, bottom: isLast ? 16 : 12, left: 0, right: 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              AppSvgIcon(assetPath: iconPath, width: 20, height: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: themeManager.aboutPaySFTContactLabelStyle),
                    const SizedBox(height: 4),
                    Text(value, style: themeManager.aboutPaySFTContactValueStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOurCommitmentSection(ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.transactionGreen40, width: 1),
        color: AppColors.transactionGreen10,
        boxShadow: [
          BoxShadow(color: AppColors.greenShadow.withOpacity(0.14), blurRadius: 24, offset: const Offset(0, 14)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // 👈 center vertically
        children: [
          AppSvgIcon(assetPath: 'assets/images/about_paysft_ourcommitment.svg', width: 36, height: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Our Commitment', style: themeManager.aboutPaySFTCommitmentTitleStyle),
                const SizedBox(height: 8),
                Text(
                  'We\'re committed to making home ownership accessible, transparent, and secure for every Indian family. Together, we\'re building a better future.',
                  style: themeManager.aboutPaySFTCommitmentDescriptionStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
