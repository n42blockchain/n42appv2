import 'package:flutter/material.dart';

import 'core/theme/n42_chat_theme.dart';
import 'integration/api_hub_bridge.dart';
import 'integration/wallet_bridge.dart';

const Object _copyWithUndefined = Object();

T? _nullableCopyWithValue<T>(Object? value, T? fallback) {
  if (identical(value, _copyWithUndefined)) {
    return fallback;
  }
  return value as T?;
}

// ─────────────────────────────────────────────────────────────────────────────
// Push Protocol 配置
// ─────────────────────────────────────────────────────────────────────────────

/// Push Protocol 链上事件推送配置
///
/// Push Protocol 是去中心化通知协议（https://push.org），
/// 支持通过钱包地址接收来自各 DApp 频道的链上事件通知。
///
/// ## 示例
/// ```dart
/// N42ChatConfig(
///   pushProtocol: PushProtocolConfig(
///     enabled: true,
///     chainId: 1, // 以太坊主网
///   ),
/// )
/// ```
@immutable
class PushProtocolConfig {
  /// 是否启用链上事件推送
  ///
  /// 默认为 `true`，设置为 `false` 可完全禁用该功能
  final bool enabled;

  /// 链 ID
  ///
  /// - 1: 以太坊主网 (Ethereum Mainnet)
  /// - 137: Polygon Mainnet
  /// - 56: BNB Smart Chain
  /// - 其他 EVM 兼容链 ID
  /// 默认为 1（以太坊主网）
  final int chainId;

  /// 自定义 Push Protocol API 基础地址
  ///
  /// 生产环境: `https://backend.epns.io/apis`（默认）
  /// 测试环境: `https://staging.backend.epns.io/apis`
  final String? apiBaseUrl;

  /// 轮询间隔
  ///
  /// 后台定期拉取新通知的频率。
  /// 过短会增加功耗和 API 请求量，建议不低于 30 秒。
  /// 默认 60 秒。
  final Duration pollInterval;

  const PushProtocolConfig({
    this.enabled = true,
    this.chainId = 1,
    this.apiBaseUrl,
    this.pollInterval = const Duration(minutes: 1),
  });
}

/// N42 Chat 模块配置
///
/// 通过此类配置聊天模块的各种行为和外观
///
/// ## 基本配置
///
/// ```dart
/// N42ChatConfig(
///   defaultHomeserver: 'https://m.si46.world',
///   enableEncryption: true,
/// )
/// ```
///
/// ## 完整配置
///
/// ```dart
/// N42ChatConfig(
///   defaultHomeserver: 'https://your-matrix-server.com',
///   enableEncryption: true,
///   enablePushNotifications: true,
///   customTheme: N42ChatTheme.wechatLight(),
///   walletBridge: MyWalletBridge(),
///   onMessageTap: (roomId, eventId) {
///     // 处理消息点击
///   },
/// )
/// ```
@immutable
class N42ChatConfig {
  /// 默认Matrix服务器地址
  ///
  /// 用户登录时的默认服务器，可以在登录页面修改
  final String defaultHomeserver;

  /// 是否启用端对端加密
  ///
  /// 启用后，新创建的私聊会自动使用E2EE
  /// 默认为 `true`
  final bool enableEncryption;

  /// 是否启用推送通知
  ///
  /// 需要配置FCM/APNs才能生效
  /// 默认为 `true`
  final bool enablePushNotifications;

  /// 推送网关 URL
  ///
  /// Matrix Sygnal 推送网关服务器地址
  /// 用于将推送消息转发到 FCM/APNs
  final String? pushGatewayUrl;

  /// 推送应用标识符
  ///
  /// 用于 Matrix 推送注册
  final String pushAppId;

  /// 同步超时时间
  ///
  /// Matrix长轮询同步的超时时间
  /// 默认为30秒
  final Duration syncTimeout;

  /// 同步过滤器设置
  final SyncFilterConfig syncFilter;

  /// 自定义主题
  ///
  /// 如果不设置，将使用微信风格的默认主题
  final N42ChatTheme? customTheme;

  /// 钱包桥接器
  ///
  /// 提供此接口以启用聊天中的加密货币转账功能
  final IWalletBridge? walletBridge;

  /// API Hub 桥接器
  ///
  /// 提供此接口以启用市场数据、新闻和 URL 安全检测功能
  final IApiHubBridge? apiHubBridge;

  /// 是否显示 Google 登录入口
  final bool enableGoogleLogin;

  /// 是否显示 Apple 登录入口
  final bool enableAppleLogin;

  /// 是否显示 Facebook 登录入口
  final bool enableFacebookLogin;

  /// 是否显示 Twitter 登录入口
  final bool enableTwitterLogin;

  /// 是否显示微信登录入口
  final bool enableWeChatLogin;

  /// 是否显示 SSO 登录入口
  ///
  /// 当前仅应在宿主已经打通浏览器回调流程时启用。
  final bool enableSsoLogin;

  /// Google Sign-In OAuth Client ID
  ///
  /// 宿主已使用 google-services / 原生配置兜底时可不传；
  /// 若未提供原生配置，可通过这里显式注入。
  final String? googleClientId;

  /// Google Sign-In Server Client ID
  ///
  /// 用于后端交换 access token / 验证身份。
  final String? googleServerClientId;

  /// Twitter API Key
  final String? twitterApiKey;

  /// Twitter API Secret
  final String? twitterApiSecret;

  /// Twitter 回调地址
  final String? twitterRedirectUri;

  /// WeChat App ID
  final String? weChatAppId;

  /// WeChat Universal Link
  final String? weChatUniversalLink;

  /// Matrix SSO 浏览器回调地址
  ///
  /// 默认使用 `n42://auth/sso`。
  final String ssoRedirectUrl;

  /// 消息点击回调
  ///
  /// 当用户点击消息时触发
  final void Function(String roomId, String eventId)? onMessageTap;

  /// 头像点击回调
  ///
  /// 当用户点击头像时触发，可用于查看用户资料
  final void Function(String userId)? onAvatarTap;

  /// 外部链接处理
  ///
  /// 当消息中包含链接时的处理方式
  final Future<void> Function(String url)? onLinkTap;

  /// 转账请求回调
  ///
  /// 当用户发起转账请求时触发
  final Future<bool> Function(String toAddress, String amount, String token)?
  onTransferRequest;

  /// 是否显示在线状态
  final bool showPresence;

  /// 是否显示已读回执
  final bool showReadReceipts;

  /// 是否启用消息撤回
  final bool enableMessageDelete;

  /// 消息撤回时限（秒）
  ///
  /// 超过此时间的消息不能撤回
  /// 默认为120秒（2分钟）
  final int messageDeleteTimeout;

  /// 图片最大尺寸（字节）
  ///
  /// 超过此大小的图片会被压缩
  /// 默认为10MB
  final int maxImageSize;

  /// 文件最大尺寸（字节）
  ///
  /// 默认为50MB
  final int maxFileSize;

  /// 语音消息最大时长（秒）
  ///
  /// 默认为60秒
  final int maxVoiceDuration;

  /// 是否启用调试日志
  final bool enableDebugLogs;

  /// 数据库名称
  ///
  /// 支持多账号时，每个账号使用不同的数据库
  final String? databaseName;

  /// Terms of Service URL
  ///
  /// 服务条款页面链接
  final String termsOfServiceUrl;

  /// Privacy Policy URL
  ///
  /// 隐私政策页面链接
  final String privacyPolicyUrl;

  /// Giphy API Key
  ///
  /// 用于直连 Giphy 时的 API Key。
  /// 若启用代理模式，可留空并改由 [proxyAuthToken] 访问服务端代理。
  final String? giphyApiKey;

  /// Giphy API Base URL
  ///
  /// 直连模式默认使用 Giphy 官方地址。
  /// 代理模式下可传入类似 `https://api.n42.ai/proxy/v1/giphy`。
  final String giphyBaseUrl;

  /// 是否将 [giphyBaseUrl] 视为代理端点。
  final bool giphyUseProxyEndpoint;

  /// Google Translate API Key
  ///
  /// 用于消息翻译功能。从 Google Cloud Console 获取
  /// 如果不设置，将使用模拟翻译（仅用于开发测试）
  final String? googleTranslateApiKey;

  /// Google Speech API Key
  ///
  /// 用于直连 Google Speech-to-Text。
  /// 若启用代理模式，可留空并改由 [proxyAuthToken] 访问服务端代理。
  final String? googleSpeechApiKey;

  /// Azure Speech API Key
  ///
  /// 用于直连 Azure Speech Service。
  /// 若启用代理模式，可留空并改由 [proxyAuthToken] 访问服务端代理。
  final String? azureSpeechApiKey;

  /// Azure Speech 区域
  ///
  /// 仅在直连 Azure Speech 时使用。
  final String azureSpeechRegion;

  /// 代理服务访问令牌
  ///
  /// 用于访问受保护的 N42 proxy 路由，不是第三方服务自己的 API key。
  final String? proxyAuthToken;

  /// AI API Key
  ///
  /// 用于 AI 聊天助手、摘要、改写等功能
  /// 支持 OpenAI / Claude / DeepSeek 等兼容 API
  final String? aiApiKey;

  /// AI API Base URL
  ///
  /// AI 服务的 API 基础地址
  /// 默认为 OpenAI: https://api.openai.com
  /// 可切换为其他兼容服务: https://api.deepseek.com 等
  final String aiBaseUrl;

  /// AI 默认模型
  ///
  /// 默认使用的 AI 模型名称
  final String aiModel;

  /// 是否将 [aiBaseUrl] 视为已经可直接 POST 的代理端点。
  ///
  /// 为 `true` 时，AI 数据源不会再自动拼接 `/v1/chat/completions`。
  final bool aiUseProxyEndpoint;

  /// Google Speech 代理端点
  final String? speechGoogleBaseUrl;

  /// Azure Speech 代理端点
  final String? speechAzureBaseUrl;

  /// 是否将 Speech 地址视为代理端点。
  final bool speechUseProxyEndpoint;

  /// Market API 基础地址
  ///
  /// 直连模式默认使用 CoinGecko 公共 API。
  /// 代理模式下可传入类似 `https://api.n42.ai/proxy/v1/market`。
  final String marketBaseUrl;

  /// 是否将 [marketBaseUrl] 视为代理端点。
  final bool marketUseProxyEndpoint;

  /// 存储管理配置
  final StorageManagementConfig storageManagement;

  /// Push Protocol 链上事件推送配置
  ///
  /// 为 null 时禁用链上事件推送功能。
  /// 传入 [PushProtocolConfig] 实例以启用。
  final PushProtocolConfig? pushProtocol;

  /// 是否与所有设备（含未验证）共享 E2EE 密钥
  ///
  /// - `true`（默认）：向所有未被阻止的设备分享 Megolm 会话密钥，
  ///   避免"The sender has not sent us the session key"错误，兼容性最好。
  /// - `false`：仅与已完成交叉验证的设备共享密钥，安全性更高，
  ///   适用于安全敏感部署，但未验证设备无法解密历史消息。
  final bool shareE2eeKeysWithAllDevices;

  // ─────────────────────────────────────────────────────────────────────────────
  // P2 功能配置
  // ─────────────────────────────────────────────────────────────────────────────

  /// 是否启用协议抽象层 (P2.1)
  ///
  /// 启用后，通过 [ProtocolRegistry] 管理多协议注册/切换，
  /// 为未来接入 XMTP、Waku 等去中心化协议做准备。
  final bool enableProtocolAbstraction;

  /// 是否启用 DAO 治理投票 (P2.2)
  ///
  /// 启用后，群组可绑定 Snapshot Space，支持创建提案、投票、查看结果。
  final bool enableGovernance;

  /// Snapshot Hub URL (P2.2)
  ///
  /// Snapshot Hub API 地址，用于提交签名投票/提案。
  /// 默认: `https://hub.snapshot.org`
  final String? snapshotHubUrl;

  /// 是否启用链上社交图谱 (P2.3)
  ///
  /// 启用后，根据链上数据（代币持仓、NFT 收藏、链使用）
  /// 推荐相似用户和社交关系。
  final bool enableSocialGraph;

  /// DeBank Open API Key (P2.3)
  ///
  /// 用于直连查询用户链上持仓和资产数据。
  /// 若启用代理模式，可留空并改由 [proxyAuthToken] 访问服务端代理。
  final String? debankApiKey;

  /// DeBank API 基础地址
  ///
  /// 直连模式默认使用 DeBank 官方地址。
  /// 代理模式下可传入类似 `https://api.n42.ai/proxy/v1/debank`。
  final String debankBaseUrl;

  /// 是否将 [debankBaseUrl] 视为代理端点。
  final bool debankUseProxyEndpoint;

  /// Alchemy API Key (P2.3)
  ///
  /// 用于直连查询 NFT 持仓和 Token 余额。
  /// 若启用代理模式，可留空并改由 [proxyAuthToken] 访问服务端代理。
  final String? alchemyApiKey;

  /// Alchemy API 基础地址
  ///
  /// 直连模式默认使用官方 `eth-mainnet` 端点。
  /// 代理模式下可传入类似 `https://api.n42.ai/proxy/v1/alchemy/eth-mainnet`。
  final String alchemyBaseUrl;

  /// 是否将 [alchemyBaseUrl] 视为代理端点。
  final bool alchemyUseProxyEndpoint;

  /// 是否启用积分经济 (P2.4)
  ///
  /// 启用后，群组内可配置积分系统，激励活跃参与和高质量内容。
  final bool enablePoints;

  /// 积分 API 基础地址 (P2.4)
  ///
  /// N42 后端积分服务的 REST API 地址。
  /// 例如: `https://api.n42.world`
  final String? pointsApiBaseUrl;

  const N42ChatConfig({
    this.defaultHomeserver = 'https://m.si46.world',
    this.enableEncryption = true,
    this.enablePushNotifications = true,
    this.pushGatewayUrl,
    this.pushAppId = 'com.n42.chat',
    this.syncTimeout = const Duration(seconds: 30),
    this.syncFilter = const SyncFilterConfig(),
    this.customTheme,
    this.walletBridge,
    this.apiHubBridge,
    this.enableGoogleLogin = true,
    this.enableAppleLogin = true,
    this.enableFacebookLogin = false,
    this.enableTwitterLogin = false,
    this.enableWeChatLogin = false,
    this.enableSsoLogin = false,
    this.googleClientId,
    this.googleServerClientId,
    this.twitterApiKey,
    this.twitterApiSecret,
    this.twitterRedirectUri,
    this.weChatAppId,
    this.weChatUniversalLink,
    this.ssoRedirectUrl = 'n42://auth/sso',
    this.onMessageTap,
    this.onAvatarTap,
    this.onLinkTap,
    this.onTransferRequest,
    this.showPresence = true,
    this.showReadReceipts = true,
    this.enableMessageDelete = true,
    this.messageDeleteTimeout = 120,
    this.maxImageSize = 10 * 1024 * 1024, // 10MB
    this.maxFileSize = 50 * 1024 * 1024, // 50MB
    this.maxVoiceDuration = 60,
    this.enableDebugLogs = false,
    this.databaseName,
    this.termsOfServiceUrl = 'https://n42.world/terms',
    this.privacyPolicyUrl = 'https://n42.world/privacy',
    this.giphyApiKey,
    this.giphyBaseUrl = 'https://api.giphy.com/v1/gifs',
    this.giphyUseProxyEndpoint = false,
    this.googleTranslateApiKey,
    this.googleSpeechApiKey,
    this.azureSpeechApiKey,
    this.azureSpeechRegion = 'eastus',
    this.proxyAuthToken,
    this.aiApiKey,
    this.aiBaseUrl = 'https://api.openai.com',
    this.aiModel = 'gpt-4o-mini',
    this.aiUseProxyEndpoint = false,
    this.speechGoogleBaseUrl,
    this.speechAzureBaseUrl,
    this.speechUseProxyEndpoint = false,
    this.marketBaseUrl = 'https://api.coingecko.com/api/v3',
    this.marketUseProxyEndpoint = false,
    this.storageManagement = const StorageManagementConfig(),
    this.pushProtocol,
    this.shareE2eeKeysWithAllDevices = true,
    this.enableProtocolAbstraction = false,
    this.enableGovernance = false,
    this.snapshotHubUrl,
    this.enableSocialGraph = false,
    this.debankApiKey,
    this.debankBaseUrl = 'https://open-api.debank.com/v1',
    this.debankUseProxyEndpoint = false,
    this.alchemyApiKey,
    this.alchemyBaseUrl = 'https://eth-mainnet.g.alchemy.com/v2',
    this.alchemyUseProxyEndpoint = false,
    this.enablePoints = false,
    this.pointsApiBaseUrl,
  });

  /// 复制并修改配置
  N42ChatConfig copyWith({
    String? defaultHomeserver,
    bool? enableEncryption,
    bool? enablePushNotifications,
    Object? pushGatewayUrl = _copyWithUndefined,
    String? pushAppId,
    Duration? syncTimeout,
    SyncFilterConfig? syncFilter,
    Object? customTheme = _copyWithUndefined,
    Object? walletBridge = _copyWithUndefined,
    Object? apiHubBridge = _copyWithUndefined,
    bool? enableGoogleLogin,
    bool? enableAppleLogin,
    bool? enableFacebookLogin,
    bool? enableTwitterLogin,
    bool? enableWeChatLogin,
    bool? enableSsoLogin,
    Object? googleClientId = _copyWithUndefined,
    Object? googleServerClientId = _copyWithUndefined,
    Object? twitterApiKey = _copyWithUndefined,
    Object? twitterApiSecret = _copyWithUndefined,
    Object? twitterRedirectUri = _copyWithUndefined,
    Object? weChatAppId = _copyWithUndefined,
    Object? weChatUniversalLink = _copyWithUndefined,
    String? ssoRedirectUrl,
    Object? onMessageTap = _copyWithUndefined,
    Object? onAvatarTap = _copyWithUndefined,
    Object? onLinkTap = _copyWithUndefined,
    Object? onTransferRequest = _copyWithUndefined,
    bool? showPresence,
    bool? showReadReceipts,
    bool? enableMessageDelete,
    int? messageDeleteTimeout,
    int? maxImageSize,
    int? maxFileSize,
    int? maxVoiceDuration,
    bool? enableDebugLogs,
    Object? databaseName = _copyWithUndefined,
    String? termsOfServiceUrl,
    String? privacyPolicyUrl,
    Object? giphyApiKey = _copyWithUndefined,
    String? giphyBaseUrl,
    bool? giphyUseProxyEndpoint,
    Object? googleTranslateApiKey = _copyWithUndefined,
    Object? googleSpeechApiKey = _copyWithUndefined,
    Object? azureSpeechApiKey = _copyWithUndefined,
    String? azureSpeechRegion,
    Object? proxyAuthToken = _copyWithUndefined,
    Object? aiApiKey = _copyWithUndefined,
    String? aiBaseUrl,
    String? aiModel,
    bool? aiUseProxyEndpoint,
    Object? speechGoogleBaseUrl = _copyWithUndefined,
    Object? speechAzureBaseUrl = _copyWithUndefined,
    bool? speechUseProxyEndpoint,
    String? marketBaseUrl,
    bool? marketUseProxyEndpoint,
    StorageManagementConfig? storageManagement,
    Object? pushProtocol = _copyWithUndefined,
    bool? shareE2eeKeysWithAllDevices,
    bool? enableProtocolAbstraction,
    bool? enableGovernance,
    Object? snapshotHubUrl = _copyWithUndefined,
    bool? enableSocialGraph,
    Object? debankApiKey = _copyWithUndefined,
    String? debankBaseUrl,
    bool? debankUseProxyEndpoint,
    Object? alchemyApiKey = _copyWithUndefined,
    String? alchemyBaseUrl,
    bool? alchemyUseProxyEndpoint,
    bool? enablePoints,
    Object? pointsApiBaseUrl = _copyWithUndefined,
  }) {
    return N42ChatConfig(
      defaultHomeserver: defaultHomeserver ?? this.defaultHomeserver,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      pushGatewayUrl: _nullableCopyWithValue<String>(
        pushGatewayUrl,
        this.pushGatewayUrl,
      ),
      pushAppId: pushAppId ?? this.pushAppId,
      syncTimeout: syncTimeout ?? this.syncTimeout,
      syncFilter: syncFilter ?? this.syncFilter,
      customTheme: _nullableCopyWithValue<N42ChatTheme>(
        customTheme,
        this.customTheme,
      ),
      walletBridge: _nullableCopyWithValue<IWalletBridge>(
        walletBridge,
        this.walletBridge,
      ),
      apiHubBridge: _nullableCopyWithValue<IApiHubBridge>(
        apiHubBridge,
        this.apiHubBridge,
      ),
      enableGoogleLogin: enableGoogleLogin ?? this.enableGoogleLogin,
      enableAppleLogin: enableAppleLogin ?? this.enableAppleLogin,
      enableFacebookLogin: enableFacebookLogin ?? this.enableFacebookLogin,
      enableTwitterLogin: enableTwitterLogin ?? this.enableTwitterLogin,
      enableWeChatLogin: enableWeChatLogin ?? this.enableWeChatLogin,
      enableSsoLogin: enableSsoLogin ?? this.enableSsoLogin,
      googleClientId: _nullableCopyWithValue<String>(
        googleClientId,
        this.googleClientId,
      ),
      googleServerClientId: _nullableCopyWithValue<String>(
        googleServerClientId,
        this.googleServerClientId,
      ),
      twitterApiKey: _nullableCopyWithValue<String>(
        twitterApiKey,
        this.twitterApiKey,
      ),
      twitterApiSecret: _nullableCopyWithValue<String>(
        twitterApiSecret,
        this.twitterApiSecret,
      ),
      twitterRedirectUri: _nullableCopyWithValue<String>(
        twitterRedirectUri,
        this.twitterRedirectUri,
      ),
      weChatAppId: _nullableCopyWithValue<String>(
        weChatAppId,
        this.weChatAppId,
      ),
      weChatUniversalLink: _nullableCopyWithValue<String>(
        weChatUniversalLink,
        this.weChatUniversalLink,
      ),
      ssoRedirectUrl: ssoRedirectUrl ?? this.ssoRedirectUrl,
      onMessageTap:
          _nullableCopyWithValue<void Function(String roomId, String eventId)>(
            onMessageTap,
            this.onMessageTap,
          ),
      onAvatarTap: _nullableCopyWithValue<void Function(String userId)>(
        onAvatarTap,
        this.onAvatarTap,
      ),
      onLinkTap: _nullableCopyWithValue<Future<void> Function(String url)>(
        onLinkTap,
        this.onLinkTap,
      ),
      onTransferRequest:
          _nullableCopyWithValue<Future<bool> Function(String, String, String)>(
            onTransferRequest,
            this.onTransferRequest,
          ),
      showPresence: showPresence ?? this.showPresence,
      showReadReceipts: showReadReceipts ?? this.showReadReceipts,
      enableMessageDelete: enableMessageDelete ?? this.enableMessageDelete,
      messageDeleteTimeout: messageDeleteTimeout ?? this.messageDeleteTimeout,
      maxImageSize: maxImageSize ?? this.maxImageSize,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      maxVoiceDuration: maxVoiceDuration ?? this.maxVoiceDuration,
      enableDebugLogs: enableDebugLogs ?? this.enableDebugLogs,
      databaseName: _nullableCopyWithValue<String>(
        databaseName,
        this.databaseName,
      ),
      termsOfServiceUrl: termsOfServiceUrl ?? this.termsOfServiceUrl,
      privacyPolicyUrl: privacyPolicyUrl ?? this.privacyPolicyUrl,
      giphyApiKey: _nullableCopyWithValue<String>(
        giphyApiKey,
        this.giphyApiKey,
      ),
      giphyBaseUrl: giphyBaseUrl ?? this.giphyBaseUrl,
      giphyUseProxyEndpoint:
          giphyUseProxyEndpoint ?? this.giphyUseProxyEndpoint,
      googleTranslateApiKey: _nullableCopyWithValue<String>(
        googleTranslateApiKey,
        this.googleTranslateApiKey,
      ),
      googleSpeechApiKey: _nullableCopyWithValue<String>(
        googleSpeechApiKey,
        this.googleSpeechApiKey,
      ),
      azureSpeechApiKey: _nullableCopyWithValue<String>(
        azureSpeechApiKey,
        this.azureSpeechApiKey,
      ),
      azureSpeechRegion: azureSpeechRegion ?? this.azureSpeechRegion,
      proxyAuthToken: _nullableCopyWithValue<String>(
        proxyAuthToken,
        this.proxyAuthToken,
      ),
      aiApiKey: _nullableCopyWithValue<String>(aiApiKey, this.aiApiKey),
      aiBaseUrl: aiBaseUrl ?? this.aiBaseUrl,
      aiModel: aiModel ?? this.aiModel,
      aiUseProxyEndpoint: aiUseProxyEndpoint ?? this.aiUseProxyEndpoint,
      speechGoogleBaseUrl: _nullableCopyWithValue<String>(
        speechGoogleBaseUrl,
        this.speechGoogleBaseUrl,
      ),
      speechAzureBaseUrl: _nullableCopyWithValue<String>(
        speechAzureBaseUrl,
        this.speechAzureBaseUrl,
      ),
      speechUseProxyEndpoint:
          speechUseProxyEndpoint ?? this.speechUseProxyEndpoint,
      marketBaseUrl: marketBaseUrl ?? this.marketBaseUrl,
      marketUseProxyEndpoint:
          marketUseProxyEndpoint ?? this.marketUseProxyEndpoint,
      storageManagement: storageManagement ?? this.storageManagement,
      pushProtocol: _nullableCopyWithValue<PushProtocolConfig>(
        pushProtocol,
        this.pushProtocol,
      ),
      shareE2eeKeysWithAllDevices:
          shareE2eeKeysWithAllDevices ?? this.shareE2eeKeysWithAllDevices,
      enableProtocolAbstraction:
          enableProtocolAbstraction ?? this.enableProtocolAbstraction,
      enableGovernance: enableGovernance ?? this.enableGovernance,
      snapshotHubUrl: _nullableCopyWithValue<String>(
        snapshotHubUrl,
        this.snapshotHubUrl,
      ),
      enableSocialGraph: enableSocialGraph ?? this.enableSocialGraph,
      debankApiKey: _nullableCopyWithValue<String>(
        debankApiKey,
        this.debankApiKey,
      ),
      debankBaseUrl: debankBaseUrl ?? this.debankBaseUrl,
      debankUseProxyEndpoint:
          debankUseProxyEndpoint ?? this.debankUseProxyEndpoint,
      alchemyApiKey: _nullableCopyWithValue<String>(
        alchemyApiKey,
        this.alchemyApiKey,
      ),
      alchemyBaseUrl: alchemyBaseUrl ?? this.alchemyBaseUrl,
      alchemyUseProxyEndpoint:
          alchemyUseProxyEndpoint ?? this.alchemyUseProxyEndpoint,
      enablePoints: enablePoints ?? this.enablePoints,
      pointsApiBaseUrl: _nullableCopyWithValue<String>(
        pointsApiBaseUrl,
        this.pointsApiBaseUrl,
      ),
    );
  }
}

/// 存储管理配置
@immutable
class StorageManagementConfig {
  /// 自动清理天数（超过此天数未访问的媒体可被自动清理）
  final int autoCleanupDays;

  /// 存储预警阈值 (MB)
  final int warningThresholdMB;

  /// 存储严重阈值 (MB)
  final int criticalThresholdMB;

  /// 热数据天数
  final int hotDataDays;

  /// 暖数据天数
  final int warmDataDays;

  /// 是否启用自动清理
  final bool autoCleanupEnabled;

  /// 是否保留缩略图
  final bool preserveThumbnails;

  const StorageManagementConfig({
    this.autoCleanupDays = 90,
    this.warningThresholdMB = 500,
    this.criticalThresholdMB = 1000,
    this.hotDataDays = 30,
    this.warmDataDays = 180,
    this.autoCleanupEnabled = false,
    this.preserveThumbnails = true,
  });
}

/// 同步过滤器配置
@immutable
class SyncFilterConfig {
  /// 每个房间加载的时间线消息数量
  final int timelineLimit;

  /// 是否包含离开的房间
  final bool includeLeaveRooms;

  /// 是否懒加载成员列表
  final bool lazyLoadMembers;

  const SyncFilterConfig({
    this.timelineLimit = 20,
    this.includeLeaveRooms = false,
    this.lazyLoadMembers = true,
  });
}
