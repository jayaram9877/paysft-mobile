import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_model.dart';

class PropertyCardWidget extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;
  final bool fullWidth;

  const PropertyCardWidget({super.key, required this.property, this.onTap, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: themeManager.propertyCardWidth,
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderGrayLightNew, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(4, 12),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: fullWidth ? const EdgeInsets.all(12) : const EdgeInsets.only(top: 12),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      property.imageUrl,
                      height: 266,
                      width: fullWidth ? double.infinity : 226,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: themeManager.propertyCardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title, style: themeManager.propertyCardTitleStyle, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      property.location,
                      style: themeManager.propertyCardLocationStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
