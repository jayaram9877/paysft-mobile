import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../domain/entities/property_model.dart';
import '../home/section_header_widget.dart';
import '../home/property_horizontal_card_widget.dart';
import '../../pages/property_details_page.dart';
import '../../pages/land_details_page.dart';
import '../../pages/commercial_details_page.dart';
import '../../pages/related_properties_page.dart';
import '../../../core/utils/property_utils.dart';

/// Related Properties section - matches "Popular for you" UI/UX.
/// Displays list of related properties with See All button.
class RelatedPropertiesSection extends StatelessWidget {
  final List<PropertyModel> properties;
  final VoidCallback? onSeeAll;
  final void Function(BuildContext context, PropertyModel property)? onPropertyTap;

  const RelatedPropertiesSection({
    super.key,
    required this.properties,
    this.onSeeAll,
    this.onPropertyTap,
  });

  /// Default handler: navigate to appropriate details page based on property type
  static void defaultOnPropertyTap(BuildContext context, PropertyModel property) {
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
  }

  /// Default handler: navigate to RelatedPropertiesPage with full list
  static void defaultOnSeeAll(BuildContext context, List<PropertyModel> properties) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RelatedPropertiesPage(properties: properties)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SectionHeaderWidget(
          title: AppStrings.relatedProperties,
          actionText: AppStrings.homeSeeAll,
          onActionTap: onSeeAll ?? () => defaultOnSeeAll(context, properties),
        ),
        const SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: properties
                .map(
                  (property) => Column(
                    children: [
                      const SizedBox(height: 8),
                      PropertyHorizontalCardWidget(
                        property: property,
                        onTap: () {
                          if (onPropertyTap != null) {
                            onPropertyTap!(context, property);
                          } else {
                            defaultOnPropertyTap(context, property);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Divider(color: AppColors.borderGrayLight, height: 1, thickness: 1),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
