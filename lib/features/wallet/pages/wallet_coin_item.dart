import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_xrp.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_helpers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_aggregate_detail_page.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class WalletCoinItem extends ConsumerWidget {
  WalletCoinItem({
    required this.coinInfo,
    required this.itemKey,
    required this.group,
    this.visibilityState = 'visible',
  }) : super(key: ValueKey(itemKey));

  final CoinModel coinInfo;
  final String itemKey;
  final String group;
  final String visibilityState;

  static final _oCcy = NumberFormat('#,##0.00', 'en_US');
  static final _regular = Regular();

  String _abbreviate(double value, {String? fallback}) {
    if (value >= 1000000000) return _regular.getMoneyAbbreviation(value);
    if (value > 0 && value < 0.0000000009) {
      return _regular.getMoneyAbbreviationDecimal(value);
    }
    return fallback ?? _oCcy.format(value);
  }

  String _formatBalance(double balance) => _abbreviate(balance);

  String _formatTokenBalance(CoinModel coin) =>
      _abbreviate(coin.balanceDoubleAll(), fallback: coin.balanceString());

  Future<void> _showAssetControls(BuildContext context, WidgetRef ref) async {
    final wallet = ref.read(wapBridgeProvider);
    if (!wallet.hasAssetVisibilityWallet) return;
    final owner = wallet.walletInfo;
    final record = wallet.assetVisibilityRecord(coinInfo);
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          S.of(context).g_ui3_asset_controls_title(coinInfo.config.miniName),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(S.of(context).g_ui3_asset_controls_body),
          ),
          if (record != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${record['source']} · ${record['updatedAt']}'),
            ),
          for (final entry in {
            'visible': S.of(context).g_ui3_asset_restore_display,
            'warning': S.of(context).g_ui3_asset_mark_review,
            'hidden': S.of(context).g_ui3_asset_hide,
            'quarantined': S.of(context).g_ui3_asset_quarantine,
          }.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, entry.key),
              child: Text(entry.value),
            ),
        ],
      ),
    );
    if (choice != null && identical(wallet.walletInfo, owner)) {
      final saved = await wallet.setAssetVisibility(coinInfo, choice);
      if (!saved && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).g_ui3_asset_save_failed)),
        );
      }
    }
  }

  void _onTap(BuildContext context) {
    if (coinInfo.coin['isAggregated'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WalletAggregateDetailPage(coin: coinInfo),
        ),
      );
      return;
    }
    final page = coinInfo.config.coinType == CoinType.XRP.name
        ? WalletChainInfoXRP(coinInfo)
        : WalletChainInfo(coinInfo);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coin = coinInfo.coin;
    final config = coinInfo.config;
    final aggregate = coinInfo is AggregatedCoinModel
        ? coinInfo as AggregatedCoinModel
        : null;
    final unknown = aggregate != null && aggregate.chainBalances.isEmpty;
    final balanceStr = unknown ? '—' : _formatBalance(coinInfo.value);
    final tokenBalanceStr = unknown ? '—' : _formatTokenBalance(coinInfo);

    const defaultImg = 'assets/img/list_default.png';
    final coinIcon = config.icon;
    final Widget image = coinIcon.isEmpty
        ? Image.asset(defaultImg)
        : ImageNetWork(imageUrl: coinIcon, placeholder: defaultImg);

    final Widget? mainImage = config.isContract
        ? ImageNetWork(
            imageUrl: coinInfo.mainCoinIcon ?? '',
            placeholder: defaultImg,
          )
        : null;

    final canEdit = coin['canEdit'] == true;
    final deleteColor = canEdit
        ? AppColorTokens.of(context).danger
        : AppColorTokens.of(context).textTertiary;

    return Slidable(
      key: ValueKey(itemKey),
      groupTag: group,
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (_) async {
              if (!canEdit) return;
              // Removing an asset or chain from the wallet has no undo.
              final s = S.of(context);
              final confirmed = await AppDialog.confirm(
                context,
                title: s.g_ui3_remove_asset_title(config.miniName),
                message: s.g_ui3_remove_asset_message,
                confirmText: s.g_alert_remove,
                danger: true,
              );
              if (!confirmed || !context.mounted) return;
              final wap = ref.read(wapBridgeProvider);
              if (config.isContract) {
                wap.removeWalletChainToken(
                  coin,
                  symbol: config.coinType,
                  miniName: config.miniName,
                );
              } else {
                wap.removeWalletChain(config.mKey, coin['unit']);
              }
            },
            backgroundColor: deleteColor,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            // Swipe actions carry a visible (and spoken) name, as on iOS.
            label: S.of(context).g_alert_remove,
            autoClose: true,
          ),
        ],
      ),
      child: Container(
        key: ValueKey('wallet_coin_surface_$itemKey'),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColorTokens.of(context).border.withValues(alpha: 0.55),
              width: 0.5,
            ),
          ),
        ),
        // Material 承接卡面色，InkWell ripple 画在卡面之上——
        // 此前 InkWell 在不透明卡片下方，按压态完全不可见（§5 红线）。
        child: Material(
          color: AppColorTokens.of(context).bgBase,
          borderRadius: AppRadius.brMd,
          child: InkWell(
            key: ValueKey('wallet_coin_open_$itemKey'),
            onLongPress: coinInfo is AggregatedCoinModel
                ? null
                : () => _showAssetControls(context, ref),
            onTap: () {
              if (aggregate == null &&
                  ref.read(wapBridgeProvider).assetVisibilityState(coinInfo) ==
                      'quarantined') {
                return;
              }
              _onTap(context);
            },
            borderRadius: AppRadius.brMd,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _CoinIcon(
                    image: image,
                    mainImage: mainImage,
                    warningText: visibilityState == 'warning'
                        ? S.of(context).g_ui3_asset_marked_review_hint
                        : null,
                    showWarning:
                        visibilityState == 'warning' ||
                        aggregate?.loadError == true ||
                        shouldShowBalanceLoadWarning(coinInfo),
                  ),
                  Expanded(
                    child: _CoinInfo(
                      coinInfo: coinInfo,
                      balanceStr: balanceStr,
                      tokenBalanceStr: tokenBalanceStr,
                    ),
                  ),
                  if (coin['isAggregated'] != true)
                    WalletPinIconButton(
                      isPinned: coinInfo.isPinned,
                      onTap: () =>
                          ref.read(wapBridgeProvider).togglePinCoin(coinInfo),
                    )
                  else
                    SizedBox.square(dimension: WalletPinIconButton.touchExtent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinIcon extends StatelessWidget {
  const _CoinIcon({
    required this.image,
    this.mainImage,
    this.showWarning = false,
    this.warningText,
  });

  final Widget image;
  final Widget? mainImage;
  final bool showWarning;
  final String? warningText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: EdgeInsets.only(right: AppSpacing.space4),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(borderRadius: AppRadius.brLg, child: image),
          if (showWarning)
            Positioned(
              right: -2,
              bottom: -2,
              child: Tooltip(
                message: warningText ?? S.of(context).g_wallet_balance_warning,
                child: Icon(
                  Icons.error_rounded,
                  size: ScreenUtil().setWidth(28),
                  // Plain system orange is about 2:1 on the row; keep the
                  // status glyph at the 3:1 minimum for meaningful icons.
                  color: AppContrast.ensure(
                    AppColorTokens.of(context).warning,
                    [AppColorTokens.of(context).bgBase],
                    darken: Theme.of(context).brightness != Brightness.dark,
                    min: 3,
                  ),
                ),
              ),
            ),
          if (mainImage != null)
            Positioned(
              top: -2,
              left: -2,
              height: ScreenUtil().setWidth(20),
              width: ScreenUtil().setWidth(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.brSm,
                  border: Border.all(
                    color: AppColorTokens.of(context).bgBase,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.brSm,
                  child: mainImage,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoinInfo extends StatelessWidget {
  const _CoinInfo({
    required this.coinInfo,
    required this.balanceStr,
    required this.tokenBalanceStr,
  });

  final CoinModel coinInfo;
  final String balanceStr;
  final String tokenBalanceStr;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = walletAssetRowUsesStackedLayout(
          context,
          constraints.maxWidth,
        );
        final market = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoinValueText(
              text: coinInfo.config.miniName,
              wrap: stacked,
              style: AppTypography.subheadline.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: AppSpacing.space2,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _CoinValueText(
                  text: "\$${coinInfo.coinPriceString()}",
                  wrap: stacked,
                  style: AppTypography.footnote.copyWith(
                    color: colors.textSubtitle,
                  ),
                ),
                CoinPercentageBadge(percentage: coinInfo.percentage),
              ],
            ),
          ],
        );
        final holdings = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CoinValueText(
              text: balanceStr == '—' ? '—' : "\$$balanceStr",
              wrap: stacked,
              style: AppTypography.subheadline.copyWith(
                color: colors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 2),
            _CoinValueText(
              text: '$tokenBalanceStr ${coinInfo.config.miniName}',
              wrap: stacked,
              style: AppTypography.footnote.copyWith(
                color: colors.textSubtitle,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        );
        if (stacked) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              market,
              SizedBox(height: AppSpacing.space4),
              holdings,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 5, child: market),
            SizedBox(width: AppSpacing.space4),
            Expanded(flex: 4, child: holdings),
          ],
        );
      },
    );
  }
}

/// Preserve full values for long press / accessibility when a narrow row clips.
class _CoinValueText extends StatelessWidget {
  const _CoinValueText({
    required this.text,
    required this.style,
    this.textAlign = TextAlign.left,
    this.wrap = false,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final bool wrap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: text,
    excludeFromSemantics: true,
    child: Text(
      text,
      maxLines: wrap ? null : 1,
      overflow: wrap ? TextOverflow.visible : TextOverflow.ellipsis,
      textAlign: textAlign,
      style: style,
    ),
  );
}

class CoinPercentageBadge extends StatelessWidget {
  const CoinPercentageBadge({super.key, required this.percentage});

  final num percentage;

  @override
  Widget build(BuildContext context) {
    final isPositive = percentage >= 0;
    final colorKey = isPositive
        ? AppThemeKeys.rightTextColor
        : AppThemeKeys.errorTextColor;
    // System green/red text on the list background is about 2:1 / 3.2:1;
    // shift the shade until the footnote reaches 4.5:1 in both themes.
    final color = AppContrast.ensure(
      AppThemeUtils.getColorByKey(context, colorKey.name),
      [AppColorTokens.of(context).bgBase],
      darken: Theme.of(context).brightness != Brightness.dark,
    );

    return Text(
      "${isPositive ? '+' : ''}${percentage.toStringAsFixed(2)}%",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.footnote.copyWith(
        color: color,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
