// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/loyalty/models/loyalty_model.dart';
import 'package:n42appv2/src/loyalty/provider/loyalty_provider.dart';

/// 任务列表页面
class TasksPage extends StatelessWidget {
  final List<LoyaltyTask> tasks;
  final LoyaltyProvider provider;

  const TasksPage({
    super.key,
    required this.tasks,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment,
              size: ScreenUtil().setWidth(80),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              'No tasks available',
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

    // 分组任务
    final dailyTasks = tasks.where((t) => t.type == TaskType.dailyCheckIn).toList();
    final specialTasks = tasks.where((t) => t.type == TaskType.special).toList();
    final regularTasks = tasks
        .where((t) =>
            t.type != TaskType.dailyCheckIn && t.type != TaskType.special)
        .toList();

    return ListView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      children: [
        if (dailyTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Daily Tasks'),
          ...dailyTasks.map((task) => _buildTaskCard(context, task)),
          SizedBox(height: ScreenUtil().setWidth(16)),
        ],
        if (specialTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Special Events'),
          ...specialTasks.map((task) => _buildTaskCard(context, task)),
          SizedBox(height: ScreenUtil().setWidth(16)),
        ],
        if (regularTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Tasks'),
          ...regularTasks.map((task) => _buildTaskCard(context, task)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(4),
        bottom: ScreenUtil().setWidth(12),
      ),
      child: Text(
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
    );
  }

  Widget _buildTaskCard(BuildContext context, LoyaltyTask task) {
    final isCompleted = task.status == TaskStatus.completed;
    final canComplete = task.canComplete;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: task.type == TaskType.special
            ? Border.all(color: Colors.amber.withAlpha(100), width: 1)
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
              color: _getTaskColor(task.type).withAlpha(30),
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
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(10),
                        vertical: ScreenUtil().setWidth(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(30),
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

                // 进度和过期时间
                if (task.maxCompletions != null || task.expiresAt != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  Row(
                    children: [
                      if (task.maxCompletions != null)
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
                      if (task.maxCompletions != null && task.expiresAt != null)
                        Text(' • '),
                      if (task.expiresAt != null)
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

                // 操作按钮
                if (!isCompleted) ...[
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canComplete
                          ? () => _handleTaskAction(context, task)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getTaskColor(task.type),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(10),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                        ),
                      ),
                      child: Text(
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
                        size: ScreenUtil().setWidth(24),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(6)),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
        return 'Go';
      case TaskType.referral:
        return 'Invite';
      default:
        return 'Complete';
    }
  }

  String _getExpiryText(DateTime expiresAt) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);

    if (diff.isNegative) {
      return 'Expired';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h left';
    } else {
      return '${diff.inDays}d left';
    }
  }

  bool _isExpiringSoon(DateTime expiresAt) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    return diff.inDays <= 1;
  }

  void _handleTaskAction(BuildContext context, LoyaltyTask task) async {
    if (task.actionUrl != null && task.actionUrl!.startsWith('http')) {
      // TODO: 打开外部链接
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening ${task.actionUrl}')),
      );
    } else if (task.actionUrl != null) {
      // 内部导航
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to ${task.actionUrl}')),
      );
    } else {
      // 直接完成任务
      final provider = this.provider;
      final success = await provider.completeTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Task completed! +${task.points} points' : 'Failed to complete task',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
