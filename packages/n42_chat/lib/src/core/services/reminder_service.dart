import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../domain/entities/favorite_entity.dart';

/// 待办提醒服务
///
/// 监控 [FavoriteEntity.dueAt] 字段，到期时通过
/// [FlutterLocalNotificationsPlugin] 发送本地通知；
/// 同时提供按时间排序的待办列表查询 API。
///
/// 持久化于 SharedPreferences 键 `n42_todo_items`。
class ReminderService {
  static const String _storageKey = 'n42_todo_items';
  static const int _channelId = 42001;

  final FlutterLocalNotificationsPlugin _notifications;
  Timer? _checkTimer;
  final Set<String> _notifiedIds = {};

  ReminderService({FlutterLocalNotificationsPlugin? notifications})
      : _notifications =
            notifications ?? FlutterLocalNotificationsPlugin();

  /// 启动每分钟轮询检查到期待办。
  void startPolling() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDueTodos();
    });
    _checkDueTodos();
  }

  void stopPolling() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// 保存一个待办收藏到本地（追加或覆盖同 id）。
  Future<void> saveTodo(FavoriteEntity item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadAll(prefs);
    list.removeWhere((e) => e.id == item.id);
    list.add(item);
    await _persist(prefs, list);
  }

  /// 标记待办完成。
  Future<void> completeTodo(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadAll(prefs);
    final idx = list.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    list[idx] = list[idx].copyWith(isCompleted: true);
    _notifiedIds.remove(id);
    await _persist(prefs, list);
  }

  /// 删除待办。
  Future<void> removeTodo(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadAll(prefs);
    list.removeWhere((e) => e.id == id);
    _notifiedIds.remove(id);
    await _persist(prefs, list);
  }

  /// 获取所有待办，按 dueAt 升序排列。
  Future<List<FavoriteEntity>> getTodos({bool includeCompleted = false}) async {
    final prefs = await SharedPreferences.getInstance();
    var list = await _loadAll(prefs);
    if (!includeCompleted) {
      list = list.where((e) => !e.isCompleted).toList();
    }
    list.sort((a, b) {
      final aDue = a.dueAt ?? DateTime(9999);
      final bDue = b.dueAt ?? DateTime(9999);
      return aDue.compareTo(bDue);
    });
    return list;
  }

  /// 获取已过期未完成的待办。
  Future<List<FavoriteEntity>> getOverdueTodos() async {
    final all = await getTodos();
    return all.where((e) => e.isOverdue).toList();
  }

  Future<void> _checkDueTodos() async {
    try {
      final overdue = await getOverdueTodos();
      for (final item in overdue) {
        if (_notifiedIds.contains(item.id)) continue;
        _notifiedIds.add(item.id);
        await _showNotification(item);
      }
    } catch (_) {}
  }

  Future<void> _showNotification(FavoriteEntity item) async {
    const androidDetails = AndroidNotificationDetails(
      'n42_todo_reminder',
      'Todo Reminders',
      channelDescription: '待办到期提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    final body = item.content.length > 80
        ? '${item.content.substring(0, 80)}...'
        : item.content;
    await _notifications.show(
      id: _channelId + item.id.hashCode.abs() % 10000,
      title: '待办到期',
      body: body,
      notificationDetails: details,
    );
  }

  Future<List<FavoriteEntity>> _loadAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => FavoriteEntity.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _persist(SharedPreferences prefs, List<FavoriteEntity> items) {
    return prefs.setString(
      _storageKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  void dispose() {
    stopPolling();
  }
}
