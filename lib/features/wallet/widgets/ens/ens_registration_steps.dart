// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// ENS 注册步骤指示器
///
/// 显示两步注册流程的进度:
/// 1. 提交承诺 (Commit)
/// 2. 等待确认
/// 3. 执行注册 (Register)
class EnsRegistrationSteps extends StatelessWidget {
  /// 当前步骤: 0=初始, 1=提交中, 2=等待中, 3=注册中, 4=完成, -1=失败
  final int currentStep;

  const EnsRegistrationSteps({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          // 步骤连接线
          Row(
            children: [
              _buildStepCircle(context, 1, S.of(context).g_key_ens_step_1),
              _buildConnector(context, currentStep >= 2),
              _buildStepCircle(context, 2, S.of(context).g_key_ens_step_2),
              _buildConnector(context, currentStep >= 4),
              _buildStepCircle(context, 3, S.of(context).g_key_ens_step_3),
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          // 步骤标签
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).g_key_ens_commit,
                  style: AppTypography.caption.copyWith(
                    color: _getStepColor(context, 1),
                    fontWeight: currentStep == 1
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  S.of(context).g_key_ens_wait,
                  style: AppTypography.caption.copyWith(
                    color: _getStepColor(context, 2),
                    fontWeight: currentStep == 2
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  S.of(context).g_key_ens_register,
                  style: AppTypography.caption.copyWith(
                    color: _getStepColor(context, 3),
                    fontWeight: currentStep == 3
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(BuildContext context, int step, String number) {
    final isActive = _isStepActive(step);
    final isCompleted = _isStepCompleted(step);
    final isFailed = currentStep == -1;

    Color bgColor;
    Color fgColor;
    IconData? icon;

    if (isFailed && step == _getFailedStep()) {
      bgColor = AppColorTokens.of(context).danger;
      fgColor = Colors.white;
      icon = Icons.close;
    } else if (isCompleted) {
      bgColor = AppColorTokens.of(context).success;
      fgColor = Colors.white;
      icon = Icons.check;
    } else if (isActive) {
      bgColor = AppColorTokens.of(context).brand;
      fgColor = Colors.white;
    } else {
      bgColor = AppColorTokens.of(context).textSubtitle.withAlpha(30);
      fgColor = AppColorTokens.of(context).textSubtitle;
    }

    return Expanded(
      child: Center(
        child: Container(
          width: ScreenUtil().setWidth(44),
          height: ScreenUtil().setWidth(44),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: bgColor.withAlpha(80),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, size: ScreenUtil().setWidth(24), color: fgColor)
                : Text(
                    number,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnector(BuildContext context, bool isActive) {
    return Expanded(
      child: Container(
        height: ScreenUtil().setWidth(4),
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
        decoration: BoxDecoration(
          color: isActive
              ? AppColorTokens.of(context).success
              : AppColorTokens.of(context).textSubtitle.withAlpha(30),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(2)),
        ),
      ),
    );
  }

  bool _isStepActive(int step) {
    if (currentStep == -1) return false;
    switch (step) {
      case 1:
        return currentStep == 1;
      case 2:
        return currentStep == 2;
      case 3:
        return currentStep == 3;
      default:
        return false;
    }
  }

  bool _isStepCompleted(int step) {
    if (currentStep == -1) return false;
    switch (step) {
      case 1:
        return currentStep >= 2;
      case 2:
        return currentStep >= 3;
      case 3:
        return currentStep >= 4;
      default:
        return false;
    }
  }

  int _getFailedStep() {
    // 根据实际失败点返回
    // 简化处理：假设在当前步骤失败
    return 1; // 默认在第一步失败
  }

  Color _getStepColor(BuildContext context, int step) {
    if (_isStepCompleted(step)) {
      return AppColorTokens.of(context).success;
    }
    if (_isStepActive(step)) {
      return AppColorTokens.of(context).brand;
    }
    if (currentStep == -1 && step == _getFailedStep()) {
      return AppColorTokens.of(context).danger;
    }
    return AppColorTokens.of(context).textSubtitle;
  }
}
