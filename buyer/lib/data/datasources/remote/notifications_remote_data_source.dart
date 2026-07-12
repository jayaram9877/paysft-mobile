import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_error_message_extractor.dart';
import '../../../domain/entities/notification_model.dart';

/// Buyer notification feed on the PaySFT demo backend:
///   GET /buyer/notifications -> {items: [...]}.
///
/// The backend renders `title`/`body` and tags each item with a `kind` plus
/// optional deep-link ids (lead_id / sale_id / project_id). It does NOT track
/// read state, so that stays local (see [NotificationsProvider]); every item is
/// returned with `isRead: false` here.
abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final Dio dio;

  NotificationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final resp = await dio.get(ApiConstants.buyerNotifications);
      final data = resp.data;
      // Documented shape is {items: [...]}, but tolerate a bare list too.
      final list = data is Map ? data['items'] : data;
      if (list is! List) return const [];
      return list.whereType<Map>().map(_fromJson).toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e, 'Failed to load notifications');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to load notifications');
    }
  }

  NotificationModel _fromJson(Map m) {
    final offer = m['offer'] is Map ? m['offer'] as Map : null;
    final kind = (_str(m['kind']) ?? '').toLowerCase();

    // sale_id can arrive at the top level or nested under the offer summary.
    final saleId = _str(m['sale_id']) ?? _str(offer?['sale_id']);
    final projectId = _str(m['project_id']) ?? _str(offer?['project_id']);

    final createdAt = _str(m['created_at']);
    final timestamp =
        (createdAt == null ? null : DateTime.tryParse(createdAt)?.toLocal()) ??
            DateTime.now();

    return NotificationModel(
      id: '${m['id'] ?? ''}',
      title: _str(m['title']) ?? '',
      message: _str(m['body']) ?? '',
      timestamp: timestamp,
      type: _typeFor(kind, hasOffer: offer != null),
      saleId: saleId,
      projectId: projectId,
    );
  }

  /// Maps the backend `kind` string onto the app's coarse notification types.
  /// Unknown kinds fall back to [NotificationType.system] so the item still
  /// renders (with its server-provided title/body) instead of being dropped.
  NotificationType _typeFor(String kind, {required bool hasOffer}) {
    if (kind.contains('offer') || hasOffer) return NotificationType.offer;
    if (kind.contains('visit') || kind.contains('meeting')) {
      return NotificationType.visit;
    }
    if (kind.contains('broker') ||
        kind.contains('lead') ||
        kind.contains('assign') ||
        kind.contains('interest')) {
      return NotificationType.interest;
    }
    return NotificationType.system;
  }

  String? _str(dynamic v) => v == null ? null : '$v';

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
