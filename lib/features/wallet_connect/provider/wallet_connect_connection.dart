import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/shared/utils/wallet_connect_uri.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_state.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:web3dart/web3dart.dart' as web3;

/// Mixin: WalletConnect connection lifecycle, relay reconnect timer,
/// WalletKit initialization, and chain/coin resolution helpers.
mixin WalletConnectConnection on ChangeNotifier {
  wallet_connect.ReownWalletKit? signClient;
  web3.Web3Client? web3client;
  String? dAppTopic;
  web3.EthPrivateKey? _privateKey;
  web3.EthPrivateKey get privateKey {
    final key = _privateKey;
    if (key == null) {
      throw StateError(
        'Private key not initialized. Call web3clientInit first.',
      );
    }
    return key;
  }

  int coinModelsIndex = -1;
  List<CoinModel> coinModels = [];

  /// Look up the [CoinModel] for [type] from the loaded chain list.
  /// Returns null when the chain is not configured for the current session.
  CoinModel? coinModelFor(CoinType type) =>
      coinModels.where((c) => c.config.coinType == type.name).firstOrNull;
  WalletConnectState walletConnectState = WalletConnectState.loading;

  /// Guard: prevent duplicate WalletKit event subscriptions.
  bool eventsRegistered = false;

  /// True while the user-initiated disconnect is in progress.
  /// Suppresses the DApp-disconnect Toast from onSessionDelete in that window.
  bool disconnectingByUser = false;

  late final Trustdart trustdart = Trustdart();

  // ── Reconnect timer ───────────────────────────────────────────────────────

  Timer? reconnectTimer;
  static const _maxReconnectAttempts = 5;
  int reconnectAttempts = 0;

  void scheduleReconnect() {
    cancelReconnectTimer();
    if (signClient == null || reconnectAttempts >= _maxReconnectAttempts) {
      if (reconnectAttempts >= _maxReconnectAttempts && dAppTopic != null) {
        final s = wcL10n();
        ToastUtils.show(
          s?.g_wc_connection_lost ?? 'Connection lost. Please reconnect.',
        );
        viewStateDeal(WalletConnectState.disconnect);
      }
      return;
    }
    // Exponential back-off: 2s, 4s, 8s, 16s, 30s
    final seconds = (reconnectAttempts < 4) ? (2 << reconnectAttempts) : 30;
    reconnectTimer = Timer(Duration(seconds: seconds), _tryReconnect);
    AppLogger.d(
      'WalletConnect',
      'reconnect attempt ${reconnectAttempts + 1} in ${seconds}s',
    );
  }

  Future<void> _tryReconnect() async {
    reconnectAttempts++;
    if (signClient == null) return;
    try {
      await signClient!.core.relayClient.connect();
      reconnectAttempts = 0;
      AppLogger.d('WalletConnect', 'relay reconnected');
    } catch (e) {
      AppLogger.w('WalletConnect', 'reconnect #$reconnectAttempts failed: $e');
      scheduleReconnect();
    }
  }

  void cancelReconnectTimer() {
    reconnectTimer?.cancel();
    reconnectTimer = null;
  }

  // ── App lifecycle ──────────────────────────────────────────────────────────

  /// Called when app returns to foreground.
  /// Re-establishes the relay WebSocket that may have been closed by the OS,
  /// then pings the DApp to verify the session is still alive.
  void onAppResumed() {
    if (signClient == null || dAppTopic == null) return;
    try {
      signClient!.core.relayClient
          .connect()
          .then((_) {
            pingSession();
          })
          .catchError((e) {
            AppLogger.w('WalletConnect', 'resume relay reconnect error: $e');
            scheduleReconnect();
          });
    } catch (e) {
      AppLogger.w('WalletConnect', 'resume relay reconnect: $e');
    }
  }

  /// Ping the active DApp session to verify it's still alive.
  /// If the ping fails, the session is stale — notify and disconnect.
  Future<void> pingSession() async {
    final topic = dAppTopic;
    if (topic == null || signClient == null) return;
    try {
      await signClient!.reOwnSign
          .ping(topic: topic)
          .timeout(const Duration(seconds: 10));
      AppLogger.d('WalletConnect', 'session ping OK');
    } catch (e) {
      AppLogger.w('WalletConnect', 'session ping failed: $e');
      final s = wcL10n();
      ToastUtils.show(s?.g_wc_session_expired ?? 'Session has expired');
      viewStateDeal(WalletConnectState.disconnect);
    }
  }

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> connectInit() async {
    try {
      if (signClient != null) {
        coinModelInit();
        return;
      }
      signClient = await wallet_connect.ReownWalletKit.createInstance(
        projectId: const String.fromEnvironment(
          'WC_PROJECT_ID',
          defaultValue: '18a60a7cb862aad161fecd764ecc736a',
        ),
        metadata: wallet_connect.PairingMetadata(
          name: AppConfig.apiUrl['walletName'],
          description: AppConfig.apiUrl['walletName'],
          url: AppConfig.apiUrl['n42Browser']!,
          icons: ["https://n42.ai/static/n42.png"],
        ),
      );
      coinModelInit();
      setChainInfo();
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  Future<bool> pair(String relayUrl) async {
    try {
      final uri = parseWalletConnectUri(relayUrl);
      if (uri == null) {
        await viewStateDeal(
          WalletConnectState.error,
          params: 'Invalid WalletConnect URI',
        );
        return false;
      }
      await signClient!.pair(uri: uri);
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('pairing already exists') ||
          msg.contains('already exists') ||
          msg.contains('already connected')) {
        // Extract topic from the incoming URI to verify it matches existing pairing.
        // WC v2 URI format: wc:<topic>@2?relay-protocol=...&symKey=...
        final uri = parseWalletConnectUri(relayUrl);
        final uriPath = uri?.path ?? '';
        final incomingTopic = uriPath.contains('@')
            ? uriPath.split('@').first
            : uriPath;

        final existingPairings = signClient?.core.pairing.getPairings() ?? [];
        final isMatchingPairing =
            incomingTopic.isNotEmpty &&
            existingPairings.any((p) => p.topic == incomingTopic && p.active);

        if (isMatchingPairing) {
          AppLogger.d(
            'WalletConnect',
            'pair: same URI retry, waiting for session_propose',
          );
          notifyListeners();
          return true;
        }

        // Different DApp or stale pairing — prompt user
        final s = wcL10n();
        ToastUtils.show(
          s?.g_wc_connection_lost ??
              'Please disconnect existing session first.',
        );
        AppLogger.w(
          'WalletConnect',
          'pair: pairing conflict with different DApp',
        );
        return false;
      }
      await viewStateDeal(WalletConnectState.error, params: e.toString());
      return false;
    }
  }

  Future<bool> web3clientInit() async {
    try {
      final cm = coinModels[coinModelsIndex];
      web3client = web3.Web3Client(
        cm.isTest ? cm.config.serviceTest : cm.config.service,
        Client(),
      );

      final walletService = globalProviderContainer.read(walletServiceProvider);
      if (walletService == null) {
        viewStateDeal(
          WalletConnectState.error,
          params: "Wallet service not available",
        );
        return false;
      }

      final currentIndex = walletService.miningWalletIndex >= 0
          ? walletService.miningWalletIndex
          : 0;
      String? pKey = await walletService.getPrivateKeyForWallet(currentIndex);

      if (pKey == null) {
        final mnemonic = await walletService.getMnemonicForWallet(currentIndex);
        if (mnemonic != null) {
          pKey = await trustdart.getPrivateKey(
            mnemonic,
            cm.config.coinType,
            getPathWithIndex(cm.config.pathForAddrType('legacy')!, cm.pathIndex),
          );
        }
      }

      if (pKey == null) {
        viewStateDeal(
          WalletConnectState.error,
          params: "Could not get private key",
        );
        return false;
      }

      final Uint8List decodedKey;
      try {
        decodedKey = base64Decode(pKey);
      } on FormatException catch (e) {
        viewStateDeal(
          WalletConnectState.error,
          params: 'Invalid private key encoding: ${e.message}',
        );
        return false;
      }
      if (decodedKey.length != 32) {
        viewStateDeal(
          WalletConnectState.error,
          params: 'Invalid private key length: expected 32 bytes',
        );
        return false;
      }
      _privateKey = web3.EthPrivateKey(Uint8List.fromList(decodedKey));
      SecureStorage.secureWipeBytes(decodedKey);
      return true;
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
      return false;
    }
  }

  Future<bool> web3clientInitFromChainId(String chainStr) async {
    final namespace = chainStr.split(':')[0];

    // Solana: no web3client needed, just locate the coin model
    if (namespace == 'solana') {
      final idx = coinModels.indexWhere(
        (cm) => cm.config.blockchainType == BlockchainType.Solana.name,
      );
      if (idx == -1) {
        viewStateDeal(
          WalletConnectState.error,
          params: 'Solana chain not configured',
        );
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // Tron: no web3client needed, just locate the coin model
    if (namespace == 'tron') {
      final idx = coinModels.indexWhere(
        (cm) => cm.config.blockchainType == BlockchainType.Tron.name,
      );
      if (idx == -1) {
        viewStateDeal(
          WalletConnectState.error,
          params: 'Tron chain not configured',
        );
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // Aptos: no web3client needed
    if (namespace == 'aptos') {
      final idx = coinModels.indexWhere(
        (cm) => cm.config.blockchainType == BlockchainType.Aptos.name,
      );
      if (idx == -1) {
        viewStateDeal(
          WalletConnectState.error,
          params: 'Aptos chain not configured',
        );
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // Sui: no web3client needed
    if (namespace == 'sui') {
      final idx = coinModels.indexWhere(
        (cm) => cm.config.blockchainType == BlockchainType.Sui.name,
      );
      if (idx == -1) {
        viewStateDeal(
          WalletConnectState.error,
          params: 'Sui chain not configured',
        );
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // NEAR: no web3client needed
    if (namespace == 'near') {
      final idx = coinModels.indexWhere(
        (cm) => cm.config.blockchainType == BlockchainType.Near.name,
      );
      if (idx == -1) {
        viewStateDeal(
          WalletConnectState.error,
          params: 'NEAR chain not configured',
        );
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // EIP-155 (Ethereum): use web3client
    final chainId = chainStr.split(':')[1];
    final chainIndex = coinModels.indexWhere((cm) {
      if (cm.config.blockchainType != BlockchainType.Ethereum.name) {
        return false;
      }
      final id = (cm.isTest ? cm.config.chainIdTest : cm.config.chainId)
          .toString();
      return id == chainId;
    });
    if (chainIndex == -1) {
      viewStateDeal(WalletConnectState.error, params: 'Error');
      return false;
    }
    final needsReinit = coinModelsIndex != chainIndex || web3client == null;
    if (coinModelsIndex != chainIndex) setCoinModelsIndex(chainIndex);
    return needsReinit ? await web3clientInit() : true;
  }

  void coinModelInit({int chainId = -1}) {
    try {
      coinModels = globalWapAdapter.coinModels
          .where(
            (cm) =>
                cm.config.blockchainType == BlockchainType.Ethereum.name ||
                cm.config.blockchainType == BlockchainType.Tron.name ||
                cm.config.blockchainType == BlockchainType.Solana.name ||
                cm.config.blockchainType == BlockchainType.Aptos.name ||
                cm.config.blockchainType == BlockchainType.Sui.name ||
                cm.config.blockchainType == BlockchainType.Near.name,
          )
          .toList();

      if (coinModels.isEmpty) return;

      if (chainId == -1) {
        // 默认选中第一个 Ethereum 链
        final ethIndex = coinModels.indexWhere(
          (cm) => cm.config.blockchainType == BlockchainType.Ethereum.name,
        );
        setCoinModelsIndex(ethIndex >= 0 ? ethIndex : 0);
        return;
      }
      // 按指定 chainId 查找匹配项
      final matchIndex = coinModels.indexWhere((cm) {
        final cmChainId = cm.isTest
            ? cm.config.chainIdTest
            : cm.config.chainId;
        return cmChainId == chainId;
      });
      if (matchIndex != -1) setCoinModelsIndex(matchIndex);
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  /// Find a coin model matching the given WalletConnect chain ID string.
  CoinModel? coinModelFind(String chainId) {
    return coinModels.where((element) {
      final blockchainType = element.config.blockchainType;
      if (blockchainType == BlockchainType.Ethereum.name) {
        final id = element.isTest
            ? element.config.chainIdTest
            : element.config.chainId;
        return 'eip155:$id' == chainId;
      }
      if (blockchainType == BlockchainType.Tron.name) {
        return 'tron:0x2b6653dc' == chainId;
      }
      if (blockchainType == BlockchainType.Solana.name) {
        return chainId == _solanaMainnetChainId ||
            chainId == _solanaDevnetChainId;
      }
      if (blockchainType == BlockchainType.Aptos.name) {
        return chainId == _aptosMainnetChainId ||
            chainId == _aptosTestnetChainId;
      }
      if (blockchainType == BlockchainType.Sui.name) {
        return chainId == _suiMainnetChainId || chainId == _suiTestnetChainId;
      }
      if (blockchainType == BlockchainType.Near.name) {
        return chainId == _nearMainnetChainId || chainId == _nearTestnetChainId;
      }
      return false;
    }).firstOrNull;
  }

  /// Solana WalletConnect chain IDs
  static const String _solanaMainnetChainId =
      'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ';
  static const String _solanaDevnetChainId =
      'solana:8E9rvCKLFQia2Y35HXjjpWzj8weVo44K';

  /// Aptos WalletConnect chain IDs
  static const String _aptosMainnetChainId = 'aptos:1';
  static const String _aptosTestnetChainId = 'aptos:2';

  /// Sui WalletConnect chain IDs
  static const String _suiMainnetChainId = 'sui:mainnet';
  static const String _suiTestnetChainId = 'sui:testnet';

  /// NEAR WalletConnect chain IDs
  static const String _nearMainnetChainId = 'near:mainnet';
  static const String _nearTestnetChainId = 'near:testnet';

  /// Fetch mnemonic + private key for the current mining wallet.
  ///
  /// All chains (TRON, Solana, Aptos, Sui, NEAR, …) derive their per-chain
  /// addresses from the same mnemonic and HD path, so a single accessor
  /// suffices. Returns empty strings if no wallet is registered.
  Future<({String mnemonic, String privateKey})>
  getCurrentWalletCredentials() async {
    final walletService = globalProviderContainer.read(walletServiceProvider);
    if (walletService == null) return (mnemonic: '', privateKey: '');
    return walletService.getCredentials(walletService.miningWalletIndex);
  }

  // ── Abstract methods to be implemented by the concrete class ──────────────

  void setCoinModelsIndex(int value);
  void setChainInfo();
  Future<void> viewStateDeal(WalletConnectState state, {dynamic params});
}
