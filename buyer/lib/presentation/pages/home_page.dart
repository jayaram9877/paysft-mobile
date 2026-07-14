import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_string_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/home_provider.dart';
import '../widgets/home/category_item_widget.dart';
import '../widgets/home/location_chip_widget.dart';
import '../widgets/home/property_card_widget.dart';
import '../widgets/home/property_card_overlay_widget.dart';
import '../widgets/home/property_horizontal_card_widget.dart';
import '../widgets/home/search_bar_widget.dart';
import '../widgets/home/section_header_widget.dart';
import '../widgets/home/property_stats_card_widget.dart';
import '../widgets/home/featured_property_card_widget.dart';
import '../widgets/home/property_type_card_widget.dart';
import '../widgets/home/quick_action_card_widget.dart';
import '../widgets/common/app_svg_icon.dart';
import 'notifications_page.dart';
import 'copilot_page.dart';
import '../widgets/common/app_loader_widget.dart';
import 'location_selection_page.dart';
import '../providers/location_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/offers_provider.dart';
import '../providers/visits_provider.dart';
import '../widgets/home/buyer_offer_card.dart';
import '../widgets/meetings/meeting_card.dart';
import '../widgets/meetings/meetings_view.dart' show openMeetingDetails;
import 'offer_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasInitializedLocation = false;
  LocationProvider? _locationProvider;

  /// Refetch the catalog whenever the selected city (backend id) changes.
  void _onLocationChanged() {
    if (!mounted) return;
    context.read<HomeProvider>().setCity(_locationProvider?.selectedCityId);
  }

  @override
  void dispose() {
    _locationProvider?.removeListener(_onLocationChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load home data + trigger location detection when home page is first shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Refetch the catalog when the buyer changes their city.
      _locationProvider = context.read<LocationProvider>();
      _locationProvider!.addListener(_onLocationChanged);
      // Load from the backend now that the auth token is available.
      context.read<HomeProvider>().ensureLoaded(
            cityId: _locationProvider!.selectedCityId,
          );
      context.read<VisitsProvider>().ensureLoaded();
      context.read<OffersProvider>().ensureLoaded();
      context.read<NotificationsProvider>().ensureLoaded();

      if (!_hasInitializedLocation) {
        _hasInitializedLocation = true;
        final locationProvider = context.read<LocationProvider>();
        // If location is still "Select Location", trigger detection
        if (locationProvider.selectedLocation == AppStrings.selectLocation ||
            locationProvider.selectedLocation.isEmpty) {
          locationProvider.detectCurrentLocation();
        }
      }
    });
  }

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([
      context.read<HomeProvider>().fetchData(),
      context.read<VisitsProvider>().reload(),
      context.read<OffersProvider>().reload(),
      context.read<NotificationsProvider>().reload(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final themeManager = ThemeManager();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray25,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CopilotPage()),
        ),
        backgroundColor: AppColors.bluePrimary,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('Copilot',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: ColoredBox(
        color: AppColors.backgroundGray25,
        child: SafeArea(
          child: homeProvider.isLoading
              ? const Center(child: AppLoaderWidget())
              : RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  color: AppColors.bluePrimary,
                  child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context, homeProvider)),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(child: _buildSearchBarWithToggle(context, homeProvider, themeManager)),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    _buildOffersSection(context),
                    _buildUpcomingMeetingSection(context),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    if (homeProvider.showAllSections) ...[
                      _buildFeaturedSection(context, homeProvider, themeManager),
                      _buildCategoriesSection(context, homeProvider, themeManager),
                      _buildRecommendedSection(context, homeProvider, themeManager),
                      _buildNearbySection(context, homeProvider, themeManager),
                      _buildPopularSection(context, homeProvider, themeManager),
                      _buildTopLocationsSection(context, homeProvider, themeManager),
                    ],
                    if (homeProvider.showAllSections == false) ...[
                      _buildPropertyStatsSection(context, homeProvider, themeManager),
                      _buildMyPropertiesSection(context, homeProvider, themeManager),
                      _buildPropertyTypesSection(context, homeProvider, themeManager),
                      _buildQuickActionsSection(context, homeProvider, themeManager),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeProvider homeProvider) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LocationSelectionPage()));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔽 Location label with dropdown arrow
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            AppStrings.homeLocationLabel,
                            style: TextStyle(fontSize: 13, color: AppColors.textGrayLight),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.bluePrimary),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // 📍 Location icon + selected location value
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppSvgIcon(assetPath: 'assets/images/location.svg', width: 24, height: 24),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationProvider.selectedLocation,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Notification icon with unread badge
              Consumer<NotificationsProvider>(
                builder: (context, notifications, _) {
                  final unread = notifications.unreadCount;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderGrayLight,
                              width: 1,
                            ),
                            color: AppColors.backgroundWhite,
                          ),
                          child: Center(
                            child: AppSvgIcon(
                              assetPath: 'assets/images/notification.svg',
                              width: 44,
                              height: 44,
                            ),
                          ),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.backgroundWhite,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBarWithToggle(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: themeManager.searchBarHeight,
              child: SearchBarWidget(
                hintText: AppStrings.homeSearchHint,
                onTap: () => homeProvider.onSearchTap(context),
                onFilterTap: () => homeProvider.onFilterTap(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: homeProvider.showAllSections,
            onChanged: (_) => homeProvider.toggleSectionsView(),
            activeTrackColor: AppColors.bluePrimary,
            activeThumbColor: AppColors.backgroundWhite,
            inactiveThumbColor: AppColors.backgroundWhite,
            inactiveTrackColor: AppColors.notificationToggleInactive,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyStatsSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.propertyStats == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: PropertyStatsCardWidget(
                label: 'Total Properties',
                value: homeProvider.propertyStats!.totalProperties.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PropertyStatsCardWidget(
                label: 'Pending Payments',
                value: homeProvider.propertyStats!.pendingPayments,
                isPayment: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPropertiesSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.propertyStats?.featuredProperty == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Properties', style: themeManager.myPropertiesTitleStyle),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to all properties
                  },
                  child: Text('View All', style: themeManager.viewAllStyle),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FeaturedPropertyCardWidget(
            property: homeProvider.propertyStats!.featuredProperty!,
            useGradientStyle: !homeProvider.showAllSections,
            onTap: () {
              // TODO: Navigate to property details
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPropertyTypesSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.propertyStats == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final stats = homeProvider.propertyStats!.propertyTypeStats;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: PropertyTypeCardWidget(
                  iconPath: 'assets/images/home_residential.svg',
                  count: stats.residential,
                  label: 'Residential',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PropertyTypeCardWidget(
                  iconPath: 'assets/images/home_commercial.svg',
                  count: stats.commercial,
                  label: 'Commercial',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PropertyTypeCardWidget(
                  iconPath: 'assets/images/home_lands.svg',
                  count: stats.lands,
                  label: 'Lands',
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Quick Actions', style: themeManager.quickActionsTitleStyle),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: (MediaQuery.of(context).size.width - 44) / (2 * 126),
              ),
              itemCount: homeProvider.quickActions.length,
              itemBuilder: (context, index) {
                final action = homeProvider.quickActions[index];
                return QuickActionCardWidget(
                  action: action,
                  onTap: () {
                    // TODO: Handle quick action tap
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Prominent upcoming-visit card at the top of Home. Hidden when the buyer
  /// has no upcoming site visit.
  Widget _buildOffersSection(BuildContext context) {
    final offers = context.watch<OffersProvider>();
    if (offers.isLoading && offers.offers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (offers.offers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeaderWidget(title: AppStrings.homeYourOffers),
          ...offers.offers.map(
            (offer) => BuyerOfferCard(
              offer: offer,
              onTap: () => openOfferDetails(context, offer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMeetingSection(BuildContext context) {
    final visits = context.watch<VisitsProvider>();
    final next = visits.nextUpcoming;
    if (next == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: UpcomingMeetingCard(
        visit: next,
        onTap: () => openMeetingDetails(context, next),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.featuredProperties.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: ClipRect(
        child: Column(
          children: [
            const SizedBox(height: 12),
            SectionHeaderWidget(
              title: AppStrings.homeFeatured,
              actionText: AppStrings.homeSeeAll,
              onActionTap: () => homeProvider.onSeeAllFeatured(context),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              height: 384,
              child: ListView.separated(
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: homeProvider.featuredProperties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final property = homeProvider.featuredProperties[index];
                  return PropertyCardWidget(
                    property: property,
                    onTap: () => homeProvider.onPropertyTap(context, property),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none, // 🔹 VERY IMPORTANT
        children: [
          /// 🔹 True top shadow (no line, no gradient)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 1, // 🔹 invisible anchor
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 28,
                      spreadRadius: 6,
                      offset: const Offset(0, -12), // 🔹 shadow goes UP
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔹 Actual content
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                SectionHeaderWidget(
                  title: AppStrings.homeCategories,
                  actionText: AppStrings.homeSeeAll,
                  onActionTap: () => homeProvider.onSeeAllCategories(context),
                  padding: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 12.0),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: homeProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = homeProvider.categories[index];
                      return CategoryItemWidget(
                        category: category,
                        onTap: () => homeProvider.onCategoryTap(category, context),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.recommendedProperties.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 8),
          SectionHeaderWidget(
            title: AppStrings.homeRecommended,
            actionText: AppStrings.homeSeeAll,
            onActionTap: () => homeProvider.onSeeAllRecommended(context),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 166,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: homeProvider.recommendedProperties.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final property = homeProvider.recommendedProperties[index];
                return PropertyCardOverlayWidget(
                  property: property,
                  onTap: () => homeProvider.onPropertyTap(context, property),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.nearbyProperties.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 8),
          SectionHeaderWidget(
            title: AppStrings.homeNearby,
            actionText: AppStrings.homeSeeAll,
            onActionTap: () => homeProvider.onSeeAllNearby(context),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 190, // enough for 2 cards + divider
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,

              itemCount: (homeProvider.nearbyProperties.length / 2).ceil(),
              itemBuilder: (context, columnIndex) {
                final firstIndex = columnIndex * 2;
                final secondIndex = firstIndex + 1;

                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 Card 1
                      if (firstIndex < homeProvider.nearbyProperties.length)
                        PropertyHorizontalCardWidget(
                          property: homeProvider.nearbyProperties[firstIndex],
                          onTap: () => homeProvider.onPropertyTap(context, homeProvider.nearbyProperties[firstIndex]),
                        ),

                      /// spacing
                      const SizedBox(height: 12),
                      Container(height: 1, width: double.infinity, color: AppColors.borderGrayLight),

                      /// 🔹 Card 2 (if exists)
                      if (secondIndex < homeProvider.nearbyProperties.length) const SizedBox(height: 12),

                      PropertyHorizontalCardWidget(
                        property: homeProvider.nearbyProperties[secondIndex],
                        onTap: () => homeProvider.onPropertyTap(context, homeProvider.nearbyProperties[secondIndex]),
                      ),

                      /// 🔹 Line AFTER the set (ALWAYS)
                      const SizedBox(height: 12),
                      Container(height: 1, width: double.infinity, color: AppColors.borderGrayLight),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.popularProperties.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 8),
          SectionHeaderWidget(
            title: AppStrings.homePopularForYou,
            actionText: AppStrings.homeSeeAll,
            onActionTap: () => homeProvider.onSeeAllPopular(context),
          ),
          const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: homeProvider.popularProperties
                  .map(
                    (property) => Column(
                      children: [
                        const SizedBox(height: 8),
                        PropertyHorizontalCardWidget(
                          property: property,
                          onTap: () => homeProvider.onPropertyTap(context, property),
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
      ),
    );
  }

  Widget _buildTopLocationsSection(BuildContext context, HomeProvider homeProvider, ThemeManager themeManager) {
    if (homeProvider.topLocations.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 8),
          SectionHeaderWidget(
            title: AppStrings.homeTopLocations,
            actionText: AppStrings.homeSeeAll,
            onActionTap: () => homeProvider.onSeeAllLocations(context),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: homeProvider.topLocations.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final location = homeProvider.topLocations[index];
                final isSelected = homeProvider.selectedLocationId == location.id;
                return LocationChipWidget(
                  location: location,
                  isSelected: isSelected,
                  onTap: () => homeProvider.onLocationTap(location, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
