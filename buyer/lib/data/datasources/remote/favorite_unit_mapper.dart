import '../../../domain/entities/favorite_unit.dart';

/// Maps the enriched unit rows returned by `/buyer/saved-units` and
/// `/buyer/leads` onto the shared [FavoriteUnit] entity.
class FavoriteUnitMapper {
  const FavoriteUnitMapper._();

  static FavoriteUnit fromSavedUnit(Map row) {
    final title = _str(row['property_title']);
    final number = _str(row['unit_number']) ?? '';
    return FavoriteUnit(
      unitId: '${row['unit_id'] ?? ''}',
      projectId: '${row['project_id'] ?? ''}',
      title: (title != null && title.isNotEmpty)
          ? title
          : (_str(row['project_name']) ?? 'Unit'),
      projectName: _str(row['project_name']) ?? '',
      location: _location(row['locality'], row['city']),
      unitNumber: number,
      unitType: _pretty(_str(row['unit_type'])),
      priceLabel: _inr(row['base_price']),
      imageUrl: null, // saved-units payload has no cover image
      statusLabel: _pretty(_str(row['inventory_status'])),
      isAvailable: row['is_available'] == true,
    );
  }

  static FavoriteUnit fromLead(Map row) {
    final title = _str(row['unit_title']);
    final number = _str(row['unit_number']) ?? '';
    final status = _str(row['status']) ?? '';
    return FavoriteUnit(
      unitId: '${row['unit_id'] ?? ''}',
      projectId: '${row['project_id'] ?? ''}',
      title: (title != null && title.isNotEmpty)
          ? title
          : (_str(row['project_name']) ?? 'Unit'),
      projectName: _str(row['project_name']) ?? '',
      location: _location(row['locality'], row['city']),
      unitNumber: number,
      unitType: '',
      priceLabel: '', // leads payload has no price
      imageUrl: _str(row['cover_image_url']),
      statusLabel: _leadStatusLabel(status),
      isAvailable: status != 'closed' && status != 'cancelled',
    );
  }

  // --- helpers -------------------------------------------------------------

  static String _leadStatusLabel(String status) {
    switch (status) {
      case 'routing':
        return 'Finding an advisor';
      case 'accepted':
        return 'Advisor assigned';
      case 'no_brokers':
        return 'Awaiting advisor';
      case 'closed':
        return 'Closed';
      case 'cancelled':
        return 'Withdrawn';
      default:
        return _pretty(status);
    }
  }

  static String _location(dynamic locality, dynamic city) {
    return [_str(locality), _str(city)]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');
  }

  static String? _str(dynamic v) => v == null ? null : '$v';

  static String _pretty(String? v) {
    if (v == null || v.isEmpty) return '';
    return v
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Indian-grouped rupees, e.g. 1234567 -> ₹12,34,567. Empty for non-numbers.
  static String _inr(dynamic v) {
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
      final grouped = rest.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+$)'),
        (m) => '${m[1]},',
      );
      res = '$grouped,$last3';
    }
    return '₹${neg ? '-' : ''}$res';
  }
}
