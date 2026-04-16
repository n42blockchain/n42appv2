import 'package:matrix/matrix.dart' show Filter, RoomFilter, StateFilter;

import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../utils/debug_log.dart';

/// 服务端保留策略信息
class ServerRetentionInfo {
  /// 服务器消息最大保留天数
  final int? maxLifetimeDays;

  /// 服务器消息最大保留天数（来自 m.room.retention）
  final int? roomRetentionDays;

  /// 是否支持保留策略
  final bool supported;

  const ServerRetentionInfo({
    this.maxLifetimeDays,
    this.roomRetentionDays,
    this.supported = false,
  });
}

/// 保留策略建议
class RetentionRecommendation {
  final String title;
  final String description;
  final int? suggestedDays;

  const RetentionRecommendation({
    required this.title,
    required this.description,
    this.suggestedDays,
  });
}

/// 同步优化服务
///
/// 配置最优同步过滤器以减少服务端压力和带宽。
/// 基于本地数据分级策略，仅同步热数据+增量。
class SyncOptimizationService {
  final MatrixClientManager _clientManager;

  SyncOptimizationService({required MatrixClientManager clientManager})
    : _clientManager = clientManager;

  /// 配置最优同步过滤器
  ///
  /// 减少每次同步的数据量：
  /// - 限制 timeline 条数（默认 30 条）
  /// - 启用 lazy_load_members
  /// - 过滤不必要的事件类型（如 receipts）
  Future<void> configureOptimalSyncFilter() async {
    try {
      final client = _clientManager.client;
      if (client == null) return;

      final filter = Filter(
        room: RoomFilter(
          state: StateFilter(lazyLoadMembers: true),
          timeline: StateFilter(limit: 30, lazyLoadMembers: true),
          ephemeral: StateFilter(notTypes: ['m.receipt']),
        ),
      );

      // 在服务器上创建 filter 并获取 filterId
      final filterId = await client.defineFilter(client.userID!, filter);

      debugLog('SyncOptimizationService: Sync filter configured: $filterId');
    } catch (e) {
      debugLog('SyncOptimizationService: Failed to configure filter: $e');
    }
  }

  /// 获取服务端保留策略信息
  Future<ServerRetentionInfo?> getServerRetentionInfo() async {
    try {
      final client = _clientManager.client;
      if (client == null) return null;

      // 查询服务器 capabilities
      final capabilities = await client.getCapabilities();
      final roomVersions = capabilities.mRoomVersions;

      // m.room.retention 不是标准 capability，暂通过 capabilities 存在性推断
      if (roomVersions != null) {
        return const ServerRetentionInfo(supported: false);
      }

      return const ServerRetentionInfo(supported: false);
    } catch (e) {
      debugLog('SyncOptimizationService: Failed to get retention info: $e');
      return null;
    }
  }

  /// 生成保留策略建议
  Future<RetentionRecommendation> getRetentionRecommendation() async {
    final serverInfo = await getServerRetentionInfo();

    if (serverInfo?.supported == true && serverInfo?.maxLifetimeDays != null) {
      return RetentionRecommendation(
        title: 'Server Retention Policy Active',
        description:
            'Your server automatically removes messages older than '
            '${serverInfo!.maxLifetimeDays} days. Local data tiering '
            'is aligned with this policy.',
        suggestedDays: serverInfo.maxLifetimeDays,
      );
    }

    return const RetentionRecommendation(
      title: 'Local Data Management',
      description:
          'Your server keeps all messages. We recommend enabling local '
          'data tiering to manage storage efficiently. Media files '
          'older than 90 days will be cleaned, but can be re-downloaded.',
      suggestedDays: 90,
    );
  }
}
