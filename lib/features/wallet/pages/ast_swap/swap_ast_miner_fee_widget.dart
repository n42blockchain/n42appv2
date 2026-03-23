import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String _swapFeeString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

int _swapFeeInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

/// 矿工费详情面板，显示链余额、Gas Price、Gas Limit 和预估总费用。
class SwapAstMinerFeeWidget extends StatelessWidget {
  final CoinModel? payCoinModel;
  final BigInt totalGasPrice;
  final BigInt gasPrice;
  final BigInt gas;

  const SwapAstMinerFeeWidget({
    super.key,
    required this.payCoinModel,
    required this.totalGasPrice,
    required this.gasPrice,
    required this.gas,
  });

  @override
  Widget build(BuildContext context) {
    if (payCoinModel == null) return const SizedBox.shrink();

    final String title = _swapFeeString(
      payCoinModel!.coin['coinType'],
      fallback: CoinType.N.name,
    );
    final feeStrings = _buildFeeStrings(context, title);

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
      ),
      child: Column(
        children: [
          _buildFeeRow(
            context,
            label: S.of(context).g_key_29,
            value:
                '${payCoinModel!.balanceStringAll()} ${payCoinModel!.coin['unit'] ?? ""}',
            valueColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonBgColor.name),
          ),
          _buildFeeRow(
            context,
            label: S.of(context).g_key_t_15,
            value: feeStrings.gasPriceStr,
          ),
          if (feeStrings.gasLimitStr != null)
            _buildFeeRow(
              context,
              label: S.of(context).g_key_101,
              value: feeStrings.gasLimitStr!,
              topMargin: true,
            ),
          _buildFeeRow(
            context,
            label: S.of(context).g_key_t_16,
            value: feeStrings.totalGasPriceStr,
            valueColor: feeStrings.totalGasPriceColor,
            topMargin: true,
          ),
        ],
      ),
    );
  }

  _FeeStrings _buildFeeStrings(BuildContext context, String title) {
    final String blockchainType =
        _swapFeeString(payCoinModel!.coin['blockchainType']);
    final int decimals = _swapFeeInt(payCoinModel!.coin['decimals'], fallback: 18);
    Color totalGasPriceColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);

    if (blockchainType == BlockchainType.Ethereum.name) {
      final String unit = _swapFeeString(
        payCoinModel!.coin['unit'],
        fallback: title,
      );
      if (totalGasPrice > payCoinModel!.balance) {
        totalGasPriceColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
      }
      return _FeeStrings(
        totalGasPriceStr:
            '${dec.Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())}$unit',
        gasPriceStr:
            '${dec.Decimal.parse(toGWei(gasPrice.toString()).toString())}Gwei',
        totalGasPriceColor: totalGasPriceColor,
        gasLimitStr: gas.toString(),
      );
    }

    if (blockchainType == BlockchainType.Tron.name) {
      if (toEther(totalGasPrice.toString(), decimals).toDouble() >
          payCoinModel!.balanceDoubleAll()) {
        totalGasPriceColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
      }
      return _FeeStrings(
        totalGasPriceStr:
            '${dec.Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())} $title',
        gasPriceStr:
            '${dec.Decimal.parse(toEther(gasPrice.toString(), decimals).toString())} $title',
        totalGasPriceColor: totalGasPriceColor,
        gasLimitStr: gas.toString(),
      );
    }

    // Default chains
    return _FeeStrings(
      totalGasPriceStr: '${toEther(totalGasPrice.toString(), decimals)} $title',
      gasPriceStr: '${toEther(gasPrice.toString(), decimals)} $title',
      totalGasPriceColor: totalGasPriceColor,
    );
  }

  Widget _buildFeeRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool topMargin = false,
  }) {
    return Container(
      alignment: Alignment.center,
      margin: topMargin
          ? EdgeInsets.only(top: ScreenUtil().setWidth(32.0))
          : EdgeInsets.only(bottom: ScreenUtil().setWidth(32.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ??
                  AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeStrings {
  final String totalGasPriceStr;
  final String gasPriceStr;
  final Color totalGasPriceColor;
  final String? gasLimitStr;

  const _FeeStrings({
    required this.totalGasPriceStr,
    required this.gasPriceStr,
    required this.totalGasPriceColor,
    this.gasLimitStr,
  });
}
