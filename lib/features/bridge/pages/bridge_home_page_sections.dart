// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page_logic.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 路由展示区 + 底部操作按钮 mixin
mixin BridgeHomeSectionsMixin
    on ConsumerState<BridgeHomePage>, BridgeHomeLogicMixin {
  // ─── 路由对比区（全部路由）──────────────────────────────────────────────────

  Widget buildAllRoutesSection(BuildContext context, BridgeProvider provider) {
    final response = provider.quoteResponse!;

    if (!response.hasRoutes) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
        ),
        child: Center(
          child: Text(
            S.of(context).g_key_bridge_no_routes,
            style: TextStyle(color: AppColorTokens.of(context).textSubtitle),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_bridge_route,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.space4),
        ...response.routes.map((r) => _buildRouteCard(context, provider, r)),
      ],
    );
  }

  /// 单个路由卡片（支持选中高亮）
  Widget _buildRouteCard(
    BuildContext context,
    BridgeProvider provider,
    BridgeRoute route,
  ) {
    final isSelected = provider.selectedRoute?.id == route.id;
    final selectedColor = AppColorTokens.of(context).brand;

    // 标签优先级：RECOMMENDED > FASTEST > CHEAPEST
    String? tagLabel;
    Color tagColor = AppColorTokens.of(context).textTertiary;
    if (route.isRecommended) {
      tagLabel = S.of(context).g_key_bridge_recommended;
      tagColor = AppColorTokens.of(context).success;
    } else if (route.isFastest) {
      tagLabel = S.of(context).g_key_bridge_fastest;
      tagColor = AppColorTokens.of(context).warning;
    } else if (route.isCheapest) {
      tagLabel = S.of(context).g_key_bridge_cheapest;
      tagColor = AppColorTokens.of(context).info;
    }

    // 路由使用的协议名称（step 聚合）
    final protocols = route.steps.map((s) => s.toolName).toSet().join(' + ');

    final toDecimals = provider.toToken?.decimals ?? 18;
    final receiveAmt = formatAmount(route.toAmount, toDecimals);
    final minReceive = formatAmount(route.toAmountMin, toDecimals);
    final gasCost = route.gasCostUSD > 0
        ? '\$${route.gasCostUSD.toStringAsFixed(2)}'
        : '—';
    final minutes = (route.estimatedSeconds / 60).ceil();

    return GestureDetector(
      onTap: () => provider.selectRoute(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (route.steps.isNotEmpty &&
                    route.steps.first.toolLogoUri.isNotEmpty)
                  ClipRRect(
                    borderRadius: AppRadius.brSm,
                    child: Image.network(
                      route.steps.first.toolLogoUri,
                      width: ScreenUtil().setWidth(32),
                      height: ScreenUtil().setWidth(32),
                      errorBuilder: (ctx, err, stack) =>
                          Icon(Icons.link, size: ScreenUtil().setWidth(32)),
                    ),
                  )
                else
                  Icon(Icons.link, size: ScreenUtil().setWidth(32)),
                SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    protocols.isNotEmpty ? protocols : route.id,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (tagLabel != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space2,
                      vertical: AppSpacing.space2,
                    ),
                    decoration: BoxDecoration(
                      color: tagColor.withAlpha(30),
                      borderRadius: AppRadius.brSm,
                      border: Border.all(color: tagColor),
                    ),
                    child: Text(
                      tagLabel,
                      style: AppTypography.captionSm.copyWith(
                        color: tagColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isSelected)
                  Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
                    child: Icon(
                      Icons.check_circle,
                      color: selectedColor,
                      size: ScreenUtil().setWidth(32),
                    ),
                  ),
              ],
            ),

            SizedBox(height: AppSpacing.space4),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).g_key_bridge_estimated_receive,
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                      SizedBox(height: AppSpacing.space2),
                      Text(
                        '$receiveAmt ${provider.toToken?.symbol ?? ''}',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                      Text(
                        'Min: $minReceive ${provider.toToken?.symbol ?? ''}',
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _infoChip(
                      context,
                      Icons.local_gas_station_outlined,
                      gasCost,
                    ),
                    SizedBox(height: AppSpacing.space2),
                    _infoChip(context, Icons.access_time, '~$minutes min'),
                  ],
                ),
              ],
            ),

            if (route.steps.length > 1) ...[
              SizedBox(height: AppSpacing.space4),
              Wrap(
                spacing: ScreenUtil().setWidth(8),
                runSpacing: ScreenUtil().setWidth(4),
                children: route.steps.map((step) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space2,
                      vertical: AppSpacing.space2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorTokens.of(context).bgBase,
                      borderRadius: AppRadius.brSm,
                    ),
                    child: Text(
                      '${step.fromToken.symbol} → ${step.toToken.symbol} via ${step.toolName}',
                      style: AppTypography.captionSm.copyWith(
                        color: AppColorTokens.of(context).textSubtitle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: ScreenUtil().setWidth(26),
          color: AppColorTokens.of(context).textSubtitle,
        ),
        SizedBox(width: AppSpacing.space2),
        Text(
          text,
          style: AppTypography.caption.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
      ],
    );
  }

  // ─── 错误信息 ────────────────────────────────────────────────────────────────

  Widget buildErrorMessage(BuildContext context, BridgeProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.errorBgColor2.name,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColorTokens.of(context).danger,
            size: ScreenUtil().setWidth(40),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: AppTypography.bodySm.copyWith(
                color: AppColorTokens.of(context).danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 底部按钮 ────────────────────────────────────────────────────────────────

  Widget buildBottomButton(BuildContext context, BridgeProvider provider) {
    final isLoading =
        provider.state == BridgeState.loadingQuotes ||
        provider.state == BridgeState.executing;

    final canGetQuote =
        provider.fromChain != null &&
        provider.toChain != null &&
        provider.fromToken != null &&
        provider.toToken != null &&
        provider.fromAmount.isNotEmpty;

    final canExecute = provider.selectedRoute != null;

    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgBase,
        border: Border(
          top: BorderSide(color: AppColorTokens.of(context).border),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: ScreenUtil().setWidth(88),
        child: AppButton(
          label: isLoading
              ? '${S.of(context).g_key_106}...'
              : canExecute
              ? S.of(context).g_key_bridge_title
              : S.of(context).g_key_bridge_get_quote,
          loading: isLoading,
          onPressed: isLoading
              ? null
              : () =>
                    onButtonPressed(context, provider, canGetQuote, canExecute),
        ),
      ),
    );
  }
}
