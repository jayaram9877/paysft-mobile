import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_model.dart';
import '../../widgets/common/app_svg_icon.dart';

class PropertyCardOverlayWidget extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;
  final double? width;

  const PropertyCardOverlayWidget({super.key, required this.property, this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        shadowColor: AppColors.overlayBlack25,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(themeManager.propertyCardBorderRadius)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Container(
              height: 166,
              width: width ?? 224,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(property.imageUrl), fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: themeManager.propertyCardTitleStyle.copyWith(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppSvgIcon(
                        assetPath: 'assets/images/location.svg',
                        width: 14,
                        height: 14,
                        color: AppColors.textWhite,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          property.location,
                          style: themeManager.propertyCardLocationStyle.copyWith(
                            color: AppColors.backgroundGrayVeryLight,
                            fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
