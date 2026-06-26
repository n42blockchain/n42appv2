import 'package:shared_preferences/shared_preferences.dart';

/// 跨通道、跨 isolate 的推送通知去重存储。
///
/// 同一条消息可能经由多条独立路径触发通知：
///   1. FCM 前台 `onMessage`（主 isolate）
///   2. Matrix sync timeline（主 isolate，app 切后台后短时间内仍活跃）
///   3. FCM `onBackgroundMessage`（独立后台 isolate）
/// 以及 FCM 自身的 at-least-once 重发。这些路径之间没有共享内存，
/// 因此用 SharedPreferences 持久化「已通知键」集合，弹通知前先
/// [tryMarkNotified]，返回 false 则跳过。
///
/// 键的选取：Matrix 消息用 `event_id`（全局唯一），非 Matrix 推送用
/// FCM `messageId`。两者键空间天然不冲突。
///
/// 跨 isolate 一致性：SharedPreferences 在每个 isolate 有独立缓存，
/// 查询前必须 [SharedPreferences.reload] 才能看到另一 isolate 的写入。
/// 仍存在极小的并发竞态窗口（两个 isolate 几乎同时标记同一键），
/// 由「通知 ID 取键的稳定哈希」兜底：即使竞态双弹，后一条会覆盖
/// 前一条同 ID 通知，用户最多看到一条。
class PushDedupStore {
  PushDedupStore({
    String prefsKey = _defaultPrefsKey,
    int capacity = _defaultCapacity,
    Duration ttl = _defaultTtl,
    DateTime Function()? now,
  })  : _prefsKey = prefsKey,
        _capacity = capacity,
        _ttl = ttl,
        _now = now ?? DateTime.now;

  static const String _defaultPrefsKey = 'n42_push.notified_keys';
  static const int _defaultCapacity = 300;
  static const Duration _defaultTtl = Duration(hours: 48);

  /// 进程级共享实例（主 isolate 与后台 isolate 各持有一个，
  /// 通过 SharedPreferences 磁盘层达成一致）。
  static final PushDedupStore instance = PushDedupStore();

  final String _prefsKey;
  final int _capacity;
  final Duration _ttl;
  final DateTime Function() _now;

  /// 串行化标记操作，避免同 isolate 内并发读改写丢失条目。
  Future<void> _pending = Future<void>.value();

  /// 若 [key] 未被通知过则标记并返回 true；已通知过返回 false。
  ///
  /// 返回 true 的调用方应继续展示通知；返回 false 的调用方跳过。
  ///
  /// fail-open：去重存储自身异常（SharedPreferences 平台错误等）时
  /// 返回 true —— 宁可冒重复通知的小风险，也不能因存储故障丢通知，
  /// 更不能把异常抛进各通知路径（多为无人捕获的 async 回调）。
  Future<bool> tryMarkNotified(String key) {
    final result = _pending
        .then((_) => _tryMarkNotifiedImpl(key))
        .catchError((Object _) => true);
    _pending = result.then((_) {});
    return result;
  }

  Future<bool> _tryMarkNotifiedImpl(String key) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // 看到其他 isolate 的最新写入（Android 后台 isolate 必需）。
      await prefs.reload();
    } catch (_) {
      // reload 在部分平台/测试环境不支持，降级为本 isolate 视图。
    }

    final nowMs = _now().millisecondsSinceEpoch;
    final ttlMs = _ttl.inMilliseconds;
    final raw = prefs.getStringList(_prefsKey) ?? const <String>[];

    var alreadyNotified = false;
    final kept = <String>[];
    for (final entry in raw) {
      final sep = entry.indexOf('|');
      if (sep <= 0) continue;
      final ts = int.tryParse(entry.substring(0, sep));
      if (ts == null || nowMs - ts > ttlMs) continue;
      final entryKey = entry.substring(sep + 1);
      if (entryKey == key) {
        alreadyNotified = true;
      }
      kept.add(entry);
    }

    if (alreadyNotified) {
      return false;
    }

    kept.add('$nowMs|$key');
    // 容量裁剪：丢最旧的（列表按插入序，旧条目在前）。
    final pruned = kept.length > _capacity
        ? kept.sublist(kept.length - _capacity)
        : kept;
    await prefs.setStringList(_prefsKey, pruned);
    return true;
  }

  /// 推送消息的去重键：Matrix `event_id` 全局唯一、跨通道一致，优先；
  /// 缺失时退回 FCM `messageId`（仅防同通道的 at-least-once 重发）。
  /// 两者都缺时返回 null —— 调用方应放行展示（无键可去重）。
  ///
  /// 所有通知路径（FCM 前台 / 后台 isolate / 宿主侧）必须经此派生，
  /// 保证同一条消息在任何通道上算出同一个键。
  static String? dedupKeyFor({String? eventId, String? messageId}) =>
      (eventId != null && eventId.isNotEmpty) ? eventId : messageId;

  /// 由 [key] 派生稳定的本地通知 ID（FNV-1a 32 位，截到正 int 范围）。
  ///
  /// 同一条消息无论从哪条路径弹出都映射到同一通知 ID —— 即使去重
  /// 竞态导致二次 show，也只是原地替换而不是在通知栏叠加第二条。
  /// 进程重启后 ID 依然稳定，修复了「后台 isolate 计数器归零导致
  /// 新通知覆盖通知栏旧通知」的丢失问题。
  static int notificationIdForKey(String key) {
    var hash = 0x811C9DC5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }
}
