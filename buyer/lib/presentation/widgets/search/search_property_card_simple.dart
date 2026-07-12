import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_model.dart';
import '../../widgets/common/app_svg_icon.dart';
import '../../pages/property_details_page.dart';
import '../../pages/land_details_page.dart';
import '../../pages/commercial_details_page.dart';
import '../../../core/utils/property_utils.dart';

/// Simplified property card for initial state - shows only name and location
class SearchPropertyCardSimple extends StatelessWidget {
  final PropertyModel property;

  const SearchPropertyCardSimple({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: () {
        Widget page;
        switch (PropertyUtils.getPropertyType(property)) {
          case PropertyType.land:
            page = LandDetailsPage(property: property);
            break;
          case PropertyType.commercial:
            page = CommercialDetailsPage(property: property);
            break;
          case PropertyType.residential:
          default:
            page = PropertyDetailsPage(property: property);
            break;
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderGrayLight, width: 1),
          ),
        ),
        child: Row(
          children: [
            AppSvgIcon(
              assetPath: 'assets/images/location.svg',
              width: 20,
              height: 20,
              color: AppColors.textGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: themeManager.bodyMediumStyle.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    style: themeManager.captionStyle.copyWith(
                      color: AppColors.textGray,
                    ),
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
