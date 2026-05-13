// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
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
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(color: Colors.green.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: ScreenUtil().setWidth(64), color: Colors.green),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_ens_renew_success,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (widget.renewResult.newExpiresAt != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              '${S.of(context).g_key_ens_new_expiry}: ${_formatDate(widget.renewResult.newExpiresAt!)}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ],
          if (widget.renewResult.txHash != null) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                'Tx: ${_shortenHash(widget.renewResult.txHash!)}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontFamily: 'monospace',
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
            ),
          ],
          // 到期提醒开关
          if (widget.renewResult.newExpiresAt != null) ...[
            SizedBox(height: ScreenUtil().setWidth(20)),
            Divider(color: Colors.green.withAlpha(50)),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).g_key_ens_reminder_enable,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          fontWeight: FontWeight.w600,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        S.of(context).g_key_ens_reminder_hint,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _reminderEnabled,
                  activeThumbColor: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
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
