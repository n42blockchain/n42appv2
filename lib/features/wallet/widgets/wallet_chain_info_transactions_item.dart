import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/security/address_label_service.dart';
import 'package:n42_wallet/features/wallet/api/tokenview_enhanced_api.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
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
  const WalletChainInfoTransactionsItem({
    required this.type,
    required this.transactionModel,
    required this.coinModel,
    required this.onBack,
    super.key,
  });

  bool get _isBtcType => type == 0;

  bool _isOutgoing() {
    if (_isBtcType) {
      final index = transactionModel.InputsAddress.indexWhere(
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
      return isOut
          ? transactionModel.OutputAddressStr
          : transactionModel.InputAddressStr;
    }
    return isOut ? transactionModel.to1 : transactionModel.from1;
  }

  String _errorIcon() {
    return _isBtcType ? "assets/img/remind.png" : "assets/img/error.png";
  }

  bool get _isMempoolTx => transactionModel is MempoolTxItem;

  @override
  Widget build(BuildContext context) {
    if (_isMempoolTx) return _buildMempoolTxCard(context);

    final isOut = _isOutgoing();

    return InkWell(
      onTap: () => _onItemTap(context),
      child: Card(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        elevation: 0,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(30.0),
            horizontal: ScreenUtil().setWidth(30.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间 + 箭头
              _buildTimeRow(context),
              const Divider(height: 10.0, indent: 0, endIndent: 0),
              // 方向图标 + 地址
              _buildDirectionRow(context, isOut),
              SizedBox(height: ScreenUtil().setWidth(20.0)),
              // 消息（仅非 BTC 类型）
              if (!_isBtcType && (transactionModel.message ?? "") != "") ...[
                Text(
                  '${transactionModel.message}',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                    fontSize: ScreenUtil().setSp(26.0),
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: ScreenUtil().setWidth(20.0)),
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
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26.0),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios_sharp,
          size: ScreenUtil().setWidth(30.0),
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainTextColor.name,
          ),
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
          margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
          child: Icon(
            isOut ? Icons.arrow_upward : Icons.arrow_downward,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemTextColor.name,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOut ? S.of(context).g_key_t_4 : S.of(context).g_key_t_5,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    isOut
                        ? AppThemeKeys.errorTextColor.name
                        : AppThemeKeys.rightTextColor.name,
                  ),
                  fontSize: ScreenUtil().setSp(30.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              EnsAddressText(
                address: _counterpartyAddress(isOut),
                coinType: coinModel?.coin['coinType'] ?? 'ETH',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemTextColor.name,
                  ),
                  fontSize: ScreenUtil().setSp(26.0),
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
            '${transactionModel.priceDouble()} ${transactionModel.coin['unit'].toUpperCase()}',
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
              fontSize: ScreenUtil().setSp(26.0),
            ),
          ),
        ),
        Text(
          getBuyStateText(transactionModel.state),
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
            fontSize: ScreenUtil().setSp(28.0),
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
            padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(20.0)),
              ),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.errorBgColor.name,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _errorIcon(),
                  width: ScreenUtil().setWidth(30.0),
                  height: ScreenUtil().setWidth(32.0),
                ),
                SizedBox(width: ScreenUtil().setWidth(10.0)),
                Text(
                  transactionModel.errorMessage,
                  maxLines: null,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.errorTextColor.name,
                    ),
                    fontSize: ScreenUtil().setSp(24.0),
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
    if (_isBtcType) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailPage(
            from: transactionModel.address,
            to: transactionModel.to1,
            txHash: transactionModel.txHash,
            value: transactionModel.priceDouble().toString(),
            coinType: transactionModel.coin['coinType'],
            time: transactionModel.getTxTimeStr(),
            isTest: coinModel?.isTest,
          ),
        ),
      );
      return;
    }

    final blockchainType = coinModel!.coin['blockchainType'];
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
            value: transactionModel.priceDouble().toString(),
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

    final Color tagColor;
    switch (label.riskLevel) {
      case 'danger':
        tagColor = const Color(0xFFF44336);
      case 'caution':
        tagColor = const Color(0xFFFF9800);
      default:
        tagColor = const Color(0xFF4CAF50);
    }

    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(4)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(8),
          vertical: ScreenUtil().setWidth(2),
        ),
        decoration: BoxDecoration(
          color: tagColor.withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
        ),
        child: Text(
          label.name,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(20),
            color: tagColor,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMempoolTxCard(BuildContext context) {
    final tx = transactionModel as MempoolTxItem;
    final su = ScreenUtil();
    final myAddr = coinModel?.address?.toString().toLowerCase() ?? '';
    final isOut = tx.from.toLowerCase() == myAddr;
    final counterparty = isOut ? tx.to : tx.from;

    return Card(
      margin: EdgeInsets.only(bottom: su.setWidth(30.0)),
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.itemBgColor.name,
      ),
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: su.setWidth(30.0),
          horizontal: su.setWidth(30.0),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.withAlpha(60), width: 1),
          borderRadius: BorderRadius.circular(su.setWidth(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mempool badge instead of time
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: su.setWidth(12),
                    vertical: su.setWidth(4),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(su.setWidth(8)),
                  ),
                  child: Text(
                    'Mempool',
                    style: TextStyle(
                      fontSize: su.setSp(22),
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Pending (Mempool)',
                  style: TextStyle(
                    fontSize: su.setSp(22),
                    color: Colors.orange,
                  ),
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
                  margin: EdgeInsets.only(right: su.setWidth(20.0)),
                  child: Icon(
                    isOut ? Icons.arrow_upward : Icons.arrow_downward,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemTextColor.name,
                    ),
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
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            isOut
                                ? AppThemeKeys.errorTextColor.name
                                : AppThemeKeys.rightTextColor.name,
                          ),
                          fontSize: su.setSp(30.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        counterparty.length > 16
                            ? '${counterparty.substring(0, 8)}...${counterparty.substring(counterparty.length - 8)}'
                            : counterparty,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemTextColor.name,
                          ),
                          fontSize: su.setSp(26.0),
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
