// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_node_detail_page.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

/// Mining Status Widget
///
/// Displays mining status card and balance card side by side.
/// Shows mining active/inactive status with play/pause controls.
class MiningStatusWidget extends StatelessWidget {
  final MiningV2Provider mpValue;

  const MiningStatusWidget({super.key, required this.mpValue});

  @override
  Widget build(BuildContext context) {
    final isActive = mpValue.miningStatus;
    final c = AppColorTokens.of(context);
    final statusColor = isActive ? c.success : c.danger;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(context, isActive, statusColor, isDark),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(child: _buildBalanceCard(context, isDark)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    bool isActive,
    Color statusColor,
    bool isDark,
  ) {
    final c = AppColorTokens.of(context);
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0D2A18), const Color(0xFF0A2010)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)],
              )
            : null,
        color: isActive ? null : AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: isActive
              ? statusColor.withValues(alpha: 0.25)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBox(
                ScreenUtil().setWidth(36),
                statusColor.withValues(alpha: 0.15),
                Icon(
                  isActive
                      ? Icons.verified_outlined
                      : Icons.pause_circle_outline,
                  size: ScreenUtil().setWidth(20),
                  color: statusColor,
                ),
              ),
              SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  S.of(context).g_mining_key_5,
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (mpValue.depositsEnable == true) ...[
                InkWell(
                  onTap: () {
                    if (isActive) {
                      mpValue.disconnectWebSocket();
                    } else {
                      mpValue.checkAddressMiningStatus();
                    }
                  },
                  child: SizedBox(
                    width: ScreenUtil().setWidth(36),
                    height: ScreenUtil().setWidth(36),
                    child: Icon(
                      isActive
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: ScreenUtil().setWidth(36),
                      color: isActive ? c.danger : c.success,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MiningNodeDetailPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(4)),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: ScreenUtil().setWidth(24),
                      color: AppColorTokens.of(context).textSubtitle,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          Row(
            children: [
              Expanded(
                child: Text(
                  isActive ? S.current.g_key_193 : S.current.g_mining_key_47,
                  style: AppTypography.body.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (mpValue.wsConnected)
                Container(
                  width: ScreenUtil().setWidth(8),
                  height: ScreenUtil().setWidth(8),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(6)),
                  decoration: BoxDecoration(
                    color: c.success,
                    shape: BoxShape.circle,
                  ),
                ),
              Container(
                width: ScreenUtil().setWidth(14),
                height: ScreenUtil().setWidth(14),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBox(
                ScreenUtil().setWidth(36),
                AppColorTokens.of(context).brand.withValues(alpha: 0.15),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: ScreenUtil().setWidth(20),
                  color: AppColorTokens.of(context).brand,
                ),
              ),
              SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  S.of(context).g_key_29,
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  mpValue.depositsEnable ?? false
                      ? '${mpValue.balanceInBeacon}'
                      : mpValue.walletNBalance.toStringAsFixed(2),
                  style: AppTypography.body.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                CoinType.N.name,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(double size, Color bgColor, Widget icon) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, borderRadius: AppRadius.brSm),
      child: icon,
    );
  }
}
