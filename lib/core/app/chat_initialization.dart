// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/core/platform/chat_social_auth_config.dart';
import 'package:n42_wallet/core/platform/social_auth_native_config.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/platform/deep_link_service.dart';
import 'package:n42_wallet/core/routing/chat_sso_utils.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/live/presentation/pages/live_app.dart';
import 'package:n42_wallet/features/utils/app_push_utils.dart';
import 'package:n42_wallet/features/utils/chat_logout_compat.dart';
import 'package:n42_wallet/features/wallet/n42_api_hub_bridge.dart';
import 'package:n42_wallet/features/wallet/n42_wallet_bridge.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_chat/n42_chat.dart';

/// Mixin that handles N42Chat initialization, deep link routing,
/// and auth status synchronization for the main app widget.
mixin ChatInitializationMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  StreamSubscription? _chatAuthSubscription;
  StreamSubscription? _chatUserSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  DeepLinkData? _pendingChatDeepLink;
  DeepLinkData? _pendingChatSsoDeepLink;
  AuthStatus? _lastChatAuthStatus;
  bool _localeListenerRegistered = false;

  /// Initialize N42Chat module (runs in background, does not block UI).
  Future<void> initN42Chat() async {
    try {
      await purgePendingCancelledChatDataCompat();

      const envChatGoogleClientId = String.fromEnvironment(
        'N42_CHAT_GOOGLE_CLIENT_ID',
      );
      const envChatGoogleServerClientId = String.fromEnvironment(
        'N42_CHAT_GOOGLE_SERVER_CLIENT_ID',
      );
      const envChatTwitterApiKey = String.fromEnvironment(
        'N42_CHAT_TWITTER_API_KEY',
      );
      const envChatTwitterApiSecret = String.fromEnvironment(
        'N42_CHAT_TWITTER_API_SECRET',
      );
      const envChatTwitterRedirectUri = String.fromEnvironment(
        'N42_CHAT_TWITTER_REDIRECT_URI',
      );
      const envChatWeChatAppId = String.fromEnvironment(
        'N42_CHAT_WECHAT_APP_ID',
      );
      const envChatWeChatUniversalLink = String.fromEnvironment(
        'N42_CHAT_WECHAT_UNIVERSAL_LINK',
      );
      // 增量三家（Discord/GitHub/Telegram）——走自建 backend/social-auth。
      // 三者均需 SOCIAL_AUTH_BASE_URL 指向部署地址才生效。
      const envChatDiscordClientId = String.fromEnvironment(
        'N42_CHAT_DISCORD_CLIENT_ID',
      );
      const envChatGithubClientId = String.fromEnvironment(
        'N42_CHAT_GITHUB_CLIENT_ID',
      );
      const envChatTelegramBotId = String.fromEnvironment(
        'N42_CHAT_TELEGRAM_BOT_ID',
      );
      const envChatSocialAuthBaseUrl = String.fromEnvironment(
        'N42_CHAT_SOCIAL_AUTH_BASE_URL',
      );
      const envGoogleTranslateApiKey = String.fromEnvironment(
        'GOOGLE_TRANSLATE_API_KEY',
      );
      const envGoogleSpeechApiKey = String.fromEnvironment(
        'GOOGLE_SPEECH_API_KEY',
      );
      const envAzureSpeechApiKey = String.fromEnvironment(
        'AZURE_SPEECH_API_KEY',
      );
      const envAzureSpeechRegion = String.fromEnvironment(
        'AZURE_SPEECH_REGION',
        defaultValue: 'eastus',
      );
      const envGiphyApiKey = String.fromEnvironment('GIPHY_API_KEY');
      const envTenorApiKey = String.fromEnvironment('TENOR_API_KEY');
      const envFiatRampApiKey = String.fromEnvironment('FIATRAMP_API_KEY');
      const envAiApiKey = String.fromEnvironment('AI_API_KEY');
      const envAiBaseUrl = String.fromEnvironment(
        'AI_BASE_URL',
        defaultValue: 'https://api.groq.com/openai',
      );
      const envAiModel = String.fromEnvironment(
        'AI_MODEL',
        defaultValue: 'llama-3.3-70b-versatile',
      );
      const envDebankApiKey = String.fromEnvironment('DEBANK_API_KEY');
      const envAlchemyApiKey = String.fromEnvironment('ALCHEMY_API_KEY');
      // 端侧 LLM（Gemma）模型源——不配则端侧推理不可用、AI 自动回退云端。
      const envLocalLlmModelUrl = String.fromEnvironment('LOCAL_LLM_MODEL_URL');
      const envLocalLlmHfToken = String.fromEnvironment('LOCAL_LLM_HF_TOKEN');
      const envIdHubUrl = String.fromEnvironment('ID_HUB_URL');
      final nativeSocialAuthConfig = await SocialAuthNativeConfig.load();
      final chatSocialAuthConfig = ChatSocialAuthConfig.resolve(
        nativeConfig: nativeSocialAuthConfig,
        envGoogleClientId: envChatGoogleClientId,
        envGoogleServerClientId: envChatGoogleServerClientId,
        envTwitterApiKey: envChatTwitterApiKey,
        envTwitterApiSecret: envChatTwitterApiSecret,
        envTwitterRedirectUri: envChatTwitterRedirectUri,
        envWeChatAppId: envChatWeChatAppId,
        envWeChatUniversalLink: envChatWeChatUniversalLink,
        envDiscordClientId: envChatDiscordClientId,
        envGithubClientId: envChatGithubClientId,
        envTelegramBotId: envChatTelegramBotId,
        envSocialAuthBaseUrl: envChatSocialAuthBaseUrl,
      );
      String? normalizedEnv(String value) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return null;
        return trimmed;
      }

      final proxyAuthToken = normalizedEnv(ProxyConfig.authToken);
      final directGoogleTranslateApiKey = normalizedEnv(
        envGoogleTranslateApiKey,
      );
      final directGoogleSpeechApiKey = normalizedEnv(envGoogleSpeechApiKey);
      final directAzureSpeechApiKey = normalizedEnv(envAzureSpeechApiKey);
      final directGiphyApiKey = normalizedEnv(envGiphyApiKey);
      final directTenorApiKey = normalizedEnv(envTenorApiKey);
      final directFiatRampApiKey = normalizedEnv(envFiatRampApiKey);
      final directAiApiKey = normalizedEnv(envAiApiKey);
      final directDebankApiKey = normalizedEnv(envDebankApiKey);
      final directAlchemyApiKey = normalizedEnv(envAlchemyApiKey);
      final directLocalLlmModelUrl = normalizedEnv(envLocalLlmModelUrl);
      final directLocalLlmHfToken = normalizedEnv(envLocalLlmHfToken);
      final idHubUrl = normalizedEnv(envIdHubUrl);

      for (final line in chatSocialAuthConfig.diagnostics(
        isAndroid: Platform.isAndroid,
        isIOS: Platform.isIOS,
        isMacOS: Platform.isMacOS,
      )) {
        AppLogger.d('N42Chat', line);
      }

      final String pushAppId;
      if (Platform.isAndroid) {
        pushAppId = 'ai.n42.www.android';
      } else if (Platform.isIOS) {
        pushAppId = 'ai.n42.www.ios';
      } else {
        pushAppId = 'ai.n42.www.web';
      }

      N42Chat.setNavigatorKey(AppGlobals.navigatorKey);
      N42Chat.setNotificationTapHandler((roomId, eventId) {
        AppPushUtils.recordHandledChatNotificationTap(
          roomId: roomId,
          eventId: eventId,
        );
        AppLogger.d(
          'N42Chat',
          'notification tapped: roomId=$roomId, eventId=$eventId',
        );
      });

      await N42Chat.initialize(
        N42ChatConfig(
          defaultHomeserver: 'https://m.si46.world',
          enableEncryption: true,
          enablePushNotifications: true,
          pushGatewayUrl: 'https://m.si46.world/_matrix/push/v1/notify',
          pushAppId: pushAppId,
          enableGoogleLogin: chatSocialAuthConfig
              .supportsGoogleForCurrentPlatform(
                isAndroid: Platform.isAndroid,
                isIOS: Platform.isIOS,
                isMacOS: Platform.isMacOS,
              ),
          enableAppleLogin: Platform.isIOS || Platform.isMacOS,
          enableFacebookLogin: Platform.isAndroid,
          enableTwitterLogin: chatSocialAuthConfig.twitterConfigured,
          enableWeChatLogin: chatSocialAuthConfig.weChatConfigured,
          enableDiscordLogin: chatSocialAuthConfig.discordConfigured,
          enableGithubLogin: chatSocialAuthConfig.githubConfigured,
          enableTelegramLogin: chatSocialAuthConfig.telegramConfigured,
          enableSsoLogin: true,
          idHubUrl: idHubUrl,
          enableIdHubLogin: idHubUrl != null,
          googleClientId: chatSocialAuthConfig.googleClientId.isEmpty
              ? null
              : chatSocialAuthConfig.googleClientId,
          googleServerClientId:
              chatSocialAuthConfig.googleServerClientId.isEmpty
              ? null
              : chatSocialAuthConfig.googleServerClientId,
          twitterApiKey: chatSocialAuthConfig.twitterApiKey.isEmpty
              ? null
              : chatSocialAuthConfig.twitterApiKey,
          twitterApiSecret: chatSocialAuthConfig.twitterApiSecret.isEmpty
              ? null
              : chatSocialAuthConfig.twitterApiSecret,
          twitterRedirectUri: chatSocialAuthConfig.twitterConfigured
              ? chatSocialAuthConfig.twitterRedirectUri
              : null,
          weChatAppId: chatSocialAuthConfig.weChatAppId.isEmpty
              ? null
              : chatSocialAuthConfig.weChatAppId,
          weChatUniversalLink: chatSocialAuthConfig.weChatUniversalLink.isEmpty
              ? null
              : chatSocialAuthConfig.weChatUniversalLink,
          discordClientId: chatSocialAuthConfig.discordClientId.isEmpty
              ? null
              : chatSocialAuthConfig.discordClientId,
          githubClientId: chatSocialAuthConfig.githubClientId.isEmpty
              ? null
              : chatSocialAuthConfig.githubClientId,
          telegramBotId: chatSocialAuthConfig.telegramBotId.isEmpty
              ? null
              : chatSocialAuthConfig.telegramBotId,
          socialAuthBaseUrl: chatSocialAuthConfig.socialAuthBaseUrl.isEmpty
              ? null
              : chatSocialAuthConfig.socialAuthBaseUrl,
          // 不能使用通用 n42://：若设备同时装有旧版/11X，系统会把 SSO
          // 回调交给错误的 app。该 scheme 只由当前钱包注册。
          ssoRedirectUrl: 'n42wallet://auth/sso',
          walletBridge: N42WalletBridge(),
          apiHubBridge: N42ApiHubBridge(),
          // 链上事件通知（Push Protocol，公开只读 REST，只需钱包地址、无 key）。
          // 会话列表页的通知铃铛入口一直在，但此前宿主从未传 pushProtocol，
          // 导致 OnChainNotificationBloc 从不注册——铃铛的 BlocBuilder 解析
          // 会抛异常。启用后 datasource/repository/bloc 完整注册，铃铛可用。
          pushProtocol: const PushProtocolConfig(enabled: true, chainId: 1),
          proxyAuthToken: proxyAuthToken,
          giphyApiKey: directGiphyApiKey,
          giphyBaseUrl: 'https://api.giphy.com/v1/gifs',
          giphyUseProxyEndpoint: false,
          tenorApiKey: directTenorApiKey,
          tenorBaseUrl: 'https://tenor.googleapis.com/v2',
          tenorUseProxyEndpoint: false,
          fiatRampApiKey: directFiatRampApiKey,
          fiatRampProvider: 'moonpay',
          googleTranslateApiKey: directGoogleTranslateApiKey,
          aiApiKey: directAiApiKey,
          aiBaseUrl: envAiBaseUrl,
          aiModel: envAiModel,
          aiUseProxyEndpoint: false,
          localLlmModelUrl: directLocalLlmModelUrl,
          localLlmHuggingFaceToken: directLocalLlmHfToken,
          googleSpeechApiKey: directGoogleSpeechApiKey,
          azureSpeechApiKey: directAzureSpeechApiKey,
          azureSpeechRegion: envAzureSpeechRegion,
          speechGoogleBaseUrl: null,
          speechAzureBaseUrl: null,
          speechUseProxyEndpoint: false,
          marketBaseUrl: 'https://api.coingecko.com/api/v3',
          marketUseProxyEndpoint: false,
          debankApiKey: directDebankApiKey,
          debankBaseUrl: 'https://open-api.debank.com/v1',
          debankUseProxyEndpoint: false,
          alchemyApiKey: directAlchemyApiKey,
          alchemyBaseUrl: 'https://eth-mainnet.g.alchemy.com/v2',
          alchemyUseProxyEndpoint: false,
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          AppLogger.w('N42Chat', 'Initialization timed out after 15s');
          throw TimeoutException(
            'N42Chat.initialize',
            const Duration(seconds: 15),
          );
        },
      );
      await flushPendingChatDeepLink();
      await flushPendingChatSsoDeepLink();
      await AppPushUtils.flushPendingChatNotification();

      // 宿主接管 chat 外观（明暗模式）：chat 不再用自身存储值覆盖宿主下发，
      // 明暗模式以宿主设置页为唯一来源。必须在 setThemeMode 之前置位。
      N42Chat.hostControlsAppearance = true;
      final currentTheme = globalProviderContainer.read(themeModeProvider);
      N42Chat.setThemeMode(currentTheme);

      final currentLocale = globalProviderContainer.read(localeProvider);
      N42Chat.setLocale(currentLocale);

      if (!_localeListenerRegistered) {
        _localeListenerRegistered = true;
        N42Chat.addLocaleListener((locale) {
          final currentAppLocale = globalProviderContainer.read(localeProvider);
          if (languageCodeFromLocale(currentAppLocale) !=
              languageCodeFromLocale(locale)) {
            globalProviderContainer
                .read(localeProvider.notifier)
                .setLocale(languageCodeFromLocale(locale));
            AppLogger.d('N42Chat', 'Main app locale synced: $locale');
          }
        });
      }

      _unreadCountSubscription = N42Chat.unreadCountStream.listen((count) {
        globalProviderContainer
            .read(unreadCountProvider.notifier)
            .setCount(count);
        AppLogger.d('N42Chat', 'unread count updated: $count');
      });
      _chatUserSubscription?.cancel();
      _chatUserSubscription = N42Chat.userStream.listen((_) {
        unawaited(flushPendingChatDeepLink());
        unawaited(flushPendingChatSsoDeepLink());
        unawaited(AppPushUtils.flushPendingChatNotification());
      });
      _lastChatAuthStatus = N42Chat.authStatus;
      syncHostWithChatAuthStatus(_lastChatAuthStatus);
      _chatAuthSubscription?.cancel();
      _chatAuthSubscription = N42Chat.authStatusStream.listen((status) {
        final previousStatus = _lastChatAuthStatus;
        _lastChatAuthStatus = status;
        syncHostWithChatAuthStatus(status, previousStatus: previousStatus);
      });

      void switchToWalletTab() {
        final ctx = AppGlobals.navigatorKey.currentContext;
        if (ctx != null) {
          Navigator.of(ctx).popUntil((r) => r.isFirst);
        }
        globalProviderContainer.read(homeTabIndexProvider.notifier).state = 0;
      }

      // 宿主侧 Wallet / Card Pack 入口：chat ServicesPage 点击后
      // 弹回主 app 并切到 wallet tab（index 0）。卡包暂未实装，
      // 同样指向 wallet tab 作为最接近的入口。
      N42Chat.setBackToHostHandler(switchToWalletTab);
      N42Chat.setOpenWalletHandler(switchToWalletTab);
      N42Chat.setOpenCardPackHandler(switchToWalletTab);
      // 发现页「直播」入口 → 宿主的视频直播（复用 chat 的 Matrix 房间 +
      // 自部署 LiveKit）。未注册时发现页回退到语音房列表。
      N42Chat.setLiveEntryHandler((ctx) {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute<void>(builder: (_) => const LiveApp()));
      });

      AppLogger.i(
        'N42Chat',
        'initialized successfully with theme: $currentTheme',
      );
    } catch (e, s) {
      AppLogger.e('N42Chat', 'initialization failed', error: e, stackTrace: s);
    }
  }

  bool get isChatSessionReady => N42Chat.isInitialized && N42Chat.isLoggedIn;

  bool isChatDeepLink(DeepLinkType type) {
    return type == DeepLinkType.chat ||
        type == DeepLinkType.user ||
        type == DeepLinkType.group ||
        type == DeepLinkType.friendCard;
  }

  Future<void> routeChatSsoDeepLink(DeepLinkData data) async {
    if (!N42Chat.isInitialized) {
      _pendingChatSsoDeepLink = data;
      AppLogger.d(
        'ChatSso',
        'queued deep link until N42Chat initializes: $data',
      );
      return;
    }

    final loginToken =
        data.params['loginToken'] ??
        data.params['login_token'] ??
        data.params['token'] ??
        '';
    if (loginToken.isEmpty) {
      AppLogger.w(
        'ChatSso',
        'callback missing login token: ${data.sanitizedUri}',
      );
      return;
    }

    final homeserver = normalizeChatSsoHomeserver(
      data.params['homeserver'],
      fallbackHomeserver: N42Chat.config?.defaultHomeserver,
    );
    if (homeserver == null || homeserver.isEmpty) {
      AppLogger.w(
        'ChatSso',
        'callback missing or invalid homeserver: ${data.sanitizedUri}',
      );
      return;
    }

    try {
      await N42Chat.loginWithLoginToken(
        homeserver: homeserver,
        loginToken: loginToken,
      );
    } catch (e, s) {
      AppLogger.e(
        'ChatSso',
        'failed to complete login',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> openChatEntry(BuildContext navContext) async {
    if (!mounted) return;
    await Navigator.of(
      navContext,
    ).push(MaterialPageRoute(builder: (_) => N42Chat.chatWidget()));
  }

  Future<void> openChatConversation(
    BuildContext navContext,
    String roomId,
  ) async {
    if (!isChatSessionReady) {
      await openChatEntry(navContext);
      return;
    }

    try {
      await N42Chat.openConversation(roomId, context: navContext);
    } catch (e, s) {
      AppLogger.e(
        'ChatDeepLink',
        'failed to open conversation $roomId',
        error: e,
        stackTrace: s,
      );
      if (!mounted || !navContext.mounted) return;
      await openChatEntry(navContext);
    }
  }

  Future<void> openDirectMessage(BuildContext navContext, String userId) async {
    if (!isChatSessionReady) {
      await openChatEntry(navContext);
      return;
    }

    try {
      final roomId = await N42Chat.createDirectMessage(userId);
      if (!mounted || !navContext.mounted) return;
      await N42Chat.openConversation(roomId, context: navContext);
    } catch (e, s) {
      AppLogger.e(
        'ChatDeepLink',
        'failed to open direct message for $userId',
        error: e,
        stackTrace: s,
      );
      if (!mounted || !navContext.mounted) return;
      await openChatEntry(navContext);
    }
  }

  Future<void> openChatUserProfile(
    BuildContext navContext,
    String userId,
  ) async {
    if (!isChatSessionReady) {
      await openChatEntry(navContext);
      return;
    }

    try {
      await N42Chat.openUserProfile(userId, context: navContext);
    } catch (e, s) {
      AppLogger.e(
        'ChatDeepLink',
        'failed to open user profile for $userId',
        error: e,
        stackTrace: s,
      );
      if (!mounted || !navContext.mounted) return;
      await openChatEntry(navContext);
    }
  }

  Future<void> routeChatDeepLink(
    DeepLinkData data, {
    required BuildContext navContext,
  }) async {
    if (!N42Chat.isInitialized) {
      _pendingChatDeepLink = data;
      AppLogger.d('ChatDeepLink', 'queued until N42Chat initializes: $data');
      return;
    }

    if (isChatDeepLink(data.type) && !N42Chat.isLoggedIn) {
      _pendingChatDeepLink = data;
      await openChatEntry(navContext);
      return;
    }

    switch (data.type) {
      case DeepLinkType.chat:
        final roomId = data.params['roomId'] ?? '';
        if (roomId.isNotEmpty) {
          await openChatConversation(navContext, roomId);
        }
        return;
      case DeepLinkType.user:
        final userId = data.params['userId'] ?? '';
        if (userId.isNotEmpty) {
          await openDirectMessage(navContext, userId);
        }
        return;
      case DeepLinkType.group:
        final groupId = data.params['groupId'] ?? '';
        if (groupId.isNotEmpty) {
          await openChatConversation(navContext, groupId);
        }
        return;
      case DeepLinkType.friendCard:
        final userId = data.params['userId'] ?? '';
        if (userId.isNotEmpty) {
          await openChatUserProfile(navContext, userId);
        } else {
          await openChatEntry(navContext);
        }
        return;
      case DeepLinkType.chatSso:
        return;
      case DeepLinkType.walletConnect:
      case DeepLinkType.groupMining:
      case DeepLinkType.fullNode:
      case DeepLinkType.idHubBind:
      case DeepLinkType.idHubAuth:
      case DeepLinkType.unknown:
        return;
    }
  }

  Future<void> flushPendingChatDeepLink() async {
    final pending = _pendingChatDeepLink;
    if (pending == null || !isChatDeepLink(pending.type) || !mounted) {
      return;
    }

    final navContext = AppGlobals.navigatorKey.currentContext;
    if (navContext == null) {
      return;
    }

    _pendingChatDeepLink = null;
    await routeChatDeepLink(pending, navContext: navContext);
  }

  Future<void> flushPendingChatSsoDeepLink() async {
    final pending = _pendingChatSsoDeepLink;
    if (pending == null || pending.type != DeepLinkType.chatSso) {
      return;
    }

    _pendingChatSsoDeepLink = null;
    await routeChatSsoDeepLink(pending);
  }

  void syncHostWithChatAuthStatus(
    AuthStatus? status, {
    AuthStatus? previousStatus,
  }) {
    if (status == null) {
      return;
    }

    if (status == AuthStatus.authenticated &&
        previousStatus != AuthStatus.authenticated) {
      unawaited(clearPendingCancelledChatDataPurgeCompat());
      N42Chat.notifyUserChanged();
      // Chat 登录成功后检查推送权限，未开启则提醒用户；
      // 国产 ROM 另引导开启自启动+电池白名单，否则后台收不到消息。
      AppPushUtils.checkAndPromptPermission();
      AppPushUtils.checkAndPromptBgDelivery();
      return;
    }

    if ((status == AuthStatus.unauthenticated ||
            status == AuthStatus.initial) &&
        previousStatus != status) {
      N42Chat.notifyUserChanged();
      globalProviderContainer.read(unreadCountProvider.notifier).reset();
      AppPushUtils.clearBadgeOnly();
    }
  }

  void disposeChatSubscriptions() {
    _chatAuthSubscription?.cancel();
    _chatUserSubscription?.cancel();
    _unreadCountSubscription?.cancel();
  }
}
