import '../../domain/entities/category_model.dart';
import '../../domain/entities/location_model.dart';
import '../../domain/entities/property_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/remote/home_remote_data_source.dart';

/// Home data backed by the PaySFT demo REST backend.
///
/// The backend exposes a single `/buyer/projects` catalog with filters + paging
/// (there is no server-side notion of "featured / recommended / nearby /
/// popular"), so each home section maps to a sensible, distinct query below.
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PropertyModel>> getFeaturedProperties({String? cityId}) async {
    // Featured showcases a random selection from the whole catalog so it
    // varies between visits (the backend has no "featured" flag).
    final all = await remoteDataSource.getProjects(limit: 30, cityId: cityId);
    all.shuffle();
    return all.take(8).toList();
  }

  @override
  Future<List<PropertyModel>> getRecommendedProperties({String? cityId}) {
    return remoteDataSource.getProjects(
      projectType: 'residential',
      limit: 10,
      cityId: cityId,
    );
  }

  @override
  Future<List<PropertyModel>> getNearbyProperties({String? cityId}) {
    return remoteDataSource.getProjects(
      constructionStatus: 'ready_to_move',
      limit: 10,
      cityId: cityId,
    );
  }

  @override
  Future<List<PropertyModel>> getPopularProperties({String? cityId}) {
    return remoteDataSource.getProjects(
      constructionStatus: 'under_construction',
      limit: 10,
      cityId: cityId,
    );
  }

  @override
  Future<List<LocationModel>> getTopLocations() {
    return remoteDataSource.getCities(limit: 10);
  }

  @override
  Future<LocationModel?> findCity(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    // Search by the city token only (e.g. "Hyderabad" from "Hyderabad, Telangana").
    final cityToken = trimmed.split(',').first.trim();
    final matches = await remoteDataSource.getCities(search: cityToken, limit: 10);
    if (matches.isEmpty) return null;
    final lower = cityToken.toLowerCase();
    // Prefer an exact (case-insensitive) city-name match, else the first result.
    for (final m in matches) {
      if (m.name.toLowerCase() == lower) return m;
    }
    return matches.first;
  }

  @override
  Future<List<PropertyModel>> searchProjects({
    String? query,
    String? projectType,
    String? projectSubtype,
    String? cityId,
    num? priceMax,
    int limit = 30,
  }) {
    return remoteDataSource.getProjects(
      q: query,
      projectType: projectType,
      projectSubtype: projectSubtype,
      cityId: cityId,
      priceMax: priceMax,
      limit: limit,
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    // Categories are the backend `project_subtype` enum values (used as filters
    // for /buyer/projects). Ids map to the enum, names are display labels.
    return const [
      CategoryModel(id: 'apartment', name: 'Apartment'),
      CategoryModel(id: 'villa', name: 'Villa'),
      CategoryModel(id: 'gated_plots', name: 'Gated Plots'),
      CategoryModel(id: 'independent_house', name: 'Independent House'),
      CategoryModel(id: 'office', name: 'Office'),
      CategoryModel(id: 'retail_shop', name: 'Retail Shop'),
    ];
  }
}
