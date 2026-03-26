import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/di/service_locator_setup.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet_connect/wallet_connect_uri.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_state.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:web3dart/web3dart.dart' as web3;

/// Mixin: WalletConnect connection lifecycle, relay reconnect timer,
/// WalletKit initialization, and chain/coin resolution helpers.
mixin WalletConnectConnection on ChangeNotifier {
  wallet_connect.ReownWalletKit? signClient;
  web3.Web3Client? web3client;
  String? dAppTopic;
  late web3.EthPrivateKey privateKey;
  int coinModelsIndex = -1;
  List<CoinModel> coinModels = [];
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
    debugPrint(
      '[WalletConnect] Reconnect attempt ${reconnectAttempts + 1} in ${seconds}s',
    );
  }

  Future<void> _tryReconnect() async {
    reconnectAttempts++;
    if (signClient == null) return;
    try {
      await signClient!.core.relayClient.connect();
      reconnectAttempts = 0;
      debugPrint('[WalletConnect] Relay reconnected');
    } catch (e) {
      debugPrint('[WalletConnect] Reconnect #$reconnectAttempts failed: $e');
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
            debugPrint('[WalletConnect] Resume relay reconnect error: $e');
            scheduleReconnect();
          });
    } catch (e) {
      debugPrint('[WalletConnect] Resume relay reconnect: $e');
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
      debugPrint('[WalletConnect] Session ping OK');
    } catch (e) {
      debugPrint('[WalletConnect] Session ping failed: $e');
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
          url: AppConfig.apiUrl['walletamazeBrowser']!,
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
      // "Pairing already exists" is non-fatal: the DApp may reuse the same URI
      // on a retry. The existing pairing is still valid — just wait for the
      // next session_propose event instead of entering error state.
      final msg = e.toString().toLowerCase();
      if (msg.contains('pairing already exists') ||
          msg.contains('already exists') ||
          msg.contains('already connected')) {
        debugPrint('[WalletConnect] pair: $e — treating as non-fatal, waiting for session_propose');
        notifyListeners();
        return true;
      }
      await viewStateDeal(WalletConnectState.error, params: e.toString());
      return false;
    }
  }

  Future<bool> web3clientInit() async {
    try {
      final cm = coinModels[coinModelsIndex];
      web3client = web3.Web3Client(
        cm.isTest ? cm.coin['service_test'] : cm.coin['service'],
        Client(),
      );

      final walletService = ServiceLocatorSetup.walletService;
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
            cm.coin['coinType'],
            getPathWithIndex(cm.coin['path']['legacy'], cm.pathIndex),
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
      privateKey = web3.EthPrivateKey(decodedKey);
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
        (cm) => cm.coin['blockchainType'] == BlockchainType.Solana.name,
      );
      if (idx == -1) {
        viewStateDeal(WalletConnectState.error, params: 'Solana chain not configured');
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // Tron: no web3client needed, just locate the coin model
    if (namespace == 'tron') {
      final idx = coinModels.indexWhere(
        (cm) => cm.coin['blockchainType'] == BlockchainType.Tron.name,
      );
      if (idx == -1) {
        viewStateDeal(WalletConnectState.error, params: 'Tron chain not configured');
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // Aptos: no web3client needed
    if (namespace == 'aptos') {
      final idx = coinModels.indexWhere(
        (cm) => cm.coin['blockchainType'] == BlockchainType.Aptos.name,
      );
      if (idx == -1) {
        viewStateDeal(WalletConnectState.error, params: 'Aptos chain not configured');
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // Sui: no web3client needed
    if (namespace == 'sui') {
      final idx = coinModels.indexWhere(
        (cm) => cm.coin['blockchainType'] == BlockchainType.Sui.name,
      );
      if (idx == -1) {
        viewStateDeal(WalletConnectState.error, params: 'Sui chain not configured');
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // NEAR: no web3client needed
    if (namespace == 'near') {
      final idx = coinModels.indexWhere(
        (cm) => cm.coin['blockchainType'] == BlockchainType.Near.name,
      );
      if (idx == -1) {
        viewStateDeal(WalletConnectState.error, params: 'NEAR chain not configured');
        return false;
      }
      if (coinModelsIndex != idx) setCoinModelsIndex(idx);
      return true;
    }

    // EIP-155 (Ethereum): use web3client
    final chainId = chainStr.split(':')[1];
    final chainIndex = coinModels.indexWhere((cm) {
      if (cm.coin['blockchainType'] != BlockchainType.Ethereum.name) return false;
      final id = (cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId'])
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
                cm.coin['blockchainType'] == BlockchainType.Ethereum.name ||
                cm.coin['blockchainType'] == BlockchainType.Tron.name ||
                cm.coin['blockchainType'] == BlockchainType.Solana.name ||
                cm.coin['blockchainType'] == BlockchainType.Aptos.name ||
                cm.coin['blockchainType'] == BlockchainType.Sui.name ||
                cm.coin['blockchainType'] == BlockchainType.Near.name,
          )
          .toList();

      if (coinModels.isEmpty) return;

      if (chainId == -1) {
        // 默认选中第一个 Ethereum 链
        final ethIndex = coinModels.indexWhere(
          (cm) => cm.coin['blockchainType'] == BlockchainType.Ethereum.name,
        );
        setCoinModelsIndex(ethIndex >= 0 ? ethIndex : 0);
        return;
      }
      // 按指定 chainId 查找匹配项
      final matchIndex = coinModels.indexWhere((cm) {
        final cmChainId = cm.isTest
            ? cm.coin['chainId_test']
            : cm.coin['chainId'];
        return cmChainId == chainId;
      });
      if (matchIndex != -1) setCoinModelsIndex(matchIndex);
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  /// Find a coin model matching the given WalletConnect chain ID string.
  CoinModel? coinModelFind(String chainId) {
    // TODO: remove this debug filter once Blast connection issue is resolved.
    if (chainId == 'eip155:81457') return null;
    return coinModels.where((element) {
      final blockchainType = element.coin['blockchainType'];
      if (blockchainType == BlockchainType.Ethereum.name) {
        final id = element.isTest
            ? element.coin['chainId_test']
            : element.coin['chainId'];
        return 'eip155:$id' == chainId;
      }
      if (blockchainType == BlockchainType.Tron.name) {
        return 'tron:0x2b6653dc' == chainId;
      }
      if (blockchainType == BlockchainType.Solana.name) {
        return chainId == _solanaMainnetChainId || chainId == _solanaDevnetChainId;
      }
      if (blockchainType == BlockchainType.Aptos.name) {
        return chainId == _aptosMainnetChainId || chainId == _aptosTestnetChainId;
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
  static const String _solanaMainnetChainId = 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ';
  static const String _solanaDevnetChainId  = 'solana:8E9rvCKLFQia2Y35HXjjpWzj8weVo44K';

  /// Aptos WalletConnect chain IDs
  static const String _aptosMainnetChainId = 'aptos:1';
  static const String _aptosTestnetChainId = 'aptos:2';

  /// Sui WalletConnect chain IDs
  static const String _suiMainnetChainId = 'sui:mainnet';
  static const String _suiTestnetChainId = 'sui:testnet';

  /// NEAR WalletConnect chain IDs
  static const String _nearMainnetChainId = 'near:mainnet';
  static const String _nearTestnetChainId = 'near:testnet';

  /// Fetch TRON wallet credentials from IWalletService.
  Future<({String mnemonic, String privateKey})> getTronCredentials() async {
    final walletService = ServiceLocatorSetup.walletService;
    final currentIndex = walletService?.miningWalletIndex ?? 0;
    final mnemonic =
        await walletService?.getMnemonicForWallet(currentIndex) ?? "";
    final pk = await walletService?.getPrivateKeyForWallet(currentIndex) ?? "";
    return (mnemonic: mnemonic, privateKey: pk);
  }

  /// Fetch Solana wallet credentials from IWalletService.
  Future<({String mnemonic, String privateKey})> getSolanaCredentials() async {
    final walletService = ServiceLocatorSetup.walletService;
    final currentIndex = walletService?.miningWalletIndex ?? 0;
    final mnemonic = await walletService?.getMnemonicForWallet(currentIndex) ?? "";
    final pk = await walletService?.getPrivateKeyForWallet(currentIndex) ?? "";
    return (mnemonic: mnemonic, privateKey: pk);
  }

  /// Fetch Aptos wallet credentials from IWalletService.
  Future<({String mnemonic, String privateKey})> getAptosCredentials() async {
    final walletService = ServiceLocatorSetup.walletService;
    final currentIndex = walletService?.miningWalletIndex ?? 0;
    final mnemonic = await walletService?.getMnemonicForWallet(currentIndex) ?? "";
    final pk = await walletService?.getPrivateKeyForWallet(currentIndex) ?? "";
    return (mnemonic: mnemonic, privateKey: pk);
  }

  /// Fetch Sui wallet credentials from IWalletService.
  Future<({String mnemonic, String privateKey})> getSuiCredentials() async {
    final walletService = ServiceLocatorSetup.walletService;
    final currentIndex = walletService?.miningWalletIndex ?? 0;
    final mnemonic = await walletService?.getMnemonicForWallet(currentIndex) ?? "";
    final pk = await walletService?.getPrivateKeyForWallet(currentIndex) ?? "";
    return (mnemonic: mnemonic, privateKey: pk);
  }

  /// Fetch NEAR wallet credentials from IWalletService.
  Future<({String mnemonic, String privateKey})> getNearCredentials() async {
    final walletService = ServiceLocatorSetup.walletService;
    final currentIndex = walletService?.miningWalletIndex ?? 0;
    final mnemonic = await walletService?.getMnemonicForWallet(currentIndex) ?? "";
    final pk = await walletService?.getPrivateKeyForWallet(currentIndex) ?? "";
    return (mnemonic: mnemonic, privateKey: pk);
  }

  // ── Abstract methods to be implemented by the concrete class ──────────────

  void setCoinModelsIndex(int value);
  void setChainInfo();
  Future<void> viewStateDeal(WalletConnectState state, {dynamic params});
}
