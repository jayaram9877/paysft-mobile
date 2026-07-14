import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/app_flavor.dart';
import 'core/di/injection_container.dart' as di;
import 'core/network/dio_client.dart';
import 'core/services/deep_link_service.dart';
import 'core/theme/theme_manager.dart';
import 'presentation/pages/phone_login_page.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/social_auth_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/app_version_provider.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/lead_provider.dart';
import 'presentation/providers/saved_units_provider.dart';
import 'presentation/providers/notifications_provider.dart';
import 'presentation/providers/offers_provider.dart';
import 'presentation/providers/visits_provider.dart';
import 'presentation/providers/copilot_provider.dart';

/// Global navigator key so non-widget layers (e.g. the auth interceptor) can
/// drive navigation such as redirecting to login when the session expires.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _configureSessionExpiryRedirect() {
  DioClient.onSessionExpired = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneLoginPage()),
      (route) => false,
    );
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Default to dev flavor if not specified
  const flavor = AppFlavor.dev;
  await di.init(AppConfig.fromFlavor(flavor));
  _configureSessionExpiryRedirect();
  runApp(MyApp(config: AppConfig.fromFlavor(flavor)));
  // Route incoming deep links (buyer.demo.paysft.com/projects/{id}) into the app.
  DeepLinkService.instance.init(navigatorKey);
}

/// Entry point for flavor-specific main files
void mainWithFlavor(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init(AppConfig.fromFlavor(flavor));
  _configureSessionExpiryRedirect();
  runApp(MyApp(config: AppConfig.fromFlavor(flavor)));
  // Route incoming deep links (buyer.demo.paysft.com/projects/{id}) into the app.
  DeepLinkService.instance.init(navigatorKey);
}

class MyApp extends StatelessWidget {
  final AppConfig config;

  const MyApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<HomeProvider>()),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(
          create: (_) => SocialAuthProvider(
            socialAuthService: di.sl(),
            localStorageService: di.sl(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<LocationProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AppVersionProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<OnboardingProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<LeadProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<SavedUnitsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<VisitsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<OffersProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<NotificationsProvider>()),
        ChangeNotifierProvider(create: (_) => CopilotProvider()),
      ],
      child: Consumer<ThemeManager>(
        builder: (_, themeManager, __) {
          // Set status bar style to white icons
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Brightness.light, // For Android (light icons)
              statusBarBrightness:
                  Brightness.dark, // For iOS (dark content = light icons)
            ),
          );

          return MaterialApp(
            navigatorKey: navigatorKey,
            title: config.appName,
            debugShowCheckedModeBanner: config.enableLogging,
            theme: themeManager.lightTheme,
            darkTheme: themeManager.darkTheme,
            themeMode: themeManager.themeMode,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
