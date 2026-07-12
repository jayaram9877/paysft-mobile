import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../../domain/entities/location_model.dart';
import '../../../domain/entities/property_model.dart';

/// Talks to the PaySFT demo backend (REST) for buyer home content:
///   GET /buyer/projects  (catalog, with filters + pagination)
///   GET /buyer/cities    (locations)
///
/// Responses are mapped directly onto the domain entities the home UI already
/// consumes (PropertyModel / LocationModel).
abstract class HomeRemoteDataSource {
  Future<List<PropertyModel>> getProjects({
    String? q,
    String? projectType,
    String? projectSubtype,
    String? constructionStatus,
    String? cityId,
    num? priceMax,
    int limit,
    int offset,
  });

  Future<List<LocationModel>> getCities({String? search, int limit});

  Future<List<LocationModel>> getLocations({String? search, int limit});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  /// Fallback cover image for projects that have no `cover_image_url`.
  static const String _fallbackImage =
      'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800';

  @override
  Future<List<PropertyModel>> getProjects({
    String? q,
    String? projectType,
    String? projectSubtype,
    String? constructionStatus,
    String? cityId,
    num? priceMax,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        if (q != null && q.isNotEmpty) 'q': q,
        if (projectType != null) 'project_type': projectType,
        if (projectSubtype != null) 'project_subtype': projectSubtype,
        if (constructionStatus != null) 'construction_status': constructionStatus,
        if (cityId != null) 'city_id': cityId,
        if (priceMax != null) 'price_max': priceMax,
      };

      final response = await dio.get(
        ApiConstants.buyerProjects,
        queryParameters: query,
      );

      _ensureOk(response);

      final body = response.data;
      final items = body is Map<String, dynamic> ? body['items'] : body;
      if (items is! List) return const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(_mapProject)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load properties');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load properties');
    }
  }

  @override
  Future<List<LocationModel>> getCities({String? search, int limit = 10}) async {
    return _fetchLocations(ApiConstants.buyerCities, search: search, limit: limit);
  }

  @override
  Future<List<LocationModel>> getLocations({String? search, int limit = 10}) {
    return _fetchLocations(ApiConstants.buyerLocations, search: search, limit: limit);
  }

  Future<List<LocationModel>> _fetchLocations(
    String path, {
    String? search,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: <String, dynamic>{
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      _ensureOk(response);

      final body = response.data;
      final items = body is Map<String, dynamic> ? body['items'] : body;
      if (items is! List) return const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(_mapLocation)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load locations');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load locations');
    }
  }

  // --- mappers -------------------------------------------------------------

  PropertyModel _mapProject(Map<String, dynamic> json) {
    final locality = (json['locality'] as String?)?.trim();
    final city = (json['city'] as String?)?.trim();
    final location = [locality, city]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');

    final cover = (json['cover_image_url'] as String?)?.trim();

    return PropertyModel(
      id: '${json['id']}',
      title: (json['name'] as String?)?.trim() ?? 'Untitled project',
      location: location,
      imageUrl: (cover != null && cover.isNotEmpty) ? cover : _fallbackImage,
      isFeatured: true,
      unitType: _prettyEnum(json['project_subtype'] as String?),
      sftArea: json['total_built_up_area_sqft']?.toString(),
      propertyType: (json['project_type'] as String?) ?? 'residential',
      hasPayment: false,
    );
  }

  LocationModel _mapLocation(Map<String, dynamic> json) {
    // /buyer/cities -> {city, state}; /buyer/locations -> {locality, city, state}
    final locality = (json['locality'] as String?)?.trim();
    final city = (json['city'] as String?)?.trim();
    final name = (locality != null && locality.isNotEmpty) ? locality : (city ?? '');
    return LocationModel(
      id: '${json['id']}',
      name: name,
      imageUrl: _fallbackImage,
    );
  }

  /// 'gated_plots' -> 'Gated Plots'
  String _prettyEnum(String? value) {
    if (value == null || value.isEmpty) return '';
    return value
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  void _ensureOk(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw ServerException(
        ApiErrorMessageExtractor.extract(response.data),
      );
    }
  }

  Exception _mapDioException(DioException e, String fallback) {
    if (e.response?.data != null) {
      return ServerException(
        ApiErrorMessageExtractor.extract(e.response!.data, fallback: fallback),
      );
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
        );
      default:
        return NetworkException(e.message ?? 'Network error. Please try again.');
    }
  }
}
