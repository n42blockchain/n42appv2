import 'package:flutter_mining/mobileverify.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/features/mining_v3/mobileverify_probe.dart';

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

/// Plays a node: the registration commits on the [commitOn]th call, the
/// head's packet arrives on the [packetOn]th, the certificate on the
/// [certOn]th.
class _FakeNode implements MobileVerifyApi {
  _FakeNode({
    this.commitOn = 2,
    this.packetOn = 2,
    this.certOn = 2,
    this.certRoot = '0xroot',
  });

  final int commitOn;
  final int packetOn;
  final int certOn;
  final String certRoot;
  int registers = 0;
  int latests = 0;
  int certs = 0;
  int keys = 0;
  final opened = <String>[];
  final verified = <String>[];
  bool closed = false;

  @override
  Future<String> generateKey() async {
    keys++;
    return 'aa' * 32;
  }

  @override
  Future<String> publicKey(String privHex) async => 'bb' * 48;

  @override
  Future<String> open({
    required String baseUrl,
    required String privHex,
    required String chain,
  }) async {
    opened.add('$baseUrl|$privHex|$chain');
    return 'bb' * 48;
  }

  @override
  Future<MvRegistration> register() async =>
      MvRegistration(index: 3, committed: ++registers >= commitOn);

  @override
  Future<MvHead> latest() async =>
      MvHead(number: 100, hash: '0xhead', packet: ++latests >= packetOn);

  @override
  Future<MvVerified> verifyBlock(String blockHash) async {
    verified.add(blockHash);
    return MvVerified(
      blockNumber: 100,
      blockHash: blockHash,
      receiptsRoot: '0xroot',
      txs: 2,
      index: 3,
      elapsedMs: 50,
    );
  }

  @override
  Future<List<MvCert>> cert(String blockHash) async => ++certs >= certOn
      ? [MvCert(blockNumber: 100, receiptsRoot: certRoot, signers: 4)]
      : [];

  @override
  Future<Map<String, dynamic>> health() async => {};

  @override
  Future<void> close() async => closed = true;

  // The probe drives the session only, never the miner.
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  const config = MobileVerifyProbeConfig(
    baseUrl: 'http://10.0.2.2:21012',
    chain: 'mainnet_qmdb_staggered',
    poll: Duration(seconds: 1),
    registerPoll: Duration(seconds: 1),
    registerTimeout: Duration(seconds: 5),
    headTimeout: Duration(seconds: 5),
    certTimeout: Duration(seconds: 5),
  );
  Future<void> noSleep(Duration _) async {}

  test(
    'registers, waits for the commit and the packet, verifies the head and sees it certified',
    () async {
      final node = _FakeNode();
      final store = _MemoryStore();
      final log = <String>[];
      final result = await MobileVerifyProbe(
        api: node,
        store: store,
        sleep: noSleep,
      ).run(config, log.add);

      expect(result.passed, isTrue, reason: log.join('\n'));
      expect(result.signers, 4);
      expect(node.registers, 2);
      expect(node.verified, ['0xhead']);
      expect(node.opened, [
        'http://10.0.2.2:21012|${'aa' * 32}|mainnet_qmdb_staggered',
      ]);
      expect(store.values[mobileVerifyKeyStorageKey], 'aa' * 32);
      expect(node.closed, isTrue);
    },
  );

  test('reuses the stored device key', () async {
    final node = _FakeNode();
    final store = _MemoryStore()..values[mobileVerifyKeyStorageKey] = 'cc' * 32;
    await MobileVerifyProbe(
      api: node,
      store: store,
      sleep: noSleep,
    ).run(config, (_) {});
    expect(node.keys, 0);
    expect(node.opened.single, contains('cc' * 32));
  });

  test('can wait a full epoch within the registration rate limit', () async {
    final node = _RateLimitedNode();
    final result =
        await MobileVerifyProbe(
          api: node,
          store: _MemoryStore(),
          sleep: (delay) async => node.elapsed += delay,
        ).run(
          const MobileVerifyProbeConfig(
            baseUrl: 'http://node',
            chain: 'mainnet_qmdb_staggered',
          ),
          (_) {},
        );

    expect(result.passed, isTrue, reason: result.failure);
    expect(node.elapsed, greaterThanOrEqualTo(const Duration(minutes: 1)));
    expect(node.verified, ['0xhead']);
  });

  test('gives up when the registration is never committed', () async {
    final node = _FakeNode(commitOn: 1000);
    final result = await MobileVerifyProbe(
      api: node,
      store: _MemoryStore(),
      sleep: noSleep,
    ).run(config, (_) {});
    expect(result.passed, isFalse);
    expect(result.failure, contains('not committed'));
    expect(node.verified, isEmpty);
    expect(node.closed, isTrue);
  });

  test('gives up when no certificate arrives', () async {
    final node = _FakeNode(certOn: 1000);
    final result = await MobileVerifyProbe(
      api: node,
      store: _MemoryStore(),
      sleep: noSleep,
    ).run(config, (_) {});
    expect(result.passed, isFalse);
    expect(result.failure, contains('no certificate'));
  });

  test('a certificate over another root is a failure', () async {
    final node = _FakeNode(certRoot: '0xother');
    final result = await MobileVerifyProbe(
      api: node,
      store: _MemoryStore(),
      sleep: noSleep,
    ).run(config, (_) {});
    expect(result.passed, isFalse);
    expect(result.failure, contains('none over our root'));
  });

  test('a native failure ends the probe and closes the session', () async {
    final node = _ThrowingNode();
    final result = await MobileVerifyProbe(
      api: node,
      store: _MemoryStore(),
      sleep: noSleep,
    ).run(config, (_) {});
    expect(result.passed, isFalse);
    expect(result.failure, contains('packet not in window'));
    expect(node.closed, isTrue);
  });
}

class _RateLimitedNode extends _FakeNode {
  Duration elapsed = Duration.zero;
  final registrations = <Duration>[];

  @override
  Future<MvRegistration> register() async {
    final recent = registrations.where(
      (at) => elapsed - at < const Duration(minutes: 1),
    );
    if (recent.length >= 10) {
      throw StateError('server 429: registration rate limit');
    }
    registrations.add(elapsed);
    return MvRegistration(
      index: 3,
      committed: elapsed >= const Duration(minutes: 1),
    );
  }
}

class _ThrowingNode extends _FakeNode {
  _ThrowingNode() : super(commitOn: 1, packetOn: 1);

  @override
  Future<MvVerified> verifyBlock(String blockHash) =>
      Future.error(StateError('server 404: packet not in window'));

  // The probe drives the session only, never the miner.
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
