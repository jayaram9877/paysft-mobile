import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/property_details_model.dart';
import '../widgets/property_details/interest_button.dart';

/// Full-screen details for a single unit — mirrors the richness of the
/// property page, showing every field the API returns for the unit
/// (attributes, amenities, and the full price breakup).
class UnitDetailsPage extends StatelessWidget {
  final UnitInfo unit;

  const UnitDetailsPage({super.key, required this.unit});

  // Order + labels for the price breakup (only shown when non-zero).
  static const List<List<String>> _priceRows = [
    ['base_price', 'Base price'],
    ['plc_charges', 'PLC charges'],
    ['floor_rise_charges', 'Floor rise charges'],
    ['corner_premium', 'Corner premium'],
    ['facing_premium', 'Facing premium'],
    ['parking_charges', 'Parking charges'],
    ['club_charges', 'Club charges'],
    ['maintenance_deposit', 'Maintenance deposit'],
    ['other_charges', 'Other charges'],
  ];

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return Scaffold(
      backgroundColor: AppColors.backgroundGrayLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        title: Text('Unit Details', style: themeManager.titleMediumStyle),
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
            _detailsCard(),
            if (unit.amenities.isNotEmpty) ...[
              const SizedBox(height: 16),
              _amenitiesCard(),
            ],
            if (_priceItems().isNotEmpty || _total().isNotEmpty) ...[
              const SizedBox(height: 16),
              _pricingCard(),
            ],
          ],
        ),
      ),
      // Per-unit "I'm Interested" call to action (POST /buyer/leads).
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: InterestButton(unitId: unit.id, prominent: true),
        ),
      ),
    );
  }

  // --- header --------------------------------------------------------------

  Widget _headerCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  unit.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _statusChip(unit.inventoryStatus),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (unit.unitType.isNotEmpty) unit.unitType,
              if (unit.unitNumber.isNotEmpty) 'No. ${unit.unitNumber}',
            ].join('  •  '),
            style: TextStyle(fontSize: 14, color: AppColors.textGray70),
          ),
          if (unit.priceLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              unit.priceLabel,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.bluePrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- details (attributes) ------------------------------------------------

  // Curated order + labels for known attribute keys. Anything not listed here
  // (and not in [_skipAttrs]) is appended afterwards with a prettified key.
  static const List<List<String>> _attrRows = [
    ['bhk_label', 'Configuration'],
    ['super_built_up_area_sqft', 'Super built-up area'],
    ['carpet_area_sqft', 'Carpet area'],
    ['facing', 'Facing'],
    ['floor', 'Floor'],
    ['tower', 'Tower'],
    ['bathrooms', 'Bathrooms'],
    ['balconies', 'Balconies'],
    ['parking_count', 'Covered parking'],
    ['is_corner', 'Corner unit'],
  ];

  // Keys shown elsewhere / redundant, so excluded from the generic pass.
  static const Set<String> _skipAttrs = {
    'amenities_included',
    'bhk', // duplicated by bhk_label
  };

  static const Set<String> _areaAttrs = {
    'super_built_up_area_sqft',
    'carpet_area_sqft',
  };

  String _attrValue(String key, dynamic v) {
    if (_areaAttrs.contains(key)) {
      final n = double.tryParse('$v');
      if (n != null) return '${_inr('$v').replaceFirst('₹', '')} sq.ft';
    }
    return _value(v);
  }

  Widget _detailsCard() {
    final a = unit.attributes;
    final used = <String>{..._skipAttrs};

    final rows = <MapEntry<String, String>>[
      if (unit.unitType.isNotEmpty) MapEntry('Type', unit.unitType),
      if (unit.unitNumber.isNotEmpty) MapEntry('Unit number', unit.unitNumber),
      if (unit.inventoryStatus.isNotEmpty)
        MapEntry('Status', _pretty(unit.inventoryStatus)),
    ];

    // Known attributes in a sensible order.
    for (final row in _attrRows) {
      final key = row[0];
      final v = a[key];
      if (v == null || '$v'.trim().isEmpty) continue;
      rows.add(MapEntry(row[1], _attrValue(key, v)));
      used.add(key);
    }

    // Any remaining real attributes we didn't explicitly map.
    for (final e in a.entries) {
      if (used.contains(e.key)) continue;
      if (e.value == null || '${e.value}'.trim().isEmpty) continue;
      rows.add(MapEntry(_pretty(e.key), _attrValue(e.key, e.value)));
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Unit details'),
          const SizedBox(height: 4),
          ...rows.map((r) => _labelValueRow(r.key, r.value)),
        ],
      ),
    );
  }

  // --- amenities -----------------------------------------------------------

  Widget _amenitiesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Amenities'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: unit.amenities
                .map(
                  (a) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlueVeryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _pretty(a),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bluePrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // --- pricing -------------------------------------------------------------

  List<MapEntry<String, String>> _priceItems() {
    final items = <MapEntry<String, String>>[];
    for (final row in _priceRows) {
      final v = unit.pricing[row[0]];
      final d = double.tryParse('${v ?? ''}');
      if (d != null && d != 0) {
        items.add(MapEntry(row[1], _inr(v)));
      }
    }
    return items;
  }

  String _total() => _inr(unit.pricing['total_price']);

  Widget _pricingCard() {
    final items = _priceItems();
    final total = _total();
    final booking = _inr(unit.pricing['booking_amount']);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Price breakup'),
          const SizedBox(height: 4),
          ...items.map((r) => _labelValueRow(r.key, r.value)),
          if (total.isNotEmpty) ...[
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total price',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bluePrimary,
                  ),
                ),
              ],
            ),
          ],
          if (booking.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking amount',
                    style: TextStyle(fontSize: 13, color: AppColors.textGray70)),
                Text(booking,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
              ],
            ),
          ],
          if (_priceNotes().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _priceNotes(),
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                fontStyle: FontStyle.italic,
                color: AppColors.textGray70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _priceNotes() {
    final n = unit.pricing['price_notes'];
    return n == null ? '' : '$n'.trim();
  }

  // --- shared helpers ------------------------------------------------------

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            width: 150,
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

  Widget _statusChip(String status) {
    final label = status.isEmpty ? '' : _pretty(status);
    if (label.isEmpty) return const SizedBox.shrink();
    final s = status.toLowerCase();
    Color bg;
    Color fg;
    if (s == 'available') {
      bg = AppColors.tokenPaidGreen.withValues(alpha: 0.12);
      fg = AppColors.tokenPaidGreen;
    } else if (s.startsWith('sold')) {
      bg = AppColors.errorRed.withValues(alpha: 0.10);
      fg = AppColors.errorRed;
    } else {
      bg = AppColors.textGray70.withValues(alpha: 0.10);
      fg = AppColors.textGray70;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  String _pretty(String v) => v
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  String _value(dynamic v) {
    if (v is bool) return v ? 'Yes' : 'No';
    return '$v';
  }

  /// Indian-grouped rupees, e.g. 1234567 -> ₹12,34,567. Empty for non-numbers.
  String _inr(dynamic v) {
    final d = double.tryParse('${v ?? ''}');
    if (d == null) return '';
    var n = d.round();
    final neg = n < 0;
    n = n.abs();
    final s = n.toString();
    String res;
    if (s.length <= 3) {
      res = s;
    } else {
      final last3 = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      final grouped =
          rest.replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+$)'), (m) => '${m[1]},');
      res = '$grouped,$last3';
    }
    return '₹${neg ? '-' : ''}$res';
  }
}
