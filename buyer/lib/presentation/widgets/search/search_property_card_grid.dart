import 'package:buyer/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_model.dart';
import '../../widgets/common/app_svg_icon.dart';
import '../../pages/property_details_page.dart';
import '../../pages/land_details_page.dart';
import '../../pages/commercial_details_page.dart';
import '../../../core/utils/property_utils.dart';

class SearchPropertyCardGrid extends StatelessWidget {
  final PropertyModel property;

  const SearchPropertyCardGrid({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
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
      child: SizedBox(
        width: 167.5,
        height: 246,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Card(
            color: AppColors.backgroundWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0, // increase elevation for more prominent shadow
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Outer container with shadow and white background
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite, // White background
                        border: Border.all(color: AppColors.backgroundGrayVeryLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            property.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.backgroundGrayLight,
                              child: const Icon(Icons.image_not_supported, size: 64),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.title,
                    style: themeManager.searchPropertyCardTitleStyle.copyWith(color: AppColors.textDark, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppSvgIcon(
                        assetPath: 'assets/images/location.svg',
                        width: 13,
                        height: 13,
                        color: AppColors.textGray,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: themeManager.searchPropertyCardLocationStyle.copyWith(
                            color: AppColors.textGray,
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      property.isFeatured ? 'Tribhuja Realty' : 'Signature Avenues',
                      style: themeManager.labelStyle.copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: AppColors.backgroundGrayVeryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppColors.borderGrayLight),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
