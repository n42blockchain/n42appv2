// Mining v3: the N42 mobile verification loop (`/mobileverify`), driven
// through evmsdk's MobileVerifySession on the "n42/mobileverify" channel.
//
// A device registers its BLS key once per launch, then for each new head
// fetches the block's packet, re-executes it, and signs and submits a
// receipt; the node aggregates the receipts of one block into a
// certificate once its window closes.

import 'dart:convert';

import 'package:flutter/services.dart';

/// The device's registration: [committed] is false until the node's next
/// epoch, and until then its receipts do not count and [index] is
/// provisional.
class MvRegistration {
  const MvRegistration({required this.index, required this.committed});

  factory MvRegistration.fromJson(Map<String, dynamic> json) => MvRegistration(
    index: (json['index'] as num).toInt(),
    committed: json['committed'] as bool? ?? false,
  );

  final int index;
  final bool committed;
}

/// The node's canonical head; [packet] says whether the node already
/// holds the block's packet, i.e. whether it can be verified yet.
class MvHead {
  const MvHead({
    required this.number,
    required this.hash,
    required this.packet,
  });

  factory MvHead.fromJson(Map<String, dynamic> json) => MvHead(
    number: (json['number'] as num).toInt(),
    hash: json['hash'] as String,
    packet: json['packet'] as bool? ?? false,
  );

  final int number;
  final String hash;
  final bool packet;
}

/// A block this device re-executed and attested; the node accepted the
/// receipt under device [index].
class MvVerified {
  const MvVerified({
    required this.blockNumber,
    required this.blockHash,
    required this.receiptsRoot,
    required this.txs,
    required this.index,
    required this.elapsedMs,
  });

  factory MvVerified.fromJson(Map<String, dynamic> json) => MvVerified(
    blockNumber: (json['blockNumber'] as num).toInt(),
    blockHash: json['blockHash'] as String,
    receiptsRoot: json['receiptsRoot'] as String,
    txs: (json['txs'] as num).toInt(),
    index: (json['index'] as num).toInt(),
    elapsedMs: (json['elapsedMs'] as num).toInt(),
  );

  final int blockNumber;
  final String blockHash;
  final String receiptsRoot;
  final int txs;
  final int index;
  final int elapsedMs;
}

/// A block's certificate: the aggregate of [signers] devices' receipts
/// over [receiptsRoot].
class MvCert {
  const MvCert({
    required this.blockNumber,
    required this.receiptsRoot,
    required this.signers,
  });

  factory MvCert.fromJson(Map<String, dynamic> json) => MvCert(
    blockNumber: (json['blockNumber'] as num).toInt(),
    receiptsRoot: json['receiptsRoot'] as String,
    signers: (json['signers'] as num).toInt(),
  );

  final int blockNumber;
  final String receiptsRoot;
  final int signers;
}

/// The state of the native miner (evmsdk.MobileVerifyMiner), the
/// continuous loop the app runs in a foreground service.
class MvMinerStatus {
  const MvMinerStatus({
    required this.running,
    required this.phase,
    this.endpoint,
    this.pubkey,
    this.deviceIndex,
    this.verified = 0,
    this.failed = 0,
    this.certified = 0,
    this.uncertified = 0,
    this.lastBlock,
    this.lastSigners = 0,
    this.lastError,
    this.startedAtMs,
    this.sessionId,
    this.activeDurationMs,
    this.pausedForBackground = false,
    this.logTimeUtc = false,
    this.log = const [],
  });

  factory MvMinerStatus.fromJson(Map<String, dynamic> json) => MvMinerStatus(
    running: json['running'] as bool? ?? false,
    phase: json['phase'] as String? ?? 'idle',
    endpoint: json['endpoint'] as String?,
    pubkey: json['pubkey'] as String?,
    deviceIndex: (json['deviceIndex'] as num?)?.toInt(),
    verified: (json['verified'] as num?)?.toInt() ?? 0,
    failed: (json['failed'] as num?)?.toInt() ?? 0,
    certified: (json['certified'] as num?)?.toInt() ?? 0,
    uncertified: (json['uncertified'] as num?)?.toInt() ?? 0,
    lastBlock: json['lastBlock'] == null
        ? null
        : MvVerified.fromJson(json['lastBlock'] as Map<String, dynamic>),
    lastSigners: (json['lastSigners'] as num?)?.toInt() ?? 0,
    lastError: json['lastError'] as String?,
    startedAtMs: (json['startedAtMs'] as num?)?.toInt(),
    sessionId: json['sessionId'] as String?,
    activeDurationMs: (json['activeDurationMs'] as num?)?.toInt(),
    pausedForBackground: json['pausedForBackground'] as bool? ?? false,
    logTimeUtc: json['logTimeUtc'] as bool? ?? false,
    log: [for (final l in json['log'] as List<dynamic>? ?? []) l as String],
  );

  static const idle = MvMinerStatus(running: false, phase: 'idle');

  final bool running;

  /// idle, connecting, registering, mining or retrying.
  final String phase;
  final String? endpoint;
  final String? pubkey;
  final int? deviceIndex;

  /// Blocks re-executed, attested and accepted by the node.
  final int verified;

  /// Blocks whose verification or submission failed.
  final int failed;

  /// Verified blocks whose certificate counts this device's root.
  final int certified;

  /// Verified blocks with no certificate over this device's root in time.
  final int uncertified;
  final MvVerified? lastBlock;
  final int lastSigners;
  final String? lastError;
  final int? startedAtMs;

  /// iOS keeps one user session across foreground/background transitions.
  final String? sessionId;
  final int? activeDurationMs;
  final bool pausedForBackground;

  /// New SDK logs use UTC; older SDKs retain their original clock display.
  final bool logTimeUtc;

  /// The newest lines, oldest first.
  final List<String> log;
}

/// The calls of one mobileverify session. Every call but [close] blocks
/// natively and runs off the UI thread; a failure surfaces as a
/// [PlatformException] carrying the SDK's message.
///
/// [minerStart], [minerStop] and [minerStatus] drive the native miner
/// instead, which runs the whole loop without the app's UI.
abstract class MobileVerifyApi {
  /// Creates a device key and returns its secret hex: persist it in
  /// secure storage, it is the device's identity.
  Future<String> generateKey();

  /// The 48-byte BLS public key hex of a secret key.
  Future<String> publicKey(String privHex);

  /// Binds [privHex] to a node and returns the public key. [chain] must
  /// name the chain the node runs, e.g. `mainnet_qmdb_staggered`.
  Future<String> open({
    required String baseUrl,
    required String privHex,
    required String chain,
  });

  Future<MvRegistration> register();

  Future<MvHead> latest();

  Future<MvVerified> verifyBlock(String blockHash);

  /// Empty while the block's window is still open.
  Future<List<MvCert>> cert(String blockHash);

  Future<Map<String, dynamic>> health();

  /// Aborts the call in flight and ends the session.
  Future<void> close();

  /// Starts the native miner. Android uses a foreground service; iOS pauses
  /// on backgrounding and resumes on activation while still requested.
  /// Repeating the same start while requested is idempotent.
  Future<void> minerStart({
    required String baseUrl,
    required String privHex,
    required String chain,
  });

  Future<void> minerStop();

  Future<MvMinerStatus> minerStatus();
}

class MethodChannelMobileVerify implements MobileVerifyApi {
  MethodChannelMobileVerify({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('n42/mobileverify');

  final MethodChannel _channel;

  Future<String> _call(String method, [Map<String, String>? args]) async {
    final value = await _channel.invokeMethod<String>(method, args);
    if (value == null) {
      throw PlatformException(
        code: 'MobileVerify',
        message: '$method returned nothing',
      );
    }
    return value;
  }

  Future<Map<String, dynamic>> _object(
    String method, [
    Map<String, String>? args,
  ]) async => jsonDecode(await _call(method, args)) as Map<String, dynamic>;

  @override
  Future<String> generateKey() => _call('generateKey');

  @override
  Future<String> publicKey(String privHex) =>
      _call('publicKey', {'privHex': privHex});

  @override
  Future<String> open({
    required String baseUrl,
    required String privHex,
    required String chain,
  }) => _call('open', {'baseUrl': baseUrl, 'privHex': privHex, 'chain': chain});

  @override
  Future<MvRegistration> register() async =>
      MvRegistration.fromJson(await _object('register'));

  @override
  Future<MvHead> latest() async => MvHead.fromJson(await _object('latest'));

  @override
  Future<MvVerified> verifyBlock(String blockHash) async => MvVerified.fromJson(
    await _object('verifyBlock', {'blockHash': blockHash}),
  );

  @override
  Future<List<MvCert>> cert(String blockHash) async {
    final list =
        jsonDecode(await _call('cert', {'blockHash': blockHash}))
            as List<dynamic>;
    return [for (final c in list) MvCert.fromJson(c as Map<String, dynamic>)];
  }

  @override
  Future<Map<String, dynamic>> health() => _object('health');

  @override
  Future<void> close() => _channel.invokeMethod<void>('close');

  @override
  Future<void> minerStart({
    required String baseUrl,
    required String privHex,
    required String chain,
  }) => _channel.invokeMethod<void>('minerStart', {
    'baseUrl': baseUrl,
    'privHex': privHex,
    'chain': chain,
  });

  @override
  Future<void> minerStop() => _channel.invokeMethod<void>('minerStop');

  @override
  Future<MvMinerStatus> minerStatus() async =>
      MvMinerStatus.fromJson(await _object('minerStatus'));
}
