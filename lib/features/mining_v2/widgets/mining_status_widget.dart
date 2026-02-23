// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_node_detail_page.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

/// Mining Status Widget
///
/// Displays mining status card and balance card side by side.
/// Shows mining active/inactive status with play/pause controls.
class MiningStatusWidget extends StatelessWidget {
  final MiningV2Provider mpValue;

  const MiningStatusWidget({
    super.key,
    required this.mpValue,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = mpValue.miningStatus == true;
    final statusColor = isActive ? const Color(0xff32D74B) : const Color(0xffEB5851);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
      child: Row(
        children: [
          // Mining status card
          Expanded(
            child: _buildStatusCard(context, isActive, statusColor, isDark),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          // Balance card
          Expanded(
            child: _buildBalanceCard(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isActive, Color statusColor, bool isDark) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(36),
                height: ScreenUtil().setWidth(36),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                ),
                child: Icon(
                  isActive ? Icons.verified_outlined : Icons.pause_circle_outline,
                  size: ScreenUtil().setWidth(20),
                  color: statusColor,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(10)),
              Expanded(
                child: Text(
                  S.of(context).g_mining_key_5,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(22),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (mpValue.depositsEnable == true)
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
                      isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                      size: ScreenUtil().setWidth(36),
                      color: isActive ? const Color(0xffEB5851) : const Color(0xff32D74B),
                    ),
                  ),
                ),
              if (mpValue.depositsEnable == true)
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const MiningNodeDetailPage()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(4)),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: ScreenUtil().setWidth(24),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          // Status text + WS indicator dot
          Row(
            children: [
              Expanded(
                child: Text(
                  isActive ? S.current.g_key_193 : S.current.g_mining_key_47,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // WS connected green dot (only when connected)
              if (mpValue.wsConnected)
                Container(
                  width: ScreenUtil().setWidth(8),
                  height: ScreenUtil().setWidth(8),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(6)),
                  decoration: const BoxDecoration(
                    color: Color(0xff32D74B),
                    shape: BoxShape.circle,
                  ),
                ),
              // Status indicator dot
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
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(36),
                height: ScreenUtil().setWidth(36),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: ScreenUtil().setWidth(20),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(10)),
              Expanded(
                child: Text(
                  S.of(context).g_key_29,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(22),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  mpValue.depositsEnable ?? false
                      ? '${mpValue.balanceInBeacon}'
                      : mpValue.walletNBalance.toStringAsFixed(2),
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(32),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                CoinType.N.name,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
