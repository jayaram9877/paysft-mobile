import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_model.dart';
import '../../widgets/common/app_svg_icon.dart';

class PropertyHorizontalCardWidget extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  const PropertyHorizontalCardWidget({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.backgroundWhite, // flat background
        child: Row(
          children: [
            Container(
              width: 80,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(8), // image rounding is OK
                image: DecorationImage(image: NetworkImage(property.imageUrl), fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(property.title, style: themeManager.propertyCardTitleStyle, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AppSvgIcon(
                          assetPath: 'assets/images/location.svg',
                          width: 14,
                          height: 14,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            property.location,
                            style: themeManager.propertyCardLocationStyle.copyWith(
                              color: AppColors.gray400,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
