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

/// The calls of one mobileverify session. Every call but [close] blocks
/// natively and runs off the UI thread; a failure surfaces as a
/// [PlatformException] carrying the SDK's message.
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
}
