import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_stats_model.dart';
import '../../widgets/common/app_svg_icon.dart';

class FeaturedPropertyCardWidget extends StatelessWidget {
  final FeaturedPropertyModel property;
  final VoidCallback? onTap;
  final bool useGradientStyle;

  const FeaturedPropertyCardWidget({
    super.key,
    required this.property,
    this.onTap,
    this.useGradientStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(useGradientStyle ? 16 : 22),
          border: Border.all(
            color: useGradientStyle
                ? Colors.black.withOpacity(0.10)
                : AppColors.borderGrayLightNew,
          ),
          gradient: useGradientStyle
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF155DFC), Color(0xFF1447E6)],
                )
              : null,
          color: useGradientStyle ? null : AppColors.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: useGradientStyle
                  ? const Color(0xFF0733F9).withOpacity(0.14)
                  : Colors.black.withOpacity(0.12),
              blurRadius: useGradientStyle ? 24 : 36,
              offset: Offset(0, useGradientStyle ? 14 : 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.ultramarine90,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Featured',
                style: themeManager.featuredPropertyLocationStyle.copyWith(fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
            // Property name
            Text(
              property.name,
              style: themeManager.featuredPropertyNameStyle.copyWith(
                color: useGradientStyle ? AppColors.textWhite : AppColors.textGray90,
              ),
            ),
            const SizedBox(height: 8),
            // Location
            Row(
              children: [
                AppSvgIcon(
                  assetPath: 'assets/images/location.svg',
                  width: 16,
                  height: 16,
                  color: useGradientStyle ? AppColors.textWhite : AppColors.textGray70,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    property.location,
                    style: themeManager.featuredPropertyLocationStyle.copyWith(
                      color: useGradientStyle ? AppColors.textWhite : AppColors.textGray70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Payment info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Next Payment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Payment',
                      style: themeManager.nextPaymentLabelStyle.copyWith(
                        color: useGradientStyle ? AppColors.ultramarine10 : AppColors.textGray70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.nextPayment,
                      style: themeManager.nextPaymentValueStyle.copyWith(
                        color: useGradientStyle ? AppColors.ultramarine10 : AppColors.paymentOrange,
                      ),
                    ),
                  ],
                ),
                // Due Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due Date',
                      style: themeManager.dueDateLabelStyle.copyWith(
                        color: useGradientStyle ? AppColors.ultramarine10 : AppColors.textGray70,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.dueDate,
                      style: themeManager.dueDateValueStyle.copyWith(
                        color: useGradientStyle ? AppColors.ultramarine10 : AppColors.textGray90,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
