import '../../core/constants/app_string_constants.dart';

class InputValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${AppStrings.fieldRequired}';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.phoneNumberRequired;
    }
    // Remove any spaces or special characters for validation
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 10) {
      return AppStrings.phoneNumberMustHave10Digits;
    }

    // Check if first digit is between 6 and 9
    final firstDigit = int.tryParse(cleaned[0]);
    if (firstDigit == null || firstDigit < 6 || firstDigit > 9) {
      return AppStrings.phoneNumberMustStartWith;
    }

    // Check if all digits are zeros
    if (cleaned == '0000000000') {
      return AppStrings.phoneNumberCannotBeAllZeros;
    }
    
    // Check if all digits are the same, but allow 6, 7, 8, 9
    // Reject all same digits only if they are NOT 6, 7, 8, or 9
    final firstChar = cleaned[0];
    if (cleaned.split('').every((char) => char == firstChar)) {
      // Allow if all digits are 6, 7, 8, or 9
      if (firstChar != '6' && firstChar != '7' && firstChar != '8' && firstChar != '9') {
        return AppStrings.phoneNumberCannotBeAllSameDigits;
      }
    }
    
    return null;
  }

  /// Validates Indian phone number with comprehensive checks
  /// Returns null if valid, error message if invalid
  static String? validateIndianPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.phoneNumberRequired;
    }
    
    // Remove any spaces or special characters for validation
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Must be exactly 10 digits
    if (cleaned.length != 10) {
      return AppStrings.phoneNumberMustHave10Digits;
    }
    
    // Check if first digit is between 6 and 9
    final firstDigit = int.tryParse(cleaned[0]);
    if (firstDigit == null || firstDigit < 6 || firstDigit > 9) {
      return AppStrings.phoneNumberMustStartWith;
    }
    
    // Check if all digits are zeros
    if (cleaned == '0000000000') {
      return AppStrings.phoneNumberCannotBeAllZeros;
    }
    
    // Check if all digits are the same, but allow 6, 7, 8, 9
    // Reject all same digits only if they are NOT 6, 7, 8, or 9
    final firstChar = cleaned[0];
    if (cleaned.split('').every((char) => char == firstChar)) {
      // Allow if all digits are 6, 7, 8, or 9
      if (firstChar != '6' && firstChar != '7' && firstChar != '8' && firstChar != '9') {
        return AppStrings.phoneNumberCannotBeAllSameDigits;
      }
    }

    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.otpRequired;
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 6) {
      return AppStrings.otpMustHave6Digits;
    }

    return null;
  }

  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.panNumberRequired;
    }
    // Remove spaces and convert to uppercase
    final cleaned = value.replaceAll(RegExp(r'\s+'), '').toUpperCase();

    // PAN format: 5 letters, 4 digits, 1 letter (e.g., ABCDE1234F)
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(cleaned)) {
      return AppStrings.panNumberInvalid;
    }

    return null;
  }

  static String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.aadhaarNumberRequired;
    }
    // Remove spaces and special characters
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    // Aadhaar should have exactly 12 digits
    if (cleaned.length != 12) {
      return AppStrings.aadhaarNumberInvalid;
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.addressRequired;
    }
    // Address should have at least 10 characters
    if (value.trim().length < 10) {
      return AppStrings.addressMinLength;
    }
    return null;
  }
}
