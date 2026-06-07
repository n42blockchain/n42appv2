// Copyright 2021-2026 N42 Inc. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import 'session_key_models.dart';

/// Read-only bottom sheet that displays all fields of a [SessionKeyData].
class KeyDetailsSheet extends StatelessWidget {
  final SessionKeyData keyData;

  const KeyDetailsSheet({super.key, required this.keyData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(4),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_aa_session_details,
            style: AppTypography.headline.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          _row(context, S.of(context).g_key_aa_label, keyData.label),
          _row(
            context,
            S.of(context).g_key_aa_permission,
            _permLabel(context, keyData.permission),
          ),
          _row(
            context,
            S.of(context).g_key_aa_created,
            _date(keyData.createdAt),
          ),
          _row(
            context,
            S.of(context).g_key_aa_expires,
            _date(keyData.expiresAt),
          ),
          _row(
            context,
            S.of(context).g_key_aa_transactions,
            '${keyData.transactionCount ?? 0}',
          ),
          if (keyData.spendingToken != null && keyData.spendingLimit != null)
            _row(
              context,
              S.of(context).g_key_aa_spending_limit,
              '${_formatBigInt(keyData.spendingLimit!, 18)} ${keyData.spendingToken}',
            ),
          SizedBox(height: ScreenUtil().setWidth(24)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColorTokens.of(context).textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _permLabel(BuildContext context, SessionKeyPermission p) =>
      switch (p) {
        SessionKeyPermission.transfer =>
          S.of(context).g_key_aa_session_preset_transfer,
        SessionKeyPermission.approve => S.of(context).g_key_aa_approve,
        SessionKeyPermission.contractCall =>
          S.of(context).g_key_aa_session_preset_contract,
        SessionKeyPermission.full => S.of(context).g_key_aa_session_preset_full,
      };

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static final _trailingZeros = RegExp(r'0+$');

  static String _formatBigInt(BigInt value, int decimals) {
    if (value == BigInt.zero) return '0';
    final pow = BigInt.from(10).pow(decimals);
    final whole = value ~/ pow;
    final frac = (value % pow).toString().padLeft(decimals, '0');
    final trimmed = frac.replaceAll(_trailingZeros, '');
    return trimmed.isEmpty ? whole.toString() : '$whole.$trimmed';
  }
}
