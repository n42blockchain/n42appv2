// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/security/tx_simulation_result.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

/// Compact card showing the result of an on-chain transaction simulation.
///
/// Visual states (mirrors Rabby / OKX style):
/// - [TxSimStatus.simulating]  — grey animated progress bar
/// - [TxSimStatus.success]     — green; shows gas estimate when available
/// - [TxSimStatus.reverted]    — red; shows full, selectable revert reason
/// - [TxSimStatus.unavailable] — orange; non-blocking, user may still proceed
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
          // Show gas estimate when available — helps users judge tx complexity
          detail: result.gasEstimate != null
              ? s.g_key_sim_gas_estimate(_formatGas(result.gasEstimate!))
              : null,
          detailSelectable: false,
        ),
      TxSimStatus.reverted => _StatusCard(
          icon: Icons.cancel_outlined,
          color: const Color(0xFFF44336),
          label: s.g_key_sim_reverted,
          // Full revert reason — no truncation; selectable so users can copy
          detail: result.revertReason != null
              ? s.g_key_sim_reverted_reason(result.revertReason!)
              : null,
          detailSelectable: true,
        ),
      TxSimStatus.unavailable => _StatusCard(
          icon: Icons.info_outline,
          color: const Color(0xFFFF9800),
          label: s.g_key_sim_unavailable,
        ),
    };
  }

  /// Format gas units for display: 21000 → "21,000", 1234567 → "1.23M"
  static String _formatGas(BigInt gas) {
    final v = gas.isValidInt ? gas.toInt() : 0x7FFFFFFF;
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(2)}M';
    }
    if (v >= 1000) {
      // Insert comma separator
      final s = v.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return v.toString();
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

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
          // Indeterminate progress bar along the top edge
          LinearProgressIndicator(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ScreenUtil().setWidth(12)),
            ),
            minHeight: ScreenUtil().setWidth(3),
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9E9E9E)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(26),
                  height: ScreenUtil().setWidth(26),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF9E9E9E)),
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

  /// When true, [detail] text is rendered as [SelectableText] so users
  /// can copy the revert reason to investigate.
  final bool detailSelectable;

  const _StatusCard({
    required this.icon,
    required this.color,
    required this.label,
    this.detail,
    this.detailSelectable = false,
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
            // ── Status row ────────────────────────────────────────────────
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

            // ── Detail row (gas estimate / revert reason) ─────────────────
            if (detail != null) ...[
              SizedBox(height: ScreenUtil().setWidth(8)),
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(42)),
                child: detailSelectable
                    // SelectableText lets users long-press and copy the reason
                    ? SelectableText(
                        detail!,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: color,
                          height: 1.45,
                        ),
                      )
                    : Text(
                        detail!,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.ff888888.name),
                          height: 1.45,
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
