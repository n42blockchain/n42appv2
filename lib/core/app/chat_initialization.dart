// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
      final directAiApiKey = normalizedEnv(envAiApiKey);
      final directDebankApiKey = normalizedEnv(envDebankApiKey);
      final directAlchemyApiKey = normalizedEnv(envAlchemyApiKey);

      if (kDebugMode) {
        for (final line in chatSocialAuthConfig.diagnostics(
          isAndroid: Platform.isAndroid,
          isIOS: Platform.isIOS,
          isMacOS: Platform.isMacOS,
        )) {
          debugPrint(line);
        }
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
        if (kDebugMode) {
          debugPrint(
            'N42Chat notification tapped: roomId=$roomId, eventId=$eventId',
          );
        }
      });

      await N42Chat.initialize(N42ChatConfig(
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
          enableSsoLogin: true,
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
          ssoRedirectUrl: 'n42://auth/sso',
          walletBridge: N42WalletBridge(),
          apiHubBridge: N42ApiHubBridge(),
          proxyAuthToken: proxyAuthToken,
          giphyApiKey: directGiphyApiKey,
          giphyBaseUrl: 'https://api.giphy.com/v1/gifs',
          giphyUseProxyEndpoint: false,
          googleTranslateApiKey: directGoogleTranslateApiKey,
          aiApiKey: directAiApiKey,
          aiBaseUrl: envAiBaseUrl,
          aiModel: envAiModel,
          aiUseProxyEndpoint: false,
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
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        if (kDebugMode) {
          debugPrint('[N42Chat] Initialization timed out after 15s');
        }
        throw TimeoutException('N42Chat.initialize', const Duration(seconds: 15));
      });
      await flushPendingChatDeepLink();
      await flushPendingChatSsoDeepLink();
      await AppPushUtils.flushPendingChatNotification();

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
          if (kDebugMode) {
            debugPrint('Main app locale synced from N42Chat: $locale');
          }
        }
        });
      }

      _unreadCountSubscription = N42Chat.unreadCountStream.listen((count) {
        globalProviderContainer
            .read(unreadCountProvider.notifier)
            .setCount(count);
        if (kDebugMode) debugPrint('N42Chat unread count updated: $count');
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

      if (kDebugMode) {
        debugPrint(
          'N42Chat initialized successfully with theme: $currentTheme',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('N42Chat initialization failed: $e');
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
      if (kDebugMode) {
        debugPrint(
          'Queued chat SSO deep link until N42Chat initializes: $data',
        );
      }
      return;
    }

    final loginToken =
        data.params['loginToken'] ??
        data.params['login_token'] ??
        data.params['token'] ??
        '';
    if (loginToken.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'Deep link: SSO callback missing login token: ${data.sanitizedUri}',
        );
      }
      return;
    }

    final homeserver = normalizeChatSsoHomeserver(
      data.params['homeserver'],
      fallbackHomeserver: N42Chat.config?.defaultHomeserver,
    );
    if (homeserver == null || homeserver.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'Deep link: SSO callback missing or invalid homeserver: '
          '${data.sanitizedUri}',
        );
      }
      return;
    }

    try {
      await N42Chat.loginWithLoginToken(
        homeserver: homeserver,
        loginToken: loginToken,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link: failed to complete chat SSO login: $e');
      }
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
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link: failed to open conversation $roomId: $e');
      }
      if (!mounted || !navContext.mounted) return;
      await openChatEntry(navContext);
    }
  }

  Future<void> openDirectMessage(
    BuildContext navContext,
    String userId,
  ) async {
    if (!isChatSessionReady) {
      await openChatEntry(navContext);
      return;
    }

    try {
      final roomId = await N42Chat.createDirectMessage(userId);
      if (!mounted || !navContext.mounted) return;
      await N42Chat.openConversation(roomId, context: navContext);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link: failed to open direct message for $userId: $e');
      }
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
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link: failed to open user profile for $userId: $e');
      }
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
      if (kDebugMode) {
        debugPrint('Queued chat deep link until N42Chat initializes: $data');
      }
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
