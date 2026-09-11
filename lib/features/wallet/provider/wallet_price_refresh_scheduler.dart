import 'dart:async';

import 'package:flutter/foundation.dart';

/// Low-frequency home refresh. Initial load and manual refresh remain separate.
class WalletPriceRefreshScheduler {
  WalletPriceRefreshScheduler({
    required this.canRefresh,
    required this.onRefresh,
    this.onError = FlutterError.reportError,
  });

  static const interval = Duration(minutes: 5);
  final bool Function() canRefresh;
  final Future<void> Function() onRefresh;
  final void Function(FlutterErrorDetails) onError;
  Timer? _timer;
  bool _inFlight = false;
  bool _disposed = false;

  void start() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(_tick()));
  }

  Future<void> _tick() async {
    if (_disposed || _inFlight) return;
    try {
      if (!canRefresh()) return;
      _inFlight = true;
      await onRefresh();
    } catch (error, stack) {
      onError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'wallet home refresh',
          context: ErrorDescription(
            'while refreshing wallet prices and balances',
          ),
          silent: true,
        ),
      );
    } finally {
      _inFlight = false;
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}
