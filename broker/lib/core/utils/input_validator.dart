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
}

