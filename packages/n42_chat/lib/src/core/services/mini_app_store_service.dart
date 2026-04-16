import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/mini_app_entity.dart';
import '../utils/debug_log.dart';

/// Mini App 应用商店服务。
///
/// 管理 Mini App 的发现、安装、卸载、审核状态。
/// 数据来源：
/// - 内置 App（硬编码）
/// - 远端商店 API（未来 Matrix room state 或独立服务）
/// - 用户自定义添加（URL 直接输入）
class MiniAppStoreService {
  static const _installedKey = 'n42_miniapp_installed';
  static const _favoritesKey = 'n42_miniapp_favorites';

  final BehaviorSubject<List<MiniAppEntity>> _installed =
      BehaviorSubject.seeded(const []);
  bool _loaded = false;

  Stream<List<MiniAppEntity>> get installedStream => _installed.stream;
  List<MiniAppEntity> get installedApps => _installed.value;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_installedKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .whereType<Map<String, dynamic>>()
            .map(MiniAppEntity.fromJson)
            .toList();
        _installed.add(list);
      } catch (e) {
        debugLog('MiniAppStore: parse installed failed - $e');
      }
    }
    _loaded = true;
  }

  /// 安装一个 Mini App。
  Future<void> install(MiniAppEntity app) async {
    await _ensureLoaded();
    final list = [..._installed.value];
    if (list.any((a) => a.id == app.id)) return;
    list.add(app);
    await _persist(list);
  }

  /// 卸载一个 Mini App（内置 App 不可卸载）。
  Future<bool> uninstall(String appId) async {
    await _ensureLoaded();
    final list = _installed.value.toList();
    final idx = list.indexWhere((a) => a.id == appId);
    if (idx < 0) return false;
    if (list[idx].isBuiltIn) return false;
    list.removeAt(idx);
    await _persist(list);
    return true;
  }

  /// 按分类获取已安装的 App。
  Future<List<MiniAppEntity>> getByCategory(MiniAppCategory category) async {
    await _ensureLoaded();
    return _installed.value.where((a) => a.category == category).toList();
  }

  /// 搜索（名称或描述模糊匹配）。
  Future<List<MiniAppEntity>> search(String query) async {
    await _ensureLoaded();
    final lower = query.toLowerCase();
    return _installed.value.where((a) {
      return a.name.toLowerCase().contains(lower) ||
          a.description.toLowerCase().contains(lower);
    }).toList();
  }

  /// 收藏/取消收藏。
  Future<void> toggleFavorite(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favoritesKey) ?? [];
    if (favs.contains(appId)) {
      favs.remove(appId);
    } else {
      favs.add(appId);
    }
    await prefs.setStringList(_favoritesKey, favs);
  }

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? []).toSet();
  }

  /// 推荐 / 精选列表（来自远端或硬编码）。
  Future<List<MiniAppEntity>> getFeatured() async {
    // 远端 API 未接入时返回内置列表。
    return const [];
  }

  /// 按分类获取可发现的所有 App（含远端商店）。
  Future<List<MiniAppEntity>> discover({MiniAppCategory? category}) async {
    // 远端 API 未接入时返回空。
    return const [];
  }

  Future<void> _persist(List<MiniAppEntity> list) async {
    _installed.add(list);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _installedKey,
      jsonEncode(list.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> dispose() async {
    await _installed.close();
  }
}
