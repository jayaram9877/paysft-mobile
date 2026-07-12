import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../data/models/broker_client_model.dart';
import '../../data/models/broker_visit_model.dart';
import '../providers/client_schedule_provider.dart';

const Color _green = Color(0xFF12B76A);
const Color _greenBg = Color(0xFFE7F8F0);
const Color _amber = Color(0xFFB54708);
const Color _amberBg = Color(0xFFFFF4E5);
const Color _red = Color(0xFFD92D20);
const Color _redBg = Color(0xFFFEE4E2);

class ClientDetailPage extends StatelessWidget {
  final BrokerClientModel client;
  const ClientDetailPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ClientScheduleProvider>()..load(client.leadId),
      child: _ClientDetailView(client: client),
    );
  }
}

class _ClientDetailView extends StatelessWidget {
  final BrokerClientModel client;
  const _ClientDetailView({required this.client});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _dateTime(DateTime? dt) {
    if (dt == null) return '—';
    final l = dt.toLocal();
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    final m = l.minute.toString().padLeft(2, '0');
    return '${l.day} ${_months[l.month - 1]} ${l.year}, $h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientScheduleProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1D2939)),
        title: Text(
          client.buyerFullName,
          style: const TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: provider.isBusy
                  ? null
                  : () => _scheduleNew(context, provider),
              icon: provider.isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add, size: 20),
              label: const Text('Schedule Visit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _clientCard(),
          const SizedBox(height: 20),
          const Text(
            'Site visits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 10),
          if (provider.isLoading && provider.visits.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.visits.isEmpty)
            _emptyVisits()
          else
            ...provider.visits.map((v) => _visitTile(context, provider, v)),
        ],
      ),
    );
  }

  Widget _clientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundBlueSelectedVeryLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  client.initials,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bluePrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.buyerFullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _greenBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Client',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26, color: Color(0xFFF0F1F3)),
          _info('Property', client.projectName),
          _info('Unit', client.unitLabel),
          if (client.location.isNotEmpty) _info('Location', client.location),
          if ((client.notes ?? '').isNotEmpty) _info('Notes', client.notes!),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  Widget _emptyVisits() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_outlined, size: 36, color: AppColors.textGrayMedium),
          SizedBox(height: 10),
          Text(
            'No visits scheduled.\nTap "Schedule Visit" to book one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _visitTile(
      BuildContext context, ClientScheduleProvider provider, BrokerVisitModel v) {
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, size: 18, color: AppColors.bluePrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _dateTime(v.scheduledFor),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  v.statusLabel,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: fg),
                ),
              ),
            ],
          ),
          if (v.isScheduled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.isBusy
                        ? null
                        : () => _reschedule(context, provider, v),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.bluePrimary,
                      side: const BorderSide(color: AppColors.bluePrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reschedule',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.isBusy
                        ? null
                        : () => _cancel(context, provider, v),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context, {DateTime? initial}) async {
    final now = DateTime.now();
    final base = initial ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: base.isBefore(now) ? now : base,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _scheduleNew(
      BuildContext context, ClientScheduleProvider provider) async {
    final when = await _pickDateTime(context);
    if (when == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await provider.schedule(when);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Visit scheduled')),
    );
  }

  Future<void> _reschedule(BuildContext context,
      ClientScheduleProvider provider, BrokerVisitModel v) async {
    final when = await _pickDateTime(context, initial: v.scheduledFor);
    if (when == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await provider.reschedule(v.id, when);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Visit rescheduled')),
    );
  }

  Future<void> _cancel(BuildContext context, ClientScheduleProvider provider,
      BrokerVisitModel v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this visit?'),
        content: const Text('The buyer will be notified.'),
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
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await provider.cancel(v.id);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Visit cancelled')),
    );
  }
}
