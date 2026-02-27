// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/earn/provider/earn_provider.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/earn/pages/earn_page.dart';

/// 业务逻辑 mixin：状态加载、导航、工具方法
mixin EarnPageLogicMixin on ConsumerState<EarnPage> {
  void loadStakedData() {
    final wap = ref.read(wapBridgeProvider);
    String? ethAddr, solAddr, atomAddr;
    double ethPrice = 0.0, solPrice = 0.0, atomPrice = 0.0;
    for (final cm in wap.coinList) {
      final coinType = cm.coin['coinType'] as String? ?? '';
      final addr = cm.address?.toString() ?? '';
      if (addr.isEmpty) continue;
      if (coinType == 'ETH' && ethAddr == null) {
        ethAddr = addr;
        ethPrice = cm.coinPrice ?? 0.0;
      }
      if (coinType == 'SOL' && solAddr == null) {
        solAddr = addr;
        solPrice = cm.coinPrice ?? 0.0;
      }
      if (coinType == 'ATOM' && atomAddr == null) {
        atomAddr = addr;
        atomPrice = cm.coinPrice ?? 0.0;
      }
    }
    ref.read(earnProvider.notifier).updateCoinPrices(
      ethPrice: ethPrice,
      solPrice: solPrice,
      atomPrice: atomPrice,
    );
    ref.read(earnProvider.notifier).loadPositions(
      ethAddress: ethAddr,
      solAddress: solAddr,
      atomAddress: atomAddr,
    );
  }

  String get walletAddress {
    final wap = ref.read(wapBridgeProvider);
    return wap.coinList.isNotEmpty
        ? wap.coinList.first.address?.toString() ?? ''
        : '';
  }

  /// Swap 导航：底部弹出选择"买 N"
  void navigateToSwap(BuildContext context) {
    final s = S.of(context);
    sheetBottom(
      context,
      s.g_key_earn_select_swap,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _swapOptionTile(
            context,
            icon: Icons.currency_exchange,
            title: s.g_key_earn_buy_n,
            subtitle: s.g_key_earn_buy_n_desc,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SwapAstHome()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _swapOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: ScreenUtil().setWidth(48),
        height: ScreenUtil().setWidth(48),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name)
              .withAlpha(25),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Icon(
          icon,
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainBlueColor.name),
          size: ScreenUtil().setWidth(26),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.w600,
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemSubtitleTextColor.name),
      ),
      onTap: onTap,
    );
  }

  void showBurnNftTip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.local_fire_department_rounded,
                color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.of(context).g_key_burn_nft_title,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          '${S.of(context).g_key_burn_nft_tip}\n\n'
          '${S.of(context).g_key_burn_nft_steps}\n'
          '${S.of(context).g_key_burn_nft_step1}\n'
          '${S.of(context).g_key_burn_nft_step2}\n'
          '${S.of(context).g_key_burn_nft_step3}\n'
          '${S.of(context).g_key_burn_nft_step4}',
          style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context).g_key_burn_got_it,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 工具方法 ────────────────────────────────────────────────────────────────

  Color chainColor(StakingChainType chainType) {
    switch (chainType) {
      case StakingChainType.ethereum:
        return const Color(0xFF627EEA);
      case StakingChainType.solana:
        return const Color(0xFF9945FF);
      case StakingChainType.cosmos:
        return const Color(0xFF2E3148);
      case StakingChainType.polkadot:
        return const Color(0xFFE6007A);
    }
  }

  /// 将最小单位 BigInt 按链精度换算，格式化为可读字符串（最多 6 位有效小数）
  String formatBigIntForChain(
      BigInt raw, StakingChainType chainType, String symbol) {
    if (raw == BigInt.zero) return '0 $symbol';
    final amount = EarnState.tokenAmount(raw, chainType);
    final formatted = amount
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return '$formatted $symbol';
  }

  /// 根据链类型返回实时 APY（apyLoading 时降级到默认值）
  double liveApy(EarnState earnState, StakingChainType chainType) {
    switch (chainType) {
      case StakingChainType.ethereum:
        return earnState.ethApy;
      case StakingChainType.solana:
        return earnState.solApy;
      case StakingChainType.cosmos:
        return earnState.atomApy;
      case StakingChainType.polkadot:
        return 0.0;
    }
  }
}
