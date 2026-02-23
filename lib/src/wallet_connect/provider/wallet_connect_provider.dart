import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/core/di/service_locator_setup.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/provider/trustdart.dart';
import 'package:n42_wallet/src/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/src/wallet_connect/widgets/wallet_connect_alert_widget.dart';
import 'package:n42_wallet/src/widgets/sheet_bottom.dart';
import 'package:eip712/eip712.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:wallet/wallet.dart' as wallet_types;
import 'package:web3dart/web3dart.dart' as web3;

/// Localized WC toast helper.
/// Uses the navigator context if available; falls back to English.
S? _wcL10n() {
  final ctx = AppGlobals.navigatorKey.currentContext;
  if (ctx == null) return null;
  try {
    return S.of(ctx);
  } catch (_) {
    return null;
  }
}

class WalletConnectProvider with ChangeNotifier, WidgetsBindingObserver {
  WalletConnectProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// 公开的刷新方法，用于通知监听者数据已更新
  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelReconnectTimer();
    web3client?.dispose();
    web3client = null;
    if (signClient != null) {
      try {
        signClient!.core.relayClient.disconnect();
      } catch (e) {
        if (kDebugMode) debugPrint('[WalletConnect] disconnect error: $e');
      }
      signClient = null;
    }
    // 清除敏感数据，避免内存泄漏
    actionData = null;
    actionDataMap = {};
    errorMessage = '';
    super.dispose();
  }

  // ── App lifecycle ──────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  /// Called when app returns to foreground.
  /// Re-establishes the relay WebSocket that may have been closed by the OS,
  /// then pings the DApp to verify the session is still alive.
  void _onAppResumed() {
    if (signClient == null || dAppTopic == null) return;
    try {
      signClient!.core.relayClient.connect().then((_) {
        // After relay is up, ping the DApp to verify session health.
        _pingSession();
      }).catchError((e) {
        debugPrint('[WalletConnect] Resume relay reconnect error: $e');
        _scheduleReconnect();
      });
    } catch (e) {
      debugPrint('[WalletConnect] Resume relay reconnect: $e');
    }
  }

  /// Ping the active DApp session to verify it's still alive.
  /// If the ping fails, the session is stale — notify and disconnect.
  Future<void> _pingSession() async {
    final topic = dAppTopic;
    if (topic == null || signClient == null) return;
    try {
      await signClient!.reOwnSign.ping(topic: topic).timeout(
        const Duration(seconds: 10),
      );
      debugPrint('[WalletConnect] Session ping OK');
    } catch (e) {
      debugPrint('[WalletConnect] Session ping failed: $e');
      final s = _wcL10n();
      ToastUtils.show(s?.g_wc_session_expired ?? 'Session has expired');
      viewStateDeal(WalletConnectState.disconnect);
    }
  }

  // ── Reconnect timer ───────────────────────────────────────────────────────

  Timer? _reconnectTimer;
  static const _maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;

  void _scheduleReconnect() {
    _cancelReconnectTimer();
    if (signClient == null || _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts && dAppTopic != null) {
        final s = _wcL10n();
        ToastUtils.show(s?.g_wc_connection_lost ?? 'Connection lost. Please reconnect.');
        viewStateDeal(WalletConnectState.disconnect);
      }
      return;
    }
    // Exponential back-off: 2s, 4s, 8s, 16s, 30s
    final seconds = (_reconnectAttempts < 4) ? (2 << _reconnectAttempts) : 30;
    _reconnectTimer = Timer(Duration(seconds: seconds), _tryReconnect);
    debugPrint('[WalletConnect] Reconnect attempt ${_reconnectAttempts + 1} in ${seconds}s');
  }

  Future<void> _tryReconnect() async {
    _reconnectAttempts++;
    try {
      await signClient!.core.relayClient.connect();
      _reconnectAttempts = 0;
      debugPrint('[WalletConnect] Relay reconnected');
    } catch (e) {
      debugPrint('[WalletConnect] Reconnect #$_reconnectAttempts failed: $e');
      _scheduleReconnect();
    }
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Trustdart? _trustdart;
  Trustdart get trustdart {
    _trustdart ??= Trustdart();
    return _trustdart!;
  }

  bool pageOpen = false;
  wallet_connect.ReownWalletKit? signClient;
  web3.Web3Client? web3client;
  String? dAppTopic;

  /// Guard: prevent duplicate WalletKit event subscriptions when connectInit
  /// is called again (e.g. user scans a new QR after disconnect).
  bool _eventsRegistered = false;

  /// True while the user-initiated disconnect is in progress.
  /// Suppresses the DApp-disconnect Toast from [onSessionDelete] in that window.
  bool _disconnectingByUser = false;

  late web3.EthPrivateKey privateKey;
  int coinModelsIndex = -1;
  List<CoinModel> coinModels = [];
  Map<String, wallet_connect.Namespace>? namespace;
  WalletConnectState walletConnectState = WalletConnectState.loading;
  String errorMessage = "";
  wallet_connect.PairingMetadata? metadata;
  Load load = Load.finish;
  dynamic actionData;
  Map<String, dynamic>? actionDataMap;

  void setCoinModelsIndex(int value) {
    coinModelsIndex = value;
    notifyListeners();
  }

  // ── Multi-session management ─────────────────────────────────────────────

  /// Returns all active WalletConnect sessions from the SDK's persistent store.
  Map<String, wallet_connect.SessionData> getActiveSessions() {
    if (signClient == null) return {};
    try {
      return signClient!.getActiveSessions();
    } catch (e) {
      if (kDebugMode) debugPrint('[WalletConnect] getActiveSessions error: $e');
      return {};
    }
  }

  /// Disconnect a specific session by its topic.
  Future<void> disconnectSessionByTopic(String topic) async {
    if (signClient == null) return;
    try {
      await signClient!.disconnectSession(
        topic: topic,
        reason: wallet_connect.Errors.getSdkError(
          wallet_connect.Errors.USER_DISCONNECTED,
        ).toSignError(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[WalletConnect] disconnectSession($topic) error: $e');
    }
    // If the disconnected session is the current one, clean up local state
    if (dAppTopic == topic) {
      cleanData();
    }
    notifyListeners();
  }

  /// Disconnect all active sessions.
  Future<void> disconnectAllSessions() async {
    final sessions = getActiveSessions();
    for (final topic in sessions.keys.toList()) {
      try {
        await signClient!.disconnectSession(
          topic: topic,
          reason: wallet_connect.Errors.getSdkError(
            wallet_connect.Errors.USER_DISCONNECTED,
          ).toSignError(),
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[WalletConnect] disconnectAll($topic) error: $e');
      }
    }
    cleanData();
    notifyListeners();
  }

  /// Set the active session context when user taps a session from the list.
  void setActiveSession(wallet_connect.SessionData session) {
    dAppTopic = session.topic;
    metadata = session.peer.metadata;
    walletConnectState = WalletConnectState.connect;
    notifyListeners();
  }

  Future<void> setActionDataMap(wallet_connect.SessionRequestEvent eventData) async {
    if (eventData.params == null) {
      viewStateDeal(WalletConnectState.error, params: 'Invalid request: params is null');
      return;
    }
    if (coinModelsIndex < 0 || coinModelsIndex >= coinModels.length) {
      viewStateDeal(WalletConnectState.error, params: 'No valid chain selected');
      return;
    }

    // Resolve the correct session metadata for this request's topic
    // so the signing popup shows the right DApp info.
    final sessions = getActiveSessions();
    final session = sessions[eventData.topic];
    if (session != null) {
      metadata = session.peer.metadata;
      // Track permission usage for this DApp origin (fire-and-forget)
      final origin = Uri.tryParse(session.peer.metadata.url)?.host ?? '';
      unawaited(DAppPermissionsTracker.record(origin, eventData.method));
    }

    // Assign actionData BEFORE dispatching so UI reads the correct event
    actionData = eventData;
    final initOk = await web3clientInitFromChainId(eventData.chainId);
    if (!initOk) return;

    final networkName = coinModels[coinModelsIndex].coin['name'];

    switch (eventData.method) {
      // ── Message signing methods ──────────────────────────────────────────
      case "personal_sign":
        final params = (eventData.params! as List).cast<String>();
        if (params.length < 2) {
          viewStateDeal(WalletConnectState.error,
              params: 'Invalid personal_sign params: expected 2, got ${params.length}');
          return;
        }
        // personal_sign: data at [0], address at [1] (reversed from eth_sign)
        actionDataMap = _buildMessageData(networkName, params[1], params[0]);
        viewStateDeal(WalletConnectState.messageSignOK);

      case "eth_sign":
      case "eth_signTypedData":
      case "eth_signTypedData_v3":
      case "eth_signTypedData_v4":
        final params = (eventData.params! as List).cast<String>();
        if (params.length < 2) {
          viewStateDeal(WalletConnectState.error,
              params: 'Invalid ${eventData.method} params: expected 2, got ${params.length}');
          return;
        }
        // eth_sign / signTypedData: address at [0], data at [1]
        actionDataMap = _buildMessageData(networkName, params[0], params[1]);
        viewStateDeal(WalletConnectState.messageSignOK);

      case "tron_signMessage":
        final params = eventData.params! as Map;
        actionDataMap = _buildMessageData(
          networkName,
          params["address"],
          params["message"],
        );
        viewStateDeal(WalletConnectState.messageSignOK);

      // ── Transaction methods ──────────────────────────────────────────────
      case "eth_signTransaction":
      case "eth_sendTransaction":
        final trMap = eventData.params![0] as Map<String, dynamic>;
        actionDataMap = {
          "network": networkName,
          "coinType": coinModels[coinModelsIndex].coin['coinType'] ?? '',
          "gas": web3.hexToInt(trMap['gas'] ?? "0x0").toInt().toString(),
          "from": trMap['from'] ?? "0x",
          "to": trMap['to'] ?? "0x",
          "data": trMap['data'] ?? "0x",
          "value": trMap['value'] ?? "0x0",
          "signType": "transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);

      case "tron_signTransaction":
        final rawTronParams = eventData.params;
        if (rawTronParams == null || rawTronParams is! Map || !rawTronParams.containsKey('transaction')) {
          viewStateDeal(WalletConnectState.error, params: 'Invalid TRON transaction: missing params');
          break;
        }
        final trMap = Map<String, dynamic>.from(rawTronParams['transaction'] as Map);
        final tronInnerTx = trMap['transaction'] as Map<String, dynamic>? ?? {};
        final tronRawData = tronInnerTx['raw_data'] as Map<String, dynamic>? ?? {};
        final tronContractRaw = tronRawData['contract'];
        String tronContractType = '';
        Map<String, dynamic> tronContractValue = {};
        if (tronContractRaw is List && tronContractRaw.isNotEmpty) {
          final item = tronContractRaw[0] as Map<String, dynamic>;
          tronContractType = item['type'] as String? ?? '';
          tronContractValue = (item['parameter']?['value'] as Map<String, dynamic>?) ?? {};
        } else if (tronContractRaw is Map<String, dynamic>) {
          tronContractType = tronContractRaw['type'] as String? ?? '';
          tronContractValue = (tronContractRaw['parameter']?['value'] as Map<String, dynamic>?) ?? {};
        }
        final tronOwnerAddr = tronContractValue['owner_address'] as String? ?? '';
        final tronToAddr = tronContractValue['to_address'] as String? ?? '';
        final tronContractAddr = tronContractValue['contract_address'] as String? ?? '';
        final tronFeeLimit = tronRawData['fee_limit'] as int? ?? 0;
        final isTrc20 = tronContractType == 'TriggerSmartContract';
        actionDataMap = {
          "network": networkName,
          "gas": tronFeeLimit.toString(),
          "from": tronOwnerAddr,
          "to": isTrc20 ? tronContractAddr : tronToAddr,
          "data": tronInnerTx['raw_data_hex'] as String? ?? "",
          "signType": "transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);

      default:
        debugPrint('[WalletConnect] Unsupported method: ${eventData.method}');
        _rejectUnsupportedMethod(eventData);
    }
  }

  /// Build a standard message-sign action data map.
  Map<String, dynamic> _buildMessageData(String network, String address, String data) {
    return {
      "network": network,
      "from": address,
      "data": data,
      "signType": "message",
    };
  }

  /// Reject an unsupported method with a JSON-RPC error so the DApp
  /// doesn't hang indefinitely waiting for a response.
  void _rejectUnsupportedMethod(wallet_connect.SessionRequestEvent eventData) {
    try {
      signClient?.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          error: wallet_connect.JsonRpcError(
            code: 4200,
            message: 'Unsupported method: ${eventData.method}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('[WalletConnect] Error rejecting unsupported method: $e');
    }
  }
  Future<void> connectInit() async {
    try {
      if (signClient != null) {
        coinModelInit();
        return;
      }
      signClient = await wallet_connect.ReownWalletKit.createInstance(
        projectId: "18a60a7cb862aad161fecd764ecc736a",
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

  Future<void> pair(String relayUrl) async {
    try {
      final uri = Uri.tryParse(relayUrl);
      if (uri != null) {
        await signClient!.pair(uri: uri);
      }
      notifyListeners();
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  Future<bool> web3clientInit() async {
    try {
      CoinModel cm = coinModels[coinModelsIndex];
      web3client = web3.Web3Client(cm.isTest ? cm.coin['service_test'] : cm.coin['service'], Client());
      
      // 使用 IWalletService 获取当前钱包的私钥和助记词
      final walletService = ServiceLocatorSetup.walletService;
      if (walletService == null) {
        viewStateDeal(WalletConnectState.error, params: "Wallet service not available");
        return false;
      }
      
      final currentIndex = walletService.miningWalletIndex >= 0 
          ? walletService.miningWalletIndex 
          : 0;
      String? pKey = await walletService.getPrivateKeyForWallet(currentIndex);
      
      if (pKey == null) {
        final mnemonic = await walletService.getMnemonicForWallet(currentIndex);
        if (mnemonic != null) {
          pKey = await trustdart.getPrivateKey(mnemonic, cm.coin['coinType'], getPathWithIndex(cm.coin['path']['legacy'], cm.pathIndex));
        }
      }
      
      if (pKey == null) {
        viewStateDeal(WalletConnectState.error, params: "Could not get private key");
        return false;
      }
      
      // 验证 base64 格式并确认解码后为 32 字节私钥
      final Uint8List decodedKey;
      try {
        decodedKey = base64Decode(pKey);
      } on FormatException catch (e) {
        viewStateDeal(WalletConnectState.error, params: 'Invalid private key encoding: ${e.message}');
        return false;
      }
      if (decodedKey.length != 32) {
        viewStateDeal(WalletConnectState.error, params: 'Invalid private key length: expected 32 bytes');
        return false;
      }
      privateKey = web3.EthPrivateKey(decodedKey);
      return true;
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
      return false;
    }
  }
  Future<bool> web3clientInitFromChainId(String eip155) async {
    final chainId = eip155.split(":")[1];
    final chainIndex = coinModels.indexWhere((element) {
      final eChainId = (element.isTest ? element.coin['chainId_test'] : element.coin['chainId']).toString();
      return eChainId == chainId;
    });
    if (chainIndex == -1) {
      viewStateDeal(WalletConnectState.error, params: "Error");
      return false;
    }
    if (coinModelsIndex != chainIndex) {
      setCoinModelsIndex(chainIndex);
      return await web3clientInit();
    }
    if (web3client == null) {
      return await web3clientInit();
    }
    return true;
  }

  void coinModelInit({int chainId = -1}) {
    try {
      final cms = globalWapAdapter.coinModels;
      coinModels = [];
      for (final cm in cms) {
        if (cm.coin['blockchainType'] != BlockchainType.Ethereum.name) continue;
        coinModels.add(cm);
        if (chainId != -1) {
          final cmChainId = cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId'];
          if (cmChainId == chainId) {
            setCoinModelsIndex(coinModels.length - 1);
          }
        }
      }
      if (coinModels.isNotEmpty && chainId == -1) {
        setCoinModelsIndex(0);
      }
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  /// Find a coin model matching the given WalletConnect chain ID string.
  CoinModel? coinModelFind(String chainId) {
    final index = coinModels.indexWhere((element) {
      final blockchainType = element.coin['blockchainType'];
      if (blockchainType == BlockchainType.Ethereum.name) {
        final id = element.isTest ? element.coin['chainId_test'] : element.coin['chainId'];
        return "eip155:$id" == chainId;
      } else if (blockchainType == BlockchainType.Tron.name) {
        return "tron:0x2b6653dc" == chainId;
      }
      return false;
    });
    return index == -1 ? null : coinModels[index];
  }

  /// EIP-155 methods registered per chain for WalletConnect session handling.
  static const _ethMethods = [
    "eth_sendTransaction",
    "eth_signTransaction",
    "eth_sign",
    "personal_sign",
    "eth_signTypedData",
    "eth_signTypedData_v3",
    "eth_signTypedData_v4",
  ];

  /// TRON methods registered for WalletConnect session handling.
  static const _tronMethods = [
    "tron_signTransaction",
    "tron_signMessage",
  ];

  /// Standard events exposed to DApps via WalletConnect namespaces.
  static const _namespaceEvents = ['chainChanged', 'accountsChanged'];

  void setChainInfo() {
    if (_eventsRegistered) return;
    _eventsRegistered = true;
    try {
      if (signClient == null) return;

      _subscribeRelayEvents();
      _subscribeSessionEvents();
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  /// Subscribe to relay-level connect/disconnect/error events.
  void _subscribeRelayEvents() {
    try {
      signClient!.core.relayClient.onRelayClientDisconnect.subscribe((_) {
        debugPrint('[WalletConnect] Relay disconnected');
        if (dAppTopic != null) _scheduleReconnect();
      });
      signClient!.core.relayClient.onRelayClientConnect.subscribe((_) {
        debugPrint('[WalletConnect] Relay connected');
        _reconnectAttempts = 0;
        _cancelReconnectTimer();
      });
      signClient!.core.relayClient.onRelayClientError.subscribe((_) {
        debugPrint('[WalletConnect] Relay error');
        if (dAppTopic != null) _scheduleReconnect();
      });
    } catch (e) {
      debugPrint('[WalletConnect] Relay event subscription unavailable: $e');
    }
  }

  /// Subscribe to session-level WalletKit events (proposal, request, delete, etc.).
  void _subscribeSessionEvents() {
    signClient!.onSessionProposal.subscribe((wallet_connect.SessionProposalEvent? args) async {
      if (args == null) {
        viewStateDeal(WalletConnectState.error, params: "Error");
        return;
      }
      actionData = args;
      metadata = args.params.proposer.metadata;

      final resolvedModels = _resolveChains(
        args.params.optionalNamespaces,
        args.params.requiredNamespaces,
      );
      coinModels = resolvedModels;
      coinModelsIndex = coinModels.length - 1;

      final accounts = <String>[];
      final accountsTron = <String>[];
      _registerChainHandlers(accounts, accountsTron);

      namespace = {
        "eip155": wallet_connect.Namespace(
          accounts: accounts,
          methods: _ethMethods,
          events: _namespaceEvents,
        ),
      };
      if (accountsTron.isNotEmpty) {
        namespace!['tron'] = wallet_connect.Namespace(
          accounts: accountsTron,
          methods: _tronMethods,
          events: _namespaceEvents,
        );
      }
      viewStateDeal(WalletConnectState.selectChain);
    });

    signClient!.onSessionRequest.subscribe((wallet_connect.SessionRequestEvent? args) async {
      if (args != null) setActionDataMap(args);
    });

    signClient!.onSessionDelete.subscribe((args) async {
      if (_disconnectingByUser) return;
      if (dAppTopic != null && dAppTopic == args.topic) {
        final s = _wcL10n();
        ToastUtils.show(s?.g_wc_dapp_disconnected ?? 'DApp has disconnected');
        viewStateDeal(WalletConnectState.disconnect);
      } else {
        notifyListeners();
      }
    });

    signClient!.onSessionProposalError.subscribe((wallet_connect.SessionProposalErrorEvent? args) async {
      viewStateDeal(WalletConnectState.error, params: args?.error.message ?? "Error");
    });

    signClient!.onSessionExpire.subscribe((args) async {
      if (dAppTopic != null) {
        final s = _wcL10n();
        ToastUtils.show(s?.g_wc_session_expired ?? 'Session has expired');
        viewStateDeal(WalletConnectState.disconnect);
      }
    });

    signClient!.onProposalExpire.subscribe((wallet_connect.SessionProposalEvent? args) async {
      final s = _wcL10n();
      viewStateDeal(WalletConnectState.error, params: s?.g_wc_proposal_timeout ?? 'Connection request timed out');
    });
  }

  /// Resolve coin models from optional + required WalletConnect namespaces.
  ///
  /// Optional chains are added first; required chains not already in optional
  /// are inserted at the front of the list (higher priority).
  List<CoinModel> _resolveChains(
    Map<String, wallet_connect.RequiredNamespace> optional,
    Map<String, wallet_connect.RequiredNamespace> required,
  ) {
    final result = <CoinModel>[];

    // Collect optional chains
    for (final chain in optional.keys) {
      final chains = optional[chain]?.chains;
      if (chains == null) continue;
      for (final chainId in chains) {
        final cm = coinModelFind(chainId);
        if (cm != null) result.add(cm);
      }
    }

    // Collect required chains not already covered by optional
    final optionalSets = <String, Set<String>>{};
    for (final key in optional.keys) {
      optionalSets[key] = Set<String>.from(optional[key]?.chains ?? []);
    }

    for (final chain in required.keys) {
      final chains = required[chain]?.chains;
      if (chains == null) continue;
      final alreadyCovered = optionalSets[chain] ?? <String>{};
      for (final chainId in chains) {
        if (alreadyCovered.contains(chainId)) continue;
        final cm = coinModelFind(chainId);
        if (cm != null) result.insert(0, cm);
      }
    }

    return result;
  }

  /// Register request handlers and build account lists for all resolved chains.
  void _registerChainHandlers(List<String> accounts, List<String> accountsTron) {
    for (int i = coinModels.length - 1; i >= 0; i--) {
      final cm = coinModels[i];
      final blockchainType = cm.coin['blockchainType'];

      if (blockchainType == BlockchainType.Ethereum.name) {
        final chainId = "eip155:${cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId']}";
        final addr = cm.address.toString();
        accounts.add("$chainId:$addr");
        for (final method in _ethMethods) {
          signClient!.registerRequestHandler(chainId: chainId, method: method);
        }
        signClient!.registerAccount(chainId: chainId, accountAddress: addr);
      } else if (blockchainType == BlockchainType.Tron.name) {
        const tronChainId = "tron:0x2b6653dc";
        final addr = cm.address.toString();
        accountsTron.add("$tronChainId:$addr");
        for (final method in _tronMethods) {
          signClient!.registerRequestHandler(chainId: tronChainId, method: method);
        }
        signClient!.registerAccount(chainId: tronChainId, accountAddress: addr);
      }
    }
  }

  /// Map method name to EIP-712 typed data version.
  static const _typedDataVersions = {
    "eth_signTypedData": TypedDataVersion.v4,
    "eth_signTypedData_v3": TypedDataVersion.v3,
    "eth_signTypedData_v4": TypedDataVersion.v4,
  };

  Future<void> messageSignTap() async {
    try {
      if (walletConnectState == WalletConnectState.messageSign) return;
      viewStateDeal(WalletConnectState.messageSign);
      final eventData = actionData as wallet_connect.SessionRequestEvent;
      String signedDataHex;

      if (eventData.method == "personal_sign") {
        final requestParams = (eventData.params! as List).cast<String>();
        final rawData = requestParams[0];
        // DApps may send either hex-encoded bytes (0xdeadbeef) or plain
        // UTF-8 text (e.g. SIWE messages). Detect and decode accordingly.
        final stripped = web3.strip0x(rawData);
        final encodedMessage = _isValidHex(stripped)
            ? web3.hexToBytes(stripped)
            : Uint8List.fromList(utf8.encode(rawData));
        final signedData = privateKey.signPersonalMessageToUint8List(encodedMessage);
        signedDataHex = bytesToHex(signedData, include0x: true);

      } else if (_typedDataVersions.containsKey(eventData.method)) {
        final requestParams = (eventData.params! as List).cast<String>();
        signedDataHex = _signTypedData(
          privateKey: privateKey,
          jsonData: requestParams[1],
          version: _typedDataVersions[eventData.method]!,
        );

      } else if (eventData.method == "tron_signMessage") {
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.TRX.name).firstOrNull;
        if (cm == null) {
          viewStateDeal(WalletConnectState.error, params: 'TRON chain not supported');
          return;
        }
        final credentials = await _getTronCredentials();
        final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
        signedDataHex = await trustdart.signMessage(
          CoinType.TRX.name, path, dataToSign,
          mnemonic: credentials.mnemonic, pk: credentials.privateKey,
        );

      } else {
        final requestParams = (eventData.params! as List).cast<String>();
        final dataToSign = web3.strip0x(requestParams[1]);
        if (coinModels[coinModelsIndex].coin['coinType'] == CoinType.N.name) {
          signedDataHex = await trustdart.signMessage(
            CoinType.N.name, "", dataToSign,
            pk: base64Encode(privateKey.privateKey),
          );
          signedDataHex = "0x$signedDataHex";
        } else {
          final encodedMessage = web3.hexToBytes(dataToSign);
          final signedData = privateKey.signPersonalMessageToUint8List(encodedMessage);
          signedDataHex = bytesToHex(signedData, include0x: true);
        }
      }

      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(id: eventData.id, result: signedDataHex),
      );
      viewStateDeal(WalletConnectState.connect);
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }
  Future<void> transactionSignTap() async {
    try {
      if (walletConnectState == WalletConnectState.transaction) return;
      viewStateDeal(WalletConnectState.transaction);
      final eventData = actionData as wallet_connect.SessionRequestEvent;
      final initOk = await web3clientInitFromChainId(eventData.chainId);
      if (!initOk) return;

      if (eventData.method == "tron_signTransaction") {
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.TRX.name).firstOrNull;
        if (cm == null) {
          viewStateDeal(WalletConnectState.error, params: 'TRON chain not supported');
          return;
        }
        final credentials = await _getTronCredentials();
        final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
        final returnStr = await trustdart.signTransaction(
          CoinType.TRX.name, path, dataToSign,
          mnemonic: credentials.mnemonic, pk: credentials.privateKey,
        );
        signClient!.respondSessionRequest(
          topic: eventData.topic,
          response: wallet_connect.JsonRpcResponse(id: eventData.id, result: returnStr),
        );
        viewStateDeal(WalletConnectState.connect);
        return;
      }

      final parameters = eventData.params.first as Map<String, dynamic>;
      final from = parameters['from'] as String;
      final to = parameters['to'] as String?;
      final value = parameters['value'] as String?;
      final nonce = parameters['nonce'] as String?;
      final gasPrice = parameters['gasPrice'] as String?;
      final maxFeePerGas = parameters['maxFeePerGas'] as String?;
      final maxPriorityFeePerGas = parameters['maxPriorityFeePerGas'] as String?;
      final gasLimit = parameters['gasLimit'] as String?;
      final data = parameters['data'] as String?;

      final transaction = web3.Transaction(
        from: wallet_types.EthereumAddress.fromHex(from),
        to: wallet_types.EthereumAddress.fromHex(to ?? "0x"),
        value: wallet_types.EtherAmount.fromBigInt(
          wallet_types.EtherUnit.wei,
          BigInt.tryParse(value ?? "0x") ?? BigInt.zero,
        ),
        gasPrice: gasPrice != null
            ? wallet_types.EtherAmount.fromBigInt(wallet_types.EtherUnit.gwei, BigInt.tryParse(gasPrice) ?? BigInt.zero)
            : null,
        maxFeePerGas: maxFeePerGas != null
            ? wallet_types.EtherAmount.fromBigInt(wallet_types.EtherUnit.gwei, BigInt.tryParse(maxFeePerGas) ?? BigInt.zero)
            : null,
        maxPriorityFeePerGas: maxPriorityFeePerGas != null
            ? wallet_types.EtherAmount.fromBigInt(wallet_types.EtherUnit.gwei, BigInt.tryParse(maxPriorityFeePerGas) ?? BigInt.zero)
            : null,
        maxGas: int.tryParse(gasLimit ?? ''),
        nonce: int.tryParse(nonce ?? ''),
        data: (data != null && data != '0x') ? web3.hexToBytes(data) : null,
      );

      String returnStr;
      if (eventData.method == "eth_signTransaction") {
        final sig = await web3client!.signTransaction(privateKey, transaction);
        returnStr = bytesToHex(sig, include0x: true);
      } else {
        final cm = coinModels[coinModelsIndex];
        returnStr = await web3client!.sendTransaction(
          privateKey,
          transaction,
          chainId: cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId'],
        );
      }

      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(id: eventData.id, result: returnStr),
      );
      viewStateDeal(WalletConnectState.connect);
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  Future<void> cancelTap(WalletConnectState state) async {
    viewStateDeal(state);
    try {
      final eventData = actionData as wallet_connect.SessionRequestEvent;
      await signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          error: wallet_connect.JsonRpcError(
            code: 4001,
            message: "User rejected.",
          ),
        ),
      );
    } catch (e) {
      debugPrint('[WalletConnect] Cancel respond error: $e');
    }
    viewStateDeal(WalletConnectState.connect);
  }
  Future<void> disconnectOnTap() async {
    final topic = dAppTopic;
    if (topic == null) {
      // Nothing to disconnect; just reset state.
      viewStateDeal(WalletConnectState.disconnect);
      return;
    }
    _disconnectingByUser = true;
    try {
      await signClient!.disconnectSession(
        topic: topic,
        reason: wallet_connect.Errors.getSdkError(
          wallet_connect.Errors.USER_DISCONNECTED,
        ).toSignError(),
      );
    } catch (e) {
      // Session may already be gone (e.g. network drop, DApp crashed).
      // We still want to clean up local state.
      if (kDebugMode) debugPrint('[WalletConnect] Disconnect error: $e');
    } finally {
      _disconnectingByUser = false;
      viewStateDeal(WalletConnectState.disconnect);
    }
  }
  Future<void> viewStateDeal(WalletConnectState state, {dynamic params}) async {
    switch (state) {
      case WalletConnectState.loading:
        await connectInit();
        await pair(params as String);
      case WalletConnectState.connectOK:
        final args = actionData as wallet_connect.SessionProposalEvent;
        try {
          signClient!.approveSession(id: args.id, namespaces: namespace!).then((value) async {
            dAppTopic = value.topic;
            viewStateDeal(WalletConnectState.connect);
          }).catchError((error) {
            ToastUtils.show(error.toString());
            viewStateDeal(WalletConnectState.disconnect);
          });
        } catch (e) {
          ToastUtils.show("Connection error: ${e.toString()}");
          viewStateDeal(WalletConnectState.disconnect);
        }
      case WalletConnectState.disconnect:
        cleanData();
      case WalletConnectState.transactionOK:
      case WalletConnectState.messageSignOK:
        if (!pageOpen) showAlertWidget();
      case WalletConnectState.error:
        errorMessage = params as String;
      case WalletConnectState.selectChain:
      case WalletConnectState.connect:
      case WalletConnectState.reconnect:
      case WalletConnectState.transaction:
      case WalletConnectState.messageSign:
        break;
    }
    walletConnectState = state;
    notifyListeners();
  }

  void showAlertWidget() {
    final ctx = AppGlobals.navigatorKey.currentContext;
    if (ctx == null || metadata == null || actionDataMap == null) {
      debugPrint('[WalletConnect] Cannot show alert: context or data is null');
      return;
    }
    sheetBottom(ctx, "", WalletConnectAlertWidget(metadata!, actionDataMap!));
  }

  void cleanData() {
    _cancelReconnectTimer();
    _reconnectAttempts = 0;
    dAppTopic = null;
    errorMessage = "";
    walletConnectState = WalletConnectState.loading;
  }

  void cleanDataLogout() {
    if (dAppTopic != null) {
      disconnectOnTap();
    } else {
      cleanData();
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Fetch TRON wallet credentials from IWalletService.
  Future<({String mnemonic, String privateKey})> _getTronCredentials() async {
    final walletService = ServiceLocatorSetup.walletService;
    final currentIndex = walletService?.miningWalletIndex ?? 0;
    final mnemonic = await walletService?.getMnemonicForWallet(currentIndex) ?? "";
    final pk = await walletService?.getPrivateKeyForWallet(currentIndex) ?? "";
    return (mnemonic: mnemonic, privateKey: pk);
  }

  /// Returns true if [s] contains only hex characters (0-9, a-f, A-F).
  /// Empty string returns false to avoid creating a zero-length byte array.
  static bool _isValidHex(String s) {
    if (s.isEmpty) return false;
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);
  }

  /// Sign typed data using EIP-712 standard.
  ///
  /// IMPORTANT: [hashTypedData] already returns keccak256(0x1901 ‖ domainHash ‖ messageHash).
  /// We must sign this hash DIRECTLY with secp256k1 — do NOT use [signToEcSignature]
  /// which internally calls keccak256 again, producing an invalid double-hashed signature.
  String _signTypedData({
    required web3.EthPrivateKey privateKey,
    required String jsonData,
    required TypedDataVersion version,
  }) {
    // Parse and validate JSON
    final Map<String, dynamic> typedData = json.decode(jsonData);
    const requiredFields = ['types', 'primaryType', 'domain', 'message'];
    for (final field in requiredFields) {
      if (!typedData.containsKey(field)) {
        throw FormatException(
          'Invalid EIP-712 data: missing required field "$field"',
        );
      }
    }

    final typedMessage = TypedMessage.fromJson(typedData);

    // hashTypedData returns the final 32-byte keccak256 hash — ready to sign
    final hash = hashTypedData(
      typedData: typedMessage,
      version: version,
    );

    // Sign the pre-hashed data directly via secp256k1.
    // ecSign does NOT hash again; it signs the raw 32-byte digest.
    // The returned v is already recovery + 27 (i.e. 27 or 28).
    final signature = web3.sign(hash, privateKey.privateKey);

    // Encode to 65-byte hex: r (32 bytes) + s (32 bytes) + v (1 byte)
    final r = signature.r.toRadixString(16).padLeft(64, '0');
    final s = signature.s.toRadixString(16).padLeft(64, '0');
    final v = signature.v.toRadixString(16).padLeft(2, '0');

    return '0x$r$s$v';
  }
}
enum WalletConnectState {
  loading,
  selectChain,
  connectOK,
  connect,
  disconnect,
  reconnect,
  transactionOK,
  transaction,
  messageSignOK,
  messageSign,
  error,
}