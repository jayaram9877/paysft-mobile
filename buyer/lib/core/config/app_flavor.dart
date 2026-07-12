/// App Flavor enum to represent different build environments
enum AppFlavor {
  dev,
  staging,
  production;

  String get name {
    switch (this) {
      case AppFlavor.dev:
        return 'Dev';
      case AppFlavor.staging:
        return 'Staging';
      case AppFlavor.production:
        return 'Production';
    }
  }

  String get appName {
    switch (this) {
      case AppFlavor.dev:
        return 'Buyer Dev';
      case AppFlavor.staging:
        return 'Buyer Staging';
      case AppFlavor.production:
        return 'Buyer';
    }
  }

  String get baseUrl {
    switch (this) {
      case AppFlavor.dev:
        return 'https://api.demo.paysft.com';
      case AppFlavor.staging:
        return 'https://api.demo.paysft.com';
      case AppFlavor.production:
        return 'https://api.demo.paysft.com';
    }
  }

  bool get enableLogging {
    switch (this) {
      case AppFlavor.dev:
      case AppFlavor.staging:
        return true;
      case AppFlavor.production:
        return false;
    }
  }
}

/// App Configuration class that holds flavor-specific settings
class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String baseUrl;
  final bool enableLogging;

  AppConfig({required this.flavor, required this.appName, required this.baseUrl, required this.enableLogging});

  static AppConfig fromFlavor(AppFlavor flavor) {
    return AppConfig(
      flavor: flavor,
      appName: flavor.appName,
      baseUrl: flavor.baseUrl,
      enableLogging: flavor.enableLogging,
    );
  }
}
