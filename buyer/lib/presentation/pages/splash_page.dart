import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/app_version_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/social_auth_provider.dart';
import '../widgets/primary_blue_button.dart';
import '../widgets/secondary_gray_button.dart';
import 'main_tab_page.dart';
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
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    final appVersionProvider = context.read<AppVersionProvider>();
    // Check login status from storage first
    final authProvider = context.read<AuthProvider>();
    final socialAuthProvider = context.read<SocialAuthProvider>();

    await appVersionProvider.verifyOnAppLaunch();
    await authProvider.checkLoginStatus();
    await socialAuthProvider.checkLoginStatus();

    // Wait for splash animation (total 3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (appVersionProvider.isUpdateRequired) {
      final shouldProceed = await _showVersionUpdateDialog(appVersionProvider);
      if (!mounted || !shouldProceed) return;
    }

    // Navigate based on login status
    if (authProvider.status == AuthStatus.success ||
        socialAuthProvider.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OnboardingPage(forceUpdate: appVersionProvider.isUpdateRequired),
        ),
      );
    }
  }

  Future<bool> _showVersionUpdateDialog(
    AppVersionProvider appVersionProvider,
  ) async {
    final check = appVersionProvider.versionCheck;
    final isForce = check.isForceUpdate;
    final latestVersion = check.latestVersion?.trim();
    final currentVersion = appVersionProvider.currentVersion?.trim();
    final releaseNotes = check.releaseNotes?.trim();
    final message = check.message?.trim();
    final updateUrl = check.updateUrl?.trim();

    final displayMessage = [
      if (message != null && message.isNotEmpty) message,
      if (latestVersion != null && latestVersion.isNotEmpty)
        'Latest version: $latestVersion'
      else if (currentVersion != null && currentVersion.isNotEmpty)
        'Current version: $currentVersion',
      if (releaseNotes != null && releaseNotes.isNotEmpty) releaseNotes,
    ].join('\n\n');

    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: !isForce,
      builder: (context) {
        final theme = context.read<ThemeManager>();
        return PopScope(
          canPop: !isForce,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isForce ? 'Update required' : 'Update available',
                    style: theme.dialogTitleStyle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayMessage.isEmpty
                        ? 'A newer app version is available.'
                        : displayMessage,
                    style: theme.dialogContentStyle.copyWith(
                      color: AppColors.textGray70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryGradientButton(
                    text: 'Update now',
                    onTap: () async {
                      if (updateUrl != null && updateUrl.isNotEmpty) {
                        final uri = Uri.tryParse(updateUrl);
                        if (uri != null) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }

                      if (isForce) {
                        SystemNavigator.pop();
                        return;
                      }
                      if (context.mounted) Navigator.of(context).pop(true);
                    },
                  ),
                  if (!isForce) ...[
                    const SizedBox(height: 10),
                    SecondaryGrayButton(
                      text: 'Later',
                      onTap: () => Navigator.of(context).pop(true),
                      showBottomBorder: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );

    return shouldProceed ?? !isForce;
  }

  Future<void> _triggerAnimation() async {
    // Wait before switching to second background and logo
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _showSecondStage = true);
    }
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
