import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../../core/utils/currency_format.dart';
import '../../../domain/entities/buyer_offer.dart';

/// Buyer unit-sale offers on the PaySFT demo backend:
///   GET  /buyer/sales                      -> list offers
///   GET  /buyer/sales/{id}                 -> offer detail
///   GET  /buyer/sales/{id}/preview         -> preview
///   POST /buyer/sales/{id}/accept          -> accept
///   POST /buyer/sales/{id}/decline         -> decline
///   POST /buyer/sales/{id}/claim {token}   -> claim with token
abstract class SalesRemoteDataSource {
  Future<List<BuyerOfferSummary>> listOffers();

  Future<BuyerOfferDetail> getOffer(String saleId);

  Future<BuyerOfferPreview> previewOffer(String saleId);

  Future<BuyerOfferDetail> acceptOffer(String saleId);

  Future<BuyerOfferDetail> declineOffer(String saleId);

  Future<BuyerOfferDetail> claimOffer(String saleId, String token);
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final Dio dio;

  SalesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BuyerOfferSummary>> listOffers() async {
    try {
      final resp = await dio.get(ApiConstants.buyerSales);
      final data = resp.data;
      final items = data is Map ? data['items'] : null;
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map(_summaryFromJson)
          .where((o) => o.saleId.isNotEmpty)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load your offers');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load your offers');
    }
  }

  @override
  Future<BuyerOfferDetail> getOffer(String saleId) async {
    return _detailFromWrite(() => dio.get(ApiConstants.buyerSale(saleId)));
  }

  @override
  Future<BuyerOfferPreview> previewOffer(String saleId) async {
    try {
      final resp = await dio.get(ApiConstants.buyerSalePreview(saleId));
      final data = resp.data;
      if (data is! Map) {
        throw const ServerException('Unexpected response from preview');
      }
      return _previewFromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load offer preview');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load offer preview');
    }
  }

  @override
  Future<BuyerOfferDetail> acceptOffer(String saleId) async {
    return _detailFromWrite(() => dio.post(ApiConstants.buyerSaleAccept(saleId)));
  }

  @override
  Future<BuyerOfferDetail> declineOffer(String saleId) async {
    return _detailFromWrite(() => dio.post(ApiConstants.buyerSaleDecline(saleId)));
  }

  @override
  Future<BuyerOfferDetail> claimOffer(String saleId, String token) async {
    return _detailFromWrite(
      () => dio.post(
        ApiConstants.buyerSaleClaim(saleId),
        data: {'token': token.trim()},
      ),
    );
  }

  Future<BuyerOfferDetail> _detailFromWrite(
    Future<Response> Function() call,
  ) async {
    try {
      final resp = await call();
      final data = resp.data;
      if (data is! Map) {
        throw const ServerException('Unexpected response from the offer API');
      }
      return _detailFromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Could not update this offer');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Could not update this offer');
    }
  }

  BuyerOfferSummary _summaryFromJson(Map m) => BuyerOfferSummary(
        saleId: '${m['sale_id'] ?? m['id'] ?? ''}',
        status: '${m['status'] ?? ''}',
        projectName: '${m['project_name'] ?? ''}',
        unitLabel: '${m['unit_label'] ?? m['unit_number'] ?? ''}',
        totalCost: CurrencyFormat.inr(m['total_cost']),
      );

  BuyerOfferDetail _detailFromJson(Map m) => BuyerOfferDetail(
        saleId: '${m['sale_id'] ?? m['id'] ?? ''}',
        status: '${m['status'] ?? ''}',
        projectId: '${m['project_id'] ?? ''}',
        projectName: '${m['project_name'] ?? ''}',
        projectLocation: _str(m['project_location']),
        projectRera: _str(m['project_rera']),
        projectType: '${m['project_type'] ?? ''}',
        projectSubtype: '${m['project_subtype'] ?? ''}',
        unitNumber: '${m['unit_number'] ?? ''}',
        unitTitle: _str(m['unit_title']),
        builderName: '${m['builder_name'] ?? ''}',
        totalCost: CurrencyFormat.inr(m['total_cost']),
        costBreakdown: _mapOf(m['cost_breakdown']),
        milestones: _listOfMaps(m['milestones']),
        escrow: m['escrow'] is Map
            ? Map<String, dynamic>.from(m['escrow'] as Map)
            : null,
        relationshipManager: m['relationship_manager'] is Map
            ? Map<String, dynamic>.from(m['relationship_manager'] as Map)
            : null,
        sentAt: _dt(m['sent_at']),
        viewedAt: _dt(m['viewed_at']),
        acceptedAt: _dt(m['accepted_at']),
        declinedAt: _dt(m['declined_at']),
      );

  BuyerOfferPreview _previewFromJson(Map m) => BuyerOfferPreview(
        saleId: '${m['sale_id'] ?? ''}',
        status: '${m['status'] ?? ''}',
        projectName: '${m['project_name'] ?? ''}',
        unitNumber: '${m['unit_number'] ?? ''}',
        unitTitle: _str(m['unit_title']),
        builderName: '${m['builder_name'] ?? ''}',
        buyerName: _str(m['buyer_name']),
        totalCost: CurrencyFormat.inr(m['total_cost']),
        costBreakdown: _mapOf(m['cost_breakdown']),
        milestones: _listOfMaps(m['milestones']),
      );

  String? _str(dynamic v) => v == null ? null : '$v';

  DateTime? _dt(dynamic v) {
    final s = _str(v);
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s)?.toLocal();
  }

  Map<String, dynamic> _mapOf(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : const {};

  List<Map<String, dynamic>> _listOfMaps(dynamic v) {
    if (v is! List) return const [];
    return v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
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
