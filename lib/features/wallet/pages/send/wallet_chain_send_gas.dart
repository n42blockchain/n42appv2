import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
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
    final blockchainType = coinModel.config.blockchainType;
    final coinType = coinModel.config.coinType;
    final isContract = coinModel.config.isContract;
    final isEthereum = blockchainType == BlockchainType.Ethereum.name;
    final isTron = blockchainType == BlockchainType.Tron.name;

    final decimals = isContract
        ? (chainModel?.coin['decimals'] ?? 0)
        : (coinModel.coin['decimals'] as num?)?.toInt() ?? 18;

    var totalGasPriceColor = AppColorTokens.of(context).textPrimary;
    final errorColor = AppColorTokens.of(context).danger;

    String totalGasPriceStr;
    String gasPriceStr;
    Widget gasLimitWidget = const SizedBox.shrink();

    if (isEthereum) {
      final displayUnit = isContract
          ? (chainModel?.coin['unit'] ?? '').toString().toUpperCase()
          : coinModel.coin['unit'].toString().toUpperCase();
      if (isContract && totalGasPrice > (chainModel?.balance ?? BigInt.zero)) {
        totalGasPriceColor = errorColor;
      }
      totalGasPriceStr =
          '${Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())}$displayUnit';
      gasPriceStr =
          '${Decimal.parse(toGWei(gasPrice.toString()).toString())}Gwei';
      gasLimitWidget = _GasLimitRow(
        label: S.of(context).g_key_101,
        value: '$gas',
      );
    } else if (isTron) {
      if (isContract &&
          toEther(totalGasPrice.toString(), decimals).toDouble() >
              (chainModel?.balanceDoubleAll() ?? 0)) {
        totalGasPriceColor = errorColor;
      }
      totalGasPriceStr =
          '${toEther(totalGasPrice.toString(), decimals)} $coinType';
      gasPriceStr = '${toEther(gasPrice.toString(), decimals)} $coinType';
      gasLimitWidget = _GasLimitRow(
        label: S.of(context).g_key_101,
        value: '$gas',
      );
    } else {
      totalGasPriceStr =
          '${toEther(totalGasPrice.toString(), decimals)} $coinType';
      gasPriceStr = '${toEther(gasPrice.toString(), decimals)} $coinType';
    }

    return containerStyle1(
      context,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space8,
      ),
      child: Column(
        children: [
          if (isContract) _ChainBalanceRow(chainModel: chainModel),
          _FeeRow(
            label: S.of(context).g_key_t_17,
            value: gasPriceStr,
            valueColor: AppColorTokens.of(context).textPrimary,
          ),
          gasLimitWidget,
          _FeeRow(
            label: S.of(context).g_key_t_16,
            value: totalGasPriceStr,
            valueColor: totalGasPriceColor,
            topMargin: AppSpacing.space8,
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
    final isContract = coinModel.config.isContract as bool? ?? false;
    final chainBalance = chainModel?.balance ?? BigInt.zero;
    final gasExceedsBalance = isContract && totalGasPrice > chainBalance;

    return Column(
      children: [
        if (isContract)
          containerStyle1(
            context,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    S.of(context).g_key_29,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: AppColorTokens.of(context).textSubtitle,
                    ),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: AppTypography.body.copyWith(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainButtonBgColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: AppSpacing.space4),
        GasSelectorCompact(gasEstimate: gasEstimate, onTap: onGasSettingsTap),
        if (gasExceedsBalance)
          Container(
            margin: EdgeInsets.only(
              top: AppSpacing.space2,
              left: AppSpacing.space8,
              right: AppSpacing.space8,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.errorBgColor2.name,
              ),
              borderRadius: AppRadius.brSm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  size: ScreenUtil().setWidth(32.0),
                  color: AppColorTokens.of(context).danger,
                ),
                SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    S
                        .of(context)
                        .g_key_t_29(chainModel?.coin['coinType'] ?? ''),
                    style: AppTypography.caption.copyWith(
                      color: AppColorTokens.of(context).danger,
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
        top: AppSpacing.space4,
        left: AppSpacing.space8,
        right: AppSpacing.space8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space8,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.errorBgColor2.name,
        ),
      ),
      child: Text(
        message,
        style: AppTypography.body.copyWith(
          color: AppColorTokens.of(context).danger,
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
      margin: EdgeInsets.only(bottom: AppSpacing.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              S.of(context).g_key_29,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
              style: AppTypography.body.copyWith(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainButtonBgColor.name,
                ),
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(color: valueColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _GasLimitRow extends StatelessWidget {
  const _GasLimitRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelColor = AppColorTokens.of(context).textSubtitle;
    final valueColor = AppColorTokens.of(context).textPrimary;

    return Container(
      margin: EdgeInsets.only(top: AppSpacing.space8),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(color: labelColor),
            ),
          ),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(color: valueColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
