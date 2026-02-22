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
// Period constants – maps UI label to CoinGecko `days` param
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
  // ─────────────────────────── formatters ───────────────────────────────────
  final oCcy = NumberFormat('#,##0.00########', 'en_US');
  final Regular _regular = Regular();

  // ─────────────────────────── coin data ────────────────────────────────────
  late Map<String, dynamic> _coin;
  double _priceChange24h = 0.0;

  // ─────────────────────────── coinInfo (gecko) ─────────────────────────────
  Map<String, dynamic>? coinInfo;
  Load _infoLoad = Load.loading;

  // ─────────────────────────── social links ─────────────────────────────────
  String _website = '';
  List<dynamic> _browsers = [];
  String? _reddit;
  String? _twitter;
  String? _facebook;
  final String _lang = 'en';

  // ─────────────────────────── chart state ──────────────────────────────────
  int _periodIndex = 0; // index into _periodDays
  List<OhlcPoint> _ohlcvData = [];
  List<double> _volumeData = [];
  bool _chartLoading = false;

  // ─────────────────────────── lifecycle ────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // FIX: was `coin = Map.from(coin)` which caused a stack-overflow.
    _coin = Map<String, dynamic>.from(widget.coin);
    _priceChange24h = (_coin['price_change_per_24h'] == null ||
            _coin['price_change_per_24h'] == '')
        ? 0.0
        : (_coin['price_change_per_24h'] as num).toDouble();
    _fetchCoinPrice();
    _fetchCoinInfo();
  }

  // ─────────────────────────── data fetching ────────────────────────────────

  /// Refresh live price from market API.
  Future<void> _fetchCoinPrice() async {
    if (_coin.isEmpty) return;
    final coinSymbol = (_coin['coin'] ?? '').toString();
    if (coinSymbol.isEmpty) return;
    final result = await MarketApi().getWalletCoinsInfo(coinSymbol);
    if (result['error'] == false) {
      final coins = result['data']?['data'] as List<dynamic>?;
      if (coins != null) {
        for (final c in coins) {
          if (c['coin'] == coinSymbol) {
            if (mounted) {
              setState(() {
                _coin = Map<String, dynamic>.from(c as Map);
                _priceChange24h = (_coin['price_change_per_24h'] == null)
                    ? 0.0
                    : (_coin['price_change_per_24h'] as num).toDouble();
              });
            }
            break;
          }
        }
      }
    }
  }

  /// Load detail from N42 market API (proxies CoinGecko coin info).
  Future<void> _fetchCoinInfo() async {
    if (_coin.isEmpty) return;
    final geckoId = (_coin['coin_gecko_id'] ?? '').toString();
    coinInfo = await ref.read(wapBridgeProvider).getCoinsBaseInfo(geckoId);
    if (!mounted) return;
    if (coinInfo == null) {
      setState(() => _infoLoad = Load.error);
    } else {
      _parseSocialLinks();
      setState(() => _infoLoad = Load.finish);
      // Fetch chart once coin info is ready
      if (geckoId.isNotEmpty) _fetchChartData();
    }
  }

  void _parseSocialLinks() {
    final links = coinInfo!['links'] as Map?;
    if (links == null) return;
    final forumUrls = links['official_forum_url'] as List? ?? [];
    for (final ws in forumUrls) {
      if (ws != null && ws.toString().isNotEmpty) {
        _website = ws.toString();
        break;
      }
    }
    _browsers = links['blockchain_site'] as List? ?? [];
    _reddit = links['subreddit_url']?.toString();
    final tt = links['twitter_screen_name']?.toString();
    if (tt != null && tt.isNotEmpty) _twitter = 'https://twitter.com/$tt';
    final fb = links['facebook_username']?.toString();
    if (fb != null && fb.isNotEmpty) {
      _facebook = 'https://www.facebook.com/$fb';
    }
  }

  /// Fetch OHLCV + volume data in parallel.
  Future<void> _fetchChartData() async {
    final geckoId = (_coin['coin_gecko_id'] ?? '').toString();
    if (geckoId.isEmpty) return;
    if (mounted) setState(() => _chartLoading = true);

    final days = _periodDays[_periodIndex];
    final api = MarketApi();
    final results = await Future.wait([
      api.getOhlcvData(geckoId, days: days),
      api.getMarketChart(geckoId, days: days),
    ]);

    if (!mounted) return;
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

  // ─────────────────────────── helpers ──────────────────────────────────────

  /// Extract double from nested market_data map (e.g. ath.usd).
  double _marketDouble(String key, [String currency = 'usd']) {
    try {
      final md = coinInfo?['market_data'] as Map?;
      if (md == null) return 0;
      final node = md[key];
      if (node is Map) return (node[currency] as num? ?? 0).toDouble();
      if (node is num) return node.toDouble();
    } catch (_) {}
    return 0;
  }

  double _marketPctChange(String key) {
    try {
      final md = coinInfo?['market_data'] as Map?;
      if (md == null) return 0;
      final v = md[key];
      if (v is num) return v.toDouble();
    } catch (_) {}
    return 0;
  }

  int _marketRank() {
    try {
      final md = coinInfo?['market_data'] as Map?;
      return (md?['market_cap_rank'] as num? ?? 0).toInt();
    } catch (_) {
      return 0;
    }
  }

  double _liquidityScore() {
    try {
      return (coinInfo?['liquidity_score'] as num? ?? 0).toDouble();
    } catch (_) {
      return 0;
    }
  }

  String _fmtPct(double v) =>
      '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

  Color _pctColor(double v, BuildContext ctx) =>
      AppThemeUtils.getColorByKey(
          ctx,
          v >= 0
              ? AppThemeKeys.rightTextColor.name
              : AppThemeKeys.errorTextColor.name);

  // ─────────────────────────── build ────────────────────────────────────────

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
                    if (_infoLoad == Load.finish && coinInfo != null) ...[
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

  // ─────────────── header ───────────────────────────────────────────────────

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
                  imageUrl: _coin['image'] ?? '',
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

  // ─────────────── price section ────────────────────────────────────────────

  Widget _buildPriceSection(BuildContext context) {
    final isUp = _priceChange24h >= 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '\$${oCcy.format(_coin['price'] ?? 0)}',
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
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
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

  // ─────────────── period selector ──────────────────────────────────────────

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
                margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(4)),
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
                decoration: BoxDecoration(
                  color: selected
                      ? AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonBgColor.name)
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
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
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────── chart section ────────────────────────────────────────────

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
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _ohlcvData.isEmpty
                  ? _buildFallbackLineChart(context, chartH)
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

  /// Falls back to the original sparkline from kline_default when OHLCV is
  /// unavailable (no gecko ID or API error).
  Widget _buildFallbackLineChart(BuildContext context, double height) {
    final klineData = _coin['kline_default'] as List? ?? [];
    if (klineData.isEmpty) {
      return Center(
        child: Text(
          'No chart data',
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(24),
          ),
        ),
      );
    }
    // Derive a simple candlestick from sequential price points
    // (every group of N points becomes one candle).
    const buckets = 40;
    final step = max(1, klineData.length ~/ buckets);
    final ohlc = <OhlcPoint>[];
    for (int i = 0; i + step <= klineData.length; i += step) {
      final slice = klineData.sublist(i, i + step);
      final prices = slice.map((v) => (v as num).toDouble()).toList();
      ohlc.add(OhlcPoint(
        open: prices.first,
        close: prices.last,
        high: prices.reduce(max),
        low: prices.reduce(min),
      ));
    }
    return CandlestickChart(
      ohlcData: ohlc,
      height: height,
      volumeHeightRatio: 0,
    );
  }

  // ─────────────── market stats card ────────────────────────────────────────

  Widget _buildMarketStatsCard(BuildContext context) {
    final geckoMd = coinInfo?['market_data'] as Map?;
    final high24h = geckoMd != null
        ? _marketDouble('high_24h')
        : (_coin['high_24h'] as num? ?? 0).toDouble();
    final low24h = geckoMd != null
        ? _marketDouble('low_24h')
        : (_coin['low_24h'] as num? ?? 0).toDouble();
    final fdv = _marketDouble('fully_diluted_valuation');
    final rank = _marketRank();

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
      child: Column(
        children: [
          _statRow(context, S.of(context).g_key_m_2,
              '\$${_regular.getMoneyAbbreviation((_coin['market_cap'] ?? 0) * 1.0)}'),
          _divider(context),
          _statRow(context, S.of(context).g_key_m_3,
              '\$${_regular.getMoneyAbbreviation((_coin['volume_24h'] ?? 0) * 1.0)}'),
          _divider(context),
          _statRow(context, S.of(context).g_key_m_4,
              '${_regular.getMoneyAbbreviation((_coin['total_supply'] ?? 0) * 1.0)} ${(_coin['coin'] ?? '').toString().toUpperCase()}'),
          _divider(context),
          _statRow(context, S.of(context).g_key_m_5,
              '${_regular.getMoneyAbbreviation((_coin['circulating_supply'] ?? 0) * 1.0)} ${(_coin['coin'] ?? '').toString().toUpperCase()}'),
          if (high24h > 0) ...[
            _divider(context),
            _statRow(context, 'High 24H',
                '\$${_regular.formartNum(high24h, 6, isCrop: true)}'),
          ],
          if (low24h > 0) ...[
            _divider(context),
            _statRow(context, 'Low 24H',
                '\$${_regular.formartNum(low24h, 6, isCrop: true)}'),
          ],
          if (fdv > 0) ...[
            _divider(context),
            _statRow(context, 'FDV',
                '\$${_regular.getMoneyAbbreviation(fdv)}'),
          ],
          if (rank > 0) ...[
            _divider(context),
            _statRow(context, 'Rank', '#$rank'),
          ],
        ],
      ),
    );
  }

  // ─────────────── depth / liquidity card ───────────────────────────────────

  Widget _buildDepthDataCard(BuildContext context) {
    final ath = _marketDouble('ath');
    final atl = _marketDouble('atl');
    final pct7d = _marketPctChange('price_change_percentage_7d');
    final pct30d = _marketPctChange('price_change_percentage_30d');
    final liq = _liquidityScore();

    // Collect rows that have meaningful data
    final rows = <Widget>[];

    if (ath > 0) {
      rows.add(_statRow(
        context,
        'ATH',
        '\$${_regular.formartNum(ath, 6, isCrop: true)}',
      ));
    }
    if (atl > 0) {
      if (rows.isNotEmpty) rows.add(_divider(context));
      rows.add(_statRow(
        context,
        'ATL',
        '\$${_regular.formartNum(atl, 6, isCrop: true)}',
      ));
    }
    if (pct7d != 0) {
      if (rows.isNotEmpty) rows.add(_divider(context));
      rows.add(_statRowColored(context, '7D Change', pct7d));
    }
    if (pct30d != 0) {
      if (rows.isNotEmpty) rows.add(_divider(context));
      rows.add(_statRowColored(context, '30D Change', pct30d));
    }
    if (liq > 0) {
      if (rows.isNotEmpty) rows.add(_divider(context));
      rows.add(_statRow(
        context,
        'Liquidity Score',
        liq.toStringAsFixed(1),
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: ScreenUtil().setWidth(10),
              top: ScreenUtil().setWidth(6),
            ),
            child: Text(
              'Market Depth',
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor.name),
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...rows,
        ],
      ),
    );
  }

  // ─────────────── about section ────────────────────────────────────────────

  Widget _buildAboutSection(BuildContext context) {
    final desc = (coinInfo!['description'] as Map?)?[_lang]?.toString() ?? '';
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
          Text(
            S.of(context).g_key_m_6,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonBgColor.name),
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w600,
            ),
          ),
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
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
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
                    onTap: () =>
                        aboutShowDialog(context, desc, S.of(context).g_key_m_6),
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
                              context, AppThemeKeys.mainButtonBgColor.name),
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

  // ─────────────── social links section ─────────────────────────────────────

  Widget _buildLinksSection(BuildContext context) {
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
      if (_reddit != null && _reddit!.isNotEmpty)
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
          Text(
            S.of(context).g_key_m_8,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonBgColor.name),
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(10),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
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
    final validBrowsers =
        _browsers.where((b) => b != null && b.toString().isNotEmpty).toList();
    if (validBrowsers.isEmpty) return const SizedBox.shrink();
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
        ...validBrowsers.map(
          (b) => InkWell(
            onTap: () => _openUrl(context, b.toString()),
            child: SizedBox(
              height: ScreenUtil().setWidth(85),
              child: Row(
                children: [
                  SizedBox(width: ScreenUtil().setWidth(70)),
                  Expanded(
                    child: Text(
                      b.toString(),
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
                        context, AppThemeKeys.itemSubtitleTextColor.name),
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

  // ─────────────── reusable row widgets ─────────────────────────────────────

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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _LinkItem {
  final String icon;
  final String label;
  final String url;
  const _LinkItem({required this.icon, required this.label, required this.url});
}
