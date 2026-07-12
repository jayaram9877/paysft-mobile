import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/lead_provider.dart';

/// Registers interest in a unit via POST /buyer/leads. Once interested, shows a
/// read-only state — dropping interest is only available from Favorites.
class InterestButton extends StatelessWidget {
  final String unitId;

  /// When true, uses the taller/bolder styling for the unit details page.
  final bool prominent;

  const InterestButton({
    super.key,
    required this.unitId,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    final leads = context.watch<LeadProvider>();
    final interested = leads.isInterested(unitId);
    final busy = leads.isBusy(unitId);

    final height = prominent ? 54.0 : 42.0;
    final fontSize = prominent ? 16.0 : 14.0;

    if (interested) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.tokenPaidGreen.withValues(alpha: 0.12),
            disabledBackgroundColor:
                AppColors.tokenPaidGreen.withValues(alpha: 0.12),
            disabledForegroundColor: AppColors.tokenPaidGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                "Interested",
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    Future<void> onTap() async {
      final message =
          await context.read<LeadProvider>().expressInterest(unitId);
      if (message != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      }
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: busy ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.bluePrimary,
          side: const BorderSide(color: AppColors.bluePrimary, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "I'm Interested",
                    style:
                        TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }
}
