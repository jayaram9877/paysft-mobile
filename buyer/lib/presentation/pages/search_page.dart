import 'package:buyer/presentation/widgets/home/search_widget_as_header_widger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/di/injection_container.dart' as di;
import '../providers/search_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/explore/explore_property_card_widget.dart';
import '../widgets/search/search_property_card_list.dart';
import '../widgets/search/search_property_card_simple.dart';
import '../widgets/common/filter_chips_widget.dart';
import 'filter_page.dart';
import 'package:buyer/presentation/widgets/common/app_loader_widget.dart';
import '../widgets/common/app_svg_icon.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _didRequestKeyboard = false;
  bool _didAttachFocusListener = false;
  SearchProvider? _createdProvider;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Request focus after the route transition completes (more reliable keyboard behavior).
    if (_didRequestKeyboard) return;
    _didRequestKeyboard = true;

    final route = ModalRoute.of(context);
    final animation = route?.animation;
    if (animation != null) {
      // If the route transition is already completed, request keyboard immediately.
      if (animation.status == AnimationStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _requestKeyboard());
        return;
      }

      void listener(AnimationStatus status) {
        if (!mounted) return;
        if (status == AnimationStatus.completed) {
          animation.removeStatusListener(listener);
          _requestKeyboard();
        }
      }

      animation.addStatusListener(listener);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestKeyboard());
    }
  }

  void _requestKeyboard() {
    if (!mounted) return;

    // Delay until AppBar + TextField are fully laid out
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 150));

      if (!mounted) return;

      FocusScope.of(context).requestFocus(_searchFocusNode);

      await Future.delayed(const Duration(milliseconds: 50));

      if (_searchFocusNode.hasFocus) {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) {
        _createdProvider = SearchProvider(
          homeRepository: di.sl(),
          cityId: ctx.read<LocationProvider>().selectedCityId,
        );
        return _createdProvider!;
      },
      child: Consumer<SearchProvider>(
        builder: (context, provider, _) {
          // Attach focus listener once, after provider is available.
          // Only clear empty-submit flag when field gains focus (not during typing).
          // This ensures that if user deletes all text and presses Search, it shows No Results.
          if (!_didAttachFocusListener) {
            _didAttachFocusListener = true;
            bool _wasFocused = false;
            _searchFocusNode.addListener(() {
              final isFocused = _searchFocusNode.hasFocus;
              // Only call onSearchFieldFocused when transitioning from unfocused to focused
              // This prevents clearing the flag during typing/deleting
              if (isFocused && !_wasFocused) {
                provider.onSearchFieldFocused();
              }
              _wasFocused = isFocused;
            });
          }

          final themeManager = ThemeManager();
          final bool shouldShowInitialState = provider.shouldShowInitialState;
          final bool isSearchInProgress = provider.isSearchInProgress;
          final bool hasActiveSearch = provider.hasActiveSearch;

          return Scaffold(
            backgroundColor: AppColors.backgroundWhite,

            /// Custom Search AppBar
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(76),
              child: AppBarSearchHeaderWidget(
                controller: provider.searchController,
                onBack: () => _handleBackNavigation(context, provider),
                onFilterTap: () => _onFilterTap(context, provider),
                onChanged: provider.performSearch,
                onSubmitted: provider.submitSearch,
                focusNode: _searchFocusNode,
              ),
            ),

            body: Column(
              children: [
                /// Top Category Filters - Show only when there are search results
                if (hasActiveSearch)
                  FilterChipsWidget(
                    selectedCategory: provider.selectedCategory,
                    onCategorySelected: (category) => provider.setCategory(category),
                  ),

                /// Results header - Only when user has active search results
                if (hasActiveSearch)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 8),
                    child: _buildResultsHeader(provider, themeManager, context),
                  ),

                /// Main content
                Expanded(
                  child: (shouldShowInitialState && !provider.showNoResultsForEmptySubmit)
                      ? _buildInitialState(context, provider, themeManager)
                      : isSearchInProgress
                      ? _buildLoadingState(themeManager)
                      : provider.shouldShowNoResults
                      ? _buildNoResultsState(themeManager)
                      : _buildPropertyList(context, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Handle back navigation - clear search state and return to initial state
  void _handleBackNavigation(BuildContext context, SearchProvider provider) {
    provider.clearSearchState();
    Navigator.of(context).pop();
  }

  /// Initial/Empty State - Shows Recent History and Recent Results
  Widget _buildInitialState(BuildContext context, SearchProvider provider, ThemeManager themeManager) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent History Section
          if (provider.recentSearchHistory.isNotEmpty) ...[
            Text(
              AppStrings.recent,
              style: themeManager.titleMediumStyle.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...provider.recentSearchHistory.map(
              (query) => _buildRecentHistoryItem(context, query, provider, themeManager),
            ),
            const SizedBox(height: 24),
          ],

          // Recent Results Section
          if (provider.recentResults.isNotEmpty) ...[
            Text(
              AppStrings.result,
              style: themeManager.titleMediumStyle.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...provider.recentResults.map((property) => SearchPropertyCardSimple(property: property)),
          ],
        ],
      ),
    );
  }

  /// Build recent history item
  Widget _buildRecentHistoryItem(
    BuildContext context,
    String query,
    SearchProvider provider,
    ThemeManager themeManager,
  ) {
    return GestureDetector(
      onTap: () => provider.selectRecentSearch(query),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderGrayLight, width: 1)),
        ),
        child: Row(
          children: [
            Icon(Icons.history, size: 20, color: AppColors.textGray),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    query,
                    style: themeManager.bodyMediumStyle.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading State - Center-aligned loading indicator
  Widget _buildLoadingState(ThemeManager themeManager) {
    return const Center(child: AppLoaderWidget());
  }

  /// No Results State - Empty state with illustration
  Widget _buildNoResultsState(ThemeManager themeManager) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/images/search_no_results.svg', width: 157, height: 145),
                  const SizedBox(height: 24),
                  Text(AppStrings.searchNotFound, style: themeManager.titleStyle.copyWith(color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      AppStrings.enableLocationServices,
                      textAlign: TextAlign.center,
                      style: themeManager.captionStyle.copyWith(color: AppColors.gray400),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Results Header
  Widget _buildResultsHeader(SearchProvider provider, ThemeManager themeManager, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${provider.properties.length} found',
            style: themeManager.titleMediumStyle.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              IconButton(
                icon: provider.layout == SearchLayout.grid
                    ? SvgPicture.asset("assets/images/grid_selected.svg", width: 22, height: 22)
                    : SvgPicture.asset("assets/images/grid_unselected.svg", width: 22, height: 22),
                onPressed: () => provider.setLayout(SearchLayout.grid),
              ),
              IconButton(
                icon: provider.layout == SearchLayout.list
                    ? SvgPicture.asset("assets/images/list_selected.svg", width: 22, height: 22)
                    : SvgPicture.asset("assets/images/list_unselected.svg", width: 22, height: 22),
                onPressed: () => provider.setLayout(SearchLayout.list),
              ),
              IconButton(
                icon: SvgPicture.asset("assets/images/sort_list.svg", width: 22, height: 22),
                onPressed: () => _showSortBottomSheet(context, provider, themeManager),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Property List - Grid or List view
  Widget _buildPropertyList(BuildContext context, SearchProvider provider) {
    if (provider.layout == SearchLayout.grid) {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
        itemCount: provider.properties.length,
        itemBuilder: (context, index) {
          final property = provider.properties[index];
          return ExplorePropertyCardWidget(property: property);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16),
        itemCount: provider.properties.length,
        itemBuilder: (context, index) {
          final property = provider.properties[index];
          return SearchPropertyCardList(property: property);
        },
      );
    }
  }

  void _onFilterTap(BuildContext context, SearchProvider searchProvider) {
    final filterProvider = di.sl<FilterProvider>();
    // Set callback to apply filters to SearchProvider
    filterProvider.onFiltersApplied = (filterModel) {
      searchProvider.applyFilters(filterModel);
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: AnimationStyle(curve: Curves.easeInOut, duration: const Duration(milliseconds: 500)),
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
