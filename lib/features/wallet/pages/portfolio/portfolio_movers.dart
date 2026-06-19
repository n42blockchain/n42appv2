// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_models.dart';
import 'package:n42_wallet/features/widgets/image_network.dart'
    show ImageNetWork;

// ─── Mover row ────────────────────────────────────────────────────────────────

class MoverRow extends StatelessWidget {
  final String label;
  final List<CoinRecord> records;
  final double Function(double, double) pnlFn;
  final String Function(double) fmtUsd;
  final Color textColor;

  const MoverRow({
    super.key,
    required this.label,
    required this.records,
    required this.pnlFn,
    required this.fmtUsd,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isGainer = records.isNotEmpty && records.first.percentage >= 0;
    final labelColor = isGainer
        ? AppColorTokens.of(context).success
        : AppColorTokens.of(context).danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isGainer
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 26.sp,
              color: labelColor,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        for (final r in records)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: r.icon.isNotEmpty
                      ? ImageNetWork(
                          imageUrl: r.icon,
                          width: 48.w,
                          height: 48.w,
                        )
                      : Container(
                          width: 48.w,
                          height: 48.w,
                          color: textColor.withAlpha(30),
                          child: Icon(
                            Icons.currency_bitcoin,
                            size: 28.sp,
                            color: textColor.withAlpha(100),
                          ),
                        ),
                ),
                SizedBox(width: 16.w),
                Text(
                  r.symbol.toUpperCase(),
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${r.percentage >= 0 ? '+' : ''}${r.percentage.toStringAsFixed(2)}%',
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                    Text(
                      fmtUsd(pnlFn(r.value, r.percentage)),
                      style: AppTypography.caption.copyWith(
                        color: labelColor.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
