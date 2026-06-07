// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Gas 代付标识
///
/// 显示交易是否由 Paymaster 赞助 Gas
class GasSponsorshipBadge extends StatelessWidget {
  final bool isSponsored;
  final String? sponsorName;
  final String? savedAmount;

  const GasSponsorshipBadge({
    super.key,
    required this.isSponsored,
    this.sponsorName,
    this.savedAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSponsored) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(14),
        vertical: ScreenUtil().setWidth(10),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withAlpha(30), Colors.green.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: Colors.green.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_giftcard,
            size: ScreenUtil().setWidth(22),
            color: Colors.green,
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).g_key_aa_gas_sponsored,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              if (sponsorName != null || savedAmount != null)
                Text(
                  sponsorName != null
                      ? '${S.of(context).g_key_aa_by} $sponsorName'
                      : '${S.of(context).g_key_aa_saved} $savedAmount',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    color: Colors.green.withAlpha(180),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 简化版 Gas 代付标识 (仅图标)
class GasSponsoredIcon extends StatelessWidget {
  final bool isSponsored;
  final double size;

  const GasSponsoredIcon({
    super.key,
    required this.isSponsored,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSponsored) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.card_giftcard,
        size: ScreenUtil().setWidth(size),
        color: Colors.green,
      ),
    );
  }
}
