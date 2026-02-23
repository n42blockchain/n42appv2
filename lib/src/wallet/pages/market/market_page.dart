// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/market/crypto_news_service.dart';
import 'package:n42_wallet/core/market/fear_greed_service.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/api/market_api.dart';
import 'package:n42_wallet/src/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/src/wallet/pages/market/price_alert_sheet.dart';
import 'package:n42_wallet/src/wallet/services/coin_price_alert_service.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/src/widgets/image_network.dart' show ImageNetWork;
import 'package:url_launcher/url_launcher.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Trending
  List<Map<String, dynamic>> _trending = [];
  bool _trendingLoading = false;

  // Search
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searchLoading = false;
  Timer? _debounce;

  // Watchlist
  List<String> _watchlistSymbols = [];
  List<Map<String, dynamic>> _watchlistCoins = [];
  bool _watchlistLoading = false;

  // Price alerts (coinId → config)
  Map<String, CoinPriceAlertConfig> _priceAlerts = {};

  // Price alert polling timer
  Timer? _alertCheckTimer;

  // Fear & Greed
  FearGreedData? _fearGreed;

  // News
  List<NewsArticle> _news = [];
  bool _newsLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTrending();
    _loadWatchlist();
    _loadAlerts();
    _startAlertPolling();
    _loadFearGreed();
    _loadNews();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    _alertCheckTimer?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {});
  }

  // ─── Fear & Greed + News loaders ────────────────────────────────────────

  Future<void> _loadFearGreed() async {
    final data = await FearGreedService.fetch();
    if (mounted && data != null) setState(() => _fearGreed = data);
  }

  Future<void> _loadNews() async {
    if (_newsLoading) return;
    if (mounted) setState(() => _newsLoading = true);
    final list = await CryptoNewsService.fetchLatest();
    if (mounted) setState(() { _news = list; _newsLoading = false; });
  }

  // ─── Price alert helpers ─────────────────────────────────────────────────

  Future<void> _loadAlerts() async {
    final alerts = await CoinPriceAlertService.loadAll();
    if (mounted) setState(() => _priceAlerts = alerts);
  }

  void _startAlertPolling() {
    // Immediate check + every 5 minutes while page is visible
    _checkPriceAlerts();
    _alertCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkPriceAlerts(),
    );
  }

  Future<void> _checkPriceAlerts() async {
    final configs = await CoinPriceAlertService.loadAll();
    if (configs.isEmpty) return;

    final enabledSymbols = configs.values
        .where((c) => c.enabled)
        .map((c) => c.symbol.toLowerCase())
        .toSet();
    if (enabledSymbols.isEmpty) return;

    final resp = await MarketApi().getWalletCoinsInfo(enabledSymbols.join(','));
    if (resp['error'] != false) return;

    final rawData = resp['data'];
    final coins = (rawData is Map ? rawData['data'] : null);
    if (coins is! List) return;

    final prices = <String, double>{};
    for (final c in coins) {
      if (c is! Map) continue;
      final sym = c['coin']?.toString().toLowerCase() ?? '';
      final v = c['price'];
      final price = (v is num)
          ? v.toDouble()
          : double.tryParse(v?.toString() ?? '') ?? 0.0;
      if (sym.isNotEmpty && price > 0) prices[sym] = price;
    }

    await CoinPriceAlertService.checkAndNotify(prices);
  }

  Future<void> _openAlertSheet(
    BuildContext ctx,
    String coinId,
    String symbol,
    String name,
    double currentPrice,
  ) async {
    final changed = await showPriceAlertSheet(
      context: ctx,
      coinId: coinId,
      symbol: symbol,
      name: name,
      currentPrice: currentPrice,
    );
    if (changed == true) await _loadAlerts();
  }

  // ─── Data loaders ───────────────────────────────────────────────────────────

  Future<void> _loadTrending() async {
    if (_trendingLoading) return;
    setState(() => _trendingLoading = true);
    final result = await MarketApi().getTrendingCoins();
    if (mounted) {
      setState(() {
        _trending = result;
        _trendingLoading = false;
      });
    }
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _searchLoading = true);
      final result = await MarketApi().searchCoins(q);
      if (mounted) {
        setState(() {
          _searchResults = result;
          _searchLoading = false;
        });
      }
    });
  }

  Future<void> _loadWatchlist() async {
    final symbols = await SPUtil().getMarketWatchlist();
    if (!mounted) return;
    setState(() {
      _watchlistSymbols = symbols;
      _watchlistLoading = symbols.isNotEmpty;
    });

    if (symbols.isNotEmpty) {
      final resp = await MarketApi().getWalletCoinsInfo(symbols.join(','));
      if (!mounted) return;
      final data = resp['data'];
      final coins =
          (data is List) ? data : (data is Map ? [data] : <dynamic>[]);
      setState(() {
        _watchlistCoins = coins
            .whereType<Map<dynamic, dynamic>>()
            .map((c) => Map<String, dynamic>.from(c))
            .toList();
        _watchlistLoading = false;
      });
    }
  }

  Future<void> _toggleWatchlist(String symbol) async {
    final lower = symbol.toLowerCase();
    final updated = List<String>.from(_watchlistSymbols);
    if (updated.contains(lower)) {
      updated.remove(lower);
    } else {
      updated.add(lower);
    }
    await SPUtil().saveMarketWatchlist(updated);
    setState(() => _watchlistSymbols = updated);
    await _loadWatchlist();
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void _navigateToDetail(Map<String, dynamic> coin, _CoinSource source) {
    final normalized = _normalize(coin, source);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MarketCoinInfo(normalized)),
    ).then((_) => _loadAlerts()); // refresh bell states on return
  }

  Map<String, dynamic> _normalize(
      Map<String, dynamic> coin, _CoinSource source) {
    switch (source) {
      case _CoinSource.trending:
        final priceStr = (coin['data']?['price'] ?? '')
            .toString()
            .replaceAll(r'$', '')
            .replaceAll(',', '');
        final price = double.tryParse(priceStr) ?? 0.0;
        final pct =
            coin['data']?['price_change_percentage_24h']?['usd'] ?? 0.0;
        return {
          'coin_gecko_id': coin['id'] ?? '',
          'coin': (coin['symbol'] ?? '').toString().toLowerCase(),
          'name': coin['name'] ?? '',
          'image': coin['large'] ?? coin['thumb'] ?? '',
          'price': price,
          'price_change_per_24h':
              pct is num ? pct.toDouble() : 0.0,
        };

      case _CoinSource.search:
        return {
          'coin_gecko_id': coin['id'] ?? '',
          'coin': (coin['symbol'] ?? '').toString().toLowerCase(),
          'name': coin['name'] ?? '',
          'image': coin['large'] ?? coin['thumb'] ?? '',
          'price': 0.0,
          'price_change_per_24h': 0.0,
        };

      case _CoinSource.watchlist:
        return {
          'coin_gecko_id': coin['coin_gecko_id'] ?? '',
          'coin': coin['coin'] ?? '',
          'name': coin['name'] ?? '',
          'image': coin['image'] ?? '',
          'price': (coin['price'] is num)
              ? (coin['price'] as num).toDouble()
              : double.tryParse(coin['price']?.toString() ?? '') ?? 0.0,
          'price_change_per_24h': (coin['price_change_per_24h'] is num)
              ? (coin['price_change_per_24h'] as num).toDouble()
              : double.tryParse(
                      coin['price_change_per_24h']?.toString() ?? '') ??
                  0.0,
        };
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bgColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.backGroundColor.name);
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final accentColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context, textColor, accentColor),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TrendingTab(
                  coins: _trending,
                  loading: _trendingLoading,
                  watchlistSymbols: _watchlistSymbols,
                  priceAlerts: _priceAlerts,
                  onTap: (c) => _navigateToDetail(c, _CoinSource.trending),
                  onToggleWatchlist: _toggleWatchlist,
                  onSetAlert: (ctx, c) {
                    final id = c['id']?.toString() ?? '';
                    final sym = (c['symbol'] ?? '').toString().toLowerCase();
                    final name = c['name']?.toString() ?? '';
                    final priceStr = (c['data']?['price'] ?? '')
                        .toString()
                        .replaceAll(r'$', '')
                        .replaceAll(',', '');
                    final price = double.tryParse(priceStr) ?? 0.0;
                    _openAlertSheet(ctx, id, sym, name, price);
                  },
                  onRefresh: _loadTrending,
                ),
                _SearchTab(
                  controller: _searchCtrl,
                  results: _searchResults,
                  loading: _searchLoading,
                  watchlistSymbols: _watchlistSymbols,
                  priceAlerts: _priceAlerts,
                  onChanged: _onSearchChanged,
                  onTap: (c) => _navigateToDetail(c, _CoinSource.search),
                  onToggleWatchlist: _toggleWatchlist,
                  onSetAlert: (ctx, c) {
                    final id = c['id']?.toString() ?? '';
                    final sym = (c['symbol'] ?? '').toString().toLowerCase();
                    final name = c['name']?.toString() ?? '';
                    _openAlertSheet(ctx, id, sym, name, 0.0);
                  },
                ),
                _WatchlistTab(
                  coins: _watchlistCoins,
                  symbols: _watchlistSymbols,
                  loading: _watchlistLoading,
                  priceAlerts: _priceAlerts,
                  onTap: (c) => _navigateToDetail(c, _CoinSource.watchlist),
                  onToggleWatchlist: _toggleWatchlist,
                  onSetAlert: (ctx, c) {
                    final id = c['coin_gecko_id']?.toString() ?? '';
                    final sym = (c['coin'] ?? '').toString().toLowerCase();
                    final name = c['name']?.toString() ?? '';
                    final v = c['price'];
                    final price = (v is num)
                        ? v.toDouble()
                        : double.tryParse(v?.toString() ?? '') ?? 0.0;
                    _openAlertSheet(ctx, id, sym, name, price);
                  },
                  onRefresh: _loadWatchlist,
                ),
                _NewsTab(
                  articles: _news,
                  loading: _newsLoading,
                  onRefresh: _loadNews,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, Color textColor, Color accentColor) {
    final itemBgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final dividerColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name);

    return Container(
      color: itemBgColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                Text(
                  'Markets',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          // Fear & Greed pill
          if (_fearGreed != null)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: _FearGreedBadge(data: _fearGreed!),
            ),
          TabBar(
            controller: _tabController,
            labelColor: accentColor,
            unselectedLabelColor: textColor.withAlpha(153),
            indicatorColor: accentColor,
            indicatorWeight: 2,
            dividerColor: dividerColor,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle:
                TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 26.sp),
            tabs: [
              Tab(text: S.of(context).g_market_trending),
              Tab(text: S.of(context).g_market_search),
              Tab(text: S.of(context).g_market_watchlist),
              Tab(text: S.of(context).g_market_news),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Source enum ─────────────────────────────────────────────────────────────

enum _CoinSource { trending, search, watchlist }

// ─── Shared coin tile ────────────────────────────────────────────────────────

class _CoinTile extends StatelessWidget {
  final Map<String, dynamic> coin;
  final _CoinSource source;
  final bool inWatchlist;
  final bool alertActive;
  final VoidCallback onTap;
  final ValueChanged<String> onToggleWatchlist;
  final void Function(BuildContext ctx, Map<String, dynamic> coin) onSetAlert;

  const _CoinTile({
    required this.coin,
    required this.source,
    required this.inWatchlist,
    required this.alertActive,
    required this.onTap,
    required this.onToggleWatchlist,
    required this.onSetAlert,
  });

  String get _coinId {
    switch (source) {
      case _CoinSource.trending:
      case _CoinSource.search:
        return coin['id']?.toString() ?? '';
      case _CoinSource.watchlist:
        return coin['coin_gecko_id']?.toString() ?? '';
    }
  }

  String get _symbol {
    switch (source) {
      case _CoinSource.trending:
      case _CoinSource.search:
        return (coin['symbol'] ?? '').toString().toLowerCase();
      case _CoinSource.watchlist:
        return (coin['coin'] ?? '').toString().toLowerCase();
    }
  }

  String get _name => (coin['name'] ?? '').toString();

  String get _imageUrl {
    switch (source) {
      case _CoinSource.trending:
      case _CoinSource.search:
        return coin['large'] ?? coin['thumb'] ?? '';
      case _CoinSource.watchlist:
        return coin['image'] ?? '';
    }
  }

  int? get _rank {
    final r = coin['market_cap_rank'];
    if (r == null) return null;
    if (r is int) return r;
    if (r is num) return r.toInt();
    return int.tryParse(r.toString());
  }

  double get _price {
    switch (source) {
      case _CoinSource.trending:
        final s = (coin['data']?['price'] ?? '')
            .toString()
            .replaceAll(r'$', '')
            .replaceAll(',', '');
        return double.tryParse(s) ?? 0.0;
      case _CoinSource.search:
        return 0.0;
      case _CoinSource.watchlist:
        final v = coin['price'];
        if (v is num) return v.toDouble();
        return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }
  }

  double get _pct24h {
    switch (source) {
      case _CoinSource.trending:
        final v =
            coin['data']?['price_change_percentage_24h']?['usd'];
        if (v is num) return v.toDouble();
        return double.tryParse(v?.toString() ?? '') ?? 0.0;
      case _CoinSource.search:
        return 0.0;
      case _CoinSource.watchlist:
        final v = coin['price_change_per_24h'];
        if (v is num) return v.toDouble();
        return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subColor = textColor.withAlpha(153);
    final dividerColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name);
    final isPositive = _pct24h >= 0;
    final pctColor =
        isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final showPrice = source != _CoinSource.search;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 88.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  // Coin icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: ImageNetWork(
                      imageUrl: _imageUrl,
                      width: 48.w,
                      height: 48.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Rank + name/symbol
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (_rank != null) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: dividerColor,
                                  borderRadius:
                                      BorderRadius.circular(3.r),
                                ),
                                child: Text(
                                  '#$_rank',
                                  style: TextStyle(
                                      fontSize: 18.sp, color: subColor),
                                ),
                              ),
                              SizedBox(width: 6.w),
                            ],
                            Flexible(
                              child: Text(
                                _name,
                                style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          _symbol.toUpperCase(),
                          style:
                              TextStyle(fontSize: 22.sp, color: subColor),
                        ),
                      ],
                    ),
                  ),
                  // Price / pct
                  if (showPrice) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _price > 0
                              ? '\$${_formatPrice(_price)}'
                              : '--',
                          style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w600,
                              color: textColor),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${isPositive ? '+' : ''}${_pct24h.toStringAsFixed(2)}%',
                          style:
                              TextStyle(fontSize: 22.sp, color: pctColor),
                        ),
                      ],
                    ),
                    SizedBox(width: 6.w),
                  ],
                  // Bell icon (price alert)
                  if (_coinId.isNotEmpty)
                    GestureDetector(
                      onTap: () => onSetAlert(context, coin),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(
                          alertActive
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          color: alertActive
                              ? AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainBlueColor.name)
                              : subColor,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  SizedBox(width: 2.w),
                  // Star (watchlist)
                  GestureDetector(
                    onTap: () => onToggleWatchlist(_symbol),
                    child: Icon(
                      inWatchlist
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: inWatchlist
                          ? const Color(0xFFFACC15)
                          : subColor,
                      size: 30.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
              height: 1,
              thickness: 0.5,
              color: dividerColor,
              indent: 68.w,
              endIndent: 0),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    return price
        .toStringAsPrecision(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

// ─── Trending Tab ────────────────────────────────────────────────────────────

class _TrendingTab extends StatelessWidget {
  final List<Map<String, dynamic>> coins;
  final bool loading;
  final List<String> watchlistSymbols;
  final Map<String, CoinPriceAlertConfig> priceAlerts;
  final ValueChanged<Map<String, dynamic>> onTap;
  final ValueChanged<String> onToggleWatchlist;
  final void Function(BuildContext ctx, Map<String, dynamic> coin) onSetAlert;
  final Future<void> Function() onRefresh;

  const _TrendingTab({
    required this.coins,
    required this.loading,
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
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: coins.length,
        itemBuilder: (_, i) {
          final coin = coins[i];
          final symbol =
              (coin['symbol'] ?? '').toString().toLowerCase();
          final coinId = coin['id']?.toString() ?? '';
          return _CoinTile(
            coin: coin,
            source: _CoinSource.trending,
            inWatchlist: watchlistSymbols.contains(symbol),
            alertActive: priceAlerts.containsKey(coinId) &&
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

// ─── Search Tab ──────────────────────────────────────────────────────────────

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
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final itemBgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final subColor = textColor.withAlpha(153);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12.w),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(color: textColor, fontSize: 26.sp),
            decoration: InputDecoration(
              hintText: S.of(context).g_market_search_hint,
              hintStyle: TextStyle(color: subColor, fontSize: 26.sp),
              prefixIcon:
                  Icon(Icons.search, color: subColor, size: 28.sp),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: subColor, size: 26.sp),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: itemBgColor,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w, vertical: 10.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
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
      return _EmptyState(
        icon: Icons.search,
        message: 'Search for a coin',
      );
    }
    if (results.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_rounded,
        message: S.of(context).g_market_no_results,
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final coin = results[i];
        final symbol =
            (coin['symbol'] ?? '').toString().toLowerCase();
        final coinId = coin['id']?.toString() ?? '';
        return _CoinTile(
          coin: coin,
          source: _CoinSource.search,
          inWatchlist: watchlistSymbols.contains(symbol),
          alertActive: priceAlerts.containsKey(coinId) &&
              (priceAlerts[coinId]?.enabled ?? false),
          onTap: () => onTap(coin),
          onToggleWatchlist: onToggleWatchlist,
          onSetAlert: onSetAlert,
        );
      },
    );
  }
}

// ─── Watchlist Tab ───────────────────────────────────────────────────────────

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
        itemCount: coins.length,
        itemBuilder: (_, i) {
          final coin = coins[i];
          final symbol =
              (coin['coin'] ?? '').toString().toLowerCase();
          final coinId = coin['coin_gecko_id']?.toString() ?? '';
          return _CoinTile(
            coin: coin,
            source: _CoinSource.watchlist,
            inWatchlist: symbols.contains(symbol),
            alertActive: priceAlerts.containsKey(coinId) &&
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

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Future<void> Function()? onRefresh;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final subColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainTextColor.name)
        .withAlpha(128);

    Widget body = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64.sp, color: subColor),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26.sp, color: subColor),
          ),
        ],
      ),
    );

    if (onRefresh != null) {
      body = RefreshIndicator(
        onRefresh: onRefresh!,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: body,
          ),
        ),
      );
    }

    return body;
  }
}

// ─── Fear & Greed Badge ───────────────────────────────────────────────────────

class _FearGreedBadge extends StatelessWidget {
  final FearGreedData data;
  const _FearGreedBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    final level = data.level;
    final color = Color(level.colorValue);
    final bgColor = color.withAlpha(26); // 10% opacity background

    return Row(
      children: [
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(level.emoji, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 4.w),
              Text(
                '${data.classification}  ${data.value}',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          'Fear & Greed',
          style: TextStyle(
            fontSize: 18.sp,
            color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name)
                .withAlpha(100),
          ),
        ),
      ],
    );
  }
}

// ─── News Tab ─────────────────────────────────────────────────────────────────

class _NewsTab extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool loading;
  final Future<void> Function() onRefresh;

  const _NewsTab({
    required this.articles,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (articles.isEmpty) {
      return _EmptyState(
        icon: Icons.newspaper_outlined,
        message: S.of(context).g_news_empty,
        onRefresh: onRefresh,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (_, i) => _NewsCard(article: articles[i]),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final textColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);
    final subColor = textColor.withAlpha(153);
    final dividerColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.dividerColor.name);

    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(article.url);
        if (uri != null &&
            (uri.isScheme('https') || uri.isScheme('http'))) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: article.imageUrl != null
                      ? ImageNetWork(
                          imageUrl: article.imageUrl!,
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 72.w,
                          height: 72.w,
                          color: dividerColor,
                          child: Icon(Icons.article_outlined,
                              color: subColor, size: 32.sp),
                        ),
                ),
                SizedBox(width: 12.w),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              article.sourceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20.sp, color: subColor),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 6.w),
                            child: Text('·',
                                style: TextStyle(
                                    fontSize: 20.sp, color: subColor)),
                          ),
                          Text(
                            article.timeAgo(),
                            style: TextStyle(
                                fontSize: 20.sp, color: subColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios,
                    size: 16.sp, color: subColor.withAlpha(128)),
              ],
            ),
          ),
          Divider(
              height: 1,
              thickness: 0.5,
              color: dividerColor,
              indent: 16.w,
              endIndent: 0),
        ],
      ),
    );
  }
}
