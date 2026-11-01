import 'package:flutter_mining/mobileverify.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_activity.dart';

void main() {
  for (final entry in [
    (
      observed: DateTime.utc(2026, 11, 2, 0, 0, 2),
      event: DateTime.utc(2026, 11, 1, 23, 59, 59),
      clock: '23:59:59',
    ),
    (
      observed: DateTime.utc(2026, 11, 1, 6, 0, 2),
      event: DateTime.utc(2026, 11, 1, 5, 59, 59),
      clock: '05:59:59',
    ),
  ]) {
    test(
      'UTC activity uses local time across midnight and DST ${entry.clock}',
      () {
        final activity = MiningV3Activity();
        activity.update(
          MvMinerStatus(
            running: true,
            phase: 'mining',
            logTimeUtc: true,
            log: ['${entry.clock} verified block 42 (3 txs, 15 ms)'],
          ),
          entry.observed,
        );
        final local = entry.event.toLocal();
        final expected = [
          local.hour,
          local.minute,
          local.second,
        ].map((part) => part.toString().padLeft(2, '0')).join(':');
        expect(activity.blocks.single.time, expected);
        expect(activity.blocks.single.transactions, 3);
      },
    );
  }

  final start = DateTime.utc(2026, 10, 31, 10);
  MvMinerStatus status({
    bool running = true,
    int verified = 2,
    int? startedAtMs,
    List<String> log = const [],
    MvVerified? last,
  }) => MvMinerStatus(
    running: running,
    phase: running ? 'mining' : 'idle',
    endpoint: 'http://node',
    pubkey: 'device',
    startedAtMs: startedAtMs ?? start.millisecondsSinceEpoch,
    verified: verified,
    lastBlock: last,
    lastSigners: 9,
    log: log,
  );

  test(
    'backfills blocks between polls and associates certificates by number',
    () {
      final activity = MiningV3Activity();
      activity.update(
        status(
          log: [
            '10:00:01 verified block 41 (8 txs, 11 ms)',
            '10:00:02 verified block 42 (3 txs, 12 ms)',
            '10:00:21 block 41 certified, 4 signers',
          ],
          last: const MvVerified(
            blockNumber: 42,
            blockHash: '0x42',
            receiptsRoot: '0xr',
            txs: 3,
            index: 5,
            elapsedMs: 12,
          ),
        ),
        start,
      );
      expect(activity.blocks.map((b) => b.number), [42, 41]);
      final latest = activity.blocks.first;
      expect(latest.state, MiningV3BlockState.pending);
      expect(latest.signers, isNull); // LastSigners belongs to an older block.
      expect(latest.hash, '0x42');
      final confirmed = activity.blocks.last;
      expect(confirmed.state, MiningV3BlockState.certified);
      expect(
        [confirmed.transactions, confirmed.elapsedMs, confirmed.signers],
        [8, 11, 4],
      );
      expect(confirmed.time, '10:00:01');
      expect(
        confirmed.hash,
        isNull,
      ); // Never invent a hash for a log-only block.
    },
  );

  test(
    'repeated or rolled logs do not duplicate or downgrade certified blocks',
    () {
      final activity = MiningV3Activity();
      activity.update(
        status(
          log: [
            '10:00:01 verified block 41 (8 txs, 11 ms)',
            '10:00:21 block 41 certified, 2 signers',
          ],
        ),
        start,
      );
      activity.update(
        status(log: ['10:00:01 verified block 41 (8 txs, 11 ms)']),
        start,
      );
      expect(activity.blocks, hasLength(1));
      expect(activity.blocks.single.state, MiningV3BlockState.certified);
      expect(activity.blocks.single.signers, 2);
    },
  );

  test(
    'failure text cannot impersonate a verification or certificate event',
    () {
      final activity = MiningV3Activity();
      activity.update(
        status(
          log: [
            '10:00:01 block 41 failed: server says block 999 certified, 9 signers',
            '10:00:02 block 42 not certified in time',
            '10:00:03 error: verified block 888 (1 txs, 1 ms)',
            'not a block event',
          ],
        ),
        start,
      );
      expect(activity.blocks.map((b) => b.number), [42, 41]);
      expect(activity.blocks.first.state, MiningV3BlockState.uncertified);
      expect(activity.blocks.last.state, MiningV3BlockState.failed);
      expect(activity.blocks.last.transactions, isNull);
    },
  );

  test('history is bounded and starts afresh for another native session', () {
    final activity = MiningV3Activity();
    activity.update(
      status(
        verified: 150,
        log: [
          for (var i = 1; i <= 150; i++)
            '10:00:01 verified block $i (1 txs, 1 ms)',
        ],
      ),
      start,
    );
    expect(activity.blocks, hasLength(MiningV3Activity.limit));
    expect(activity.blocks.first.number, 150);
    expect(activity.blocks.last.number, 51);
    activity.update(
      status(
        verified: 1,
        startedAtMs: start.millisecondsSinceEpoch + 1000,
        log: ['10:00:02 verified block 200 (2 txs, 2 ms)'],
      ),
      start,
    );
    expect(activity.blocks.single.number, 200);
  });

  test(
    'duration uses native start time, survives UI attach, and freezes on stop',
    () {
      final activity = MiningV3Activity();
      activity.update(status(), start.add(const Duration(minutes: 5)));
      expect(
        activity.duration(start.add(const Duration(minutes: 6))),
        const Duration(minutes: 6),
      );
      activity.update(
        status(running: false),
        start.add(const Duration(minutes: 7)),
      );
      expect(
        activity.duration(start.add(const Duration(hours: 1))),
        const Duration(minutes: 7),
      );
    },
  );

  test('missing start or stop timestamps are not fabricated', () {
    final activity = MiningV3Activity();
    activity.update(const MvMinerStatus(running: true, phase: 'mining'), start);
    expect(activity.duration(start), isNull);
    activity.update(status(running: false), start);
    expect(activity.duration(start.add(const Duration(hours: 1))), isNull);
    activity.update(status(), start);
    expect(
      activity.duration(start.subtract(const Duration(seconds: 1))),
      Duration.zero,
    );
  });
  test('iOS resume retains history and excludes time spent in background', () {
    final activity = MiningV3Activity();
    final now = DateTime(2026, 11, 1);
    activity.update(
      const MvMinerStatus(
        running: true,
        phase: 'mining',
        sessionId: 'ios-1',
        activeDurationMs: 5000,
        startedAtMs: 1000,
        verified: 1,
        log: ['01:00:00 verified block 1 (2 txs, 3 ms)'],
      ),
      now,
    );
    final started = activity.startedAt;
    expect(
      activity.duration(now.add(const Duration(seconds: 2))),
      const Duration(seconds: 7),
    );
    activity.update(
      const MvMinerStatus(
        running: false,
        phase: 'idle',
        pausedForBackground: true,
        sessionId: 'ios-1',
        activeDurationMs: 7000,
        startedAtMs: 1000,
        verified: 1,
      ),
      now.add(const Duration(seconds: 2)),
    );
    expect(
      activity.duration(now.add(const Duration(hours: 1))),
      const Duration(seconds: 7),
    );
    activity.update(
      const MvMinerStatus(
        running: true,
        phase: 'mining',
        sessionId: 'ios-1',
        activeDurationMs: 7000,
        startedAtMs: 3600000,
        verified: 2,
        log: ['02:00:00 verified block 2 (4 txs, 5 ms)'],
      ),
      now.add(const Duration(hours: 1)),
    );
    expect(activity.startedAt, started);
    expect(activity.blocks.map((b) => b.number), [2, 1]);
    expect(
      activity.duration(now.add(const Duration(hours: 1, seconds: 3))),
      const Duration(seconds: 10),
    );
    activity.update(
      const MvMinerStatus(
        running: false,
        phase: 'idle',
        sessionId: 'ios-1',
        activeDurationMs: 10000,
        startedAtMs: 3600000,
        verified: 2,
      ),
      now.add(const Duration(hours: 1, seconds: 3)),
    );
    expect(
      activity.duration(now.add(const Duration(hours: 2))),
      const Duration(seconds: 10),
    );
    activity.update(
      const MvMinerStatus(
        running: true,
        phase: 'mining',
        sessionId: 'ios-2',
        activeDurationMs: 0,
        verified: 2,
      ),
      now.add(const Duration(hours: 3)),
    );
    expect(activity.blocks, isEmpty);
  });
}
