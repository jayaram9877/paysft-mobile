import 'package:flutter/material.dart';
import 'package:broker/core/di/injection_container.dart' as di;
import 'package:broker/core/services/local_storage_service.dart';
import 'package:broker/presentation/pages/auth_gate_page.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showSecondStage = false;

  @override
  void initState() {
    super.initState();
    _triggerAnimation();
    _navigateAfterSplash();
  }

  Future<void> _triggerAnimation() async {
    // Wait before switching to second background and logo
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _showSecondStage = true);
    }
  }

  Future<void> _navigateAfterSplash() async {
    // Total splash duration before moving on.
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Maintain session: if a login is stored, resume it (the gate refreshes
    // the token and routes); otherwise show onboarding.
    final loggedIn = await di.sl<LocalStorageService>().isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            loggedIn ? const AuthGatePage(restore: true) : const OnboardingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// 🔥 Animated background
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 900),
            child: Container(
              key: ValueKey(_showSecondStage),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    _showSecondStage
                        ? "assets/images/splash_bg_2.png"
                        : "assets/images/splash_bg.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          /// 🔥 Animated foreground (logos)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 900),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: _showSecondStage ? _fullLogoWidget() : _singleLogoWidget(),
          ),
        ],
      ),
    );
  }

  /// STEP 1 → Logo only
  Widget _singleLogoWidget() {
    return Image.asset(
      "assets/images/logo.png",
      key: const ValueKey("logo_only"),
      width: 120,
      height: 120,
    );
  }

  /// STEP 2 → Logo with text
  Widget _fullLogoWidget() {
    return Image.asset(
      "assets/images/logo_with_text.png",
      key: const ValueKey("logo_full"),
      width: 200,
      height: 200,
    );
  }
}
