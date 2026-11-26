// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class AAGasEstimateValue extends StatelessWidget {
  const AAGasEstimateValue({
    super.key,
    required this.isEstimating,
    required this.isSponsored,
    required this.cost,
  });

  final bool isEstimating;
  final bool isSponsored;
  final String? cost;

  @override
  Widget build(BuildContext context) {
    if (isEstimating) {
      return SizedBox.square(
        dimension: ScreenUtil().setWidth(20),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final value = cost;
    if (value == null) {
      return Text(
        '-',
        style: AppTypography.bodySm.copyWith(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemSubtitleTextColor.name,
          ),
        ),
      );
    }
    return Text(
      isSponsored ? S.of(context).g_key_aa_free : value,
      style: AppTypography.bodySm.copyWith(
        fontWeight: FontWeight.w600,
        color: isSponsored
            ? AppColorTokens.of(context).success
            : AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
      ),
    );
  }
}
