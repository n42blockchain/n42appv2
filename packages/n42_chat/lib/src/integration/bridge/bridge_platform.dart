import 'package:flutter/material.dart';

/// Supported Mautrix bridge platforms
///
/// Each platform corresponds to a mautrix bridge that runs as a
/// Matrix Application Service on the homeserver.
enum BridgePlatform {
  discord,
  messenger,
  instagram,
  twitter,
  linkedin,
  whatsapp,
  signal,
  googleMessages,
  googleVoice,
  slack,
  bluesky,
  irc,
  zulip,
  telegram,
  imessage,
  googleChat,
}

/// Metadata and configuration for each bridge platform
class BridgePlatformInfo {
  /// Platform identifier
  final BridgePlatform platform;

  /// Human-readable display name
  final String displayName;

  /// Default bridge bot username prefix (before homeserver)
  final String botUsername;

  /// Mautrix repository name on GitHub
  final String repoName;

  /// Platform icon data
  final IconData icon;

  /// Brand color
  final Color brandColor;

  /// Whether the bridge is actively maintained
  final bool isActive;

  /// Implementation language
  final String language;

  /// Short description of supported features
  final String description;

  /// Supported authentication methods
  final List<BridgeAuthMethod> authMethods;

  /// Whether the platform supports direct messages
  final bool supportsDM;

  /// Whether the platform supports group chats
  final bool supportsGroups;

  /// Whether relay mode is supported (bridging without login)
  final bool supportsRelay;

  /// Ghost user MXID prefix (used to identify bridged users)
  final String ghostPrefix;

  const BridgePlatformInfo({
    required this.platform,
    required this.displayName,
    required this.botUsername,
    required this.repoName,
    required this.icon,
    required this.brandColor,
    this.isActive = true,
    this.language = 'Go',
    required this.description,
    required this.authMethods,
    this.supportsDM = true,
    this.supportsGroups = true,
    this.supportsRelay = false,
    this.ghostPrefix = '',
  });

  /// Get the full bot Matrix user ID for a given homeserver
  String botUserId(String homeserver) => '@$botUsername:$homeserver';
}

/// Authentication method for bridge login
enum BridgeAuthMethod {
  /// QR code scanning (e.g., WhatsApp, WeChat)
  qrCode,

  /// Email and password
  emailPassword,

  /// Phone number and verification code
  phoneVerification,

  /// OAuth2 flow (redirect to external page)
  oauth,

  /// API token (e.g., Slack, Discord bots)
  apiToken,

  /// Username and password
  usernamePassword,

  /// No authentication needed (e.g., IRC)
  none,
}

/// Registry of all supported bridge platforms with their metadata
class BridgePlatformRegistry {
  BridgePlatformRegistry._();

  static const Map<BridgePlatform, BridgePlatformInfo> _platforms = {
    BridgePlatform.discord: BridgePlatformInfo(
      platform: BridgePlatform.discord,
      displayName: 'Discord',
      botUsername: 'discordbot',
      repoName: 'discord',
      icon: Icons.discord,
      brandColor: Color(0xFF5865F2),
      description: 'Bridge Discord servers and DMs',
      authMethods: [BridgeAuthMethod.apiToken, BridgeAuthMethod.qrCode],
      supportsRelay: true,
      ghostPrefix: 'discord_',
    ),
    BridgePlatform.messenger: BridgePlatformInfo(
      platform: BridgePlatform.messenger,
      displayName: 'Messenger',
      botUsername: 'messengerbot',
      repoName: 'meta',
      icon: Icons.messenger_outline,
      brandColor: Color(0xFF0084FF),
      description: 'Bridge Facebook Messenger DMs',
      authMethods: [BridgeAuthMethod.emailPassword],
      ghostPrefix: 'messenger_',
    ),
    BridgePlatform.instagram: BridgePlatformInfo(
      platform: BridgePlatform.instagram,
      displayName: 'Instagram',
      botUsername: 'instagrambot',
      repoName: 'meta',
      icon: Icons.camera_alt_outlined,
      brandColor: Color(0xFFE4405F),
      description: 'Bridge Instagram DMs',
      authMethods: [BridgeAuthMethod.emailPassword],
      ghostPrefix: 'instagram_',
    ),
    BridgePlatform.twitter: BridgePlatformInfo(
      platform: BridgePlatform.twitter,
      displayName: 'X (Twitter) DM',
      botUsername: 'twitterbot',
      repoName: 'twitter',
      icon: Icons.alternate_email,
      brandColor: Color(0xFF000000),
      description: 'Bridge Twitter/X direct messages',
      authMethods: [BridgeAuthMethod.emailPassword],
      supportsGroups: false,
    ),
    BridgePlatform.linkedin: BridgePlatformInfo(
      platform: BridgePlatform.linkedin,
      displayName: 'LinkedIn',
      botUsername: 'linkedinbot',
      repoName: 'linkedin',
      icon: Icons.business,
      brandColor: Color(0xFF0A66C2),
      description: 'Bridge LinkedIn messages',
      authMethods: [BridgeAuthMethod.emailPassword],
      supportsGroups: false,
    ),
    BridgePlatform.whatsapp: BridgePlatformInfo(
      platform: BridgePlatform.whatsapp,
      displayName: 'WhatsApp',
      botUsername: 'whatsappbot',
      repoName: 'whatsapp',
      icon: Icons.chat,
      brandColor: Color(0xFF25D366),
      description: 'Bridge WhatsApp via linked device',
      authMethods: [BridgeAuthMethod.qrCode],
      supportsRelay: true,
      ghostPrefix: 'whatsapp_',
    ),
    BridgePlatform.signal: BridgePlatformInfo(
      platform: BridgePlatform.signal,
      displayName: 'Signal',
      botUsername: 'signalbot',
      repoName: 'signal',
      icon: Icons.security,
      brandColor: Color(0xFF3A76F0),
      description: 'Bridge Signal messages via linked device',
      authMethods: [BridgeAuthMethod.qrCode, BridgeAuthMethod.phoneVerification],
      supportsRelay: true,
      ghostPrefix: 'signal_',
    ),
    BridgePlatform.googleMessages: BridgePlatformInfo(
      platform: BridgePlatform.googleMessages,
      displayName: 'Google Messages',
      botUsername: 'gmessagesbot',
      repoName: 'gmessages',
      icon: Icons.sms,
      brandColor: Color(0xFF1A73E8),
      description: 'Bridge RCS/SMS via Google Messages',
      authMethods: [BridgeAuthMethod.qrCode],
    ),
    BridgePlatform.googleVoice: BridgePlatformInfo(
      platform: BridgePlatform.googleVoice,
      displayName: 'Google Voice',
      botUsername: 'gvoicebot',
      repoName: 'gvoice',
      icon: Icons.phone,
      brandColor: Color(0xFF34A853),
      description: 'Bridge Google Voice calls and messages',
      authMethods: [BridgeAuthMethod.oauth],
    ),
    BridgePlatform.slack: BridgePlatformInfo(
      platform: BridgePlatform.slack,
      displayName: 'Slack',
      botUsername: 'slackbot',
      repoName: 'slack',
      icon: Icons.tag,
      brandColor: Color(0xFF4A154B),
      description: 'Bridge Slack workspaces and DMs',
      authMethods: [BridgeAuthMethod.apiToken, BridgeAuthMethod.emailPassword],
      supportsRelay: true,
    ),
    BridgePlatform.bluesky: BridgePlatformInfo(
      platform: BridgePlatform.bluesky,
      displayName: 'Bluesky',
      botUsername: 'blueskybot',
      repoName: 'bluesky',
      icon: Icons.cloud,
      brandColor: Color(0xFF0085FF),
      description: 'Bridge Bluesky DMs',
      authMethods: [BridgeAuthMethod.usernamePassword],
      supportsGroups: false,
    ),
    BridgePlatform.irc: BridgePlatformInfo(
      platform: BridgePlatform.irc,
      displayName: 'IRC',
      botUsername: 'ircbot',
      repoName: 'irc',
      icon: Icons.terminal,
      brandColor: Color(0xFF009900),
      description: 'Bridge IRC channels and private messages',
      authMethods: [BridgeAuthMethod.none, BridgeAuthMethod.usernamePassword],
      supportsRelay: true,
    ),
    BridgePlatform.zulip: BridgePlatformInfo(
      platform: BridgePlatform.zulip,
      displayName: 'Zulip',
      botUsername: 'zulipbot',
      repoName: 'zulip',
      icon: Icons.forum,
      brandColor: Color(0xFF6492FE),
      description: 'Bridge Zulip streams and DMs',
      authMethods: [BridgeAuthMethod.apiToken],
    ),
    BridgePlatform.telegram: BridgePlatformInfo(
      platform: BridgePlatform.telegram,
      displayName: 'Telegram',
      botUsername: 'telegrambot',
      repoName: 'telegram',
      icon: Icons.send,
      brandColor: Color(0xFF2AABEE),
      description: 'Bridge Telegram chats',
      authMethods: [BridgeAuthMethod.phoneVerification],
      supportsRelay: true,
      ghostPrefix: 'telegram_',
    ),
    BridgePlatform.imessage: BridgePlatformInfo(
      platform: BridgePlatform.imessage,
      displayName: 'iMessage',
      botUsername: 'imessagebot',
      repoName: 'imessage',
      icon: Icons.message,
      brandColor: Color(0xFF34C759),
      isActive: false,
      description: 'Bridge iMessage (requires macOS/Android)',
      authMethods: [BridgeAuthMethod.none],
    ),
    BridgePlatform.googleChat: BridgePlatformInfo(
      platform: BridgePlatform.googleChat,
      displayName: 'Google Chat',
      botUsername: 'googlechatbot',
      repoName: 'googlechat',
      icon: Icons.chat_bubble,
      brandColor: Color(0xFF00AC47),
      isActive: false,
      language: 'Python',
      description: 'Bridge Google Chat spaces and DMs',
      authMethods: [BridgeAuthMethod.oauth],
    ),
  };

  /// Get platform info by enum value
  static BridgePlatformInfo getInfo(BridgePlatform platform) {
    return _platforms[platform]!;
  }

  /// Get all platforms
  static List<BridgePlatformInfo> get allPlatforms =>
      _platforms.values.toList();

  /// Get only actively maintained platforms
  static List<BridgePlatformInfo> get activePlatforms =>
      _platforms.values.where((p) => p.isActive).toList();

  /// Get platforms grouped by maintenance status
  static Map<bool, List<BridgePlatformInfo>> get groupedByStatus {
    final grouped = <bool, List<BridgePlatformInfo>>{};
    for (final p in _platforms.values) {
      (grouped[p.isActive] ??= []).add(p);
    }
    return grouped;
  }

  /// Find platform info by bot username
  static BridgePlatformInfo? findByBotUsername(String username) {
    for (final info in _platforms.values) {
      if (info.botUsername == username) return info;
    }
    return null;
  }
}
