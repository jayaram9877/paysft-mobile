import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_model.dart';
import '../../widgets/common/app_svg_icon.dart';
import '../../pages/property_details_page.dart';
import '../../pages/land_details_page.dart';
import '../../pages/commercial_details_page.dart';
import '../../../core/utils/property_utils.dart';

/// Full-width compact property row used in Explore's list layout.
/// Data-driven: image + name + location + unit-type chip (no hardcoded content).
class SearchPropertyCardList extends StatelessWidget {
  final PropertyModel property;

  const SearchPropertyCardList({super.key, required this.property});

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
      onTap: () => _openDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrayLightNew),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail
              Image.network(
                property.imageUrl,
                width: 112,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 112,
                  color: AppColors.backgroundGrayLight,
                  child: Icon(Icons.apartment_rounded,
                      size: 32, color: AppColors.textGrayLight),
                ),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        property.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: themeManager.searchPropertyCardTitleStyle.copyWith(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
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
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textGray70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _tag(_typeLabel),
                          if (property.unitType != null &&
                              property.unitType!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Flexible(child: _tag(property.unitType!)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrayVeryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayLight),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.gray600,
        ),
      ),
    );
  }
}
