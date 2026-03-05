// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'tasks_page.dart';

/// 任务页面业务逻辑：过滤、颜色、文本、事件处理
mixin TasksLogicMixin on State<TasksPage> {
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

  Color _getTaskColor(TaskType type) => switch (type) {
        TaskType.dailyCheckIn => Colors.amber,
        TaskType.transaction => Colors.blue,
        TaskType.referral => Colors.green,
        TaskType.staking => Colors.purple,
        TaskType.dappUsage => Colors.orange,
        TaskType.social => Colors.pink,
        TaskType.special => Colors.red,
      };

  String _getButtonText(LoyaltyTask task) => switch (task.type) {
        TaskType.dailyCheckIn => 'Check In',
        TaskType.social => task.actionUrl != null ? 'Go →' : 'Follow',
        TaskType.referral => 'Invite Friends',
        TaskType.dappUsage => task.actionUrl != null ? 'Open →' : 'Complete',
        TaskType.staking => task.actionUrl != null ? 'Go Stake →' : 'Complete',
        _ => 'Complete',
      };

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
