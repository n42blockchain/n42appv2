import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/bridge_entity.dart';
import '../utils/debug_log.dart';

/// 跨协议 Bridge 管理服务。
///
/// 管理已配置的 Matrix Appservice Bridge 实例（Slack/Discord/Telegram/…），
/// 提供连接状态监控、房间映射查询、启用/禁用 API。
///
/// 实际桥接由 Matrix Homeserver 侧的 Appservice 完成，
/// 本服务只管元数据与 UI 呈现。
class BridgeManagementService {
  static const _storageKey = 'n42_bridge_configs';

  final BehaviorSubject<List<BridgeEntity>> _bridges =
      BehaviorSubject.seeded(const []);
  bool _loaded = false;

  Stream<List<BridgeEntity>> get bridgesStream => _bridges.stream;
  List<BridgeEntity> get currentBridges => _bridges.value;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .whereType<Map<String, dynamic>>()
            .map(BridgeEntity.fromJson)
            .toList();
        _bridges.add(list);
      } catch (e) {
        debugLog('BridgeService: parse failed - $e');
      }
    }
    _loaded = true;
  }

  /// 添加或更新一个桥接配置。
  Future<void> saveBridge(BridgeEntity bridge) async {
    await _ensureLoaded();
    final list = [..._bridges.value];
    list.removeWhere((b) => b.id == bridge.id);
    list.add(bridge);
    await _persist(list);
  }

  /// 移除桥接配置。
  Future<void> removeBridge(String bridgeId) async {
    await _ensureLoaded();
    final list = _bridges.value.where((b) => b.id != bridgeId).toList();
    await _persist(list);
  }

  /// 更新桥接连接状态。
  Future<void> updateStatus(
    String bridgeId,
    BridgeConnectionStatus status, {
    String? errorMessage,
  }) async {
    await _ensureLoaded();
    final list = _bridges.value.map((b) {
      if (b.id == bridgeId) {
        return b.copyWith(
          status: status,
          errorMessage: errorMessage,
          connectedAt:
              status == BridgeConnectionStatus.connected ? DateTime.now() : null,
        );
      }
      return b;
    }).toList();
    await _persist(list);
  }

  /// 获取指定协议的桥接列表。
  Future<List<BridgeEntity>> getBridgesByProtocol(BridgeProtocol protocol) async {
    await _ensureLoaded();
    return _bridges.value.where((b) => b.protocol == protocol).toList();
  }

  /// 获取与指定 Matrix 房间关联的桥接。
  Future<BridgeEntity?> getBridgeForRoom(String roomId) async {
    await _ensureLoaded();
    for (final bridge in _bridges.value) {
      if (bridge.linkedRoomIds.contains(roomId)) return bridge;
    }
    return null;
  }

  /// 预置可用桥接模板（首次使用时显示可安装项）。
  List<BridgeEntity> get availableBridgeTemplates => [
        const BridgeEntity(
          id: 'slack_template',
          protocol: BridgeProtocol.slack,
          displayName: 'Slack',
          iconUrl: 'assets/icons/bridge_slack.png',
        ),
        const BridgeEntity(
          id: 'discord_template',
          protocol: BridgeProtocol.discord,
          displayName: 'Discord',
          iconUrl: 'assets/icons/bridge_discord.png',
        ),
        const BridgeEntity(
          id: 'telegram_template',
          protocol: BridgeProtocol.telegram,
          displayName: 'Telegram',
          iconUrl: 'assets/icons/bridge_telegram.png',
        ),
        const BridgeEntity(
          id: 'whatsapp_template',
          protocol: BridgeProtocol.whatsapp,
          displayName: 'WhatsApp',
          iconUrl: 'assets/icons/bridge_whatsapp.png',
        ),
        const BridgeEntity(
          id: 'signal_template',
          protocol: BridgeProtocol.signal,
          displayName: 'Signal',
          iconUrl: 'assets/icons/bridge_signal.png',
        ),
      ];

  Future<void> _persist(List<BridgeEntity> list) async {
    _bridges.add(list);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(list.map((b) => b.toJson()).toList()),
    );
  }

  Future<void> dispose() async {
    await _bridges.close();
  }
}
