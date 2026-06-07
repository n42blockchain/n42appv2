// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_chain_config.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';

/// ENS 管理页快捷操作按钮栏（续费 / 设置主要 / 复制）
class EnsQuickActions extends StatelessWidget {
  final OwnedEns ownedEns;
  final EnsChainConfig domainChain;
  final VoidCallback onRenew;
  final VoidCallback? onSetPrimary;
  final VoidCallback onCopy;

  const EnsQuickActions({
    super.key,
    required this.ownedEns,
    required this.domainChain,
    required this.onRenew,
    required this.onSetPrimary,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.autorenew,
            label: S.of(context).g_key_ens_renew,
            color: const Color(0xFF66BB6A),
            onTap: onRenew,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _ActionButton(
            icon: Icons.star,
            label: S.of(context).g_key_ens_set_primary,
            color: const Color(0xFFFFA726),
            onTap: onSetPrimary,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _ActionButton(
            icon: Icons.content_copy,
            label: S.of(context).g_key_119,
            color: blueColor,
            onTap: onCopy,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.withAlpha(20) : color.withAlpha(20),
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: isDisabled ? Colors.grey.withAlpha(30) : color.withAlpha(40),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: ScreenUtil().setWidth(28),
              color: isDisabled ? Colors.grey : color,
            ),
            SizedBox(height: ScreenUtil().setWidth(6)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.w500,
                color: isDisabled
                    ? Colors.grey
                    : AppColorTokens.of(context).textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
