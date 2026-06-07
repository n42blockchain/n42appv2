// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// 高级操作区块（转移所有权等）
class EnsAdvancedSection extends StatelessWidget {
  final VoidCallback onTransfer;

  const EnsAdvancedSection({super.key, required this.onTransfer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_ens_advanced,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.swap_horiz, color: Colors.red),
            title: Text(S.of(context).g_key_ens_transfer),
            subtitle: Text(S.of(context).g_key_ens_transfer_desc),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTransfer,
          ),
        ],
      ),
    );
  }
}
