import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/property_model.dart';
import '../widgets/home/property_card_widget.dart';
import 'property_details_page.dart';
import 'land_details_page.dart';
import 'commercial_details_page.dart';
import '../../core/utils/property_utils.dart';

class FeaturedPropertiesPage extends StatelessWidget {
  final List<PropertyModel> properties;

  const FeaturedPropertiesPage({super.key, required this.properties});

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
          AppStrings.featuredProperties,
          style: themeManager.titleMediumStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return Row(
            children: [
              Expanded(
                child: PropertyCardWidget(
                  property: property,
                  fullWidth: true,
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
              ),
            ],
          );
        },
      ),
    );
  }
}
