import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyAuthType = 'auth_type'; // 'phone' or 'social'
  static const String _keySocialProvider = 'social_provider'; // 'google' or 'apple'
  static const String _keySelectedLocation = 'selected_location';
  static const String _keyPreferencesCompleted = 'preferences_completed';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> setLoggedIn({
    required bool isLoggedIn,
    String? phoneNumber,
    String? authType,
    String? socialProvider,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);

    if (isLoggedIn) {
      if (phoneNumber != null) {
        await prefs.setString(_keyPhoneNumber, phoneNumber);
      }
      if (authType != null) {
        await prefs.setString(_keyAuthType, authType);
      }
      if (socialProvider != null) {
        await prefs.setString(_keySocialProvider, socialProvider);
      }
    } else {
      // Clear all auth-related data on logout
      await prefs.remove(_keyPhoneNumber);
      await prefs.remove(_keyAuthType);
      await prefs.remove(_keySocialProvider);
    }
  }

  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }

  Future<String?> getAuthType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthType);
  }

  Future<String?> getSocialProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySocialProvider);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyPhoneNumber);
    await prefs.remove(_keyAuthType);
    await prefs.remove(_keySocialProvider);
  }

  // Auth token storage
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  // Location storage methods
  Future<void> saveSelectedLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedLocation, location);
  }

  Future<String?> getSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedLocation);
  }

  Future<void> clearSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedLocation);
  }

  // Preference completion methods
  Future<bool> arePreferencesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPreferencesCompleted) ?? false;
  }

  Future<void> setPreferencesCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPreferencesCompleted, completed);
  }
}
