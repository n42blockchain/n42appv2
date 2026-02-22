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
import 'package:n42appv2/src/wallet/widgets/about_show_dialog.dart';
import 'package:n42appv2/src/widgets/candlestick_chart.dart';
import 'package:n42appv2/src/widgets/image_network.dart';

// ---------------------------------------------------------------------------
// Period tabs
// [FIX M4] Both arrays are defined together so it is immediately obvious if
// they ever fall out of sync. An assert in initState enforces equal length.
// ---------------------------------------------------------------------------
const _periodLabels = ['1D', '7D', '1M', '3M', '1Y'];
const _periodDays = [1, 7, 30, 90, 365];

class MarketCoinInfo extends ConsumerStatefulWidget {
  final Map<String, dynamic> coin;
  const MarketCoinInfo(this.coin, {super.key});

  @override
  ConsumerState<MarketCoinInfo> createState() => _MarketCoinInfoState();
}

class _MarketCoinInfoState extends ConsumerState<MarketCoinInfo> {
  // ─── formatters ────────────────────────────────────────────────────────────
  final oCcy = NumberFormat('#,##0.00########', 'en_US');
  final Regular _regular = Regular();

  // ─── live coin data ────────────────────────────────────────────────────────
  late Map<String, dynamic> _coin;
  double _priceChange24h = 0.0;

  // ─── gecko coin info ────────────────────────────────────────────────────────
  Map<String, dynamic>? _coinInfo;
  Load _infoLoad = Load.loading;

  // ─── social links (parsed once, immutable after that) ───────────────────────
  String _website = '';
  List<String> _browsers = [];   // [FIX S2] Now typed List<String> validated URLs only.
  String? _reddit;
  String? _twitter;
  String? _facebook;
  final String _lang = 'en';

  // ─── cached market metrics (avoid recomputing on every build) ──────────────
  // [FIX P2] Computed once when coinInfo arrives.
  double _high24h = 0;
  double _low24h = 0;
  double _fdv = 0;
  int _rank = 0;
  double _ath = 0;
  double _atl = 0;
  double _pct7d = 0;
  double _pct30d = 0;
  double _liquidityScore = 0;

  // ─── chart state ────────────────────────────────────────────────────────────
  int _periodIndex = 0;
  List<OhlcPoint> _ohlcvData = [];
  List<double> _volumeData = [];
  bool _chartLoading = false;

  // [FIX C3] Generation counter: each _fetchChartData call captures its own
  // generation; stale (superseded) responses are silently discarded.
  int _chartGeneration = 0;

  // ─── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // [FIX M4] Fail fast in debug builds if period arrays get out of sync.
    assert(
      _periodLabels.length == _periodDays.length,
      '_periodLabels and _periodDays must have the same length',
    );

    _coin = Map<String, dynamic>.from(widget.coin);
    _priceChange24h = _toDouble(_coin['price_change_per_24h']);
    _fetchCoinPrice();
    _fetchCoinInfo();
  }

  @override
  void dispose() {
    // [FIX M2] Invalidate any in-flight chart fetches.
    _chartGeneration++;
    super.dispose();
  }

  // ─── data fetching ──────────────────────────────────────────────────────────

  /// Refresh live price from market API.
  Future<void> _fetchCoinPrice() async {
    final coinSymbol = (_coin['coin'] ?? '').toString().trim();
    if (coinSymbol.isEmpty) return;

    final result = await MarketApi().getWalletCoinsInfo(coinSymbol);
    if (result['error'] != false) return;

    // [FIX C2] Use `is` check instead of force-cast for the API list.
    final rawData = result['data'];
    final coins = (rawData is Map ? rawData['data'] : null);
    if (coins is! List) return;

    for (final c in coins) {
      // [FIX C1] Guard against non-Map items before building from them.
      if (c is! Map) continue;
      if (c['coin'] != coinSymbol) continue;
      if (!mounted) return;
      setState(() {
        _coin = Map<String, dynamic>.from(c);
        _priceChange24h = _toDouble(_coin['price_change_per_24h']);
      });
      break;
    }
  }

  /// Load detail from N42 market API (proxies CoinGecko coin info).
  Future<void> _fetchCoinInfo() async {
    // [FIX C4] Do not call the API when geckoId is absent.
    final geckoId = (_coin['coin_gecko_id'] ?? '').toString().trim();
    if (geckoId.isEmpty) {
      if (mounted) setState(() => _infoLoad = Load.error);
      return;
    }

    final info =
        await ref.read(wapBridgeProvider).getCoinsBaseInfo(geckoId);
    if (!mounted) return;

    if (info == null) {
      setState(() => _infoLoad = Load.error);
    } else {
      _coinInfo = info;
      _parseSocialLinks();
      _cacheMarketMetrics();          // [FIX P2]
      setState(() => _infoLoad = Load.finish);
      _fetchChartData();
    }
  }

  // [FIX S2] Parse and validate every URL from the API response.
  void _parseSocialLinks() {
    final links = _coinInfo?['links'];
    if (links is! Map) return;

    final forumUrls = links['official_forum_url'];
    if (forumUrls is List) {
      for (final ws in forumUrls) {
        final url = _validateHttpUrl(ws?.toString());
        if (url != null) {
          _website = url;
          break;
        }
      }
    }

    final rawBrowsers = links['blockchain_site'];
    if (rawBrowsers is List) {
      _browsers = rawBrowsers
          .map((b) => _validateHttpUrl(b?.toString()))
          .whereType<String>()
          .toList();
    }

    final redditUrl = _validateHttpUrl(links['subreddit_url']?.toString());
    _reddit = redditUrl;

    // [FIX S2] Validate username contains only safe characters before
    // interpolating into a URL we construct ourselves.
    final tt = links['twitter_screen_name']?.toString() ?? '';
    if (_isSafeUsername(tt)) _twitter = 'https://twitter.com/$tt';

    final fb = links['facebook_username']?.toString() ?? '';
    if (_isSafeUsername(fb)) _facebook = 'https://www.facebook.com/$fb';
  }

  // [FIX P2] Extract market metrics once and cache in fields.
  void _cacheMarketMetrics() {
    _high24h = _marketDouble('high_24h');
    _low24h = _marketDouble('low_24h');
    _fdv = _marketDouble('fully_diluted_valuation');
    _rank = _marketRankFromInfo();
    _ath = _marketDouble('ath');
    _atl = _marketDouble('atl');
    _pct7d = _marketPctChange('price_change_percentage_7d');
    _pct30d = _marketPctChange('price_change_percentage_30d');
    _liquidityScore = _liquidityScoreFromInfo();
  }

  /// Fetch OHLCV + volume data in parallel.
  Future<void> _fetchChartData() async {
    final geckoId = (_coin['coin_gecko_id'] ?? '').toString().trim();
    if (geckoId.isEmpty) return;

    // [FIX C3] Capture this generation; later fetches increment the counter
    // and cause older responses to be discarded.
    final generation = ++_chartGeneration;

    if (mounted) setState(() => _chartLoading = true);

    final days = _periodDays[_periodIndex];
    final api = MarketApi();
    final results = await Future.wait([
      api.getOhlcvData(geckoId, days: days),
      api.getMarketChart(geckoId, days: days),
    ]);

    // [FIX C3] Discard stale response if a newer fetch overtook us.
    if (!mounted || generation != _chartGeneration) return;

    setState(() {
      _ohlcvData = results[0] as List<OhlcPoint>;
      final chartMap = results[1] as Map<String, List<double>>;
      _volumeData = chartMap['volumes'] ?? [];
      _chartLoading = false;
    });
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

  // ─── helpers ────────────────────────────────────────────────────────────────

  /// Safely converts an API value (num | String | null) to double.
  /// [FIX C5] Replaces the fragile `(value ?? 0) * 1.0` pattern.
  static double _toDouble(dynamic v, [double fallback = 0.0]) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  double _marketDouble(String key, [String currency = 'usd']) {
    try {
      final md = _coinInfo?['market_data'];
      if (md is! Map) return 0;
      final node = md[key];
      if (node is Map) return _toDouble(node[currency]);
      if (node is num) return node.toDouble();
    } catch (_) {}
    return 0;
  }

  double _marketPctChange(String key) {
    try {
      final md = _coinInfo?['market_data'];
      if (md is! Map) return 0;
      return _toDouble(md[key]);
    } catch (_) {
      return 0;
    }
  }

  int _marketRankFromInfo() {
    try {
      final md = _coinInfo?['market_data'];
      if (md is! Map) return 0;
      return (_toDouble(md['market_cap_rank'])).toInt();
    } catch (_) {
      return 0;
    }
  }

  double _liquidityScoreFromInfo() {
    try {
      return _toDouble(_coinInfo?['liquidity_score']);
    } catch (_) {
      return 0;
    }
  }

  String _fmtPct(double v) =>
      '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

  Color _pctColor(double v, BuildContext ctx) => AppThemeUtils.getColorByKey(
        ctx,
        v >= 0
            ? AppThemeKeys.rightTextColor.name
            : AppThemeKeys.errorTextColor.name,
      );

  // [FIX S2] Returns the URL only if it uses http/https and has a host.
  static String? _validateHttpUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    if (!uri.isScheme('https') && !uri.isScheme('http')) return null;
    if (uri.host.isEmpty) return null;
    return raw;
  }

  // [FIX S2] Allow only alphanumeric, underscores, hyphens and dots –
  // the character set used by all major social media platforms for usernames.
  // This prevents path-traversal sequences like '../../evil' or '?q=inject'.
  static bool _isSafeUsername(String? username) {
    if (username == null || username.isEmpty) return false;
    return RegExp(r'^[\w\-\.]+$').hasMatch(username);
  }

  // ─── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
                    _buildPeriodSelector(context),
                    _buildChartSection(context),
                    _buildMarketStatsCard(context),
                    if (_infoLoad == Load.finish && _coinInfo != null) ...[
                      _buildDepthDataCard(context),
                      _buildAboutSection(context),
                      _buildLinksSection(context),
                    ],
                    SizedBox(height: ScreenUtil().setWidth(40)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(100),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
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
          ],
        ),
      ),
    );
  }

  // ─── price section ──────────────────────────────────────────────────────────

  Widget _buildPriceSection(BuildContext context) {
    final isUp = _priceChange24h >= 0;
    // [FIX C5] Use _toDouble helper for safe price extraction.
    final price = _toDouble(_coin['price']);
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '\$${oCcy.format(price)}',
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
              color: AppThemeUtils.getColorByKey(
                      context,
                      isUp
                          ? AppThemeKeys.rightTextColor.name
                          : AppThemeKeys.errorTextColor.name)
                  .withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(8)),
            ),
            child: Text(
              '${isUp ? '+' : ''}${_regular.formartNum(_priceChange24h, 2, isCrop: true)}%',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                    context,
                    isUp
                        ? AppThemeKeys.rightTextColor.name
                        : AppThemeKeys.errorTextColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── period selector ────────────────────────────────────────────────────────

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
                  color: selected
                      ? AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainButtonBgColor.name)
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemBgColor.name),
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
                        : AppThemeUtils.getColorByKey(
                            context,
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

  // ─── chart section ──────────────────────────────────────────────────────────

  Widget _buildChartSection(BuildContext context) {
    final chartH = ScreenUtil().setWidth(360);
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Container(
        height: chartH,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius:
              BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(ScreenUtil().setWidth(16)),
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

  /// Falls back to a candlestick chart derived from `kline_default` price
  /// points when no CoinGecko OHLCV data is available.
  Widget _buildFallbackChart(BuildContext context, double height) {
    final klineRaw = _coin['kline_default'];
    if (klineRaw is! List || klineRaw.isEmpty) {
      return Center(
        child: Text(
          'No chart data',  // TODO: i18n
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(24),
          ),
        ),
      );
    }

    // Group sequential price points into synthetic OHLC buckets.
    const buckets = 40;
    // [FIX C5] Safe conversion of each kline value.
    final prices = klineRaw
        .map((v) => _toDouble(v))
        .where((v) => v.isFinite && v > 0)
        .toList();

    if (prices.isEmpty) {
      return Center(
        child: Text(
          'No chart data',  // TODO: i18n
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(24),
          ),
        ),
      );
    }

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

    return CandlestickChart(
      ohlcData: ohlc,
      height: height,
      volumeHeightRatio: 0,
    );
  }

  // ─── market stats card ──────────────────────────────────────────────────────

  Widget _buildMarketStatsCard(BuildContext context) {
    final symbol = (_coin['coin'] ?? '').toString().toUpperCase();

    // [FIX C5] Use _toDouble for all numeric field reads.
    final marketCap = _toDouble(_coin['market_cap']);
    final volume24h = _toDouble(_coin['volume_24h']);
    final totalSupply = _toDouble(_coin['total_supply']);
    final circSupply = _toDouble(_coin['circulating_supply']);

    // [FIX P2] Use cached metrics instead of recomputing each build.
    final rows = [
      (S.of(context).g_key_m_2,
          '\$${_regular.getMoneyAbbreviation(marketCap)}'),
      (S.of(context).g_key_m_3,
          '\$${_regular.getMoneyAbbreviation(volume24h)}'),
      (S.of(context).g_key_m_4,
          '${_regular.getMoneyAbbreviation(totalSupply)} $symbol'),
      (S.of(context).g_key_m_5,
          '${_regular.getMoneyAbbreviation(circSupply)} $symbol'),
      if (_high24h > 0)
        ('High 24H',    // TODO: i18n
            '\$${_regular.formartNum(_high24h, 6, isCrop: true)}'),
      if (_low24h > 0)
        ('Low 24H',     // TODO: i18n
            '\$${_regular.formartNum(_low24h, 6, isCrop: true)}'),
      if (_fdv > 0)
        ('FDV', '\$${_regular.getMoneyAbbreviation(_fdv)}'),  // TODO: i18n
      if (_rank > 0) ('Rank', '#$_rank'),                      // TODO: i18n
    ];

    return _card(
      context,
      child: Column(
        children: _rowsWithDividers(context, rows),
      ),
    );
  }

  // ─── depth data card ────────────────────────────────────────────────────────

  Widget _buildDepthDataCard(BuildContext context) {
    // [FIX P2] Already cached; just read.
    final pctRows = <(String, double)>[
      if (_pct7d != 0) ('7D Change', _pct7d),    // TODO: i18n
      if (_pct30d != 0) ('30D Change', _pct30d), // TODO: i18n
    ];

    final staticRows = <(String, String)>[
      if (_ath > 0)
        ('ATH', '\$${_regular.formartNum(_ath, 6, isCrop: true)}'), // TODO: i18n
      if (_atl > 0)
        ('ATL', '\$${_regular.formartNum(_atl, 6, isCrop: true)}'), // TODO: i18n
      if (_liquidityScore > 0)
        ('Liquidity Score',                                          // TODO: i18n
            _liquidityScore.toStringAsFixed(1)),
    ];

    if (pctRows.isEmpty && staticRows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Build all row widgets, inserting dividers between them.
    final widgets = <Widget>[];

    for (int i = 0; i < staticRows.length; i++) {
      if (widgets.isNotEmpty) widgets.add(_divider(context));
      widgets.add(_statRow(context, staticRows[i].$1, staticRows[i].$2));
    }
    for (int i = 0; i < pctRows.length; i++) {
      if (widgets.isNotEmpty) widgets.add(_divider(context));
      widgets.add(
          _statRowColored(context, pctRows[i].$1, pctRows[i].$2));
    }

    return _card(
      context,
      title: 'Market Depth',  // TODO: i18n
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  // ─── about section ──────────────────────────────────────────────────────────

  Widget _buildAboutSection(BuildContext context) {
    final desc =
        (_coinInfo!['description'] as Map?)?[_lang]?.toString() ?? '';
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
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name),
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
                          color: AppThemeUtils.getColorByKey(
                              context,
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

  // ─── social links ────────────────────────────────────────────────────────────

  Widget _buildLinksSection(BuildContext context) {
    // [FIX S2] _browsers is already filtered to validated URLs in
    // _parseSocialLinks; _twitter/_facebook are also validated there.
    final links = <_LinkItem>[
      if (_website.isNotEmpty)
        _LinkItem(
          icon: 'assets/img/webshit1.png',
          label: S.of(context).g_key_m_9,
          url: _website,
        ),
      if (_facebook != null)
        _LinkItem(
          icon: 'assets/img/facebook.png',
          label: S.of(context).g_key_m_10,
          url: _facebook!,
        ),
      if (_twitter != null)
        _LinkItem(
          icon: 'assets/img/twitter.png',
          label: S.of(context).g_key_m_11,
          url: _twitter!,
        ),
      if (_reddit != null)
        _LinkItem(
          icon: 'assets/img/reddit.png',
          label: S.of(context).g_key_m_14,
          url: _reddit!,
        ),
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
        // _browsers is already validated; no need for an extra url check here.
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
                    color: AppThemeUtils.getColorByKey(
                        context,
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

  // ─── shared widget primitives ────────────────────────────────────────────────

  /// Card container used by stats and depth sections.
  Widget _card(BuildContext context,
      {required Widget child, String? title}) {
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
      child: title == null
          ? child
          : Column(
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
            ),
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

  /// Interleaves dividers between rows.
  // [FIX] Replaces the fragile manual divider-insertion pattern in both cards.
  List<Widget> _rowsWithDividers(
      BuildContext context, List<(String, String)> rows) {
    final result = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      if (i > 0) result.add(_divider(context));
      result.add(_statRow(context, rows[i].$1, rows[i].$2));
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

  Widget _statRowColored(
      BuildContext context, String label, double pct) {
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

// ---------------------------------------------------------------------------
// Value type for link items
// ---------------------------------------------------------------------------

class _LinkItem {
  final String icon;
  final String label;
  final String url;
  const _LinkItem(
      {required this.icon, required this.label, required this.url});
}
