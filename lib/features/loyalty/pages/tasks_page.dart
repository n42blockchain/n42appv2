// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_model.dart';
import 'package:n42_wallet/features/loyalty/provider/loyalty_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 任务列表过滤枚举
enum _TaskFilter { all, available, completed }

/// 任务列表页面
class TasksPage extends StatefulWidget {
  final List<LoyaltyTask> tasks;
  final LoyaltyProvider provider;

  const TasksPage({
    super.key,
    required this.tasks,
    required this.provider,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  _TaskFilter _filter = _TaskFilter.all;

  /// 正在提交的任务 ID 集合（用于显示 loading 状态）
  final Set<String> _completingTaskIds = {};

  List<LoyaltyTask> get _filteredTasks {
    switch (_filter) {
      case _TaskFilter.all:
        return widget.tasks;
      case _TaskFilter.available:
        return widget.tasks.where((t) => t.canComplete).toList();
      case _TaskFilter.completed:
        return widget.tasks.where((t) => t.status == TaskStatus.completed).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks;

    return Column(
      children: [
        // 过滤条
        _buildFilterBar(context),

        // 列表
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyView(context)
              : _buildTaskList(context, filtered),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final total = widget.tasks.length;
    final available = widget.tasks.where((t) => t.canComplete).length;
    final completed = widget.tasks.where((t) => t.status == TaskStatus.completed).length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(10),
      ),
      child: Row(
        children: [
          _filterChip(context, 'All ($total)', _TaskFilter.all),
          SizedBox(width: ScreenUtil().setWidth(8)),
          _filterChip(context, 'Active ($available)', _TaskFilter.available),
          SizedBox(width: ScreenUtil().setWidth(8)),
          _filterChip(context, 'Done ($completed)', _TaskFilter.completed),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, _TaskFilter value) {
    final selected = _filter == value;
    final color = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(14),
          vertical: ScreenUtil().setWidth(6),
        ),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? Colors.white
                : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            _filter == _TaskFilter.completed
                ? 'No completed tasks yet'
                : 'No tasks available',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<LoyaltyTask> tasks) {
    // 分组
    final dailyTasks = tasks.where((t) => t.type == TaskType.dailyCheckIn).toList();
    final specialTasks = tasks.where((t) => t.type == TaskType.special).toList();
    final regularTasks = tasks
        .where((t) => t.type != TaskType.dailyCheckIn && t.type != TaskType.special)
        .toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        ScreenUtil().setWidth(16),
        0,
        ScreenUtil().setWidth(16),
        ScreenUtil().setWidth(16),
      ),
      children: [
        if (dailyTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Daily Tasks', dailyTasks.length),
          ...dailyTasks.map((task) => _buildTaskCard(context, task)),
          SizedBox(height: ScreenUtil().setWidth(8)),
        ],
        if (specialTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Special Events', specialTasks.length),
          ...specialTasks.map((task) => _buildTaskCard(context, task)),
          SizedBox(height: ScreenUtil().setWidth(8)),
        ],
        if (regularTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Tasks', regularTasks.length),
          ...regularTasks.map((task) => _buildTaskCard(context, task)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(4),
        top: ScreenUtil().setWidth(8),
        bottom: ScreenUtil().setWidth(12),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(8),
              vertical: ScreenUtil().setWidth(2),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, LoyaltyTask task) {
    final isCompleted = task.status == TaskStatus.completed;
    final canComplete = task.canComplete;
    final isChecking = _completingTaskIds.contains(task.id);
    final taskColor = _getTaskColor(task.type);
    final hasProgress =
        task.maxCompletions != null && task.maxCompletions! > 1 && task.completedCount > 0;
    final progressValue = hasProgress
        ? task.completedCount / task.maxCompletions!
        : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: task.type == TaskType.special
            ? Border.all(
                color: Colors.amber.withValues(alpha: 0.6),
                width: 1,
              )
            : isCompleted
                ? Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任务图标
          Container(
            width: ScreenUtil().setWidth(52),
            height: ScreenUtil().setWidth(52),
            decoration: BoxDecoration(
              color: taskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Text(
                task.icon,
                style: TextStyle(fontSize: ScreenUtil().setSp(28)),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),

          // 任务信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题 + 积分
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.green,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(10),
                        vertical: ScreenUtil().setWidth(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                      ),
                      child: Text(
                        '+${task.points}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),

                // 描述
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),

                // 进度条（多次任务）
                if (hasProgress) ...[
                  SizedBox(height: ScreenUtil().setWidth(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${task.completedCount}/${task.maxCompletions} completed',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                      Text(
                        '${(progressValue * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: taskColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(4)),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor:
                          taskColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(taskColor),
                      minHeight: ScreenUtil().setWidth(6),
                    ),
                  ),
                ],

                // 完成次数（单次任务，显示 0/1）
                if (!hasProgress &&
                    task.maxCompletions != null &&
                    task.expiresAt != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  Text(
                    '${task.completedCount}/${task.maxCompletions}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                ],

                // 过期时间
                if (task.expiresAt != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: ScreenUtil().setWidth(18),
                        color: _isExpiringSoon(task.expiresAt!)
                            ? Colors.orange
                            : AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.itemSubtitleTextColor.name,
                              ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(4)),
                      Text(
                        _getExpiryText(task.expiresAt!),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: _isExpiringSoon(task.expiresAt!)
                              ? Colors.orange
                              : AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.itemSubtitleTextColor.name,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],

                // 操作按钮（未完成）
                if (!isCompleted) ...[
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (canComplete && !isChecking)
                          ? () => _handleTaskAction(context, task)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: taskColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            taskColor.withValues(alpha: 0.3),
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(10),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                        ),
                      ),
                      child: isChecking
                          ? SizedBox(
                              width: ScreenUtil().setWidth(20),
                              height: ScreenUtil().setWidth(20),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _getButtonText(task),
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(24),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],

                // 已完成标记
                if (isCompleted) ...[
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: ScreenUtil().setWidth(22),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(6)),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (task.lastCompletedAt != null) ...[
                        Text(
                          ' · ${_relativeTime(task.lastCompletedAt!)}',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(22),
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(TaskType type) {
    switch (type) {
      case TaskType.dailyCheckIn:
        return Colors.amber;
      case TaskType.transaction:
        return Colors.blue;
      case TaskType.referral:
        return Colors.green;
      case TaskType.staking:
        return Colors.purple;
      case TaskType.dappUsage:
        return Colors.orange;
      case TaskType.social:
        return Colors.pink;
      case TaskType.special:
        return Colors.red;
    }
  }

  String _getButtonText(LoyaltyTask task) {
    switch (task.type) {
      case TaskType.dailyCheckIn:
        return 'Check In';
      case TaskType.social:
        return task.actionUrl != null ? 'Go →' : 'Follow';
      case TaskType.referral:
        return 'Invite Friends';
      case TaskType.dappUsage:
        return task.actionUrl != null ? 'Open →' : 'Complete';
      case TaskType.staking:
        return task.actionUrl != null ? 'Go Stake →' : 'Complete';
      default:
        return 'Complete';
    }
  }

  String _getExpiryText(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours < 1) return '${diff.inMinutes}m left';
    if (diff.inHours < 24) return '${diff.inHours}h left';
    return '${diff.inDays}d left';
  }

  bool _isExpiringSoon(DateTime expiresAt) {
    return expiresAt.difference(DateTime.now()).inDays <= 1;
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  Future<void> _handleTaskAction(BuildContext context, LoyaltyTask task) async {
    final url = task.actionUrl;

    if (url != null && url.startsWith('http')) {
      // 外部链接：钓鱼检测 + 真实打开
      await _launchExternalUrl(context, url);
    } else if (url != null) {
      // 内部路由导航（暂时用 SnackBar 提示，Navigator 由上层处理）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening $url...')),
      );
    } else {
      // 直接完成任务
      setState(() => _completingTaskIds.add(task.id));
      try {
        final success = await widget.provider.completeTask(task.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? '🎉 Task completed! +${task.points} pts'
                    : 'Failed to complete task. Please try again.',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _completingTaskIds.remove(task.id));
      }
    }
  }

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final result = PhishingDetector.instance.checkUrl(url);
    if (result == PhishingCheckResult.phishing) {
      if (!context.mounted) return;
      final proceed = await showPhishingWarningDialog(context, url);
      if (proceed != true) return;
      PhishingDetector.instance.allowForSession(url);
    }

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $url')),
        );
      }
    }
  }
}
