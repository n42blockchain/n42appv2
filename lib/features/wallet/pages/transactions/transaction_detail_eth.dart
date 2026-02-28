import 'dart:async';
import 'dart:convert';

import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/prompt_widget.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_retry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'transaction_detail_eth_sections.dart';

bool _isReceiptSuccess(dynamic status) {
  if (status == null) return false;
  if (status is bool) return status;
  if (status is int) return status == 1;
  final s = status.toString().toLowerCase().trim();
  if (s == '1' || s == 'true') return true;
  final hex = s.startsWith('0x') ? s.substring(2) : s;
  final n = int.tryParse(hex, radix: 16);
  return n != null && n == 1;
}

class TransactionDetailEth extends StatefulWidget {
  final String txHash;
  final CoinModel coinModel;
  const TransactionDetailEth(this.coinModel,this.txHash,{super.key});

  @override
  State<TransactionDetailEth> createState() => _TransactionDetailEthState();
}

class _TransactionDetailEthState extends State<TransactionDetailEth> {
  late final EthAPI ethAPI = EthAPI();
  late final AppDatabase db = AppDatabase();
  late final TokenViewApi tokenViewApi = TokenViewApi();

  TextEditingController searchEditingController = TextEditingController();
  Load load = Load.finish;
  String errorMessage = "";
  TransationRecordModel trm = TransationRecordModel();
  late String _txHash;
  Timer? _pollingTimer;
  late String _explorerUrl;

  @override
  void initState() {
    _txHash = widget.txHash;
    searchEditingController.text = _txHash;
    _explorerUrl = getBrowserTxHash(
      widget.coinModel.coin['coinType'],
      _txHash,
      isTest: widget.coinModel.isTest,
    );
    init();
    super.initState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    errorMessage = "";
    if (_txHash.isEmpty) _txHash = searchEditingController.text;
    if (_txHash.isEmpty) {
      owner = false;
      return;
    }
    if (mounted) setState(() => load = Load.loading);
    final trModelList = await db.selectTransationRecordTxHash(_txHash, widget.coinModel.address);
    if (trModelList.isNotEmpty) {
      trm = trModelList[0];
    }
    final success = await getTransactionByHash();
    if (!mounted) return;
    if (!success) {
      setState(() => load = Load.error);
      return;
    }
    await getTransactionReceipt();
    if (!mounted) return;
    setState(() => load = Load.finish);
  }

  Map<String, dynamic>? transactionInfo;
  Map<String, dynamic>? transactionInfoReceipt;
  String resultStr = "Pending";
  String value = '';
  String gasPrice = '';
  String gasLimit = '';
  String nonce = "";
  bool owner = true; // 是否是自己的交易信息

  Future<bool> getTransactionByHash() async {
    final rData = await ethAPI.getTransactionByHash(
      _txHash,
      coinType: widget.coinModel.coin['coinType'],
    );
    if (rData.error != false) {
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
    trm.gas = hexToInt(transactionInfo!['gas'] ?? "0x0").toInt();
    trm.gasPriceValue = hexToInt(transactionInfo!['gasPrice'] ?? "0x0");
    resultStr = "Pending";
    gasPrice = '${toGWei(trm.gasPriceValue.toString())} GWei';
    gasLimit = '${trm.gas}';
    nonce = '${hexToInt(transactionInfo!['nonce'] ?? "0x0").toInt()}';

    final decimals = widget.coinModel.coin['decimals'];
    final unit = widget.coinModel.coin['unit'];

    if (trm.contract == "") {
      try {
        trm.message = utf8.decode(hexToBytes(transactionInfo!['input']));
      } catch (_) {
        trm.message = "";
      }
      trm.to1 = transactionInfo!['to'];
      trm.price = hexToInt(transactionInfo!['value'] ?? "0x0");
      value = '${toEther(trm.price.toString(), decimals)} $unit';
    } else {
      try {
        trm.message = "";
        final input = transactionInfo!['input'] as String;
        trm.to1 = "0x${input.substring(34, 74)}";
        trm.price = hexToInt(input.substring(74, 138));
        value = '${toEther(trm.price.toString(), decimals)} $unit';
      } catch (_) {}
    }
    owner = trm.from1.toLowerCase() == (transactionInfo?['from'] ?? "").toString().toLowerCase();
    return true;
  }

  Future<void> getTransactionReceipt() async {
    final rData = await ethAPI.getTransactionReceipt(
      _txHash,
      coinType: widget.coinModel.coin['coinType'],
    );
    if (rData.error != false) {
      errorMessage = rData.data.toString();
      return;
    }
    transactionInfoReceipt = rData.data;
    if (transactionInfoReceipt != null) {
      resultStr = _isReceiptSuccess(transactionInfoReceipt!['status'])
          ? "Success"
          : "Failed";
      return;
    }
    errorMessage = "";
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer(const Duration(seconds: 3), () async {
      await getTransactionReceipt();
      if (mounted) setState(() {});
    });
  }

  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_3,
        actions: _explorerUrl.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.open_in_browser_outlined),
                  tooltip: S.of(context).g_key_196,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BrowserPage(_explorerUrl)),
                  ),
                ),
              ]
            : null,
      ),
      body: bodyWidget(),
    );
  }

  Widget bodyWidget() {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                buildSearchWidget(),
                Expanded(
                  child: load == Load.error
                      ? buildErrorWidget()
                      : buildTxDataWidget(),
                ),
              ],
            ),
          ),
          if (resultStr == "Pending" && owner && load == Load.finish)
            buildPendingActionBar(),
        ],
      ),
    );
  }
}
