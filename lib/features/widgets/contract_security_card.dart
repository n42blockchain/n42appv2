// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/security/goplus_security_result.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// GoPlus 合约安全评分卡片
///
/// 三种状态：
/// - [ContractSecurityCard.loading]     — 正在查询
/// - [ContractSecurityCard.result]      — 显示安全等级 + 风险标签
/// - [ContractSecurityCard.unavailable] — 隐藏（不阻断操作）
class ContractSecurityCard extends StatelessWidget {
  final _State _state;
  final GoplusSecurityResult? _result;

  const ContractSecurityCard.loading({super.key})
      : _state = _State.loading,
        _result = null;

  const ContractSecurityCard.result({
    super.key,
    required GoplusSecurityResult result,
  })  : _state = _State.result,
        _result = result;

  const ContractSecurityCard.unavailable({super.key})
      : _state = _State.unavailable,
        _result = null;

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _State.loading:
        return _buildLoading(context);
      case _State.result:
        return _buildResult(context, _result!);
      case _State.unavailable:
        return const SizedBox.shrink();
    }
  }

  // ── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoading(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(12),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(18),
            height: ScreenUtil().setWidth(18),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Flexible(
            child: Text(
              S.of(context).g_key_security_goplus_checking,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Result ───────────────────────────────────────────────────────────────
  Widget _buildResult(BuildContext context, GoplusSecurityResult result) {
    final level = result.overallLevel;

    final Color color;
    final IconData icon;
    final String title;

    switch (level) {
      case GoplusRiskLevel.safe:
        color = const Color(0xFF4CAF50);
        icon = Icons.verified_outlined;
        title = S.of(context).g_key_security_goplus_safe;
        break;
      case GoplusRiskLevel.caution:
        color = const Color(0xFFFFA726);
        icon = Icons.warning_amber_outlined;
        title = S.of(context).g_key_security_goplus_caution;
        break;
      case GoplusRiskLevel.danger:
        color = const Color(0xFFEF5350);
        icon = Icons.dangerous_outlined;
        title = S.of(context).g_key_security_goplus_danger;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(12),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: ScreenUtil().setWidth(20), color: color),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  S.of(context).g_key_security_goplus_powered_by,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ],
          ),
          if (result.risks.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Wrap(
              spacing: ScreenUtil().setWidth(6),
              runSpacing: ScreenUtil().setWidth(4),
              children: result.risks
                  .take(5)
                  .map((r) => _buildRiskChip(r))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskChip(GoplusRisk risk) {
    final color = risk.level == GoplusRiskLevel.danger
        ? const Color(0xFFEF5350)
        : const Color(0xFFFFA726);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        risk.label,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum _State { loading, result, unavailable }
