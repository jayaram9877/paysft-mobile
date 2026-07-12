import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/domain/entities/property_model.dart';
import 'package:buyer/presentation/widgets/favorites/favorite_property_card_widget.dart';
import 'package:buyer/presentation/widgets/primary_blue_button.dart';
import 'package:flutter/material.dart';

class RemoveFavouritesBottomSheet extends StatelessWidget {
  final PropertyModel property;
  final List<String> imageUrls;
  final VoidCallback onRemove;
  final VoidCallback onCancel;

  const RemoveFavouritesBottomSheet({
    super.key,
    required this.property,
    required this.imageUrls,
    required this.onRemove,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FavoritePropertyCardWidget(
              hideFavIcon: false,
              property: property,
              imageUrls: imageUrls,
              onTap: () {},
              onFavoriteTap: () {},
              onMenuTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppStrings.removeFromFavorites,
              style: themeManager.headingStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppStrings.removeFromFavoritesConfirm,
              style: themeManager.bodySmallStyle.copyWith(
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: themeManager.outlinedButtonStyle(
                        borderRadius: 28,
                        borderColor: AppColors.blueLight,
                        textColor: AppColors.blueSecondary,
                      ),
                      child: Text(
                        AppStrings.cancel,
                        style: themeManager.buttonTextLargeStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryGradientButton(
                    text: AppStrings.yesRemove,
                    onTap: onRemove,
                    borderRadius: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required PropertyModel property,
    required List<String> imageUrls,
    required VoidCallback onRemove,
    required VoidCallback onCancel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) =>
          RemoveFavouritesBottomSheet(property: property, imageUrls: imageUrls, onRemove: onRemove, onCancel: onCancel),
    );
  }
}
