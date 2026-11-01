import 'package:flutter_mining/mobileverify.dart';

enum MiningV3BlockState { pending, certified, uncertified, failed }

/// One observed block, with confirmation tied to its own block number.
class MiningV3Block {
  const MiningV3Block({
    required this.number,
    this.state = MiningV3BlockState.pending,
    this.transactions,
    this.elapsedMs,
    this.time,
    this.hash,
    this.receiptsRoot,
    this.signers,
    this.error,
  });

  final int number;
  final MiningV3BlockState state;
  final int? transactions;
  final int? elapsedMs;
  final String? time;
  final String? hash;
  final String? receiptsRoot;
  final int? signers;
  final String? error;

  MiningV3Block copyWith({
    MiningV3BlockState? state,
    int? transactions,
    int? elapsedMs,
    String? time,
    String? hash,
    String? receiptsRoot,
    int? signers,
    String? error,
  }) => MiningV3Block(
    number: number,
    state: state ?? this.state,
    transactions: transactions ?? this.transactions,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    time: time ?? this.time,
    hash: hash ?? this.hash,
    receiptsRoot: receiptsRoot ?? this.receiptsRoot,
    signers: signers ?? this.signers,
    error: error ?? this.error,
  );
}

/// A bounded view of real native activity, not a full chain history.
class MiningV3Activity {
  static const limit = 100;
  static final _verified = RegExp(
    r'^verified block (\d+) \((\d+) txs, (\d+) ms\)$',
  );
  static final _certified = RegExp(r'^block (\d+) certified, (\d+) signers$');
  static final _uncertified = RegExp(r'^block (\d+) not certified in time$');
  static final _failed = RegExp(r'^block (\d+) failed: (.+)$');
  static final _time = RegExp(r'^(\d{2}:\d{2}:\d{2}) ');

  static String _localLogTime(String clock, DateTime observedAt) {
    final parts = clock.split(':').map(int.parse).toList();
    if (parts[0] > 23 || parts[1] > 59 || parts[2] > 59) return clock;
    final now = observedAt.toUtc();
    var event = DateTime.utc(
      now.year,
      now.month,
      now.day,
      parts[0],
      parts[1],
      parts[2],
    );
    // The bounded log can include events just before UTC midnight.
    if (event.isAfter(now)) event = event.subtract(const Duration(days: 1));
    final local = event.toLocal();
    return [
      local.hour,
      local.minute,
      local.second,
    ].map((part) => part.toString().padLeft(2, '0')).join(':');
  }

  final _records = <int, MiningV3Block>{};
  String? _session;
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _wasRunning = false;
  Duration? _nativeDuration;
  DateTime? _observedAt;
  int _verifiedCount = 0;
  int _failedCount = 0;
  List<MiningV3Block> blocks = const [];

  DateTime? get startedAt => _startedAt;

  Duration? duration(DateTime now) {
    if (_nativeDuration case final Duration duration) {
      final delta = _wasRunning && _observedAt != null
          ? now.difference(_observedAt!)
          : Duration.zero;
      return duration + (delta.isNegative ? Duration.zero : delta);
    }
    final start = _startedAt;
    final end = _wasRunning ? now : _endedAt;
    if (start == null || end == null) return null;
    final elapsed = end.difference(start);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  void update(MvMinerStatus status, DateTime observedAt) {
    final session =
        status.sessionId ??
        '${status.startedAtMs}|${status.pubkey}|${status.endpoint}';
    if (_session != session ||
        status.verified < _verifiedCount ||
        status.failed < _failedCount) {
      _records.clear();
      _endedAt = null;
      _startedAt = null;
      _wasRunning = false;
    }
    _session = session;
    _verifiedCount = status.verified;
    _failedCount = status.failed;
    final start = status.startedAtMs;
    if (status.sessionId == null || _startedAt == null) {
      _startedAt = start != null && start > 0
          ? DateTime.fromMillisecondsSinceEpoch(start)
          : null;
    }
    final active = status.activeDurationMs;
    _nativeDuration = active != null && active >= 0
        ? Duration(milliseconds: active)
        : null;
    _observedAt = observedAt;
    if (_wasRunning && !status.running) _endedAt = observedAt;
    _wasRunning = status.running;

    // The native log also contains blocks between consecutive status polls.
    for (final line in status.log) {
      final clock = _time.firstMatch(line)?.group(1);
      final time = clock != null && status.logTimeUtc
          ? _localLogTime(clock, observedAt)
          : clock;
      final message = clock == null ? line : line.substring(clock.length + 1);
      final verified = _verified.firstMatch(message);
      final certified = _certified.firstMatch(message);
      final uncertified = _uncertified.firstMatch(message);
      final failed = _failed.firstMatch(message);
      final match = verified ?? certified ?? uncertified ?? failed;
      if (match == null) continue;
      final number = int.tryParse(match.group(1)!);
      if (number == null) continue;
      final old = _records[number] ?? MiningV3Block(number: number);
      _records[number] = verified != null
          ? old.copyWith(
              transactions: int.tryParse(verified.group(2)!),
              elapsedMs: int.tryParse(verified.group(3)!),
              time: time,
            )
          : old.copyWith(
              state: certified != null
                  ? MiningV3BlockState.certified
                  : failed != null
                  ? MiningV3BlockState.failed
                  : MiningV3BlockState.uncertified,
              signers: certified == null
                  ? null
                  : int.tryParse(certified.group(2)!),
              error: failed?.group(2),
              time: old.time ?? time,
            );
    }
    final last = status.lastBlock;
    if (last != null) {
      final old =
          _records[last.blockNumber] ?? MiningV3Block(number: last.blockNumber);
      _records[last.blockNumber] = old.copyWith(
        transactions: last.txs,
        elapsedMs: last.elapsedMs,
        hash: last.blockHash,
        receiptsRoot: last.receiptsRoot,
      );
    }
    final numbers = _records.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final number in numbers.skip(limit)) {
      _records.remove(number);
    }
    blocks = List.unmodifiable(numbers.take(limit).map((n) => _records[n]!));
  }
}
