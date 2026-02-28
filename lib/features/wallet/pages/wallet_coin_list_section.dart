import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/token_discovery/discovered_token.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/token_discovery/token_discovery_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_helpers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

// ── 代币列表 Section ─────────────────────────────────────────────────────────

/// 代币列表主体（SliverList wrapper）
class WalletCoinListSliver extends StatelessWidget {
  const WalletCoinListSliver({
    super.key,
    required this.waValue,
    required this.smallAssetsThreshold,
    required this.discoveredTokens,
    required this.onDiscoveryDismiss,
    required this.onDiscoveryAdded,
    required this.onShowAllTap,
    required this.coinItemBuilder,
  });

  final WalletActionProvider waValue;
  final double smallAssetsThreshold;
  final List<DiscoveredToken> discoveredTokens;
  final VoidCallback onDiscoveryDismiss;
  final VoidCallback onDiscoveryAdded;
  final VoidCallback onShowAllTap;

  /// 由 State 提供，负责构建单个代币行 Widget
  final Widget Function(CoinModel coin, String key, String group) coinItemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, _) => _CoinListBody(
          waValue: waValue,
          smallAssetsThreshold: smallAssetsThreshold,
          discoveredTokens: discoveredTokens,
          onDiscoveryDismiss: onDiscoveryDismiss,
          onDiscoveryAdded: onDiscoveryAdded,
          onShowAllTap: onShowAllTap,
          coinItemBuilder: coinItemBuilder,
        ),
        childCount: 1,
      ),
    );
  }
}

// ── 代币列表主体 ─────────────────────────────────────────────────────────────

class _CoinListBody extends StatelessWidget {
  const _CoinListBody({
    required this.waValue,
    required this.smallAssetsThreshold,
    required this.discoveredTokens,
    required this.onDiscoveryDismiss,
    required this.onDiscoveryAdded,
    required this.onShowAllTap,
    required this.coinItemBuilder,
  });

  final WalletActionProvider waValue;
  final double smallAssetsThreshold;
  final List<DiscoveredToken> discoveredTokens;
  final VoidCallback onDiscoveryDismiss;
  final VoidCallback onDiscoveryAdded;
  final VoidCallback onShowAllTap;
  final Widget Function(CoinModel coin, String key, String group) coinItemBuilder;

  @override
  Widget build(BuildContext context) {
    final displayList = smallAssetsThreshold > 0
        ? waValue.coinList.where((c) => c.value >= smallAssetsThreshold).toList()
        : waValue.coinList;

    final showSkeleton = waValue.coinList.isEmpty && waValue.buildwallet;

    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.backGroundColor.name),
        border: Border.all(
          width: 2,
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
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
          if (waValue.loadBalance == Load.loading)
            Container(
              width: double.infinity,
              height: ScreenUtil().setWidth(60.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.textColorOrange.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                S.of(context).g_key_208,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainWhiteColor.name),
                ),
              ),
            ),
          if (showSkeleton) const WalletCoinListSkeleton(),
          if (!showSkeleton && displayList.isEmpty)
            Container(
              height: ScreenUtil().setWidth(300.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name),
              child: smallAssetsThreshold > 0 && waValue.coinList.isNotEmpty
                  ? _AllHiddenHint(onShowAll: onShowAllTap)
                  : const EmptyView(),
            ),
          if (!showSkeleton && displayList.isNotEmpty)
            _CoinListView(
              list: displayList,
              coinItemBuilder: coinItemBuilder,
            ),
        ],
      ),
    );
  }
}

// ── Token Discovery Banner ───────────────────────────────────────────────────

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
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    return GestureDetector(
      onTap: () async {
        final added = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => TokenDiscoveryPage(tokens: discoveredTokens),
          ),
        );
        if (added == true) onAdded();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(24),
          vertical: ScreenUtil().setWidth(14),
        ),
        decoration: BoxDecoration(
          color: blueColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(color: blueColor.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Icon(Icons.manage_search_rounded,
                color: blueColor, size: ScreenUtil().setWidth(36)),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: Text(
                S.of(context).g_key_token_discovery_banner(count),
                style: TextStyle(
                  color: blueColor,
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                child: Icon(
                  Icons.close_rounded,
                  color: blueColor.withValues(alpha: 0.70),
                  size: ScreenUtil().setWidth(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 代币列表 ListView（含置顶分隔行）───────────────────────────────────────

class _CoinListView extends StatelessWidget {
  const _CoinListView({
    required this.list,
    required this.coinItemBuilder,
  });

  final List<dynamic> list;
  final Widget Function(CoinModel coin, String key, String group) coinItemBuilder;

  @override
  Widget build(BuildContext context) {
    final pinnedCount = list.cast<CoinModel>().takeWhile((c) => c.isPinned).length;

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
        final coinIndex =
            (needsDivider && index > pinnedCount) ? index - 1 : index;
        return coinItemBuilder(
            list[coinIndex] as CoinModel, "c$coinIndex", "coin_list");
      },
    );
  }
}

// ── 置顶 / 普通分隔行 ────────────────────────────────────────────────────────

class _PinnedDivider extends StatelessWidget {
  const _PinnedDivider();

  @override
  Widget build(BuildContext context) {
    final color =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(4)),
      child: Row(
        children: [
          Expanded(child: Divider(height: 1, color: color)),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12)),
            child: Text(
              S.of(context).g_key_coin_list_separator,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name)
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(child: Divider(height: 1, color: color)),
        ],
      ),
    );
  }
}

// ── 全部资产被隐藏提示 ────────────────────────────────────────────────────────

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
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_coin_list_all_hidden,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          GestureDetector(
            onTap: onShowAll,
            child: Text(
              S.of(context).g_key_coin_list_show_all,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
