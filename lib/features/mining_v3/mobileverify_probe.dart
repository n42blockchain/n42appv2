// Mining v3 phase 1: one pass of the mobile verification loop against a
// node, as a debug probe: load (or create) the device key, register and
// wait for the epoch commit, take the node's head, re-execute and attest
// it, and wait for the block's certificate to carry a signer.

import 'package:flutter_mining/mobileverify.dart';

import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/features/mining_v3/device_key.dart';

export 'package:n42_wallet/features/mining_v3/device_key.dart'
    show mobileVerifyKeyStorageKey;

class MobileVerifyProbeConfig {
  const MobileVerifyProbeConfig({
    required this.baseUrl,
    required this.chain,
    this.poll = const Duration(seconds: 2),
    this.registerTimeout = const Duration(minutes: 3),
    this.headTimeout = const Duration(minutes: 1),
    this.certTimeout = const Duration(minutes: 2),
  });

  final String baseUrl;
  final String chain;
  final Duration poll;

  /// The node commits registrations on its epoch timer.
  final Duration registerTimeout;
  final Duration headTimeout;

  /// The block's window must close before its certificate exists.
  final Duration certTimeout;
}

class MobileVerifyProbeResult {
  const MobileVerifyProbeResult.passed(this.verified, this.signers)
    : failure = null;
  const MobileVerifyProbeResult.failed(this.failure)
    : verified = null,
      signers = 0;

  final MvVerified? verified;
  final int signers;
  final String? failure;

  bool get passed => failure == null;
}

class MobileVerifyProbe {
  MobileVerifyProbe({
    required MobileVerifyApi api,
    required SecureStore store,
    Future<void> Function(Duration)? sleep,
  }) : _api = api,
       _store = store,
       _sleep = sleep ?? Future<void>.delayed;

  final MobileVerifyApi _api;
  final SecureStore _store;
  final Future<void> Function(Duration) _sleep;

  Future<MobileVerifyProbeResult> run(
    MobileVerifyProbeConfig config,
    void Function(String) log,
  ) async {
    try {
      return await _run(config, log);
    } on Object catch (e) {
      log('failed: $e');
      return MobileVerifyProbeResult.failed('$e');
    } finally {
      await _api.close();
    }
  }

  Future<MobileVerifyProbeResult> _run(
    MobileVerifyProbeConfig config,
    void Function(String) log,
  ) async {
    final (priv, created) = await loadOrCreateDeviceKey(_api, _store);
    if (created) log('created a device key');
    final pub = await _api.open(
      baseUrl: config.baseUrl,
      privHex: priv,
      chain: config.chain,
    );
    log(
      'session open at ${config.baseUrl} (${config.chain}), pubkey ${pub.substring(0, 16)}…',
    );

    var reg = await _api.register();
    log('registered: index ${reg.index}, committed ${reg.committed}');
    final regTries = _tries(config.registerTimeout, config.poll);
    for (var i = 0; !reg.committed; i++) {
      if (i >= regTries) {
        return _fail(
          log,
          'registration not committed within ${config.registerTimeout}',
        );
      }
      await _sleep(config.poll);
      reg = await _api.register();
    }
    log('committed as device ${reg.index}');

    var head = await _api.latest();
    final headTries = _tries(config.headTimeout, config.poll);
    for (var i = 0; !head.packet; i++) {
      if (i >= headTries) {
        return _fail(log, 'no head with a packet within ${config.headTimeout}');
      }
      await _sleep(config.poll);
      head = await _api.latest();
    }
    log('head ${head.number} ${head.hash}');

    final verified = await _api.verifyBlock(head.hash);
    log(
      'verified block ${verified.blockNumber}: ${verified.txs} txs, '
      'root ${verified.receiptsRoot}, ${verified.elapsedMs} ms, accepted as device ${verified.index}',
    );

    final certTries = _tries(config.certTimeout, config.poll);
    for (var i = 0; ; i++) {
      final certs = await _api.cert(verified.blockHash);
      final ours = certs.where((c) => c.receiptsRoot == verified.receiptsRoot);
      final signers = ours.fold<int>(
        0,
        (m, c) => c.signers > m ? c.signers : m,
      );
      if (signers >= 1) {
        log('certificate: $signers signers over our root');
        return MobileVerifyProbeResult.passed(verified, signers);
      }
      if (certs.isNotEmpty && ours.isEmpty) {
        return _fail(
          log,
          'certificates exist, none over our root ${verified.receiptsRoot}',
        );
      }
      if (i >= certTries) {
        return _fail(log, 'no certificate within ${config.certTimeout}');
      }
      await _sleep(config.poll);
    }
  }

  static int _tries(Duration timeout, Duration poll) => poll.inMilliseconds <= 0
      ? 1
      : (timeout.inMilliseconds / poll.inMilliseconds).ceil();

  static MobileVerifyProbeResult _fail(void Function(String) log, String why) {
    log('failed: $why');
    return MobileVerifyProbeResult.failed(why);
  }
}
