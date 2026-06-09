// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/gas_sponsorship_badge.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// AA 批量交易页面的主体 UI
///
/// 纯展示组件，所有状态和回调由 [AABatchTransactionPage] 提供。
/// 将 Widget 构建逻辑与业务逻辑分离，使主文件更易维护。
class AABatchTransactionBody extends StatelessWidget {
  final List<BatchOperation> operations;
  final PaymasterOption selectedPaymaster;
  final bool isEstimating;
  final bool isSending;
  final BigInt? estimatedTotalGas;
  final String? estimateError;
  final String Function() formatGasCost;

  // callbacks
  final VoidCallback onShowTemplates;
  final VoidCallback onAddOperation;
  final VoidCallback onSaveTemplate;
  final VoidCallback onShowPaymaster;
  final VoidCallback onSendBatch;
  final void Function(int index) onRemoveOperation;
  final VoidCallback onClearAll;

  const AABatchTransactionBody({
    super.key,
    required this.operations,
    required this.selectedPaymaster,
    required this.isEstimating,
    required this.isSending,
    required this.estimatedTotalGas,
    required this.estimateError,
    required this.formatGasCost,
    required this.onShowTemplates,
    required this.onAddOperation,
    required this.onSaveTemplate,
    required this.onShowPaymaster,
    required this.onSendBatch,
    required this.onRemoveOperation,
    required this.onClearAll,
  });

  /// 主题色快捷访问
  Color _themeColor(BuildContext context, AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_batch_transaction,
        actions: [
          IconButton(
            onPressed: onShowTemplates,
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: S.of(context).g_key_aa_batch_templates,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(context),
                  SizedBox(height: AppSpacing.space6),
                  _buildOperationsList(context),
                  SizedBox(height: AppSpacing.space4),
                  _buildAddButton(context),
                  if (operations.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.space4),
                    _buildSaveTemplateButton(context),
                    SizedBox(height: AppSpacing.space6),
                    _buildPaymasterSection(context),
                    SizedBox(height: AppSpacing.space6),
                    _buildGasSection(context),
                    if (estimateError != null) ...[
                      SizedBox(height: AppSpacing.space2),
                      _buildEstimateErrorRow(context),
                    ],
                  ],
                  SizedBox(height: AppSpacing.space6),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withAlpha(20),
            const Color(0xFFFF9800).withAlpha(5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.layers,
                size: ScreenUtil().setWidth(28),
                color: const Color(0xFFFF9800),
              ),
              SizedBox(width: AppSpacing.space4),
              Flexible(
                child: Text(
                  S.of(context).g_key_aa_batch_transaction,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _themeColor(context, AppThemeKeys.mainTextColor),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_key_aa_batch_description,
            style: AppTypography.caption.copyWith(
              color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          _buildFeatureRow(
            context,
            Icons.savings,
            S.of(context).g_key_aa_batch_save_gas,
          ),
          _buildFeatureRow(
            context,
            Icons.bolt,
            S.of(context).g_key_aa_batch_atomic,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
      child: Row(
        children: [
          Icon(
            icon,
            size: ScreenUtil().setWidth(18),
            color: const Color(0xFFFF9800),
          ),
          SizedBox(width: AppSpacing.space2),
          Flexible(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsList(BuildContext context) {
    if (operations.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.space8),
        decoration: BoxDecoration(
          color: _themeColor(context, AppThemeKeys.itemBgColor),
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: _themeColor(
              context,
              AppThemeKeys.itemSubtitleTextColor,
            ).withAlpha(30),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: ScreenUtil().setWidth(56),
              color: _themeColor(
                context,
                AppThemeKeys.itemSubtitleTextColor,
              ).withAlpha(100),
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              S.of(context).g_key_aa_no_operations,
              style: AppTypography.bodySm.copyWith(
                color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
              ),
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              S.of(context).g_key_aa_add_first_operation,
              style: AppTypography.caption.copyWith(
                color: _themeColor(
                  context,
                  AppThemeKeys.itemSubtitleTextColor,
                ).withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '${S.of(context).g_key_aa_operations} (${operations.length})',
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _themeColor(context, AppThemeKeys.mainTextColor),
                ),
              ),
            ),
            TextButton(
              onPressed: onClearAll,
              child: Text(
                S.of(context).g_key_batch_clear_all,
                style: TextStyle(color: AppColorTokens.of(context).danger),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.space4),
        for (int i = 0; i < operations.length; i++)
          BatchOperationItem(
            operation: operations[i],
            index: i,
            onRemove: () => onRemoveOperation(i),
          ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onAddOperation,
      icon: const Icon(Icons.add),
      label: Text(S.of(context).g_key_aa_add_operation),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
    );
  }

  Widget _buildSaveTemplateButton(BuildContext context) {
    return TextButton.icon(
      onPressed: onSaveTemplate,
      icon: Icon(Icons.bookmark_add_outlined, size: ScreenUtil().setWidth(20)),
      label: Text(S.of(context).g_key_aa_batch_save_template),
      style: TextButton.styleFrom(
        foregroundColor: _themeColor(context, AppThemeKeys.mainBlueColor),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildPaymasterSection(BuildContext context) {
    return GestureDetector(
      onTap: onShowPaymaster,
      child: PaymasterOptionCard(option: selectedPaymaster, isSelected: true),
    );
  }

  Widget _buildGasSection(BuildContext context) {
    final isSponsored = selectedPaymaster.type == PaymasterType.sponsored;

    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: isSponsored
            ? AppColorTokens.of(context).success.withAlpha(15)
            : _themeColor(context, AppThemeKeys.itemBgColor),
        borderRadius: AppRadius.brMd,
        border: isSponsored
            ? Border.all(color: AppColorTokens.of(context).success.withAlpha(30))
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_aa_total_gas,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: _themeColor(
                      context,
                      AppThemeKeys.itemSubtitleTextColor,
                    ),
                  ),
                ),
              ),
              _buildGasValue(context, isSponsored),
            ],
          ),
          if (isSponsored && estimatedTotalGas != null) ...[
            SizedBox(height: AppSpacing.space2),
            GasSponsorshipBadge(
              isSponsored: true,
              savedAmount: formatGasCost(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGasValue(BuildContext context, bool isSponsored) {
    if (isEstimating) {
      final size = ScreenUtil().setWidth(20);
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (estimatedTotalGas != null) {
      return Text(
        isSponsored ? S.of(context).g_key_aa_free : formatGasCost(),
        style: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: isSponsored
              ? AppColorTokens.of(context).success
              : _themeColor(context, AppThemeKeys.mainTextColor),
        ),
      );
    }
    return Text(
      '-',
      style: AppTypography.bodySm.copyWith(
        color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
      ),
    );
  }

  Widget _buildEstimateErrorRow(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: AppColorTokens.of(context).warning,
          size: 16,
        ),
        SizedBox(width: AppSpacing.space2),
        Expanded(
          child: Text(
            estimateError!,
            style: AppTypography.captionSm.copyWith(
              color: AppColorTokens.of(context).warning,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final canSend = operations.isNotEmpty && !isEstimating && !isSending;

    return Container(
      padding: EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: _themeColor(context, AppThemeKeys.itemBgColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canSend ? onSendBatch : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
            disabledBackgroundColor: AppColorTokens.of(context).textTertiary,
          ),
          child: isSending
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setWidth(20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(width: AppSpacing.space2),
                    Flexible(
                      child: Text(
                        S.of(context).g_key_aa_batch_submitting,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  '${S.of(context).g_key_aa_execute_batch} (${operations.length})',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
