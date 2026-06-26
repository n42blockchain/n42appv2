// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';

/// Paymaster 选择底部弹层
///
/// 展示可选的 Paymaster 方案（自付 / 赞助），选中后回调给主页面。
class PaymasterSelectionSheet extends StatelessWidget {
  final PaymasterOption selected;
  final ValueChanged<PaymasterOption> onSelect;

  const PaymasterSelectionSheet({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final options = [PaymasterOption.none, PaymasterOption.sponsored];

    return Container(
      padding: EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Paymaster',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.space4),
            ...options.map((option) {
              final isSelected = option.type == selected.type;
              return GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
                  decoration: isSelected
                      ? BoxDecoration(
                          borderRadius: AppRadius.brMd,
                          border: Border.all(
                            color: const Color(0xFFFF9800),
                            width: 2,
                          ),
                        )
                      : null,
                  child: PaymasterOptionCard(
                    option: option,
                    isSelected: isSelected,
                  ),
                ),
              );
            }),
            SizedBox(height: AppSpacing.space2),
          ],
        ),
      ),
    );
  }
}
