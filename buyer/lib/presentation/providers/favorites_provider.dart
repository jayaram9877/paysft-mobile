import 'package:flutter/material.dart';
import '../../domain/entities/property_model.dart';
import '../../data/datasources/home_local_data_source.dart';
import '../../core/di/injection_container.dart' as di;
import '../widgets/favorites/remove_favorites_bottom_sheet.dart';

class FavoritesProvider extends ChangeNotifier {
  final HomeLocalDataSource dataSource;

  FavoritesProvider({required this.dataSource}) {
    fetchFavorites();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PropertyModel> _favorites = [];
  List<PropertyModel> get favorites => _favorites;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  List<PropertyModel> get filteredFavorites {
    Iterable<PropertyModel> result = _favorites;

    if (_selectedCategory != 'All') {
      // Placeholder for category-based filtering if categories are added in the future
      result = result;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((p) {
        final titleMatch = p.title.toLowerCase().contains(query);
        final locationMatch = p.location.toLowerCase().contains(query);
        return titleMatch || locationMatch;
      });
    }

    return result.toList();
  }

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get favorites from data source
      _favorites = List.from(await dataSource.getFavorites());
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void performSearch(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  void toggleFavorite(PropertyModel property) {
    if (_favorites.any((p) => p.id == property.id)) {
      _favorites.removeWhere((p) => p.id == property.id);
    } else {
      _favorites.add(property);
    }
    notifyListeners();
  }

  bool isFavorite(String propertyId) {
    return _favorites.any((p) => p.id == propertyId);
  }
}
