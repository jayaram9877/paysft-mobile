import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/widgets/property_details/land_details_view.dart';
import 'package:buyer/presentation/widgets/property_details/pay_token_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/property_details_model.dart';
import '../../domain/entities/property_model.dart';
import '../providers/property_details_provider.dart';
import '../widgets/property_details/description_section.dart';
import '../widgets/property_details/units_section.dart';
import '../widgets/property_details/dotted_vertical_divider.dart';
import '../widgets/property_details/image_carousel_widget.dart';
import '../widgets/common/app_svg_icon.dart';
import 'gallery_page.dart';
import 'booking_slot_page.dart';
import 'agent_profile_page.dart';
import 'package:buyer/presentation/widgets/common/app_loader_widget.dart';

class LandDetailsPage extends StatelessWidget {
  final PropertyModel property;

  const LandDetailsPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<PropertyDetailsProvider>()..loadPropertyDetails(property),
      child: Consumer<PropertyDetailsProvider>(
        builder: (context, provider, _) {
          final themeManager = ThemeManager();

          return Scaffold(
            backgroundColor: AppColors.backgroundGrayLight,

            body: provider.isLoading
                ? const Center(child: AppLoaderWidget())
                : provider.error != null
                ? Center(child: Text(provider.error!, style: themeManager.errorTextStyle))
                : provider.propertyDetails == null
                ? Center(child: Text(AppStrings.propertyNotFound, style: themeManager.errorTextStyle))
                : CustomScrollView(
                    slivers: [
                      _buildAppBar(context, themeManager, provider),
                      SliverToBoxAdapter(
                        child: LandDetailsView(
                          property: provider.propertyDetails!,
                          provider: provider,
                          themeManager: themeManager,
                        ),
                      ),
                    ],
                  ),

          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeManager themeManager, PropertyDetailsProvider provider) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      title: Text(AppStrings.landDetails, style: themeManager.titleMediumStyle),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
        onPressed: () => provider.onBackPressed(context),
      ),
      actions: [
        IconButton(
          icon: AppSvgIcon(assetPath: "assets/images/share.svg"),
          onPressed: () => provider.onSharePressed(context),
        ),
        IconButton(
          icon: AppSvgIcon(assetPath: "assets/images/ic_heart.svg"),
          onPressed: () {
            provider.onFavoritePressed(context);
          },
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, PropertyDetailsProvider provider, ThemeManager themeManager) {
    // When browsing a plot the primary action is "Schedule a Visit" (matching
    // the residential/commercial views). Token payment is started later from
    // the Pay Token flow, not while browsing — so we no longer show "Pay Now"
    // just because pricing data exists.
    return SafeArea(
      child: Container(
        height: 86, // ✅ fixed height
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            /// Chat SVG Icon (already includes circle)
            GestureDetector(
              onTap: () {
                // Chat action
              },
              child: AppSvgIcon(assetPath: 'assets/images/schedule_chat.svg', height: 52, width: 52),
            ),

            const SizedBox(width: 12),

            /// Schedule Visit Button
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.propertyDetails != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookingSlotPage(property: provider.propertyDetails!)),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.blueDark, AppColors.blueDark, AppColors.purpleGradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppSvgIcon(
                            assetPath: 'assets/images/schedule_calendar.svg',
                            height: 24,
                            width: 24,
                            color: AppColors.textWhite,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.requestVisit,
                            style: themeManager.buttonTextStyle.copyWith(color: AppColors.textWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageAndGallerySection(BuildContext context, ThemeManager themeManager, PropertyDetailsModel property) {
    return Container(
      color: AppColors.backgroundGrayLight,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _getImage(property, themeManager),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate how many thumbnails can fit based on available width
              // Available width = container width (already accounts for padding)
              final availableWidth = constraints.maxWidth;
              const thumbnailWidth = 72.0;
              const thumbnailSpacing = 8.0;

              // Calculate how many thumbnails can fit
              // Formula: (availableWidth) / (thumbnailWidth + spacing)
              // We subtract one spacing since the last item doesn't need trailing spacing
              final maxThumbnails = ((availableWidth + thumbnailSpacing) / (thumbnailWidth + thumbnailSpacing)).floor();

              // Use the minimum of: calculated max and available images
              // Ensure we show at least 1 if images are available
              final displayCount = property.galleryImages.isEmpty
                  ? 0
                  : (maxThumbnails < property.galleryImages.length ? maxThumbnails : property.galleryImages.length);

              // Calculate remaining images dynamically
              final remainingCount = property.galleryImages.length - displayCount;
              final hasMoreImages = remainingCount > 0;

              return SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayCount,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isLast = index == displayCount - 1 && hasMoreImages;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: thumbnailWidth,
                            height: 72,
                            child: Image.network(
                              property.galleryImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: AppColors.gray300, child: const Icon(Icons.image, size: 24));
                              },
                            ),
                          ),
                        ),
                        if (isLast)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => GalleryPage(property: property)),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    stops: const [0.0, 0.4],
                                    colors: [AppColors.overlayBlack60, Colors.transparent],
                                  ),
                                ),
                                child: Center(
                                  child: Text('$remainingCount+', style: themeManager.galleryOverlayTextStyle),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeManager themeManager, PropertyDetailsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabItem(themeManager, AppStrings.overview, 0, provider),
          _buildTabItem(themeManager, AppStrings.floorPlans, 1, provider),
          _buildTabItem(themeManager, AppStrings.documents, 2, provider),
        ],
      ),
    );
  }

  Widget _buildTabItem(ThemeManager themeManager, String title, int index, PropertyDetailsProvider provider) {
    final isSelected = provider.selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.onTabChanged(index),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: isSelected ? themeManager.tabBarSelectedStyle : themeManager.tabBarUnselectedStyle,
              ),
            ),
            // Gradient underline
            if (isSelected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, ThemeManager themeManager, PropertyDetailsModel property) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DescriptionSection(description: property.description),
          PropertyUnitsSection(units: property.units),
          _buildAreaDetailsSection(themeManager, property),
          _buildPropertyInfoSection(themeManager, property),
          _buildFacilitiesSection(themeManager, property),
          _buildGallerySection(context, themeManager, property),
          _buildLocationSection(themeManager, property),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAreaDetailsSection(ThemeManager themeManager, PropertyDetailsModel property) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16), // rounded rectangle
        border: Border.all(
          color: AppColors.borderGrayMedium, // light border like design
          width: 1,
        ),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.areaDetails, style: themeManager.propertyDetailsTitleStyle),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhiteLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderBlueLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(property.areaDetails.indoorArea, style: themeManager.propertyDetailsValueStyle),
                      const SizedBox(height: 4),
                      Text(property.areaDetails.indoorAreaLabel, style: themeManager.propertyDetailsLabelStyle),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DottedVerticalDivider(height: 48, color: AppColors.blueInfoLight),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(property.areaDetails.openSkyArea, style: themeManager.propertyDetailsValueStyle),
                      const SizedBox(height: 4),
                      Text(property.areaDetails.openSkyAreaLabel, style: themeManager.propertyDetailsLabelStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfoSection(ThemeManager themeManager, PropertyDetailsModel property) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16), // rounded rectangle
        border: Border.all(
          color: AppColors.borderGrayMedium, // light border like design
          width: 1,
        ),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.propertyInfo, style: themeManager.propertyDetailsTitleStyle),
          const SizedBox(height: 16),
          Divider(color: AppColors.borderGrayMedium, thickness: 1),
          const SizedBox(height: 16),
          GridView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.1,
            ),
            children: [
              _buildInfoCard(
                themeManager,
                'assets/images/sfts_image.svg',
                property.propertyInfo.sqft,
                property.propertyInfo.sqftLabel,
              ),
              _buildInfoCard(
                themeManager,
                'assets/images/bed_rooms.svg',
                property.propertyInfo.bedrooms,
                property.propertyInfo.bedroomsLabel,
              ),
              _buildInfoCard(
                themeManager,
                'assets/images/bath_rooms.svg',
                property.propertyInfo.bathrooms,
                property.propertyInfo.bathroomsLabel,
              ),
              _buildInfoCard(
                themeManager,
                'assets/images/safety_rank.svg',
                property.propertyInfo.safetyRank,
                property.propertyInfo.safetyRankLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeManager themeManager, String iconName, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppSvgIcon(assetPath: iconName, width: 32, height: 32),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: themeManager.infoCardValueStyle),
                const SizedBox(height: 4),
                Text(label, style: themeManager.infoCardLabelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(ThemeManager themeManager, PropertyDetailsModel property) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16), // rounded rectangle
        border: Border.all(
          color: AppColors.borderGrayMedium, // light border like design
          width: 1,
        ),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.facilities, style: themeManager.propertyDetailsTitleStyle),
          const SizedBox(height: 8),
          Divider(color: AppColors.borderGrayMedium, thickness: 1),
          const SizedBox(height: 12),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: property.facilities.length,
            itemBuilder: (context, index) {
              final facility = property.facilities[index];
              return _buildFacilityChip(themeManager, facility);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityChip(ThemeManager themeManager, FacilityModel facility) {
    String iconName;
    switch (facility.iconName) {
      case 'car_parking':
        iconName = 'assets/images/fac_car.svg';
        break;
      case 'swimming_pool':
        iconName = 'assets/images/fac_swimming.svg';
        break;
      case 'gym':
        iconName = 'assets/images/fac_gym.svg';
        break;
      case 'restaurant':
        iconName = 'assets/images/fac_restaurant.svg';
        break;
      case 'wifi':
        iconName = 'assets/images/fac_wifi.svg';
        break;
      case 'pet_center':
        iconName = 'assets/images/fac_pet.svg';
        break;
      case 'sports_club':
        iconName = 'assets/images/fac_sports.svg';
        break;
      case 'laundry':
        iconName = 'assets/images/fac_laundry.svg';
        break;
      default:
        iconName = 'bath_rooms';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16), // rounded rectangle
        border: Border.all(
          color: AppColors.borderGrayMedium, // light border like design
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 👈 align all items from top
        children: [
          const SizedBox(height: 8),

          AppSvgIcon(assetPath: iconName, width: 24, height: 24),
          const SizedBox(height: 8),

          SizedBox(
            height: 18, // 👈 fixed height for single-line text
            child: Text(
              facility.name,
              style: themeManager.facilityChipLabelStyle,
              textAlign: TextAlign.center,
              maxLines: 1, // 👈 single line
              overflow: TextOverflow.ellipsis, // 👈 show ..
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context, ThemeManager themeManager, PropertyDetailsModel property) {
    const double imageSize = 88;
    const double spacing = 8;
    const double horizontalMargin = 16 * 2;
    const double containerPadding = 16 * 2;

    final screenWidth = MediaQuery.of(context).size.width;

    final availableWidth = screenWidth - horizontalMargin - containerPadding;

    // ✅ Correct visible image calculation (accounts for spacing)
    final visibleCount = ((availableWidth + spacing) / (imageSize + spacing)).floor();

    final totalImages = property.galleryImages.length;

    // Index where overlay should appear
    final overlayIndex = totalImages > visibleCount ? visibleCount - 1 : -1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.gallery, style: themeManager.propertyDetailsTitleStyle),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryPage(property: property)));
                },
                child: Row(
                  children: [
                    Text(AppStrings.seeAll, style: themeManager.gallerySeeAllStyle),
                    const SizedBox(width: 4),
                    AppSvgIcon(
                      assetPath: 'assets/images/arrow_right.svg',
                      width: 24,
                      height: 24,
                      color: AppColors.blueInfo,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Divider(color: AppColors.borderGrayMedium),
          const SizedBox(height: 12),

          /// Gallery Images
          SizedBox(
            height: imageSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalImages,
              separatorBuilder: (_, __) => const SizedBox(width: spacing),
              itemBuilder: (context, index) {
                final isOverlayItem = index == overlayIndex;
                final remainingCount = totalImages - visibleCount;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        /// Image
                        Image.network(
                          property.galleryImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.gray300,
                            child: Icon(Icons.image, size: 32, color: AppColors.gray600),
                          ),
                        ),

                        /// Overlay for last visible image
                        if (isOverlayItem) ...[
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                              ),
                            ),
                          ),
                          Center(child: Text('+$remainingCount', style: themeManager.galleryOverlayLargeTextStyle)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ThemeManager themeManager, PropertyDetailsModel property) {
    // Use property's map location data
    final lat = property.mapLocation.latitude;
    final lng = property.mapLocation.longitude;

    // Use the mapImageUrl from property, or fallback to OpenStreetMap
    final mapImageUrl = property.mapLocation.mapImageUrl.isNotEmpty
        ? property.mapLocation.mapImageUrl
        : 'https://maps.googleapis.com/maps/api/staticmap?zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$lat,$lng&key=AIzaSyAmb2FYgNJA5x7JCTRq86SLXCr-5x--B8Y';

    Future<void> openMaps() async {
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      final uri = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.locationAndPublicFacilities, style: themeManager.propertyDetailsTitleStyle),
          const SizedBox(height: 12),
          Divider(color: AppColors.borderGrayMedium),
          const SizedBox(height: 8),

          /// Horizontally scrollable chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: property.publicFacilities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final facility = property.publicFacilities[index];

                String iconName;
                switch (facility.iconName) {
                  case 'hospital':
                    iconName = 'assets/images/loc_hospital.svg';
                    break;
                  case 'gas_station':
                    iconName = 'assets/images/loc_gas_station.svg';
                    break;
                  case 'mall':
                    iconName = 'assets/images/loc_mosque.svg';
                    break;
                  case 'market':
                    iconName = 'assets/images/loc_mall.svg';
                    break;
                  default:
                    iconName = 'assets/images/loc_mall.svg';
                }

                return Chip(
                  side: const BorderSide(color: Colors.transparent),
                  avatar: AppSvgIcon(assetPath: iconName, width: 18, height: 18),
                  label: Text(facility.name, style: themeManager.propertyDetailsLabelStyle),
                  backgroundColor: AppColors.backgroundBlueLight,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          /// 🗺️ Map with overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    mapImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.gray200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback: Show a placeholder with map icon
                      return Container(
                        color: AppColors.gray300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 64, color: AppColors.gray600),
                            const SizedBox(height: 8),
                            Text(property.location, style: themeManager.mapErrorTextStyle),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// Bottom overlay
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.overlayBlack70, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(property.location, style: themeManager.mapOverlayTextStyle),
                        GestureDetector(
                          onTap: openMaps,
                          child: Row(
                            children: [
                              Text(AppStrings.openInMaps, style: themeManager.mapOverlayTextStyle),
                              SizedBox(width: 4),
                              Icon(Icons.open_in_new, size: 16, color: AppColors.textWhite),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getImage(PropertyDetailsModel property, ThemeManager themeManager) {
    // Combine mainImageUrl with galleryImages for pagination
    final images = [property.mainImageUrl, ...property.galleryImages];
    return ImageCarouselWidget(images: images);
  }

  Widget _buildPayTokenSection(ThemeManager themeManager, PropertyDetailsModel property) {
    return PayTokenWidget(decoration: themeManager.payTokenSectionDecorationResidential);
  }
}
