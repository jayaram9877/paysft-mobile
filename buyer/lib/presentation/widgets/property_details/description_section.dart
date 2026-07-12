import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';
import 'package:readmore/readmore.dart';

class DescriptionSection extends StatelessWidget {
  final String description;

  const DescriptionSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: themeManager.propertyDetailsTitleStyle,
          ),
          const SizedBox(height: 8),
          ReadMoreText(
            description,
            trimLines: 3,
            preDataTextStyle: TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            colorClickableText: AppColors.blueInfo,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Read more',
            trimExpandedText: ' Read less',
            style: themeManager.descriptionStyle,
            moreStyle: themeManager.readMoreStyle,
            lessStyle: themeManager.readMoreStyle,
          ),
        ],
      ),
    );
  }
}
