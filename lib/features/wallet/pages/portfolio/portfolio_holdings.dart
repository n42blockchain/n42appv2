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
    final pctColor = isUp
        ? AppColorTokens.of(context).success
        : AppColorTokens.of(context).danger;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final rightColumnWidth = (availableWidth * 0.38)
              .clamp(112.0, 172.0)
              .toDouble();
          final changeText =
              '${isUp ? '+' : ''}${record.percentage.toStringAsFixed(2)}% '
              '(${pnl >= 0 ? '+' : ''}\$${pnl.abs() < 1 ? pnl.toStringAsFixed(4) : pnl.toStringAsFixed(2)})';

          return Row(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: sliceColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: sliceColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: record.icon.isNotEmpty
                    ? ImageNetWork(
                        imageUrl: record.icon,
                        width: 56.w,
                        height: 56.w,
                      )
                    : Container(
                        width: 56.w,
                        height: 56.w,
                        color: textColor.withAlpha(20),
                      ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.symbol.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong.copyWith(
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: (pct / 100).clamp(0.0, 1.0),
                              minHeight: 6.h,
                              backgroundColor: textColor.withAlpha(20),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                sliceColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.captionSm.copyWith(
                            fontWeight: FontWeight.w400,
                            color: textColor.withAlpha(128),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              SizedBox(
                width: rightColumnWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fmtUsd(record.value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      changeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTypography.caption.copyWith(color: pctColor),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
