// Copyright 2021-2026 N42 Inc. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import 'session_key_models.dart';

// ── Step 4: Spending limit ─────────────────────────────────────────────────

/// Amount input + token selector for the spending limit step.
///
/// Rendered only when the transfer preset is selected.
class SessionKeyAmountLimit extends StatelessWidget {
  final TextEditingController amountCtrl;
  final String selectedToken;
  final bool noLimit;
  final void Function(bool?) onNoLimitChanged;
  final void Function(String) onTokenChanged;

  const SessionKeyAmountLimit({
    super.key,
    required this.amountCtrl,
    required this.selectedToken,
    required this.noLimit,
    required this.onNoLimitChanged,
    required this.onTokenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: amountCtrl,
                enabled: !noLimit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: S.of(context).g_key_aa_session_amount_hint,
                  border: OutlineInputBorder(borderRadius: AppRadius.brMd),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space4,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.space4),
            _TokenChips(selected: selectedToken, onChanged: onTokenChanged),
          ],
        ),
        SizedBox(height: AppSpacing.space2),
        Row(
          children: [
            Checkbox(value: noLimit, onChanged: onNoLimitChanged),
            Expanded(
              child: Text(
                S.of(context).g_key_aa_session_amount_limit,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textSubtitle,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TokenChips extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const _TokenChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const tokens = ['ETH', 'USDC', 'USDT'];
    return Row(
      children: tokens.map((t) {
        final isSelected = selected == t;
        return GestureDetector(
          onTap: () => onChanged(t),
          child: Container(
            margin: EdgeInsets.only(left: ScreenUtil().setWidth(6)),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8B5CF6).withAlpha(25)
                  : AppColorTokens.of(context).textTertiary.withAlpha(15),
              borderRadius: AppRadius.brSm,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : AppColorTokens.of(context).border.withAlpha(40),
              ),
            ),
            child: Text(
              t,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Step 5: Risk summary ───────────────────────────────────────────────────

/// Summarises the current session key configuration before creation.
///
/// Shows DApp name, expiry, permission label, optional spending limit,
/// and a high-risk warning banner when the full preset is selected.
class SessionKeyRiskSummary extends StatelessWidget {
  final SessionKeyPermission preset;
  final String dappLabel;
  final String expiryLabel;
  final String permissionLabel;
  final Color riskColor;
  final String? spendingLimitLine; // null = not shown

  const SessionKeyRiskSummary({
    super.key,
    required this.preset,
    required this.dappLabel,
    required this.expiryLabel,
    required this.permissionLabel,
    required this.riskColor,
    this.spendingLimitLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: riskColor.withAlpha(10),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: riskColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: ScreenUtil().setWidth(20),
                color: riskColor,
              ),
              SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  S.of(context).g_key_aa_permission,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          _row(
            context,
            '🏷️',
            '${S.of(context).g_key_aa_session_dapp_label}: $dappLabel',
          ),
          _row(
            context,
            '⏱️',
            '${S.of(context).g_key_aa_session_expiry}: $expiryLabel',
          ),
          _row(
            context,
            '🔑',
            '${S.of(context).g_key_aa_permission}: $permissionLabel',
          ),
          if (spendingLimitLine != null)
            _row(
              context,
              '💰',
              '${S.of(context).g_key_aa_session_amount_limit}: $spendingLimitLine',
            ),
          if (preset == SessionKeyPermission.full) ...[
            SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  size: ScreenUtil().setWidth(18),
                  color: AppColorTokens.of(context).danger,
                ),
                SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    S.of(context).g_key_aa_session_risk_warning,
                    style: AppTypography.captionSm.copyWith(
                      color: AppColorTokens.of(context).danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: ScreenUtil().setSp(20))),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Risk confirm checkbox ──────────────────────────────────────────────────

/// Checkbox row that the user must tick before creating the session key.
class SessionKeyConfirmCheckbox extends StatelessWidget {
  final bool value;
  final void Function(bool?) onChanged;

  const SessionKeyConfirmCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColorTokens.of(context).brand,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
              child: Text(
                S.of(context).g_key_aa_session_confirm_risk,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
