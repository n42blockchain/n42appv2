import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/token_discovery/discovered_token.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/token_discovery/token_discovery_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_helpers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

class WalletCoinListSliver extends StatelessWidget {
  const WalletCoinListSliver({
    super.key,
    required this.waValue,
    required this.smallAssetsThreshold,
    required this.searchQuery,
    required this.discoveredTokens,
    required this.onDiscoveryDismiss,
    required this.onDiscoveryAdded,
    required this.onShowAllTap,
    required this.coinItemBuilder,
  });

  final WalletActionProvider waValue;
  final double smallAssetsThreshold;

  /// 搜索词以 listenable 传入：每个按键只重建下方列表，不惊动整页
  /// （行情、资产总览等 sliver 与搜索无关）。
  final ValueListenable<String> searchQuery;
  final List<DiscoveredToken> discoveredTokens;
  final VoidCallback onDiscoveryDismiss;
  final VoidCallback onDiscoveryAdded;
  final VoidCallback onShowAllTap;

  /// 由 State 提供，负责构建单个代币行 Widget
  final Widget Function(CoinModel coin, String key, String group)
  coinItemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, _) => ValueListenableBuilder<String>(
          valueListenable: searchQuery,
          builder: (context, query, _) => _CoinListBody(
            waValue: waValue,
            smallAssetsThreshold: smallAssetsThreshold,
            searchQuery: query,
            discoveredTokens: discoveredTokens,
            onDiscoveryDismiss: onDiscoveryDismiss,
            onDiscoveryAdded: onDiscoveryAdded,
            onShowAllTap: onShowAllTap,
            coinItemBuilder: coinItemBuilder,
          ),
        ),
        childCount: 1,
      ),
    );
  }
}

class _CoinListBody extends StatelessWidget {
  const _CoinListBody({
    required this.waValue,
    required this.smallAssetsThreshold,
    required this.searchQuery,
    required this.discoveredTokens,
    required this.onDiscoveryDismiss,
    required this.onDiscoveryAdded,
    required this.onShowAllTap,
    required this.coinItemBuilder,
  });

  final WalletActionProvider waValue;
  final double smallAssetsThreshold;
  final String searchQuery;
  final List<DiscoveredToken> discoveredTokens;
  final VoidCallback onDiscoveryDismiss;
  final VoidCallback onDiscoveryAdded;
  final VoidCallback onShowAllTap;
  final Widget Function(CoinModel coin, String key, String group)
  coinItemBuilder;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final bgColor = AppColorTokens.of(context).bgBase;
    final thresholdList = smallAssetsThreshold > 0
        ? waValue.coinList
              .where((c) => c.value >= smallAssetsThreshold)
              .toList()
        : waValue.coinList;
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final displayList = normalizedQuery.isEmpty
        ? thresholdList
        : thresholdList.where((coin) {
            final config = coin.config;
            return config.miniName.toLowerCase().contains(normalizedQuery) ||
                config.name.toLowerCase().contains(normalizedQuery) ||
                config.coinType.toLowerCase().contains(normalizedQuery) ||
                config.symbol.toLowerCase().contains(normalizedQuery);
          }).toList();
    final showSkeleton = waValue.coinList.isEmpty && waValue.buildwallet;

    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(color: bgColor),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      margin: EdgeInsets.only(bottom: AppSpacing.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (discoveredTokens.isNotEmpty)
            _DiscoveryBanner(
              count: discoveredTokens.length,
              discoveredTokens: discoveredTokens,
              onDismiss: onDiscoveryDismiss,
              onAdded: onDiscoveryAdded,
            ),
          if (waValue.loadBalance == Load.loading) _LoadingBanner(su: su),
          if (showSkeleton) const WalletCoinListSkeleton(),
          if (!showSkeleton && displayList.isEmpty)
            Container(
              height: su.setWidth(300.0),
              color: bgColor,
              child:
                  smallAssetsThreshold > 0 &&
                      waValue.coinList.isNotEmpty &&
                      normalizedQuery.isEmpty
                  ? _AllHiddenHint(onShowAll: onShowAllTap)
                  : _NoSearchResults(
                      hasSearchQuery: normalizedQuery.isNotEmpty,
                    ),
            ),
          if (!showSkeleton && displayList.isNotEmpty)
            _CoinListView(list: displayList, coinItemBuilder: coinItemBuilder),
        ],
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.hasSearchQuery});

  final bool hasSearchQuery;

  @override
  Widget build(BuildContext context) {
    if (!hasSearchQuery) return const EmptyView();
    final color = AppColorTokens.of(context).textSubtitle;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: color,
            size: ScreenUtil().setWidth(56),
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_market_no_results,
            style: AppTypography.body.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner({required this.su});

  final ScreenUtil su;

  @override
  Widget build(BuildContext context) {
    // warning 12% 色调底 + 同色字（AppBadge 风格）——此前 warning 实底白字
    // 亮色下对比 ≈2.2:1 不达 4.5:1（§2.6）。
    final warning = AppColorTokens.of(context).warning;
    return Container(
      width: double.infinity,
      height: su.setWidth(64.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: AppRadius.brSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_rounded, size: su.setWidth(28), color: warning),
          SizedBox(width: AppSpacing.space2),
          Text(
            S.of(context).g_key_208,
            style: AppTypography.caption.copyWith(color: warning),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryBanner extends StatelessWidget {
  const _DiscoveryBanner({
    required this.count,
    required this.discoveredTokens,
    required this.onDismiss,
    required this.onAdded,
  });

  final int count;
  final List<DiscoveredToken> discoveredTokens;
  final VoidCallback onDismiss;
  final VoidCallback onAdded;

  @override
  Widget build(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.space4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final added = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => TokenDiscoveryPage(tokens: discoveredTokens),
              ),
            );
            if (added == true) onAdded();
          },
          borderRadius: AppRadius.brMd,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space6,
              vertical: AppSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: blueColor.withValues(alpha: 0.10),
              borderRadius: AppRadius.brMd,
              border: Border.all(color: blueColor.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.manage_search_rounded,
                  color: blueColor,
                  size: ScreenUtil().setWidth(36),
                ),
                SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: Text(
                    S.of(context).g_key_token_discovery_banner(count),
                    style: AppTypography.bodySm.copyWith(
                      color: blueColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onDismiss,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    // >=88.w 命中区（44dp 触控红线）
                    width: ScreenUtil().setWidth(88),
                    height: ScreenUtil().setWidth(88),
                    child: Icon(
                      Icons.close_rounded,
                      color: blueColor.withValues(alpha: 0.70),
                      size: ScreenUtil().setWidth(32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinListView extends StatelessWidget {
  const _CoinListView({required this.list, required this.coinItemBuilder});

  final List<dynamic> list;
  final Widget Function(CoinModel coin, String key, String group)
  coinItemBuilder;

  @override
  Widget build(BuildContext context) {
    final pinnedCount = list
        .cast<CoinModel>()
        .takeWhile((c) => c.isPinned)
        .length;

    final needsDivider = pinnedCount > 0 && pinnedCount < list.length;
    final itemCount = list.length + (needsDivider ? 1 : 0);

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (needsDivider && index == pinnedCount) {
          return const _PinnedDivider();
        }
        final coinIndex = (needsDivider && index > pinnedCount)
            ? index - 1
            : index;
        return coinItemBuilder(
          list[coinIndex] as CoinModel,
          "c$coinIndex",
          "coin_list",
        );
      },
    );
  }
}

class _PinnedDivider extends StatelessWidget {
  const _PinnedDivider();

  @override
  Widget build(BuildContext context) {
    final color = AppColorTokens.of(context).border;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Row(
        children: [
          Expanded(child: Divider(height: 1, color: color)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Text(
              S.of(context).g_key_coin_list_separator,
              style: AppTypography.captionSm.copyWith(
                color: AppColorTokens.of(context).textTertiary,
              ),
            ),
          ),
          Expanded(child: Divider(height: 1, color: color)),
        ],
      ),
    );
  }
}

class _AllHiddenHint extends StatelessWidget {
  const _AllHiddenHint({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: ScreenUtil().setWidth(60),
            color: AppColorTokens.of(context).textSubtitle,
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_key_coin_list_all_hidden,
            style: AppTypography.body.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onShowAll,
              borderRadius: AppRadius.brSm,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: ScreenUtil().setWidth(88),
                  minWidth: ScreenUtil().setWidth(88),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                child: Text(
                  S.of(context).g_key_coin_list_show_all,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColorTokens.of(context).brand,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
