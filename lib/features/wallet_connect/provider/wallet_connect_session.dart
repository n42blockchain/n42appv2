import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_connection.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_state.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:web3dart/web3dart.dart' as web3;

/// Mixin: WalletConnect session event subscriptions, chain registration,
/// namespace building, and request dispatch.
mixin WalletConnectSession on ChangeNotifier, WalletConnectConnection {
  wallet_connect.PairingMetadata? metadata;
  Map<String, wallet_connect.Namespace>? namespace;
  dynamic actionData;
  Map<String, dynamic>? actionDataMap;

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

  /// Solana methods registered for WalletConnect session handling.
  static const _solanaMethods = [
    "solana_signTransaction",
    "solana_signMessage",
    "solana_signAndSendTransaction",
  ];

  /// Aptos methods registered for WalletConnect session handling.
  static const _aptosMethods = [
    "aptos_signTransaction",
    "aptos_signMessage",
    "aptos_signAndSubmitTransaction",
  ];

  /// Sui methods registered for WalletConnect session handling.
  static const _suiMethods = [
    "sui_signTransaction",
    "sui_signAndExecuteTransaction",
    "sui_signMessage",
  ];

  /// NEAR methods registered for WalletConnect session handling.
  static const _nearMethods = [
    "near_signTransaction",
    "near_signAndSendTransaction",
  ];

  /// Standard events exposed to DApps via WalletConnect namespaces.
  static const _namespaceEvents = ['chainChanged', 'accountsChanged'];

  /// Cached user-disconnect reason to avoid repeated construction.
  static final _userDisconnectReason = wallet_connect.Errors.getSdkError(
    wallet_connect.Errors.USER_DISCONNECTED,
  ).toSignError();

  // ── Multi-session management ──────────────────────────────────────────────

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
        reason: _userDisconnectReason,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[WalletConnect] disconnectSession($topic) error: $e');
    }
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
          reason: _userDisconnectReason,
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

  // ── Chain info and event subscriptions ───────────────────────────────────

  @override
  void setChainInfo() {
    if (eventsRegistered) return;
    eventsRegistered = true;
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
      // Log ALL raw incoming relay messages for debugging
      signClient!.core.relayClient.onRelayClientMessage.subscribe((args) {
        debugPrint('[WC] relayMessage topic=${args.topic} message=${args.message}');
      });
      signClient!.core.relayClient.onRelayClientDisconnect.subscribe((_) {
        debugPrint('[WalletConnect] Relay disconnected');
        if (dAppTopic != null) scheduleReconnect();
      });
      signClient!.core.relayClient.onRelayClientConnect.subscribe((_) {
        debugPrint('[WalletConnect] Relay connected');
        reconnectAttempts = 0;
        cancelReconnectTimer();
      });
      signClient!.core.relayClient.onRelayClientError.subscribe((_) {
        debugPrint('[WalletConnect] Relay error');
        if (dAppTopic != null) scheduleReconnect();
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

      // Debug: log what the DApp is requesting
      debugPrint('[WC] requiredNamespaces: ${args.params.requiredNamespaces}');
      debugPrint('[WC] optionalNamespaces: ${args.params.optionalNamespaces}');
      debugPrint('[WC] sessionProperties: ${args.params.sessionProperties}');
      debugPrint('[WC] proposer metadata: ${args.params.proposer.metadata}');

      final resolvedModels = _resolveChains(
        args.params.optionalNamespaces,
        args.params.requiredNamespaces,
      );
      coinModels = resolvedModels;
      coinModelsIndex = coinModels.length - 1;

      final opt = args.params.optionalNamespaces;
      final req = args.params.requiredNamespaces;

      final accounts = <String>[];
      final accountsTron = <String>[];
      final accountsSolana = <String>[];
      final accountsAptos = <String>[];
      final accountsSui = <String>[];
      final accountsNear = <String>[];
      _registerChainHandlers(
        accounts, accountsTron, accountsSolana,
        accountsAptos, accountsSui, accountsNear,
      );

      namespace = {};
      // Only include eip155 if DApp requested EVM chains (non-empty accounts)
      if (accounts.isNotEmpty) {
        namespace!['eip155'] = wallet_connect.Namespace(
          accounts: accounts,
          methods: _ethMethods,
          events: _namespaceEvents,
        );
      }
      if (accountsTron.isNotEmpty) {
        final chains = _nsChainIds('tron', opt, req);
        namespace!['tron'] = wallet_connect.Namespace(
          chains: chains.isNotEmpty ? chains.toList() : null,
          accounts: accountsTron,
          methods: _nsMethods('tron', opt, req, _tronMethods),
          events: _nsEvents('tron', opt, req),
        );
      }
      if (accountsSolana.isNotEmpty) {
        final chains = _nsChainIds('solana', opt, req);
        namespace!['solana'] = wallet_connect.Namespace(
          chains: chains.isNotEmpty ? chains.toList() : null,
          accounts: accountsSolana,
          methods: _nsMethods('solana', opt, req, _solanaMethods),
          events: _nsEvents('solana', opt, req),
        );
      }
      if (accountsAptos.isNotEmpty) {
        final chains = _nsChainIds('aptos', opt, req);
        namespace!['aptos'] = wallet_connect.Namespace(
          chains: chains.isNotEmpty ? chains.toList() : null,
          accounts: accountsAptos,
          methods: _nsMethods('aptos', opt, req, _aptosMethods),
          events: _nsEvents('aptos', opt, req),
        );
      }
      if (accountsSui.isNotEmpty) {
        final chains = _nsChainIds('sui', opt, req);
        namespace!['sui'] = wallet_connect.Namespace(
          chains: chains.isNotEmpty ? chains.toList() : null,
          accounts: accountsSui,
          methods: _nsMethods('sui', opt, req, _suiMethods),
          events: _nsEvents('sui', opt, req),
        );
      }
      if (accountsNear.isNotEmpty) {
        final chains = _nsChainIds('near', opt, req);
        namespace!['near'] = wallet_connect.Namespace(
          chains: chains.isNotEmpty ? chains.toList() : null,
          accounts: accountsNear,
          methods: _nsMethods('near', opt, req, _nearMethods),
          events: _nsEvents('near', opt, req),
        );
      }
      viewStateDeal(WalletConnectState.selectChain);
    });

    signClient!.onSessionRequest.subscribe((wallet_connect.SessionRequestEvent? args) async {
      debugPrint('[WC] onSessionRequest: method=${args?.method} chainId=${args?.chainId} params=${args?.params}');
      if (args != null) setActionDataMap(args);
    });

    signClient!.onSessionDelete.subscribe((args) async {
      debugPrint('[WC] onSessionDelete: topic=${args.topic} dAppTopic=$dAppTopic');
      if (disconnectingByUser) return;
      if (dAppTopic != null && dAppTopic == args.topic) {
        final s = wcL10n();
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
        final s = wcL10n();
        ToastUtils.show(s?.g_wc_session_expired ?? 'Session has expired');
        viewStateDeal(WalletConnectState.disconnect);
      }
    });

    signClient!.onProposalExpire.subscribe((wallet_connect.SessionProposalEvent? args) async {
      final s = wcL10n();
      viewStateDeal(WalletConnectState.error,
          params: s?.g_wc_proposal_timeout ?? 'Connection request timed out');
    });
  }

  // ── Request dispatch ──────────────────────────────────────────────────────

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
      // ── Message signing methods ─────────────────────────────────────────
      case "personal_sign":
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
        // personal_sign: data at [0], address at [1] (reversed from eth_sign)
        final isPersonalSign = eventData.method == "personal_sign";
        final address = isPersonalSign ? params[1] : params[0];
        final data = isPersonalSign ? params[0] : params[1];
        actionDataMap = _buildMessageData(networkName, address, data);
        viewStateDeal(WalletConnectState.messageSignOK);

      case "tron_signMessage":
        final params = eventData.params! as Map;
        actionDataMap = _buildMessageData(
          networkName,
          params["address"],
          params["message"],
        );
        viewStateDeal(WalletConnectState.messageSignOK);

      case "solana_signMessage":
        final params = eventData.params! as Map;
        actionDataMap = _buildMessageData(
          networkName,
          params["pubkey"] as String? ?? '',
          params["message"] as String? ?? '',
        );
        viewStateDeal(WalletConnectState.messageSignOK);

      // ── Transaction methods ─────────────────────────────────────────────
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
        _parseTronTransaction(eventData, networkName);

      case "solana_signTransaction":
      case "solana_signAndSendTransaction":
        final params = eventData.params! as Map;
        actionDataMap = {
          "network": networkName,
          "coinType": CoinType.SOL.name,
          "from": params["feePayer"] as String? ?? '',
          "to": '',
          "data": params["transaction"] as String? ?? '',
          "value": "0",
          "gas": "0",
          "signType": "transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);

      // ── Aptos ────────────────────────────────────────────────────────────
      case "aptos_signMessage":
        final params = eventData.params! as Map;
        actionDataMap = _buildMessageData(
          networkName,
          params["address"] as String? ?? '',
          params["message"] as String? ?? (params["fullMessage"] as String? ?? ''),
        );
        viewStateDeal(WalletConnectState.messageSignOK);

      case "aptos_signTransaction":
      case "aptos_signAndSubmitTransaction":
        final params = eventData.params! as Map;
        actionDataMap = {
          "network": networkName,
          "coinType": CoinType.APT.name,
          "from": '',
          "to": '',
          "data": params["encodedTransaction"] as String? ??
              (params["transaction"] as String? ?? ''),
          "value": "0",
          "gas": "0",
          "signType": "transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);

      // ── Sui ──────────────────────────────────────────────────────────────
      case "sui_signMessage":
        final params = eventData.params! as Map;
        actionDataMap = _buildMessageData(
          networkName,
          params["account"] as String? ?? '',
          params["message"] as String? ?? '',
        );
        viewStateDeal(WalletConnectState.messageSignOK);

      case "sui_signTransaction":
      case "sui_signAndExecuteTransaction":
        final params = eventData.params! as Map;
        actionDataMap = {
          "network": networkName,
          "coinType": CoinType.SUI.name,
          "from": '',
          "to": '',
          "data": params["transactionBlock"] as String? ??
              (params["transaction"] as String? ?? ''),
          "value": "0",
          "gas": "0",
          "signType": "transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);

      // ── NEAR ─────────────────────────────────────────────────────────────
      case "near_signTransaction":
      case "near_signAndSendTransaction":
        final params = eventData.params! as Map;
        // DApp sends either a single transaction or a list
        final txList = params["transactions"];
        final txData = txList is List
            ? (txList.isNotEmpty ? txList[0].toString() : '')
            : (params["transaction"] as String? ?? '');
        actionDataMap = {
          "network": networkName,
          "coinType": CoinType.NEAR.name,
          "from": '',
          "to": '',
          "data": txData,
          "value": "0",
          "gas": "0",
          "signType": "transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);

      default:
        debugPrint('[WalletConnect] Unsupported method: ${eventData.method}');
        _rejectUnsupportedMethod(eventData);
    }
  }

  /// Parse and dispatch a TRON transaction request.
  void _parseTronTransaction(wallet_connect.SessionRequestEvent eventData, String networkName) {
    final rawTronParams = eventData.params;
    if (rawTronParams == null || rawTronParams is! Map || !rawTronParams.containsKey('transaction')) {
      viewStateDeal(WalletConnectState.error, params: 'Invalid TRON transaction: missing params');
      return;
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

  // ── Chain resolution helpers ──────────────────────────────────────────────

  /// Resolve coin models from optional + required WalletConnect namespaces.
  ///
  /// Optional chains are added first; required chains not already in optional
  /// are inserted at the front of the list (higher priority).
  List<CoinModel> _resolveChains(
    Map<String, wallet_connect.RequiredNamespace> optional,
    Map<String, wallet_connect.RequiredNamespace> required,
  ) {
    final result = <CoinModel>[];
    // Track added models by address to prevent duplicates when a DApp sends
    // multiple chain IDs that map to the same coin model (e.g. ton:mainnet + ton:-239)
    final seen = <String>{};

    void addIfNew(CoinModel cm, {bool prepend = false}) {
      final key = '${cm.coin['blockchainType']}:${cm.address}';
      if (seen.add(key)) {
        if (prepend) {
          result.insert(0, cm);
        } else {
          result.add(cm);
        }
      }
    }

    // Collect optional chains
    for (final chain in optional.keys) {
      final chains = optional[chain]?.chains;
      if (chains == null) continue;
      for (final chainId in chains) {
        final cm = coinModelFind(chainId);
        if (cm != null) addIfNew(cm);
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
        if (cm != null) addIfNew(cm, prepend: true);
      }
    }

    return result;
  }

  /// Register request handlers and build account lists for all resolved chains.
  void _registerChainHandlers(
    List<String> accounts,
    List<String> accountsTron,
    List<String> accountsSolana,
    List<String> accountsAptos,
    List<String> accountsSui,
    List<String> accountsNear,
  ) {
    bool solanaRegistered = false;
    bool aptosRegistered = false;
    bool suiRegistered = false;
    bool nearRegistered = false;
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
      } else if (blockchainType == BlockchainType.Solana.name && !solanaRegistered) {
        const solanaChainId = "solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ";
        final addr = cm.address.toString();
        accountsSolana.add("$solanaChainId:$addr");
        for (final method in _solanaMethods) {
          signClient!.registerRequestHandler(chainId: solanaChainId, method: method);
        }
        signClient!.registerAccount(chainId: solanaChainId, accountAddress: addr);
        solanaRegistered = true;
      } else if (blockchainType == BlockchainType.Aptos.name && !aptosRegistered) {
        const aptosChainId = "aptos:1";
        final addr = cm.address.toString();
        accountsAptos.add("$aptosChainId:$addr");
        for (final method in _aptosMethods) {
          signClient!.registerRequestHandler(chainId: aptosChainId, method: method);
        }
        signClient!.registerAccount(chainId: aptosChainId, accountAddress: addr);
        aptosRegistered = true;
      } else if (blockchainType == BlockchainType.Sui.name && !suiRegistered) {
        const suiChainId = "sui:mainnet";
        final addr = cm.address.toString();
        accountsSui.add("$suiChainId:$addr");
        for (final method in _suiMethods) {
          signClient!.registerRequestHandler(chainId: suiChainId, method: method);
        }
        signClient!.registerAccount(chainId: suiChainId, accountAddress: addr);
        suiRegistered = true;
      } else if (blockchainType == BlockchainType.Near.name && !nearRegistered) {
        const nearChainId = "near:mainnet";
        final addr = cm.address.toString();
        accountsNear.add("$nearChainId:$addr");
        for (final method in _nearMethods) {
          signClient!.registerRequestHandler(chainId: nearChainId, method: method);
        }
        signClient!.registerAccount(chainId: nearChainId, accountAddress: addr);
        nearRegistered = true;
      }
    }
  }

  // ── Namespace proposal helpers ────────────────────────────────────────────

  /// Collect chain IDs from both optional and required namespaces for [nsKey].
  static Set<String> _nsChainIds(
    String nsKey,
    Map<String, wallet_connect.RequiredNamespace> opt,
    Map<String, wallet_connect.RequiredNamespace> req,
  ) {
    final ids = <String>{};
    for (final ns in [opt, req]) {
      final n = ns[nsKey];
      if (n?.chains != null) ids.addAll(n!.chains!);
    }
    return ids;
  }

  /// Collect methods from both optional and required namespaces for [nsKey].
  /// Falls back to [fallback] if the DApp specified nothing.
  static List<String> _nsMethods(
    String nsKey,
    Map<String, wallet_connect.RequiredNamespace> opt,
    Map<String, wallet_connect.RequiredNamespace> req,
    List<String> fallback,
  ) {
    final methods = <String>{};
    for (final ns in [opt, req]) {
      methods.addAll(ns[nsKey]?.methods ?? []);
    }
    return methods.isEmpty ? fallback : methods.toList();
  }

  /// Collect events from both optional and required namespaces for [nsKey].
  /// Returns empty list when DApp requests no events (avoids EVM-specific
  /// events like chainChanged/accountsChanged being sent to non-EVM DApps).
  static List<String> _nsEvents(
    String nsKey,
    Map<String, wallet_connect.RequiredNamespace> opt,
    Map<String, wallet_connect.RequiredNamespace> req,
  ) {
    final events = <String>{...?(opt[nsKey]?.events), ...?(req[nsKey]?.events)};
    return events.isEmpty ? const [] : events.toList();
  }

  // ── Abstract methods ──────────────────────────────────────────────────────

  void cleanData();
}
