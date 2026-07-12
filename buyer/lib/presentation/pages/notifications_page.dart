import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/utils/date_time_format.dart';
import '../../domain/entities/buyer_offer.dart';
import '../../domain/entities/notification_model.dart';
import '../../domain/entities/visit_meeting.dart';
import '../providers/notifications_provider.dart';
import '../providers/offers_provider.dart';
import '../providers/visits_provider.dart';
import '../widgets/common/app_loader_widget.dart';
import '../widgets/meetings/meetings_view.dart' show openMeetingDetails;
import 'offer_details_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    // Warm offers/visits so tapping a notification can resolve its deep-link
    // target; the inbox itself now comes from GET /buyer/notifications.
    context.read<OffersProvider>().ensureLoaded();
    context.read<VisitsProvider>().ensureLoaded();
    await context.read<NotificationsProvider>().reload();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final provider = context.watch<NotificationsProvider>();

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
          AppStrings.notifications,
          style: themeManager.titleMediumStyle.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllRead(),
              child: Text(
                AppStrings.markAllRead,
                style: themeManager.bodyMediumStyle.copyWith(
                  color: AppColors.bluePrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderDivider),
        ),
      ),
      body: provider.isLoading && provider.items.isEmpty
          ? const Center(child: AppLoaderWidget())
          : provider.items.isEmpty
              ? _buildEmptyState(themeManager)
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.bluePrimary,
                  child: _buildNotificationsList(provider.items),
                ),
    );
  }

  Widget _buildEmptyState(ThemeManager themeManager) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/no_notifications.svg',
              width: 206,
              height: 194,
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.noNotificationYet,
              style: themeManager.titleStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.noNotificationDescription,
              textAlign: TextAlign.center,
              style: themeManager.bodyStyle.copyWith(
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<NotificationModel>>{};
    for (final n in notifications) {
      final d = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
      String label;
      if (d == today) {
        label = AppStrings.notificationsToday;
      } else if (d == yesterday) {
        label = AppStrings.notificationsYesterday;
      } else {
        label = DateTimeFormat.date(n.timestamp);
      }
      groups.putIfAbsent(label, () => []).add(n);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final entry in groups.entries) ...[
          _buildSectionHeader(entry.key),
          ...entry.value.map((n) => _buildNotificationItem(n)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: ThemeManager().bodyMediumStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final icon = _iconFor(notification.type);
    final iconColor = _iconColor(notification.type);

    return Material(
      color: notification.isRead
          ? AppColors.backgroundWhite
          : AppColors.backgroundBlueVeryLight.withValues(alpha: 0.35),
      child: InkWell(
        onTap: () => _onTap(notification),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.bluePrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateTimeFormat.time(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.offer:
        return Icons.local_offer_outlined;
      case NotificationType.visit:
        return Icons.event_outlined;
      case NotificationType.interest:
        return Icons.favorite_border;
      case NotificationType.system:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(NotificationType type) {
    switch (type) {
      case NotificationType.offer:
        return AppColors.bluePrimary;
      case NotificationType.visit:
        return AppColors.tokenPaidGreen;
      case NotificationType.interest:
        return AppColors.errorRed;
      case NotificationType.system:
        return AppColors.textGray70;
    }
  }

  Future<void> _onTap(NotificationModel notification) async {
    await context.read<NotificationsProvider>().markRead(notification.id);

    if (!mounted) return;

    switch (notification.type) {
      case NotificationType.offer:
        final saleId = notification.saleId;
        if (saleId == null) return;
        final offers = context.read<OffersProvider>().offers;
        BuyerOfferSummary? match;
        for (final o in offers) {
          if (o.saleId == saleId) {
            match = o;
            break;
          }
        }
        if (match != null) {
          openOfferDetails(context, match);
        }
        break;
      case NotificationType.visit:
        final visitId = notification.visitId;
        if (visitId == null) return;
        final visits = context.read<VisitsProvider>().visits;
        VisitMeeting? visit;
        for (final v in visits) {
          if (v.id == visitId) {
            visit = v;
            break;
          }
        }
        if (visit != null) openMeetingDetails(context, visit);
        break;
      case NotificationType.interest:
      case NotificationType.system:
        break;
    }
  }
}
