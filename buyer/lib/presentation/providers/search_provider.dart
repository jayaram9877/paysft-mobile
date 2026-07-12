import 'package:flutter/material.dart';
import '../../domain/entities/property_model.dart';
import '../../domain/entities/filter_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../../core/constants/app_string_constants.dart';

enum SearchLayout { grid, list }

enum SearchSortOption { recentlyAdded, orderByAZ, orderByZA, priceLowToHigh, priceHighToLow }

class SearchProvider extends ChangeNotifier {
  final HomeRepository homeRepository;
  final TextEditingController searchController = TextEditingController();

  SearchProvider({
    required this.homeRepository,
    String? initialSubtype,
    String? initialCategoryLabel,
    String? cityId,
  }) {
    _cityId = cityId;
    if (initialSubtype != null && initialSubtype.isNotEmpty) {
      _projectSubtype = initialSubtype;
      _selectedCategory = initialCategoryLabel ?? _selectedCategory;
    }
    fetchProperties();
    searchController.addListener(() {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PropertyModel> _properties = [];
  List<PropertyModel> _allProperties = [];
  List<PropertyModel> get properties => _properties;

  SearchLayout _layout = SearchLayout.grid;
  SearchLayout get layout => _layout;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // Active server-side filters sent to GET /buyer/projects.
  String? _projectType; // 'residential' | 'commercial' | 'land'
  String? _projectSubtype; // e.g. 'apartment', 'villa' (from home categories)
  String? _cityId; // backend /buyer/cities id for the buyer's selected city

  SearchSortOption? _selectedSortOption;
  SearchSortOption? get selectedSortOption => _selectedSortOption;

  static const List<String> tabs = ['All', 'Residential', 'Commercial', 'Lands'];
  List<String> get categories => tabs;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Recent search history (latest 3 items)
  List<String> _recentSearchHistory = [];
  List<String> get recentSearchHistory => _recentSearchHistory.take(3).toList();

  // Recent search results (latest 3 properties)
  List<PropertyModel> _recentResults = [];
  List<PropertyModel> get recentResults => _recentResults.take(3).toList();

  // Track if search is in progress
  bool _isSearchInProgress = false;
  bool get isSearchInProgress => _isSearchInProgress;

  // If user presses keyboard "Search" with an empty query, show "No results" state.
  bool _showNoResultsForEmptySubmit = false;
  bool get showNoResultsForEmptySubmit => _showNoResultsForEmptySubmit;

  // Track if we have active search results
  bool get hasActiveSearch => _searchQuery.isNotEmpty && _properties.isNotEmpty && !_isLoading;

  // Track if we should show initial state
  // Show initial state when search query is empty (even during loading)
  bool get shouldShowInitialState => _searchQuery.isEmpty;

  bool get shouldShowNoResults =>
      _showNoResultsForEmptySubmit ||
      (_searchQuery.isNotEmpty && _properties.isEmpty && !_isLoading && !_isSearchInProgress);

  /// When the user focuses the search field with an empty query, we should show
  /// the initial hints (Recent + Results). This clears the "empty submit" override
  /// without removing recent history/results.
  ///
  /// NOTE: We only clear the flag when the user explicitly focuses the field
  /// (e.g., taps on it), NOT when they're typing/deleting. This ensures that
  /// if they delete all text and press Search, it still shows No Results.
  void onSearchFieldFocused() {
    // If user explicitly submitted empty search,
    // DO NOT revive hints automatically
    if (_showNoResultsForEmptySubmit) return;

    if (_searchQuery.isNotEmpty) return;

    notifyListeners();
  }

  /// Updates the city filter (from the buyer's selected location) and reloads
  /// if it changed. The fetch is deferred to a microtask so this is safe to call
  /// from a ProxyProvider `update` during the build phase.
  void setCity(String? cityId) {
    if (cityId == _cityId) return;
    _cityId = cityId;
    Future.microtask(fetchProperties);
  }

  Future<void> fetchProperties() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Server-side catalog query honoring the active category/type filter.
      final results = await homeRepository.searchProjects(
        projectType: _projectType,
        projectSubtype: _projectSubtype,
        cityId: _cityId,
        limit: 50,
      );
      _allProperties = results;
      _properties = results;
      // Re-apply any active text query on top of the fetched set.
      _applyFilters();
    } catch (e) {
      _allProperties = [];
      _properties = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _typeForTabIndex(int index) {
    switch (index) {
      case 1:
        return 'residential';
      case 2:
        return 'commercial';
      case 3:
        return 'land';
      default:
        return null; // 'All'
    }
  }

  /// Applies a home-screen category (a `project_subtype`) as a server-side
  /// filter and reloads. Resets the type tab to "All".
  void applyHomeCategory({required String subtype, String? label}) {
    _projectSubtype = subtype;
    _projectType = null;
    _selectedCategory = label ?? 'All';
    _selectedTabIndex = 0;
    _searchQuery = '';
    searchController.clear();
    fetchProperties();
    notifyListeners();
  }

  void setLayout(SearchLayout layout) {
    _layout = layout;
    notifyListeners();
  }

  void setSortOption(SearchSortOption? sortOption) {
    _selectedSortOption = sortOption;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    final index = tabs.indexOf(category);
    _selectedCategory = category;
    _selectedTabIndex = index < 0 ? 0 : index;
    _projectSubtype = null;
    _projectType = _typeForTabIndex(_selectedTabIndex);
    fetchProperties();
    notifyListeners();
  }

  void onTabChanged(int index) {
    _selectedTabIndex = index;
    _selectedCategory = tabs[index];
    _projectSubtype = null;
    _projectType = _typeForTabIndex(index);
    fetchProperties();
    notifyListeners();
  }

  void applyFilters(FilterModel filterModel) {
    _selectedCategory = filterModel.selectedCategory;
    _applyFilters();
    notifyListeners();
  }

  void performSearch(String query) {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      // When query becomes empty (user deleted all text), clear the empty-submit flag
      // so that if they press Search, it will set the flag and show No Results.
      // Don't call clearSearchState() here - we want to preserve the state until submit.
      _showNoResultsForEmptySubmit = false;
      _isSearchInProgress = false;
      _properties = _allProperties;
      notifyListeners();
      return;
    }

    // Any typing with non-empty text clears the "empty submit" no-results override.
    _showNoResultsForEmptySubmit = false;

    // Add to recent history if not already present
    if (!_recentSearchHistory.contains(_searchQuery)) {
      _recentSearchHistory.insert(0, _searchQuery);
      // Keep only latest 3
      if (_recentSearchHistory.length > 3) {
        _recentSearchHistory = _recentSearchHistory.take(3).toList();
      }
    } else {
      // Move to top if already exists
      _recentSearchHistory.remove(_searchQuery);
      _recentSearchHistory.insert(0, _searchQuery);
    }

    _isSearchInProgress = true;
    notifyListeners();

    // Perform search with debounce simulation
    Future.delayed(const Duration(milliseconds: 300), () {
      _applyFilters();
      _isSearchInProgress = false;

      // Update recent results with current search results
      if (_properties.isNotEmpty) {
        _recentResults = _properties.take(3).toList();
      }

      notifyListeners();
    });
  }

  void clearSearchState() {
    _searchQuery = '';
    _showNoResultsForEmptySubmit = false;
    _isSearchInProgress = false;
    searchController.clear();
    _properties = _allProperties;
    notifyListeners();
  }

  void cancelSearch() {
    _isSearchInProgress = false;
    notifyListeners();
  }

  /// Called when user presses keyboard "Search"
  void submitSearch(String query) {
    final submitted = query.trim();
    if (submitted.isEmpty) {
      _searchQuery = '';
      _isSearchInProgress = false;
      _showNoResultsForEmptySubmit = true;
      _properties = [];
      notifyListeners();
      return;
    }

    _showNoResultsForEmptySubmit = false;
    performSearch(submitted);
  }

  void addToRecentHistory(String query) {
    if (query.trim().isEmpty) return;

    if (!_recentSearchHistory.contains(query)) {
      _recentSearchHistory.insert(0, query);
      if (_recentSearchHistory.length > 3) {
        _recentSearchHistory = _recentSearchHistory.take(3).toList();
      }
      notifyListeners();
    }
  }

  void selectRecentSearch(String query) {
    searchController.text = query;
    performSearch(query);
  }

  void _applyFilters() {
    _properties = _allProperties.where((property) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final titleLower = property.title.toLowerCase();
        final locationLower = property.location.toLowerCase();
        final queryLower = _searchQuery.toLowerCase();
        if (!titleLower.contains(queryLower) && !locationLower.contains(queryLower)) {
          return false;
        }
      }
      // Filter by category if not "All"
      if (_selectedCategory != 'All' && _selectedCategory != AppStrings.categoryAll) {
        // Use propertyType field from PropertyModel for accurate filtering
        final propertyTypeLower = property.propertyType.toLowerCase();
        final categoryLower = _selectedCategory.toLowerCase();

        // Map category names to property types
        // Handle both 'Residential' and 'residential' formats
        if (categoryLower == 'residential') {
          if (propertyTypeLower != 'residential') {
            return false;
          }
        } else if (categoryLower == 'commercial') {
          if (propertyTypeLower != 'commercial') {
            return false;
          }
        } else if (categoryLower == 'lands' || categoryLower == 'land') {
          if (propertyTypeLower != 'land') {
            return false;
          }
        }
      }
      return true;
    }).toList();

    // Apply sorting if selected
    if (_selectedSortOption != null) {
      switch (_selectedSortOption!) {
        case SearchSortOption.recentlyAdded:
          // Sort by most recent (assuming properties are already in order)
          // In a real app, you'd sort by a date field
          break;
        case SearchSortOption.orderByAZ:
          _properties.sort((a, b) => a.title.compareTo(b.title));
          break;
        case SearchSortOption.orderByZA:
          _properties.sort((a, b) => b.title.compareTo(a.title));
          break;
        case SearchSortOption.priceLowToHigh:
          // Sort by price if available, otherwise by title
          _properties.sort((a, b) {
            // In a real app, you'd compare actual price values
            // For now, we'll use a placeholder
            return a.title.compareTo(b.title);
          });
          break;
        case SearchSortOption.priceHighToLow:
          // Sort by price if available, otherwise by title
          _properties.sort((a, b) {
            // In a real app, you'd compare actual price values
            // For now, we'll use a placeholder
            return b.title.compareTo(a.title);
          });
          break;
      }
    }
  }
}
