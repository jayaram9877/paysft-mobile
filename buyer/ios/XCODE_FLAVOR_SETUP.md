# Xcode Flavor Configuration Setup

✅ **Build configurations and schemes have been automatically created!**

## Build Configurations Added

The following build configurations have been added to the project:

- **Debug-dev** - Bundle ID: `com.example.buyer.dev`
- **Debug-staging** - Bundle ID: `com.example.buyer.staging`
- **Debug-prod** - Bundle ID: `com.example.buyer`
- **Release-dev** - Bundle ID: `com.example.buyer.dev`
- **Release-staging** - Bundle ID: `com.example.buyer.staging`
- **Release-prod** - Bundle ID: `com.example.buyer`
- **Profile-dev** - Bundle ID: `com.example.buyer.dev`
- **Profile-staging** - Bundle ID: `com.example.buyer.staging`
- **Profile-prod** - Bundle ID: `com.example.buyer`

## Schemes Created

The following schemes have been automatically created:

- **Runner Dev** - Uses Debug-dev, Release-dev, Profile-dev
- **Runner Staging** - Uses Debug-staging, Release-staging, Profile-staging
- **Runner Prod** - Uses Debug-prod, Release-prod, Profile-prod

### Scheme Configuration Details

**Runner Dev:**
- Run/Test/Analyze: `Debug-dev`
- Profile: `Profile-dev`
- Archive: `Release-dev`

**Runner Staging:**
- Run/Test/Analyze: `Debug-staging`
- Profile: `Profile-staging`
- Archive: `Release-staging`

**Runner Prod:**
- Run/Test/Analyze: `Debug-prod`
- Profile: `Profile-prod`
- Archive: `Release-prod`

## Updating Info.plist for Display Names

You can optionally update `Runner/Info.plist` to use different display names per flavor. However, since we're using Flutter's main files, the app name is controlled by the Dart code.

## Building with Flavors

### Using Flutter CLI:
```bash
# Dev
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

### Using Xcode:
1. Select the appropriate scheme (Runner Dev, Runner Staging, or Runner Prod)
2. Select the build configuration (Debug-dev, Release-dev, etc.)
3. Build and run

## Verifying Configuration

To verify the setup:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Check that the schemes **Runner Dev**, **Runner Staging**, and **Runner Prod** appear in the scheme selector
3. Select each scheme and verify the build configurations are correct
4. Build and run each flavor independently to confirm they work

## Notes

- The existing **Runner** scheme will continue to work with the default Debug/Release/Profile configurations
- You can have multiple flavors installed on the same device since they have different bundle identifiers
- Make sure to update signing & capabilities for each bundle identifier in Xcode if needed

