import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Shown after KYC documents are submitted; the broker is `pending` (in review).
class VerificationInProgressPage extends StatelessWidget {
  const VerificationInProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPurpleBright.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.primaryPurpleBright,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verification in progress',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your documents have been submitted and are under review. '
                'We\'ll notify you once your account is verified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
