import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/visit_meeting.dart';
import '../../providers/visits_provider.dart';
import '../../pages/meeting_details_page.dart';
import '../common/app_loader_widget.dart';
import 'meeting_card.dart';

/// Opens the schedule details for a meeting/visit (which itself links through
/// to the property it's for).
void openMeetingDetails(BuildContext context, VisitMeeting visit) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => MeetingDetailsPage(visit: visit)),
  );
}

/// Content of the Chat "Meetings" tab — the buyer's scheduled site visits.
class MeetingsView extends StatefulWidget {
  const MeetingsView({super.key});

  @override
  State<MeetingsView> createState() => _MeetingsViewState();
}

class _MeetingsViewState extends State<MeetingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<VisitsProvider>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VisitsProvider>();
    final visits = provider.visits;

    if (provider.isLoading && visits.isEmpty) {
      return const Center(child: AppLoaderWidget());
    }
    if (visits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_note,
                  size: 64, color: AppColors.borderGrayMedium),
              const SizedBox(height: 16),
              const Text(
                'No meetings scheduled',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Site visits scheduled with an advisor will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textGray70),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<VisitsProvider>().reload(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: visits.length,
        itemBuilder: (context, index) => MeetingCard(
          visit: visits[index],
          onTap: () => openMeetingDetails(context, visits[index]),
        ),
      ),
    );
  }
}
