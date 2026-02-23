import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/src/wallet/api/market_api.dart';
import 'package:n42appv2/src/wallet/models/portfolio_trade.dart';
import 'package:n42appv2/src/wallet/pages/market/price_alert_sheet.dart';
import 'package:n42appv2/src/wallet/pages/market/trade_entry_sheet.dart';
import 'package:n42appv2/src/wallet/services/coin_price_alert_service.dart';
import 'package:n42appv2/src/wallet/services/portfolio_trade_service.dart';
import 'package:n42appv2/src/wallet/widgets/about_show_dialog.dart';
import 'package:n42appv2/src/widgets/candlestick_chart.dart';
import 'package:n42appv2/src/widgets/image_network.dart';

// Period selector — both arrays must stay in sync (enforced by assert in initState).
const _periodLabels = ['1D', '7D', '1M', '3M', '1Y'];
const _periodDays   = [1, 7, 30, 90, 365];

class MarketCoinInfo extends ConsumerStatefulWidget {
  final Map<String, dynamic> coin;
  const MarketCoinInfo(this.coin, {super.key});

  @override
  ConsumerState<MarketCoinInfo> createState() => _MarketCoinInfoState();
}

class _MarketCoinInfoState extends ConsumerState<MarketCoinInfo> {
  // ─── formatters ────────────────────────────────────────────────────────────
  final _regular = Regular();

  /// 根据价格大小自动选择合适的小数位：>=$1000 两位，>=$1 四位，小于 $1 四位有效数字。
  String _fmtPrice(double price) {
    if (price <= 0) return '0.00';
    if (price >= 1000) return NumberFormat('#,##0.00', 'en_US').format(price);
    if (price >= 1)    return NumberFormat('#,##0.0000', 'en_US').format(price);
    // 小数：保留 4 位有效数字，去尾零
    final s = price.toStringAsPrecision(4);
    return double.tryParse(s)?.toString() ?? s;
  }

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
  int          _periodIndex = 0;
  List<OhlcPoint> _ohlcvData = [];
  List<double>    _volumeData = [];
  bool _chartLoading = false;
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
      _periodLabels.length == _periodDays.length,
      '_periodLabels and _periodDays must have the same length',
    );
    _coin = Map<String, dynamic>.from(widget.coin);
    _priceChange24h = _toDouble(_coin['price_change_per_24h']);
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
    final name = (_coin['name'] ?? '').toString().trim();
    final price = _toDouble(_coin['price']);

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
    final name = (_coin['name'] ?? '').toString().trim();
    final price = _toDouble(_coin['price']);

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
        _priceChange24h = _toDouble(_coin['price_change_per_24h']);
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
    final days = _periodDays[_periodIndex];

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
              .map((u) => _validateHttpUrl(u?.toString()))
              .whereType<String>()
              .firstOrNull ??
          '';
    }

    final rawBrowsers = links['blockchain_site'];
    if (rawBrowsers is List) {
      _browsers = rawBrowsers
          .map((b) => _validateHttpUrl(b?.toString()))
          .whereType<String>()
          .toList();
    }

    _reddit = _validateHttpUrl(links['subreddit_url']?.toString());

    final tt = links['twitter_screen_name']?.toString() ?? '';
    if (_isSafeUsername(tt)) _twitter = 'https://twitter.com/$tt';

    final fb = links['facebook_username']?.toString() ?? '';
    if (_isSafeUsername(fb)) _facebook = 'https://www.facebook.com/$fb';
  }

  void _cacheMarketMetrics() {
    _high24h        = _marketDouble('high_24h');
    _low24h         = _marketDouble('low_24h');
    _fdv            = _marketDouble('fully_diluted_valuation');
    _rank           = _toDouble(_marketData?['market_cap_rank']).toInt();
    _ath            = _marketDouble('ath');
    _atl            = _marketDouble('atl');
    _pct7d          = _toDouble(_marketData?['price_change_percentage_7d']);
    _pct30d         = _toDouble(_marketData?['price_change_percentage_30d']);
    _liquidityScore = _toDouble(_coinInfo?['liquidity_score']);

    // 将 market_data 里的市值/成交量/供应量回填到 _coin，供 _buildMarketStatsCard 使用
    final md = _marketData;
    if (md != null) {
      _coin['market_cap']          = _marketDouble('market_cap');
      _coin['volume_24h']          = _marketDouble('total_volume');
      _coin['total_supply']        = _toDouble(md['total_supply']);
      _coin['circulating_supply']  = _toDouble(md['circulating_supply']);

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
    if (node is Map) return _toDouble(node[currency]);
    return _toDouble(node);
  }

  // ─── formatting & theme helpers ────────────────────────────────────────────

  String _fmtPct(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

  Color _pctColor(double v, BuildContext ctx) => AppThemeUtils.getColorByKey(
        ctx,
        v >= 0
            ? AppThemeKeys.rightTextColor.name
            : AppThemeKeys.errorTextColor.name,
      );

  /// Converts an API value (num | String | null) to double without throwing.
  static double _toDouble(dynamic v, [double fallback = 0.0]) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  /// Returns [raw] only when it has an http/https scheme and a non-empty host.
  static String? _validateHttpUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.host.isEmpty) return null;
    if (!uri.isScheme('https') && !uri.isScheme('http')) return null;
    return raw;
  }

  /// Allows only characters valid in social-media usernames
  /// (alphanumeric, underscore, hyphen, dot) — prevents path traversal.
  static bool _isSafeUsername(String? u) =>
      u != null && u.isNotEmpty && RegExp(r'^[\w\-\.]+$').hasMatch(u);

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final coinId = (_coin['coin_gecko_id'] ?? '').toString().trim();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPriceSection(context),
                    if (_trades.isNotEmpty) _buildPnlCard(context),
                    _buildPeriodSelector(context),
                    _buildChartSection(context),
                    _buildMarketStatsCard(context),
                    if (_infoLoad == Load.finish && _coinInfo != null) ...[
                      _buildDepthDataCard(context),
                      _buildAboutSection(context),
                      _buildLinksSection(context),
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

  // ─── header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(100),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                width: ScreenUtil().setWidth(80),
                height: ScreenUtil().setWidth(80),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  size: ScreenUtil().setWidth(44),
                ),
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(80),
              height: ScreenUtil().setWidth(80),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                child: ImageNetWork(
                  imageUrl: _coin['image']?.toString() ?? '',
                  placeholder: 'assets/img/list.default.png',
                ),
              ),
            ),
            Text(
              (_coin['coin'] ?? '').toString().toUpperCase(),
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(36),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Expanded(
              child: Text(
                '(${_coin['name'] ?? ''})',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(20),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Price alert bell
            InkWell(
              onTap: _openAlertSheet,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                child: Icon(
                  (_alertConfig != null && _alertConfig!.enabled)
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: (_alertConfig != null && _alertConfig!.enabled)
                      ? AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name)
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                  size: ScreenUtil().setWidth(44),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── price section ─────────────────────────────────────────────────────────

  Widget _buildPriceSection(BuildContext context) {
    final isUp   = _priceChange24h >= 0;
    final price  = _toDouble(_coin['price']);
    final pctKey = isUp
        ? AppThemeKeys.rightTextColor.name
        : AppThemeKeys.errorTextColor.name;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '\$${_fmtPrice(price)}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(44),
                fontWeight: FontWeight.w700,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 2,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(16),
              vertical: ScreenUtil().setWidth(6),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, pctKey)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            ),
            child: Text(
              '${isUp ? '+' : ''}${_regular.formartNum(_priceChange24h, 2, isCrop: true)}%',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, pctKey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── portfolio P&L card ────────────────────────────────────────────────────

  Widget _buildPnlCard(BuildContext context) {
    final textColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);
    final subColor = textColor.withAlpha(153);
    final cardBg = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemBgColor.name);
    final accentColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final s = S.of(context);

    final summary = CoinPnlSummary(_trades);
    final currentPrice = _toDouble(_coin['price']);
    final pnlUsd = summary.pnlUsd(currentPrice);
    final pnlPct = summary.pnlPct(currentPrice);
    final isProfit = pnlUsd >= 0;
    final pnlColor =
        isProfit ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(8)),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  s.g_pnl_cost_basis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _openTradeSheet,
                  child: Icon(Icons.add_circle_outline,
                      color: accentColor, size: ScreenUtil().setSp(30)),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            // Stats row
            Row(
              children: [
                _pnlStat(
                  s.g_pnl_avg_cost,
                  '\$${_fmtPrice(summary.avgCost)}',
                  textColor,
                  subColor,
                ),
                SizedBox(width: ScreenUtil().setWidth(20)),
                _pnlStat(
                  s.g_pnl_quantity,
                  _fmtQty(summary.totalQty),
                  textColor,
                  subColor,
                ),
                SizedBox(width: ScreenUtil().setWidth(20)),
                _pnlStat(
                  s.g_pnl_unrealized,
                  '${isProfit ? '+' : ''}\$${_fmtPrice(pnlUsd.abs())}  '
                  '${isProfit ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
                  pnlColor,
                  subColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pnlStat(
      String label, String value, Color valueColor, Color labelColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(20), color: labelColor),
          ),
          SizedBox(height: ScreenUtil().setWidth(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _fmtQty(double v) {
    if (v == v.truncateToDouble()) return v.truncate().toString();
    return v.toStringAsFixed(v < 1 ? 6 : 4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // ─── period selector ───────────────────────────────────────────────────────

  Widget _buildPeriodSelector(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(16),
      ),
      child: Row(
        children: List.generate(_periodLabels.length, (i) {
          final selected = _periodIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onPeriodChanged(i),
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(4)),
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(12)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    selected
                        ? AppThemeKeys.mainButtonBgColor.name
                        : AppThemeKeys.itemBgColor.name,
                  ),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Text(
                  _periodLabels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? Colors.white
                        : AppThemeUtils.getColorByKey(context,
                            AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── chart section ─────────────────────────────────────────────────────────

  Widget _buildChartSection(BuildContext context) {
    final chartH = ScreenUtil().setWidth(360);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Container(
        height: chartH,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          child: _chartLoading
              ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 2))
              : _ohlcvData.isEmpty
                  ? _buildFallbackChart(context, chartH)
                  : CandlestickChart(
                      ohlcData: _ohlcvData,
                      volumeData: _volumeData,
                      height: chartH,
                      volumeHeightRatio: 0.22,
                    ),
        ),
      ),
    );
  }

  Widget _buildFallbackChart(BuildContext context, double height) {
    final prices = _fallbackPrices();
    if (prices.isEmpty) return _noChartData(context);

    const buckets = 40;
    final step = max(1, prices.length ~/ buckets);
    final ohlc = <OhlcPoint>[];
    for (int i = 0; i + step <= prices.length; i += step) {
      final slice = prices.sublist(i, i + step);
      final point = OhlcPoint(
        open: slice.first,
        close: slice.last,
        high: slice.reduce(max),
        low: slice.reduce(min),
      );
      if (point.isValid) ohlc.add(point);
    }
    if (ohlc.isEmpty) return _noChartData(context);

    return CandlestickChart(ohlcData: ohlc, height: height, volumeHeightRatio: 0);
  }

  List<double> _fallbackPrices() {
    final raw = _coin['kline_default'];
    if (raw is! List) return const [];
    return raw
        .map((v) => _toDouble(v))
        .where((v) => v.isFinite && v > 0)
        .toList();
  }

  Widget _noChartData(BuildContext context) => Center(
        child: Text(
          'No chart data', // TODO: i18n
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(24),
          ),
        ),
      );

  // ─── market stats card ─────────────────────────────────────────────────────

  Widget _buildMarketStatsCard(BuildContext context) {
    final symbol    = (_coin['coin'] ?? '').toString().toUpperCase();
    final marketCap = _toDouble(_coin['market_cap']);
    final volume24h = _toDouble(_coin['volume_24h']);
    final totalSup  = _toDouble(_coin['total_supply']);
    final circSup   = _toDouble(_coin['circulating_supply']);

    return _card(
      context,
      child: Column(
        children: _withDividers(context, [
          _statRow(context, S.of(context).g_key_m_2,
              '\$${_regular.getMoneyAbbreviation(marketCap)}'),
          _statRow(context, S.of(context).g_key_m_3,
              '\$${_regular.getMoneyAbbreviation(volume24h)}'),
          _statRow(context, S.of(context).g_key_m_4,
              '${_regular.getMoneyAbbreviation(totalSup)} $symbol'),
          _statRow(context, S.of(context).g_key_m_5,
              '${_regular.getMoneyAbbreviation(circSup)} $symbol'),
          if (_high24h > 0)
            _statRow(context, 'High 24H', // TODO: i18n
                '\$${_regular.formartNum(_high24h, 6, isCrop: true)}'),
          if (_low24h > 0)
            _statRow(context, 'Low 24H', // TODO: i18n
                '\$${_regular.formartNum(_low24h, 6, isCrop: true)}'),
          if (_fdv > 0)
            _statRow(context, 'FDV', // TODO: i18n
                '\$${_regular.getMoneyAbbreviation(_fdv)}'),
          if (_rank > 0)
            _statRow(context, 'Rank', '#$_rank'), // TODO: i18n
        ]),
      ),
    );
  }

  // ─── depth / liquidity card ────────────────────────────────────────────────

  Widget _buildDepthDataCard(BuildContext context) {
    final rows = <Widget>[
      if (_ath > 0)
        _statRow(context, 'ATH', // TODO: i18n
            '\$${_regular.formartNum(_ath, 6, isCrop: true)}'),
      if (_atl > 0)
        _statRow(context, 'ATL', // TODO: i18n
            '\$${_regular.formartNum(_atl, 6, isCrop: true)}'),
      if (_liquidityScore > 0)
        _statRow(context, 'Liquidity Score', // TODO: i18n
            _liquidityScore.toStringAsFixed(1)),
      if (_pct7d != 0)
        _statRowColored(context, '7D Change', _pct7d), // TODO: i18n
      if (_pct30d != 0)
        _statRowColored(context, '30D Change', _pct30d), // TODO: i18n
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return _card(
      context,
      title: 'Market Depth', // TODO: i18n
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _withDividers(context, rows),
      ),
    );
  }

  // ─── about section ─────────────────────────────────────────────────────────

  Widget _buildAboutSection(BuildContext context) {
    final descMap = _coinInfo?['description'];
    final desc    = (descMap is Map ? descMap[_lang]?.toString() : null) ?? '';
    if (desc.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(24),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, S.of(context).g_key_m_6),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Container(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
              top: ScreenUtil().setWidth(24),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            child: Column(
              children: [
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 6,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => aboutShowDialog(
                        context, desc, S.of(context).g_key_m_6),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(15),
                        horizontal: ScreenUtil().setWidth(30),
                      ),
                      margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(10)),
                      child: Text(
                        S.of(context).g_key_m_7,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.mainButtonBgColor.name),
                          fontSize: ScreenUtil().setSp(28),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── social links section ──────────────────────────────────────────────────

  Widget _buildLinksSection(BuildContext context) {
    final links = <_LinkItem>[
      if (_website.isNotEmpty)
        (icon: 'assets/img/webshit1.png', label: S.of(context).g_key_m_9,  url: _website),
      if (_facebook != null)
        (icon: 'assets/img/facebook.png', label: S.of(context).g_key_m_10, url: _facebook!),
      if (_twitter != null)
        (icon: 'assets/img/twitter.png',  label: S.of(context).g_key_m_11, url: _twitter!),
      if (_reddit != null)
        (icon: 'assets/img/reddit.png',   label: S.of(context).g_key_m_14, url: _reddit!),
    ];

    if (links.isEmpty && _browsers.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(24),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, S.of(context).g_key_m_8),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(10),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            child: Column(
              children: [
                ...links.map((item) => _buildLinkRow(context, item)),
                if (links.isNotEmpty && _browsers.isNotEmpty)
                  _divider(context),
                _buildBrowserRows(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(BuildContext context, _LinkItem item) {
    return InkWell(
      onTap: () => _openUrl(context, item.url),
      child: SizedBox(
        height: ScreenUtil().setWidth(85),
        child: Row(
          children: [
            Image.asset(
              item.icon,
              width: ScreenUtil().setWidth(40),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
            SizedBox(width: ScreenUtil().setWidth(30)),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(30),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowserRows(BuildContext context) {
    if (_browsers.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: ScreenUtil().setWidth(85),
          child: Row(
            children: [
              Image.asset(
                'assets/img/website.png',
                width: ScreenUtil().setWidth(40),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              SizedBox(width: ScreenUtil().setWidth(30)),
              Expanded(
                child: Text(
                  S.of(context).g_key_m_15,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
              ),
            ],
          ),
        ),
        ..._browsers.map(
          (url) => InkWell(
            onTap: () => _openUrl(context, url),
            child: SizedBox(
              height: ScreenUtil().setWidth(85),
              child: Row(
                children: [
                  SizedBox(width: ScreenUtil().setWidth(70)),
                  Expanded(
                    child: Text(
                      url,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(26),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: ScreenUtil().setWidth(30),
                    color: AppThemeUtils.getColorByKey(context,
                        AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openUrl(BuildContext context, String url) {
    if (kDebugMode) debugPrint('MarketCoinInfo: open $url');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrowserPage(url)),
    );
  }

  // ─── widget primitives ─────────────────────────────────────────────────────

  Widget _card(BuildContext context, {required Widget child, String? title}) {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(24),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(10),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: ScreenUtil().setWidth(10),
                    top: ScreenUtil().setWidth(6),
                  ),
                  child: _sectionTitle(context, title),
                ),
                child,
              ],
            )
          : child,
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
        title,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonBgColor.name),
          fontSize: ScreenUtil().setSp(30),
          fontWeight: FontWeight.w600,
        ),
      );

  /// Inserts a [_divider] between every adjacent pair of items.
  List<Widget> _withDividers(BuildContext context, List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) result.add(_divider(context));
      result.add(items[i]);
    }
    return result;
  }

  Widget _statRow(BuildContext context, String label, String value) {
    return SizedBox(
      height: ScreenUtil().setWidth(80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor.name),
                fontSize: ScreenUtil().setSp(28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRowColored(BuildContext context, String label, double pct) {
    return SizedBox(
      height: ScreenUtil().setWidth(80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          Text(
            _fmtPct(pct),
            style: TextStyle(
              color: _pctColor(pct, context),
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
        height: ScreenUtil().setWidth(1),
        thickness: 0.5,
        color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name)
            .withValues(alpha: 0.15),
      );
}

// Record type for social link list items — replaces the old class definition.
typedef _LinkItem = ({String icon, String label, String url});
