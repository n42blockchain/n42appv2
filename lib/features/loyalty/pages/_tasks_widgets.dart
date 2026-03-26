// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'tasks_page.dart';

/// 任务页面 Widget 构建方法
mixin TasksWidgetsMixin on State<TasksPage>, TasksLogicMixin {
  /// Shorthand for theme color lookup to reduce repetitive boilerplate.
  Color _themeColor(BuildContext context, String key) =>
      AppThemeUtils.getColorByKey(context, key);

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
    final color = _themeColor(context, AppThemeKeys.mainBlueColor.name);
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
                : _themeColor(context, AppThemeKeys.mainTextColor.name),
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
            color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            _filter == _TaskFilter.completed
                ? 'No completed tasks yet'
                : 'No tasks available',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name),
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
              color: _themeColor(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(8),
              vertical: ScreenUtil().setWidth(2),
            ),
            decoration: BoxDecoration(
              color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name),
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
        color: _themeColor(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: _getTaskCardBorder(task.type, isCompleted),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任务图标
          _buildTaskIcon(task, taskColor),
          SizedBox(width: ScreenUtil().setWidth(12)),

          // 任务信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskTitleRow(context, task, isCompleted),
                SizedBox(height: ScreenUtil().setWidth(4)),
                _buildTaskDescription(context, task),
                if (hasProgress)
                  _buildProgressSection(context, task, taskColor, progressValue),
                if (!hasProgress &&
                    task.maxCompletions != null &&
                    task.expiresAt != null)
                  _buildCompletionCount(context, task),
                if (task.expiresAt != null)
                  _buildExpiryRow(context, task.expiresAt!),
                if (!isCompleted)
                  _buildActionButton(context, task, canComplete, isChecking, taskColor),
                if (isCompleted)
                  _buildCompletedMark(context, task),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Border? _getTaskCardBorder(TaskType type, bool isCompleted) {
    if (type == TaskType.special) {
      return Border.all(
        color: Colors.amber.withValues(alpha: 0.6),
        width: 1,
      );
    }
    if (isCompleted) {
      return Border.all(
        color: Colors.green.withValues(alpha: 0.3),
        width: 1,
      );
    }
    return null;
  }

  Widget _buildTaskIcon(LoyaltyTask task, Color taskColor) {
    return Container(
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
    );
  }

  Widget _buildTaskTitleRow(BuildContext context, LoyaltyTask task, bool isCompleted) {
    return Row(
      children: [
        Expanded(
          child: Text(
            task.title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: _themeColor(context, AppThemeKeys.mainTextColor.name),
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
    );
  }

  Widget _buildTaskDescription(BuildContext context, LoyaltyTask task) {
    return Text(
      task.description,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(24),
        color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    LoyaltyTask task,
    Color taskColor,
    double progressValue,
  ) {
    return Column(
      children: [
        SizedBox(height: ScreenUtil().setWidth(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${task.completedCount}/${task.maxCompletions} completed',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name),
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
            backgroundColor: taskColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(taskColor),
            minHeight: ScreenUtil().setWidth(6),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCount(BuildContext context, LoyaltyTask task) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(6)),
      child: Text(
        '${task.completedCount}/${task.maxCompletions}',
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
      ),
    );
  }

  Widget _buildExpiryRow(BuildContext context, DateTime expiresAt) {
    final expiring = _isExpiringSoon(expiresAt);
    final color = expiring
        ? Colors.orange
        : _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name);

    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(4)),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: ScreenUtil().setWidth(18),
            color: color,
          ),
          SizedBox(width: ScreenUtil().setWidth(4)),
          Text(
            _getExpiryText(expiresAt),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    LoyaltyTask task,
    bool canComplete,
    bool isChecking,
    Color taskColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (canComplete && !isChecking)
              ? () => _handleTaskAction(context, task)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: taskColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: taskColor.withValues(alpha: 0.3),
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
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _getButtonText(task),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCompletedMark(BuildContext context, LoyaltyTask task) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
      child: Row(
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
                color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
