import 'package:flutter/services.dart';

/// Formats a 10-digit Indian mobile number as: `123 456 7890`
///
/// Notes:
/// - Country code `+91` should be rendered via `InputDecoration.prefixText`
///   (non-editable), not inside the controller text.
/// - Cursor position is preserved based on digit index.
class IndiaMobileNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final rawDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final digits = rawDigits.length > 10 ? rawDigits.substring(0, 10) : rawDigits;

    final formatted = _format(digits);

    final digitIndexBeforeCursor = _digitCountBeforeCursor(newValue);
    final newCursor = _cursorFromDigitIndex(formatted, digitIndexBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
      composing: TextRange.empty,
    );
  }

  String _format(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return '${digits.substring(0, 3)} ${digits.substring(3)}';
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }

  int _digitCountBeforeCursor(TextEditingValue value) {
    final offset = value.selection.baseOffset;
    if (offset <= 0) return 0;
    final safeOffset = offset.clamp(0, value.text.length);
    return value.text.substring(0, safeOffset).replaceAll(RegExp(r'[^\d]'), '').length;
  }

  int _cursorFromDigitIndex(String formatted, int digitIndex) {
    if (digitIndex <= 0) return 0;
    int seen = 0;
    for (int i = 0; i < formatted.length; i++) {
      final c = formatted.codeUnitAt(i);
      final isDigit = c >= 48 && c <= 57;
      if (isDigit) {
        seen++;
        if (seen >= digitIndex) return i + 1;
      }
    }
    return formatted.length;
  }
}

