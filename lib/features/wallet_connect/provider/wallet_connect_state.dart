import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// WalletConnect provider state machine.
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

/// Localized WC toast helper.
/// Uses the navigator context if available; falls back to English.
S? wcL10n() {
  final ctx = AppGlobals.navigatorKey.currentContext;
  if (ctx == null) return null;
  try {
    return S.of(ctx);
  } catch (_) {
    return null;
  }
}
