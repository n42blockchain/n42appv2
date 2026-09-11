// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'market_page.dart';

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

  String get _coinId => switch (source) {
    _CoinSource.trending || _CoinSource.search => coin['id']?.toString() ?? '',
    _CoinSource.watchlist => coin['coin_gecko_id']?.toString() ?? '',
  };

  String get _symbol => switch (source) {
    _CoinSource.trending ||
    _CoinSource.search => (coin['symbol'] ?? '').toString().toLowerCase(),
    _CoinSource.watchlist => (coin['coin'] ?? '').toString().toLowerCase(),
  };

  String get _name => (coin['name'] ?? '').toString();

  String get _imageUrl => switch (source) {
    _CoinSource.trending ||
    _CoinSource.search => coin['large'] ?? coin['thumb'] ?? '',
    _CoinSource.watchlist => coin['image'] ?? '',
  };

  int? get _rank {
    final r = coin['market_cap_rank'];
    if (r == null) return null;
    if (r is int) return r;
    if (r is num) return r.toInt();
    return int.tryParse(r.toString());
  }

  double get _price => switch (source) {
    _CoinSource.trending =>
      double.tryParse(
            (coin['data']?['price'] ?? '')
                .toString()
                .replaceAll(r'$', '')
                .replaceAll(',', ''),
          ) ??
          0.0,
    _CoinSource.search => 0.0,
    _CoinSource.watchlist => _toDouble(coin['price']),
  };

  double get _pct24h => switch (source) {
    _CoinSource.trending => _toDouble(
      coin['data']?['price_change_percentage_24h']?['usd'],
    ),
    _CoinSource.search => 0.0,
    _CoinSource.watchlist => _toDouble(coin['price_change_per_24h']),
  };

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColorTokens.of(context).textPrimary;
    final subColor = textColor.withAlpha(153);
    final dividerColor = AppColorTokens.of(context).border;
    final isPositive = _pct24h >= 0;
    final pctColor = isPositive
        ? AppColorTokens.of(context).success
        : AppColorTokens.of(context).danger;
    final showPrice = source != _CoinSource.search;

    return InkWell(
      onTap: onTap,
      // 默认 splash + 可见 highlight（此前 splash 禁用 + 3% 高亮形同虚设）
      highlightColor: AppColorTokens.of(context).brand.withValues(alpha: 0.08),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                color: dividerColor.withAlpha(60),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26.r),
                child: ImageNetWork(
                  imageUrl: _imageUrl,
                  width: 52.w,
                  height: 52.w,
                ),
              ),
            ),
            SizedBox(width: 12.w),
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
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: dividerColor.withAlpha(80),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '#$_rank',
                            style: AppTypography.captionSm.copyWith(
                              color: subColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Flexible(
                        child: Text(
                          _name,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    _symbol.toUpperCase(),
                    style: AppTypography.captionSm.copyWith(
                      fontWeight: FontWeight.w400,
                      color: subColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            if (showPrice) ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _price > 0 ? '\$${_formatPrice(_price)}' : '--',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: pctColor.withAlpha(22),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${_pct24h.toStringAsFixed(2)}%',
                      style: AppTypography.captionSm.copyWith(
                        color: pctColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 6.w),
            ],
            if (_coinId.isNotEmpty)
              // IconButton 默认 48dp 命中区（§5 触控红线）
              IconButton(
                onPressed: () => onSetAlert(context, coin),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  alertActive
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: alertActive
                      ? AppColorTokens.of(context).brand
                      : subColor,
                  size: 26.sp,
                ),
              ),
            IconButton(
              onPressed: () => onToggleWatchlist(_symbol),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                inWatchlist ? Icons.star_rounded : Icons.star_outline_rounded,
                color: inWatchlist ? AppColorTokens.highlight : subColor,
                size: 28.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return formatMarketPriceDisplay(price);
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
    final subColor = AppColorTokens.of(context).textPrimary.withAlpha(128);

    Widget body = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              color: subColor.withAlpha(14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48.sp, color: subColor.withAlpha(160)),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w400,
              color: subColor,
            ),
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
    final bgColor = color.withAlpha(22);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withAlpha(60), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                level.emoji,
                style: AppTypography.captionSm.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                data.classification,
                style: AppTypography.captionSm.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${data.value}',
                  style: AppTypography.captionSm.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          S.of(context).g_ui_fear_greed,
          style: AppTypography.captionSm.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColorTokens.of(context).textPrimary.withAlpha(90),
          ),
        ),
      ],
    );
  }
}
