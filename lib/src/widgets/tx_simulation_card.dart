// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/security/tx_simulation_result.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

/// Compact card that shows the result of an on-chain transaction simulation.
///
/// Visual states:
/// - [TxSimStatus.simulating]  — grey progress indicator
/// - [TxSimStatus.success]     — green banner with checkmark
/// - [TxSimStatus.reverted]    — red banner with X and optional revert reason
/// - [TxSimStatus.unavailable] — orange banner with warning icon
///
/// Matches the Card styling used by [TxRiskBannerWidget] for visual consistency.
class TxSimulationCard extends StatelessWidget {
  final TxSimulationResult result;

  const TxSimulationCard({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return switch (result.status) {
      TxSimStatus.simulating => _SimulatingCard(label: s.g_key_sim_simulating),
      TxSimStatus.success => _StatusCard(
          icon: Icons.check_circle_outline,
          color: const Color(0xFF4CAF50),
          label: s.g_key_sim_success,
        ),
      TxSimStatus.reverted => _StatusCard(
          icon: Icons.cancel_outlined,
          color: const Color(0xFFF44336),
          label: s.g_key_sim_reverted,
          detail: result.revertReason != null
              ? s.g_key_sim_reverted_reason(result.revertReason!)
              : null,
        ),
      TxSimStatus.unavailable => _StatusCard(
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFFF9800),
          label: s.g_key_sim_unavailable,
        ),
    };
  }
}

// ── Internal widgets ─────────────────────────────────────────────────────────

class _SimulatingCard extends StatelessWidget {
  final String label;
  const _SimulatingCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(10),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ScreenUtil().setWidth(12)),
            ),
            minHeight: ScreenUtil().setWidth(4),
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9E9E9E)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(14),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(28),
                  height: ScreenUtil().setWidth(28),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9E9E9E)),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.ff888888.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? detail;

  const _StatusCard({
    required this.icon,
    required this.color,
    required this.label,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(10),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: color.withAlpha(80),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20),
          vertical: ScreenUtil().setWidth(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: ScreenUtil().setWidth(32), color: color),
                SizedBox(width: ScreenUtil().setWidth(10)),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (detail != null) ...[
              SizedBox(height: ScreenUtil().setWidth(8)),
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(42)),
                child: Text(
                  detail!,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: color,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
