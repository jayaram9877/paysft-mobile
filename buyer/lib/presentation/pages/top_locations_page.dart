import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/location_model.dart';
import '../widgets/home/location_chip_widget.dart';

class TopLocationsPage extends StatelessWidget {
  final List<LocationModel> locations;
  final Function(LocationModel) onLocationTap;

  const TopLocationsPage({super.key, required this.locations, required this.onLocationTap});

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
          AppStrings.homeTopLocations,
          style: themeManager.titleMediumStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: locations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final location = locations[index];
          return SizedBox(
            height: 60,
            child: InkWell(
              onTap: () => onLocationTap(location),
              child: LocationChipWidget(location: location, onTap: () => onLocationTap(location)),
            ),
          );
        },
      ),
    );
  }
}
