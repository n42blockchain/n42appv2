import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;

import 'avatar_decoration_preset.dart';

final _whitespaceRegExp = RegExp(r'\s+');

/// 用户资料实体
class UserProfileEntity extends Equatable {
  /// 用户ID（Matrix格式：@user:server.com）
  final String userId;

  /// 显示名称
  final String? displayName;

  /// 头像URL
  final String? avatarUrl;

  /// 签名/状态
  final String? statusMessage;

  /// 邮箱
  final String? email;

  /// 手机号
  final String? phoneNumber;

  /// 注册时间
  final DateTime? createdAt;

  /// 最后活跃时间
  final DateTime? lastActiveAt;

  /// 是否在线
  final bool isOnline;

  /// 是否已验证邮箱
  final bool emailVerified;

  /// 是否已验证手机
  final bool phoneVerified;

  // ============================================
  // NFT 头像字段
  // ============================================

  /// NFT 合约地址
  final String? nftContractAddress;

  /// NFT Token ID
  final int? nftTokenId;

  /// NFT 所在链 ID
  final int? nftChainId;

  /// NFT 头像图片 URL（已解析的 HTTPS URL）
  final String? nftImageUrl;

  /// 头像装饰样式
  final AvatarDecorationPreset avatarDecorationPreset;

  /// 是否使用 NFT 头像
  bool get hasNftAvatar =>
      nftContractAddress != null && nftTokenId != null && nftImageUrl != null;

  const UserProfileEntity({
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.statusMessage,
    this.email,
    this.phoneNumber,
    this.createdAt,
    this.lastActiveAt,
    this.isOnline = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.nftContractAddress,
    this.nftTokenId,
    this.nftChainId,
    this.nftImageUrl,
    this.avatarDecorationPreset = AvatarDecorationPreset.none,
  });

  /// 获取有效显示名称
  String get effectiveDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    // 从userId中提取用户名
    final localpart = userId.split(':').first;
    return localpart.startsWith('@') ? localpart.substring(1) : localpart;
  }

  /// 获取名字首字母
  String get initials {
    final name = effectiveDisplayName;
    if (name.isEmpty) return '?';

    final words = name.trim().split(_whitespaceRegExp);
    if (words.length == 1) {
      return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    }

    return words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  /// 获取服务器地址
  String get homeserver {
    final parts = userId.split(':');
    if (parts.length > 1) {
      return parts.last;
    }
    return '';
  }

  /// 获取用户名部分（不含@和服务器）
  String get username {
    final localpart = userId.split(':').first;
    return localpart.startsWith('@') ? localpart.substring(1) : localpart;
  }

  @override
  List<Object?> get props => [
    userId,
    displayName,
    avatarUrl,
    statusMessage,
    email,
    phoneNumber,
    createdAt,
    lastActiveAt,
    isOnline,
    emailVerified,
    phoneVerified,
    nftContractAddress,
    nftTokenId,
    nftChainId,
    nftImageUrl,
    avatarDecorationPreset,
  ];

  UserProfileEntity copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? statusMessage,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isOnline,
    bool? emailVerified,
    bool? phoneVerified,
    String? nftContractAddress,
    int? nftTokenId,
    int? nftChainId,
    String? nftImageUrl,
    AvatarDecorationPreset? avatarDecorationPreset,
  }) {
    return UserProfileEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      statusMessage: statusMessage ?? this.statusMessage,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isOnline: isOnline ?? this.isOnline,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      nftContractAddress: nftContractAddress ?? this.nftContractAddress,
      nftTokenId: nftTokenId ?? this.nftTokenId,
      nftChainId: nftChainId ?? this.nftChainId,
      nftImageUrl: nftImageUrl ?? this.nftImageUrl,
      avatarDecorationPreset:
          avatarDecorationPreset ?? this.avatarDecorationPreset,
    );
  }
}

/// 用户设置实体
class UserSettingsEntity extends Equatable {
  /// 通知设置
  final NotificationSettings notifications;

  /// 隐私设置
  final PrivacySettings privacy;

  /// 外观设置
  final AppearanceSettings appearance;

  /// 聊天设置
  final ChatSettings chat;

  const UserSettingsEntity({
    this.notifications = const NotificationSettings(),
    this.privacy = const PrivacySettings(),
    this.appearance = const AppearanceSettings(),
    this.chat = const ChatSettings(),
  });

  @override
  List<Object?> get props => [notifications, privacy, appearance, chat];

  UserSettingsEntity copyWith({
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    AppearanceSettings? appearance,
    ChatSettings? chat,
  }) {
    return UserSettingsEntity(
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      appearance: appearance ?? this.appearance,
      chat: chat ?? this.chat,
    );
  }
}

/// 通知设置
enum NotificationPrivacyMode {
  /// 显示发件人与消息正文
  full,

  /// 仅显示发件人/会话名，不显示正文
  senderOnly,

  /// 不显示发件人与正文，只显示通用提示
  hidden,
}

/// 通知设置
class NotificationSettings extends Equatable {
  /// 是否启用通知
  final bool enabled;

  /// 是否显示消息预览
  final bool showPreview;

  /// 是否播放声音
  final bool playSound;

  /// 是否震动
  final bool vibrate;

  /// 免打扰模式
  final bool doNotDisturb;

  /// 免打扰开始时间
  final String? doNotDisturbStart;

  /// 免打扰结束时间
  final String? doNotDisturbEnd;

  /// 通知隐私模式
  final NotificationPrivacyMode privacyMode;

  const NotificationSettings({
    this.enabled = true,
    this.showPreview = true,
    this.playSound = true,
    this.vibrate = true,
    this.doNotDisturb = false,
    this.doNotDisturbStart,
    this.doNotDisturbEnd,
    this.privacyMode = NotificationPrivacyMode.full,
  });

  @override
  List<Object?> get props => [
    enabled,
    showPreview,
    playSound,
    vibrate,
    doNotDisturb,
    doNotDisturbStart,
    doNotDisturbEnd,
    privacyMode,
  ];

  NotificationSettings copyWith({
    bool? enabled,
    bool? showPreview,
    bool? playSound,
    bool? vibrate,
    bool? doNotDisturb,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
    NotificationPrivacyMode? privacyMode,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      showPreview: showPreview ?? this.showPreview,
      playSound: playSound ?? this.playSound,
      vibrate: vibrate ?? this.vibrate,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      doNotDisturbStart: doNotDisturbStart ?? this.doNotDisturbStart,
      doNotDisturbEnd: doNotDisturbEnd ?? this.doNotDisturbEnd,
      privacyMode: privacyMode ?? this.privacyMode,
    );
  }
}

/// 隐私设置
class PrivacySettings extends Equatable {
  /// 谁可以查看头像
  final VisibilityLevel avatarVisibility;

  /// 谁可以查看状态
  final VisibilityLevel statusVisibility;

  /// 谁可以查看最后上线时间
  final VisibilityLevel lastSeenVisibility;

  /// 是否允许陌生人私聊
  final bool allowStrangerMessage;

  /// 是否显示已读回执
  final bool showReadReceipts;

  /// 是否显示输入状态
  final bool showTypingIndicator;

  /// 是否在客户端隐藏手机号展示
  final bool hidePhoneNumber;

  /// 是否为聊天中的链接自动拉取预览
  final bool showLinkPreviews;

  /// 是否默认对新聊天开启端到端加密
  final bool defaultEncryptNewChats;

  /// 是否启用私密聊天模式
  ///
  /// 启用后会在私聊/加密聊天会话中临时开启截图防护。
  final bool privateChatMode;

  /// 是否启用 IP 地址保护
  ///
  /// 该选项会优先通过自定义 HTTP/HTTPS 代理或本地 Privoxy-compatible
  /// Tor HTTP 代理发起网络请求。
  final bool protectIpAddress;

  /// 是否启用自定义代理
  final bool proxyEnabled;

  /// 自定义代理地址（例如 http://127.0.0.1:7890）
  final String? proxyUrl;

  /// 是否使用本地 Tor/Privoxy HTTP 代理
  ///
  /// 默认走 http://127.0.0.1:8118，不支持原生 SOCKS5 Tor 直连。
  final bool useTor;

  /// 新消息默认自毁时长（秒）
  ///
  /// `null` 表示关闭默认自毁。
  final int? defaultSelfDestructSeconds;

  const PrivacySettings({
    this.avatarVisibility = VisibilityLevel.everyone,
    this.statusVisibility = VisibilityLevel.everyone,
    this.lastSeenVisibility = VisibilityLevel.everyone,
    this.allowStrangerMessage = true,
    this.showReadReceipts = true,
    this.showTypingIndicator = true,
    this.hidePhoneNumber = false,
    this.showLinkPreviews = true,
    this.defaultEncryptNewChats = true,
    this.privateChatMode = false,
    this.protectIpAddress = false,
    this.proxyEnabled = false,
    this.proxyUrl,
    this.useTor = false,
    this.defaultSelfDestructSeconds,
  });

  bool get hasNetworkProxy =>
      useTor ||
      (proxyEnabled && proxyUrl != null && proxyUrl!.trim().isNotEmpty);

  @override
  List<Object?> get props => [
    avatarVisibility,
    statusVisibility,
    lastSeenVisibility,
    allowStrangerMessage,
    showReadReceipts,
    showTypingIndicator,
    hidePhoneNumber,
    showLinkPreviews,
    defaultEncryptNewChats,
    privateChatMode,
    protectIpAddress,
    proxyEnabled,
    proxyUrl,
    useTor,
    defaultSelfDestructSeconds,
  ];

  PrivacySettings copyWith({
    VisibilityLevel? avatarVisibility,
    VisibilityLevel? statusVisibility,
    VisibilityLevel? lastSeenVisibility,
    bool? allowStrangerMessage,
    bool? showReadReceipts,
    bool? showTypingIndicator,
    bool? hidePhoneNumber,
    bool? showLinkPreviews,
    bool? defaultEncryptNewChats,
    bool? privateChatMode,
    bool? protectIpAddress,
    bool? proxyEnabled,
    String? proxyUrl,
    bool? useTor,
    Object? defaultSelfDestructSeconds = _copyWithUndefined,
  }) {
    return PrivacySettings(
      avatarVisibility: avatarVisibility ?? this.avatarVisibility,
      statusVisibility: statusVisibility ?? this.statusVisibility,
      lastSeenVisibility: lastSeenVisibility ?? this.lastSeenVisibility,
      allowStrangerMessage: allowStrangerMessage ?? this.allowStrangerMessage,
      showReadReceipts: showReadReceipts ?? this.showReadReceipts,
      showTypingIndicator: showTypingIndicator ?? this.showTypingIndicator,
      hidePhoneNumber: hidePhoneNumber ?? this.hidePhoneNumber,
      showLinkPreviews: showLinkPreviews ?? this.showLinkPreviews,
      defaultEncryptNewChats:
          defaultEncryptNewChats ?? this.defaultEncryptNewChats,
      privateChatMode: privateChatMode ?? this.privateChatMode,
      protectIpAddress: protectIpAddress ?? this.protectIpAddress,
      proxyEnabled: proxyEnabled ?? this.proxyEnabled,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      useTor: useTor ?? this.useTor,
      defaultSelfDestructSeconds:
          identical(defaultSelfDestructSeconds, _copyWithUndefined)
          ? this.defaultSelfDestructSeconds
          : defaultSelfDestructSeconds as int?,
    );
  }
}

const Object _copyWithUndefined = Object();

/// 可见性级别
enum VisibilityLevel {
  /// 所有人
  everyone,

  /// 仅联系人
  contacts,

  /// 无人
  nobody,
}

/// 外观设置
class AppearanceSettings extends Equatable {
  /// 主题模式
  final ThemeMode themeMode;

  /// 字体大小
  final FontSize fontSize;

  /// 聊天背景
  final String? chatBackground;

  /// 气泡样式
  final BubbleStyle bubbleStyle;

  const AppearanceSettings({
    this.themeMode = ThemeMode.system,
    this.fontSize = FontSize.medium,
    this.chatBackground,
    this.bubbleStyle = BubbleStyle.wechat,
  });

  @override
  List<Object?> get props => [themeMode, fontSize, chatBackground, bubbleStyle];

  AppearanceSettings copyWith({
    ThemeMode? themeMode,
    FontSize? fontSize,
    String? chatBackground,
    BubbleStyle? bubbleStyle,
  }) {
    return AppearanceSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      chatBackground: chatBackground ?? this.chatBackground,
      bubbleStyle: bubbleStyle ?? this.bubbleStyle,
    );
  }
}

/// 主题模式
/// 使用 Flutter 的 ThemeMode，从 material.dart 导入
/// 如需使用，请导入 'package:flutter/material.dart' 并使用 ThemeMode.system/light/dark

/// 字体大小
enum FontSize { small, medium, large, extraLarge }

/// 气泡样式
enum BubbleStyle { wechat, modern, classic }

/// 聊天设置
class ChatSettings extends Equatable {
  /// 自动下载图片
  final bool autoDownloadImage;

  /// 自动下载视频
  final bool autoDownloadVideo;

  /// 自动下载文件
  final bool autoDownloadFile;

  /// WiFi下自动下载
  final bool autoDownloadOnWifi;

  /// 发送消息快捷键
  final SendMessageKey sendMessageKey;

  const ChatSettings({
    this.autoDownloadImage = true,
    this.autoDownloadVideo = false,
    this.autoDownloadFile = false,
    this.autoDownloadOnWifi = true,
    this.sendMessageKey = SendMessageKey.enter,
  });

  @override
  List<Object?> get props => [
    autoDownloadImage,
    autoDownloadVideo,
    autoDownloadFile,
    autoDownloadOnWifi,
    sendMessageKey,
  ];

  ChatSettings copyWith({
    bool? autoDownloadImage,
    bool? autoDownloadVideo,
    bool? autoDownloadFile,
    bool? autoDownloadOnWifi,
    SendMessageKey? sendMessageKey,
  }) {
    return ChatSettings(
      autoDownloadImage: autoDownloadImage ?? this.autoDownloadImage,
      autoDownloadVideo: autoDownloadVideo ?? this.autoDownloadVideo,
      autoDownloadFile: autoDownloadFile ?? this.autoDownloadFile,
      autoDownloadOnWifi: autoDownloadOnWifi ?? this.autoDownloadOnWifi,
      sendMessageKey: sendMessageKey ?? this.sendMessageKey,
    );
  }
}

/// 发送消息快捷键
enum SendMessageKey { enter, ctrlEnter }
