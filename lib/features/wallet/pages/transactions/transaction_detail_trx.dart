import 'dart:async';

import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transaction_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/prompt_widget.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class TransactionDetailTrx extends StatefulWidget {
  final String txHash;
  final CoinModel coinModel;
  const TransactionDetailTrx(this.coinModel, this.txHash, {super.key});

  @override
  State<TransactionDetailTrx> createState() => _TransactionDetailTrxState();
}

class _TransactionDetailTrxState extends State<TransactionDetailTrx> {
  late final TransactionApi transactionApi = TransactionApi();
  late final AppDatabase db = AppDatabase();
  late final TokenViewApi tokenViewApi = TokenViewApi();

  final searchEditingController = TextEditingController();
  Load load = Load.finish;
  String errorMessage = "";
  TransationRecordModel trm = TransationRecordModel();
  late String _txHash;
  Timer? _pollingTimer;
  late String _explorerUrl;

  @override
  void initState() {
    super.initState();
    _txHash = widget.txHash;
    searchEditingController.text = _txHash;
    _explorerUrl = getBrowserTxHash(
      widget.coinModel.coin['coinType'],
      _txHash,
      isTest: widget.coinModel.isTest,
    );
    init();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
  Map<String, dynamic>? transactionInfo;
  String resultStr = "Pending";
  String value = '';
  String gasPrice = '';
  bool owner = true;

  Future<void> init() async {
    if (_txHash.isEmpty) _txHash = searchEditingController.text;
    if (_txHash.isEmpty) {
      owner = false;
      return;
    }
    if (mounted) setState(() => load = Load.loading);

    final trModelList = await db.selectTransationRecordTxHash(
        _txHash, widget.coinModel.address);
    if (trModelList.isNotEmpty) trm = trModelList[0];

    final ok = await getTransactionByHash();
    if (!mounted) return;
    setState(() => load = ok ? Load.finish : Load.error);
  }

  Future<bool> getTransactionByHash() async {
    final rData = await transactionApi.trxTransactionInfoHash(_txHash);
    if (rData.error) {
      errorMessage = rData.data.toString();
      owner = false;
      return false;
    }
    if (rData.data == null) {
      errorMessage = "Not found";
      owner = false;
      return false;
    }

    transactionInfo = rData.data;
    trm.gas = transactionInfo?['cost']?['net_fee_cost'] ?? 0;
    trm.gasPriceValue = BigInt.from(transactionInfo?['cost']?['fee'] ?? 0);

    final confirmed = transactionInfo?['confirmed'] == true;
    resultStr = confirmed ? "Success" : "Pending";
    if (confirmed) {
      _stopPolling();
    } else {
      _startPolling();
    }

    final unit = widget.coinModel.coin['unit'];
    final decimals = widget.coinModel.coin['decimals'];
    value = '${toEther(trm.price.toString(), decimals)} $unit';
    gasPrice = '${toEther(trm.gasPrice.toString(), decimals)} $unit';
    owner = trm.from1.toLowerCase() ==
        (transactionInfo?['from'] ?? "").toString().toLowerCase();
    return true;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer(const Duration(seconds: 3), () async {
      await getTransactionByHash();
      if (mounted) setState(() {});
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_3,
        actions: _explorerUrl.isNotEmpty ? [
          IconButton(
            icon: const Icon(Icons.open_in_browser_outlined),
            tooltip: S.of(context).g_key_196,
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BrowserPage(_explorerUrl))),
          ),
        ] : null,
      ),
      body: bodyWidget(),
    );
  }
  Widget bodyWidget() {
    return SafeArea(
      child: Column(
        children: [
          searchWidget(),
          Expanded(
            child: load == Load.error ? errorWidget() : txDataWidget(),
          ),
        ],
      ),
    );
  }

  Widget errorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: init,
          child: Container(
            height: ScreenUtil().setWidth(80),
            width: ScreenUtil().setWidth(80),
            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
            child: Icon(
              Icons.refresh,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
            ),
          ),
        ),
        errorMessageWidget(),
      ],
    );
  }
  Widget _divider() => Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
      );

  Widget txDataWidget() {
    if (transactionInfo == null) {
      return const IntrinsicHeight(child: Center(child: EmptyView()));
    }
    final s = S.of(context);
    final info = transactionInfo!;
    return SingleChildScrollView(
      child: Column(
        children: [
          itemWidget(s.g_key_wallet_k37, info['hash'] ?? "", copy: true),
          _divider(),
          itemWidget(s.g_key_wallet_k33, resultStr),
          _divider(),
          itemWidget(s.g_key_wallet_k54, info['block'].toString(), copy: true),
          _divider(),
          addressItemWidget(s.g_key_75, info['ownerAddress'] ?? ""),
          _divider(),
          addressItemWidget(s.g_key_38, trm.to1),
          _divider(),
          itemWidget(s.g_key_wallet_k55, value),
          _divider(),
          itemWidget(s.g_key_t_15, gasPrice),
          errorMessageWidget(),
          SizedBox(height: ScreenUtil().setWidth(140)),
        ],
      ),
    );
  }
  void _searchAndReload() {
    closeKeyboard();
    init();
  }

  Widget searchWidget() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
      ),
      height: ScreenUtil().setWidth(72.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26.0),
              ),
              controller: searchEditingController,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(10.0)),
                hintText: S.of(context).search,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
              maxLines: 1,
              onEditingComplete: _searchAndReload,
            ),
          ),
          InkWell(
            onTap: _searchAndReload,
            child: SizedBox(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              child: Icon(
                Icons.search,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20.0)),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorBgColor2.name),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget itemWidget(String title, String value, {bool copy = false}) {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: blueColor, fontSize: ScreenUtil().setSp(28)),
                ),
              ),
              if (copy)
                InkWell(
                  onTap: () {
                    ToastUtils.init(context);
                    Clipboard.setData(ClipboardData(text: value));
                    ToastUtils.showFtToast(
                      child: successViewV1(S.of(context).copy),
                      duration: 3,
                    );
                  },
                  child: SizedBox(
                    height: ScreenUtil().setWidth(50),
                    width: ScreenUtil().setWidth(50),
                    child: Icon(Icons.copy, color: blueColor),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 地址显示组件（支持 ENS）
  Widget addressItemWidget(String title, String address) {
    if (address.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          EnsAddressDisplay(
            address: address,
            coinType: widget.coinModel.coin['coinType'] ?? 'TRX',
            style: EnsDisplayStyle.full,
            showAvatar: true,
            showCopy: true,
            fontSize: ScreenUtil().setSp(28),
          ),
        ],
      ),
    );
  }
}
