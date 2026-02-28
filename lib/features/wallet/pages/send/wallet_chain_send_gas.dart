import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/gas_selector_widget.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// 矿工费展示区块（标准模式）。
///
/// 显示 Gas 单价、Gas Limit（仅 EVM/Tron）和总费用。
class StandardMinerFeeWidget extends StatelessWidget {
  const StandardMinerFeeWidget({
    super.key,
    required this.coinModel,
    required this.chainModel,
    required this.gasPrice,
    required this.gas,
    required this.totalGasPrice,
  });

  final CoinModel coinModel;
  final CoinModel? chainModel;
  final BigInt gasPrice;
  final BigInt gas;
  final BigInt totalGasPrice;

  @override
  Widget build(BuildContext context) {
    final blockchainType = coinModel.coin['blockchainType'] as String;
    final coinType = coinModel.coin['coinType'] as String;
    final isContract = coinModel.coin['isContract'] as bool? ?? false;

    String totalGasPriceStr;
    String gasPriceStr;
    Color totalGasPriceColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    Widget gasLimitWidget = const SizedBox.shrink();

    // isContract 时统一使用主链精度
    int decimals = isContract
        ? (chainModel?.coin['decimals'] ?? 0)
        : coinModel.coin['decimals'] as int;

    if (blockchainType == BlockchainType.Ethereum.name) {
      final displayUnit = isContract
          ? (chainModel?.coin['unit'] ?? '').toString().toUpperCase()
          : coinModel.coin['unit'].toString().toUpperCase();
      if (isContract && totalGasPrice > (chainModel?.balance ?? BigInt.zero)) {
        totalGasPriceColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
      }
      totalGasPriceStr =
          '${Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())}$displayUnit';
      gasPriceStr =
          '${Decimal.parse(toGWei(gasPrice.toString()).toString())}Gwei';
      gasLimitWidget = _GasLimitRow(
        label: S.of(context).g_key_101,
        value: '$gas',
        useExpanded: true,
      );
    } else if (blockchainType == BlockchainType.Tron.name) {
      if (isContract &&
          toEther(totalGasPrice.toString(), decimals).toDouble() >
              (chainModel?.balanceDoubleAll() ?? 0)) {
        totalGasPriceColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
      }
      totalGasPriceStr = '${toEther(totalGasPrice.toString(), decimals)} $coinType';
      gasPriceStr = '${toEther(gasPrice.toString(), decimals)} $coinType';
      gasLimitWidget = _GasLimitRow(
        label: S.of(context).g_key_101,
        value: '$gas',
        useExpanded: false,
      );
    } else {
      totalGasPriceStr = '${toEther(totalGasPrice.toString(), decimals)} $coinType';
      gasPriceStr = '${toEther(gasPrice.toString(), decimals)} $coinType';
    }

    return containerStyle1(
      context,
      alignment: Alignment.center,
      margin:
          EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      child: Column(
        children: [
          if (isContract) _ChainBalanceRow(chainModel: chainModel),
          _FeeRow(
            label: S.of(context).g_key_t_17,
            value: gasPriceStr,
            valueColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
          gasLimitWidget,
          _FeeRow(
            label: S.of(context).g_key_t_16,
            value: totalGasPriceStr,
            valueColor: totalGasPriceColor,
            topMargin: ScreenUtil().setWidth(30.0),
          ),
        ],
      ),
    );
  }
}

/// 高级矿工费展示区块（带 Gas 选择器，仅 EVM 链有高级估算时使用）。
class AdvancedMinerFeeWidget extends StatelessWidget {
  const AdvancedMinerFeeWidget({
    super.key,
    required this.coinModel,
    required this.chainModel,
    required this.gasEstimate,
    required this.totalGasPrice,
    required this.onGasSettingsTap,
  });

  final CoinModel coinModel;
  final CoinModel? chainModel;
  final GasEstimateModel gasEstimate;
  final BigInt totalGasPrice;
  final VoidCallback onGasSettingsTap;

  @override
  Widget build(BuildContext context) {
    final isContract = coinModel.coin['isContract'] as bool? ?? false;
    final chainBalance = chainModel?.balance ?? BigInt.zero;
    final gasExceedsBalance = isContract && totalGasPrice > chainBalance;

    return Column(
      children: [
        if (isContract)
          containerStyle1(
            context,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30.0)),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30.0),
              vertical: ScreenUtil().setWidth(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_29,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainButtonBgColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: ScreenUtil().setWidth(20.0)),
        GasSelectorCompact(
          gasEstimate: gasEstimate,
          onTap: onGasSettingsTap,
        ),
        if (gasExceedsBalance)
          Container(
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(10.0),
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(30.0),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20.0),
              vertical: ScreenUtil().setWidth(10.0),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.errorBgColor2.name),
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(8.0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  size: ScreenUtil().setWidth(32.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                ),
                SizedBox(width: ScreenUtil().setWidth(10.0)),
                Expanded(
                  child: Text(
                    S.of(context).g_key_t_29(
                        chainModel?.coin['coinType'] ?? ''),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.errorTextColor.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 错误信息展示区块。
class SendErrorWidget extends StatelessWidget {
  const SendErrorWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorBgColor2.name),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
        ),
      ),
    );
  }
}

// ── 私有辅助 Widgets ──────────────────────────────────────────────────────────

class _ChainBalanceRow extends StatelessWidget {
  const _ChainBalanceRow({required this.chainModel});

  final CoinModel? chainModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).g_key_29,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.topMargin = 0,
  });

  final String label;
  final String value;
  final Color valueColor;
  final double topMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      alignment: Alignment.center,
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
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: ScreenUtil().setSp(28.0),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _GasLimitRow extends StatelessWidget {
  const _GasLimitRow({
    required this.label,
    required this.value,
    required this.useExpanded,
  });

  final String label;
  final String value;
  final bool useExpanded;

  @override
  Widget build(BuildContext context) {
    final labelColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final valueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final labelStyle =
        TextStyle(color: labelColor, fontSize: ScreenUtil().setSp(28.0));
    final valueStyle =
        TextStyle(color: valueColor, fontSize: ScreenUtil().setSp(28.0));

    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0)),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          SizedBox(width: ScreenUtil().setWidth(10)),
          if (useExpanded)
            Expanded(
              child: Text(value, style: valueStyle, textAlign: TextAlign.right),
            )
          else ...[
            Expanded(child: const SizedBox.shrink()),
            Text(value, style: valueStyle),
          ],
        ],
      ),
    );
  }
}
