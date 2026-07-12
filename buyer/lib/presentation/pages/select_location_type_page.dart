import 'package:buyer/core/services/location_service.dart';
import 'package:buyer/presentation/pages/location_selection_page.dart';
import 'package:buyer/presentation/widgets/primary_blue_button.dart';
import 'package:buyer/presentation/widgets/secondary_gray_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/location_provider.dart';
import 'main_tab_page.dart';

class SelectLocatioTypePage extends StatelessWidget {
  const SelectLocatioTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const MainTabPage()),
                                (route) => false,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: AppColors.skipBorderColor, width: 1),
                              ),
                              child: Text(AppStrings.skip, style: ThemeManager().bodyStyle),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset('assets/images/location_select_image.svg', width: 167, height: 117),
                          const SizedBox(height: 46),
                          Text(AppStrings.locationGreeting, style: ThemeManager().titleStyle),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(
                              AppStrings.locationSubGreeting,
                              style: ThemeManager().bodyStyle.copyWith(color: AppColors.textGrayMedium),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: PrimaryGradientButton(
                            text: AppStrings.useCurrentLocation,
                            onTap: () {
                              final locationProvider = context.read<LocationProvider>();
                              LocationService().checkPermission().then((permission) async {
                                if (permission == LocationPermission.deniedForever) {
                                  await locationProvider.openLocationSettings();
                                  return;
                                }
                                await locationProvider.detectCurrentLocation();
                                Navigator.of(
                                  context,
                                ).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const MainTabPage()),
                                  (route) => false,
                                );
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: AppColors.blueInfo, width: 1),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => LocationSelectionPage()),
                                    );
                                  },
                                  child: Text(
                                    AppStrings.selectManually,
                                    style: TextStyle(
                                      color: AppColors.blueInfo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
