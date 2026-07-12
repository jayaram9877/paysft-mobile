import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/broker_project_model.dart';
import '../../data/models/broker_unit_model.dart';

const Color _availGreen = Color(0xFF12B76A);
const Color _availGreenBg = Color(0xFFE7F8F0);
const Color _amber = Color(0xFFB54708);
const Color _amberBg = Color(0xFFFFF4E5);

/// Read-only detail view for a single unit. All data is already loaded with
/// the project's units, so this is a plain widget (no API call).
class UnitDetailPage extends StatelessWidget {
  final BrokerUnitModel unit;
  final String projectName;
  const UnitDetailPage({
    super.key,
    required this.unit,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1D2939)),
        title: Text(
          _title,
          style: const TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _headerCard(),
          const SizedBox(height: 20),
          _configSection(),
          _priceSection(),
          if ((unit.statusReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 20),
            _note(unit.statusReason!),
          ],
        ],
      ),
    );
  }

  String get _title => unit.propertyTitle?.isNotEmpty == true
      ? unit.propertyTitle!
      : '${BrokerProjectModel.pretty(unit.unitType)} ${unit.unitNumber}';

  Widget _headerCard() {
    final total = _inr(unit.pricing?.totalPrice);
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
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlueSelectedVeryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_typeIcon, color: AppColors.bluePrimary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGray70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _chip(BrokerProjectModel.pretty(unit.unitType)),
              const SizedBox(width: 8),
              _chip('Unit ${unit.unitNumber}'),
            ],
          ),
          if (total != null) ...[
            const Divider(height: 28, color: Color(0xFFF0F1F3)),
            const Text(
              'Total price',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              total,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.bluePrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _configSection() {
    final rows = <Widget>[];
    unit.attributes.forEach((key, value) {
      final text = _stringify(value);
      if (text.isEmpty) return;
      rows.add(_InfoRow(label: BrokerProjectModel.pretty(key), value: text));
    });

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Configuration'),
        const SizedBox(height: 10),
        _card(rows),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _priceSection() {
    final p = unit.pricing;
    if (p == null) {
      return const _StateLine('Pricing not published for this unit.');
    }

    final rows = <Widget>[];
    void add(String label, String? raw, {bool always = false}) {
      final v = double.tryParse(raw ?? '');
      if (v == null) return;
      if (!always && v <= 0) return;
      rows.add(_InfoRow(label: label, value: _inr(raw) ?? '—'));
    }

    add('Base price', p.basePrice, always: true);
    add('PLC charges', p.plcCharges);
    add('Floor rise', p.floorRiseCharges);
    add('Corner premium', p.cornerPremium);
    add('Facing premium', p.facingPremium);
    add('Parking', p.parkingCharges);
    add('Club charges', p.clubCharges);
    add('Maintenance deposit', p.maintenanceDeposit);
    add('Other charges', p.otherCharges);

    if (rows.isEmpty && (p.totalPrice == null)) {
      return const _StateLine('Pricing not published for this unit.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Price breakup'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGrayMedium),
          ),
          child: Column(
            children: [
              ...rows,
              if (_inr(p.totalPrice) != null) _totalRow(_inr(p.totalPrice)!),
            ],
          ),
        ),
        if ((p.bookingAmount != null) &&
            (double.tryParse(p.bookingAmount!) ?? 0) > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _availGreenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_added_outlined,
                    color: _availGreen, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Booking amount',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGray80,
                    ),
                  ),
                ),
                Text(
                  _inr(p.bookingAmount) ?? '—',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _availGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
        if ((p.priceNotes ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          _note(p.priceNotes!),
        ],
      ],
    );
  }

  Widget _totalRow(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Total price',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.bluePrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: Column(children: rows),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlueSelectedVeryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.bluePrimary,
        ),
      ),
    );
  }

  Widget _statusBadge() {
    final available = unit.isAvailable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: available ? _availGreenBg : _amberBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        BrokerProjectModel.pretty(unit.inventoryStatus),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: available ? _availGreen : _amber,
        ),
      ),
    );
  }

  Widget _note(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _amberBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: _amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textGray80,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData get _typeIcon {
    switch (unit.unitType) {
      case 'flat':
        return Icons.apartment;
      case 'plot':
        return Icons.landscape_outlined;
      case 'villa':
        return Icons.villa_outlined;
      case 'office':
        return Icons.business_outlined;
      case 'retail':
        return Icons.storefront_outlined;
      case 'warehouse':
        return Icons.warehouse_outlined;
      default:
        return Icons.meeting_room_outlined;
    }
  }

  static String _stringify(dynamic value) {
    if (value == null) return '';
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is List) {
      return value.map((e) => e.toString()).where((s) => s.isNotEmpty).join(', ');
    }
    if (value is Map) return '';
    return value.toString();
  }

  /// Formats a decimal-string amount with Indian digit grouping (e.g.
  /// ₹1,23,45,678). Returns null when not a positive number.
  static String? _inr(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null || value <= 0) return null;
    final s = value.round().toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '₹${groups.join(',')},$last3';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F1F3))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
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
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF101828),
      ),
    );
  }
}

class _StateLine extends StatelessWidget {
  final String text;
  const _StateLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.textGray70),
      ),
    );
  }
}
