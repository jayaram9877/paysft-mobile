import '../../../domain/entities/app_version_check.dart';

class VerifyAppVersionResponse {
  final String? status;
  final String? message;
  final bool? isUpdateRequired;
  final bool? isForceUpdate;
  final String? latestVersion;
  final String? minSupportedVersion;
  final bool? canSkip;
  final String? releaseNotes;
  final String? updateUrl;

  const VerifyAppVersionResponse({
    this.status,
    this.message,
    this.isUpdateRequired,
    this.isForceUpdate,
    this.latestVersion,
    this.minSupportedVersion,
    this.canSkip,
    this.releaseNotes,
    this.updateUrl,
  });

  factory VerifyAppVersionResponse.fromJson(Map<String, dynamic> json) {
    final responseObject = _asMap(json['responceDataObject']);
    final data = _asMap(responseObject['data']);

    return VerifyAppVersionResponse(
      status: _asString(json['status']),
      message:
          _asString(responseObject['message']) ?? _asString(json['message']),
      isUpdateRequired:
          _asBool(data['isUpdateRequired']) ??
          _asBool(data['isForceUpdate']) ??
          _asBool(data['forceUpdate']) ??
          _asBool(data['required']),
      isForceUpdate:
          _asBool(data['isForceUpdate']) ??
          _asBool(data['forceUpdate']) ??
          _asBool(data['isMandatory']),
      latestVersion:
          _asString(data['latestVersion']) ?? _asString(data['currentVersion']),
      minSupportedVersion:
          _asString(data['minSupportedVersion']) ??
          _asString(data['minimumSupportedVersion']),
      canSkip: _asBool(data['canSkip']) ?? _asBool(data['isSkippable']),
      releaseNotes: _asString(data['releaseNotes']),
      updateUrl:
          _asString(data['updateUrl']) ??
          _asString(data['storeUrl']) ??
          _asString(data['playStoreUrl']) ??
          _asString(data['appStoreUrl']),
    );
  }

  AppVersionCheck toEntity(String currentVersion) {
    final minVersionCheck = _isVersionLower(
      currentVersion,
      minSupportedVersion,
    );
    final requiredByFlag = isUpdateRequired == true;
    final requiredBySkipRule = canSkip == false;
    final forceByFlag = isForceUpdate == true;

    return AppVersionCheck(
      isUpdateRequired: requiredByFlag || requiredBySkipRule || minVersionCheck,
      isForceUpdate: forceByFlag || requiredBySkipRule || minVersionCheck,
      latestVersion: latestVersion,
      minSupportedVersion: minSupportedVersion,
      message: message,
      releaseNotes: releaseNotes,
      updateUrl: updateUrl,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return <String, dynamic>{};
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    return raw.isEmpty ? null : raw;
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes')
        return true;
      if (normalized == 'false' || normalized == '0' || normalized == 'no')
        return false;
    }
    return null;
  }

  static bool _isVersionLower(String current, String? minimumSupported) {
    if (minimumSupported == null || minimumSupported.trim().isEmpty)
      return false;

    final currentParts = _parseVersion(current);
    final minParts = _parseVersion(minimumSupported);
    final maxLen = currentParts.length > minParts.length
        ? currentParts.length
        : minParts.length;

    for (var i = 0; i < maxLen; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final minPart = i < minParts.length ? minParts[i] : 0;

      if (currentPart < minPart) return true;
      if (currentPart > minPart) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String version) {
    final numeric = version.split('+').first;
    return numeric.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  }
}
