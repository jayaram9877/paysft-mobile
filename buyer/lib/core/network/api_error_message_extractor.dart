/// Extracts the most meaningful error message from this API's response shape.
///
/// Rules (per your backend contract):
/// - Prefer `responceDataObject.message`
/// - Fallback to top-level `message`
/// - Otherwise return a generic message
class ApiErrorMessageExtractor {
  static String extract(dynamic data, {String fallback = 'Something went wrong'}) {
    if (data is Map<String, dynamic>) {
      // PaySFT demo backend business error shape:
      // {"error": {"code": "...", "message": "..."}}
      final error = data['error'];
      if (error is Map) {
        final message = error['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }

      // FastAPI validation error shape: {"detail": ...}
      // `detail` may be a plain string, or a list of validation objects
      // like [{"msg": "...", "loc": [...]}].
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
      if (detail is List && detail.isNotEmpty) {
        final messages = detail
            .whereType<Map>()
            .map((e) => e['msg'])
            .whereType<String>()
            .where((m) => m.trim().isNotEmpty)
            .toList();
        if (messages.isNotEmpty) return messages.join('\n');
      }

      final responseDataObject = data['responceDataObject'];
      if (responseDataObject is Map<String, dynamic>) {
        final nestedMessage = responseDataObject['message'];
        if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
          return nestedMessage;
        }
      }

      final topMessage = data['message'];
      if (topMessage is String && topMessage.trim().isNotEmpty) {
        return topMessage;
      }
    }

    return fallback;
  }
}

