// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';

// ─── BottomBar ────────────────────────────────────────────────────────────────

/// 底部汇总信息栏与操作按钮
class BatchBottomBar extends StatelessWidget {
  final BatchTransferProvider provider;
  final String tokenSymbol;
  final String chainSymbol;
  final String Function(BigInt) formatGasFee;
  final VoidCallback onProceed;

  const BatchBottomBar({
    super.key,
    required this.provider,
    required this.tokenSymbol,
    required this.chainSymbol,
    required this.formatGasFee,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.items.isNotEmpty) ...[
              _summaryRow(
                context,
                label: '${S.of(context).g_key_batch_recipients}:',
                value: '${provider.recipientCount}',
              ),
              SizedBox(height: AppSpacing.space2),
              _summaryRow(
                context,
                label: '${S.of(context).g_key_batch_total_amount}:',
                value:
                    '${provider.formatAmount(provider.totalAmount)} $tokenSymbol',
              ),
              if (provider.gasEstimate != null) ...[
                SizedBox(height: AppSpacing.space2),
                _summaryRow(
                  context,
                  label: '${S.of(context).g_key_aa_estimated_gas}:',
                  value: formatGasFee(provider.gasEstimate!.totalFee),
                ),
              ],
              SizedBox(height: AppSpacing.space4),
            ],

            if (provider.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: AppColorTokens.of(context).danger.withAlpha(20),
                  borderRadius: AppRadius.brSm,
                ),
                child: Text(
                  provider.errorMessage!,
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).danger,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.space4),
            ],

            Row(
              children: [
                if (provider.items.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.clearItems,
                      child: Text(S.of(context).g_key_batch_clear_all),
                    ),
                  ),
                  SizedBox(width: AppSpacing.space4),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: provider.items.isEmpty ? null : onProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorTokens.of(context).brand,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.space4,
                      ),
                    ),
                    child: BatchButtonContent(provider: provider),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── ButtonContent ────────────────────────────────────────────────────────────

/// 底部主按钮内容（根据 provider 状态显示不同文字/指示器）
class BatchButtonContent extends StatelessWidget {
  final BatchTransferProvider provider;

  const BatchButtonContent({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return switch (provider.state) {
      BatchTransferState.estimatingGas => _loadingRow(
        s.g_key_batch_estimating_gas,
      ),
      BatchTransferState.signing => _loadingRow(s.g_key_batch_signing),
      BatchTransferState.broadcasting => _loadingRow(
        s.g_key_batch_broadcasting,
      ),
      BatchTransferState.success => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: ScreenUtil().setWidth(24)),
          SizedBox(width: AppSpacing.space2),
          Text(s.g_key_batch_done),
        ],
      ),
      _ => Text(s.g_key_batch_continue),
    };
  }

  Widget _loadingRow(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: ScreenUtil().setWidth(24),
          height: ScreenUtil().setWidth(24),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
        SizedBox(width: AppSpacing.space2),
        Text(label),
      ],
    );
  }
}
