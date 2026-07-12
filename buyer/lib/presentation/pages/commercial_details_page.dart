import 'dart:io';
import 'dart:ui';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/widgets/property_details/pay_token_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/property_details_model.dart';
import '../../domain/entities/property_model.dart';
import '../providers/property_details_provider.dart';
import '../widgets/property_details/description_section.dart';
import '../widgets/property_details/units_section.dart';
import '../widgets/property_details/dotted_vertical_divider.dart';
import '../widgets/property_details/image_carousel_widget.dart';
import '../widgets/property_details/document_card.dart';
import '../widgets/property_details/commercial_connectivity_rows.dart';
import '../widgets/property_details/expandable_label_value_section.dart';
import '../widgets/property_details/related_properties_section.dart';
import '../widgets/common/app_svg_icon.dart';
import 'gallery_page.dart';
import 'booking_slot_page.dart';
import 'document_viewer_page.dart';
import 'agent_profile_page.dart';
import 'package:buyer/presentation/widgets/common/app_loader_widget.dart';

class CommercialDetailsPage extends StatefulWidget {
  final PropertyModel property;

  const CommercialDetailsPage({super.key, required this.property});

  @override
  State<CommercialDetailsPage> createState() => _CommercialDetailsPageState();
}

class _CommercialDetailsPageState extends State<CommercialDetailsPage> {
  // Track expanded state for each section
  bool _isUnitDetailsExpanded = false;
  bool _isTechnicalInfrastructureExpanded = false;
  bool _isInteriorWorkspaceExpanded = false;
  bool _isParkingAccessExpanded = false;
  bool _isOperatingPermissionsExpanded = false;
  bool _isWarehouseLogisticsExpanded = false;
  bool _isGccReadyExpanded = false;
  bool _isDataCenterSuitabilityExpanded = false;
  bool _isRetailHighStreetExpanded = false;
  bool _isAmenitiesExpanded = false;

  static final _technicalInfrastructureItems = [
    MapEntry(AppStrings.floorLoadCapacity, '100 KG / SqFt'),
    MapEntry(AppStrings.powerSanctionLoad, '2000 kVA'),
    MapEntry(AppStrings.powerRedundancy, 'Dual Feed'),
    MapEntry(AppStrings.hvacType, 'Central'),
    MapEntry(AppStrings.coolingCapacity, '30 - 60 / SqFt'),
    MapEntry(AppStrings.serverRoomReadiness, 'Yes'),
  ];

  static final _interiorWorkspaceItems = [
    MapEntry(AppStrings.workstationsCapacity, '2000'),
    MapEntry(AppStrings.cabins, '2000'),
    MapEntry(AppStrings.conferenceRooms, '50'),
    MapEntry(AppStrings.receptionArea, 'Yes'),
    MapEntry(AppStrings.pantry, 'Dry & Wet'),
    MapEntry(AppStrings.washrooms, 'Exclusive'),
    MapEntry(AppStrings.falseCeiling, '—'),
    MapEntry(AppStrings.flooring, 'Carpet'),
    MapEntry(AppStrings.lighting, 'Warm'),
  ];

  static final _parkingAccessItems = [
    MapEntry(AppStrings.parkingArea, 'Basement'),
    MapEntry(AppStrings.dedicatedParking, '2000'),
    MapEntry(AppStrings.visitorParking, 'Yes'),
    MapEntry(AppStrings.twoWheelerParking, 'Yes'),
    MapEntry(AppStrings.evCharging, 'Yes'),
    MapEntry(AppStrings.serviceBayAccess, 'Yes'),
  ];

  static final _operatingPermissionsItems = [
    MapEntry(AppStrings.operationsTiming, '24 / 7'),
    MapEntry(AppStrings.activityRestrictions, 'Yes'),
    MapEntry(AppStrings.soundRestrictions, 'Yes'),
    MapEntry(AppStrings.noiseImpact, '—'),
    MapEntry(AppStrings.signageAllowed, 'Yes'),
    MapEntry(AppStrings.brandingRights, 'Yes'),
  ];

  static final _warehouseLogisticsItems = [
    MapEntry(AppStrings.clearCeilingHeight, '100 m'),
    MapEntry(AppStrings.floorLoadCapacity, '20 KG / SqFt'),
    MapEntry(AppStrings.dockDoors, '20'),
    MapEntry(AppStrings.truckTurningRadius, '360 deg'),
    MapEntry(AppStrings.entryGateWH, '15 Ft x 10 Ft'),
    MapEntry(AppStrings.columnSpacing, '10 Ft'),
    MapEntry(AppStrings.powerLoad, 'kVA'),
    MapEntry(AppStrings.fireComplianceReadiness, 'Yes'),
    MapEntry(AppStrings.yardArea, 'Yes'),
    MapEntry(AppStrings.stagingArea, 'No'),
  ];

  static final _gccReadyItems = [
    MapEntry(AppStrings.largeFloorPlates, 'Yes'),
    MapEntry(AppStrings.dualPowerFeed, 'Yes'),
    MapEntry(AppStrings.highParkingRatio, 'No'),
    MapEntry(AppStrings.expansionPossibility, 'Yes'),
    MapEntry(AppStrings.powerRedundancy, '—'),
    MapEntry(AppStrings.evCharging, 'Yes'),
    MapEntry(AppStrings.carParking, '300'),
    MapEntry(AppStrings.twoWheelerParking, 'No'),
    MapEntry(AppStrings.foodCourt, 'Yes'),
    MapEntry(AppStrings.cafeteriaSpace, '1100 SqFt'),
    MapEntry(AppStrings.breakoutAreas, '1200 SqFt'),
    MapEntry(AppStrings.washroomRatio, '1200 SqFt / Floor'),
    MapEntry(AppStrings.accessibility, 'Yes'),
  ];

  static final _dataCenterSuitabilityItems = [
    MapEntry(AppStrings.floorLoadCapacity, '20 KG / SqFt'),
    MapEntry(AppStrings.powerSanctionLoad, '2000 MW'),
    MapEntry(AppStrings.dualPower, 'Yes'),
    MapEntry(AppStrings.dgBackupCapacity, '2000 KVA'),
    MapEntry(AppStrings.coolingReadiness, 'HVAC'),
    MapEntry(AppStrings.fiberConnectivity, 'Yes'),
    MapEntry(AppStrings.serverRoom, 'Yes - 1200 SqFt'),
    MapEntry(AppStrings.water, 'Yes - Municipal'),
    MapEntry(AppStrings.fireSuppression, 'No'),
    MapEntry(AppStrings.noiseTolerance, 'Yes'),
  ];

  static final _retailHighStreetItems = [
    MapEntry(AppStrings.frontageWidth, '2000 m'),
    MapEntry(AppStrings.visibilityFromMainRoad, 'Yes'),
    MapEntry(AppStrings.floorToCeilingHeight, '12 Ft'),
    MapEntry(AppStrings.signageRights, 'Yes'),
    MapEntry(AppStrings.brandingRights, 'No'),
    MapEntry(AppStrings.footfallPotential, 'High'),
    MapEntry(AppStrings.parkingVisibility, 'No'),
    MapEntry(AppStrings.accessFromRoad, 'Left-in'),
    MapEntry(AppStrings.powerLoad, '—'),
    MapEntry(AppStrings.fireNoc, 'Yes'),
  ];

  bool _isCommercialHighlightsExpanded = false;
  bool _isSafetyClearancesExpanded = false;
  bool _isLocationConnectivityExpanded = false;
  bool _isDownloadsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<PropertyDetailsProvider>()..loadPropertyDetails(widget.property),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageAndGallerySection(context, themeManager, provider.propertyDetails!),
                            _buildContentContainer(context, themeManager, provider.propertyDetails!, provider),

                            /// 👇 Add bottom spacing so content doesn't hide
                            const SizedBox(height: 40),
                          ],
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
      title: Text(AppStrings.commercialPropertyDetails, style: themeManager.titleMediumStyle),
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
    return SafeArea(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 86, // ✅ fixed height
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: themeManager.bottomRequestBarDecoration,
            child: Row(
              children: [
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
                          gradient: themeManager.requestVisitGradient,
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

  Widget _buildContentContainer(
    BuildContext context,
    ThemeManager themeManager,
    PropertyDetailsModel property,
    PropertyDetailsProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertyHeader(context, themeManager, property),
          _buildAgentCard(context, themeManager, property, provider),
          _buildTabBar(themeManager, provider),
          _buildTabContent(context, themeManager, property, provider),
        ],
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
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        border: Border.all(color: AppColors.borderGrayMedium),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: AppStrings.reraId, style: themeManager.reraIdLabelStyle),
                            TextSpan(text: '123456789012345', style: themeManager.reraIdValueStyle),
                          ],
                        ),
                      ),
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

  Widget _buildAgentCard(
    BuildContext context,
    ThemeManager themeManager,
    PropertyDetailsModel property,
    PropertyDetailsProvider provider,
  ) {
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius - borderWidth),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgentProfilePage(agent: property.agent)),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(property.agent.imageUrl)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property.agent.name, style: themeManager.agentCardNameStyle),
                        const SizedBox(height: 4),
                        Text(property.agent.role, style: themeManager.agentCardRoleStyle),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlueLight,
                      shape: BoxShape.circle, // makes it a perfect circle
                    ),
                    child: IconButton(
                      icon: AppSvgIcon(assetPath: 'assets/images/agent_call.svg', width: 36, height: 36),
                      onPressed: provider.onCallAgent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlueLight,
                      shape: BoxShape.circle, // makes it a perfect circle
                    ),
                    child: IconButton(
                      icon: AppSvgIcon(assetPath: 'assets/images/agent_message.svg', width: 36, height: 36),
                      onPressed: provider.onMessageAgent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeManager themeManager, PropertyDetailsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabItem(themeManager, AppStrings.overview, 0, provider),
          _buildTabItem(themeManager, AppStrings.pricing, 1, provider),
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

  Widget _buildTabContent(
    BuildContext context,
    ThemeManager themeManager,
    PropertyDetailsModel property,
    PropertyDetailsProvider provider,
  ) {
    if (provider.selectedTabIndex == 0) {
      // Overview tab
      return Container(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PropertyUnitsSection(units: property.units),
            _buildExpandableSection(
              title: AppStrings.commercialUnitDetails,
              isExpanded: _isUnitDetailsExpanded,
              onToggle: () => setState(() => _isUnitDetailsExpanded = !_isUnitDetailsExpanded),
              child: _buildCommercialUnitDetailsSection(themeManager, property),
            ),
            ExpandableLabelValueSection(
              title: AppStrings.technicalAndInfrastructure,
              items: _technicalInfrastructureItems,
              isExpanded: _isTechnicalInfrastructureExpanded,
              onToggle: () => setState(() => _isTechnicalInfrastructureExpanded = !_isTechnicalInfrastructureExpanded),
              themeManager: themeManager,
            ),
            ExpandableLabelValueSection(
              title: AppStrings.interiorAndWorkspace,
              items: _interiorWorkspaceItems,
              isExpanded: _isInteriorWorkspaceExpanded,
              onToggle: () => setState(() => _isInteriorWorkspaceExpanded = !_isInteriorWorkspaceExpanded),
              themeManager: themeManager,
            ),
            ExpandableLabelValueSection(
              title: AppStrings.parkingAndAccess,
              items: _parkingAccessItems,
              isExpanded: _isParkingAccessExpanded,
              onToggle: () => setState(() => _isParkingAccessExpanded = !_isParkingAccessExpanded),
              themeManager: themeManager,
            ),
            ExpandableLabelValueSection(
              title: AppStrings.operatingPermissionsRestrictions,
              items: _operatingPermissionsItems,
              isExpanded: _isOperatingPermissionsExpanded,
              onToggle: () => setState(() => _isOperatingPermissionsExpanded = !_isOperatingPermissionsExpanded),
              themeManager: themeManager,
            ),
            ExpandableLabelValueSection(
              title: AppStrings.warehouseLogisticsSuitability,
              items: _warehouseLogisticsItems,
              isExpanded: _isWarehouseLogisticsExpanded,
              onToggle: () => setState(() => _isWarehouseLogisticsExpanded = !_isWarehouseLogisticsExpanded),
              themeManager: themeManager,
            ),
            ExpandableLabelValueSection(
              title: AppStrings.gccReady,
              items: _gccReadyItems,
              isExpanded: _isGccReadyExpanded,
              onToggle: () => setState(() => _isGccReadyExpanded = !_isGccReadyExpanded),
              themeManager: themeManager,
            ),
            ExpandableLabelValueSection(
              title: AppStrings.dataCenterSuitability,
              items: _dataCenterSuitabilityItems,
              isExpanded: _isDataCenterSuitabilityExpanded,
              onToggle: () => setState(() => _isDataCenterSuitabilityExpanded = !_isDataCenterSuitabilityExpanded),
              themeManager: themeManager,
            ),
            ExpandableLabelValueSection(
              title: AppStrings.retailHighStreet,
              items: _retailHighStreetItems,
              isExpanded: _isRetailHighStreetExpanded,
              onToggle: () => setState(() => _isRetailHighStreetExpanded = !_isRetailHighStreetExpanded),
              themeManager: themeManager,
            ),
            _buildExpandableSection(
              title: AppStrings.amenitiesFeatures,
              isExpanded: _isAmenitiesExpanded,
              onToggle: () => setState(() => _isAmenitiesExpanded = !_isAmenitiesExpanded),
              child: _buildAmenitiesFeaturesSection(themeManager, property),
            ),
            _buildExpandableSection(
              title: AppStrings.commercialHighlights,
              isExpanded: _isCommercialHighlightsExpanded,
              onToggle: () => setState(() => _isCommercialHighlightsExpanded = !_isCommercialHighlightsExpanded),
              child: _buildCommercialHighlightsSection(themeManager, property),
            ),
            _buildExpandableSection(
              title: AppStrings.safetyClearances,
              isExpanded: _isSafetyClearancesExpanded,
              onToggle: () => setState(() => _isSafetyClearancesExpanded = !_isSafetyClearancesExpanded),
              child: _buildSafetyClearancesSection(themeManager, property),
            ),
            _buildExpandableSection(
              title: AppStrings.locationConnectivity,
              isExpanded: _isLocationConnectivityExpanded,
              onToggle: () => setState(() => _isLocationConnectivityExpanded = !_isLocationConnectivityExpanded),
              child: _buildLocationConnectivitySection(themeManager, property),
            ),
            _buildExpandableSection(
              title: AppStrings.downloads,
              isExpanded: _isDownloadsExpanded,
              onToggle: () => setState(() => _isDownloadsExpanded = !_isDownloadsExpanded),
              child: _buildDownloadsSection(context, themeManager, property),
            ),
            RelatedPropertiesSection(properties: property.relatedProperties ?? []),
            const SizedBox(height: 24),
          ],
        ),
      );
    } else if (provider.selectedTabIndex == 1) {
      // Pricing tab
      return _buildPricingTab(context, themeManager, property);
    } else {
      // Documents tab
      return _buildDocumentsTab(context, themeManager, property);
    }
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

          /// 🗺️ Map with overlay - tap anywhere to open full maps
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openMaps(),
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
    return PayTokenWidget(decoration: themeManager.payTokenSectionDecorationCommercial);
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    final themeManager = ThemeManager();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray20, width: 1),
        color: AppColors.backgroundWhite,
        boxShadow: [BoxShadow(color: AppColors.overlayBlack06, blurRadius: 24, offset: const Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: themeManager.expandableSectionTitleStyle),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.textDark),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.borderGray20, thickness: 1, height: 1),
          if (isExpanded) ...[Padding(padding: const EdgeInsets.all(16), child: child)],
        ],
      ),
    );
  }

  // ============================================================================
  // COMMERCIAL SECTIONS
  // ============================================================================

  Widget _buildCommercialUnitDetailsSection(ThemeManager themeManager, PropertyDetailsModel property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Name Label
        Text(AppStrings.projectName, style: themeManager.projectNameLabelStyle),
        const SizedBox(height: 8),
        // Project Name Value
        Text(property.title, style: themeManager.projectNameValueStyle),
        const SizedBox(height: 12),
        // RERA Approved Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.approvedTagBgColor, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvgIcon(
                assetPath: 'assets/images/rera_certified_layout_icon.svg',
                width: 16,
                height: 16,
                color: AppColors.approvedTagTextColor,
              ),
              const SizedBox(width: 6),
              Text(AppStrings.reraApproved, style: themeManager.reraApprovedBadgeTextStyle),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Super Built-up Area (highlighted section)
        // Super Built-up Area (highlighted section)
        Container(
          width: double.infinity, // 👈 forces full width
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundBlueLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderBlueLight, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.superBuiltUpArea, style: themeManager.unitDetailsLabelStyle),
              const SizedBox(height: 6),
              Text('1800 Sft', style: themeManager.unitDetailsValueStyle),
            ],
          ),
        ),

        const SizedBox(height: 16),
        // Unit Details Grid
        _buildCommercialUnitDetailsGrid(themeManager, property),
      ],
    );
  }

  Widget _buildCommercialUnitDetailsGrid(ThemeManager themeManager, PropertyDetailsModel property) {
    final unitDetails = [
      _CommercialUnitDetailItem(icon: 'assets/images/sfts_image.svg', label: AppStrings.carpetArea, value: '1200 Sft'),
      _CommercialUnitDetailItem(icon: 'assets/images/sfts_image.svg', label: AppStrings.builtUpArea, value: '1800 Sft'),
      _CommercialUnitDetailItem(icon: 'assets/images/safety_rank.svg', label: AppStrings.facing, value: 'Road Facing'),
      _CommercialUnitDetailItem(icon: 'assets/images/safety_rank.svg', label: AppStrings.floor, value: '8th Floor'),
      _CommercialUnitDetailItem(icon: 'assets/images/sfts_image.svg', label: AppStrings.commonArea, value: '20%'),
      _CommercialUnitDetailItem(icon: 'assets/images/safety_rank.svg', label: AppStrings.premium, value: 'Corner Unit'),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemCount: unitDetails.length,
      itemBuilder: (context, index) {
        final item = unitDetails[index];
        return _buildCommercialUnitDetailCard(themeManager, item);
      },
    );
  }

  Widget _buildCommercialUnitDetailCard(ThemeManager themeManager, _CommercialUnitDetailItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.borderGrayMedium),
        color: AppColors.backgroundWhite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Fixed icon column (auto-safe)
          SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: AppSvgIcon(
                assetPath: item.icon,
                width: 32, // internal icon size
                height: 32,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 🔹 Text area (auto adjusts + ellipsis)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: themeManager.unitDetailsLabelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // ✅ label safe
                  softWrap: false,
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: themeManager.unitDetailsValueStyle,
                  maxLines: 1, // ✅ value safe
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesFeaturesSection(ThemeManager themeManager, PropertyDetailsModel property) {
    final amenities = [
      AppStrings.highSpeedElevators,
      AppStrings.centralAirConditioning,
      AppStrings.powerBackup100,
      AppStrings.security247Common,
      AppStrings.fireSafetySystem,
      AppStrings.ampleParkingSpace,
      AppStrings.conferenceRooms,
    ];

    return Column(
      children: amenities.map((amenity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrayMedium, width: 1),
          ),
          child: Row(
            children: [
              Expanded(child: Text(amenity, style: themeManager.amenitiesChipLabelStyle)),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: AppColors.bluePrimary, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: AppColors.textWhite, size: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommercialHighlightsSection(ThemeManager themeManager, PropertyDetailsModel property) {
    return Column(
      children: [
        _buildCommercialHighlightRow(themeManager, AppStrings.footageWidth, '25 ft'),
        const SizedBox(height: 12),
        _buildCommercialHighlightRow(themeManager, AppStrings.ceilingHeight, '12 ft'),
        const SizedBox(height: 12),
        _buildCommercialHighlightRow(themeManager, AppStrings.accessPoint, '2 Entries'),
      ],
    );
  }

  Widget _buildCommercialHighlightRow(ThemeManager themeManager, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlueLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderBlueLight, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: themeManager.unitDetailsLabelStyle),
          Text(value, style: themeManager.unitDetailsValueStyle),
        ],
      ),
    );
  }

  Widget _buildSafetyClearancesSection(ThemeManager themeManager, PropertyDetailsModel property) {
    final clearances = [
      AppStrings.fireNoc,
      AppStrings.electricityNoc,
      AppStrings.environmentalClearance,
      AppStrings.occupancyCertificate,
    ];

    return Column(
      children: clearances.map((clearance) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrayMedium, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(clearance, style: themeManager.safetyClearanceLabelStyle),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.transactionStatusBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.safetyBadgeBorder, width: 1),
                ),
                child: Text(AppStrings.approved, style: themeManager.safetyClearanceBadgeTextStyle),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationConnectivitySection(ThemeManager themeManager, PropertyDetailsModel property) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                side: BorderSide(color: AppColors.backgroundWhite),
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
                      colors: [AppColors.overlayBlack70, AppColors.backgroundWhite],
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
                            const SizedBox(width: 4),
                            const Icon(Icons.open_in_new, size: 16, color: AppColors.textWhite),
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

        const SizedBox(height: 24),

        /// Post-map connectivity rows (label on left, value on right)
        CommercialConnectivityRows(connectivity: property.connectivity, themeManager: themeManager),
      ],
    );
  }

  Widget _buildDownloadsSection(BuildContext context, ThemeManager themeManager, PropertyDetailsModel property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDownloadButton(
          context,
          themeManager,
          AppStrings.downloadFloorPlan,
          onTap: () {
            // TODO: Implement download functionality
          },
        ),
        const SizedBox(height: 12),
        _buildDownloadButton(
          context,
          themeManager,
          AppStrings.downloadBrochure,
          onTap: () {
            // TODO: Implement download functionality
          },
        ),
        const SizedBox(height: 12),
        _buildDownloadButton(
          context,
          themeManager,
          AppStrings.downloadReraCertificate,
          onTap: () {
            // TODO: Implement download functionality
          },
        ),
      ],
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    ThemeManager themeManager,
    String label, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        ),
        child: Row(
          children: [
            AppSvgIcon(
              assetPath: 'assets/images/land_details_download.svg',
              width: 20,
              height: 20,
              color: AppColors.pdfTextColor,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: themeManager.downloadButtonTextStyle)),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PRICING TAB METHODS
  // ============================================================================

  Widget _buildPricingTab(BuildContext context, ThemeManager themeManager, PropertyDetailsModel property) {
    if (property.pricing == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(AppStrings.pricingInformationNotAvailable, style: themeManager.propertyDetailsLabelStyle),
        ),
      );
    }

    final pricing = property.pricing!;
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalPlotCostSection(themeManager, pricing),
          _buildPriceBreakdownSection(themeManager, pricing),
          _buildPaymentMilestonesSection(themeManager, pricing),
          _buildEmiCalculatorSection(themeManager, pricing),
          _buildRelationshipManagerSection(themeManager, pricing),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTotalPlotCostSection(ThemeManager themeManager, PricingModel pricing) {
    final totalAmount = double.tryParse(pricing.totalAmount.replaceAll(RegExp(r'[₹,\s]'), '')) ?? 0;
    final amountPaid = double.tryParse(pricing.amountPaid.replaceAll(RegExp(r'[₹,\s]'), '')) ?? 0;
    final progress = totalAmount > 0 ? amountPaid / totalAmount : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: themeManager.greenGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.greenGradientStart.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.totalAmount, style: themeManager.totalAmountLabelStyle),
          const SizedBox(height: 4),
          Text(pricing.totalAmount, style: themeManager.totalAmountValueStyle),
          const SizedBox(height: 16),
          Divider(color: AppColors.textWhite.withOpacity(0.2), height: 1),
          const SizedBox(height: 16),
          _buildCostRow(themeManager, AppStrings.amountPaid, pricing.amountPaid),
          const SizedBox(height: 12),
          _buildCostRow(themeManager, AppStrings.balance, pricing.balance),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.progressTrackGreen, borderRadius: BorderRadius.circular(10)),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 10,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: AppColors.vibrantGreen,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: AppColors.vibrantGreen.withOpacity(0.6), blurRadius: 8, spreadRadius: 1),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(ThemeManager themeManager, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: themeManager.costRowLabelStyle),
        Text(value, style: themeManager.costRowValueStyle),
      ],
    );
  }

  Widget _buildPriceBreakdownSection(ThemeManager themeManager, PricingModel pricing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.priceBreakdown, style: themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          ...pricing.breakdown.asMap().entries.expand((entry) {
            final item = entry.value;
            return [
              if (item.isSubtotal) ...[
                const SizedBox(height: 8),
                Divider(color: AppColors.borderGrayMedium.withOpacity(0.5), thickness: 1, height: 1),
                const SizedBox(height: 12),
              ],
              Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildBreakdownRow(themeManager, item)),
              if (item.isSubtotal) ...[
                const SizedBox(height: 4),
                Divider(color: AppColors.borderGrayMedium.withOpacity(0.5), thickness: 1, height: 1),
                const SizedBox(height: 12),
              ],
            ];
          }).toList(),
          const SizedBox(height: 4),
          Divider(color: AppColors.borderGrayMedium.withOpacity(0.5), thickness: 1, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.grandTotal,
                style: themeManager.propertyDetailsTitleStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              Text(
                pricing.grandTotal,
                style: themeManager.propertyDetailsValueStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(ThemeManager themeManager, PriceBreakdownItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.label,
            style: themeManager.propertyDetailsLabelStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: item.isSubtotal ? AppColors.textDark : AppColors.gray700,
            ),
          ),
        ),
        Text(
          item.amount,
          style: themeManager.propertyDetailsValueStyle.copyWith(
            fontSize: 14,
            fontWeight: item.isSubtotal ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMilestonesSection(ThemeManager themeManager, PricingModel pricing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.paymentMilestones, style: themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildTimelineMilestones(themeManager, pricing.milestones),
        ],
      ),
    );
  }

  Widget _buildTimelineMilestones(ThemeManager themeManager, List<PaymentMilestone> milestones) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final isLast = index == milestones.length - 1;
        return _buildTimelineMilestoneItem(themeManager, milestone, isLast);
      },
    );
  }

  Widget _buildTimelineMilestoneItem(ThemeManager themeManager, PaymentMilestone milestone, bool isLast) {
    final circleColor = _getMilestoneColor(milestone.status);
    final textColor = _getMilestoneTextColor(milestone.status);
    final showTag = milestone.status == 'paid' || milestone.status == 'due';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '${milestone.number}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    fontFamily: AppStrings.fontFamilyText,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            if (!isLast) Container(width: 2, height: 50, color: AppColors.gray300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                milestone.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF38383D),
                  fontFamily: AppStrings.fontFamilyText,
                  height: 20 / 13,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                milestone.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64646D),
                  fontFamily: AppStrings.fontFamilyText,
                  height: 20 / 13,
                  letterSpacing: -0.25,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              milestone.amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF38383D),
                fontFamily: AppStrings.fontFamily,
                height: 24 / 17,
              ),
            ),
            if (showTag) ...[const SizedBox(height: 6), _buildStatusBadge(milestone.status)],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'paid') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB9F8CF), width: 1),
        ),
        child: Text(
          AppStrings.paid,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF008236),
            fontFamily: AppStrings.fontFamilyText,
            height: 16 / 13,
          ),
        ),
      );
    } else if (status == 'due') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFD6A7), width: 1),
        ),
        child: Text(
          AppStrings.due,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFCA3500),
            fontFamily: AppStrings.fontFamilyText,
            height: 16 / 13,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getMilestoneColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.successGreenLight;
      case 'due':
        return const Color(0xFFF54900);
      case 'pending':
      default:
        return AppColors.gray400;
    }
  }

  Color _getMilestoneTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'due':
        return AppColors.textWhite;
      case 'pending':
      default:
        return AppColors.textDark;
    }
  }

  Widget _buildEmiCalculatorSection(ThemeManager themeManager, PricingModel pricing) {
    final emi = pricing.emiCalculator;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.landLoanEmiCalculator, style: themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildEmiInputField(themeManager, AppStrings.loanAmount, emi.loanAmount),
          const SizedBox(height: 12),
          _buildEmiInputField(themeManager, AppStrings.tenureYears, emi.tenure),
          const SizedBox(height: 12),
          _buildEmiInputField(themeManager, AppStrings.interestRate, emi.interestRate),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.approvedTagBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.successGreenLight.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmiResultRow(themeManager, AppStrings.monthlyEmi, emi.monthlyEmi),
                const SizedBox(height: 20),
                _buildEmiResultRow(themeManager, AppStrings.totalInterest, emi.totalInterest),
                const SizedBox(height: 20),
                _buildEmiResultRow(themeManager, AppStrings.totalAmount, emi.totalAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiInputField(ThemeManager themeManager, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: themeManager.propertyDetailsLabelStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrayMedium),
          ),
          child: Row(
            children: [Expanded(child: Text(value, style: themeManager.propertyDetailsValueStyle))],
          ),
        ),
      ],
    );
  }

  Widget _buildEmiResultRow(ThemeManager themeManager, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: themeManager.emiResultLabelStyle),
        const SizedBox(height: 4),
        Text(value, style: themeManager.emiResultValueStyle),
      ],
    );
  }

  Widget _buildRelationshipManagerSection(ThemeManager themeManager, PricingModel pricing) {
    final rm = pricing.relationshipManager;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppStrings.yourRelationshipManager, style: themeManager.sectionHeaderStyle),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bluePrimary.withOpacity(0.8), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(rm.imageUrl)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rm.name, style: themeManager.agentCardNameStyle),
                        const SizedBox(height: 2),
                        Text(rm.role, style: themeManager.agentCardRoleStyle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppStrings.reraId,
                      style: themeManager.propertyDetailsLabelStyle.copyWith(fontSize: 13, color: AppColors.gray700),
                    ),
                    TextSpan(
                      text: rm.reraId,
                      style: themeManager.propertyDetailsValueStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (rm.isVerified) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.approvedTagBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.successGreenLight.withOpacity(0.3)),
                  ),
                  child: Text(AppStrings.verifiedChannelPartner, style: themeManager.verifiedTagStyle),
                ),
              ],
              const SizedBox(height: 16),
              Divider(color: AppColors.borderGrayLight.withOpacity(0.5), thickness: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildContactButton('assets/images/land_details_call.svg', () {})),
                  const SizedBox(width: 12),
                  Expanded(child: _buildContactButton('assets/images/land_details_message.svg', () {})),
                  const SizedBox(width: 12),
                  Expanded(child: _buildContactButton('assets/images/land_details_chat.svg', () {})),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton(String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bluePrimary.withOpacity(0.6)),
        ),
        child: Center(
          child: AppSvgIcon(assetPath: iconPath, width: 22, height: 22, color: AppColors.bluePrimary),
        ),
      ),
    );
  }

  // ============================================================================
  // DOCUMENTS TAB METHODS
  // ============================================================================

  Widget _buildDocumentsTab(BuildContext context, ThemeManager themeManager, PropertyDetailsModel property) {
    final documents = property.documents ?? [];
    if (documents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(AppStrings.noDocumentsAvailable, style: themeManager.propertyDetailsLabelStyle)),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.availableDocuments, style: themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          ...documents.map((doc) => DocumentCard(document: doc, onTap: () => _downloadAndViewDocument(context, doc))),
        ],
      ),
    );
  }

  Future<void> _downloadAndViewDocument(BuildContext context, DocumentModel document) async {
    if (document.downloadUrl == null || document.downloadUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.downloadUrlNotAvailable), backgroundColor: AppColors.errorRed));
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.downloading),
          duration: const Duration(seconds: 30),
          backgroundColor: AppColors.bluePrimary,
        ),
      );

      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          final manageStorageStatus = await Permission.manageExternalStorage.request();
          if (!manageStorageStatus.isGranted) {
            scaffoldMessenger.hideCurrentSnackBar();
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(AppStrings.storagePermissionDenied), backgroundColor: AppColors.errorRed),
            );
            return;
          }
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadsPath = '${directory.path.split('Android')[0]}Download';
          final downloadsDir = Directory(downloadsPath);
          if (await downloadsDir.exists()) {
            directory = downloadsDir;
          }
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access download directory');
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final response = await http.get(Uri.parse(document.downloadUrl!));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      String extension = 'pdf';
      final urlPath = Uri.parse(document.downloadUrl!).path.toLowerCase();
      if (urlPath.endsWith('.pdf')) {
        extension = 'pdf';
      } else if (urlPath.endsWith('.doc') || urlPath.endsWith('.docx')) {
        extension = 'doc';
      } else if (urlPath.endsWith('.xls') || urlPath.endsWith('.xlsx')) {
        extension = 'xls';
      } else if (urlPath.endsWith('.jpg') || urlPath.endsWith('.jpeg')) {
        extension = 'jpg';
      } else if (urlPath.endsWith('.png')) {
        extension = 'png';
      }

      final sanitizedTitle = document.title.replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
      final fileName = '$sanitizedTitle.$extension';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(child: Text(AppStrings.downloadedAndStored)),
                GestureDetector(
                  onTap: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentViewerPage(filePath: filePath, documentTitle: document.title),
                      ),
                    );
                  },
                  child: Text(
                    AppStrings.view,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading file: $e');
      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.downloadFailed}: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// Helper class for commercial unit detail items
class _CommercialUnitDetailItem {
  final String icon;
  final String label;
  final String value;

  _CommercialUnitDetailItem({required this.icon, required this.label, required this.value});
}

// Helper class for nearby places
class _NearbyPlace {
  final String category;
  final String icon;
  final String name;
  final String distance;

  _NearbyPlace({required this.category, required this.icon, required this.name, required this.distance});
}

// Extension to group list items
extension ListGroupBy<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keyFunction(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
}
