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

/// 子域名列表区块
class EnsSubdomainSection extends StatelessWidget {
  final List<SubdomainInfo> subdomains;
  final bool isLoading;
  final EnsChainConfig domainChain;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final void Function(SubdomainInfo) onCopy;
  final void Function(SubdomainInfo) onDelete;

  const EnsSubdomainSection({
    super.key,
    required this.subdomains,
    required this.isLoading,
    required this.domainChain,
    required this.onRefresh,
    required this.onCreate,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(context),
          _buildBody(context),
          SizedBox(height: AppSpacing.space4),
          _buildCreateButton(context),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final mainTextColor = AppColorTokens.of(context).textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            S.of(context).g_key_ens_subdomains,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: mainTextColor,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: isLoading ? null : onRefresh,
              color: subtitleColor,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 22),
              onPressed: onCreate,
              color: domainChain.color,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final scr = ScreenUtil();

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: scr.setWidth(24)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (subdomains.isEmpty) return _buildEmptyState(context, scr);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subdomains.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _SubdomainItem(
        sub: subdomains[i],
        domainChain: domainChain,
        onCopy: onCopy,
        onDelete: onDelete,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ScreenUtil scr) {
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scr.setWidth(20)),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.subdirectory_arrow_right,
              size: scr.setWidth(48),
              color: subtitleColor.withAlpha(100),
            ),
            SizedBox(height: scr.setWidth(8)),
            Text(
              S.of(context).g_key_ens_subdomain_empty,
              style: TextStyle(fontSize: scr.setSp(24), color: subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onCreate,
      icon: Icon(
        Icons.add,
        size: ScreenUtil().setWidth(20),
        color: domainChain.color,
      ),
      label: Text(
        S.of(context).g_key_ens_subdomain_create,
        style: TextStyle(color: domainChain.color),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: domainChain.color.withAlpha(80)),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        minimumSize: Size(double.infinity, ScreenUtil().setWidth(80)),
      ),
    );
  }
}

class _SubdomainItem extends StatelessWidget {
  final SubdomainInfo sub;
  final EnsChainConfig domainChain;
  final void Function(SubdomainInfo) onCopy;
  final void Function(SubdomainInfo) onDelete;

  const _SubdomainItem({
    required this.sub,
    required this.domainChain,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scr = ScreenUtil();
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final mainTextColor = AppColorTokens.of(context).textPrimary;
    final iconSize = scr.setWidth(40);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: scr.setWidth(12)),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: domainChain.color.withAlpha(20),
              borderRadius: BorderRadius.circular(scr.setWidth(20)),
            ),
            child: Icon(
              Icons.subdirectory_arrow_right,
              size: scr.setWidth(20),
              color: domainChain.color,
            ),
          ),
          SizedBox(width: scr.setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.fullName,
                  style: TextStyle(
                    fontSize: scr.setSp(26),
                    fontWeight: FontWeight.w500,
                    color: mainTextColor,
                  ),
                ),
                if (sub.owner.isNotEmpty)
                  Text(
                    '${sub.owner.substring(0, 6)}...${sub.owner.substring(sub.owner.length - 4)}',
                    style: TextStyle(
                      fontSize: scr.setSp(22),
                      color: subtitleColor,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            onPressed: () => onCopy(sub),
            color: subtitleColor,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => onDelete(sub),
            color: Colors.red.withAlpha(180),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: child,
    );
  }
}
