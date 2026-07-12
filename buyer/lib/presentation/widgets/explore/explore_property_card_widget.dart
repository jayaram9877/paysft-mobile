import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_model.dart';
import '../../widgets/common/app_svg_icon.dart';
import '../../pages/property_details_page.dart';
import '../../pages/land_details_page.dart';
import '../../pages/commercial_details_page.dart';
import '../../../core/utils/property_utils.dart';

/// Compact, modern property card used in Explore's 2-column grid.
/// Data-driven: shows only real fields (image, type, name, location, unit type).
class ExplorePropertyCardWidget extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  const ExplorePropertyCardWidget({super.key, required this.property, this.onTap});

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PropertyDetailsPage(property: property)),
    );
  }

  String get _typeLabel {
    switch (property.propertyType.toLowerCase()) {
      case 'commercial':
        return 'Commercial';
      case 'land':
        return 'Land';
      default:
        return 'Residential';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap ?? () => _openDetails(context),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrayLightNew),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + type badge
            Stack(
              children: [
                Image.network(
                  property.imageUrl,
                  height: 118,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(
                          height: 118,
                          color: AppColors.backgroundGrayLight,
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    height: 118,
                    color: AppColors.backgroundGrayLight,
                    child: Icon(Icons.apartment_rounded,
                        size: 36, color: AppColors.textGrayLight),
                  ),
                ),
                Positioned(top: 8, left: 8, child: _typeBadge()),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: themeManager.propertyCardTitleStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        height: 1.25,
                      ),
                    ),
                    const Spacer(),
                    _locationRow(),
                    if (property.unitType != null &&
                        property.unitType!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _unitTypeChip(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _typeLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _locationRow() {
    return Row(
      children: [
        AppSvgIcon(
          assetPath: 'assets/images/location.svg',
          width: 13,
          height: 13,
          color: AppColors.textGray70,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            property.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.textGray70),
          ),
        ),
      ],
    );
  }

  Widget _unitTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlueVeryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        property.unitType!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.bluePrimary,
        ),
      ),
    );
  }
}
