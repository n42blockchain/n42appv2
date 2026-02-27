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

part '_tasks_logic.dart';
part '_tasks_widgets.dart';

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

class _TasksPageState extends State<TasksPage>
    with TasksLogicMixin, TasksWidgetsMixin {
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
}
