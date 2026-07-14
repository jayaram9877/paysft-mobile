import 'package:broker/presentation/welcome_screen/splash_page.dart';
import 'package:broker/core/theme/theme_manager.dart';
import 'package:broker/core/di/injection_container.dart' as di;
import 'package:broker/presentation/providers/auth_provider.dart';
import 'package:broker/presentation/providers/broker_auth_provider.dart';
import 'package:broker/presentation/providers/broker_kyc_provider.dart';
import 'package:broker/presentation/providers/home_dashboard_provider.dart';
import 'package:broker/presentation/providers/projects_provider.dart';
import 'package:broker/presentation/providers/profile_provider.dart';
import 'package:broker/presentation/providers/main_tab_controller.dart';
import 'package:broker/presentation/providers/schedule_provider.dart';
import 'package:broker/presentation/providers/copilot_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<BrokerAuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<BrokerKycProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<HomeDashboardProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProjectsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => MainTabController()),
        ChangeNotifierProvider(create: (_) => di.sl<ScheduleProvider>()),
        ChangeNotifierProvider(create: (_) => CopilotProvider()),
      ],
      child: MaterialApp(
        title: 'Paysft Broker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
