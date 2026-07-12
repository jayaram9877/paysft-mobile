import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/common/app_svg_icon.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // SMS Notifications
  bool _smsPaymentAlerts = true;
  bool _smsSecurityAlerts = true;
  bool _smsPaymentReminders = true;

  // Push Notifications
  bool _paymentAlerts = true;
  bool _constructionUpdates = true;
  bool _documentAlerts = true;
  bool _brokerMessages = true;

  // Email Notifications
  bool _paymentReceipts = true;
  bool _monthlyStatements = true;
  bool _promotionalEmails = false;

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
            child: Text(AppStrings.notifications, style: themeManager.editProfileTitleStyle),
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
            _buildPushNotificationsSection(themeManager),
            const SizedBox(height: 24),
            _buildEmailNotificationsSection(themeManager),
            const SizedBox(height: 24),
            _buildSMSNotificationsSection(themeManager),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSMSNotificationsSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SMS Notifications', style: themeManager.notificationSectionTitleStyle),
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
              _buildNotificationOption(
                themeManager,
                title: 'Payment Alerts',
                subtitle: 'SMS for successful payments',
                value: _smsPaymentAlerts,
                onChanged: (value) => setState(() => _smsPaymentAlerts = value),
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildNotificationOption(
                themeManager,
                title: 'Security Alerts',
                subtitle: 'Login and account activity',
                value: _smsSecurityAlerts,
                onChanged: (value) => setState(() => _smsSecurityAlerts = value),
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildNotificationOption(
                themeManager,
                title: 'Payment Reminders',
                subtitle: 'Upcoming payment due dates',
                value: _smsPaymentReminders,
                onChanged: (value) => setState(() => _smsPaymentReminders = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPushNotificationsSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Push Notifications', style: themeManager.notificationSectionTitleStyle),
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
              _buildNotificationOption(
                themeManager,
                title: 'Payment Alerts',
                subtitle: 'Get notified about payment updates',
                value: _paymentAlerts,
                onChanged: (value) => setState(() => _paymentAlerts = value),
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildNotificationOption(
                themeManager,
                title: 'Construction Updates',
                subtitle: 'Milestone completion notifications',
                value: _constructionUpdates,
                onChanged: (value) => setState(() => _constructionUpdates = value),
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildNotificationOption(
                themeManager,
                title: 'Document Alerts',
                subtitle: 'New documents and signing requests',
                value: _documentAlerts,
                onChanged: (value) => setState(() => _documentAlerts = value),
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildNotificationOption(
                themeManager,
                title: 'Broker Messages',
                subtitle: 'Messages from your relationship manager',
                value: _brokerMessages,
                onChanged: (value) => setState(() => _brokerMessages = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailNotificationsSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Notifications', style: themeManager.notificationSectionTitleStyle),
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
              _buildNotificationOption(
                themeManager,
                title: 'Payment Receipts',
                subtitle: 'Email receipts for all transactions',
                value: _paymentReceipts,
                onChanged: (value) => setState(() => _paymentReceipts = value),
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildNotificationOption(
                themeManager,
                title: 'Monthly Statements',
                subtitle: 'Monthly account summary via email',
                value: _monthlyStatements,
                onChanged: (value) => setState(() => _monthlyStatements = value),
              ),
              const Divider(height: 1, color: AppColors.borderDivider),
              _buildNotificationOption(
                themeManager,
                title: 'Promotional Emails',
                subtitle: 'New property launches and offers',
                value: _promotionalEmails,
                onChanged: (value) => setState(() => _promotionalEmails = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationOption(
    ThemeManager themeManager, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
            activeTrackColor: AppColors.notificationToggleActive, // Black track when active
            activeThumbColor: AppColors.backgroundWhite, // White thumb when active
            inactiveThumbColor: AppColors.backgroundWhite, // White thumb when inactive
            inactiveTrackColor: AppColors.notificationToggleInactive, // Light gray track when inactive
          ),
        ],
      ),
    );
  }
}
