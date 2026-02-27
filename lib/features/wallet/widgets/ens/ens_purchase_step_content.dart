// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';

/// ENS 购买页各注册步骤的内容区域
///
/// currentStep: 0=初始, 1=提交承诺中, 2=等待中, 3=注册中, 4=完成, -1=失败
class EnsPurchaseStepContent extends StatelessWidget {
  final int currentStep;
  final int remainingSeconds;
  final CommitResult? commitResult;
  final RegisterResult? registerResult;
  final String? errorMessage;
  final String domainName;

  const EnsPurchaseStepContent({
    super.key,
    required this.currentStep,
    required this.remainingSeconds,
    required this.commitResult,
    required this.registerResult,
    required this.errorMessage,
    required this.domainName,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentStep) {
      case 0:
        return _buildInitialContent(context);
      case 1:
        return _buildCommittingContent(context);
      case 2:
        return _buildWaitingContent(context);
      case 3:
        return _buildRegisteringContent(context);
      case 4:
        return _buildSuccessContent(context);
      case -1:
        return _buildErrorContent(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInitialContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_ens_registration_info,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildInfoRow(context, Icons.security, S.of(context).g_key_ens_two_step_process),
          _buildInfoRow(context, Icons.timer, S.of(context).g_key_ens_wait_time_info),
          _buildInfoRow(
            context,
            Icons.warning_amber_rounded,
            S.of(context).g_key_ens_keep_app_open,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: ScreenUtil().setWidth(24),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommittingContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_ens_committing,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_ens_please_wait,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
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

  Widget _buildWaitingContent(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final minWaitTime = commitResult?.minWaitTime ?? 0;
    final progress = minWaitTime > 0
        ? (1 - (remainingSeconds / minWaitTime)).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          // 倒计时圆环
          SizedBox(
            width: ScreenUtil().setWidth(120),
            height: ScreenUtil().setWidth(120),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ).withAlpha(30),
                  valueColor: AlwaysStoppedAnimation(
                    AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          Text(
            S.of(context).g_key_ens_waiting,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_ens_wait_explanation,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteringContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_ens_registering,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_ens_finalizing,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
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

  Widget _buildSuccessContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(color: Colors.green.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: ScreenUtil().setWidth(80), color: Colors.green),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_ens_success,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            '$domainName.eth ${S.of(context).g_key_ens_is_yours}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          if (registerResult?.txHash != null) ...[
            SizedBox(height: ScreenUtil().setWidth(16)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                'Tx: ${_shortenHash(registerResult!.txHash!)}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontFamily: 'monospace',
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(color: Colors.red.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(Icons.error, size: ScreenUtil().setWidth(64), color: Colors.red),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_ens_failed,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            errorMessage ?? S.of(context).g_key_error_3,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _shortenHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 6)}';
  }
}

/// ENS 购买页操作按钮
class EnsPurchaseActionButton extends StatelessWidget {
  final int currentStep;
  final VoidCallback onStart;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const EnsPurchaseActionButton({
    super.key,
    required this.currentStep,
    required this.onStart,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentStep) {
      case 0:
        return _buildPrimaryButton(
          context,
          label: S.of(context).g_key_ens_start_registration,
          onPressed: onStart,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        );

      case 1:
      case 2:
      case 3:
        return _buildPrimaryButton(
          context,
          label: S.of(context).g_key_ens_processing,
          onPressed: null,
          color: Colors.grey,
        );

      case 4:
        return _buildPrimaryButton(
          context,
          label: S.of(context).g_swap_key_18,
          onPressed: onDone,
          color: Colors.green,
        );

      case -1:
        return _buildPrimaryButton(
          context,
          label: S.of(context).g_swap_key_6,
          onPressed: onRetry,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(30),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
