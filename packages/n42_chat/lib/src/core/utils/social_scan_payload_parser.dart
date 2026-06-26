import '../services/mini_app_bridge_service.dart';
import '../../domain/entities/mini_app_entity.dart';

enum SocialScanPayloadType { matrixUser, miniApp }

class SocialScanPayload {
  final SocialScanPayloadType type;
  final String? userId;
  final MiniAppEntity? miniApp;
  final String? miniAppLaunchUrl;

  const SocialScanPayload._({
    required this.type,
    this.userId,
    this.miniApp,
    this.miniAppLaunchUrl,
  });

  const SocialScanPayload.matrixUser(String userId)
    : this._(type: SocialScanPayloadType.matrixUser, userId: userId);

  const SocialScanPayload.miniApp(MiniAppEntity miniApp, {String? launchUrl})
    : this._(
        type: SocialScanPayloadType.miniApp,
        miniApp: miniApp,
        miniAppLaunchUrl: launchUrl,
      );
}

SocialScanPayload? parseSocialScanPayload(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;

  final userId = _extractMatrixUserId(value);
  if (userId != null) {
    return SocialScanPayload.matrixUser(userId);
  }

  final miniAppMatch = _extractBuiltInMiniApp(value);
  if (miniAppMatch != null) {
    return SocialScanPayload.miniApp(
      miniAppMatch.app,
      launchUrl: miniAppMatch.launchUrl,
    );
  }

  return null;
}

String? _extractMatrixUserId(String data) {
  for (final prefix in const [
    'n42chat://user/',
    'n42chat:user:',
    'n42://user/',
  ]) {
    if (data.startsWith(prefix)) {
      return _normalizeMatrixUserId(data.substring(prefix.length));
    }
  }

  final directUserId = _normalizeMatrixUserId(data);
  if (directUserId != null) {
    return directUserId;
  }

  final uri = Uri.tryParse(data);
  if (uri == null) return null;

  if (uri.host == 'matrix.to') {
    final fragment = uri.fragment;
    if (fragment.isEmpty) return null;
    final normalizedFragment = fragment.startsWith('/')
        ? fragment.substring(1)
        : fragment;
    final decoded = Uri.decodeComponent(normalizedFragment).split('?').first;
    return _normalizeMatrixUserId(decoded);
  }

  return null;
}

String? _normalizeMatrixUserId(String value) {
  final trimmed = value.trim();
  if (!trimmed.startsWith('@') || !trimmed.contains(':')) {
    return null;
  }
  return trimmed;
}

class _BuiltInMiniAppMatch {
  final MiniAppEntity app;
  final String? launchUrl;

  const _BuiltInMiniAppMatch({required this.app, this.launchUrl});
}

_BuiltInMiniAppMatch? _extractBuiltInMiniApp(String data) {
  for (final prefix in const [
    'n42chat://miniapp/',
    'n42://miniapp/',
    'n42chat:miniapp:',
  ]) {
    if (data.startsWith(prefix)) {
      final id = data.substring(prefix.length).trim().split('?').first;
      final app = _findBuiltInMiniAppById(id);
      if (app != null) {
        return _BuiltInMiniAppMatch(app: app);
      }
      return null;
    }
  }

  final candidateUri = normalizeTrustedMiniAppUri(data);
  if (candidateUri == null) return null;

  for (final app in BuiltInMiniApps.all) {
    final appUri = normalizeTrustedMiniAppUri(app.url);
    if (appUri == null) continue;
    if (appUri.scheme == candidateUri.scheme &&
        appUri.host == candidateUri.host &&
        appUri.port == candidateUri.port) {
      return _BuiltInMiniAppMatch(app: app, launchUrl: candidateUri.toString());
    }
  }

  return null;
}

MiniAppEntity? _findBuiltInMiniAppById(String id) {
  for (final app in BuiltInMiniApps.all) {
    if (app.id == id) return app;
  }
  return null;
}
