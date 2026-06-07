// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_select_chain_page.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI 组件 mixin：链卡片、交换按钮、滑点选择器
mixin BridgeHomeWidgetsMixin
    on ConsumerState<BridgeHomePage>, BridgeHomeLogicMixin {
  // ─── 源/目标链卡片 ──────────────────────────────────────────────────────────

  Widget buildChainCard(
    BuildContext context,
    BridgeProvider provider, {
    required bool isFrom,
  }) {
    final chain = isFrom ? provider.fromChain : provider.toChain;
    final token = isFrom ? provider.fromToken : provider.toToken;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签 + 链选择器
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isFrom ? S.of(context).g_key_75 : S.of(context).g_key_38,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              ),
              _buildChainPicker(context, provider, chain, isFrom),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 代币选择 + 金额
          Row(
            children: [
              _buildTokenPicker(context, provider, chain, token, isFrom),
              SizedBox(width: ScreenUtil().setWidth(20)),
              Expanded(
                child: isFrom
                    ? TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setSp(40),
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.textFieldHintColor.name,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: provider.setFromAmount,
                      )
                    : Text(
                        provider.selectedRoute != null
                            ? formatAmount(
                                provider.selectedRoute!.toAmount,
                                provider.toToken?.decimals ?? 18,
                              )
                            : '0.0',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChainPicker(
    BuildContext context,
    BridgeProvider provider,
    BridgeChain? chain,
    bool isFrom,
  ) {
    return InkWell(
      borderRadius: AppRadius.brMd,
      onTap: () async {
        final selected = await Navigator.push<BridgeChain>(
          context,
          MaterialPageRoute(
            builder: (_) => BridgeSelectChainPage(
              chains: provider.chains,
              selectedChain: chain,
              excludeChain: isFrom ? provider.toChain : provider.fromChain,
            ),
          ),
        );
        if (selected != null) {
          if (isFrom) {
            provider.setFromChain(selected);
          } else {
            provider.setToChain(selected);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgBase,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chain?.logoUri.isNotEmpty == true)
              ClipRRect(
                borderRadius: AppRadius.brMd,
                child: Image.network(
                  chain!.logoUri,
                  width: ScreenUtil().setWidth(32),
                  height: ScreenUtil().setWidth(32),
                  errorBuilder: (ctx, err, stack) =>
                      Icon(Icons.circle, size: ScreenUtil().setWidth(32)),
                ),
              ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Flexible(
              child: Text(
                chain?.name ?? S.of(context).g_key_17,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(4)),
            Icon(
              Icons.keyboard_arrow_down,
              size: ScreenUtil().setWidth(32),
              color: AppColorTokens.of(context).textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenPicker(
    BuildContext context,
    BridgeProvider provider,
    BridgeChain? chain,
    BridgeToken? token,
    bool isFrom,
  ) {
    return InkWell(
      borderRadius: AppRadius.brMd,
      onTap: () async {
        if (chain == null) return;
        final tokens = provider.getTokensForChain(chain.chainId);
        if (tokens.isEmpty) return;
        final selected = await showTokenSelector(context, tokens, token);
        if (selected != null) {
          if (isFrom) {
            provider.setFromToken(selected);
          } else {
            provider.setToToken(selected);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(12),
        ),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgBase,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (token?.logoUri.isNotEmpty == true)
              ClipRRect(
                borderRadius: AppRadius.brMd,
                child: Image.network(
                  token!.logoUri,
                  width: ScreenUtil().setWidth(40),
                  height: ScreenUtil().setWidth(40),
                  errorBuilder: (ctx, err, stack) =>
                      Icon(Icons.token, size: ScreenUtil().setWidth(40)),
                ),
              ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Flexible(
              child: Text(
                token?.symbol ?? S.of(context).g_key_bridge_select,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  fontWeight: FontWeight.bold,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: ScreenUtil().setWidth(28),
              color: AppColorTokens.of(context).textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  // ─── 交换方向按钮 ────────────────────────────────────────────────────────────

  Widget buildSwapButton(BuildContext context, BridgeProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
        child: IconButton(
          onPressed: provider.state == BridgeState.idle
              ? () {
                  provider.swapChains();
                  amountController.clear();
                }
              : null,
          icon: Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).brand,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swap_vert,
              color: Colors.white,
              size: ScreenUtil().setWidth(40),
            ),
          ),
        ),
      ),
    );
  }

  // ─── 滑点选择器 ──────────────────────────────────────────────────────────────

  Widget buildSlippageSelector(BuildContext context, BridgeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_bridge_slippage,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Row(
          children: BridgeHomeLogicMixin.slippageOptions.map((pct) {
            final selected = (provider.slippage - pct).abs() < 0.001;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                child: GestureDetector(
                  onTap: () => provider.setSlippage(pct),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(14),
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainButtonBgColor.name,
                            )
                          : AppColorTokens.of(context).bgSurface,
                      borderRadius: AppRadius.brSm,
                      border: Border.all(
                        color: selected
                            ? AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainButtonBgColor.name,
                              )
                            : AppColorTokens.of(context).border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected
                            ? AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainButtonTextColor.name,
                              )
                            : AppColorTokens.of(context).textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
