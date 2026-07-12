import '../entities/category_model.dart';
import '../entities/location_model.dart';
import '../entities/property_model.dart';

abstract class HomeRepository {
  // Home sections accept an optional [cityId] (backend /buyer/cities id) so the
  // feed can be filtered to the buyer's selected city.
  Future<List<PropertyModel>> getFeaturedProperties({String? cityId});
  Future<List<CategoryModel>> getCategories();
  Future<List<PropertyModel>> getRecommendedProperties({String? cityId});
  Future<List<PropertyModel>> getNearbyProperties({String? cityId});
  Future<List<PropertyModel>> getPopularProperties({String? cityId});
  Future<List<LocationModel>> getTopLocations();

  /// Resolves a free-text city name (e.g. from GPS / OSM) to a backend city.
  /// Returns null when there's no matching `/buyer/cities` entry.
  Future<LocationModel?> findCity(String name);

  /// Server-side catalog search/filter (GET /buyer/projects). All params are
  /// optional: [projectType] is 'residential' | 'commercial' | 'land';
  /// [projectSubtype] is a subtype enum (e.g. 'apartment', 'villa').
  Future<List<PropertyModel>> searchProjects({
    String? query,
    String? projectType,
    String? projectSubtype,
    String? cityId,
    int limit,
  });
}
