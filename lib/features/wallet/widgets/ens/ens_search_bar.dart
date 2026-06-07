// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';

/// ENS 搜索输入栏
///
/// 包含输入框、.eth 后缀标签和名称格式校验提示
class EnsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final String searchQuery;
  final EnsRegistrationService ensService;

  const EnsSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.searchQuery,
    required this.ensService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputRow(context),
          if (searchQuery.isNotEmpty && !ensService.isValidEnsName(searchQuery))
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
              child: Text(
                S.of(context).g_key_ens_invalid_name,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgBase,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: focusNode.hasFocus
              ? AppColorTokens.of(context).brand
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: ScreenUtil().setWidth(16)),
          Icon(
            Icons.search,
            color: AppColorTokens.of(context).textSubtitle,
            size: ScreenUtil().setWidth(28),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppColorTokens.of(context).textPrimary,
              ),
              decoration: InputDecoration(
                hintText: S.of(context).g_key_ens_search_hint,
                hintStyle: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  color: AppColorTokens.of(context).textSubtitle,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(16),
                ),
              ),
            ),
          ),
          // .eth 后缀标签
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(12),
              vertical: ScreenUtil().setWidth(8),
            ),
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).brand.withAlpha(20),
              borderRadius: AppRadius.brSm,
            ),
            child: Text(
              '.eth',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppColorTokens.of(context).brand,
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
        ],
      ),
    );
  }
}
