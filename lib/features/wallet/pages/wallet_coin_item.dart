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
  }) : super(key: ValueKey(itemKey));

  final CoinModel coinInfo;
  final String itemKey;
  final String group;

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
            onPressed: (_) {
              if (!canEdit) return;
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
            onTap: () => _onTap(context),
            borderRadius: AppRadius.brMd,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
              child: Row(
                children: [
                  _CoinIcon(
                    image: image,
                    mainImage: mainImage,
                    showWarning:
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
  });

  final Widget image;
  final Widget? mainImage;
  final bool showWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(64),
      height: ScreenUtil().setWidth(64),
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
                message: S.of(context).g_wallet_balance_warning,
                child: Icon(
                  Icons.error_rounded,
                  size: ScreenUtil().setWidth(28),
                  color: AppColorTokens.of(context).warning,
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
    // Two aligned columns: market data on the left, holdings on the right.
    // Wrap the quote/change at large text sizes instead of shrinking the font.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CoinValueText(
                text: coinInfo.config.miniName,
                style: AppTypography.bodyStrong.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.space2 / 2),
              Wrap(
                spacing: AppSpacing.space2,
                runSpacing: AppSpacing.space2 / 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _CoinValueText(
                    text: "\$${coinInfo.coinPriceString()}",
                    style: AppTypography.caption.copyWith(
                      color: colors.textSubtitle,
                    ),
                  ),
                  CoinPercentageBadge(percentage: coinInfo.percentage),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.space4),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CoinValueText(
                text: balanceStr == '—' ? '—' : "\$$balanceStr",
                style: AppTypography.bodyStrong.copyWith(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: AppSpacing.space2 / 2),
              _CoinValueText(
                text: '$tokenBalanceStr ${coinInfo.config.miniName}',
                style: AppTypography.caption.copyWith(
                  color: colors.textSubtitle,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Preserve full values for long press / accessibility when a narrow row clips.
class _CoinValueText extends StatelessWidget {
  const _CoinValueText({
    required this.text,
    required this.style,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: text,
    excludeFromSemantics: true,
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
    final color = AppThemeUtils.getColorByKey(context, colorKey.name);

    return Text(
      "${isPositive ? '+' : ''}${percentage.toStringAsFixed(2)}%",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
