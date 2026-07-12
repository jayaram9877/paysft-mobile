import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/property_details_model.dart';
import '../../domain/entities/property_model.dart';
import '../providers/property_details_provider.dart';
import '../providers/visits_provider.dart';
import '../providers/lead_provider.dart';
import '../widgets/property_details/description_section.dart';
import '../widgets/property_details/units_section.dart';
import '../widgets/meetings/meeting_card.dart';
import '../widgets/meetings/meetings_view.dart' show openMeetingDetails;
import '../widgets/common/app_svg_icon.dart';
import 'gallery_page.dart';
import 'package:buyer/presentation/widgets/common/app_loader_widget.dart';

class PropertyDetailsPage extends StatelessWidget {
  final PropertyModel property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<PropertyDetailsProvider>()..loadPropertyDetails(property),
      child: Consumer<PropertyDetailsProvider>(
        builder: (context, provider, _) {
          final themeManager = ThemeManager();

          // Load scheduled visits and interests once so cards reflect state.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.read<VisitsProvider>().ensureLoaded();
            context.read<LeadProvider>().ensureLoaded();
          });

          return Scaffold(
            backgroundColor: AppColors.backgroundGrayLight,

            body: provider.isLoading
                ? const Center(child: AppLoaderWidget())
                : provider.error != null
                ? Center(child: Text(provider.error!))
                : provider.propertyDetails == null
                ? Center(child: Text(AppStrings.propertyNotFound))
                : RefreshIndicator(
                    onRefresh: () => provider.loadPropertyDetails(property),
                    color: AppColors.bluePrimary,
                    child: CustomScrollView(
                      slivers: [
                        _buildAppBar(context, themeManager, provider),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageAndGallerySection(
                                context,
                                themeManager,
                                provider.propertyDetails!,
                              ),
                              _buildContentContainer(
                                context,
                                themeManager,
                                provider.propertyDetails!,
                                provider,
                              ),
                              if (provider.selectedTabIndex != 1)
                                const SizedBox(height: 24),
                            ],
                          ),
                        ),
                        if (provider.selectedTabIndex == 1 &&
                            provider.propertyDetails!.units.isNotEmpty)
                          PropertyUnitsSliverList(
                            units: provider.propertyDetails!.units,
                          ),
                        if (provider.selectedTabIndex == 1)
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
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
      title: Text(AppStrings.propertyDetails, style: themeManager.titleMediumStyle),
      centerTitle: true,
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
                                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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

  Widget _buildContentContainer(
    BuildContext context,
    ThemeManager themeManager,
    PropertyDetailsModel property,
    PropertyDetailsProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertyHeader(context, themeManager, property),
          _buildBuilderCard(context, themeManager, property),
          _buildScheduledMeetingCard(context, property),
          _buildTabBar(themeManager, provider),
          _buildTabContent(context, themeManager, property, provider),
        ],
      ),
    );
  }

  /// Shows the soonest scheduled visit for this project, if any. Hidden when
  /// there's no scheduled meeting — no mock fallback.
  Widget _buildScheduledMeetingCard(BuildContext context, PropertyDetailsModel property) {
    final visits = context.watch<VisitsProvider>().visits;
    final matches = visits
        .where((v) => v.projectId == property.id && v.status == 'scheduled')
        .toList()
      ..sort((a, b) {
        final ad = a.scheduledFor;
        final bd = b.scheduledFor;
        if (ad == null || bd == null) return 0;
        return ad.compareTo(bd);
      });
    if (matches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: UpcomingMeetingCard(
        visit: matches.first,
        onTap: () => openMeetingDetails(context, matches.first),
      ),
    );
  }

  Widget _buildPropertyHeader(BuildContext context, ThemeManager themeManager, PropertyDetailsModel property) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column with text and location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title, style: themeManager.propertyTitleStyle),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlueVeryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(property.subtitle, style: themeManager.propertySubtitleStyle),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: AppColors.gray700),
                        const SizedBox(width: 4),
                        Text(
                          property.location,
                          style: themeManager.propertyDetailsSubtitleStyle.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24), // space for the line
                  ],
                ),
              ),
              // Badge
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.successGreenLight.withOpacity(0.1), shape: BoxShape.circle),
                child: AppSvgIcon(assetPath: 'assets/images/badge.svg', width: 24, height: 24),
              ),
            ],
          ),
          // Positioned grey line
          Positioned(
            left: 0, // aligns with Column's start (title)
            right: 0, // we will adjust for badge width
            bottom: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Measure the badge width + padding
                const badgeTotalWidth = 32.0; // 24 + 4*2 padding
                return Container(height: 1, width: constraints.maxWidth - badgeTotalWidth, color: AppColors.gray400);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Real builder/developer card (from the API). Hidden when the backend
  /// doesn't provide a builder name — no mock fallback.
  Widget _buildBuilderCard(
    BuildContext context,
    ThemeManager themeManager,
    PropertyDetailsModel property,
  ) {
    final builder = property.builderName?.trim() ?? '';
    if (builder.isEmpty) return const SizedBox.shrink();

    const double borderWidth = 1; // thickness of gradient border
    const double borderRadius = 16;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: EdgeInsets.all(borderWidth), // This creates the border width
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundGrayLight, // inner card color
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundBlueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.apartment_rounded,
                    color: AppColors.bluePrimary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(builder, style: themeManager.agentCardNameStyle),
                    const SizedBox(height: 4),
                    Text('Builder', style: themeManager.agentCardRoleStyle),
                  ],
                ),
              ),
              if (property.reraId != null && property.reraId!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlueLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified,
                          size: 16, color: AppColors.bluePrimary),
                      const SizedBox(width: 4),
                      Text('RERA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bluePrimary,
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeManager themeManager, PropertyDetailsProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildTabItem(themeManager, AppStrings.overview, 0, provider),
          _buildTabItem(themeManager, 'Units', 1, provider),
          _buildTabItem(themeManager, AppStrings.floorPlans, 2, provider),
          _buildTabItem(themeManager, AppStrings.documents, 3, provider),
        ],
      ),
    );
  }

  Widget _buildTabItem(ThemeManager themeManager, String title, int index, PropertyDetailsProvider provider) {
    final isSelected = provider.selectedTabIndex == index;

    return GestureDetector(
      onTap: () => provider.onTabChanged(index),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
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
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    ThemeManager themeManager,
    PropertyDetailsModel property,
    PropertyDetailsProvider provider,
  ) {
    // Units tab — list is rendered as slivers below the header.
    if (provider.selectedTabIndex == 1) {
      if (property.units.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'No units available',
              style: themeManager.bodyStyle.copyWith(color: AppColors.textGray70),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // Overview / Floor Plans / Documents -> overview content
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DescriptionSection(description: property.description),
          _buildPropertyInfoSection(themeManager, property),
          _buildFacilitiesSection(themeManager, property),
          _buildGallerySection(context, themeManager, property),
          _buildLocationSection(themeManager, property),
          const SizedBox(height: 24),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
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
              childAspectRatio: 1.85,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: themeManager.infoCardValueStyle, maxLines: 1),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(label, style: themeManager.infoCardLabelStyle, maxLines: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(ThemeManager themeManager, PropertyDetailsModel property) {
    // Real project amenities only — hide the section when the API has none.
    if (property.facilities.isEmpty) return const SizedBox.shrink();
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.amenities, style: themeManager.propertyDetailsTitleStyle),
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
    const iconMap = <String, String>{
      'car_parking': 'assets/images/fac_car.svg',
      'swimming_pool': 'assets/images/fac_swimming.svg',
      'gym': 'assets/images/fac_gym.svg',
      'gymnasium': 'assets/images/fac_gym.svg',
      'restaurant': 'assets/images/fac_restaurant.svg',
      'wifi': 'assets/images/fac_wifi.svg',
      'pet_center': 'assets/images/fac_pet.svg',
      'sports_club': 'assets/images/fac_sports.svg',
      'clubhouse': 'assets/images/fac_sports.svg',
      'laundry': 'assets/images/fac_laundry.svg',
    };
    final iconAsset = iconMap[facility.iconName.toLowerCase()];
    // Known facility -> its SVG; real amenity slugs -> a generic amenity icon.
    final Widget facilityIcon = iconAsset != null
        ? AppSvgIcon(assetPath: iconAsset, width: 24, height: 24)
        : Icon(Icons.check_circle_outline, size: 24, color: AppColors.bluePrimary);

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
        mainAxisAlignment: MainAxisAlignment.start, // ðŸ‘ˆ align all items from top
        children: [
          const SizedBox(height: 8),

          facilityIcon,
          const SizedBox(height: 8),

          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  facility.name,
                  style: themeManager.facilityChipLabelStyle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
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

    // âœ… Correct visible image calculation (accounts for spacing)
    final visibleCount = ((availableWidth + spacing) / (imageSize + spacing)).floor();

    final totalImages = property.galleryImages.length;

    // Index where overlay should appear
    final overlayIndex = totalImages > visibleCount ? visibleCount - 1 : -1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
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
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 32)),
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
      // Prefer the real Google Maps deep link from the API; fall back to a
      // lat/lng search URL. Launch without a canLaunchUrl gate (which returns
      // false on Android 11+ without matching <queries>) and degrade to a geo:
      // intent, so the tap always does something.
      final link = property.googleMapsLink;
      final uri = Uri.parse(
        (link != null && link.trim().isNotEmpty)
            ? link.trim()
            : 'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
      try {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) {
          await launchUrl(
            Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (_) {
        try {
          await launchUrl(uri);
        } catch (_) {}
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
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

          /// ðŸ—ºï¸ Map with overlay
          GestureDetector(
            onTap: openMaps,
            child: ClipRRect(
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
                        color: Colors.grey[200],
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
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map, size: 64, color: Colors.grey),
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
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.location,
                            style: themeManager.mapOverlayTextStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: openMaps,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppStrings.openInMaps, style: themeManager.mapOverlayTextStyle),
                              SizedBox(width: 4),
                              Icon(Icons.open_in_new, size: 16, color: Colors.white),
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
          ),
        ],
      ),
    );
  }

  Widget _getImage(PropertyDetailsModel property, ThemeManager themeManager) {
    // Combine mainImageUrl with galleryImages for pagination
    final images = [property.mainImageUrl, ...property.galleryImages];
    return _ImageCarousel(images: images);
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> images;

  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  final selectedDotColor = AppColors.bluePrimary;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 232,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 64));
                  },
                );
              },
            ),
          ),
        ),
        // Linear gradient overlay at the bottom for page indicator visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
              ),
            ),
          ),
        ),
        // Page indicator dots positioned at the bottom
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (dotIndex) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotIndex == _currentPage ? selectedDotColor : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

