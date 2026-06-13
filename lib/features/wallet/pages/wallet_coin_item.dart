import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_xrp.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_helpers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
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

  static final _oCcy = NumberFormat('#,##0.0#', 'en_US');
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
      ToastUtils.show(S.of(context).g_key_aa_coming_soon);
      return;
    }
    final page = coinInfo.config.coinType == CoinType.XRP.name
        ? WalletChainInfoXRP(coinInfo)
        : WalletChainInfo(coinInfo);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final su = ScreenUtil();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coin = coinInfo.coin;
    final balanceStr = _formatBalance(coinInfo.value);
    final tokenBalanceStr = _formatTokenBalance(coinInfo);

    const defaultImg = 'assets/img/list_default.png';
    final coinIcon = coin['icon'] ?? '';
    final Widget image = coinIcon.isEmpty
        ? Image.asset(defaultImg)
        : ImageNetWork(imageUrl: coinIcon, placeholder: defaultImg);

    final Widget? mainImage = coin['isContract'] == true
        ? ImageNetWork(
            imageUrl: coinInfo.mainCoinIcon ?? '',
            placeholder: defaultImg,
          )
        : null;

    final canEdit = coin['canEdit'] == true;
    final deleteColor = canEdit
        ? AppColorTokens.of(context).danger
        : AppColorTokens.of(context).textTertiary;

    final Widget refreshWidget = coinInfo.loadError
        ? Container(
            height: su.setWidth(30.0),
            width: su.setWidth(30.0),
            margin: EdgeInsets.only(right: su.setWidth(6.0)),
            child: Image.asset(
              'assets/img/error.png',
              color: AppColorTokens.of(context).warning,
            ),
          )
        : const SizedBox();

    return InkWell(
      onTap: () => _onTap(context),
      child: Slidable(
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
                if (coin['isContract'] == true) {
                  wap.removeWalletChainToken(
                    coin,
                    symbol: coin['coinType'],
                    miniName: coin['miniName'],
                  );
                } else {
                  wap.removeWalletChain(coin['mKey'], coin['unit']);
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
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.space6,
            vertical: AppSpacing.space2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space6,
          ),
          decoration: BoxDecoration(
            color: AppColorTokens.of(context).bgSurface,
            borderRadius: AppRadius.brMd,
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(6),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              refreshWidget,
              _CoinIcon(image: image, mainImage: mainImage),
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinIcon extends StatelessWidget {
  const _CoinIcon({required this.image, this.mainImage});

  final Widget image;
  final Widget? mainImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
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
        children: [
          ClipRRect(borderRadius: AppRadius.brLg, child: image),
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
    final su = ScreenUtil();
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (coinInfo.isPinned)
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.space2),
                child: Icon(
                  Icons.push_pin,
                  size: su.setWidth(22),
                  color: AppColorTokens.of(context).brand,
                ),
              ),
            Expanded(
              child: Text(
                coinInfo.config.miniName,
                style: AppTypography.bodyStrong.copyWith(
                  color: mainText,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Text(
              tokenBalanceStr,
              style: AppTypography.bodyStrong.copyWith(color: mainText),
              textAlign: TextAlign.right,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.space2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  "\$${coinInfo.coinPriceString()}",
                  style: AppTypography.caption.copyWith(color: subtitleText),
                ),
                SizedBox(width: AppSpacing.space2),
                CoinPercentageBadge(percentage: coinInfo.percentage),
              ],
            ),
            Text(
              "\$$balanceStr",
              style: AppTypography.caption.copyWith(color: subtitleText),
            ),
          ],
        ),
      ],
    );
  }
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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brSm,
      ),
      child: Text(
        "${isPositive ? '+' : ''}${percentage.toStringAsFixed(2)}%",
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
