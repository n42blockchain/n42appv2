// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/services/ens_expiry_reminder_service.dart';

/// ENS 续费成功结果卡片
///
/// 显示交易哈希、新到期时间，以及到期提醒开关
class EnsRenewSuccessCard extends StatefulWidget {
  final String ensName;
  final RenewResult renewResult;

  const EnsRenewSuccessCard({
    super.key,
    required this.ensName,
    required this.renewResult,
  });

  @override
  State<EnsRenewSuccessCard> createState() => _EnsRenewSuccessCardState();
}

class _EnsRenewSuccessCardState extends State<EnsRenewSuccessCard> {
  bool _reminderEnabled = true;
  bool _reminderSaving = false;

  Future<void> _toggleReminder(bool value) async {
    if (_reminderSaving) return;
    setState(() => _reminderSaving = true);
    try {
      if (value) {
        await EnsExpiryReminderService.setReminder(
          widget.ensName,
          widget.renewResult.newExpiresAt!,
        );
      } else {
        await EnsExpiryReminderService.disableReminder(widget.ensName);
      }
      if (mounted) {
        setState(() {
          _reminderEnabled = value;
          _reminderSaving = false;
        });
      }
    } catch (e) {
      AppLogger.w('EnsRenewSuccess', 'failed to toggle reminder: $e');
      if (mounted) {
        setState(() => _reminderSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: Colors.green.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: ScreenUtil().setWidth(64),
            color: Colors.green,
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_key_ens_renew_success,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          if (widget.renewResult.newExpiresAt != null) ...[
            SizedBox(height: AppSpacing.space2),
            Text(
              '${S.of(context).g_key_ens_new_expiry}: ${_formatDate(widget.renewResult.newExpiresAt!)}',
              style: AppTypography.caption.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ],
          if (widget.renewResult.txHash != null) ...[
            SizedBox(height: AppSpacing.space4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: AppRadius.brSm,
              ),
              child: Text(
                'Tx: ${_shortenHash(widget.renewResult.txHash!)}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontFamily: 'monospace',
                  color: AppColorTokens.of(context).textSubtitle,
                ),
              ),
            ),
          ],
          // 到期提醒开关
          if (widget.renewResult.newExpiresAt != null) ...[
            SizedBox(height: AppSpacing.space4),
            Divider(color: Colors.green.withAlpha(50)),
            SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).g_key_ens_reminder_enable,
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.space2),
                      Text(
                        S.of(context).g_key_ens_reminder_hint,
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _reminderEnabled,
                  activeThumbColor: AppColorTokens.of(context).brand,
                  onChanged: _reminderSaving ? null : _toggleReminder,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _shortenHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 6)}';
  }
}
