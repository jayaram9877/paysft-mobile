import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/message.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';

class ContactDetailsScreen extends StatelessWidget {
  final SharedContact contact;

  const ContactDetailsScreen({
    super.key,
    required this.contact,
  });

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendMessage(String phoneNumber) async {
    final uri = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final primaryPhone = contact.primaryPhone ?? 
        (contact.phoneNumbers.isNotEmpty ? contact.phoneNumbers.first : null);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.contactDetails,
          style: themeManager.titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Contact header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.avatarBackground,
                    backgroundImage: contact.avatarUrl != null
                        ? NetworkImage(contact.avatarUrl!)
                        : null,
                    child: contact.avatarUrl == null
                        ? Text(
                            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                            style: themeManager.titleStyle.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    contact.name,
                    style: themeManager.titleStyle.copyWith(
                      fontSize: 24,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            if (primaryPhone != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makeCall(primaryPhone),
                        icon: const Icon(Icons.call, color: AppColors.textWhite),
                        label: Text(
                          AppStrings.call,
                          style: themeManager.labelStyle.copyWith(color: AppColors.textWhite),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendMessage(primaryPhone),
                        icon: const Icon(Icons.message, color: AppColors.textWhite),
                        label: Text(
                          AppStrings.message,
                          style: themeManager.labelStyle.copyWith(color: AppColors.textWhite),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            // Phone numbers
            if (contact.phoneNumbers.isNotEmpty)
              _buildSection(
                themeManager,
                title: AppStrings.phoneNumbers,
                children: contact.phoneNumbers.map((phone) {
                  return _buildInfoTile(
                    themeManager,
                    icon: Icons.phone,
                    title: phone,
                    onTap: () => _makeCall(phone),
                    isPhone: true,
                  );
                }).toList(),
              ),
            // Email
            if (contact.email != null && contact.email!.isNotEmpty)
              _buildSection(
                themeManager,
                title: AppStrings.emailLabel,
                children: [
                  _buildInfoTile(
                    themeManager,
                    icon: Icons.email,
                    title: contact.email!,
                    onTap: () => _sendEmail(contact.email!),
                  ),
                ],
              ),
            // Address
            if (contact.address != null && contact.address!.isNotEmpty)
              _buildSection(
                themeManager,
                title: AppStrings.address,
                children: [
                  _buildInfoTile(
                    themeManager,
                    icon: Icons.location_on,
                    title: contact.address!,
                    onTap: null,
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeManager themeManager, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: themeManager.bodySmallStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryGray,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDivider, width: 0.5),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoTile(
    ThemeManager themeManager, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isPhone = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondaryGray, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: themeManager.bodyStyle.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            if (onTap != null && isPhone)
              Icon(
                Icons.phone,
                color: AppColors.primaryBlue,
                size: 20,
              )
            else if (onTap != null && !isPhone)
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryGray,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

