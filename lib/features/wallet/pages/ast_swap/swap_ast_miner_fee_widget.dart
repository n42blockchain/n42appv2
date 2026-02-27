import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    if (payCoinModel == null) return const SizedBox();

    final String title = payCoinModel!.coin['coinType'] as String;
    final _FeeStrings feeStrings = _buildFeeStrings(context, title);

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil().setWidth(20.0))),
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
            _buildGasLimitRow(context, feeStrings.gasLimitStr!),
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
        payCoinModel!.coin['blockchainType'] as String;
    String totalGasPriceStr;
    String gasPriceStr;
    Color totalGasPriceColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    String? gasLimitStr;

    if (blockchainType == BlockchainType.Ethereum.name) {
      final String unit = payCoinModel!.coin['unit'] as String;
      final int decimals = payCoinModel!.coin['decimals'] as int;
      final BigInt chainBalance = payCoinModel!.balance;

      if (totalGasPrice > chainBalance) {
        totalGasPriceColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
      }
      totalGasPriceStr =
          '${dec.Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())}$unit';
      gasPriceStr =
          '${dec.Decimal.parse(toGWei(gasPrice.toString()).toString())}Gwei';
      gasLimitStr = gas.toString();
    } else if (blockchainType == BlockchainType.Tron.name) {
      final int decimals = payCoinModel!.coin['decimals'] as int;

      if (toEther(totalGasPrice.toString(), decimals).toDouble() >
          payCoinModel!.balanceDoubleAll()) {
        totalGasPriceColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
      }
      totalGasPriceStr =
          '${dec.Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())} $title';
      gasPriceStr =
          '${dec.Decimal.parse(toEther(gasPrice.toString(), decimals).toString())} $title';
      gasLimitStr = gas.toString();
    } else {
      int decimals = payCoinModel!.coin['decimals'] as int;
      if (payCoinModel!.coin['isContract'] as bool) {
        decimals = payCoinModel!.coin['decimals'] as int;
      }
      totalGasPriceStr = '${toEther(totalGasPrice.toString(), decimals)} $title';
      gasPriceStr = '${toEther(gasPrice.toString(), decimals)} $title';
    }

    return _FeeStrings(
      totalGasPriceStr: totalGasPriceStr,
      gasPriceStr: gasPriceStr,
      totalGasPriceColor: totalGasPriceColor,
      gasLimitStr: gasLimitStr,
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
          Expanded(child: Container()),
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

  Widget _buildGasLimitRow(BuildContext context, String gasLimitStr) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(32.0)),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).g_key_101,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          Expanded(child: Container()),
          Text(
            gasLimitStr,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
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
