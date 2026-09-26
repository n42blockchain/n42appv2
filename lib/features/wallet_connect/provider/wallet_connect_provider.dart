import 'package:flutter/widgets.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/utils/safe_change_notifier.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_connection.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_session.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_signing.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_state.dart';
import 'package:n42_wallet/features/wallet_connect/widgets/wallet_connect_alert_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;

export 'wallet_connect_state.dart' show WalletConnectState;

class WalletConnectProvider
    with
        ChangeNotifier,
        SafeChangeNotifierMixin,
        WidgetsBindingObserver,
        WalletConnectConnection,
        WalletConnectSession,
        WalletConnectSigning {
  WalletConnectProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  bool pageOpen = false;
  Load load = Load.finish;
  String errorMessage = "";

  /// Public refresh — notifies listeners without a state transition.
  void refresh() {
    notifyListeners();
  }

  @override
  void setCoinModelsIndex(int value) {
    coinModelsIndex = value;
    notifyListeners();
  }

  // ── App lifecycle ──────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cancelReconnectTimer();
    web3client?.dispose();
    web3client = null;
    if (signClient != null) {
      try {
        signClient!.core.heartbeat.stop();
        signClient!.core.relayClient.disconnect();
      } catch (e) {
        AppLogger.w('WalletConnect', 'disconnect error: $e');
      }
      signClient = null;
    }
    // Clear sensitive data to avoid memory leaks
    actionData = null;
    actionDataMap = {};
    errorMessage = '';
    super.dispose();
  }

  // ── State machine ──────────────────────────────────────────────────────────

  @override
  Future<void> viewStateDeal(WalletConnectState state, {dynamic params}) async {
    switch (state) {
      case WalletConnectState.loading:
        await connectInit();
        if (walletConnectState == WalletConnectState.error ||
            signClient == null) {
          return;
        }
        if (params is! String || params.isEmpty) {
          viewStateDeal(
            WalletConnectState.error,
            params: 'Missing WalletConnect URI',
          );
          return;
        }
        final paired = await pair(params);
        if (!paired || walletConnectState == WalletConnectState.error) {
          return;
        }
      case WalletConnectState.connectOK:
        if (actionData is! wallet_connect.SessionProposalEvent) {
          viewStateDeal(
            WalletConnectState.error,
            params: 'Invalid session proposal data',
          );
          return;
        }
        final args = actionData as wallet_connect.SessionProposalEvent;
        try {
          AppLogger.d('WalletConnect', 'approveSession namespace: $namespace');
          signClient!
              .approveSession(
                id: args.id,
                namespaces: namespace!,
                sessionProperties: args.params.sessionProperties,
              )
              .then((value) async {
                AppLogger.d(
                  'WalletConnect',
                  'approveSession OK topic=${value.topic}',
                );
                dAppTopic = value.topic;
                viewStateDeal(WalletConnectState.connect);
              })
              .catchError((error) {
                AppLogger.w('WalletConnect', 'approveSession error: $error');
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
        showAlertWidget();
      case WalletConnectState.error:
        errorMessage = (params as String?) ?? 'Unknown error';
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

  // ── UI helpers ─────────────────────────────────────────────────────────────

  void showAlertWidget() {
    final ctx = AppGlobals.navigatorKey.currentContext;
    if (ctx == null || metadata == null || actionDataMap == null) {
      AppLogger.w(
        'WalletConnect',
        'cannot show alert: context or data is null',
      );
      return;
    }
    sheetBottom(ctx, "", WalletConnectAlertWidget(metadata!, actionDataMap!));
  }

  // ── Session user actions ───────────────────────────────────────────────────

  Future<void> cancelTap(WalletConnectState state) async {
    viewStateDeal(state);
    try {
      if (actionData is! wallet_connect.SessionRequestEvent) {
        AppLogger.w(
          'WalletConnect',
          'cancelTap: actionData is not SessionRequestEvent',
        );
        viewStateDeal(WalletConnectState.connect);
        return;
      }
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
      AppLogger.w('WalletConnect', 'cancel respond error: $e');
    }
    viewStateDeal(WalletConnectState.connect);
  }

  Future<void> disconnectOnTap() async {
    final topic = dAppTopic;
    if (topic == null) {
      viewStateDeal(WalletConnectState.disconnect);
      return;
    }
    disconnectingByUser = true;
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
      AppLogger.w('WalletConnect', 'disconnect error: $e');
    } finally {
      disconnectingByUser = false;
      viewStateDeal(WalletConnectState.disconnect);
    }
  }

  // ── Data cleanup ───────────────────────────────────────────────────────────

  @override
  void cleanData() {
    cancelReconnectTimer();
    reconnectAttempts = 0;
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
}
