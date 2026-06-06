import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';
import 'package:n42_wallet/features/wallet/models/portfolio_trade.dart';
import 'package:n42_wallet/features/wallet/pages/market/price_alert_sheet.dart';
import 'package:n42_wallet/features/wallet/pages/market/trade_entry_sheet.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/services/coin_price_alert_service.dart';
import 'package:n42_wallet/features/wallet/services/portfolio_trade_service.dart';
import 'package:n42_wallet/features/widgets/candlestick_chart.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
  final _regular = Regular();
  late Map<String, dynamic> _coin;
  double _priceChange24h = 0.0;
  Map<String, dynamic>? _coinInfo;
  Load _infoLoad = Load.loading;

  // Social links (parsed once after info arrives)
  String _website = '';
  List<String> _browsers = [];
  String? _reddit;
  String? _twitter;
  String? _facebook;
  final String _lang = 'en';

  // Cached market metrics
  double _high24h = 0, _low24h = 0, _fdv = 0;
  double _ath = 0, _atl = 0;
  double _pct7d = 0, _pct30d = 0, _liquidityScore = 0;
  int _rank = 0;

  // Chart state
  int _periodIndex = 0;
  List<OhlcPoint> _ohlcvData = [];
  List<double> _volumeData = [];
  bool _chartLoading = false;
  int _chartGeneration = 0;
  int _priceGeneration = 0;
  int _infoGeneration = 0;
  int _alertGeneration = 0;
  int _tradesGeneration = 0;

  CoinPriceAlertConfig? _alertConfig;
  List<PortfolioTrade> _trades = [];

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

  @override
  void didUpdateWidget(covariant MarketCoinInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldGeckoId = (oldWidget.coin['coin_gecko_id'] ?? '')
        .toString()
        .trim();
    final newGeckoId = (widget.coin['coin_gecko_id'] ?? '').toString().trim();
    final oldSymbol = (oldWidget.coin['coin'] ?? '').toString().trim();
    final newSymbol = (widget.coin['coin'] ?? '').toString().trim();
    if (oldGeckoId == newGeckoId && oldSymbol == newSymbol) return;

    _chartGeneration++;
    _coin = Map<String, dynamic>.from(widget.coin);
    _priceChange24h = toDouble(_coin['price_change_per_24h']);
    _coinInfo = null;
    _infoLoad = Load.loading;
    _website = '';
    _browsers = [];
    _reddit = null;
    _twitter = null;
    _facebook = null;
    _high24h = 0;
    _low24h = 0;
    _fdv = 0;
    _ath = 0;
    _atl = 0;
    _pct7d = 0;
    _pct30d = 0;
    _liquidityScore = 0;
    _rank = 0;
    _ohlcvData = [];
    _volumeData = [];
    _chartLoading = false;
    _alertConfig = null;
    _trades = [];

    setState(() {});
    _fetchCoinPrice();
    _fetchCoinInfo();
    _loadAlertConfig();
    _loadTrades();
  }

  String get _coinId => (_coin['coin_gecko_id'] ?? '').toString().trim();
  String get _coinSymbol => (_coin['coin'] ?? '').toString().trim();
  String get _coinName => (_coin['name'] ?? '').toString().trim();

  Future<void> _loadAlertConfig() async {
    final requestId = ++_alertGeneration;
    final coinId = _coinId;
    if (coinId.isEmpty) return;
    try {
      final all = await CoinPriceAlertService.loadAll();
      if (!mounted || requestId != _alertGeneration || _coinId != coinId) {
        return;
      }
      setState(() => _alertConfig = all[coinId]);
    } catch (e) {
      AppLogger.w('MarketCoinInfo', 'failed to load alert config: $e');
    }
  }

  Future<void> _loadTrades() async {
    final requestId = ++_tradesGeneration;
    final coinId = _coinId;
    if (coinId.isEmpty) return;
    try {
      final list = await PortfolioTradeService.getTradesForCoin(coinId);
      if (!mounted || requestId != _tradesGeneration || _coinId != coinId) {
        return;
      }
      setState(() => _trades = list);
    } catch (e) {
      AppLogger.w('MarketCoinInfo', 'failed to load trades: $e');
    }
  }

  Future<void> _openTradeSheet() async {
    final changed = await showTradeEntrySheet(
      context: context,
      coinId: _coinId,
      symbol: _coinSymbol,
      name: _coinName,
      currentPrice: toDouble(_coin['price']),
    );
    if (changed == true && mounted) await _loadTrades();
  }

  Future<void> _openAlertSheet() async {
    final changed = await showPriceAlertSheet(
      context: context,
      coinId: _coinId,
      symbol: _coinSymbol,
      name: _coinName,
      currentPrice: toDouble(_coin['price']),
    );
    if (changed == true && mounted) await _loadAlertConfig();
  }

  Future<void> _fetchCoinPrice() async {
    final requestId = ++_priceGeneration;
    final coinSymbol = _coinSymbol;
    if (coinSymbol.isEmpty) return;
    try {
      final result = await MarketApi().getWalletCoinsInfo(coinSymbol);
      if (!mounted ||
          requestId != _priceGeneration ||
          _coinSymbol != coinSymbol) {
        return;
      }
      if (result['error'] != false) return;

      final coins = extractMarketCoinItems(result['data']);
      if (coins.isEmpty) return;

      for (final c in coins) {
        if (!marketCoinMatchesSymbol(c, coinSymbol)) continue;
        setState(() {
          _coin = mergeMarketCoinSnapshot(_coin, c);
          _priceChange24h = toDouble(_coin['price_change_per_24h']);
        });
        break;
      }
    } catch (e) {
      AppLogger.w('MarketCoinInfo', 'failed to fetch coin price: $e');
    }
  }

  Future<void> _fetchCoinInfo() async {
    final requestId = ++_infoGeneration;
    final geckoId = _coinId;
    if (geckoId.isEmpty) {
      if (mounted) setState(() => _infoLoad = Load.error);
      return;
    }
    try {
      final info = await ref.read(wapBridgeProvider).getCoinsBaseInfo(geckoId);
      if (!mounted || requestId != _infoGeneration || _coinId != geckoId) {
        return;
      }

      if (info == null) {
        setState(() => _infoLoad = Load.error);
        return;
      }

      _coinInfo = info;
      _parseSocialLinks();
      _cacheMarketMetrics();
      setState(() => _infoLoad = Load.finish);
      _fetchChartData();
    } catch (e) {
      AppLogger.w('MarketCoinInfo', 'failed to fetch base info: $e');
      if (mounted) {
        setState(() => _infoLoad = Load.error);
      }
    }
  }

  Future<void> _fetchChartData() async {
    final geckoId = _coinId;
    if (geckoId.isEmpty) return;

    final generation = ++_chartGeneration;
    if (mounted) setState(() => _chartLoading = true);
    try {
      final api = MarketApi();
      final days = periodDays[_periodIndex];

      final results = await Future.wait([
        api.getOhlcvData(geckoId, days: days),
        api.getMarketChart(geckoId, days: days),
      ]);

      if (!mounted || generation != _chartGeneration) return;

      setState(() {
        _ohlcvData = results[0] as List<OhlcPoint>;
        _volumeData = (results[1] as Map<String, dynamic>)['volumes'] ?? [];
        _chartLoading = false;
      });
    } catch (e) {
      AppLogger.w('MarketCoinInfo', 'failed to fetch chart data: $e');
      if (!mounted || generation != _chartGeneration) return;
      setState(() => _chartLoading = false);
    }
  }

  void _onPeriodChanged(int index) {
    if (_periodIndex == index) return;
    setState(() {
      _periodIndex = index;
      _ohlcvData = [];
      _volumeData = [];
    });
    _fetchChartData();
  }

  void _parseSocialLinks() {
    final links = _coinInfo?['links'];
    if (links is! Map) return;

    _website = extractPrimaryWebsite(links);
    _browsers = extractValidatedHttpUrls(links['blockchain_site']);

    _reddit = validateHttpUrl(links['subreddit_url']?.toString());

    final tt = links['twitter_screen_name']?.toString() ?? '';
    if (isSafeUsername(tt)) _twitter = 'https://twitter.com/$tt';

    final fb = links['facebook_username']?.toString() ?? '';
    if (isSafeUsername(fb)) _facebook = 'https://www.facebook.com/$fb';
  }

  void _cacheMarketMetrics() {
    _high24h = _marketDouble('high_24h');
    _low24h = _marketDouble('low_24h');
    _fdv = _marketDouble('fully_diluted_valuation');
    _rank = toDouble(_marketData?['market_cap_rank']).toInt();
    _ath = _marketDouble('ath');
    _atl = _marketDouble('atl');
    _pct7d = toDouble(_marketData?['price_change_percentage_7d']);
    _pct30d = toDouble(_marketData?['price_change_percentage_30d']);
    _liquidityScore = toDouble(_coinInfo?['liquidity_score']);

    final md = _marketData;
    if (md != null) {
      _coin['market_cap'] = _marketDouble('market_cap');
      _coin['volume_24h'] = _marketDouble('total_volume');
      _coin['total_supply'] = toDouble(md['total_supply']);
      _coin['circulating_supply'] = toDouble(md['circulating_supply']);

      final sparkline = md['sparkline_7d'];
      if (sparkline is Map) {
        final prices = sparkline['price'];
        if (prices is List && prices.isNotEmpty) {
          _coin['kline_default'] = prices;
        }
      }
    }
  }

  Map? get _marketData {
    final md = _coinInfo?['market_data'];
    return md is Map ? md : null;
  }

  double _marketDouble(String key, [String currency = 'usd']) {
    final node = _marketData?[key];
    if (node is Map) return toDouble(node[currency]);
    return toDouble(node);
  }

  void _openUrl(BuildContext context, String url) {
    AppLogger.d('MarketCoinInfo', 'open $url');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrowserPage(url)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: _coinId.isNotEmpty
          ? FloatingActionButton.small(
              onPressed: _openTradeSheet,
              tooltip: S.of(context).g_pnl_add_trade,
              backgroundColor: AppColorTokens.of(context).brand,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
