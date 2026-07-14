/// Build environments. The only thing that varies between them is the API
/// base URL (and whether verbose network logging is on).
enum AppFlavor {
  dev,
  production;

  String get appName {
    switch (this) {
      case AppFlavor.dev:
        return 'Buyer Dev';
      case AppFlavor.production:
        return 'Buyer';
    }
  }

  String get baseUrl {
    switch (this) {
      case AppFlavor.dev:
        return 'https://api.demo.paysft.com';
      case AppFlavor.production:
        // TODO: point this at the real production API once it exists.
        return 'https://api.paysft.com';
    }
  }

  /// Verbose request/response logging — on for dev, off in production so JWTs
  /// and PII are never written to device logs.
  bool get enableLogging {
    switch (this) {
      case AppFlavor.dev:
        return true;
      case AppFlavor.production:
        return false;
    }
  }
}

/// App Configuration class that holds flavor-specific settings.
class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String baseUrl;
  final bool enableLogging;

  AppConfig({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    required this.enableLogging,
  });

  static AppConfig fromFlavor(AppFlavor flavor) {
    return AppConfig(
      flavor: flavor,
      appName: flavor.appName,
      baseUrl: flavor.baseUrl,
      enableLogging: flavor.enableLogging,
    );
  }
}
