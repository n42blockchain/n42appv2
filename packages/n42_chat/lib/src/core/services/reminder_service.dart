import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/datasources/local/preferences_datasource.dart';
import '../../domain/entities/favorite_entity.dart';
import '../utils/debug_log.dart';

/// 待办提醒服务
///
/// 提醒以 [FavoriteEntity]（含 `dueAt`/`isCompleted`）持久化于偏好存储（独立 key），
/// 由一个 60s 周期检查器扫描到期且未完成的提醒并弹本地通知。
///
/// 通知通过**自带的 FlutterLocalNotificationsPlugin 实例只调 `show()`**——
/// 不调用 `initialize()`，复用 push 服务已完成的原生初始化，避免覆盖其 tap 回调。
/// 局限：进程被系统完全杀死时不触发（前台/存活态可靠）；这是不引入 timezone/
/// zonedSchedule 的务实取舍。
class ReminderService {
  final PreferencesDataSource _prefs;

  ReminderService(this._prefs);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'n42_reminders';
  static const String _channelName = 'Reminders';

  Timer? _timer;
  bool _channelReady = false;

  /// 已弹过通知的提醒 id（避免每 60s 重复弹；进程内即可）
  final Set<String> _notified = <String>{};

  /// 启动周期检查（幂等）
  void start() {
    _timer?.cancel();
    // 立即查一次，之后每分钟一次
    unawaited(_checkDue());
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkDue());
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  // ============================================
  // CRUD
  // ============================================

  Future<List<FavoriteEntity>> getReminders() async {
    final raw = await _prefs.getReminders();
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(FavoriteEntity.fromJson)
          .toList();
      // 未完成在前，按 dueAt 升序
      items.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        final ad = a.dueAt, bd = b.dueAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
      return items;
    } catch (e) {
      debugLog('ReminderService: parse reminders failed: $e');
      return [];
    }
  }

  Future<void> _save(List<FavoriteEntity> items) async {
    await _prefs.saveReminders(
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// 新增/更新一条提醒（按 id 去重覆盖）
  Future<void> upsert(FavoriteEntity reminder) async {
    final items = await getReminders();
    items.removeWhere((e) => e.id == reminder.id);
    items.add(reminder);
    await _save(items);
    _notified.remove(reminder.id); // dueAt 变更后允许再次提醒
    start();
  }

  Future<void> remove(String id) async {
    final items = await getReminders();
    items.removeWhere((e) => e.id == id);
    await _save(items);
    _notified.remove(id);
  }

  Future<void> toggleComplete(String id) async {
    final items = await getReminders();
    final i = items.indexWhere((e) => e.id == id);
    if (i == -1) return;
    items[i] = items[i].copyWith(isCompleted: !items[i].isCompleted);
    await _save(items);
  }

  /// 从一条消息创建提醒
  Future<FavoriteEntity> createFromMessage({
    required String text,
    required DateTime dueAt,
    String? roomId,
    String? roomName,
    String? messageId,
    String? senderName,
  }) async {
    final reminder = FavoriteEntity(
      id: 'rem_${DateTime.now().microsecondsSinceEpoch}',
      type: FavoriteType.note,
      content: text,
      sourceRoomId: roomId,
      sourceRoomName: roomName,
      sourceMessageId: messageId,
      sourceSenderName: senderName,
      createdAt: DateTime.now(),
      dueAt: dueAt,
    );
    await upsert(reminder);
    return reminder;
  }

  // ============================================
  // 到期检查 + 通知
  // ============================================

  Future<void> _checkDue() async {
    try {
      final items = await getReminders();
      for (final r in items) {
        if (r.isReminderDue && !_notified.contains(r.id)) {
          await _notify(r);
          _notified.add(r.id);
        }
      }
    } catch (e) {
      debugLog('ReminderService: checkDue failed: $e');
    }
  }

  Future<void> _ensureChannel() async {
    if (_channelReady) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: 'Todo reminders',
              importance: Importance.high,
            ),
          );
      _channelReady = true;
    } catch (e) {
      debugLog('ReminderService: ensureChannel failed: $e');
    }
  }

  Future<void> _notify(FavoriteEntity r) async {
    await _ensureChannel();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
    final body = r.content.isEmpty
        ? 'Reminder'
        : (r.content.length > 80 ? '${r.content.substring(0, 80)}…' : r.content);
    try {
      await _plugin.show(
        id: r.id.hashCode & 0x7fffffff,
        title: 'Reminder',
        body: body,
        notificationDetails: details,
        payload: jsonEncode({'room_id': r.sourceRoomId, 'reminder_id': r.id}),
      );
    } catch (e) {
      debugLog('ReminderService: show notification failed: $e');
    }
  }
}
