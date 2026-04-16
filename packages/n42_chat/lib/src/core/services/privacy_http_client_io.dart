import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../domain/entities/user_profile_entity.dart';

http.Client createPrivacyAwareHttpClient({
  required PrivacySettings? settings,
  http.Client Function()? fallbackFactory,
}) {
  final proxyUri = _resolvePrivacyProxyUri(settings);
  if (proxyUri == null) {
    return fallbackFactory?.call() ?? http.Client();
  }

  final ioClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 35)
    ..findProxy = (_) => 'PROXY ${proxyUri.host}:${proxyUri.port}; DIRECT';

  return IOClient(ioClient);
}

Uri? _resolvePrivacyProxyUri(PrivacySettings? settings) {
  if (settings == null) {
    return null;
  }

  if (settings.useTor) {
    return Uri.parse('http://127.0.0.1:8118');
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
