// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/market/crypto_news_service.dart';
import 'package:n42_wallet/core/market/fear_greed_service.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_price_format_utils.dart';
import 'package:n42_wallet/features/wallet/pages/market/price_alert_sheet.dart';
import 'package:n42_wallet/features/wallet/services/coin_price_alert_service.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/widgets/image_network.dart'
    show ImageNetWork;
import 'package:url_launcher/url_launcher.dart';

import 'market_search_utils.dart';

part 'market_shared_widgets.dart';
part 'market_coin_tabs.dart';
part 'market_news_tab.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key}) : _loadInitialData = true;

  @visibleForTesting
  const MarketPage.withoutInitialData({super.key}) : _loadInitialData = false;

  final bool _loadInitialData;

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Trending
  List<Map<String, dynamic>> _trending = [];
  bool _trendingLoading = false;
  bool _trendingIsFallback = false; // true when using N42 backend fallback

  // Search
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searchLoading = false;
  Timer? _debounce;
  int _searchGeneration = 0;
  String _activeSearchQuery = '';

  // Watchlist
  List<String> _watchlistSymbols = [];
  List<Map<String, dynamic>> _watchlistCoins = [];
  bool _watchlistLoading = false;
  int _watchlistGeneration = 0;

  // Price alerts (coinId → config)
  Map<String, CoinPriceAlertConfig> _priceAlerts = {};
  int _alertsGeneration = 0;

  // Price alert polling timer

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
    if (!widget._loadInitialData) return;
    _loadTrending();
    _loadWatchlist();
    _loadAlerts();
    // 价格提醒检查统一由 main.dart 全局 5 分钟循环负责——MarketPage 已
    // 恢复为常驻底部 tab(IndexedStack),若此处再起同周期轮询会造成
    // 行情请求翻倍 + 冷却读写竞态下同币重复弹通知(接线复审 P1)。
    // 页内仅保留 _loadAlerts 供铃铛 UI 状态。
    _loadFearGreed();
    _loadNews();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {});
  }

  // ─── Fear & Greed + News loaders ────────────────────────────────────────

  Future<void> _loadFearGreed() async {
    try {
      final data = await FearGreedService.fetch();
      if (mounted && data != null) {
        setState(() => _fearGreed = data);
      }
    } catch (e) {
      AppLogger.w('MarketPage', 'failed to load fear & greed: $e');
    }
  }

  Future<void> _loadNews() async {
    if (_newsLoading) return;
    if (mounted) setState(() => _newsLoading = true);
    try {
      final list = await CryptoNewsService.fetchLatest();
      if (mounted) {
        setState(() {
          _news = list;
          _newsLoading = false;
        });
      }
    } catch (e) {
      AppLogger.w('MarketPage', 'failed to load news: $e');
      if (mounted) {
        setState(() => _newsLoading = false);
      }
    }
  }

  // ─── Price alert helpers ─────────────────────────────────────────────────

  Future<void> _loadAlerts() async {
    final requestId = ++_alertsGeneration;
    try {
      final alerts = await CoinPriceAlertService.loadAll();
      if (mounted && requestId == _alertsGeneration) {
        setState(() => _priceAlerts = alerts);
      }
    } catch (e) {
      AppLogger.w('MarketPage', 'failed to load alerts: $e');
    }
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

  /// Parse a numeric price from a dynamic value (num or String).
  double _parsePrice(dynamic v) =>
      (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

  /// Parse the price from a trending coin's nested data structure.
  double _parseTrendingPrice(Map<String, dynamic> coin) =>
      double.tryParse(
        (coin['data']?['price'] ?? '')
            .toString()
            .replaceAll(r'$', '')
            .replaceAll(',', ''),
      ) ??
      0.0;

  // ─── Data loaders ───────────────────────────────────────────────────────────

  Future<void> _loadTrending() async {
    if (_trendingLoading) return;
    setState(() => _trendingLoading = true);
    try {
      final api = MarketApi();
      var result = await api.getTrendingCoins();
      var isFallback = false;

      if (result.isEmpty) {
        AppLogger.d(
          'MarketPage',
          'CoinGecko trending empty, trying N42 fallback',
        );
        result = await api.getFallbackTrendingCoins();
        isFallback = result.isNotEmpty;
      }

      if (mounted) {
        setState(() {
          _trending = result;
          _trendingIsFallback = isFallback;
          _trendingLoading = false;
        });
      }
    } catch (e) {
      AppLogger.w('MarketPage', 'failed to load trending: $e');
      if (mounted) {
        setState(() => _trendingLoading = false);
      }
    }
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    final query = q.trim();
    _activeSearchQuery = query;
    final requestId = ++_searchGeneration;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted ||
          !shouldApplyMarketSearchResponse(
            requestId: requestId,
            activeRequestId: _searchGeneration,
            requestQuery: query,
            activeQuery: _activeSearchQuery,
          )) {
        return;
      }
      setState(() => _searchLoading = true);
      try {
        final result = await MarketApi().searchCoins(query);
        if (mounted &&
            shouldApplyMarketSearchResponse(
              requestId: requestId,
              activeRequestId: _searchGeneration,
              requestQuery: query,
              activeQuery: _activeSearchQuery,
            )) {
          setState(() {
            _searchResults = result;
            _searchLoading = false;
          });
        }
      } catch (e) {
        AppLogger.w('MarketPage', 'failed to search coins: $e');
        if (mounted &&
            shouldApplyMarketSearchResponse(
              requestId: requestId,
              activeRequestId: _searchGeneration,
              requestQuery: query,
              activeQuery: _activeSearchQuery,
            )) {
          setState(() => _searchLoading = false);
        }
      }
    });
  }

  Future<void> _loadWatchlist() async {
    final requestId = ++_watchlistGeneration;
    try {
      final symbols = await SPUtil().getMarketWatchlist();
      if (!mounted || requestId != _watchlistGeneration) return;
      setState(() {
        _watchlistSymbols = symbols;
        _watchlistLoading = symbols.isNotEmpty;
        if (symbols.isEmpty) {
          _watchlistCoins = [];
        }
      });
      if (symbols.isEmpty) return;

      final resp = await MarketApi().getWalletCoinsInfo(symbols.join(','));
      if (!mounted || requestId != _watchlistGeneration) return;
      final coins = extractMarketCoinItems(resp['data']);
      setState(() {
        _watchlistCoins = coins;
        _watchlistLoading = false;
      });
    } catch (e) {
      AppLogger.w('MarketPage', 'failed to load watchlist: $e');
      if (!mounted || requestId != _watchlistGeneration) return;
      setState(() {
        _watchlistCoins = [];
        _watchlistLoading = false;
      });
    }
  }

  Future<void> _toggleWatchlist(String symbol) async {
    final lower = symbol.toLowerCase();
    if (lower.isEmpty) return;
    final updated = List<String>.from(_watchlistSymbols);
    if (updated.contains(lower)) {
      updated.remove(lower);
    } else {
      updated.add(lower);
    }
    final normalized = normalizeMarketWatchlistSymbols(updated);
    await SPUtil().saveMarketWatchlist(normalized);
    if (!mounted) return;
    setState(() => _watchlistSymbols = normalized);
    await _loadWatchlist();
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void _navigateToDetail(Map<String, dynamic> coin, _CoinSource source) {
    final normalized = _normalize(coin, source);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MarketCoinInfo(normalized)),
    ).then((_) {
      if (!mounted) return;
      _loadAlerts();
    }); // refresh bell states on return
  }

  Map<String, dynamic> _normalize(
    Map<String, dynamic> coin,
    _CoinSource source,
  ) {
    return switch (source) {
      _CoinSource.trending => {
        'coin_gecko_id': coin['id'] ?? '',
        'coin': (coin['symbol'] ?? '').toString().toLowerCase(),
        'name': coin['name'] ?? '',
        'image': coin['large'] ?? coin['thumb'] ?? '',
        'price': _parseTrendingPrice(coin),
        'price_change_per_24h': _parseTrendingPct(coin),
      },
      _CoinSource.search => {
        'coin_gecko_id': coin['id'] ?? '',
        'coin': (coin['symbol'] ?? '').toString().toLowerCase(),
        'name': coin['name'] ?? '',
        'image': coin['large'] ?? coin['thumb'] ?? '',
        'price': 0.0,
        'price_change_per_24h': 0.0,
      },
      _CoinSource.watchlist => {
        'coin_gecko_id': coin['coin_gecko_id'] ?? '',
        'coin': coin['coin'] ?? '',
        'name': coin['name'] ?? '',
        'image': coin['image'] ?? '',
        'price': _parsePrice(coin['price']),
        'price_change_per_24h': _parsePrice(coin['price_change_per_24h']),
      },
    };
  }

  double _parseTrendingPct(Map<String, dynamic> coin) {
    final pct = coin['data']?['price_change_percentage_24h']?['usd'] ?? 0.0;
    return pct is num ? pct.toDouble() : 0.0;
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColorTokens.of(context).bgBase;
    final textColor = AppColorTokens.of(context).textPrimary;
    final accentColor = AppColorTokens.of(context).brand;

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
                  isFallback: _trendingIsFallback,
                  watchlistSymbols: _watchlistSymbols,
                  priceAlerts: _priceAlerts,
                  onTap: (c) => _navigateToDetail(
                    c,
                    _trendingIsFallback
                        ? _CoinSource.watchlist
                        : _CoinSource.trending,
                  ),
                  onToggleWatchlist: _toggleWatchlist,
                  onSetAlert: (ctx, c) => _trendingIsFallback
                      ? _openAlertSheet(
                          ctx,
                          c['coin_gecko_id']?.toString() ?? '',
                          (c['coin'] ?? '').toString().toLowerCase(),
                          c['name']?.toString() ?? '',
                          _parsePrice(c['price']),
                        )
                      : _openAlertSheet(
                          ctx,
                          c['id']?.toString() ?? '',
                          (c['symbol'] ?? '').toString().toLowerCase(),
                          c['name']?.toString() ?? '',
                          _parseTrendingPrice(c),
                        ),
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
                  onSetAlert: (ctx, c) => _openAlertSheet(
                    ctx,
                    c['id']?.toString() ?? '',
                    (c['symbol'] ?? '').toString().toLowerCase(),
                    c['name']?.toString() ?? '',
                    0.0,
                  ),
                ),
                _WatchlistTab(
                  coins: _watchlistCoins,
                  symbols: _watchlistSymbols,
                  loading: _watchlistLoading,
                  priceAlerts: _priceAlerts,
                  onTap: (c) => _navigateToDetail(c, _CoinSource.watchlist),
                  onToggleWatchlist: _toggleWatchlist,
                  onSetAlert: (ctx, c) => _openAlertSheet(
                    ctx,
                    c['coin_gecko_id']?.toString() ?? '',
                    (c['coin'] ?? '').toString().toLowerCase(),
                    c['name']?.toString() ?? '',
                    _parsePrice(c['price']),
                  ),
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
    BuildContext context,
    Color textColor,
    Color accentColor,
  ) {
    final dividerColor = AppColorTokens.of(context).border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppHomeTopBar(
          // FittedBox 防标题+徽章在固定高顶栏内垂直溢出（宽屏/大字号下曾溢出 33px）
          titleChild: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Markets',
                  style: AppTypography.headline.copyWith(
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (_fearGreed != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: _FearGreedBadge(data: _fearGreed!),
                  ),
              ],
            ),
          ),
          onLeftImageClick: () {
            Scaffold.of(context).openDrawer();
          },
          onLeftImageUri: "assets/img/menu.png",
        ),
        /*Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Markets',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (_fearGreed != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: _FearGreedBadge(data: _fearGreed!),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),*/
        TabBar(
          controller: _tabController,
          labelColor: accentColor,
          unselectedLabelColor: textColor.withAlpha(130),
          indicatorColor: accentColor,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 2.5,
          dividerColor: dividerColor,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(text: S.of(context).g_market_trending),
            Tab(text: S.of(context).g_market_search),
            Tab(text: S.of(context).g_market_watchlist),
            Tab(text: S.of(context).g_market_news),
          ],
        ),
      ],
    );
  }
}

// ─── Source enum ─────────────────────────────────────────────────────────────

enum _CoinSource { trending, search, watchlist }
