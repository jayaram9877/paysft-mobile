import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/property_model.dart';
import '../widgets/home/property_card_overlay_widget.dart';
import 'property_details_page.dart';
import 'land_details_page.dart';
import 'commercial_details_page.dart';
import '../../core/utils/property_utils.dart';

class RecommendedPropertiesPage extends StatelessWidget {
  final List<PropertyModel> properties;

  const RecommendedPropertiesPage({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.homeRecommended,
          style: themeManager.titleMediumStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: properties.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final property = properties[index];
          return SizedBox(
            height: 180,
            child: PropertyCardOverlayWidget(
              width: double.infinity,
              property: property,
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
            ),
          );
        },
      ),
    );
  }
}
