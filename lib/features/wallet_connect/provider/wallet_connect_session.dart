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

  /// Standard events exposed to DApps via WalletConnect namespaces.
  static const _namespaceEvents = ['chainChanged', 'accountsChanged'];

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
        reason: wallet_connect.Errors.getSdkError(
          wallet_connect.Errors.USER_DISCONNECTED,
        ).toSignError(),
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

  // ── Abstract methods ──────────────────────────────────────────────────────

  void cleanData();
}
