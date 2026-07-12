import '../../../domain/entities/onboarding_content.dart';

class OnboardingContentResponse {
  final List<OnboardingContent> items;

  const OnboardingContentResponse({required this.items});

  factory OnboardingContentResponse.fromJson(Map<String, dynamic> json) {
    final responseObject = _asMap(json['responceDataObject']);
    final data = responseObject['data'];

    final list = _extractList(data);
    final parsed = list.map(_parseItem).whereType<OnboardingContent>().toList();

    return OnboardingContentResponse(items: parsed);
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      final candidates = <dynamic>[
        data['items'],
        data['onboarding'],
        data['onboardingItems'],
        data['content'],
        data['data'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) return candidate;
      }
    }
    return <dynamic>[];
  }

  static OnboardingContent? _parseItem(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;

    final fullText =
        _asString(raw['fullText']) ??
        _asString(raw['title']) ??
        _asString(raw['heading']) ??
        '';
    final highlightedText =
        _asString(raw['highlightedText']) ??
        _asString(raw['highlight']) ??
        _asString(raw['highlightText']) ??
        '';
    final description =
        _asString(raw['description']) ??
        _asString(raw['message']) ??
        _asString(raw['subTitle']) ??
        _asString(raw['subtitle']) ??
        '';
    final imageUrl =
        _asString(raw['imageUrl']) ??
        _asString(raw['image']) ??
        _asString(raw['mediaUrl']) ??
        '';

    if (fullText.isEmpty || description.isEmpty || imageUrl.isEmpty)
      return null;

    return OnboardingContent(
      fullText: fullText,
      highlightedText: highlightedText,
      description: description,
      imageUrl: imageUrl,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return <String, dynamic>{};
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}
