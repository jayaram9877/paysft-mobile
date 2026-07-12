import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_format.dart';
import '../../../domain/entities/visit_meeting.dart';

/// "Meeting scheduled on {date} at {time} with {broker}" — used wherever a
/// scheduled visit needs a one-line summary (unit cards, property page).
/// Omits the broker clause until a broker has been matched to the lead.
String meetingScheduleText(VisitMeeting visit) {
  final dt = visit.scheduledFor;
  if (dt == null) return 'Meeting scheduled — time to be confirmed';
  final base =
      'Meeting scheduled on ${DateTimeFormat.date(dt)} at ${DateTimeFormat.time(dt)}';
  final broker = visit.brokerName;
  return (broker != null && broker.isNotEmpty) ? '$base with $broker' : base;
}

/// Compact tappable banner for a scheduled visit — used inside a unit card.
class MeetingScheduledBanner extends StatelessWidget {
  final VisitMeeting visit;
  final VoidCallback? onTap;

  const MeetingScheduledBanner({super.key, required this.visit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: AppColors.backgroundBlueVeryLight,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.event_available,
                    size: 16, color: AppColors.bluePrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    meetingScheduleText(visit),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bluePrimary,
                    ),
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right,
                      size: 16, color: AppColors.bluePrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row card for the Chat "Meetings" tab.
class MeetingCard extends StatelessWidget {
  final VisitMeeting visit;
  final VoidCallback? onTap;

  const MeetingCard({super.key, required this.visit, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dt = visit.scheduledFor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Material(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrayLightNew),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dateBadge(dt),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.propertyLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppColors.textGray70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dt == null
                            ? 'Time to be confirmed'
                            : DateTimeFormat.dateTime(dt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textGray70),
                      ),
                    ),
                  ],
                ),
                if ((visit.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    visit.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textGray70),
                  ),
                ],
                const SizedBox(height: 8),
                MeetingStatusChip(status: visit.status),
              ],
            ),
          ),
        ],
            ),
          ),
        ),
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
}

/// Prominent "Upcoming Visit" card for the top of the Home screen.
class UpcomingMeetingCard extends StatelessWidget {
  final VisitMeeting visit;
  final VoidCallback? onTap;

  const UpcomingMeetingCard({super.key, required this.visit, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dt = visit.scheduledFor;
    final when = dt == null
        ? 'Time to be confirmed'
        : '${DateTimeFormat.dayLabel(dt, DateTime.now())} · ${DateTimeFormat.time(dt)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.blueDark, AppColors.purpleGradientEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available,
                    color: AppColors.textWhite, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming visit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      visit.propertyLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            when,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textWhite),
            ],
          ),
        ),
      ),
    );
  }
}

class MeetingStatusChip extends StatelessWidget {
  final String status;

  const MeetingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color color;
    String label;
    switch (s) {
      case 'scheduled':
        color = AppColors.bluePrimary;
        label = 'Scheduled';
        break;
      case 'completed':
        color = AppColors.tokenPaidGreen;
        label = 'Completed';
        break;
      case 'cancelled':
        color = AppColors.errorRed;
        label = 'Cancelled';
        break;
      case 'no_show':
        color = AppColors.textGray70;
        label = 'No show';
        break;
      default:
        color = AppColors.textGray70;
        label = status.isEmpty ? 'Visit' : status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
