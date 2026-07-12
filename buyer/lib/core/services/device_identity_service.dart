import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resolves stable device identifiers and backend labels (`android` / `ios`).
class DeviceIdentityService {
  DeviceIdentityService({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfo = deviceInfoPlugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  static const _prefsInstallIdKey = 'buyer_install_device_id';

  /// Backend expects lowercase names per API contract.
  String deviceTypeLabel() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  Future<String> resolveDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        final aid = android.data['androidId']?.toString().trim();
        if (aid != null && aid.isNotEmpty) return aid;
        final fingerprint = android.fingerprint.trim();
        if (fingerprint.isNotEmpty) return fingerprint;
      } else if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        final id = ios.identifierForVendor?.trim();
        if (id != null && id.isNotEmpty) return id;
      }
    } catch (e, st) {
      debugPrint('DeviceIdentityService hardware id failed: $e\n$st');
    }

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefsInstallIdKey)?.trim();
    if (cached != null && cached.isNotEmpty) return cached;

    final rnd = Random.secure();
    final fallback = List.generate(
      16,
      (_) => rnd.nextInt(256),
    ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    await prefs.setString(_prefsInstallIdKey, fallback);
    return fallback;
  }
}
