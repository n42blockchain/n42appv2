// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

// ─── InfoCard ────────────────────────────────────────────────────────────────

/// 顶部 Token/链 信息卡片
class BatchInfoCard extends StatelessWidget {
  final String tokenSymbol;
  final String chainSymbol;
  final bool supportsMulticall;

  const BatchInfoCard({
    super.key,
    required this.tokenSymbol,
    required this.chainSymbol,
    required this.supportsMulticall,
  });

  @override
  Widget build(BuildContext context) {
    final success = AppColorTokens.of(context).success;
    return Container(
      margin: EdgeInsets.all(AppSpacing.space4),
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Token: $tokenSymbol',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  '${S.of(context).g_key_batch_evm_only.split(' ').take(3).join(' ')} · $chainSymbol',
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              ],
            ),
          ),
          if (supportsMulticall)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space2,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: success.withAlpha(30),
                borderRadius: AppRadius.brSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flash_on,
                    color: success,
                    size: ScreenUtil().setWidth(20),
                  ),
                  SizedBox(width: AppSpacing.space2),
                  Text(
                    'Multicall',
                    style: AppTypography.captionSm.copyWith(
                      color: success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── AddItemForm ─────────────────────────────────────────────────────────────

/// 添加转账记录的表单区域
class BatchAddItemForm extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController amountController;
  final TextEditingController memoController;
  final String tokenSymbol;
  final VoidCallback onPasteAddress;
  final VoidCallback onAdd;

  const BatchAddItemForm({
    super.key,
    required this.addressController,
    required this.amountController,
    required this.memoController,
    required this.tokenSymbol,
    required this.onPasteAddress,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_batch_add_recipient,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.space4),

          TextField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: '0x...',
              labelText: 'Address',
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                onPressed: onPasteAddress,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.space4),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    labelText: 'Amount',
                    suffixText: tokenSymbol,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.space4),
              Expanded(
                child: TextField(
                  controller: memoController,
                  decoration: const InputDecoration(
                    hintText: 'Optional',
                    labelText: 'Memo',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space4),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(S.of(context).g_key_159),
            ),
          ),
        ],
      ),
    );
  }
}
