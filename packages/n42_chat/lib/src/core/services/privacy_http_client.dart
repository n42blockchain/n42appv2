import 'package:http/http.dart' as http;

import '../../domain/entities/user_profile_entity.dart';
import 'privacy_http_client_stub.dart'
    if (dart.library.io) 'privacy_http_client_io.dart'
    as impl;

const String kDefaultTorHttpProxy = 'http://127.0.0.1:8118';

bool requiresPrivacyProxy(PrivacySettings? settings) {
  if (settings == null) {
    return false;
  }
  return settings.useTor || settings.proxyEnabled || settings.protectIpAddress;
}

Uri? resolvePrivacyProxyUri(PrivacySettings? settings) {
  if (settings == null) {
    return null;
  }

  if (settings.useTor) {
    return Uri.parse(kDefaultTorHttpProxy);
  }

  if (!settings.proxyEnabled) {
    return null;
  }

  final raw = settings.proxyUrl?.trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(raw);
  if (uri == null || uri.host.isEmpty || uri.port <= 0) {
    return null;
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return null;
  }
  return uri;
}

http.Client createPrivacyAwareHttpClient({
  required PrivacySettings? settings,
  http.Client Function()? fallbackFactory,
}) {
  return impl.createPrivacyAwareHttpClient(
    settings: settings,
    fallbackFactory: fallbackFactory,
  );
}
