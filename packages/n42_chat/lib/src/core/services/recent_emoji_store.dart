import 'package:shared_preferences/shared_preferences.dart';

/// 最近使用的 emoji 存储（轻量，SharedPreferences 持久化）
///
/// emoji 选择器本身不记录历史；统一表情面板的「最近」分页用本存储补齐。
/// 贴纸的最近使用由 IStickerRepository.getRecentStickers/recordStickerUsage 负责。
class RecentEmojiStore {
  static const String _key = 'n42.chat.recent_emojis';
  static const int _max = 24;

  /// 读取最近 emoji（最新在前）
  Future<List<String>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  /// 记录一次使用：去重后置顶，截断到 [_max]
  Future<void> record(String emoji) async {
    if (emoji.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    list.remove(emoji);
    list.insert(0, emoji);
    if (list.length > _max) {
      list.removeRange(_max, list.length);
    }
    await prefs.setStringList(_key, list);
  }
}
