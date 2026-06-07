// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_list_widgets.dart';

/// 转账确认对话框。返回 true 表示用户确认，false/null 表示取消。
class BatchConfirmDialog extends StatelessWidget {
  final BatchTransferProvider provider;
  final String tokenSymbol;
  final String Function(BigInt) formatGasFee;

  const BatchConfirmDialog({
    super.key,
    required this.provider,
    required this.tokenSymbol,
    required this.formatGasFee,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white70 : Colors.black87;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Text(
        S.of(context).g_key_batch_confirm_title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${S.of(context).g_key_batch_recipients}: ${provider.recipientCount}',
              style: TextStyle(color: contentColor),
            ),
            const SizedBox(height: 8),
            Text(
              '${S.of(context).g_key_batch_total_amount}: ${provider.formatAmount(provider.totalAmount)} $tokenSymbol',
              style: TextStyle(color: contentColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Gas: ${formatGasFee(provider.gasEstimate!.totalFee)}',
              style: TextStyle(color: contentColor),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.of(context).importantNotice,
                      style: TextStyle(fontSize: 12, color: contentColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            S.of(context).g_key_79,
            style: TextStyle(color: AppColorTokens.of(context).textSubtitle),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorTokens.of(context).brand,
          ),
          child: Text(
            S.of(context).g_key_78,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// 转账成功后的底部结果面板
class BatchResultSheet extends StatelessWidget {
  final BatchTransferProvider provider;
  final String tokenSymbol;
  final Future<void> Function(BuildContext) onExport;

  const BatchResultSheet({
    super.key,
    required this.provider,
    required this.tokenSymbol,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final mainText = AppColorTokens.of(context).textPrimary;
    final subText = AppColorTokens.of(context).textSubtitle;
    final blue = AppColorTokens.of(context).brand;
    final txHash = provider.txHash ?? '';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScreenUtil().setWidth(60),
              height: ScreenUtil().setWidth(5),
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
              decoration: BoxDecoration(
                color: subText.withValues(alpha: 0.3),
                borderRadius: AppRadius.brSm,
              ),
            ),
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: ScreenUtil().setWidth(72),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              S.of(context).g_key_140,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(36),
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
              decoration: BoxDecoration(
                color: AppColorTokens.of(context).bgBase,
                borderRadius: AppRadius.brMd,
              ),
              child: Column(
                children: [
                  _ResultRow(
                    label: S.of(context).g_key_batch_recipients,
                    value: '${provider.recipientCount}',
                    labelColor: subText,
                    valueColor: mainText,
                  ),
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  _ResultRow(
                    label: S.of(context).g_key_batch_total_amount,
                    value:
                        '${provider.formatAmount(provider.totalAmount)} $tokenSymbol',
                    labelColor: subText,
                    valueColor: mainText,
                  ),
                  if (txHash.isNotEmpty) ...[
                    SizedBox(height: ScreenUtil().setWidth(8)),
                    _ResultRow(
                      label: 'TxHash',
                      value: shortenAddress(txHash),
                      labelColor: subText,
                      valueColor: mainText,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.copy_outlined,
                          size: ScreenUtil().setWidth(32),
                          color: blue,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: txHash));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).g_key_119),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onExport(context),
                icon: Icon(
                  Icons.file_download_outlined,
                  size: ScreenUtil().setWidth(36),
                ),
                label: Text(S.of(context).g_key_batch_export_csv),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(20),
                  ),
                  textStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(16),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                ),
                child: Text(S.of(context).g_key_batch_done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 帮助说明对话框
class BatchHelpDialog extends StatelessWidget {
  const BatchHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Text(
        S.of(context).g_key_batch_help_title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_key_batch_send_multiple,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).g_key_batch_csv_format,
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.grey).withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'address,amount,memo\n0x123...,1.5,Note 1\n0xabc...,2.0,Note 2',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tips',
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              '• ${S.of(context).g_key_batch_swipe_remove}',
              style: TextStyle(color: textColor),
            ),
            Text(
              '• ${S.of(context).g_key_batch_memo_optional}',
              style: TextStyle(color: textColor),
            ),
            Text(
              '• ${S.of(context).g_key_batch_multicall_tip}',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            S.of(context).g_key_burn_got_it,
            style: TextStyle(color: AppColorTokens.of(context).brand),
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final Widget? trailing;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:',
          style: AppTypography.caption.copyWith(color: labelColor)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}
