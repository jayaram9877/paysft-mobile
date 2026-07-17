import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';

/// One chat message (`ChatMessageResponse`). [mine] is true when the broker
/// (this app) sent it.
class ChatMessageModel {
  final String id;
  final String senderRole; // 'buyer' | 'broker'
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  const ChatMessageModel({
    required this.id,
    required this.senderRole,
    required this.body,
    required this.createdAt,
    required this.readAt,
  });

  bool get mine => senderRole == 'broker';

  factory ChatMessageModel.fromJson(Map m) => ChatMessageModel(
        id: '${m['id'] ?? ''}',
        senderRole: '${m['sender_role'] ?? 'buyer'}',
        body: '${m['body'] ?? ''}',
        createdAt: DateTime.tryParse('${m['created_at'] ?? ''}')?.toLocal() ??
            DateTime.now(),
        readAt: m['read_at'] == null
            ? null
            : DateTime.tryParse('${m['read_at']}')?.toLocal(),
      );
}

/// A lead's chat thread (`ChatThreadResponse`).
class ChatThreadModel {
  final String leadId;
  final String counterpartName; // the buyer, from the broker's side
  final List<ChatMessageModel> messages;

  const ChatThreadModel({
    required this.leadId,
    required this.counterpartName,
    required this.messages,
  });
}

/// Broker↔buyer chat (`/brokers/me/leads/{id}/messages`).
abstract class ChatRemoteDataSource {
  Future<ChatThreadModel> getThread(String leadId);
  Future<ChatMessageModel> sendMessage(String leadId, String body);
  Future<void> markRead(String leadId);

  /// lead_id -> unread count.
  Future<Map<String, int>> unreadPerLead();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl(this.dio);

  @override
  Future<ChatThreadModel> getThread(String leadId) async {
    try {
      final res = await dio.get(ApiConstants.brokerLeadMessages(leadId));
      final data = res.data;
      final map = data is Map ? data : const {};
      final raw = map['messages'];
      final messages = raw is List
          ? raw
              .whereType<Map>()
              .map(ChatMessageModel.fromJson)
              .toList(growable: false)
          : <ChatMessageModel>[];
      return ChatThreadModel(
        leadId: '${map['lead_id'] ?? leadId}',
        counterpartName: '${map['counterpart_name'] ?? ''}',
        messages: messages,
      );
    } on DioException catch (e) {
      throw ServerException(_message(e, 'Failed to load messages'));
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(String leadId, String body) async {
    try {
      final res = await dio.post(
        ApiConstants.brokerLeadMessages(leadId),
        data: {'body': body},
      );
      final data = res.data;
      if (data is Map) return ChatMessageModel.fromJson(data);
      throw const ServerException('Unexpected response while sending message');
    } on DioException catch (e) {
      throw ServerException(_message(e, 'Message could not be sent'));
    }
  }

  @override
  Future<void> markRead(String leadId) async {
    try {
      await dio.post(ApiConstants.brokerLeadMessagesRead(leadId));
    } catch (_) {
      // Best-effort.
    }
  }

  @override
  Future<Map<String, int>> unreadPerLead() async {
    try {
      final res = await dio.get(ApiConstants.brokersMeMessagesUnread);
      final data = res.data;
      final perLead = data is Map ? data['per_lead'] : null;
      if (perLead is Map) {
        return perLead.map(
          (k, v) => MapEntry('$k', v is int ? v : int.tryParse('$v') ?? 0),
        );
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  String _message(DioException e, String fallback) {
    final body = e.response?.data;
    if (body is Map) {
      final err = body['error'];
      if (err is Map && err['message'] != null) return '${err['message']}';
      final detail = body['detail'];
      if (detail is String) return detail;
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please try again.';
    }
    return fallback;
  }
}
