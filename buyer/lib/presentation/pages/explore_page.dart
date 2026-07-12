import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_string_constants.dart';
import '../providers/search_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/common/app_search_field.dart';
import '../widgets/explore/explore_property_card_widget.dart';
import '../widgets/search/search_property_card_list.dart';
import '../widgets/common/app_loader_widget.dart';
import '../widgets/common/app_svg_icon.dart';
import '../pages/filter_page.dart';
import '../widgets/common/property_category_tab_bar.dart';

class ExplorePage extends StatelessWidget {
  /// Optional `project_subtype` to pre-filter by (from a home category tap).
  final String? initialSubtype;
  final String? initialCategoryLabel;

  const ExplorePage({super.key, this.initialSubtype, this.initialCategoryLabel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<LocationProvider, SearchProvider>(
      create: (ctx) => SearchProvider(
        homeRepository: di.sl(),
        initialSubtype: initialSubtype,
        initialCategoryLabel: initialCategoryLabel,
        cityId: ctx.read<LocationProvider>().selectedCityId,
      ),
      // Re-filter Explore when the buyer's city resolves/changes.
      update: (ctx, location, search) {
        search!.setCity(location.selectedCityId);
        return search;
      },
      child: Consumer<SearchProvider>(
        builder: (context, provider, _) {
          final themeManager = ThemeManager();

          return Scaffold(
            backgroundColor: AppColors.backgroundWhite,
            body: SafeArea(
              child: Column(
                children: [
                  // Header with title and filter
                  _buildHeader(context, provider, themeManager),
                  const SizedBox(height: 12),
                  // Search bar
                  _buildSearchBar(context, provider, themeManager),
                  // Category tabs (shared with Documents screen)
                  PropertyCategoryTabBar(
                    tabs: SearchProvider.tabs,
                    selectedIndex: provider.selectedTabIndex,
                    onTabChanged: provider.onTabChanged,
                    themeManager: themeManager,
                  ),
                  const SizedBox(height: 16),
                  // Property count
                  _buildPropertyCount(provider, themeManager, context),
                  const SizedBox(height: 16),

                  // Property list
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: AppLoaderWidget())
                        : provider.properties.isEmpty
                        ? RefreshIndicator(
                            onRefresh: provider.fetchProperties,
                            color: AppColors.bluePrimary,
                            child: _buildEmptyState(themeManager),
                          )
                        : _buildPropertyList(context, provider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SearchProvider provider, ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppStrings.properties, style: themeManager.explorePageTitleStyle),
          GestureDetector(
            onTap: () => _onFilterTap(context, provider),
            child: AppSvgIcon(
              assetPath: 'assets/images/filter.svg',
              width: 24,
              height: 24,
              color: AppColors.bluePrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchProvider provider, ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppSearchField(
        controller: provider.searchController,
        hintText: AppStrings.homeSearchHint,
        onChanged: provider.performSearch,
        height: 48,
        borderRadius: 12,
      ),
    );
  }

  Widget _buildPropertyCount(SearchProvider provider, ThemeManager themeManager, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${provider.properties.length} ',
                  style: themeManager.titleMediumStyle.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: provider.properties.length == 1 ? 'property' : 'properties',
                  style: themeManager.bodyMediumStyle.copyWith(color: AppColors.textGray70),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _iconToggle(
                asset: provider.layout == SearchLayout.grid
                    ? "assets/images/grid_selected.svg"
                    : "assets/images/grid_unselected.svg",
                onTap: () => provider.setLayout(SearchLayout.grid),
              ),
              _iconToggle(
                asset: provider.layout == SearchLayout.list
                    ? "assets/images/list_selected.svg"
                    : "assets/images/list_unselected.svg",
                onTap: () => provider.setLayout(SearchLayout.list),
              ),
              _iconToggle(
                asset: "assets/images/sort_list.svg",
                onTap: () => _showSortBottomSheet(context, provider, themeManager),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconToggle({required String asset, required VoidCallback onTap}) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
      icon: SvgPicture.asset(asset, width: 22, height: 22),
      onPressed: onTap,
    );
  }

  Widget _buildPropertyList(BuildContext context, SearchProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.fetchProperties,
      color: AppColors.bluePrimary,
      child: provider.layout == SearchLayout.grid
          ? GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 236,
              ),
              itemCount: provider.properties.length,
              itemBuilder: (context, index) =>
                  ExplorePropertyCardWidget(property: provider.properties[index]),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: provider.properties.length,
              itemBuilder: (context, index) =>
                  SearchPropertyCardList(property: provider.properties[index]),
            ),
    );
  }

  Widget _buildEmptyState(ThemeManager themeManager) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: AppColors.textGrayLight),
                  const SizedBox(height: 16),
                  Text(AppStrings.noPropertiesFound, style: themeManager.emptyStateTextStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFilterTap(BuildContext context, SearchProvider searchProvider) {
    final filterProvider = di.sl<FilterProvider>();
    filterProvider.onFiltersApplied = (filterModel) {
      searchProvider.applyFilters(filterModel);
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(value: filterProvider, child: const FilterPage()),
    );
  }

  void _showSortBottomSheet(BuildContext context, SearchProvider provider, ThemeManager themeManager) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderGrayLight, borderRadius: BorderRadius.circular(2)),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                AppStrings.sort,
                style: themeManager.titleMediumStyle.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(color: AppColors.borderGrayLight, height: 1),
            // Sort options
            ...SearchSortOption.values.map((option) {
              final isSelected = provider.selectedSortOption == option;
              return ListTile(
                title: Text(
                  _getSortOptionLabel(option),
                  style: themeManager.bodyMediumStyle.copyWith(
                    color: AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check, color: AppColors.bluePrimary, size: 24) : null,
                onTap: () {
                  provider.setSortOption(option);
                  Navigator.pop(context);
                },
              );
            }),
            // Clear sort option
            ListTile(
              title: Text(
                AppStrings.clearSort,
                style: themeManager.bodyMediumStyle.copyWith(color: AppColors.textGray),
              ),
              onTap: () {
                provider.setSortOption(null);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  String _getSortOptionLabel(SearchSortOption option) {
    switch (option) {
      case SearchSortOption.recentlyAdded:
        return AppStrings.recentlyAdded;
      case SearchSortOption.orderByAZ:
        return AppStrings.orderByAZ;
      case SearchSortOption.orderByZA:
        return AppStrings.orderByZA;
      case SearchSortOption.priceLowToHigh:
        return AppStrings.priceLowToHigh;
      case SearchSortOption.priceHighToLow:
        return AppStrings.priceHighToLow;
    }
  }
}
