class AppVersionCheck {
  final bool isUpdateRequired;
  final bool isForceUpdate;
  final String? latestVersion;
  final String? minSupportedVersion;
  final String? message;
  final String? releaseNotes;
  final String? updateUrl;

  const AppVersionCheck({
    required this.isUpdateRequired,
    this.isForceUpdate = false,
    this.latestVersion,
    this.minSupportedVersion,
    this.message,
    this.releaseNotes,
    this.updateUrl,
  });
}
