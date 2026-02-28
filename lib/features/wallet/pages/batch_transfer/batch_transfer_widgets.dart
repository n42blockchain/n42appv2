// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

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
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Token: $tokenSymbol',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  '${S.of(context).g_key_batch_evm_only.split(' ').take(3).join(' ')} · $chainSymbol',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
          ),
          if (supportsMulticall)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(10),
                vertical: ScreenUtil().setWidth(4),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flash_on, color: Colors.green, size: ScreenUtil().setWidth(20)),
                  SizedBox(width: ScreenUtil().setWidth(4)),
                  Text(
                    'Multicall',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: Colors.green,
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
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_batch_add_recipient,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),

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
          SizedBox(height: ScreenUtil().setWidth(12)),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    labelText: 'Amount',
                    suffixText: tokenSymbol,
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
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
          SizedBox(height: ScreenUtil().setWidth(12)),

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
