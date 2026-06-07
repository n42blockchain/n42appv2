// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';

/// 已拥有 ENS 列表项
class EnsOwnedListItem extends StatelessWidget {
  final OwnedEns ownedEns;
  final VoidCallback? onTap;

  const EnsOwnedListItem({super.key, required this.ownedEns, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon = ownedEns.isExpiringSoon;
    final isExpired = ownedEns.isExpired;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: isExpired
                ? Colors.red.withAlpha(50)
                : isExpiringSoon
                ? Colors.orange.withAlpha(50)
                : AppColorTokens.of(context).brand.withAlpha(30),
          ),
        ),
        child: Row(
          children: [
            // 头像
            _buildAvatar(context),
            SizedBox(width: ScreenUtil().setWidth(14)),

            // 域名信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ownedEns.name,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                      if (ownedEns.isPrimary) ...[
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(8),
                            vertical: ScreenUtil().setWidth(2),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(30),
                            borderRadius: AppRadius.brSm,
                          ),
                          child: Text(
                            S.of(context).g_key_ens_primary,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(18),
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Row(
                    children: [
                      Icon(
                        isExpired
                            ? Icons.error_outline
                            : isExpiringSoon
                            ? Icons.warning_amber
                            : Icons.access_time,
                        size: ScreenUtil().setWidth(16),
                        color: isExpired
                            ? Colors.red
                            : isExpiringSoon
                            ? Colors.orange
                            : AppColorTokens.of(context).textSubtitle,
                      ),
                      SizedBox(width: ScreenUtil().setWidth(4)),
                      Flexible(
                        child: Text(
                          isExpired
                              ? S.of(context).g_key_ens_expired
                              : isExpiringSoon
                              ? '${ownedEns.daysUntilExpiry} ${S.of(context).g_key_ens_days_left}'
                              : ownedEns.formattedExpiresAt,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(22),
                            color: isExpired
                                ? Colors.red
                                : isExpiringSoon
                                ? Colors.orange
                                : AppColorTokens.of(context).textSubtitle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 箭头
            Icon(
              Icons.chevron_right,
              size: ScreenUtil().setWidth(28),
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (ownedEns.avatar != null) {
      return ClipRRect(
        borderRadius: AppRadius.brLg,
        child: Image.network(
          ownedEns.avatar!,
          width: ScreenUtil().setWidth(48),
          height: ScreenUtil().setWidth(48),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildDefaultAvatar(context),
        ),
      );
    }
    return _buildDefaultAvatar(context);
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).brand.withAlpha(30),
        borderRadius: AppRadius.brLg,
      ),
      child: Center(
        child: Text(
          ownedEns.name.isNotEmpty ? ownedEns.name[0].toUpperCase() : 'E',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            fontWeight: FontWeight.bold,
            color: AppColorTokens.of(context).brand,
          ),
        ),
      ),
    );
  }
}
