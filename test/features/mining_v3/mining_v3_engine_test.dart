import 'package:flutter_mining/mobileverify.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/features/mining_v3/device_key.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';

class _MemoryStore implements SecureStore {
  final values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async =>
      values[key] = value;

  @override
  Future<void> delete({required String key}) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();
}

/// A scripted node: [heads] are served in order (the last one repeats),
/// the registration commits on the [commitOn]th call, [certs] maps a block
/// hash to its certificates, and hashes in [failing] fail to verify.
class _ScriptedNode implements MobileVerifyApi {
  _ScriptedNode({
    required this.heads,
    this.commitOn = 1,
    this.certs = const {},
    this.failing = const {},
    this.latestErrors = 0,
  });

  final List<MvHead> heads;
  final int commitOn;
  final Map<String, List<MvCert>> certs;
  final Set<String> failing;
  int latestErrors;
  int registers = 0;
  int opens = 0;
  int latests = 0;
  final verified = <String>[];
  bool closed = false;

  @override
  Future<String> generateKey() async => 'aa' * 32;

  @override
  Future<String> publicKey(String privHex) async => 'bb' * 48;

  @override
  Future<String> open({
    required String baseUrl,
    required String privHex,
    required String chain,
  }) async {
    opens++;
    return 'bb' * 48;
  }

  @override
  Future<MvRegistration> register() async =>
      MvRegistration(index: 5, committed: ++registers >= commitOn);

  @override
  Future<MvHead> latest() async {
    if (latestErrors > 0) {
      latestErrors--;
      throw StateError('node unreachable');
    }
    final i = latests++;
    return heads[i < heads.length ? i : heads.length - 1];
  }

  @override
  Future<MvVerified> verifyBlock(String blockHash) async {
    verified.add(blockHash);
    if (failing.contains(blockHash)) throw StateError('state root mismatch');
    return MvVerified(
      blockNumber: int.parse(blockHash.substring(2)),
      blockHash: blockHash,
      receiptsRoot: '0xroot$blockHash',
      txs: 1,
      index: 5,
      elapsedMs: 7,
    );
  }

  @override
  Future<List<MvCert>> cert(String blockHash) async => certs[blockHash] ?? [];

  @override
  Future<Map<String, dynamic>> health() async => {};

  @override
  Future<void> close() async => closed = true;
}

MvHead _head(int n, {bool packet = true}) =>
    MvHead(number: n, hash: '0x$n', packet: packet);

MvCert _cert(int n, {int signers = 1, String? root}) => MvCert(
  blockNumber: n,
  receiptsRoot: root ?? '0xroot0x$n',
  signers: signers,
);

/// Runs [engine] on a virtual clock: each sleep advances it, and after
/// [sleeps] sleeps the engine is stopped. Returns the recorded sleeps.
Future<List<Duration>> _runFor(
  _ScriptedNode node,
  int sleeps, {
  MiningV3Timing timing = const MiningV3Timing(),
  _MemoryStore? store,
  void Function(MiningV3Engine)? onSleep,
}) async {
  final slept = <Duration>[];
  var clock = DateTime(2026, 10, 31);
  late MiningV3Engine engine;
  Future<void>? stopped;
  engine = MiningV3Engine(
    api: node,
    store: store ?? _MemoryStore(),
    timing: timing,
    now: () => clock,
    sleep: (d) async {
      slept.add(d);
      clock = clock.add(d);
      onSleep?.call(engine);
      if (slept.length == sleeps) stopped = engine.stop();
    },
  );
  engine.start('http://node');
  while (stopped == null) {
    await pumpEventQueue();
  }
  await stopped;
  expect(engine.running, isFalse);
  expect(engine.phase, MiningV3Phase.idle);
  _last = engine;
  return slept;
}

late MiningV3Engine _last;

void main() {
  const timing = MiningV3Timing();

  test('waits for the registration to commit before mining', () async {
    final node = _ScriptedNode(heads: [_head(100)], commitOn: 3);
    final phases = <MiningV3Phase>[];
    final slept = await _runFor(node, 3, onSleep: (e) => phases.add(e.phase));
    expect(node.registers, 3);
    expect(slept.take(2), everyElement(timing.registerPoll));
    expect(slept[2], timing.poll);
    expect(phases, [
      MiningV3Phase.registering,
      MiningV3Phase.registering,
      MiningV3Phase.mining,
    ]);
    expect(_last.deviceIndex, 5);
    expect(node.verified, ['0x100']);
  });

  test('verifies each new head once, only when its packet is there', () async {
    final node = _ScriptedNode(
      heads: [
        _head(99, packet: false),
        _head(100),
        _head(100),
        _head(101),
        _head(99),
        _head(102, packet: false),
        _head(102),
      ],
    );
    await _runFor(node, 7);
    expect(node.verified, ['0x100', '0x101', '0x102']);
    expect(_last.verified, 3);
    expect(_last.failed, 0);
    expect(_last.lastVerified?.blockNumber, 102);
  });

  test('a block that fails to verify is counted and mining goes on', () async {
    final node = _ScriptedNode(
      heads: [_head(100), _head(101), _head(102)],
      failing: {'0x101'},
    );
    await _runFor(node, 3);
    expect(node.verified, ['0x100', '0x101', '0x102']);
    expect(_last.verified, 2);
    expect(_last.failed, 1);
    expect(node.opens, 1);
    expect(_last.lastError, contains('state root mismatch'));
  });

  test('counts certified blocks and gives up on the rest in time', () async {
    // 1s polls: certDelay 20s, then rechecks every 10s, timeout 2m.
    final node = _ScriptedNode(
      heads: [_head(100), _head(101)],
      certs: {
        '0x100': [
          _cert(100, signers: 1, root: '0xother'),
          _cert(100, signers: 3),
        ],
        // Certified, but over a root this device did not attest.
        '0x101': [_cert(101, signers: 4, root: '0xother')],
      },
    );
    await _runFor(node, 150);
    expect(_last.certified, 1);
    expect(_last.lastSigners, 3);
    expect(_last.uncertified, 1);
  });

  test('a block is not counted uncertified before the timeout', () async {
    final node = _ScriptedNode(heads: [_head(100)]);
    await _runFor(node, 100);
    expect(_last.certified, 0);
    expect(_last.uncertified, 0);
  });

  test('an error before mining reopens the session after the retry', () async {
    final node = _ScriptedNode(heads: [_head(100)], latestErrors: 1);
    final phases = <MiningV3Phase>[];
    final slept = await _runFor(node, 2, onSleep: (e) => phases.add(e.phase));
    expect(slept, [timing.retry, timing.poll]);
    expect(phases, [MiningV3Phase.retrying, MiningV3Phase.mining]);
    expect(node.opens, 2);
    expect(node.verified, ['0x100']);
  });

  test('the device key is created once and reused', () async {
    final store = _MemoryStore();
    await _runFor(_ScriptedNode(heads: [_head(100)]), 1, store: store);
    final key = store.values[mobileVerifyKeyStorageKey];
    expect(key, 'aa' * 32);
    expect(
      _last.log.where((l) => l.contains('created a device key')),
      hasLength(1),
    );
    await _runFor(_ScriptedNode(heads: [_head(100)]), 1, store: store);
    expect(_last.log.where((l) => l.contains('created a device key')), isEmpty);
  });

  test('stop closes the session', () async {
    final node = _ScriptedNode(heads: [_head(100)]);
    await _runFor(node, 1);
    expect(node.closed, isTrue);
  });
}
