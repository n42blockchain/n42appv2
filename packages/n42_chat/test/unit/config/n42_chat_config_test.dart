// Tests for n42_chat_config.dart — pure immutable config data classes.
// Covers: N42ChatConfig defaults and copyWith, StorageManagementConfig,
// SyncFilterConfig.
// No platform/network dependencies — pure Dart.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/integration/api_hub_bridge.dart';
import 'package:n42_chat/src/integration/wallet_bridge.dart';
import 'package:n42_chat/src/n42_chat_config.dart';

void main() {
  // ─────────────────────────────────────────────────
  // N42ChatConfig — defaults
  // ─────────────────────────────────────────────────

  group('N42ChatConfig defaults', () {
    const config = N42ChatConfig();

    test('defaultHomeserver is set', () {
      expect(config.defaultHomeserver, isNotEmpty);
    });

    test('defaultHomeserver uses HTTPS scheme', () {
      // Regression guard: an accidental http:// default would silently send
      // login credentials over an unencrypted transport.
      expect(config.defaultHomeserver, startsWith('https://'));
    });

    test('enableEncryption defaults to true', () {
      expect(config.enableEncryption, isTrue);
    });

    test('enablePushNotifications defaults to true', () {
      expect(config.enablePushNotifications, isTrue);
    });

    test('pushGatewayUrl defaults to null', () {
      expect(config.pushGatewayUrl, isNull);
    });

    test('pushAppId defaults to non-empty string', () {
      expect(config.pushAppId, isNotEmpty);
    });

    test('syncTimeout defaults to 30 seconds', () {
      expect(config.syncTimeout, const Duration(seconds: 30));
    });

    test('showPresence defaults to true', () {
      expect(config.showPresence, isTrue);
    });

    test('showReadReceipts defaults to true', () {
      expect(config.showReadReceipts, isTrue);
    });

    test('enableMessageDelete defaults to true', () {
      expect(config.enableMessageDelete, isTrue);
    });

    test('messageDeleteTimeout defaults to 120', () {
      expect(config.messageDeleteTimeout, 120);
    });

    test('maxImageSize defaults to 10MB', () {
      expect(config.maxImageSize, 10 * 1024 * 1024);
    });

    test('maxFileSize defaults to 50MB', () {
      expect(config.maxFileSize, 50 * 1024 * 1024);
    });

    test('maxVoiceDuration defaults to 60', () {
      expect(config.maxVoiceDuration, 60);
    });

    test('enableDebugLogs defaults to false', () {
      expect(config.enableDebugLogs, isFalse);
    });

    test('databaseName defaults to null', () {
      expect(config.databaseName, isNull);
    });

    test('termsOfServiceUrl defaults to non-empty string', () {
      expect(config.termsOfServiceUrl, isNotEmpty);
    });

    test('privacyPolicyUrl defaults to non-empty string', () {
      expect(config.privacyPolicyUrl, isNotEmpty);
    });

    test('giphyApiKey defaults to null', () {
      expect(config.giphyApiKey, isNull);
    });

    test('giphyUseProxyEndpoint defaults to false', () {
      expect(config.giphyUseProxyEndpoint, isFalse);
    });

    test('proxyAuthToken defaults to null', () {
      expect(config.proxyAuthToken, isNull);
    });

    test('googleTranslateApiKey defaults to null', () {
      expect(config.googleTranslateApiKey, isNull);
    });

    test('googleSpeechApiKey defaults to null', () {
      expect(config.googleSpeechApiKey, isNull);
    });

    test('azureSpeechApiKey defaults to null', () {
      expect(config.azureSpeechApiKey, isNull);
    });

    test('azureSpeechRegion defaults to eastus', () {
      expect(config.azureSpeechRegion, 'eastus');
    });

    test('aiApiKey defaults to null', () {
      expect(config.aiApiKey, isNull);
    });

    test('aiBaseUrl defaults to non-empty string', () {
      expect(config.aiBaseUrl, isNotEmpty);
    });

    test('aiModel defaults to non-empty string', () {
      expect(config.aiModel, isNotEmpty);
    });

    test('aiUseProxyEndpoint defaults to false', () {
      expect(config.aiUseProxyEndpoint, isFalse);
    });

    test('speechUseProxyEndpoint defaults to false', () {
      expect(config.speechUseProxyEndpoint, isFalse);
    });

    test('marketUseProxyEndpoint defaults to false', () {
      expect(config.marketUseProxyEndpoint, isFalse);
    });

    test('marketBaseUrl defaults to CoinGecko', () {
      expect(config.marketBaseUrl, startsWith('https://api.coingecko.com'));
    });

    test('customTheme defaults to null', () {
      expect(config.customTheme, isNull);
    });

    test('walletBridge defaults to null', () {
      expect(config.walletBridge, isNull);
    });

    test('onMessageTap defaults to null', () {
      expect(config.onMessageTap, isNull);
    });

    test('onAvatarTap defaults to null', () {
      expect(config.onAvatarTap, isNull);
    });

    test('debankUseProxyEndpoint defaults to false', () {
      expect(config.debankUseProxyEndpoint, isFalse);
    });

    test('debankBaseUrl defaults to DeBank', () {
      expect(config.debankBaseUrl, startsWith('https://open-api.debank.com'));
    });

    test('alchemyUseProxyEndpoint defaults to false', () {
      expect(config.alchemyUseProxyEndpoint, isFalse);
    });

    test('alchemyBaseUrl defaults to Alchemy mainnet', () {
      expect(
        config.alchemyBaseUrl,
        startsWith('https://eth-mainnet.g.alchemy.com'),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // N42ChatConfig — copyWith
  // ─────────────────────────────────────────────────

  group('N42ChatConfig.copyWith', () {
    const base = N42ChatConfig();

    test('replaces enableEncryption', () {
      expect(base.copyWith(enableEncryption: false).enableEncryption, isFalse);
    });

    test('replaces defaultHomeserver', () {
      expect(
        base
            .copyWith(defaultHomeserver: 'https://custom.server')
            .defaultHomeserver,
        'https://custom.server',
      );
    });

    test('replaces maxImageSize', () {
      expect(
        base.copyWith(maxImageSize: 5 * 1024 * 1024).maxImageSize,
        5 * 1024 * 1024,
      );
    });

    test('replaces enableDebugLogs', () {
      expect(base.copyWith(enableDebugLogs: true).enableDebugLogs, isTrue);
    });

    test('replaces aiModel', () {
      expect(base.copyWith(aiModel: 'claude-3').aiModel, 'claude-3');
    });

    test('replaces aiUseProxyEndpoint', () {
      expect(
        base.copyWith(aiUseProxyEndpoint: true).aiUseProxyEndpoint,
        isTrue,
      );
    });

    test('replaces giphyApiKey', () {
      expect(base.copyWith(giphyApiKey: 'my-key').giphyApiKey, 'my-key');
    });

    test('replaces giphyUseProxyEndpoint', () {
      expect(
        base.copyWith(giphyUseProxyEndpoint: true).giphyUseProxyEndpoint,
        isTrue,
      );
    });

    test('replaces proxyAuthToken', () {
      expect(
        base.copyWith(proxyAuthToken: 'proxy-token').proxyAuthToken,
        'proxy-token',
      );
    });

    test('replaces googleSpeechApiKey', () {
      expect(
        base.copyWith(googleSpeechApiKey: 'google-speech').googleSpeechApiKey,
        'google-speech',
      );
    });

    test('replaces azureSpeechApiKey', () {
      expect(
        base.copyWith(azureSpeechApiKey: 'azure-speech').azureSpeechApiKey,
        'azure-speech',
      );
    });

    test('replaces azureSpeechRegion', () {
      expect(
        base.copyWith(azureSpeechRegion: 'westus').azureSpeechRegion,
        'westus',
      );
    });

    test('replaces speechUseProxyEndpoint', () {
      expect(
        base.copyWith(speechUseProxyEndpoint: true).speechUseProxyEndpoint,
        isTrue,
      );
    });

    test('replaces marketUseProxyEndpoint', () {
      expect(
        base.copyWith(marketUseProxyEndpoint: true).marketUseProxyEndpoint,
        isTrue,
      );
    });

    test('replaces marketBaseUrl', () {
      expect(
        base
            .copyWith(marketBaseUrl: 'https://proxy.example/v1/market')
            .marketBaseUrl,
        'https://proxy.example/v1/market',
      );
    });

    test('replaces syncTimeout', () {
      expect(
        base.copyWith(syncTimeout: const Duration(seconds: 60)).syncTimeout,
        const Duration(seconds: 60),
      );
    });

    test('replaces showPresence', () {
      expect(base.copyWith(showPresence: false).showPresence, isFalse);
    });

    test('replaces messageDeleteTimeout', () {
      expect(
        base.copyWith(messageDeleteTimeout: 300).messageDeleteTimeout,
        300,
      );
    });

    test('original unchanged after copyWith', () {
      base.copyWith(enableEncryption: false);
      expect(base.enableEncryption, isTrue);
    });

    test('allows clearing nullable fields back to null', () {
      final walletBridge = _TestWalletBridge();
      final apiHubBridge = _TestApiHubBridge();

      void onMessageTap(String roomId, String eventId) {}

      Future<void> onLinkTap(String url) async {}

      final configured = N42ChatConfig(
        walletBridge: walletBridge,
        apiHubBridge: apiHubBridge,
        proxyAuthToken: 'proxy-token',
        onMessageTap: onMessageTap,
        onLinkTap: onLinkTap,
        pushProtocol: const PushProtocolConfig(enabled: false),
        pointsApiBaseUrl: 'https://points.example',
      );

      final cleared = configured.copyWith(
        walletBridge: null,
        apiHubBridge: null,
        proxyAuthToken: null,
        onMessageTap: null,
        onLinkTap: null,
        pushProtocol: null,
        pointsApiBaseUrl: null,
      );

      expect(cleared.walletBridge, isNull);
      expect(cleared.apiHubBridge, isNull);
      expect(cleared.proxyAuthToken, isNull);
      expect(cleared.onMessageTap, isNull);
      expect(cleared.onLinkTap, isNull);
      expect(cleared.pushProtocol, isNull);
      expect(cleared.pointsApiBaseUrl, isNull);
    });

    test('replaces debankUseProxyEndpoint', () {
      expect(
        base.copyWith(debankUseProxyEndpoint: true).debankUseProxyEndpoint,
        isTrue,
      );
    });

    test('replaces debankBaseUrl', () {
      expect(
        base
            .copyWith(debankBaseUrl: 'https://proxy.example/v1/debank')
            .debankBaseUrl,
        'https://proxy.example/v1/debank',
      );
    });

    test('replaces alchemyUseProxyEndpoint', () {
      expect(
        base.copyWith(alchemyUseProxyEndpoint: true).alchemyUseProxyEndpoint,
        isTrue,
      );
    });

    test('replaces alchemyBaseUrl', () {
      expect(
        base
            .copyWith(
              alchemyBaseUrl: 'https://proxy.example/v1/alchemy/eth-mainnet',
            )
            .alchemyBaseUrl,
        'https://proxy.example/v1/alchemy/eth-mainnet',
      );
    });
  });

  // ─────────────────────────────────────────────────
  // StorageManagementConfig
  // ─────────────────────────────────────────────────

  group('StorageManagementConfig defaults', () {
    const config = StorageManagementConfig();

    test('autoCleanupDays defaults to 90', () {
      expect(config.autoCleanupDays, 90);
    });

    test('warningThresholdMB defaults to 500', () {
      expect(config.warningThresholdMB, 500);
    });

    test('criticalThresholdMB defaults to 1000', () {
      expect(config.criticalThresholdMB, 1000);
    });

    test('hotDataDays defaults to 30', () {
      expect(config.hotDataDays, 30);
    });

    test('warmDataDays defaults to 180', () {
      expect(config.warmDataDays, 180);
    });

    test('autoCleanupEnabled defaults to false', () {
      expect(config.autoCleanupEnabled, isFalse);
    });

    test('preserveThumbnails defaults to true', () {
      expect(config.preserveThumbnails, isTrue);
    });
  });

  group('StorageManagementConfig custom values', () {
    const config = StorageManagementConfig(
      autoCleanupDays: 30,
      warningThresholdMB: 200,
      criticalThresholdMB: 500,
      autoCleanupEnabled: true,
      preserveThumbnails: false,
    );

    test('stores custom autoCleanupDays', () {
      expect(config.autoCleanupDays, 30);
    });

    test('stores custom warningThresholdMB', () {
      expect(config.warningThresholdMB, 200);
    });

    test('stores custom criticalThresholdMB', () {
      expect(config.criticalThresholdMB, 500);
    });

    test('stores autoCleanupEnabled = true', () {
      expect(config.autoCleanupEnabled, isTrue);
    });

    test('stores preserveThumbnails = false', () {
      expect(config.preserveThumbnails, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // SyncFilterConfig
  // ─────────────────────────────────────────────────

  group('SyncFilterConfig defaults', () {
    const config = SyncFilterConfig();

    test('timelineLimit defaults to 20', () {
      expect(config.timelineLimit, 20);
    });

    test('includeLeaveRooms defaults to false', () {
      expect(config.includeLeaveRooms, isFalse);
    });

    test('lazyLoadMembers defaults to true', () {
      expect(config.lazyLoadMembers, isTrue);
    });
  });

  group('SyncFilterConfig custom values', () {
    const config = SyncFilterConfig(
      timelineLimit: 50,
      includeLeaveRooms: true,
      lazyLoadMembers: false,
    );

    test('stores custom timelineLimit', () {
      expect(config.timelineLimit, 50);
    });

    test('stores custom includeLeaveRooms', () {
      expect(config.includeLeaveRooms, isTrue);
    });

    test('stores custom lazyLoadMembers', () {
      expect(config.lazyLoadMembers, isFalse);
    });
  });

  group('SyncFilterConfig equality', () {
    test('same values → equal', () {
      expect(const SyncFilterConfig(), equals(const SyncFilterConfig()));
    });

    test('different timelineLimit → not equal', () {
      expect(
        const SyncFilterConfig(timelineLimit: 20),
        isNot(equals(const SyncFilterConfig(timelineLimit: 50))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // N42ChatConfig — syncFilter integration
  // ─────────────────────────────────────────────────

  group('N42ChatConfig syncFilter', () {
    test('default syncFilter uses default values', () {
      const config = N42ChatConfig();
      expect(config.syncFilter.timelineLimit, 20);
      expect(config.syncFilter.lazyLoadMembers, isTrue);
    });

    test('custom syncFilter is stored', () {
      const config = N42ChatConfig(
        syncFilter: SyncFilterConfig(timelineLimit: 50, lazyLoadMembers: false),
      );
      expect(config.syncFilter.timelineLimit, 50);
      expect(config.syncFilter.lazyLoadMembers, isFalse);
    });
  });
}

class _TestApiHubBridge implements IApiHubBridge {
  @override
  Future<List<BridgeNewsItem>> getLatestNews({int limit = 10}) async => [];

  @override
  Future<Map<String, double>> getPrices(List<String> symbols) async => {};

  @override
  Future<bool> isUrlMalicious(String url, {bool useRemote = true}) async =>
      false;
}

class _TestWalletBridge implements IWalletBridge {
  @override
  bool get isWalletConnected => false;

  @override
  String? get walletAddress => null;

  @override
  Future<Map<String, String?>> batchLookupEnsNames(
    List<String> addresses,
  ) async => {};

  @override
  Future<String> getBalance(String token) async => '0';

  @override
  Future<String?> getEnsAvatar(String ensName) async => null;

  @override
  Future<BigInt> getErc20Balance({
    required String contractAddress,
    required int chainId,
    String? ownerAddress,
  }) async => BigInt.zero;

  @override
  Future<int> getErc721Balance({
    required String contractAddress,
    required int chainId,
    String? ownerAddress,
  }) async => 0;

  @override
  Future<String?> getErc721TokenUri({
    required String contractAddress,
    required int tokenId,
    required int chainId,
  }) async => null;

  @override
  Future<BigInt> getErc1155Balance({
    required String contractAddress,
    required BigInt tokenId,
    required int chainId,
    String? ownerAddress,
  }) async => BigInt.zero;

  @override
  Future<PaymentRequest> generatePaymentRequest({
    required String amount,
    required String token,
    String? memo,
  }) async => PaymentRequest(
    requestId: 'req',
    amount: amount,
    token: token,
    receiverAddress: '0x0',
    qrCodeData: 'qr',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  Future<WalletUserInfo?> getUserInfoByAddress(String address) async => null;

  @override
  Future<String?> lookupEnsName(String address) async => null;

  @override
  Future<String?> resolveEnsName(String ensName) async => null;

  @override
  Future<TransferResult> requestTransfer({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
  }) async => const TransferResult(success: false);

  @override
  Future<void> showReceiveQRCode() async {}

  @override
  Future<String?> signMessage(String message) async => null;

  @override
  Future<String?> signTypedData(String typedDataJson) async => null;

  @override
  bool isValidAddress(String address) => true;

  @override
  Future<List<TokenInfo>> getSupportedTokens() async => const [];
}
