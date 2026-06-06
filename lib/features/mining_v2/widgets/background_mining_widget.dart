// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_background.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

/// Background Mining Widget
///
/// Shows background mining status and launch button.
/// Only visible when deposits are enabled.
class BackgroundMiningWidget extends StatelessWidget {
  final MiningV2Provider mpValue;

  const BackgroundMiningWidget({super.key, required this.mpValue});

  @override
  Widget build(BuildContext context) {
    if (mpValue.depositsEnable == false) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = mpValue.depositsEnable == true;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                colors: [
                  AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ).withValues(alpha: 0.08),
                  AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ).withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled
            ? null
            : AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemBgColor.name,
              ),
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: isEnabled
              ? AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainBlueColor.name,
                ).withValues(alpha: 0.2)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildIcon(context),
          SizedBox(width: ScreenUtil().setWidth(16)),
          _buildTitleSection(context, isEnabled),
          _buildLaunchButton(context, isEnabled, isDark),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(72),
      height: ScreenUtil().setWidth(72),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ).withValues(alpha: 0.12),
        borderRadius: AppRadius.brMd,
      ),
      child: Center(
        child: Image.asset(
          'assets/mining/backgroundmining.png',
          height: ScreenUtil().setWidth(44),
          width: ScreenUtil().setWidth(44),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, bool isEnabled) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_mining_key_9,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(6)),
          Text(
            isEnabled
                ? S.of(context).g_key_mining_available
                : S.of(context).g_key_mining_requires_staking,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: isEnabled
                  ? AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    )
                  : AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchButton(BuildContext context, bool isEnabled, bool isDark) {
    final disabledBgColor = isDark
        ? const Color(0xFF3A4A5C)
        : const Color(0xFFE0E0E0);
    final disabledTextColor = isDark
        ? const Color(0xFF8A9AAC)
        : const Color(0xFF9E9E9E);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => MiningBackground().backgroundStart() : null,
        borderRadius: AppRadius.brXl,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(28),
            vertical: ScreenUtil().setWidth(14),
          ),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ).withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isEnabled ? null : disabledBgColor,
            borderRadius: AppRadius.brXl,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            S.of(context).g_key_wallet_c4,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w600,
              color: isEnabled ? Colors.white : disabledTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
