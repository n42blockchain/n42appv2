// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/home/setting/change_email_page_logic.dart';
import 'package:n42_wallet/features/home/setting/change_email_page_widgets.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// 修改邮箱页面
///
/// 流程：
/// - 未登录 Chat（或 Chat 未初始化）：2 步
///     Step 0 – 输入新邮箱
///     Step 1 – 输入 N42 验证码 → 确认修改
///
/// - 已登录 Chat（可选同步）：3 步
///     Step 0 – 输入新邮箱 + 密码（开启同步时）
///     Step 1 – 输入 N42 验证码 → 确认 N42 修改
///     Step 2 – 自动请求 Chat 验证码 → 输入 Chat 验证码 → 确认
///              失败时：显示错误 + [重试] / [跳过]
///
/// 返回 `true` 表示 N42 邮箱已成功修改（无论 Chat 同步状态）。
class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage>
    with ChangeEmailPageLogicMixin, ChangeEmailPageWidgetsMixin {
  @override
  void initState() {
    super.initState();
    initLogic();
  }

  @override
  void dispose() {
    disposeLogic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final accentColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final fillColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name);
    final lineColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name);

    final totalSteps = (chatSyncEnabled && chatAvailable) ? 3 : 2;

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_email_change_title),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepIndicator(
              currentStep: step,
              totalSteps: totalSteps,
              accentColor: accentColor,
              lineColor: lineColor,
              textColor: textColor,
            ),
            SizedBox(height: 36.h),
            if (step == 0)
              buildStep0(
                  textColor, subColor, accentColor, fillColor, lineColor),
            if (step == 1)
              buildStep1(textColor, subColor, accentColor, fillColor),
            if (step == 2)
              buildStep2(
                  textColor, subColor, accentColor, fillColor, lineColor),
          ],
        ),
      ),
    );
  }
}

// ─── Step Indicator (supports 2 or 3 steps) ──────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final Color lineColor;
  final Color textColor;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.lineColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < totalSteps; i++) ...[
          _StepDot(
            label: '${i + 1}',
            done: currentStep > i,
            active: currentStep == i,
            accentColor: accentColor,
            textColor: textColor,
          ),
          if (i < totalSteps - 1)
            Expanded(
              child: Container(
                  height: 1.5,
                  color: currentStep > i ? accentColor : lineColor),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final Color accentColor;
  final Color textColor;

  const _StepDot({
    required this.label,
    required this.done,
    required this.active,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = done || active;
    final color = highlighted ? accentColor : textColor.withAlpha(80);
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? accentColor.withAlpha(26) : Colors.transparent,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: done
            ? Icon(Icons.check, size: 14.sp, color: accentColor)
            : Text(label,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: color)),
      ),
    );
  }
}
