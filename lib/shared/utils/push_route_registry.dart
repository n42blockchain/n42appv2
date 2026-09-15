import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 推送路由处理器：拿到导航 context 与推送 data 负责完成跳转。
typedef PushRouteHandler =
    void Function(BuildContext ctx, Map<String, dynamic> data);

/// 宿主推送通知的路由注册表。
///
/// 解耦点：`AppPushUtils`（features/utils）做通知分发时不 import 任何
/// feature 页面；需要跳转到具体 feature 页面的推送类型由 composition root
/// （`core/app/push_route_wiring.dart`，main 启动时调用）注册到这里。
/// 未注册的类型回落到 `app_push_navigation` 内置分支（tab 切换/告警日志）。
class PushRouteRegistry {
  PushRouteRegistry._();

  static final Map<String, PushRouteHandler> _handlers = {};

  /// 注册一个推送类型的处理器；同 type 重复注册以后者为准。
  static void register(String type, PushRouteHandler handler) {
    _handlers[type] = handler;
  }

  /// 批量注册。
  static void registerAll(Map<String, PushRouteHandler> handlers) {
    _handlers.addAll(handlers);
  }

  /// 查找处理器；未注册返回 null。
  static PushRouteHandler? resolve(Object? type) {
    if (type is! String) return null;
    return _handlers[type];
  }

  @visibleForTesting
  static void clear() => _handlers.clear();

  @visibleForTesting
  static Set<String> get registeredTypes => Set.unmodifiable(_handlers.keys);
}
