import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/broker_visit_model.dart';
import '../providers/schedule_provider.dart';

const Color _purple = Color(0xFF7C3AED);
const Color _green = Color(0xFF12B76A);
const Color _greenBg = Color(0xFFE7F8F0);
const Color _amber = Color(0xFFB54708);
const Color _amberBg = Color(0xFFFFF4E5);
const Color _red = Color(0xFFD92D20);
const Color _redBg = Color(0xFFFEE4E2);

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _selected = DateTime(n.year, n.month, n.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ScheduleProvider>();
      if (!p.loadedOnce) p.load();
    });
  }

  // ---- date helpers --------------------------------------------------------
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekdaysFull = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String _ordinal(int d) {
    if (d >= 11 && d <= 13) return '${d}th';
    switch (d % 10) {
      case 1:
        return '${d}st';
      case 2:
        return '${d}nd';
      case 3:
        return '${d}rd';
      default:
        return '${d}th';
    }
  }

  String _time(DateTime dt) {
    final l = dt.toLocal();
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    final m = l.minute.toString().padLeft(2, '0');
    return '$h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
  }

  /// The day strip covers today through any visit dates, with a sensible window.
  List<DateTime> _days(ScheduleProvider p) {
    final today = _selected;
    var start = DateTime.now();
    start = DateTime(start.year, start.month, start.day);
    var end = start.add(const Duration(days: 27));
    for (final d in p.datesWithVisits) {
      if (d.isBefore(start)) start = d;
      if (d.isAfter(end)) end = d;
    }
    if (today.isBefore(start)) start = today;
    if (today.isAfter(end)) end = today;
    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1D2939)),
            onPressed: () => context.read<ScheduleProvider>().load(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _purple,
        onPressed: _newSchedule,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ScheduleProvider provider) {
    if (provider.isLoading && !provider.loadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }
    final visits = provider.visitsOn(_selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${_months[_selected.month - 1]} ${_selected.year}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
        ),
        _dateStrip(provider),
        const Divider(height: 1, color: AppColors.borderGrayLight),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_ordinal(_selected.day)} ${_weekdaysFull[_selected.weekday - 1]}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              Text(
                '${visits.length} ${visits.length == 1 ? 'visit' : 'visits'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGray70,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _timeline(provider, visits)),
      ],
    );
  }

  Widget _dateStrip(ScheduleProvider provider) {
    final days = _days(provider);
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final d = days[i];
          final selected = d == _selected;
          final hasVisits = provider.hasVisitsOn(d);
          return GestureDetector(
            onTap: () => setState(() => _selected = d),
            child: Container(
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [
                          AppColors.blueGradientStart,
                          AppColors.blueGradientEnd
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: selected ? null : AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppColors.borderGrayLight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdays[d.weekday - 1],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white70 : AppColors.textGray70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : const Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasVisits
                          ? (selected ? Colors.white : AppColors.bluePrimary)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _timeline(ScheduleProvider provider, List<BrokerVisitModel> visits) {
    if (visits.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.load(),
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.event_available_outlined,
                      size: 48, color: AppColors.textGrayMedium),
                  SizedBox(height: 12),
                  Text(
                    'No visits scheduled for this day.',
                    style:
                        TextStyle(color: AppColors.textGray70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: visits.length,
        itemBuilder: (context, i) => _visitRow(provider, visits[i]),
      ),
    );
  }

  Widget _visitRow(ScheduleProvider provider, BrokerVisitModel visit) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                visit.scheduledFor == null ? '--' : _time(visit.scheduledFor!),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray80,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDetails(provider, visit),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                    left: BorderSide(color: _statusColor(visit), width: 4),
                    top: const BorderSide(color: AppColors.borderGrayMedium),
                    right: const BorderSide(color: AppColors.borderGrayMedium),
                    bottom: const BorderSide(color: AppColors.borderGrayMedium),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlueSelectedVeryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.home_work_outlined,
                          color: AppColors.bluePrimary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.projectNameFor(visit.projectId),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101828),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Site visit',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(visit),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BrokerVisitModel v) {
    if (v.isCompleted) return _green;
    if (v.isNoShow) return _red;
    return AppColors.bluePrimary;
  }

  Widget _statusBadge(BrokerVisitModel v) {
    Color fg = AppColors.bluePrimary, bg = AppColors.backgroundBlueSelectedVeryLight;
    if (v.isCompleted) {
      fg = _green;
      bg = _greenBg;
    } else if (v.isNoShow) {
      fg = _red;
      bg = _redBg;
    } else {
      fg = _amber;
      bg = _amberBg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        v.statusLabel,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  void _showDetails(ScheduleProvider provider, BrokerVisitModel visit) {
    final project = provider.projectFor(visit.projectId);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Visit details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Property', provider.projectNameFor(visit.projectId)),
              if (project != null && project.location.isNotEmpty)
                _detailRow('Location', project.location),
              _detailRow(
                'Date',
                visit.scheduledFor == null
                    ? '—'
                    : '${_ordinal(visit.scheduledFor!.toLocal().day)} '
                        '${_weekdaysFull[visit.scheduledFor!.toLocal().weekday - 1]}',
              ),
              _detailRow('Time',
                  visit.scheduledFor == null ? '—' : _time(visit.scheduledFor!)),
              _detailRow('Status', visit.statusLabel),
              if ((visit.notes ?? '').isNotEmpty)
                _detailRow('Notes', visit.notes!),
              const SizedBox(height: 20),
              if (visit.isScheduled)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmCancel(provider, visit);
                    },
                    icon: const Icon(Icons.close, size: 18, color: _red),
                    label: const Text('Cancel Visit',
                        style: TextStyle(
                            color: _red, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray70,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(
      ScheduleProvider provider, BrokerVisitModel visit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this visit?'),
        content: const Text('The buyer will be notified that the site visit '
            'was cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: _red),
            child: const Text('Cancel Visit'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await provider.cancelVisit(visit.id);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Visit cancelled')),
    );
  }

  void _newSchedule() {
    // The API has no broker-availability endpoint, so this is informational
    // until the backend exposes one.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Setting availability needs backend support — coming soon.'),
      ),
    );
  }
}
