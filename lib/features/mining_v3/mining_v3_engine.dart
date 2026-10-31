// Mining v3 engine: the continuous N42 mobile verification loop.
//
// Once started it keeps the device registered, verifies every new head
// whose packet the node holds (re-execute, sign, submit), and later reads
// each verified block's certificate to count the blocks the device's
// receipt helped certify. Transient failures are logged and retried; only
// stop() ends the loop.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mining/mobileverify.dart';

import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/features/mining_v3/device_key.dart';

/// The chain the fleet runs; the engine re-executes blocks under it.
const miningV3DefaultChain = String.fromEnvironment(
  'MINING_V3_CHAIN',
  defaultValue: 'mainnet_qmdb_staggered',
);

/// The node used until the user sets one: the build's MINING_V3_URL, or
/// the host's first fleet node as the Android emulator sees it.
const miningV3DefaultEndpoint = String.fromEnvironment(
  'MINING_V3_URL',
  defaultValue: 'http://10.0.2.2:21012',
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

  /// The last step failed; retrying after [MiningV3Timing.retry].
  retrying,
}

class MiningV3Timing {
  const MiningV3Timing({
    this.poll = const Duration(seconds: 1),
    this.registerPoll = const Duration(seconds: 10),
    this.retry = const Duration(seconds: 10),
    this.certDelay = const Duration(seconds: 20),
    this.certRecheck = const Duration(seconds: 10),
    this.certTimeout = const Duration(minutes: 2),
  });

  /// How often the head is polled.
  final Duration poll;
  final Duration registerPoll;
  final Duration retry;

  /// A block's window has closed by then, so its certificate exists.
  final Duration certDelay;
  final Duration certRecheck;

  /// A verified block still without a certificate over its root after
  /// this long counts as uncertified.
  final Duration certTimeout;
}

class _PendingCert {
  _PendingCert(this.verified, this.at, this.nextCheck);

  final MvVerified verified;
  final DateTime at;
  DateTime nextCheck;
}

class MiningV3Engine extends ChangeNotifier {
  MiningV3Engine({
    required MobileVerifyApi api,
    required SecureStore store,
    this.chain = miningV3DefaultChain,
    this.timing = const MiningV3Timing(),
    Future<void> Function(Duration)? sleep,
    DateTime Function()? now,
  }) : _api = api,
       _store = store,
       _sleep = sleep ?? Future<void>.delayed,
       _now = now ?? DateTime.now;

  final MobileVerifyApi _api;
  final SecureStore _store;
  final Future<void> Function(Duration) _sleep;
  final DateTime Function() _now;
  final String chain;
  final MiningV3Timing timing;

  static const _logLimit = 100;

  MiningV3Phase phase = MiningV3Phase.idle;
  String? endpoint;
  String? pubkey;
  int? deviceIndex;

  /// Blocks re-executed, attested and accepted by the node.
  int verified = 0;

  /// Blocks whose verification or submission failed.
  int failed = 0;

  /// Verified blocks whose certificate counts this device's root.
  int certified = 0;

  /// Verified blocks with no certificate over this device's root in time.
  int uncertified = 0;
  MvVerified? lastVerified;
  int lastSigners = 0;
  String? lastError;

  /// Newest last.
  final List<String> log = [];

  final List<_PendingCert> _pending = [];
  int _lastNumber = -1;
  bool _stopRequested = false;
  Future<void>? _loop;

  bool get running => _loop != null;

  /// Starts the loop against [baseUrl]; no-op while running.
  void start(String baseUrl) {
    if (_loop != null) return;
    endpoint = baseUrl;
    _stopRequested = false;
    lastError = null;
    _loop = _run(baseUrl).whenComplete(() {
      _loop = null;
      phase = MiningV3Phase.idle;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Ends the loop: aborts the native call in flight and waits for the
  /// loop to unwind.
  Future<void> stop() async {
    final loop = _loop;
    if (loop == null) return;
    _stopRequested = true;
    await _api.close();
    await loop;
  }

  void _log(String line) {
    final t = _now();
    final stamp =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
    log.add('$stamp $line');
    if (log.length > _logLimit) log.removeAt(0);
    notifyListeners();
  }

  void _enter(MiningV3Phase next) {
    phase = next;
    notifyListeners();
  }

  Future<void> _run(String baseUrl) async {
    while (!_stopRequested) {
      try {
        _enter(MiningV3Phase.connecting);
        final (priv, created) = await loadOrCreateDeviceKey(_api, _store);
        if (created) _log('created a device key');
        pubkey = await _api.open(baseUrl: baseUrl, privHex: priv, chain: chain);
        _log('session open at $baseUrl');

        _enter(MiningV3Phase.registering);
        var reg = await _api.register();
        deviceIndex = reg.index;
        while (!reg.committed && !_stopRequested) {
          _log('registered as device ${reg.index}, waiting for the epoch');
          await _sleep(timing.registerPoll);
          if (_stopRequested) return;
          reg = await _api.register();
          deviceIndex = reg.index;
        }
        if (_stopRequested) return;
        _log('committed as device ${reg.index}');

        _enter(MiningV3Phase.mining);
        while (!_stopRequested) {
          await _tick();
          await _sleep(timing.poll);
        }
      } on Object catch (e) {
        if (_stopRequested) return;
        lastError = '$e';
        _log('error: $e; retrying in ${timing.retry.inSeconds}s');
        _enter(MiningV3Phase.retrying);
        await _sleep(timing.retry);
      }
    }
  }

  /// One poll: verify the head if it is new and its packet is there, then
  /// read the certificates that are due.
  Future<void> _tick() async {
    final head = await _api.latest();
    if (head.packet && head.number > _lastNumber) {
      _lastNumber = head.number;
      try {
        final v = await _api.verifyBlock(head.hash);
        verified++;
        lastVerified = v;
        final now = _now();
        _pending.add(_PendingCert(v, now, now.add(timing.certDelay)));
        _log(
          'verified block ${v.blockNumber} (${v.txs} txs, ${v.elapsedMs} ms)',
        );
      } on Object catch (e) {
        if (_stopRequested) return;
        failed++;
        lastError = '$e';
        _log('block ${head.number} failed: $e');
      }
    }
    await _checkCerts();
  }

  Future<void> _checkCerts() async {
    final now = _now();
    for (final p in List.of(_pending)) {
      if (now.isBefore(p.nextCheck)) continue;
      final certs = await _api.cert(p.verified.blockHash);
      final signers = certs
          .where((c) => c.receiptsRoot == p.verified.receiptsRoot)
          .fold<int>(0, (m, c) => c.signers > m ? c.signers : m);
      if (signers >= 1) {
        _pending.remove(p);
        certified++;
        lastSigners = signers;
        _log('block ${p.verified.blockNumber} certified, $signers signers');
      } else if (now.difference(p.at) >= timing.certTimeout) {
        _pending.remove(p);
        uncertified++;
        _log('block ${p.verified.blockNumber} not certified in time');
      } else {
        p.nextCheck = now.add(timing.certRecheck);
      }
    }
  }

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopRequested = true;
    if (_loop != null) unawaited(_api.close());
    super.dispose();
  }
}
