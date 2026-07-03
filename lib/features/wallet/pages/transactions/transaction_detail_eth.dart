import 'dart:async';
import 'dart:convert';

import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/evm_transaction_hash_input.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/evm_transaction_requests.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_record_helpers.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/prompt_widget.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
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

bool shouldContinueEthReceiptPolling({
  required bool requestError,
  required Map<String, dynamic>? receipt,
}) {
  return requestError || receipt == null;
}

class TransactionDetailEth extends StatefulWidget {
  final String txHash;
  final CoinModel coinModel;
  const TransactionDetailEth(this.coinModel, this.txHash, {super.key});

  @override
  State<TransactionDetailEth> createState() => _TransactionDetailEthState();
}

class _TransactionDetailEthState extends State<TransactionDetailEth> {
  static const _invalidTransactionHashMessage = 'Invalid transaction hash';

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
      widget.coinModel.config.coinType,
      _txHash,
      isTest: widget.coinModel.isTest,
    );
    init();
    super.initState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    searchEditingController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    _pollingTimer?.cancel();
    transactionInfo = null;
    transactionInfoReceipt = null;
    resultStr = "Pending";
    errorMessage = "";
    final normalizedTxHash = normalizeEvmTransactionHashInput(
      searchEditingController.text,
    );
    _txHash = normalizedTxHash ?? '';
    if (normalizedTxHash != null &&
        searchEditingController.text != normalizedTxHash) {
      searchEditingController.value = TextEditingValue(
        text: normalizedTxHash,
        selection: TextSelection.collapsed(offset: normalizedTxHash.length),
      );
    }
    _explorerUrl = _txHash.isEmpty
        ? ''
        : getBrowserTxHash(
            widget.coinModel.config.coinType,
            _txHash,
            isTest: widget.coinModel.isTest,
          );
    if (searchEditingController.text.trim().isEmpty) {
      owner = false;
      return;
    }
    if (normalizedTxHash == null) {
      owner = false;
      if (mounted) {
        setState(() {
          errorMessage = _invalidTransactionHashMessage;
          load = Load.error;
        });
      }
      return;
    }
    if (mounted) setState(() => load = Load.loading);
    final trModelList = await db.selectTransationRecordTxHash(
      _txHash,
      widget.coinModel.address,
    );
    if (trModelList.isNotEmpty) {
      trm = trModelList[0];
    } else {
      trm = buildFallbackTransactionRecord(widget.coinModel);
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
    final rData = await fetchEvmTransactionByHash(
      ethAPI,
      txHash: _txHash,
      coinType: widget.coinModel.config.coinType,
      isTest: widget.coinModel.isTest,
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
    errorMessage = "";
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
      } catch (_) {
        // intentional parse fallback: input may not contain valid transfer data
      }
    }
    owner =
        trm.from1.toLowerCase() ==
        (transactionInfo?['from'] ?? "").toString().toLowerCase();
    return true;
  }

  /// 该交易是否可被加速/取消：是自己发出的、仍在 pending（无回执）、且已从
  /// 链上拿到原交易数据（含 nonce/gasPrice）。
  bool get _canReplace =>
      owner &&
      transactionInfo != null &&
      transactionInfoReceipt == null &&
      (transactionInfo!['nonce'] != null);

  bool _replacing = false;

  /// 交易加速（isCancel=false）或取消（isCancel=true）——replace-by-fee：
  /// 复用原交易 nonce，用提价 20% 的 gasPrice 广播一笔覆盖交易。
  /// - 加速：重放原交易（原生带 value；合约带原始 calldata）。
  /// - 取消：0 值自转，仅为占用同一 nonce 使原交易作废。
  Future<void> _replaceTx(bool isCancel) async {
    final info = transactionInfo;
    if (info == null || _replacing) return;

    final origNonce = hexToInt(info['nonce'] ?? '0x0');
    final origGasPrice = hexToInt(info['gasPrice'] ?? '0x0');
    // 覆盖交易的 gasPrice 必须高于原值矿工才会替换；提价 20%（RBF 常规下限约
    // +10%，留足余量）。
    final bumpedGasPrice = origGasPrice * BigInt.from(12) ~/ BigInt.from(10);

    final cm = widget.coinModel;
    final basePath =
        cm.config.pathForAddrType(cm.addrType) ?? "m/44'/60'/0'/0/0";
    final path = getPathWithIndex(basePath, cm.pathIndex);
    final decimals = (cm.coin['decimals'] as num?)?.toInt() ?? 18;

    final SendParams params;
    if (isCancel) {
      params = SendParams(
        coinType: cm.config.coinType,
        fromAddress: cm.address,
        toAddress: cm.address,
        amount: 0,
        decimals: decimals,
        path: path,
        isTest: cm.isTest,
        privateKey: cm.privateKey,
        chainConfig: cm.coin,
        nonceOverride: origNonce,
        gasPriceOverride: bumpedGasPrice,
      );
    } else {
      final input = (info['input'] as String?) ?? '0x';
      final hasCalldata = input.length > 2 && input != '0x';
      final origValue = hexToInt(info['value'] ?? '0x0');
      params = SendParams(
        coinType: cm.config.coinType,
        fromAddress: cm.address,
        toAddress: (info['to'] as String?) ?? cm.address,
        amount: toEther(origValue.toString(), decimals).toDouble(),
        decimals: decimals,
        path: path,
        isTest: cm.isTest,
        privateKey: cm.privateKey,
        chainConfig: cm.coin,
        calldata: hasCalldata ? input : null,
        nonceOverride: origNonce,
        gasPriceOverride: bumpedGasPrice,
      );
    }

    setState(() => _replacing = true);
    final result = await SenderFactory.instance
        .getSender(cm.config.coinType)
        .send(params);
    if (!mounted) return;
    setState(() => _replacing = false);
    if (result.success) {
      ToastUtils.show(S.of(context).g_key_wallet_tx_replace_submitted);
      // 覆盖交易是新 hash，用它刷新详情。
      searchEditingController.text = result.txHash ?? _txHash;
      await init();
    } else {
      ToastUtils.show(result.error ?? S.of(context).g_key_191);
    }
  }

  Future<void> getTransactionReceipt() async {
    final rData = await fetchEvmTransactionReceipt(
      ethAPI,
      txHash: _txHash,
      coinType: widget.coinModel.config.coinType,
      isTest: widget.coinModel.isTest,
    );
    final requestError = rData.error != false;
    final receipt = rData.data as Map<String, dynamic>?;
    transactionInfoReceipt = receipt;
    if (!shouldContinueEthReceiptPolling(
      requestError: requestError,
      receipt: receipt,
    )) {
      errorMessage = "";
      resultStr = _isReceiptSuccess(transactionInfoReceipt!['status'])
          ? "Success"
          : "Failed";
      return;
    }
    errorMessage = requestError ? rData.data.toString() : "";
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
    FocusScope.of(context).unfocus();
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
                    MaterialPageRoute(
                      builder: (_) => BrowserPage(_explorerUrl),
                    ),
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
        ],
      ),
    );
  }
}
