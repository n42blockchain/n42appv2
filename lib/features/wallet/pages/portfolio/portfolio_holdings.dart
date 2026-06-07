// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_models.dart';
import 'package:n42_wallet/features/widgets/image_network.dart'
    show ImageNetWork;

class HoldingRow extends StatelessWidget {
  final CoinRecord record;
  final int rank;
  final double totalValue;
  final double Function(double, double) pnlFn;
  final String Function(double) fmtUsd;
  final Color accentColor;
  final Color textColor;
  final Color sliceColor;

  const HoldingRow({
    super.key,
    required this.record,
    required this.rank,
    required this.totalValue,
    required this.pnlFn,
    required this.fmtUsd,
    required this.accentColor,
    required this.textColor,
    required this.sliceColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalValue > 0 ? record.value / totalValue * 100 : 0.0;
    final pnl = pnlFn(record.value, record.percentage);
    final isUp = record.percentage >= 0;
    final pctColor = isUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: sliceColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: sliceColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: record.icon.isNotEmpty
                ? ImageNetWork(imageUrl: record.icon, width: 28.w, height: 28.w)
                : Container(
                    width: 28.w,
                    height: 28.w,
                    color: textColor.withAlpha(20),
                  ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.symbol.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value: (pct / 100).clamp(0.0, 1.0),
                          minHeight: 3.h,
                          backgroundColor: textColor.withAlpha(20),
                          valueColor: AlwaysStoppedAnimation<Color>(sliceColor),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: textColor.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtUsd(record.value),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isUp ? '+' : ''}${record.percentage.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 11.sp, color: pctColor),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '(${pnl >= 0 ? '+' : ''}\$${pnl.abs() < 1 ? pnl.toStringAsFixed(4) : pnl.toStringAsFixed(2)})',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: pctColor.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
