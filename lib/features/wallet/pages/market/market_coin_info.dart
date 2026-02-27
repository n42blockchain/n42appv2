import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/models/portfolio_trade.dart';
import 'package:n42_wallet/features/wallet/pages/market/price_alert_sheet.dart';
import 'package:n42_wallet/features/wallet/pages/market/trade_entry_sheet.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/services/coin_price_alert_service.dart';
import 'package:n42_wallet/features/wallet/services/portfolio_trade_service.dart';
import 'package:n42_wallet/features/widgets/candlestick_chart.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

import 'market_coin_info_chart.dart';
import 'market_coin_info_helpers.dart';
import 'market_coin_info_links.dart';
import 'market_coin_info_sections.dart';

class MarketCoinInfo extends ConsumerStatefulWidget {
  final Map<String, dynamic> coin;
  const MarketCoinInfo(this.coin, {super.key});

  @override
  ConsumerState<MarketCoinInfo> createState() => _MarketCoinInfoState();
}

class _MarketCoinInfoState extends ConsumerState<MarketCoinInfo> {
  // ─── formatters ────────────────────────────────────────────────────────────
  final _regular = Regular();

  // ─── live coin data ────────────────────────────────────────────────────────
  late Map<String, dynamic> _coin;
  double _priceChange24h = 0.0;

  // ─── gecko coin info ───────────────────────────────────────────────────────
  Map<String, dynamic>? _coinInfo;
  Load _infoLoad = Load.loading;

  // ─── social links (parsed once after info arrives) ─────────────────────────
  String       _website  = '';
  List<String> _browsers = [];
  String?      _reddit;
  String?      _twitter;
  String?      _facebook;
  final String _lang = 'en';

  // ─── cached market metrics ─────────────────────────────────────────────────
  double _high24h = 0, _low24h = 0, _fdv = 0;
  double _ath = 0, _atl = 0;
  double _pct7d = 0, _pct30d = 0, _liquidityScore = 0;
  int    _rank = 0;

  // ─── chart state ──────────────────────────────────────────────────────────
  int             _periodIndex = 0;
  List<OhlcPoint> _ohlcvData   = [];
  List<double>    _volumeData  = [];
  bool _chartLoading  = false;
  int  _chartGeneration = 0; // stale-response cancellation counter

  // ─── price alert state ────────────────────────────────────────────────────
  CoinPriceAlertConfig? _alertConfig;

  // ─── portfolio P&L state ──────────────────────────────────────────────────
  List<PortfolioTrade> _trades = [];

  // ─── lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    assert(
      periodLabels.length == periodDays.length,
      'periodLabels and periodDays must have the same length',
    );
    _coin = Map<String, dynamic>.from(widget.coin);
    _priceChange24h = toDouble(_coin['price_change_per_24h']);
    _fetchCoinPrice();
    _fetchCoinInfo();
    _loadAlertConfig();
    _loadTrades();
  }

  @override
  void dispose() {
    _chartGeneration++; // cancel any in-flight chart fetch
    super.dispose();
  }

  // ─── data fetching ─────────────────────────────────────────────────────────

  Future<void> _loadAlertConfig() async {
    final coinId = (_coin['coin_gecko_id'] ?? '').toString().trim();
    if (coinId.isEmpty) return;
    final all = await CoinPriceAlertService.loadAll();
    if (!mounted) return;
    setState(() => _alertConfig = all[coinId]);
  }

  Future<void> _loadTrades() async {
    final coinId = (_coin['coin_gecko_id'] ?? '').toString().trim();
    if (coinId.isEmpty) return;
    final list = await PortfolioTradeService.getTradesForCoin(coinId);
    if (!mounted) return;
    setState(() => _trades = list);
  }

  Future<void> _openTradeSheet() async {
    final coinId = (_coin['coin_gecko_id'] ?? '').toString().trim();
    final symbol = (_coin['coin'] ?? '').toString().trim();
    final name   = (_coin['name'] ?? '').toString().trim();
    final price  = toDouble(_coin['price']);

    final changed = await showTradeEntrySheet(
      context: context,
      coinId: coinId,
      symbol: symbol,
      name: name,
      currentPrice: price,
    );
    if (changed == true) await _loadTrades();
  }

  Future<void> _openAlertSheet() async {
    final coinId = (_coin['coin_gecko_id'] ?? '').toString().trim();
    final symbol = (_coin['coin'] ?? '').toString().trim();
    final name   = (_coin['name'] ?? '').toString().trim();
    final price  = toDouble(_coin['price']);

    final changed = await showPriceAlertSheet(
      context: context,
      coinId: coinId,
      symbol: symbol,
      name: name,
      currentPrice: price,
    );
    if (changed == true) await _loadAlertConfig();
  }

  Future<void> _fetchCoinPrice() async {
    final coinSymbol = (_coin['coin'] ?? '').toString().trim();
    if (coinSymbol.isEmpty) return;

    final result = await MarketApi().getWalletCoinsInfo(coinSymbol);
    if (result['error'] != false) return;

    final rawData = result['data'];
    final coins   = (rawData is Map ? rawData['data'] : null);
    if (coins is! List) return;

    for (final c in coins) {
      if (c is! Map || c['coin'] != coinSymbol) continue;
      if (!mounted) return;
      setState(() {
        _coin = Map<String, dynamic>.from(c);
        _priceChange24h = toDouble(_coin['price_change_per_24h']);
      });
      break;
    }
  }

  Future<void> _fetchCoinInfo() async {
    final geckoId = (_coin['coin_gecko_id'] ?? '').toString().trim();
    if (geckoId.isEmpty) {
      if (mounted) setState(() => _infoLoad = Load.error);
      return;
    }

    final info = await ref.read(wapBridgeProvider).getCoinsBaseInfo(geckoId);
    if (!mounted) return;

    if (info == null) {
      setState(() => _infoLoad = Load.error);
      return;
    }

    _coinInfo = info;
    _parseSocialLinks();
    _cacheMarketMetrics();
    setState(() => _infoLoad = Load.finish);
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    final geckoId = (_coin['coin_gecko_id'] ?? '').toString().trim();
    if (geckoId.isEmpty) return;

    final generation = ++_chartGeneration;
    if (mounted) setState(() => _chartLoading = true);

    final api  = MarketApi();
    final days = periodDays[_periodIndex];

    // Both futures start immediately and run concurrently.
    final ohlcFuture  = api.getOhlcvData(geckoId, days: days);
    final chartFuture = api.getMarketChart(geckoId, days: days);
    final ohlc  = await ohlcFuture;
    final chart = await chartFuture;

    if (!mounted || generation != _chartGeneration) return;

    setState(() {
      _ohlcvData    = ohlc;
      _volumeData   = chart['volumes'] ?? [];
      _chartLoading = false;
    });
  }

  void _onPeriodChanged(int index) {
    if (_periodIndex == index) return;
    setState(() {
      _periodIndex = index;
      _ohlcvData   = [];
      _volumeData  = [];
    });
    _fetchChartData();
  }

  // ─── data helpers ──────────────────────────────────────────────────────────

  void _parseSocialLinks() {
    final links = _coinInfo?['links'];
    if (links is! Map) return;

    final forumUrls = links['official_forum_url'];
    if (forumUrls is List) {
      _website = forumUrls
              .map((u) => validateHttpUrl(u?.toString()))
              .whereType<String>()
              .firstOrNull ??
          '';
    }

    final rawBrowsers = links['blockchain_site'];
    if (rawBrowsers is List) {
      _browsers = rawBrowsers
          .map((b) => validateHttpUrl(b?.toString()))
          .whereType<String>()
          .toList();
    }

    _reddit = validateHttpUrl(links['subreddit_url']?.toString());

    final tt = links['twitter_screen_name']?.toString() ?? '';
    if (isSafeUsername(tt)) _twitter = 'https://twitter.com/$tt';

    final fb = links['facebook_username']?.toString() ?? '';
    if (isSafeUsername(fb)) _facebook = 'https://www.facebook.com/$fb';
  }

  void _cacheMarketMetrics() {
    _high24h        = _marketDouble('high_24h');
    _low24h         = _marketDouble('low_24h');
    _fdv            = _marketDouble('fully_diluted_valuation');
    _rank           = toDouble(_marketData?['market_cap_rank']).toInt();
    _ath            = _marketDouble('ath');
    _atl            = _marketDouble('atl');
    _pct7d          = toDouble(_marketData?['price_change_percentage_7d']);
    _pct30d         = toDouble(_marketData?['price_change_percentage_30d']);
    _liquidityScore = toDouble(_coinInfo?['liquidity_score']);

    // 将 market_data 里的市值/成交量/供应量回填到 _coin，供市场统计卡使用
    final md = _marketData;
    if (md != null) {
      _coin['market_cap']         = _marketDouble('market_cap');
      _coin['volume_24h']         = _marketDouble('total_volume');
      _coin['total_supply']       = toDouble(md['total_supply']);
      _coin['circulating_supply'] = toDouble(md['circulating_supply']);

      // 提取 7 日 sparkline 作为图表兜底数据
      final sparkline = md['sparkline_7d'];
      if (sparkline is Map) {
        final prices = sparkline['price'];
        if (prices is List && prices.isNotEmpty) {
          _coin['kline_default'] = prices;
        }
      }
    }
  }

  /// Convenience accessor — avoids repeating the null + type guard everywhere.
  Map? get _marketData {
    final md = _coinInfo?['market_data'];
    return md is Map ? md : null;
  }

  /// Reads a market_data value that may be currency-indexed (`{usd: x}`)
  /// or a plain number.
  double _marketDouble(String key, [String currency = 'usd']) {
    final node = _marketData?[key];
    if (node is Map) return toDouble(node[currency]);
    return toDouble(node);
  }

  void _openUrl(BuildContext context, String url) {
    if (kDebugMode) debugPrint('MarketCoinInfo: open $url');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrowserPage(url)),
    );
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final coinId = (_coin['coin_gecko_id'] ?? '').toString().trim();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildCoinInfoHeader(
              context,
              coin: _coin,
              alertConfig: _alertConfig,
              onBack: () => Navigator.pop(context),
              onAlertTap: _openAlertSheet,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildCoinPriceSection(
                      context,
                      coin: _coin,
                      priceChange24h: _priceChange24h,
                      regular: _regular,
                    ),
                    if (_trades.isNotEmpty)
                      buildPnlCard(
                        context,
                        trades: _trades,
                        coin: _coin,
                        onAddTrade: _openTradeSheet,
                      ),
                    buildPeriodSelector(
                      context,
                      selectedIndex: _periodIndex,
                      onChanged: _onPeriodChanged,
                    ),
                    buildChartSection(
                      context,
                      chartLoading: _chartLoading,
                      ohlcvData: _ohlcvData,
                      volumeData: _volumeData,
                      coin: _coin,
                    ),
                    buildMarketStatsCard(
                      context,
                      coin: _coin,
                      high24h: _high24h,
                      low24h: _low24h,
                      fdv: _fdv,
                      rank: _rank,
                      regular: _regular,
                    ),
                    if (_infoLoad == Load.finish && _coinInfo != null) ...[
                      buildDepthDataCard(
                        context,
                        ath: _ath,
                        atl: _atl,
                        liquidityScore: _liquidityScore,
                        pct7d: _pct7d,
                        pct30d: _pct30d,
                        regular: _regular,
                      ),
                      buildAboutSection(
                        context,
                        coinInfo: _coinInfo,
                        lang: _lang,
                      ),
                      buildLinksSection(
                        context,
                        website: _website,
                        browsers: _browsers,
                        reddit: _reddit,
                        twitter: _twitter,
                        facebook: _facebook,
                        openUrl: _openUrl,
                      ),
                    ],
                    SizedBox(height: ScreenUtil().setWidth(80)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: coinId.isNotEmpty
          ? FloatingActionButton.small(
              onPressed: _openTradeSheet,
              tooltip: S.of(context).g_pnl_add_trade,
              backgroundColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
