// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
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
              padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(context),
                  SizedBox(height: ScreenUtil().setWidth(24)),
                  _buildOperationsList(context),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  _buildAddButton(context),
                  if (operations.isNotEmpty) ...[
                    SizedBox(height: ScreenUtil().setWidth(16)),
                    _buildSaveTemplateButton(context),
                    SizedBox(height: ScreenUtil().setWidth(24)),
                    _buildPaymasterSection(context),
                    SizedBox(height: ScreenUtil().setWidth(24)),
                    _buildGasSection(context),
                    if (estimateError != null) ...[
                      SizedBox(height: ScreenUtil().setWidth(8)),
                      _buildEstimateErrorRow(context),
                    ],
                  ],
                  SizedBox(height: ScreenUtil().setWidth(24)),
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
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withAlpha(20),
            const Color(0xFFFF9800).withAlpha(5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.layers, size: ScreenUtil().setWidth(28), color: const Color(0xFFFF9800)),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Text(
                S.of(context).g_key_aa_batch_transaction,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            S.of(context).g_key_aa_batch_description,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildFeatureRow(context, Icons.savings, S.of(context).g_key_aa_batch_save_gas),
          _buildFeatureRow(context, Icons.bolt, S.of(context).g_key_aa_batch_atomic),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
      child: Row(
        children: [
          Icon(icon, size: ScreenUtil().setWidth(18), color: const Color(0xFFFF9800)),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Text(
            text,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
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

  Widget _buildOperationsList(BuildContext context) {
    if (operations.isEmpty) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ).withAlpha(30),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: ScreenUtil().setWidth(56),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ).withAlpha(100),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              S.of(context).g_key_aa_no_operations,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(4)),
            Text(
              S.of(context).g_key_aa_add_first_operation,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
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
            Text(
              '${S.of(context).g_key_aa_operations} (${operations.length})',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            TextButton(
              onPressed: onClearAll,
              child: Text(
                S.of(context).g_key_aa_clear_all,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
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
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
      ),
    );
  }

  Widget _buildSaveTemplateButton(BuildContext context) {
    return TextButton.icon(
      onPressed: onSaveTemplate,
      icon: Icon(Icons.bookmark_add_outlined, size: ScreenUtil().setWidth(20)),
      label: Text(S.of(context).g_key_aa_batch_save_template),
      style: TextButton.styleFrom(
        foregroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildPaymasterSection(BuildContext context) {
    return GestureDetector(
      onTap: onShowPaymaster,
      child: PaymasterOptionCard(
        option: selectedPaymaster,
        isSelected: true,
      ),
    );
  }

  Widget _buildGasSection(BuildContext context) {
    final isSponsored = selectedPaymaster.type == PaymasterType.sponsored;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: isSponsored
            ? Colors.green.withAlpha(15)
            : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: isSponsored ? Border.all(color: Colors.green.withAlpha(30)) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_aa_total_gas,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              if (isEstimating)
                SizedBox(
                  width: ScreenUtil().setWidth(20),
                  height: ScreenUtil().setWidth(20),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else if (estimatedTotalGas != null)
                Text(
                  isSponsored ? S.of(context).g_key_aa_free : formatGasCost(),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: isSponsored
                        ? Colors.green
                        : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                )
              else
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
            ],
          ),
          if (isSponsored && estimatedTotalGas != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            GasSponsorshipBadge(isSponsored: true, savedAmount: formatGasCost()),
          ],
        ],
      ),
    );
  }

  Widget _buildEstimateErrorRow(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
        SizedBox(width: ScreenUtil().setWidth(6)),
        Expanded(
          child: Text(
            estimateError!,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: Colors.orange,
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
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
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
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            disabledBackgroundColor: Colors.grey,
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
                    SizedBox(width: ScreenUtil().setWidth(10)),
                    Text(
                      S.of(context).g_key_aa_batch_submitting,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
                  '${S.of(context).g_key_aa_execute_batch} (${operations.length})',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
