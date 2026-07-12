import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyAuthType = 'auth_type'; // 'phone' or 'social'
  static const String _keySocialProvider = 'social_provider'; // 'google' or 'apple'
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keySelectedLocation = 'selected_location';
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> setLoggedIn({
    required bool isLoggedIn,
    String? phoneNumber,
    String? authType,
    String? socialProvider,
    String? accessToken,
    String? refreshToken,
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
      if (accessToken != null) {
        await prefs.setString(_keyAccessToken, accessToken);
      }
      if (refreshToken != null) {
        await prefs.setString(_keyRefreshToken, refreshToken);
      }
    } else {
      // Clear all auth-related data on logout
      await prefs.remove(_keyPhoneNumber);
      await prefs.remove(_keyAuthType);
      await prefs.remove(_keySocialProvider);
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
    }
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Updates just the token pair (used by the refresh flow), keeping the rest
  /// of the login state intact.
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_keyRefreshToken, refreshToken);
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

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyPhoneNumber);
    await prefs.remove(_keyAuthType);
    await prefs.remove(_keySocialProvider);
  }

  static const String _keySelectedCityId = 'selected_city_id';
  static const String _keySelectedLat = 'selected_lat';
  static const String _keySelectedLng = 'selected_lng';

  Future<void> clearSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedLocation);
    await prefs.remove(_keySelectedCityId);
    await prefs.remove(_keySelectedLat);
    await prefs.remove(_keySelectedLng);
  }

  // Location storage methods
  Future<void> saveSelectedLocation(
    String location, {
    String? cityId,
    double? latitude,
    double? longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedLocation, location);
    if (cityId != null && cityId.isNotEmpty) {
      await prefs.setString(_keySelectedCityId, cityId);
    } else {
      await prefs.remove(_keySelectedCityId);
    }
    if (latitude != null && longitude != null) {
      await prefs.setDouble(_keySelectedLat, latitude);
      await prefs.setDouble(_keySelectedLng, longitude);
    }
  }

  Future<String?> getSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedLocation);
  }

  /// Backend city id (`/buyer/cities`.id) matching the saved location, used to
  /// filter `/buyer/projects`. Null when the location couldn't be resolved to a
  /// backend city.
  Future<String?> getSelectedCityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCityId);
  }

  /// Last picked map coordinates, so the map picker reopens where it was left.
  Future<double?> getSelectedLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keySelectedLat);
  }

  Future<double?> getSelectedLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keySelectedLng);
  }

  Future<void> clearSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedLocation);
    await prefs.remove(_keySelectedCityId);
    await prefs.remove(_keySelectedLat);
    await prefs.remove(_keySelectedLng);
  }

  static const String _keyReadNotifications = 'read_notification_ids';
  static const String _keyOfferFirstSeen = 'offer_first_seen_';

  Future<Set<String>> getReadNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_keyReadNotifications) ?? const []).toSet();
  }

  Future<void> markNotificationRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getReadNotificationIds();
    if (ids.contains(id)) return;
    await prefs.setStringList(_keyReadNotifications, [...ids, id]);
  }

  Future<void> markAllNotificationsRead(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getReadNotificationIds();
    await prefs.setStringList(
      _keyReadNotifications,
      {...existing, ...ids}.toList(growable: false),
    );
  }

  Future<DateTime?> getOfferFirstSeen(String saleId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyOfferFirstSeen$saleId');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setOfferFirstSeen(String saleId, DateTime when) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyOfferFirstSeen$saleId', when.toIso8601String());
  }
}
