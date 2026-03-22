import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SocialAuthNativeConfig {
  static const MethodChannel _channel = MethodChannel('ai.n42.www/app_config');

  final String? googleClientId;
  final String? googleServerClientId;
  final String? twitterApiKey;
  final String? twitterApiSecret;
  final String? twitterRedirectUri;
  final String? weChatAppId;
  final String? weChatUniversalLink;

  const SocialAuthNativeConfig({
    this.googleClientId,
    this.googleServerClientId,
    this.twitterApiKey,
    this.twitterApiSecret,
    this.twitterRedirectUri,
    this.weChatAppId,
    this.weChatUniversalLink,
  });

  static Future<SocialAuthNativeConfig> load() async {
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>(
        'getSocialAuthConfig',
      );
      return SocialAuthNativeConfig.fromMap(map ?? const <String, dynamic>{});
    } catch (e) {
      assert(() {
        debugPrint('SocialAuthNativeConfig.load: $e');
        return true;
      }());
      return const SocialAuthNativeConfig();
    }
  }

  factory SocialAuthNativeConfig.fromMap(Map<String, dynamic> map) {
    return SocialAuthNativeConfig(
      googleClientId: _normalize(map['googleClientId']),
      googleServerClientId: _normalize(map['googleServerClientId']),
      twitterApiKey: _normalize(map['twitterApiKey']),
      twitterApiSecret: _normalize(map['twitterApiSecret']),
      twitterRedirectUri: _normalize(map['twitterRedirectUri']),
      weChatAppId: _normalize(map['weChatAppId']),
      weChatUniversalLink: _normalize(map['weChatUniversalLink']),
    );
  }

  static String? _normalize(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;
    if (trimmed.startsWith(r'$(') && trimmed.endsWith(')')) return null;
    return trimmed;
  }
}
