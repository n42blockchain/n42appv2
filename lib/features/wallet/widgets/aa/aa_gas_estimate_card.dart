// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/gas_sponsorship_badge.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class AAGasEstimateCard extends StatelessWidget {
  const AAGasEstimateCard({
    super.key,
    required this.isEstimating,
    required this.isSponsored,
    required this.cost,
    required this.title,
    this.icon,
  });

  final bool isEstimating;
  final bool isSponsored;
  final String? cost;
  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final success = AppColorTokens.of(context).success;
    final subtitle = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );
    final label = Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.caption.copyWith(color: subtitle),
    );
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: isSponsored
            ? success.withAlpha(15)
            : AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemBgColor.name,
              ),
        borderRadius: AppRadius.brMd,
        border: isSponsored ? Border.all(color: success.withAlpha(30)) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: icon == null
                    ? label
                    : Row(
                        children: [
                          Icon(
                            icon,
                            size: ScreenUtil().setWidth(22),
                            color: subtitle,
                          ),
                          SizedBox(width: AppSpacing.space2),
                          Flexible(child: label),
                        ],
                      ),
              ),
              _buildValue(context, subtitle, success),
            ],
          ),
          if (isSponsored && cost != null) ...[
            SizedBox(height: AppSpacing.space2),
            GasSponsorshipBadge(isSponsored: true, savedAmount: cost),
          ],
        ],
      ),
    );
  }

  Widget _buildValue(BuildContext context, Color subtitle, Color success) {
    if (isEstimating) {
      return SizedBox.square(
        dimension: ScreenUtil().setWidth(20),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final value = cost;
    if (value == null) {
      return Text('-', style: AppTypography.bodySm.copyWith(color: subtitle));
    }
    return Text(
      isSponsored ? S.of(context).g_key_aa_free : value,
      style: AppTypography.bodySm.copyWith(
        fontWeight: FontWeight.w600,
        color: isSponsored
            ? success
            : AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
      ),
    );
  }
}
