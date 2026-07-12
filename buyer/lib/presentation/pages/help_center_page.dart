import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/common/app_svg_icon.dart';
import '../widgets/common/app_search_field.dart';
import 'contact_support_page.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<HelpItem> _allItems = [];
  List<HelpItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _initializeHelpItems();
    _filteredItems = _allItems;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initializeHelpItems() {
    _allItems.addAll([
      // Payments & ESCROW section
      HelpItem(title: 'How does ESCROW account work?', section: 'Payments & ESCROW'),
      HelpItem(title: 'What payment methods are accepted?', section: 'Payments & ESCROW'),
      HelpItem(title: 'How do I track my payments?', section: 'Payments & ESCROW'),
      HelpItem(title: 'Can I get a refund?', section: 'Payments & ESCROW'),

      // Property Purchase section
      HelpItem(title: 'What is token payment?', section: 'Property Purchase'),
      HelpItem(title: 'How to choose the right property', section: 'Property Purchase'),
      HelpItem(title: 'What documents do I need?', section: 'Property Purchase'),
      HelpItem(title: 'When will I get possession?', section: 'Property Purchase'),

      // Account & Security section
      HelpItem(title: 'How to update profile information?', section: 'Account & Security'),
      HelpItem(title: 'How to change my password?', section: 'Account & Security'),
      HelpItem(title: 'What is two-factor authentication?', section: 'Account & Security'),
      HelpItem(title: 'How to enable biometric login?', section: 'Account & Security'),

      // Documents & Legal section
      HelpItem(title: 'How to download documents?', section: 'Documents & Legal'),
      HelpItem(title: 'What is e-signature?', section: 'Documents & Legal'),
      HelpItem(title: 'Are digital signatures legally valid?', section: 'Documents & Legal'),
      HelpItem(title: 'How to get property deed?', section: 'Documents & Legal'),
    ]);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) => item.title.toLowerCase().contains(query)).toList();
      }
    });
  }

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
            child: Text(AppStrings.helpCenter, style: themeManager.editProfileTitleStyle),
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
      body: Column(
        children: [
          _buildSearchBar(themeManager),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildQuickLinksSection(themeManager),
                  if (_filteredItems.any((item) => item.section == 'Payments & ESCROW')) ...[
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      themeManager,
                      'Payments & ESCROW',
                      _filteredItems.where((item) => item.section == 'Payments & ESCROW').toList(),
                    ),
                  ],
                  if (_filteredItems.any((item) => item.section == 'Property Purchase')) ...[
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      themeManager,
                      'Property Purchase',
                      _filteredItems.where((item) => item.section == 'Property Purchase').toList(),
                    ),
                  ],
                  if (_filteredItems.any((item) => item.section == 'Account & Security')) ...[
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      themeManager,
                      'Account & Security',
                      _filteredItems.where((item) => item.section == 'Account & Security').toList(),
                    ),
                  ],
                  if (_filteredItems.any((item) => item.section == 'Documents & Legal')) ...[
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      themeManager,
                      'Documents & Legal',
                      _filteredItems.where((item) => item.section == 'Documents & Legal').toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildContactSupportSection(context, themeManager),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: AppSearchField(
        controller: _searchController,
        hintText: 'Search help articles…',
        onChanged: (_) {},
        showFilter: false,
        height: 48,
        borderRadius: 12,
      ),
    );
  }

  Widget _buildQuickLinksSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Links', style: themeManager.helpCenterSectionTitleStyle),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickLinkCard(
                themeManager,
                iconPath: 'assets/images/helpcenter_gettingstarted.svg',
                title: 'Getting Started',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Getting Started guide')));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickLinkCard(
                themeManager,
                iconPath: 'assets/images/helpcenter_paymentguide.svg',
                title: 'Payment Guide',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Guide')));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickLinkCard(
    ThemeManager themeManager, {
    required String iconPath,
    required String title,
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
          children: [
            AppSvgIcon(assetPath: iconPath, width: 48, height: 48),
            const SizedBox(height: 12),
            Text(title, style: themeManager.helpCenterQuickLinkTextStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(ThemeManager themeManager, String sectionTitle, List<HelpItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sectionTitle, style: themeManager.helpCenterSectionTitleStyle),
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
              for (int i = 0; i < items.length; i++) ...[
                _buildHelpItem(themeManager, items[i], isFirst: i == 0, isLast: i == items.length - 1),
                if (i < items.length - 1) const Divider(height: 1, color: AppColors.borderDivider),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem(ThemeManager themeManager, HelpItem item, {required bool isFirst, required bool isLast}) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.title} - Coming soon')));
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: isFirst ? 16 : 12,
          bottom: isLast ? 16 : 12,
          left: 0,
          right: 0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Row(
            children: [
              Expanded(child: Text(item.title, style: themeManager.helpCenterItemTextStyle)),
              Icon(Icons.chevron_right, color: AppColors.textGray70, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSupportSection(BuildContext context, ThemeManager themeManager) {
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
        children: [
          Text(
            'Can\'t find what you\'re looking for?',
            style: themeManager.helpCenterContactSupportTitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is here to help',
            style: themeManager.helpCenterContactSupportSubtitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Contact Support', style: themeManager.helpCenterContactSupportButtonTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpItem {
  final String title;
  final String section;

  HelpItem({required this.title, required this.section});
}
