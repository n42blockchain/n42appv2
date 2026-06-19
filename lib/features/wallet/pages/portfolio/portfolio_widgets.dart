// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

// ─── Summary card ─────────────────────────────────────────────────────────────

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color valueColor;
  final Color itemBg;
  final Color textColor;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.subValue,
    required this.valueColor,
    required this.itemBg,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 30.sp, color: valueColor),
              SizedBox(width: 10.w),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: textColor.withAlpha(153),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subValue != null)
            Text(
              subValue!,
              style: AppTypography.caption.copyWith(
                color: valueColor.withAlpha(200),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Legend item ──────────────────────────────────────────────────────────────

class LegendItem extends StatelessWidget {
  final Color color;
  final String symbol;
  final double pct;
  final bool isActive;
  final Color textColor;

  const LegendItem({
    super.key,
    required this.color,
    required this.symbol,
    required this.pct,
    required this.isActive,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              symbol,
              style: AppTypography.caption.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? textColor : textColor.withAlpha(178),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: AppTypography.caption.copyWith(
              color: isActive ? textColor : textColor.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }
}
