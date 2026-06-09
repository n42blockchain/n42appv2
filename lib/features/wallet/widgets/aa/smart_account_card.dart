// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/deployment_status_indicator.dart';

/// 智能账户卡片
///
/// 显示智能账户信息，包括:
/// - 账户地址
/// - 账户类型
/// - 部署状态
/// - 链标识
class SmartAccountCard extends StatelessWidget {
  final SmartAccount account;
  final VoidCallback? onTap;
  final bool showDetails;

  const SmartAccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getAccountTypeColor(account.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [typeColor.withAlpha(30), typeColor.withAlpha(10)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.brMd,
          border: Border.all(color: typeColor.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：账户类型和状态
            Row(
              children: [
                _buildAccountTypeIcon(context),
                SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.displayName,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                      Text(
                        account.type.displayName,
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                DeploymentStatusIndicator(state: account.state),
              ],
            ),
            SizedBox(height: AppSpacing.space4),

            // 地址
            _buildAddressRow(context),

            // 详细信息
            if (showDetails) ...[
              SizedBox(height: AppSpacing.space4),
              _buildDetailsSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeIcon(BuildContext context) {
    final color = _getAccountTypeColor(account.type);
    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: AppRadius.brMd,
      ),
      child: Center(
        child: Icon(
          _getAccountTypeIcon(account.type),
          size: ScreenUtil().setWidth(28),
          color: color,
        ),
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgBase.withAlpha(100),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              account.shortAddress,
              style: AppTypography.bodySm.copyWith(
                fontFamily: 'monospace',
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: account.address));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).g_key_119),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Icon(
              Icons.copy,
              size: ScreenUtil().setWidth(22),
              color: AppColorTokens.of(context).brand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgBase.withAlpha(80),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            S.of(context).g_key_aa_chain_id,
            account.chainId.toString(),
          ),
          Divider(height: ScreenUtil().setWidth(16)),
          _buildDetailRow(
            context,
            S.of(context).g_key_aa_created,
            _formatDate(account.createdAt),
          ),
          if (account.lastActivityAt != null) ...[
            Divider(height: ScreenUtil().setWidth(16)),
            _buildDetailRow(
              context,
              S.of(context).g_key_aa_last_activity,
              _formatDate(account.lastActivityAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getAccountTypeColor(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return const Color(0xFF5E97F6);
      case SmartAccountType.simple7702Account:
        return const Color(0xFF9333EA);
      case SmartAccountType.safe:
        return const Color(0xFF12A87B);
      case SmartAccountType.kernel:
        return const Color(0xFF8B5CF6);
      case SmartAccountType.biconomy:
        return const Color(0xFFFF6B4A);
      case SmartAccountType.custom:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getAccountTypeIcon(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return Icons.account_balance_wallet;
      case SmartAccountType.simple7702Account:
        return Icons.flash_on;
      case SmartAccountType.safe:
        return Icons.security;
      case SmartAccountType.kernel:
        return Icons.memory;
      case SmartAccountType.biconomy:
        return Icons.auto_awesome;
      case SmartAccountType.custom:
        return Icons.code;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
