// Mining v3 engine: the app side of the N42 mobile verification loop.
//
// The loop itself runs natively (evmsdk.MobileVerifyMiner in an Android
// foreground service, or an iOS host that pauses in the background). The engine starts and stops it and,
// while something listens, reads its status once a second; a rebuilt UI
// picks up a miner that is already running.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mining/mobileverify.dart';

import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/features/mining_v3/device_key.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_activity.dart';

/// The chain the fleet runs; the miner re-executes blocks under it.
const miningV3DefaultChain = String.fromEnvironment(
  'MINING_V3_CHAIN',
  defaultValue: 'mainnet_qmdb_staggered',
);

/// Temporary LAN testnet, shared by physical phones and simulators.
const miningV3LocalTestnetEndpoint = 'http://192.168.0.217:21100';

/// An explicit saved node wins over this build-time/default address.
const miningV3DefaultEndpoint = String.fromEnvironment(
  'MINING_V3_URL',
  defaultValue: miningV3LocalTestnetEndpoint,
);

enum MiningV3Phase {
  /// Not running.
  idle,

  /// Opening the session.
  connecting,

  /// Registered, waiting for the node's epoch to commit the key.
  registering,

  /// Verifying blocks.
  mining,

  /// The last step failed; the miner retries on its own.
  retrying;

  static MiningV3Phase fromName(String name) =>
      values.firstWhere((p) => p.name == name, orElse: () => idle);
}

typedef PeriodicTimer = Timer Function(Duration, void Function(Timer));

class MiningV3Engine extends ChangeNotifier {
  MiningV3Engine({
    required MobileVerifyApi api,
    required SecureStore store,
    this.chain = miningV3DefaultChain,
    this.refreshEvery = const Duration(seconds: 1),
    PeriodicTimer? periodic,
    DateTime Function()? now,
  }) : _api = api,
       _store = store,
       _periodic = periodic ?? Timer.periodic,
       _now = now ?? DateTime.now {
    unawaited(refresh());
  }

  final MobileVerifyApi _api;
  final SecureStore _store;
  final PeriodicTimer _periodic;
  final DateTime Function() _now;
  final _activity = MiningV3Activity();
  Future<void>? _refreshing;
  final String chain;
  final Duration refreshEvery;

  MvMinerStatus status = MvMinerStatus.idle;

  /// Why the last start or status read failed, if it did.
  String? startError;
  bool _busy = false;
  bool _stopRequested = false;
  Completer<void>? _transitionDone;
  Future<void>? _stopping;
  Timer? _timer;
  bool _disposed = false;

  bool get running => status.running;
  bool get pausedForBackground => status.pausedForBackground;

  /// Starting or stopping.
  bool get busy => _busy;
  MiningV3Phase get phase => MiningV3Phase.fromName(status.phase);
  String? get endpoint =>
      status.running || status.pausedForBackground ? status.endpoint : null;
  int? get deviceIndex => status.deviceIndex;
  int get verified => status.verified;
  int get failed => status.failed;
  int get certified => status.certified;
  int get uncertified => status.uncertified;
  MvVerified? get lastVerified => status.lastBlock;
  int get lastSigners => status.lastSigners;
  String? get lastError => startError ?? status.lastError;
  List<String> get log => status.log;
  List<MiningV3Block> get blocks => _activity.blocks;
  Duration? get sessionDuration => _activity.duration(_now());
  DateTime? get sessionStartedAt => _activity.startedAt;

  /// Starts the miner against [baseUrl] with the device key, creating the
  /// key on first use.
  Future<void> start(String baseUrl) async {
    if (_busy || _stopRequested || _stopping != null) return;
    _busy = true;
    final transition = _transitionDone = Completer<void>();
    startError = null;
    _notify();
    try {
      final (priv, _) = await loadOrCreateDeviceKey(_api, _store);
      if (!_stopRequested) {
        await _api.minerStart(baseUrl: baseUrl, privHex: priv, chain: chain);
      }
    } on Object catch (e) {
      startError = '$e';
    } finally {
      _busy = false;
      transition.complete();
    }
    await refresh();
  }

  Future<void> stop() =>
      _stopping ??= _stop().whenComplete(() => _stopping = null);

  Future<void> _stop() async {
    _stopRequested = true;
    if (_busy) await _transitionDone?.future;
    _busy = true;
    final transition = _transitionDone = Completer<void>();
    _notify();
    try {
      await _api.minerStop();
    } on Object catch (e) {
      startError = '$e';
    } finally {
      _busy = false;
      _stopRequested = false;
      transition.complete();
    }
    await refresh();
  }

  /// Reads the miner's status.
  Future<void> refresh() => _refreshing ??= _readStatus().whenComplete(() {
    _refreshing = null;
  });

  Future<void> _readStatus() async {
    try {
      final next = await _api.minerStatus();
      if (_disposed) return;
      _activity.update(next, _now());
      status = next;
    } on Object catch (e) {
      startError ??= '$e';
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // Poll only while someone shows the status.
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _timer ??= _periodic(refreshEvery, (_) => unawaited(refresh()));
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    // The miner keeps running: it belongs to the service, not this UI.
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
