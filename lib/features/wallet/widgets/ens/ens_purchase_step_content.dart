// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
  Widget build(BuildContext context) => switch (currentStep) {
    0 => _buildInitialContent(context),
    1 => _buildProgressContent(
      context,
      title: S.of(context).g_key_ens_committing,
      subtitle: S.of(context).g_key_ens_please_wait,
    ),
    2 => _buildWaitingContent(context),
    3 => _buildProgressContent(
      context,
      title: S.of(context).g_key_ens_registering,
      subtitle: S.of(context).g_key_ens_finalizing,
    ),
    4 => _buildSuccessContent(context),
    -1 => _buildErrorContent(context),
    _ => const SizedBox.shrink(),
  };

  // ── Theme helpers ──────────────────────────────────────────────────────
  Color _mainText(BuildContext context) =>
      AppColorTokens.of(context).textPrimary;
  Color _subtitle(BuildContext context) =>
      AppColorTokens.of(context).textSubtitle;
  Color _blue(BuildContext context) => AppColorTokens.of(context).brand;

  /// Shared container decoration used by most step content builders.
  BoxDecoration _stepDecoration(
    BuildContext context, {
    Color? color,
    Color? borderColor,
  }) => BoxDecoration(
    color: color ?? AppColorTokens.of(context).bgSurface,
    borderRadius: AppRadius.brMd,
    border: borderColor != null ? Border.all(color: borderColor) : null,
  );

  // ── Step 0: Initial ────────────────────────────────────────────────────
  Widget _buildInitialContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: _stepDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_ens_registration_info,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: _mainText(context),
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          _buildInfoRow(
            context,
            Icons.security,
            S.of(context).g_key_ens_two_step_process,
          ),
          _buildInfoRow(
            context,
            Icons.timer,
            S.of(context).g_key_ens_wait_time_info,
          ),
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
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: ScreenUtil().setWidth(24), color: _blue(context)),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: _subtitle(context)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Steps 1 & 3: Progress (spinner + title + subtitle) ────────────────
  Widget _buildProgressContent(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: _stepDecoration(context),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppSpacing.space4),
          Text(
            title,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: _mainText(context),
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(color: _subtitle(context)),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Waiting (countdown ring) ───────────────────────────────────
  Widget _buildWaitingContent(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final minWaitTime = commitResult?.minWaitTime ?? 0;
    final progress = minWaitTime > 0
        ? (1 - (remainingSeconds / minWaitTime)).clamp(0.0, 1.0)
        : 1.0;
    final blue = _blue(context);
    final textColor = _mainText(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: _stepDecoration(context),
      child: Column(
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(120),
            height: ScreenUtil().setWidth(120),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: blue.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation(blue),
                ),
                Center(
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: AppTypography.headline.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.space6),
          Text(
            S.of(context).g_key_ens_waiting,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            S.of(context).g_key_ens_wait_explanation,
            style: AppTypography.caption.copyWith(color: _subtitle(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Step 4: Success ────────────────────────────────────────────────────
  Widget _buildSuccessContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: _stepDecoration(
        context,
        color: AppColorTokens.of(context).success.withAlpha(20),
        borderColor: AppColorTokens.of(context).success.withAlpha(50),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: ScreenUtil().setWidth(80),
            color: AppColorTokens.of(context).success,
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_key_ens_success,
            style: AppTypography.headline.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).success,
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            '$domainName.eth ${S.of(context).g_key_ens_is_yours}',
            style: AppTypography.bodySm.copyWith(color: _mainText(context)),
          ),
          if (registerResult?.txHash != null) ...[
            SizedBox(height: AppSpacing.space4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: AppColorTokens.of(context).success.withAlpha(20),
                borderRadius: AppRadius.brSm,
              ),
              child: Text(
                'Tx: ${_shortenHash(registerResult!.txHash!)}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontFamily: 'monospace',
                  color: _subtitle(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Step -1: Error ─────────────────────────────────────────────────────
  Widget _buildErrorContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: _stepDecoration(
        context,
        color: AppColorTokens.of(context).danger.withAlpha(20),
        borderColor: AppColorTokens.of(context).danger.withAlpha(50),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error,
            size: ScreenUtil().setWidth(64),
            color: AppColorTokens.of(context).danger,
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_key_ens_failed,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).danger,
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            errorMessage ?? S.of(context).g_key_error_3,
            style: AppTypography.caption.copyWith(color: _subtitle(context)),
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
          color: AppColorTokens.of(context).brand,
        );

      case 1:
      case 2:
      case 3:
        return _buildPrimaryButton(
          context,
          label: S.of(context).g_key_ens_processing,
          onPressed: null,
          color: AppColorTokens.of(context).textTertiary,
        );

      case 4:
        return _buildPrimaryButton(
          context,
          label: S.of(context).g_swap_key_18,
          onPressed: onDone,
          color: AppColorTokens.of(context).success,
        );

      case -1:
        return _buildPrimaryButton(
          context,
          label: S.of(context).g_swap_key_6,
          onPressed: onRetry,
          color: AppColorTokens.of(context).brand,
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
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
      child: Text(
        label,
        style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
