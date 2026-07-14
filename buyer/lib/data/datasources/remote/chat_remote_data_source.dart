import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_error_message_extractor.dart';

/// One chat message from the backend (`ChatMessageResponse`).
class ChatMessageDto {
  final String id;
  final String senderRole; // 'buyer' | 'broker'
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  const ChatMessageDto({
    required this.id,
    required this.senderRole,
    required this.body,
    required this.createdAt,
    required this.readAt,
  });

  bool get fromBuyer => senderRole == 'buyer';

  factory ChatMessageDto.fromJson(Map m) => ChatMessageDto(
        id: '${m['id'] ?? ''}',
        senderRole: '${m['sender_role'] ?? 'broker'}',
        body: '${m['body'] ?? ''}',
        createdAt: DateTime.tryParse('${m['created_at'] ?? ''}')?.toLocal() ??
            DateTime.now(),
        readAt: m['read_at'] == null
            ? null
            : DateTime.tryParse('${m['read_at']}')?.toLocal(),
      );
}

/// A lead's chat thread (`ChatThreadResponse`).
class ChatThreadDto {
  final String leadId;
  final String counterpartName;
  final List<ChatMessageDto> messages;

  const ChatThreadDto({
    required this.leadId,
    required this.counterpartName,
    required this.messages,
  });
}

/// Buyer↔broker chat on the PaySFT backend (`/buyer/leads/{id}/messages`).
abstract class ChatRemoteDataSource {
  Future<ChatThreadDto> getThread(String leadId);
  Future<ChatMessageDto> sendMessage(String leadId, String body);
  Future<void> markRead(String leadId);

  /// lead_id -> unread count.
  Future<Map<String, int>> unreadPerLead();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<ChatThreadDto> getThread(String leadId) async {
    try {
      final resp = await dio.get(ApiConstants.buyerLeadMessages(leadId));
      final data = resp.data;
      final map = data is Map ? data : const {};
      final rawMsgs = map['messages'];
      final messages = (rawMsgs is List)
          ? rawMsgs
              .whereType<Map>()
              .map(ChatMessageDto.fromJson)
              .toList(growable: false)
          : <ChatMessageDto>[];
      return ChatThreadDto(
        leadId: '${map['lead_id'] ?? leadId}',
        counterpartName: '${map['counterpart_name'] ?? ''}',
        messages: messages,
      );
    } on DioException catch (e) {
      throw _map(e, 'Failed to load messages');
    }
  }

  @override
  Future<ChatMessageDto> sendMessage(String leadId, String body) async {
    try {
      final resp = await dio.post(
        ApiConstants.buyerLeadMessages(leadId),
        data: <String, dynamic>{'body': body},
      );
      final data = resp.data;
      if (data is Map) return ChatMessageDto.fromJson(data);
      throw const ServerException('Unexpected response while sending message');
    } on DioException catch (e) {
      throw _map(e, 'Message could not be sent');
    }
  }

  @override
  Future<void> markRead(String leadId) async {
    try {
      await dio.post(ApiConstants.buyerLeadMessagesRead(leadId));
    } catch (_) {
      // Best-effort; not user-facing.
    }
  }

  @override
  Future<Map<String, int>> unreadPerLead() async {
    try {
      final resp = await dio.get(ApiConstants.buyerMessagesUnread);
      final data = resp.data;
      final perLead = (data is Map ? data['per_lead'] : null);
      if (perLead is Map) {
        return perLead.map((k, v) =>
            MapEntry('$k', v is int ? v : int.tryParse('$v') ?? 0));
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  Exception _map(DioException e, String fallback) {
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
        return NetworkException('No internet connection. Please try again.');
      default:
        return NetworkException(e.message ?? 'Network error. Please try again.');
    }
  }
}
