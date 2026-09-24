import '../services/mini_app_bridge_service.dart';
import '../../domain/entities/mini_app_entity.dart';

enum SocialScanPayloadType { matrixUser, matrixRoom, whatsappContact, miniApp }

class SocialScanPayload {
  final SocialScanPayloadType type;
  final String? userId;
  final String? roomIdOrAlias;
  final String? whatsappNumber;
  final Uri? externalUri;
  final MiniAppEntity? miniApp;
  final String? miniAppLaunchUrl;

  const SocialScanPayload._({
    required this.type,
    this.userId,
    this.roomIdOrAlias,
    this.whatsappNumber,
    this.externalUri,
    this.miniApp,
    this.miniAppLaunchUrl,
  });

  const SocialScanPayload.matrixUser(String userId)
    : this._(type: SocialScanPayloadType.matrixUser, userId: userId);

  const SocialScanPayload.matrixRoom(String roomIdOrAlias)
    : this._(
        type: SocialScanPayloadType.matrixRoom,
        roomIdOrAlias: roomIdOrAlias,
      );

  const SocialScanPayload.whatsapp(String number, Uri uri)
    : this._(
        type: SocialScanPayloadType.whatsappContact,
        whatsappNumber: number,
        externalUri: uri,
      );

  const SocialScanPayload.miniApp(MiniAppEntity miniApp, {String? launchUrl})
    : this._(
        type: SocialScanPayloadType.miniApp,
        miniApp: miniApp,
        miniAppLaunchUrl: launchUrl,
      );
}

/// Builds the standard Matrix permalink used by interoperable personal QR codes.
String buildMatrixUserPermalink(String userId) {
  final normalized = _normalizeMatrixUserId(userId);
  if (normalized == null) {
    throw const FormatException('Invalid Matrix user ID');
  }
  return 'https://matrix.to/#/${Uri.encodeComponent(normalized)}';
}

SocialScanPayload? parseSocialScanPayload(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;

  final whatsapp = _parseWhatsAppClickToChat(value);
  if (whatsapp != null) return whatsapp;

  final matrixPermalink = _parseMatrixPermalink(value);
  if (matrixPermalink != null) return matrixPermalink;

  final userId = _extractLegacyMatrixUserId(value);
  if (userId != null) return SocialScanPayload.matrixUser(userId);

  final miniAppMatch = _extractBuiltInMiniApp(value);
  if (miniAppMatch != null) {
    return SocialScanPayload.miniApp(
      miniAppMatch.app,
      launchUrl: miniAppMatch.launchUrl,
    );
  }
  return null;
}

SocialScanPayload? _parseMatrixPermalink(String raw) {
  final uri = Uri.tryParse(raw);
  if (uri == null ||
      uri.scheme.toLowerCase() != 'https' ||
      uri.host.toLowerCase() != 'matrix.to' ||
      !_hasExactAuthority(raw, 'matrix.to') ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      (uri.path.isNotEmpty && uri.path != '/') ||
      uri.query.isNotEmpty ||
      uri.fragment.isEmpty) {
    return null;
  }

  final fragment = uri.fragment;
  final targetPart = fragment.startsWith('/')
      ? fragment.substring(1)
      : fragment;
  final separator = targetPart.indexOf('?');
  final encodedTarget = separator < 0
      ? targetPart
      : targetPart.substring(0, separator);
  final rawVia = separator < 0 ? '' : targetPart.substring(separator + 1);
  if (rawVia.isNotEmpty &&
      (!rawVia.startsWith('via=') || rawVia.contains('&'))) {
    return null;
  }

  try {
    final target = Uri.decodeComponent(encodedTarget);
    final userId = _normalizeMatrixUserId(target);
    if (userId != null) return SocialScanPayload.matrixUser(userId);
    final room = _normalizeMatrixRoomTarget(target);
    if (room != null) return SocialScanPayload.matrixRoom(room);
  } on FormatException {
    return null;
  }
  return null;
}

SocialScanPayload? _parseWhatsAppClickToChat(String raw) {
  final uri = Uri.tryParse(raw);
  if (uri == null ||
      uri.scheme.toLowerCase() != 'https' ||
      uri.host.toLowerCase() != 'wa.me' ||
      !_hasExactAuthority(raw, 'wa.me') ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      uri.hasQuery ||
      uri.hasFragment) {
    return null;
  }
  final match = RegExp(r'^/([1-9][0-9]{7,14})$').firstMatch(uri.path);
  if (match == null) return null;
  final number = match.group(1)!;
  return SocialScanPayload.whatsapp(
    number,
    Uri(scheme: 'https', host: 'wa.me', path: '/$number'),
  );
}

bool _hasExactAuthority(String raw, String expectedHost) {
  final match = RegExp(
    r'^[a-z][a-z0-9+.-]*://([^/?#]*)',
    caseSensitive: false,
  ).firstMatch(raw);
  return match?.group(1)?.toLowerCase() == expectedHost;
}

String? _extractLegacyMatrixUserId(String data) {
  for (final prefix in const [
    'n42chat://user/',
    'n42chat:user:',
    'n42://user/',
  ]) {
    if (data.startsWith(prefix)) {
      return _normalizeMatrixUserId(data.substring(prefix.length));
    }
  }
  return _normalizeMatrixUserId(data);
}

String? _normalizeMatrixUserId(String value) {
  final trimmed = value.trim();
  if (!RegExp(
    r'^@[A-Za-z0-9._=+\-/]+:[A-Za-z0-9.-]+(?::[0-9]+)?$',
  ).hasMatch(trimmed)) {
    return null;
  }
  return trimmed;
}

String? _normalizeMatrixRoomTarget(String value) {
  final trimmed = value.trim();
  if (!RegExp(
    r'^[!#][A-Za-z0-9._=+\-/]+:[A-Za-z0-9.-]+(?::[0-9]+)?$',
  ).hasMatch(trimmed)) {
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
      if (app != null) return _BuiltInMiniAppMatch(app: app);
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
