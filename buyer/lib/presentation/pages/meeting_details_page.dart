import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/utils/date_time_format.dart';
import '../../domain/entities/property_model.dart';
import '../../domain/entities/visit_meeting.dart';
import '../widgets/meetings/meeting_card.dart';
import 'property_details_page.dart';

/// Full schedule details for a single site visit ("meeting"), with a
/// clickable card that opens the property it's for.
class MeetingDetailsPage extends StatelessWidget {
  final VisitMeeting visit;

  const MeetingDetailsPage({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final dt = visit.scheduledFor;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrayLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        title: Text('Meeting Details', style: themeManager.titleMediumStyle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            _scheduleCard(dt),
            const SizedBox(height: 16),
            _propertyCard(context),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dateBadge(visit.scheduledFor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.propertyLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                MeetingStatusChip(status: visit.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBadge(DateTime? dt) {
    return Container(
      width: 56,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.backgroundBlueVeryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: dt == null
          ? const Icon(Icons.event, color: AppColors.bluePrimary)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${dt.day}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bluePrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateTimeFormat.date(dt).split(' ')[2], // month abbrev
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bluePrimary,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _scheduleCard(DateTime? dt) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Date', dt == null ? 'To be confirmed' : DateTimeFormat.date(dt)),
      MapEntry('Time', dt == null ? 'To be confirmed' : DateTimeFormat.time(dt)),
      if (visit.unitNumber.isNotEmpty) MapEntry('Unit number', visit.unitNumber),
      if ((visit.notes ?? '').isNotEmpty) MapEntry('Notes', visit.notes!),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Schedule details'),
          const SizedBox(height: 4),
          ...rows.map((r) => _labelValueRow(r.key, r.value)),
        ],
      ),
    );
  }

  Widget _propertyCard(BuildContext context) {
    final canOpen = visit.projectId.isNotEmpty;
    return _card(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: canOpen ? () => _openProperty(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundBlueVeryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.apartment_rounded,
                    color: AppColors.bluePrimary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Property details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGray70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visit.projectName.isNotEmpty
                          ? visit.projectName
                          : visit.propertyLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (canOpen)
                const Icon(Icons.chevron_right, color: AppColors.textGray70),
            ],
          ),
        ),
      ),
    );
  }

  void _openProperty(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailsPage(
          property: PropertyModel(
            id: visit.projectId,
            title: visit.projectName.isNotEmpty
                ? visit.projectName
                : visit.propertyLabel,
            location: '',
            imageUrl: '',
          ),
        ),
      ),
    );
  }

  // --- shared helpers ------------------------------------------------------

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayLightNew),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      );

  Widget _labelValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(fontSize: 14, color: AppColors.textGray70)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
