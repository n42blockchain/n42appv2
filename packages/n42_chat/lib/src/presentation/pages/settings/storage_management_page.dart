import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/media_lifecycle_service.dart';
import '../../../core/services/storage_cleanup_service.dart';
import '../../../core/services/storage_manager_service.dart';
import '../../../core/services/storage_monitor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/storage/storage_management_bloc.dart';
import '../../blocs/storage/storage_management_event.dart';
import '../../blocs/storage/storage_management_state.dart';
import '../../widgets/common/common_widgets.dart';
import 'room_storage_detail_page.dart';

/// 微信风格存储管理页面
class StorageManagementPage extends StatelessWidget {
  const StorageManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StorageManagementBloc(
        storageManager: GetIt.instance<StorageManagerService>(),
        lifecycleService: GetIt.instance<MediaLifecycleService>(),
        cleanupService: GetIt.instance<StorageCleanupService>(),
        monitorService: GetIt.instance<StorageMonitorService>(),
      )..add(const LoadStorageInfo()),
      child: const _StorageManagementView(),
    );
  }
}

class _StorageManagementView extends StatelessWidget {
  const _StorageManagementView();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        title: Text(
          S.of(context)?.storageManagement ?? 'Storage',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<StorageManagementBloc, StorageManagementState>(
        listener: (context, state) {
          if (state.lastCleanupResult != null) {
            final result = state.lastCleanupResult!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Freed ${StorageInfo.formatSize(result.bytesFreed)} '
                  '(${result.filesDeleted} files)',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.storageInfo == null) {
            return const Center(child: N42Loading());
          }
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<StorageManagementBloc>()
                  .add(const LoadStorageInfo());
            },
            child: ListView(
              children: [
                _StorageOverviewSection(state: state),
                if (state.storageStatus?.level != StorageLevel.normal)
                  _StorageWarningBanner(state: state),
                const SizedBox(height: 10),
                if (state.recommendations.isNotEmpty)
                  _SmartCleanupSection(state: state),
                const SizedBox(height: 10),
                _RoomStorageSection(state: state),
                const SizedBox(height: 10),
                _StorageSettingsSection(state: state),
                const SizedBox(height: 10),
                _ClearCacheButton(state: state),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 总用量 + 环形图分类比例
class _StorageOverviewSection extends StatelessWidget {
  final StorageManagementState state;

  const _StorageOverviewSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final info = state.storageInfo;
    if (info == null) return const SizedBox.shrink();

    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      color: cardColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 环形图
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _StorageRingPainter(
                mediaRatio: info.totalSize > 0
                    ? info.mediaSize / info.totalSize
                    : 0,
                fileRatio: info.totalSize > 0
                    ? info.fileSize / info.totalSize
                    : 0,
                cacheRatio: info.totalSize > 0
                    ? info.cacheSize / info.totalSize
                    : 0,
                otherRatio: info.totalSize > 0
                    ? info.otherSize / info.totalSize
                    : 0,
                isDark: isDark,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      info.formattedTotal,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      S.of(context)?.totalUsage ?? 'Total Usage',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 分类图例
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(
                color: Colors.blue,
                label: S.of(context)?.mediaFiles ?? 'Media',
                size: info.formattedMedia,
              ),
              _LegendItem(
                color: Colors.orange,
                label: S.of(context)?.files ?? 'Files',
                size: info.formattedFile,
              ),
              _LegendItem(
                color: Colors.green,
                label: S.of(context)?.cache ?? 'Cache',
                size: info.formattedCache,
              ),
              _LegendItem(
                color: Colors.grey,
                label: S.of(context)?.other ?? 'Other',
                size: info.formattedOther,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String size;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        Text(
          size,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 预警横幅
class _StorageWarningBanner extends StatelessWidget {
  final StorageManagementState state;

  const _StorageWarningBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final level = state.storageStatus?.level ?? StorageLevel.normal;
    final isCritical = level == StorageLevel.critical;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCritical
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.error : Icons.warning_amber,
            color: isCritical ? Colors.red : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCritical
                  ? 'Storage is critically low. Please clean up to free space.'
                  : 'Storage usage is high. Consider cleaning up old files.',
              style: TextStyle(
                fontSize: 13,
                color: isCritical ? Colors.red[800] : Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 智能清理卡片 + 建议列表
class _SmartCleanupSection extends StatelessWidget {
  final StorageManagementState state;

  const _SmartCleanupSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Container(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.auto_fix_high,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Smart Cleanup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          ...state.recommendations
              .where((r) =>
                  r.type != CleanupRecommendationType.roomSpecific)
              .take(3)
              .map((rec) => _RecommendationTile(
                    recommendation: rec,
                    isCleaning: state.isCleaning,
                  )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final CleanupRecommendation recommendation;
  final bool isCleaning;

  const _RecommendationTile({
    required this.recommendation,
    required this.isCleaning,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    IconData icon;
    Color color;
    switch (recommendation.type) {
      case CleanupRecommendationType.oldMedia:
        icon = Icons.history;
        color = Colors.blue;
        break;
      case CleanupRecommendationType.largeFiles:
        icon = Icons.file_present;
        color = Colors.orange;
        break;
      case CleanupRecommendationType.cache:
        icon = Icons.cached;
        color = Colors.green;
        break;
      case CleanupRecommendationType.roomSpecific:
        icon = Icons.chat;
        color = Colors.purple;
        break;
    }

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        recommendation.title,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        recommendation.description,
        style: TextStyle(fontSize: 12, color: secondaryColor),
      ),
      trailing: TextButton(
        onPressed: isCleaning
            ? null
            : () => context
                .read<StorageManagementBloc>()
                .add(ExecuteCleanup(recommendation)),
        child: Text(
          recommendation.formattedSize,
          style: TextStyle(
            color: isCleaning ? secondaryColor : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 房间存储排行
class _RoomStorageSection extends StatelessWidget {
  final StorageManagementState state;

  const _RoomStorageSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    if (state.roomStorageList.isEmpty) return const SizedBox.shrink();

    return Container(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              S.of(context)?.roomStorageRanking ?? 'Room Storage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          ...state.roomStorageList.take(5).map(
                (room) => ListTile(
                  title: Text(
                    room.roomName,
                    style: TextStyle(fontSize: 15, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${room.mediaCount} files',
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        room.formattedSize,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right,
                          size: 20, color: secondaryColor),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider.value(
                          value: context.read<StorageManagementBloc>(),
                          child: RoomStorageDetailPage(
                            roomId: room.roomId,
                            roomName: room.roomName,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          if (state.roomStorageList.length > 5)
            ListTile(
              title: Text(
                'View all ${state.roomStorageList.length} rooms',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () {
                // TODO: Navigate to full room list
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 存储设置
class _StorageSettingsSection extends StatelessWidget {
  final StorageManagementState state;

  const _StorageSettingsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final config = state.storageConfig ?? const StorageConfig();

    return Container(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Storage Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(
              'Auto Cleanup',
              style: TextStyle(fontSize: 15, color: textColor),
            ),
            subtitle: Text(
              'Automatically clean files older than ${config.autoCleanupDays} days',
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
            value: config.autoCleanupEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: (value) {
              context.read<StorageManagementBloc>().add(
                    UpdateStorageConfig(autoCleanupEnabled: value),
                  );
            },
          ),
          Divider(
              height: 1,
              indent: 16,
              color: isDark ? AppColors.dividerDark : AppColors.divider),
          ListTile(
            title: Text(
              'Cleanup Period',
              style: TextStyle(fontSize: 15, color: textColor),
            ),
            trailing: DropdownButton<int>(
              value: config.autoCleanupDays,
              underline: const SizedBox.shrink(),
              items: [30, 60, 90, 180, 365].map((days) {
                return DropdownMenuItem(
                  value: days,
                  child: Text('$days days'),
                );
              }).toList(),
              onChanged: (days) {
                if (days != null) {
                  context.read<StorageManagementBloc>().add(
                        UpdateStorageConfig(autoCleanupDays: days),
                      );
                }
              },
            ),
          ),
          Divider(
              height: 1,
              indent: 16,
              color: isDark ? AppColors.dividerDark : AppColors.divider),
          SwitchListTile(
            title: Text(
              'Preserve Thumbnails',
              style: TextStyle(fontSize: 15, color: textColor),
            ),
            subtitle: Text(
              'Keep image thumbnails during cleanup',
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
            value: config.preserveThumbnails,
            activeTrackColor: AppColors.primary,
            onChanged: (value) {
              context.read<StorageManagementBloc>().add(
                    UpdateStorageConfig(preserveThumbnails: value),
                  );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 清除缓存按钮
class _ClearCacheButton extends StatelessWidget {
  final StorageManagementState state;

  const _ClearCacheButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Container(
      color: cardColor,
      child: ListTile(
        leading: const Icon(Icons.cleaning_services, color: AppColors.primary),
        title: Text(
          S.of(context)?.clearCache ?? 'Clear Cache',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          state.storageInfo?.formattedCache ?? '',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: state.isCleaning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: state.isCleaning
            ? null
            : () => _confirmClearCache(context),
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.clearCache ?? 'Clear Cache'),
        content: Text(S.of(context)?.confirmClearCache ??
            'Clear all cache data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<StorageManagementBloc>()
                  .add(const ClearCache());
            },
            child: Text(S.of(context)?.commonConfirm ?? 'OK'),
          ),
        ],
      ),
    );
  }
}

/// 环形图绘制器
class _StorageRingPainter extends CustomPainter {
  final double mediaRatio;
  final double fileRatio;
  final double cacheRatio;
  final double otherRatio;
  final bool isDark;

  _StorageRingPainter({
    required this.mediaRatio,
    required this.fileRatio,
    required this.cacheRatio,
    required this.otherRatio,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 16.0;
    final rect = Rect.fromCircle(
        center: center, radius: radius - strokeWidth / 2);

    // 背景圆环
    final bgPaint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (mediaRatio + fileRatio + cacheRatio + otherRatio == 0) return;

    // 绘制各段
    var startAngle = -math.pi / 2;
    void drawArc(double ratio, Color color) {
      if (ratio <= 0) return;
      final sweep = ratio * 2 * math.pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    drawArc(mediaRatio, Colors.blue);
    drawArc(fileRatio, Colors.orange);
    drawArc(cacheRatio, Colors.green);
    drawArc(otherRatio, Colors.grey);
  }

  @override
  bool shouldRepaint(covariant _StorageRingPainter oldDelegate) {
    return mediaRatio != oldDelegate.mediaRatio ||
        fileRatio != oldDelegate.fileRatio ||
        cacheRatio != oldDelegate.cacheRatio ||
        otherRatio != oldDelegate.otherRatio;
  }
}
