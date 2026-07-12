class UrlDetector {
  // Regex pattern to detect URLs
  static final RegExp _urlPattern = RegExp(r'https?://[^\s]+|www\.[^\s]+', caseSensitive: false);

  /// Detects if a string contains a URL
  static bool containsUrl(String text) {
    return _urlPattern.hasMatch(text);
  }

  /// Extracts the first URL from a string
  static String? extractUrl(String text) {
    final match = _urlPattern.firstMatch(text);
    return match?.group(0);
  }

  /// Extracts all URLs from a string
  static List<String> extractAllUrls(String text) {
    final matches = _urlPattern.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  /// Normalizes a URL (adds https:// if missing)
  static String normalizeUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }
}
