import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/property_model.dart';
import '../../presentation/pages/property_details_page.dart';

/// Handles incoming deep links (Android App Links / iOS Universal Links), e.g.
/// `https://links.paysft.com/projects/{id}`.
///
/// A matched link opens the corresponding property inside the app. The details
/// page fetches everything from the project id, so a minimal seed is enough.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  /// The link domain — this is where /.well-known/assetlinks.json is hosted.
  static const String _host = 'links.paysft.com';

  final AppLinks _appLinks = AppLinks();
  GlobalKey<NavigatorState>? _navKey;
  StreamSubscription<Uri>? _sub;

  /// Wire up cold-start + warm (already-running) link handling.
  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navKey = navigatorKey;

    // Links received while the app is already running.
    _sub ??= _appLinks.uriLinkStream.listen(_handle, onError: (_) {});

    // The link that cold-started the app (if any) — route after first frame so
    // the navigator is mounted.
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _handle(initial));
      }
    } catch (_) {
      // No initial link / platform not supported.
    }
  }

  void _handle(Uri uri) {
    final id = _projectId(uri);
    if (id == null) return;
    final nav = _navKey?.currentState;
    if (nav == null) return;
    nav.push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailsPage(
          property: PropertyModel(
            id: id,
            title: '',
            location: '',
            imageUrl: '',
          ),
        ),
      ),
    );
  }

  /// Extracts the project id from `.../projects/{id}` (web link or app scheme).
  /// Returns null when the URI isn't a project link we handle.
  String? _projectId(Uri uri) {
    // For https links, only accept our host; custom-scheme links skip the check.
    if (uri.scheme.startsWith('http') && uri.host != _host) return null;
    final segs = uri.pathSegments;
    final i = segs.indexOf('projects');
    if (i >= 0 && i + 1 < segs.length) {
      final id = segs[i + 1].trim();
      return id.isEmpty ? null : id;
    }
    return null;
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
