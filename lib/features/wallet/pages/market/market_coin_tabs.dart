// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'market_page.dart';

class _TrendingTab extends StatelessWidget {
  final List<Map<String, dynamic>> coins;
  final bool loading;

  /// When true, [coins] come from N42 backend (watchlist-format fields).
  final bool isFallback;
  final List<String> watchlistSymbols;
  final Map<String, CoinPriceAlertConfig> priceAlerts;
  final ValueChanged<Map<String, dynamic>> onTap;
  final ValueChanged<String> onToggleWatchlist;
  final void Function(BuildContext ctx, Map<String, dynamic> coin) onSetAlert;
  final Future<void> Function() onRefresh;

  const _TrendingTab({
    required this.coins,
    required this.loading,
    this.isFallback = false,
    required this.watchlistSymbols,
    required this.priceAlerts,
    required this.onTap,
    required this.onToggleWatchlist,
    required this.onSetAlert,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (coins.isEmpty) {
      return _EmptyState(
        icon: Icons.trending_up_rounded,
        message: 'No trending data',
        onRefresh: onRefresh,
      );
    }

    // When using N42 fallback data, fields match _CoinSource.watchlist format.
    final source = isFallback ? _CoinSource.watchlist : _CoinSource.trending;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 116.w),
        itemCount: coins.length,
        itemBuilder: (_, i) {
          final coin = coins[i];
          final symbol = isFallback
              ? (coin['coin'] ?? '').toString().toLowerCase()
              : (coin['symbol'] ?? '').toString().toLowerCase();
          final coinId = isFallback
              ? (coin['coin_gecko_id']?.toString() ?? '')
              : (coin['id']?.toString() ?? '');
          return _CoinTile(
            coin: coin,
            source: source,
            inWatchlist: watchlistSymbols.contains(symbol),
            alertActive:
                priceAlerts.containsKey(coinId) &&
                (priceAlerts[coinId]?.enabled ?? false),
            onTap: () => onTap(coin),
            onToggleWatchlist: onToggleWatchlist,
            onSetAlert: onSetAlert,
          );
        },
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> results;
  final bool loading;
  final List<String> watchlistSymbols;
  final Map<String, CoinPriceAlertConfig> priceAlerts;
  final ValueChanged<String> onChanged;
  final ValueChanged<Map<String, dynamic>> onTap;
  final ValueChanged<String> onToggleWatchlist;
  final void Function(BuildContext ctx, Map<String, dynamic> coin) onSetAlert;

  const _SearchTab({
    required this.controller,
    required this.results,
    required this.loading,
    required this.watchlistSymbols,
    required this.priceAlerts,
    required this.onChanged,
    required this.onTap,
    required this.onToggleWatchlist,
    required this.onSetAlert,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColorTokens.of(context).textPrimary;
    final itemBgColor = AppColorTokens.of(context).bgSurface;
    final subColor = textColor.withAlpha(153);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12.w),
          child: TextField(
            key: const ValueKey<String>('market_search_input'),
            controller: controller,
            onChanged: onChanged,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: S.of(context).g_market_search_hint,
              hintStyle: AppTypography.caption.copyWith(
                color: subColor,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(Icons.search, color: subColor, size: 26.sp),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: subColor, size: 24.sp),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: itemBgColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (controller.text.trim().isEmpty) {
      return _EmptyState(icon: Icons.search, message: 'Search for a coin');
    }
    if (results.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_rounded,
        message: S.of(context).g_market_no_results,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 116.w),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final coin = results[i];
        final symbol = (coin['symbol'] ?? '').toString().toLowerCase();
        final coinId = coin['id']?.toString() ?? '';
        return _CoinTile(
          coin: coin,
          source: _CoinSource.search,
          inWatchlist: watchlistSymbols.contains(symbol),
          alertActive:
              priceAlerts.containsKey(coinId) &&
              (priceAlerts[coinId]?.enabled ?? false),
          onTap: () => onTap(coin),
          onToggleWatchlist: onToggleWatchlist,
          onSetAlert: onSetAlert,
        );
      },
    );
  }
}

class _WatchlistTab extends StatelessWidget {
  final List<Map<String, dynamic>> coins;
  final List<String> symbols;
  final bool loading;
  final Map<String, CoinPriceAlertConfig> priceAlerts;
  final ValueChanged<Map<String, dynamic>> onTap;
  final ValueChanged<String> onToggleWatchlist;
  final void Function(BuildContext ctx, Map<String, dynamic> coin) onSetAlert;
  final Future<void> Function() onRefresh;

  const _WatchlistTab({
    required this.coins,
    required this.symbols,
    required this.loading,
    required this.priceAlerts,
    required this.onTap,
    required this.onToggleWatchlist,
    required this.onSetAlert,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (symbols.isEmpty) {
      return _EmptyState(
        icon: Icons.star_outline_rounded,
        message: S.of(context).g_market_empty_watchlist,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 116.w),
        itemCount: coins.length,
        itemBuilder: (_, i) {
          final coin = coins[i];
          final symbol = (coin['coin'] ?? '').toString().toLowerCase();
          final coinId = coin['coin_gecko_id']?.toString() ?? '';
          return _CoinTile(
            coin: coin,
            source: _CoinSource.watchlist,
            inWatchlist: symbols.contains(symbol),
            alertActive:
                priceAlerts.containsKey(coinId) &&
                (priceAlerts[coinId]?.enabled ?? false),
            onTap: () => onTap(coin),
            onToggleWatchlist: onToggleWatchlist,
            onSetAlert: onSetAlert,
          );
        },
      ),
    );
  }
}
