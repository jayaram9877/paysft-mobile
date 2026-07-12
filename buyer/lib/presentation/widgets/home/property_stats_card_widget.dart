import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';

class PropertyStatsCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool isPayment;

  const PropertyStatsCardWidget({
    super.key,
    required this.label,
    required this.value,
    this.isPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray20),
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: isPayment ? themeManager.pendingPaymentsLabelStyle : themeManager.totalPropertiesLabelStyle,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: isPayment ? themeManager.paymentValueStyle : themeManager.propertyCountStyle,
          ),
        ],
      ),
    );
  }
}
