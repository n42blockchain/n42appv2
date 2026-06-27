import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/notification_filter_rules.dart';

/// 智能通知过滤规则持久化（SharedPreferences，轻量）
///
/// 与 NotificationSettings 解耦，单独键存储优先/屏蔽关键词与优先发送者。
class NotificationFilterStore {
  static const String _key = 'n42.chat.notification_filter_rules';

  /// 读取规则；无存储/损坏返回空规则
  Future<NotificationFilterRules> load() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationFilterRules.decode(prefs.getString(_key));
  }

  /// 保存规则
  Future<void> save(NotificationFilterRules rules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, rules.encode());
  }
}
