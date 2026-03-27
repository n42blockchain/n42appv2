import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_constants.dart';
import 'package:n42_wallet/features/widgets/line_chart.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

// ── Shared theme helper ──────────────────────────────────────────────────

Color _dexColor(BuildContext context, AppThemeKeys key) =>
    AppThemeUtils.getColorByKey(context, key.name);

// ── Chain selector ─────────────────────────────────────────────────────────

/// Horizontal chip row for selecting the active DEX chain.
class DexChainChips extends StatelessWidget {
  const DexChainChips({
    super.key,
    required this.selectedChain,
    required this.onChainChanged,
  });

  final String selectedChain;
  final ValueChanged<String> onChainChanged;

  @override
  Widget build(BuildContext context) {
    final btnBg = _dexColor(context, AppThemeKeys.mainButtonBgColor);
    final itemBg = _dexColor(context, AppThemeKeys.itemBgColor);
    final btnText = _dexColor(context, AppThemeKeys.mainButtonTextColor);
    final mainText = _dexColor(context, AppThemeKeys.mainTextColor);

    return Wrap(
      spacing: ScreenUtil().setWidth(12),
      runSpacing: ScreenUtil().setWidth(8),
      children: kDexSupportedChains.map((c) {
        final selected = c['value'] == selectedChain;
        return ChoiceChip(
          label: Text(c['label']!),
          selected: selected,
          selectedColor: btnBg,
          backgroundColor: itemBg,
          labelStyle: TextStyle(
            color: selected ? btnText : mainText,
            fontSize: ScreenUtil().setSp(24),
          ),
          onSelected: (_) => onChainChanged(c['value']!),
        );
      }).toList(),
    );
  }
}

// ── Slippage selector ──────────────────────────────────────────────────────

/// A row of slippage-tolerance chips (0.1%, 0.5%, 1%, 2%).
class DexSlippageRow extends StatelessWidget {
  const DexSlippageRow({
    super.key,
    required this.slippageOptions,
    required this.selectedBps,
    required this.onChanged,
  });

  final List<int> slippageOptions;
  final int selectedBps;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final btnBg = _dexColor(context, AppThemeKeys.mainButtonBgColor);
    final itemBg = _dexColor(context, AppThemeKeys.itemBgColor);
    final btnText = _dexColor(context, AppThemeKeys.mainButtonTextColor);
    final mainText = _dexColor(context, AppThemeKeys.mainTextColor);
    final divider = _dexColor(context, AppThemeKeys.dividerColor);
    final subText = _dexColor(context, AppThemeKeys.itemSubtitleTextColor);

    return Row(
      children: [
        Flexible(
          child: Text(
            S.of(context).g_key_dex_slippage_label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: subText, fontSize: ScreenUtil().setSp(24)),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(16)),
        ...slippageOptions.map((bps) {
          final selected = selectedBps == bps;
          return GestureDetector(
            onTap: () => onChanged(bps),
            child: Container(
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(6),
              ),
              decoration: BoxDecoration(
                color: selected ? btnBg : itemBg,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                border: Border.all(color: selected ? btnBg : divider),
              ),
              child: Text(
                '${(bps / 100).toStringAsFixed(bps % 100 == 0 ? 0 : 1)}%',
                style: TextStyle(
                  color: selected ? btnText : mainText,
                  fontSize: ScreenUtil().setSp(22),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Swap direction arrow ───────────────────────────────────────────────────

/// Circular swap-direction button between the two token rows.
class DexSwapArrow extends StatelessWidget {
  const DexSwapArrow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
          decoration: BoxDecoration(
            color: _dexColor(context, AppThemeKeys.mainButtonBgColor),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.swap_vert,
            color: _dexColor(context, AppThemeKeys.mainButtonTextColor),
            size: ScreenUtil().setWidth(36),
          ),
        ),
      ),
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────

/// Red error message container shown below the token rows.
class DexErrorBanner extends StatelessWidget {
  const DexErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: _dexColor(context, AppThemeKeys.errorBgColor),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: _dexColor(context, AppThemeKeys.errorTextColor),
          fontSize: ScreenUtil().setSp(26),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Price chart section ────────────────────────────────────────────────────

/// Expandable price chart with period selector (1D / 7D / 1M).
class DexPriceChart extends StatelessWidget {
  const DexPriceChart({
    super.key,
    required this.tokenInSymbol,
    required this.chartPrices,
    required this.chartLoading,
    required this.selectedPeriodDays,
    required this.onPeriodChanged,
  });

  final String? tokenInSymbol;
  final List<double> chartPrices;
  final bool chartLoading;
  final int selectedPeriodDays;
  final ValueChanged<int> onPeriodChanged;

  static const _periods = [
    {'label': '1D', 'days': 1},
    {'label': '7D', 'days': 7},
    {'label': '1M', 'days': 30},
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final blueColor = _dexColor(context, AppThemeKeys.mainBlueColor);
    final subText = _dexColor(context, AppThemeKeys.itemSubtitleTextColor);
    final mainText = _dexColor(context, AppThemeKeys.mainTextColor);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: _dexColor(context, AppThemeKeys.itemBgColor4),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tokenInSymbol != null
                    ? '$tokenInSymbol · ${s.g_key_dex_price_chart}'
                    : s.g_key_dex_price_chart,
                style: TextStyle(
                  color: mainText,
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              ..._periods.map((p) => _periodChip(
                    context,
                    label: p['label'] as String,
                    days: p['days'] as int,
                    blueColor: blueColor,
                    subText: subText,
                  )),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _chartBody(context, s, subText),
        ],
      ),
    );
  }

  Widget _periodChip(
    BuildContext context, {
    required String label,
    required int days,
    required Color blueColor,
    required Color subText,
  }) {
    final isSelected = selectedPeriodDays == days;
    return GestureDetector(
      onTap: () {
        if (selectedPeriodDays != days) onPeriodChanged(days);
      },
      child: Container(
        margin: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(14),
          vertical: ScreenUtil().setWidth(6),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? blueColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? blueColor : subText,
            fontSize: ScreenUtil().setSp(22),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _chartBody(BuildContext context, S s, Color subText) {
    if (chartLoading) {
      return SizedBox(
        height: ScreenUtil().setWidth(160),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (chartPrices.isEmpty) {
      return SizedBox(
        height: ScreenUtil().setWidth(100),
        child: Center(
          child: Text(
            tokenInSymbol == null
                ? s.g_key_dex_select_token
                : 'No chart data',
            style:
                TextStyle(color: subText, fontSize: ScreenUtil().setSp(24)),
          ),
        ),
      );
    }
    return Column(
      children: [
        LineChart(
          chartPrices,
          chartPrices.last >= chartPrices.first,
          ScreenUtil().setWidth(160),
          0,
        ),
        SizedBox(height: ScreenUtil().setWidth(4)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${chartPrices.reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}',
              style: TextStyle(
                  color: subText, fontSize: ScreenUtil().setSp(20)),
            ),
            Text(
              '\$${chartPrices.reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}',
              style: TextStyle(
                  color: subText, fontSize: ScreenUtil().setSp(20)),
            ),
          ],
        ),
      ],
    );
  }
}

// ── AppBar action icons ────────────────────────────────────────────────────

/// The two icon buttons in the DEX swap app-bar (chart toggle + history).
class DexAppBarActions extends StatelessWidget {
  const DexAppBarActions({
    super.key,
    required this.showChart,
    required this.onToggleChart,
    required this.onOpenHistory,
  });

  final bool showChart;
  final VoidCallback onToggleChart;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final blue = _dexColor(context, AppThemeKeys.mainBlueColor);
    final sub = _dexColor(context, AppThemeKeys.itemSubtitleTextColor);
    final iconSize = ScreenUtil().setWidth(48);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onToggleChart,
          child: Container(
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(16)),
            child: Icon(
              Icons.show_chart_rounded,
              color: showChart ? blue : sub,
              size: iconSize,
            ),
          ),
        ),
        InkWell(
          onTap: onOpenHistory,
          child: Container(
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(30)),
            child: Icon(Icons.history, color: blue, size: iconSize),
          ),
        ),
      ],
    );
  }
}
