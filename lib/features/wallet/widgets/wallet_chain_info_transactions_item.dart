import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/security/address_label_service.dart';
import 'package:n42_wallet/features/wallet/api/tokenview_enhanced_api.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show toEther;
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_eth.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_page.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_trx.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletChainInfoTransactionsItem extends StatelessWidget {
  final int? type; //0 BTC类型的 1 除了btc其它类型的
  final dynamic transactionModel;
  final CoinModel? coinModel;
  final dynamic onBack;

  /// Local aggregate history has no signing account or derivation context.
  final bool readOnly;
  const WalletChainInfoTransactionsItem({
    required this.type,
    required this.transactionModel,
    required this.coinModel,
    required this.onBack,
    this.readOnly = false,
    super.key,
  });

  bool get _isBtcType => type == 0;

  String get _amountLabel =>
      '${toEther(transactionModel.price.toString(), transactionModel.coin['decimals'] ?? 0)} '
      '${transactionModel.coin['unit'].toString().toUpperCase()}';

  bool _isOutgoing() {
    if (_isBtcType) {
      final tx = transactionModel as BtcTransactionRecodeModel;
      final index = tx.inputsAddressList.indexWhere(
        (e) =>
            coinModel!.address.toString().toUpperCase() ==
            e.toString().toUpperCase(),
      );
      return index != -1;
    }
    return transactionModel.from1.toString().toLowerCase() ==
        coinModel!.address.toString().toLowerCase();
  }

  String _counterpartyAddress(bool isOut) {
    if (_isBtcType) {
      final tx = transactionModel as BtcTransactionRecodeModel;
      return isOut ? tx.outputAddressStrValue : tx.inputAddressStrValue;
    }
    return isOut ? transactionModel.to1 : transactionModel.from1;
  }

  String _errorIcon() {
    return _isBtcType ? "assets/img/remind.png" : "assets/img/error.png";
  }

  bool get _isMempoolTx => transactionModel is MempoolTxItem;

  String get _coinTypeForEns {
    final coinType = coinModel?.config.coinType;
    return coinType == null || coinType.isEmpty ? 'ETH' : coinType;
  }

  @override
  Widget build(BuildContext context) {
    if (_isMempoolTx) return _buildMempoolTxCard(context);

    final isOut = _isOutgoing();

    return InkWell(
      onTap: () => _onItemTap(context),
      child: Card(
        margin: EdgeInsets.only(bottom: AppSpacing.space8),
        color: AppColorTokens.of(context).bgSurface,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.space8,
            horizontal: AppSpacing.space8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间 + 箭头
              _buildTimeRow(context),
              const Divider(height: 10.0, indent: 0, endIndent: 0),
              // 方向图标 + 地址
              _buildDirectionRow(context, isOut),
              SizedBox(height: AppSpacing.space4),
              // 消息（仅非 BTC 类型）
              if (!_isBtcType && (transactionModel.message ?? "") != "") ...[
                Text(
                  '${transactionModel.message}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: AppSpacing.space4),
              ],
              // 金额 + 状态
              _buildAmountRow(context),
              // 错误状态
              _buildErrorSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context) {
    return Row(
      children: [
        Text(
          transactionModel.getTxTimeStr(),
          style: AppTypography.bodySm.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios_sharp,
          size: ScreenUtil().setWidth(30.0),
          color: AppColorTokens.of(context).textPrimary,
        ),
      ],
    );
  }

  Widget _buildDirectionRow(BuildContext context, bool isOut) {
    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(80.0),
          height: ScreenUtil().setWidth(80.0),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonBgColor3.name,
            ),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(80.0)),
          ),
          margin: EdgeInsets.only(right: AppSpacing.space4),
          child: Icon(
            isOut ? Icons.arrow_upward : Icons.arrow_downward,
            color: AppColorTokens.of(context).textItem,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOut ? S.of(context).g_key_t_4 : S.of(context).g_key_t_5,
                style: AppTypography.bodyStrong.copyWith(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    isOut
                        ? AppThemeKeys.errorTextColor.name
                        : AppThemeKeys.rightTextColor.name,
                  ),
                ),
              ),
              EnsAddressText(
                address: _counterpartyAddress(isOut),
                coinType: _coinTypeForEns,
                style: AppTypography.bodySm.copyWith(
                  color: AppColorTokens.of(context).textItem,
                ),
              ),
              _buildAddressLabel(context, _counterpartyAddress(isOut)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _amountLabel,
            style: AppTypography.bodySm.copyWith(
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
        ),
        Text(
          getBuyStateText(transactionModel.state),
          style: AppTypography.body.copyWith(
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(BuildContext context) {
    return Visibility(
      visible: transactionModel.state == 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: ScreenUtil().setWidth(20.0), indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(AppSpacing.space4),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: AppRadius.brMd,
              color: AppColorTokens.of(context).dangerBg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _errorIcon(),
                  width: ScreenUtil().setWidth(30.0),
                  height: ScreenUtil().setWidth(32.0),
                ),
                SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    transactionModel.errorMessage,
                    style: AppTypography.caption.copyWith(
                      color: AppColorTokens.of(context).danger,
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

  Future<void> _pushAndCallback(BuildContext context, Widget page) async {
    final r = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (!context.mounted) return;
    if (r == true) onBack();
  }

  Future<void> _onItemTap(BuildContext context) async {
    if (_isBtcType || readOnly) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailPage(
            from: _isBtcType
                ? transactionModel.address
                : transactionModel.from1,
            to: transactionModel.to1,
            txHash: transactionModel.txHash,
            value: _amountLabel,
            coinType: transactionModel.coin['coinType'],
            time: transactionModel.getTxTimeStr(),
            isTest: coinModel?.isTest,
          ),
        ),
      );
      return;
    }

    final blockchainType = coinModel!.config.blockchainType;
    final txHash = transactionModel.txHash;

    if (blockchainType == BlockchainType.Ethereum.name) {
      _pushAndCallback(context, TransactionDetailEth(coinModel!, txHash));
    } else if (blockchainType == BlockchainType.Tron.name) {
      _pushAndCallback(context, TransactionDetailTrx(coinModel!, txHash));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailPage(
            from: transactionModel.from1,
            to: transactionModel.to1,
            txHash: txHash,
            value: _amountLabel,
            coinType: transactionModel.coin['coinType'],
            time: transactionModel.getTxTimeStr(),
            isTest: coinModel?.isTest,
          ),
        ),
      );
    }
  }

  /// 获取交易状态文本
  String getBuyStateText(int state) => switch (state) {
    0 => S.current.g_key_t_2,
    1 => S.current.g_key_t_1,
    2 => S.current.g_key_t_3,
    _ => "",
  };

  Widget _buildAddressLabel(BuildContext context, String address) {
    final label = AddressLabelService.getLabel(address);
    if (label == null) return const SizedBox.shrink();

    final tokens = AppColorTokens.of(context);
    final Color tagColor;
    switch (label.riskLevel) {
      case 'danger':
        tagColor = tokens.danger;
      case 'caution':
        tagColor = tokens.warning;
      default:
        tagColor = tokens.success;
    }

    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(4)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: tagColor.withAlpha(20),
          borderRadius: AppRadius.brSm,
        ),
        child: Text(
          label.name,
          style: AppTypography.captionSm.copyWith(color: tagColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMempoolTxCard(BuildContext context) {
    final tx = transactionModel as MempoolTxItem;
    final su = ScreenUtil();
    final warn = AppColorTokens.of(context).warning;
    final myAddr = coinModel?.address?.toString().toLowerCase() ?? '';
    final isOut = tx.from.toLowerCase() == myAddr;
    final counterparty = isOut ? tx.to : tx.from;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.space8),
      color: AppColorTokens.of(context).bgSurface,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.space8,
          horizontal: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: warn.withAlpha(60), width: 1),
          borderRadius: AppRadius.brMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mempool badge instead of time
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.space2,
                    vertical: AppSpacing.space2,
                  ),
                  decoration: BoxDecoration(
                    color: warn.withAlpha(30),
                    borderRadius: AppRadius.brSm,
                  ),
                  child: Text(
                    S.of(context).g_ui_mempool,
                    style: AppTypography.captionSm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: warn,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  S.of(context).g_ui_pending_mempool,
                  style: AppTypography.captionSm.copyWith(color: warn),
                ),
              ],
            ),
            const Divider(height: 10.0),
            // Direction + address
            Row(
              children: [
                Container(
                  width: su.setWidth(80.0),
                  height: su.setWidth(80.0),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainButtonBgColor3.name,
                    ),
                    borderRadius: BorderRadius.circular(su.setWidth(80.0)),
                  ),
                  margin: EdgeInsets.only(right: AppSpacing.space4),
                  child: Icon(
                    isOut ? Icons.arrow_upward : Icons.arrow_downward,
                    color: AppColorTokens.of(context).textItem,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOut
                            ? S.of(context).g_key_t_4
                            : S.of(context).g_key_t_5,
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            isOut
                                ? AppThemeKeys.errorTextColor.name
                                : AppThemeKeys.rightTextColor.name,
                          ),
                        ),
                      ),
                      Text(
                        counterparty.length > 16
                            ? '${counterparty.substring(0, 8)}...${counterparty.substring(counterparty.length - 8)}'
                            : counterparty,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColorTokens.of(context).textItem,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
