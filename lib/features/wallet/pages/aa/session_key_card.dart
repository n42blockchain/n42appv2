// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import 'session_key_models.dart';
import 'session_key_sheets.dart';

// ════════════════════════════════════════════════════════════════════════════
// Session key card widget
// ════════════════════════════════════════════════════════════════════════════

/// A card that renders a single [SessionKeyData] entry.
///
/// Pass [showActions] = true (Active tab) to reveal Details / Revoke buttons.
/// [onRevoke] fires when the user confirms the revoke action from the dialog.
class SessionKeyCard extends StatelessWidget {
  final SessionKeyData keyData;
  final bool showActions;
  final VoidCallback? onRevoke;

  const SessionKeyCard({
    super.key,
    required this.keyData,
    required this.showActions,
    this.onRevoke,
  });

  // ── Public build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final permColor = sessionKeyPermissionColor(keyData.permission);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: sessionKeyStatusColor(context, keyData.status).withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, permColor),
          SizedBox(height: AppSpacing.space4),
          _buildAddressRow(context),
          SizedBox(height: AppSpacing.space4),
          _buildChipsRow(context, permColor),
          if (keyData.spendingLimit != null && keyData.isActive) ...[
            SizedBox(height: AppSpacing.space4),
            _buildSpendingProgress(context),
          ],
          if (showActions && keyData.isActive) ...[
            SizedBox(height: AppSpacing.space4),
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  // ── Private section builders ──────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, Color permColor) {
    return Row(
      children: [
        _buildDappIcon(permColor),
        SizedBox(width: AppSpacing.space4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                keyData.label,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
              if (keyData.dappName != null)
                Text(
                  keyData.dappName!,
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
            ],
          ),
        ),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildDappIcon(Color permColor) {
    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
      decoration: BoxDecoration(
        color: permColor.withAlpha(25),
        borderRadius: AppRadius.brMd,
      ),
      child: keyData.dappIcon != null
          ? ClipRRect(
              borderRadius: AppRadius.brMd,
              child: Image.network(
                keyData.dappIcon!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  sessionKeyPermissionIcon(keyData.permission),
                  size: ScreenUtil().setWidth(28),
                  color: permColor,
                ),
              ),
            )
          : Icon(
              sessionKeyPermissionIcon(keyData.permission),
              size: ScreenUtil().setWidth(28),
              color: permColor,
            ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final color = sessionKeyStatusColor(context, keyData.status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        sessionKeyStatusLabel(context, keyData.status),
        style: AppTypography.captionSm.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context) {
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: keyData.keyAddress));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).copy),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgBase.withAlpha(100),
          borderRadius: AppRadius.brSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.key,
              size: ScreenUtil().setWidth(16),
              color: subtitleColor,
            ),
            SizedBox(width: AppSpacing.space2),
            Text(
              keyData.shortAddress,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontFamily: 'monospace',
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
            SizedBox(width: AppSpacing.space2),
            Icon(
              Icons.copy,
              size: ScreenUtil().setWidth(14),
              color: subtitleColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipsRow(BuildContext context, Color permColor) {
    return Wrap(
      spacing: ScreenUtil().setWidth(8),
      runSpacing: ScreenUtil().setWidth(6),
      children: [
        _buildChip(
          context,
          Icons.security,
          sessionKeyPermissionLabel(context, keyData.permission),
          permColor,
        ),
        _buildChip(
          context,
          Icons.swap_horiz,
          '${keyData.transactionCount ?? 0} txns',
          null,
        ),
        if (keyData.isActive)
          _buildChip(
            context,
            Icons.timer,
            sessionKeyFormatRemainingTime(keyData.remainingTime),
            keyData.remainingTime.inDays < 3
                ? AppColorTokens.of(context).warning
                : null,
          ),
        if (keyData.spendingLimit != null && keyData.spendingToken != null)
          _buildChip(
            context,
            Icons.account_balance_wallet,
            '≤ ${sessionKeyFormatBigInt(keyData.spendingLimit!, 18)} ${keyData.spendingToken}',
            null,
          ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label,
    Color? color,
  ) {
    final chipColor = color ?? AppColorTokens.of(context).textSubtitle;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(15),
        borderRadius: AppRadius.brSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ScreenUtil().setWidth(14), color: chipColor),
          SizedBox(width: AppSpacing.space2),
          Text(
            label,
            style: AppTypography.captionSm.copyWith(color: chipColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingProgress(BuildContext context) {
    final pct = keyData.usagePercentage;
    final c = AppColorTokens.of(context);
    final color = pct > 0.8 ? c.warning : c.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                S.of(context).g_key_aa_spending_limit,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textSubtitle,
                ),
              ),
            ),
            Text(
              '${(pct * 100).toStringAsFixed(1)}%',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.space2),
        ClipRRect(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(4)),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: c.textTertiary.withAlpha(30),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: ScreenUtil().setWidth(8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => KeyDetailsSheet(keyData: keyData),
            ),
            icon: const Icon(Icons.info_outline, size: 18),
            label: Text(S.of(context).g_key_aa_details),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorTokens.of(context).brand,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brSm),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.space4),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmRevoke(context),
            icon: const Icon(Icons.block, size: 18),
            label: Text(S.of(context).g_key_aa_revoke),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorTokens.of(context).danger,
              side: BorderSide(color: AppColorTokens.of(context).danger),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brSm),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmRevoke(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).g_key_aa_revoke_session),
        content: SingleChildScrollView(
          child: Text(S.of(ctx).g_key_aa_revoke_confirm),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(ctx).g_key_79),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRevoke?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColorTokens.of(ctx).danger,
            ),
            child: Text(S.of(ctx).g_key_aa_revoke),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Shared helper functions (used by card and page)
// ════════════════════════════════════════════════════════════════════════════

/// Maps [SessionKeyStatus] to a display colour.
Color sessionKeyStatusColor(BuildContext context, SessionKeyStatus status) {
  final c = AppColorTokens.of(context);
  return switch (status) {
    SessionKeyStatus.active => c.success,
    SessionKeyStatus.expired => c.warning,
    SessionKeyStatus.revoked => c.danger,
  };
}

/// Returns a localised label for [status].
String sessionKeyStatusLabel(BuildContext context, SessionKeyStatus status) =>
    switch (status) {
      SessionKeyStatus.active => S.of(context).g_key_aa_active,
      SessionKeyStatus.expired => S.of(context).g_key_aa_expired,
      SessionKeyStatus.revoked => S.of(context).g_key_aa_revoked_status,
    };

/// Returns a localised label for [permission].
String sessionKeyPermissionLabel(
  BuildContext context,
  SessionKeyPermission permission,
) => switch (permission) {
  SessionKeyPermission.transfer =>
    S.of(context).g_key_aa_session_preset_transfer,
  SessionKeyPermission.approve => S.of(context).g_key_aa_approve,
  SessionKeyPermission.contractCall =>
    S.of(context).g_key_aa_session_preset_contract,
  SessionKeyPermission.full => S.of(context).g_key_aa_session_preset_full,
};

/// Returns a compact human-readable string for [d] (e.g. "3d", "5h", "12m").
String sessionKeyFormatRemainingTime(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d';
  if (d.inHours > 0) return '${d.inHours}h';
  if (d.inMinutes > 0) return '${d.inMinutes}m';
  return 'expired';
}

/// Formats a [BigInt] wei amount with [decimals] precision into a
/// human-readable string (e.g. "1.5", "100").
final _trailingZeros = RegExp(r'0+$');

String sessionKeyFormatBigInt(BigInt value, int decimals) {
  if (value == BigInt.zero) return '0';
  final pow = BigInt.from(10).pow(decimals);
  final whole = value ~/ pow;
  final frac = (value % pow).toString().padLeft(decimals, '0');
  final trimmed = frac.replaceAll(_trailingZeros, '');
  return trimmed.isEmpty ? whole.toString() : '$whole.$trimmed';
}
