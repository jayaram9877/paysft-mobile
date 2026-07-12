import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/broker_auth_provider.dart';
import '../providers/broker_kyc_provider.dart';
import '../welcome_screen/onboarding_page.dart';
import 'broker_profile_form_page.dart';
import 'documents_upload_page.dart';
import 'verification_in_progress_page.dart';
import 'main_tab_page.dart';

/// Lands here right after login/signup, or from splash for a persisted session.
/// Optionally refreshes the session, then checks broker verification status and
/// routes accordingly:
///   - no profile          -> BrokerProfileFormPage
///   - profile, no docs     -> DocumentsUploadPage
///   - submitted, pending   -> VerificationInProgressPage
///   - active (verified)    -> MainTabPage (Home tab + navbar)
class AuthGatePage extends StatefulWidget {
  /// When true (entered from splash), refresh the stored session first.
  final bool restore;
  const AuthGatePage({super.key, this.restore = false});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    // For a persisted session, refresh the token first. If that fails, the
    // session is no longer valid -> send the user back to onboarding.
    if (widget.restore) {
      final result = await context.read<BrokerAuthProvider>().restoreSession();
      if (!mounted) return;
      // Only a genuinely invalid/absent session returns to onboarding. On a
      // network blip we proceed and try with the existing token.
      if (result == SessionRestore.invalid || result == SessionRestore.none) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
        );
        return;
      }
    }

    final destination =
        await context.read<BrokerKycProvider>().resolveDestination();
    if (!mounted) return;

    final Widget next;
    switch (destination) {
      case KycDestination.verified:
        next = const MainTabPage();
        break;
      case KycDestination.inProgress:
        next = const VerificationInProgressPage();
        break;
      case KycDestination.documents:
        next = const DocumentsUploadPage();
        break;
      case KycDestination.profile:
        next = const BrokerProfileFormPage();
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
