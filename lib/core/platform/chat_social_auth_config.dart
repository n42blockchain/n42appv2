import 'package:n42_wallet/core/platform/social_auth_native_config.dart';

class ChatSocialAuthConfig {
  final String googleClientId;
  final String googleServerClientId;
  final String twitterApiKey;
  final String twitterApiSecret;
  final String twitterRedirectUri;
  final String weChatAppId;
  final String weChatUniversalLink;
  // 增量三家（走自建 backend/social-auth）
  final String discordClientId;
  final String githubClientId;
  final String telegramBotId;
  final String socialAuthBaseUrl;

  const ChatSocialAuthConfig({
    required this.googleClientId,
    required this.googleServerClientId,
    required this.twitterApiKey,
    required this.twitterApiSecret,
    required this.twitterRedirectUri,
    required this.weChatAppId,
    required this.weChatUniversalLink,
    this.discordClientId = '',
    this.githubClientId = '',
    this.telegramBotId = '',
    this.socialAuthBaseUrl = '',
  });

  bool get googleConfigured =>
      googleClientId.isNotEmpty || googleServerClientId.isNotEmpty;

  bool get twitterConfigured =>
      twitterApiKey.isNotEmpty && twitterApiSecret.isNotEmpty;

  bool get weChatConfigured => weChatAppId.isNotEmpty;

  /// 后端基址是三家的公共前置：未配则三家一律不可用。
  bool get socialAuthBackendConfigured => socialAuthBaseUrl.isNotEmpty;

  bool get discordConfigured =>
      socialAuthBackendConfigured && discordClientId.isNotEmpty;

  bool get githubConfigured =>
      socialAuthBackendConfigured && githubClientId.isNotEmpty;

  bool get telegramConfigured =>
      socialAuthBackendConfigured && telegramBotId.isNotEmpty;

  bool supportsGoogleForCurrentPlatform({
    required bool isAndroid,
    required bool isIOS,
    required bool isMacOS,
  }) {
    return googleConfigured && (isAndroid || isIOS || isMacOS);
  }

  bool supportsAppleForCurrentPlatform({
    required bool isIOS,
    required bool isMacOS,
  }) {
    return isIOS || isMacOS;
  }

  List<String> diagnostics({
    required bool isAndroid,
    required bool isIOS,
    required bool isMacOS,
  }) {
    final lines = <String>[];

    lines.add(
      googleConfigured
          ? '[ChatSocialAuth] Google: enabled'
          : '[ChatSocialAuth] Google: disabled (missing client id / server client id)',
    );
    lines.add(
      supportsAppleForCurrentPlatform(isIOS: isIOS, isMacOS: isMacOS)
          ? '[ChatSocialAuth] Apple: enabled'
          : '[ChatSocialAuth] Apple: disabled (platform unsupported)',
    );
    lines.add(
      isAndroid
          ? '[ChatSocialAuth] Facebook: enabled'
          : '[ChatSocialAuth] Facebook: disabled (host only enables Android)',
    );
    lines.add(
      twitterConfigured
          ? '[ChatSocialAuth] Twitter: enabled'
          : '[ChatSocialAuth] Twitter: disabled (missing API key / API secret)',
    );
    lines.add(
      weChatConfigured
          ? '[ChatSocialAuth] WeChat: enabled'
          : '[ChatSocialAuth] WeChat: disabled (missing app id)',
    );
    if (!socialAuthBackendConfigured) {
      lines.add(
        '[ChatSocialAuth] Discord/GitHub/Telegram: disabled '
        '(missing social-auth backend base url)',
      );
    } else {
      lines.add(
        discordConfigured
            ? '[ChatSocialAuth] Discord: enabled'
            : '[ChatSocialAuth] Discord: disabled (missing client id)',
      );
      lines.add(
        githubConfigured
            ? '[ChatSocialAuth] GitHub: enabled'
            : '[ChatSocialAuth] GitHub: disabled (missing client id)',
      );
      lines.add(
        telegramConfigured
            ? '[ChatSocialAuth] Telegram: enabled'
            : '[ChatSocialAuth] Telegram: disabled (missing bot id)',
      );
    }

    return lines;
  }

  factory ChatSocialAuthConfig.resolve({
    required SocialAuthNativeConfig nativeConfig,
    String envGoogleClientId = '',
    String envGoogleServerClientId = '',
    String envTwitterApiKey = '',
    String envTwitterApiSecret = '',
    String envTwitterRedirectUri = '',
    String envWeChatAppId = '',
    String envWeChatUniversalLink = '',
    String envDiscordClientId = '',
    String envGithubClientId = '',
    String envTelegramBotId = '',
    String envSocialAuthBaseUrl = '',
  }) {
    String preferEnv(String envValue, String? nativeValue) {
      if (envValue.isNotEmpty) return envValue;
      return nativeValue ?? '';
    }

    final resolvedTwitterRedirectUri = preferEnv(
      envTwitterRedirectUri,
      nativeConfig.twitterRedirectUri,
    );

    return ChatSocialAuthConfig(
      googleClientId: preferEnv(envGoogleClientId, nativeConfig.googleClientId),
      googleServerClientId: preferEnv(
        envGoogleServerClientId,
        nativeConfig.googleServerClientId,
      ),
      twitterApiKey: preferEnv(envTwitterApiKey, nativeConfig.twitterApiKey),
      twitterApiSecret: preferEnv(
        envTwitterApiSecret,
        nativeConfig.twitterApiSecret,
      ),
      twitterRedirectUri: resolvedTwitterRedirectUri.isEmpty
          ? 'n42://auth/twitter'
          : resolvedTwitterRedirectUri,
      weChatAppId: preferEnv(envWeChatAppId, nativeConfig.weChatAppId),
      weChatUniversalLink: preferEnv(
        envWeChatUniversalLink,
        nativeConfig.weChatUniversalLink,
      ),
      discordClientId: envDiscordClientId,
      githubClientId: envGithubClientId,
      telegramBotId: envTelegramBotId,
      socialAuthBaseUrl: envSocialAuthBaseUrl,
    );
  }
}
