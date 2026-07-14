/// Indian rupee formatting for API decimal strings.
class CurrencyFormat {
  const CurrencyFormat._();

  static String inr(dynamic v) {
    if (v == null) return '';
    final d = double.tryParse('$v');
    if (d == null) return '';
    final neg = d < 0;
    final n = d.abs().round();
    final s = n.toString();
    if (s.length <= 3) return '₹${neg ? '-' : ''}$s';
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${neg ? '-' : ''}${parts.join(',')},$last3';
  }

  /// Compact INR for small stat tiles: ₹5.5Cr, ₹75L, ₹50K, ₹0.
  static String inrCompact(num value) {
    final neg = value < 0;
    final v = value.abs();
    String body;
    if (v >= 10000000) {
      body = '${_trim(v / 10000000)}Cr';
    } else if (v >= 100000) {
      body = '${_trim(v / 100000)}L';
    } else if (v >= 1000) {
      body = '${_trim(v / 1000)}K';
    } else {
      body = v.round().toString();
    }
    return '₹${neg ? '-' : ''}$body';
  }

  /// One decimal, dropping a trailing `.0` (5.0 -> "5", 5.5 -> "5.5").
  static String _trim(num d) {
    final s = d.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
