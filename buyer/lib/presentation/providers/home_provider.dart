import 'package:buyer/presentation/pages/categories_page.dart';
import 'package:buyer/presentation/pages/featured_properties_page.dart';
import 'package:buyer/presentation/pages/nearby_properties_page.dart';
import 'package:buyer/presentation/pages/popular_properties_page.dart';
import 'package:buyer/presentation/pages/recommended_properties_page.dart';
import 'package:buyer/presentation/pages/top_locations_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/property_model.dart';
import '../../domain/entities/category_model.dart';
import '../../domain/entities/location_model.dart';
import '../../domain/entities/property_stats_model.dart';
import '../pages/filter_page.dart';
import '../pages/main_tab_page.dart';
import '../pages/property_details_page.dart';
import '../pages/land_details_page.dart';
import '../pages/commercial_details_page.dart';
import '../pages/search_page.dart';
import './filter_provider.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/utils/property_utils.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository homeRepository;

  HomeProvider({required this.homeRepository}) {
    _initializePropertyStats();
    _initializeQuickActions();
    // Initial data load is triggered by HomePage once it is shown, so the auth
    // token from login is available for the /buyer/* calls.
  }

  bool _hasFetched = false;

  /// Loads home data the first time the Home screen appears. Safe to call on
  /// every build; the network fetch only runs once unless [force] is set.
  Future<void> ensureLoaded({bool force = false, String? cityId}) async {
    if (cityId != _cityId) {
      _cityId = cityId;
      _hasFetched = false; // City changed — force a refetch below.
    }
    if (_hasFetched && !force) return;
    _hasFetched = true;
    await fetchData();
  }

  /// Sets the city filter and reloads the catalog if it actually changed.
  Future<void> setCity(String? cityId) async {
    if (cityId == _cityId) return;
    _cityId = cityId;
    _hasFetched = true;
    await fetchData();
  }

  void _initializePropertyStats() {
    _propertyStats = const PropertyStatsModel(
      totalProperties: 3,
      pendingPayments: '₹12,45,000',
      propertyTypeStats: PropertyTypeStatsModel(residential: 2, commercial: 1, lands: 1),
      featuredProperty: FeaturedPropertyModel(
        id: '1',
        name: 'Prestige Lakeside Habitat',
        location: 'Devanahalli, Bangalore',
        nextPayment: '₹12,45,000',
        dueDate: 'Jan 15, 2025',
      ),
    );
  }

  void _initializeQuickActions() {
    _quickActions = const [
      QuickActionModel(id: '1', name: 'Pay Bills', tag: 'Utilities', iconPath: 'assets/images/profile_utilities.svg'),
      QuickActionModel(id: '2', name: 'Documents', tag: 'All Files', iconPath: 'assets/images/profile_documents.svg'),
      QuickActionModel(
        id: '3',
        name: 'Transactions',
        tag: 'History',
        iconPath: 'assets/images/profile_transactions.svg',
      ),
      QuickActionModel(id: '4', name: 'Message', tag: 'Support', iconPath: 'assets/images/chat_active.svg'),
    ];
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _showAllSections = true;

  bool get showAllSections => _showAllSections;

  /// Backend city id used to filter the catalog. Null = whole catalog.
  String? _cityId;

  String? get cityId => _cityId;

  List<PropertyModel> _featuredProperties = [];

  List<PropertyModel> get featuredProperties => _featuredProperties;

  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  List<PropertyModel> _recommendedProperties = [];

  List<PropertyModel> get recommendedProperties => _recommendedProperties;

  List<PropertyModel> _nearbyProperties = [];

  List<PropertyModel> get nearbyProperties => _nearbyProperties;

  List<PropertyModel> _popularProperties = [];

  List<PropertyModel> get popularProperties => _popularProperties;

  List<LocationModel> _topLocations = [];

  List<LocationModel> get topLocations => _topLocations;

  String? _selectedLocationId;

  String? get selectedLocationId => _selectedLocationId;

  PropertyStatsModel? _propertyStats;

  PropertyStatsModel? get propertyStats => _propertyStats;

  List<QuickActionModel> _quickActions = [];

  List<QuickActionModel> get quickActions => _quickActions;

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    // Load every section independently and in parallel, so a single failing
    // call (e.g. /buyer/cities) can't blank the rest of the home screen.
    final featuredF = _guard(() => homeRepository.getFeaturedProperties(cityId: _cityId));
    final recommendedF = _guard(() => homeRepository.getRecommendedProperties(cityId: _cityId));
    final nearbyF = _guard(() => homeRepository.getNearbyProperties(cityId: _cityId));
    final popularF = _guard(() => homeRepository.getPopularProperties(cityId: _cityId));
    final categoriesF = _guard(homeRepository.getCategories);
    final topLocationsF = _guard(homeRepository.getTopLocations);

    _featuredProperties = await featuredF;
    _recommendedProperties = await recommendedF;
    _nearbyProperties = await nearbyF;
    _popularProperties = await popularF;
    _categories = await categoriesF;
    _topLocations = await topLocationsF;

    // Default select "Banjara Hills" if present, otherwise the first location.
    if (_topLocations.isNotEmpty) {
      final match = _topLocations.where(
        (loc) => loc.name.toLowerCase().contains('banjara'),
      );
      _selectedLocationId =
          match.isNotEmpty ? match.first.id : _topLocations.first.id;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Runs a repository call, returning an empty list on any error so one
  /// failing section never takes down the whole screen.
  Future<List<T>> _guard<T>(Future<List<T>> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return <T>[];
    }
  }

  void onSearchTap(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchPage()));
  }

  void onFilterTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      sheetAnimationStyle: AnimationStyle(curve: Curves.easeInOut, duration: const Duration(milliseconds: 500)),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(value: di.sl<FilterProvider>(), child: const FilterPage()),
    );
  }

  void onSeeAllFeatured(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FeaturedPropertiesPage(properties: _featuredProperties)));
  }

  void onSeeAllCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesPage(
          categories: _categories,
          onCategoryTap: (category) {
            onCategoryTap(category, context);
          },
        ),
      ),
    );
  }

  void onSeeAllRecommended(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecommendedPropertiesPage(properties: _recommendedProperties)),
    );
  }

  void onSeeAllNearby(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NearbyPropertiesPage(properties: _nearbyProperties)));
  }

  void onSeeAllPopular(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PopularPropertiesPage(properties: _popularProperties)));
  }

  void onSeeAllLocations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopLocationsPage(
          locations: _topLocations,
          onLocationTap: (location) {
            onLocationTap(location, context);
          },
        ),
      ),
    );
  }

  void onPropertyTap(BuildContext context, PropertyModel property) {
    // Single property details page for all types (mirrors the broker app).
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PropertyDetailsPage(property: property)),
    );
  }

  void onCategoryTap(dynamic category, BuildContext context) {
    // Home categories carry a backend project_subtype in their id
    // (e.g. 'apartment'), so Explore can filter server-side by category.
    final String? subtype = category is CategoryModel ? category.id : null;
    final String? label = category is CategoryModel ? category.name : null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainTabPage(
          initialIndex: 1,
          initialCategorySubtype: subtype,
          initialCategoryLabel: label,
        ),
      ),
      ModalRoute.withName("/"),
    );
  }

  void onLocationTap(dynamic location, BuildContext context) {
    if (location is LocationModel) {
      _selectedLocationId = location.id;
      Navigator.of(
        context,
      ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => MainTabPage(initialIndex: 1)), ModalRoute.withName("/"));
      notifyListeners();
    }
  }

  void toggleSectionsView() {
    _showAllSections = !_showAllSections;
    notifyListeners();
  }
}
