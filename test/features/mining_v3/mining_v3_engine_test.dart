import 'dart:async';

import 'package:flutter/services.dart';
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

/// Plays the native side: the miner runs between minerStart and minerStop
/// and reports [status].
class _FakeNative implements MobileVerifyApi {
  final starts = <Map<String, String>>[];
  int stops = 0;
  int statusReads = 0;
  int keys = 0;
  Object? startFails;
  Future<MvMinerStatus>? delayedStatus;
  MvMinerStatus status = MvMinerStatus.idle;

  @override
  Future<String> generateKey() async {
    keys++;
    return 'aa' * 32;
  }

  @override
  Future<void> minerStart({
    required String baseUrl,
    required String privHex,
    required String chain,
  }) async {
    if (startFails != null) throw startFails!;
    starts.add({'baseUrl': baseUrl, 'privHex': privHex, 'chain': chain});
    status = MvMinerStatus(
      running: true,
      phase: 'connecting',
      endpoint: baseUrl,
    );
  }

  @override
  Future<void> minerStop() async {
    stops++;
    status = MvMinerStatus.idle;
  }

  @override
  Future<MvMinerStatus> minerStatus() async {
    statusReads++;
    return delayedStatus == null ? status : await delayedStatus!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Timers the test fires by hand.
class _Timers {
  final created = <Duration>[];
  final callbacks = <void Function(Timer)>[];
  final timers = <_FakeTimer>[];

  Timer call(Duration d, void Function(Timer) cb) {
    created.add(d);
    callbacks.add(cb);
    final t = _FakeTimer();
    timers.add(t);
    return t;
  }

  void fire() {
    for (var i = 0; i < timers.length; i++) {
      if (timers[i].isActive) callbacks[i](timers[i]);
    }
  }
}

class _FakeTimer implements Timer {
  bool _active = true;

  @override
  bool get isActive => _active;

  @override
  void cancel() => _active = false;

  @override
  int get tick => 0;
}

const _mining = MvMinerStatus(
  running: true,
  phase: 'mining',
  endpoint: 'http://node',
  deviceIndex: 5,
  verified: 12,
  failed: 1,
  certified: 10,
  uncertified: 2,
  lastBlock: MvVerified(
    blockNumber: 42,
    blockHash: '0x42',
    receiptsRoot: '0xr',
    txs: 3,
    index: 5,
    elapsedMs: 120,
  ),
  lastSigners: 4,
  log: ['a', 'b'],
);

void main() {
  late _FakeNative native;
  late _MemoryStore store;
  late _Timers timers;

  MiningV3Engine engine() => MiningV3Engine(
    api: native,
    store: store,
    chain: 'test-chain',
    periodic: timers.call,
  );

  setUp(() {
    native = _FakeNative();
    store = _MemoryStore();
    timers = _Timers();
  });

  test('starts the miner with the device key, created once', () async {
    final e = engine();
    await e.start('http://node');
    expect(native.starts.single, {
      'baseUrl': 'http://node',
      'privHex': 'aa' * 32,
      'chain': 'test-chain',
    });
    expect(store.values[mobileVerifyKeyStorageKey], 'aa' * 32);
    expect(
      [e.running, e.phase, e.endpoint],
      [true, MiningV3Phase.connecting, 'http://node'],
    );

    await e.stop();
    await e.start('http://node');
    expect(native.keys, 1);
    expect(native.starts, hasLength(2));
    expect(native.starts.last['privHex'], 'aa' * 32);
  });

  test('a new UI picks up a miner that is already running', () async {
    native.status = _mining;
    final e = engine();
    await pumpEventQueue();
    expect(e.running, isTrue);
    expect(e.phase, MiningV3Phase.mining);
    expect(
      [e.deviceIndex, e.verified, e.failed, e.certified, e.uncertified],
      [5, 12, 1, 10, 2],
    );
    expect([e.lastVerified?.blockNumber, e.lastSigners], [42, 4]);
    expect(
      [e.endpoint, e.log],
      [
        'http://node',
        ['a', 'b'],
      ],
    );
    expect(native.starts, isEmpty);
  });

  test('polls the status only while someone listens', () async {
    final e = engine();
    await pumpEventQueue();
    expect(timers.created, isEmpty);

    void listener() {}
    e.addListener(listener);
    expect(timers.created, [const Duration(seconds: 1)]);
    native.status = _mining;
    final reads = native.statusReads;
    timers.fire();
    await pumpEventQueue();
    expect(native.statusReads, reads + 1);
    expect(e.verified, 12);

    e.removeListener(listener);
    timers.fire();
    await pumpEventQueue();
    expect(native.statusReads, reads + 1);
  });

  test('coalesces a manual refresh with a pending native status read', () async {
    final pending = Completer<MvMinerStatus>();
    native.delayedStatus = pending.future;
    final e = engine();
    final first = e.refresh();
    final second = e.refresh();
    expect(identical(first, second), isTrue);
    expect(native.statusReads, 1);
    pending.complete(_mining);
    await Future.wait([first, second]);
    expect(e.blocks.single.number, 42);
    expect(e.verified, 12);
    e.dispose();
  });

  test('stop stops the miner', () async {
    native.status = _mining;
    final e = engine();
    await e.stop();
    expect(native.stops, 1);
    expect([e.running, e.phase], [false, MiningV3Phase.idle]);
  });

  test('a failed start is reported and nothing runs', () async {
    native.startFails = PlatformException(
      code: 'MobileVerify',
      message: 'unknown chain',
    );
    final e = engine();
    await e.start('http://node');
    expect(e.running, isFalse);
    expect(e.lastError, contains('unknown chain'));
    expect(e.busy, isFalse);

    native.startFails = null;
    await e.start('http://node');
    expect(e.running, isTrue);
    expect(e.startError, isNull);
  });

  test('disposing the UI side leaves the miner running', () async {
    final e = engine();
    await e.start('http://node');
    void listener() {}
    e.addListener(listener);
    e.removeListener(listener);
    e.dispose();
    expect(native.stops, 0);
    expect(timers.timers.single.isActive, isFalse);
  });
}
