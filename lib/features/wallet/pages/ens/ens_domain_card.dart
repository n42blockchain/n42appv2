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

/// ENS 管理页的域名信息卡片（含头像、链标签、到期信息）
class EnsDomainCard extends StatelessWidget {
  final OwnedEns ownedEns;
  final EnsChainConfig domainChain;

  const EnsDomainCard({
    super.key,
    required this.ownedEns,
    required this.domainChain,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon = ownedEns.isExpiringSoon;
    final isExpired = ownedEns.isExpired;
    final themeBlue = AppColorTokens.of(context).brand;

    final Color gradientBase;
    if (isExpired) {
      gradientBase = Colors.red;
    } else if (isExpiringSoon) {
      gradientBase = Colors.orange;
    } else {
      gradientBase = themeBlue;
    }

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientBase.withAlpha(30), gradientBase.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          _EnsAvatar(ownedEns: ownedEns, domainChain: domainChain),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            ownedEns.name,
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          _ChainBadgeRow(ownedEns: ownedEns, domainChain: domainChain),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _ExpiryRow(
            ownedEns: ownedEns,
            isExpired: isExpired,
            isExpiringSoon: isExpiringSoon,
          ),
          if (!isExpired)
            Text(
              '${ownedEns.daysUntilExpiry} ${S.of(context).g_key_ens_days_left}',
              style: AppTypography.caption.copyWith(
                color: AppColorTokens.of(context).textSubtitle.withAlpha(150),
              ),
            ),
        ],
      ),
    );
  }
}

class _EnsAvatar extends StatelessWidget {
  final OwnedEns ownedEns;
  final EnsChainConfig domainChain;

  const _EnsAvatar({required this.ownedEns, required this.domainChain});

  @override
  Widget build(BuildContext context) {
    final defaultAvatar = _DefaultAvatar(
      ownedEns: ownedEns,
      domainChain: domainChain,
    );
    if (ownedEns.avatar == null) return defaultAvatar;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
      child: Image.network(
        ownedEns.avatar!,
        width: ScreenUtil().setWidth(80),
        height: ScreenUtil().setWidth(80),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => defaultAvatar,
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final OwnedEns ownedEns;
  final EnsChainConfig domainChain;

  const _DefaultAvatar({required this.ownedEns, required this.domainChain});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(80),
      height: ScreenUtil().setWidth(80),
      decoration: BoxDecoration(
        color: domainChain.color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
      ),
      child: Center(
        child: Text(
          ownedEns.name.substring(0, 1).toUpperCase(),
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.w600,
            color: domainChain.color,
          ),
        ),
      ),
    );
  }
}

class _ChainBadgeRow extends StatelessWidget {
  final OwnedEns ownedEns;
  final EnsChainConfig domainChain;

  const _ChainBadgeRow({required this.ownedEns, required this.domainChain});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _badge(label: domainChain.name, color: domainChain.color),
        if (ownedEns.isPrimary) ...[
          SizedBox(width: ScreenUtil().setWidth(8)),
          _badge(label: S.of(context).g_key_ens_primary, color: Colors.green),
        ],
      ],
    );
  }

  Widget _badge({required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(4),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: AppTypography.captionSm.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExpiryRow extends StatelessWidget {
  final OwnedEns ownedEns;
  final bool isExpired;
  final bool isExpiringSoon;

  const _ExpiryRow({
    required this.ownedEns,
    required this.isExpired,
    required this.isExpiringSoon,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColorTokens.of(context).textSubtitle;

    IconData icon;
    Color color;
    String label;

    if (isExpired) {
      icon = Icons.error;
      color = Colors.red;
      label = S.of(context).g_key_ens_expired;
    } else if (isExpiringSoon) {
      icon = Icons.warning;
      color = Colors.orange;
      label =
          '${S.of(context).g_key_ens_expires}: ${ownedEns.formattedExpiresAt}';
    } else {
      icon = Icons.access_time;
      color = subtitleColor;
      label =
          '${S.of(context).g_key_ens_expires}: ${ownedEns.formattedExpiresAt}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: ScreenUtil().setWidth(20), color: color),
        SizedBox(width: ScreenUtil().setWidth(6)),
        Text(label, style: AppTypography.caption.copyWith(color: color)),
      ],
    );
  }
}
