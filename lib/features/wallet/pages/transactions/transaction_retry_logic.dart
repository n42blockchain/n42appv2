part of 'transaction_retry.dart';

/// Business logic mixin for [_TransactionRetryState].
///
/// Handles transaction lookup, receipt polling, speed-up / cancel
/// submission, and database persistence.
mixin _TransactionRetryLogicMixin on ConsumerState<TransactionRetry> {
  EthAPI? _ethAPI;
  EthAPI get ethAPI {
    _ethAPI ??= EthAPI();
    return _ethAPI!;
  }

  AppDatabase? _db;
  AppDatabase get db {
    _db ??= AppDatabase();
    return _db!;
  }

  final TextEditingController searchEditingController = TextEditingController();

  Load load = Load.finish;
  String errorMessage = '';
  TransationRecordModel trm = TransationRecordModel();

  TokenViewApi? _tokenViewApiInstance;
  TokenViewApi get tokenViewApi {
    _tokenViewApiInstance ??= TokenViewApi();
    return _tokenViewApiInstance!;
  }

  late String _txHash;
  late String _explorerUrl;

  Map<String, dynamic>? transactionInfo;
  Map<String, dynamic>? transactionInfoReceipt;
  String resultStr = 'Pending';
  String value = '';
  String gasPrice = '';
  String gasLimit = '';
  String nonce = '';
  bool owner = true; // 是否是自己的交易信息
  BigInt _originalGasPriceValue = BigInt.zero;
  Timer? timer;

  void _setLoadState(Load state) {
    if (mounted) setState(() => load = state);
  }

  Future<void> init() async {
    if (_txHash.isEmpty) _txHash = searchEditingController.text;
    if (_txHash.isEmpty) {
      owner = false;
      return;
    }
    _setLoadState(Load.loading);
    final trModelList = await db.selectTransationRecordTxHash(
        _txHash, widget.coinModel.address);
    if (!mounted) return;
    if (trModelList.isNotEmpty) {
      trm = trModelList[0];
    } else {
      final cm = widget.coinModel;
      trm = TransationRecordModel()
        ..address = cm.address.toString()
        ..from1 = cm.address.toString()
        ..addrType = cm.addrType
        ..coin = cm.coin
        ..coinMiniName = cm.coin['coinType']
        ..walletIndex = ref.read(wapBridgeProvider).walletIndex
        ..contract = cm.isTest ? cm.coin['contract_test'] : cm.coin['contract']
        ..isTest = cm.isTest ? 1 : 0
        ..gasPrice = BigInt.zero
        ..gasPriceValue = BigInt.zero
        ..coinId = cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId'];
    }
    final r = await getTransactionByHash();
    if (r) {
      await getTransactionReceipt();
      _setLoadState(Load.finish);
    } else {
      _setLoadState(Load.error);
    }
  }

  Future<bool> getTransactionByHash() async {
    final rData = await ethAPI.getTransactionByHash(
      _txHash,
      coinType: widget.coinModel.coin['coinType'],
    );
    if (rData.error) {
      errorMessage = rData.data.toString();
      owner = false;
      return false;
    }
    if (rData.data == null) {
      errorMessage = 'Not found';
      owner = false;
      return false;
    }
    transactionInfo = rData.data;
    trm.gas = hexToInt(transactionInfo!['gas'] ?? '0x0').toInt();
    trm.gasPriceValue = hexToInt(transactionInfo!['gasPrice'] ?? '0x0');
    _originalGasPriceValue = trm.gasPriceValue;
    resultStr = 'Pending';
    gasPrice = '${toGWei(trm.gasPriceValue.toString())} GWei';
    gasLimit = '${trm.gas}';
    nonce = '${hexToInt(transactionInfo!['nonce'] ?? '0x0').toInt()}';

    final coin = widget.coinModel.coin;
    final valueUnit = '${coin['unit']}';

    if (trm.contract == '') {
      try {
        trm.message = utf8.decode(hexToBytes(transactionInfo!['input']));
      } catch (_) {
        trm.message = '';
      }
      trm.to1 = transactionInfo!['to'];
      trm.price = hexToInt(transactionInfo!['value'] ?? '0x0');
    } else {
      try {
        trm.message = '';
        final input = transactionInfo!['input'];
        trm.to1 = '0x${input.substring(10, 74).substring(24)}';
        trm.price = hexToInt(input.substring(74, 138));
      } catch (_) {}
    }
    value = '${toEther(trm.price.toString(), coin['decimals'])} $valueUnit';
    owner = trm.from1.toLowerCase() ==
        (transactionInfo?['from'] ?? '').toString().toLowerCase();
    return true;
  }

  Future<void> getTransactionReceipt() async {
    final rData = await ethAPI.getTransactionReceipt(
      _txHash,
      coinType: widget.coinModel.coin['coinType'],
    );
    if (!rData.error) {
      transactionInfoReceipt = rData.data;
      if (transactionInfoReceipt != null) {
        resultStr = _isReceiptSuccess(transactionInfoReceipt!['status'])
            ? 'Success'
            : 'Failed';
        return;
      }
      errorMessage = '';
    } else {
      errorMessage = rData.data.toString();
    }
    timerInit();
  }

  void timerInit() {
    timer = Timer(const Duration(seconds: 3), () {
      getTransactionReceipt();
    });
  }

  Future<void> send(String toAddress, BigInt transferValue,
      {bool isCancel = false}) async {
    if (load == Load.loading || errorMessage.isNotEmpty || !mounted) return;
    _setLoadState(Load.loading);
    try {
      final bool isEip1559 = transactionInfo!['gasPrice'] == '0x0' ||
          _originalGasPriceValue == BigInt.zero;
      final String? customRpc = widget.coinModel.coin['custom'] == true
          ? (widget.coinModel.isTest
              ? widget.coinModel.coin['service_test']
              : widget.coinModel.coin['service'])
          : null;

      BigInt newGasPriceValue;
      if (isEip1559) {
        final mm = await tokenViewApi.getGasPrice(
              BlockchainType.Ethereum.name,
              trm.coinMiniName,
              rpc: customRpc,
            ) ??
            MessageModel.error();
        if (!mounted) return;
        if (mm.error) {
          _setLoadState(Load.finish);
          ToastUtils.show(mm.data);
          return;
        }
        newGasPriceValue = (mm.data as BigInt) * BigInt.from(3) ~/ BigInt.from(2);
      } else {
        newGasPriceValue = _originalGasPriceValue * BigInt.from(3) ~/ BigInt.from(2);
      }

      if (isCancel) {
        final cancelTrm = _buildCancelTrm(newGasPriceValue);
        final check = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WalletBaseSend(cancelTrm, null, cancelTrm.coin['unit'])),
        );
        if (!mounted) return;
        if (!check) { _setLoadState(Load.finish); return; }
        final mm = await TransferApi().transferWallet(
          trModel: cancelTrm,
          privateKey: widget.coinModel.privateKey,
          pathIndex: widget.coinModel.pathIndex,
        );
        if (!mounted) return;
        await _handleTransferResult(mm, cancelTrm);
      } else {
        trm
          ..gasPriceValue = newGasPriceValue
          ..price = transferValue
          ..to1 = toAddress
          ..nonce = transactionInfo!['nonce']
          ..gas = hexToInt(transactionInfo!['gas']).toInt();

        final gaslimit = BigInt.from(getCoinGas(
          widget.coinModel.coin['coinType'],
          contract: widget.coinModel.coin['isContract'],
        ));
        final cm = widget.coinModel;
        final gasEst = await tokenViewApi.getGasEstimateEthV2(
          cm.address, trm.to1, trm.gasPriceValue, trm.price, gaslimit,
          cm.coin['coinType'],
          contract: cm.isTest ? cm.coin['contract_test'] : cm.coin['contract'],
          isTest: cm.isTest,
        );
        if (!mounted) return;
        if (gasEst.error) {
          _setLoadState(Load.finish);
          ToastUtils.show(gasEst.data);
          return;
        }
        trm.gas = (gasEst.data as BigInt).toInt();
        trm.gasPrice = trm.gasPriceValue * BigInt.from(trm.gas);

        final check = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WalletBaseSend(trm, null, trm.coin['unit'])),
        );
        if (!mounted) return;
        if (!check) { _setLoadState(Load.finish); return; }
        final mm = await TransferApi().transferWallet(
          trModel: trm,
          privateKey: cm.privateKey,
          pathIndex: cm.pathIndex,
        );
        if (!mounted) return;
        await _handleTransferResult(mm, trm);
      }
    } catch (e) {
      if (mounted) {
        _setLoadState(Load.finish);
        ToastUtils.show(e.toString());
      }
    }
  }

  TransationRecordModel _buildCancelTrm(BigInt gasPriceValue) {
    return TransationRecordModel()
      ..address = trm.address
      ..from1 = trm.from1
      ..to1 = widget.coinModel.address
      ..price = BigInt.zero
      ..gas = 21000
      ..gasPriceValue = gasPriceValue
      ..gasPrice = gasPriceValue * BigInt.from(21000)
      ..nonce = transactionInfo!['nonce']
      ..contract = ''
      ..coin = trm.coin
      ..coinMiniName = trm.coinMiniName
      ..coinId = trm.coinId
      ..isTest = trm.isTest
      ..addrType = trm.addrType
      ..walletIndex = trm.walletIndex;
  }

  Future<void> _handleTransferResult(
      MessageModel mm, TransationRecordModel model) async {
    if (mm.error) {
      _setLoadState(Load.finish);
      ToastUtils.show(mm.data);
      return;
    }
    model.txHash = mm.data;
    if (model.trId == 0) {
      model.trId = await db.insertTransationRecord(model);
      if (!mounted) return;
      ref.read(tripBridgeProvider).addUndoneTr(model, 1);
    } else {
      await db.updateTransationRecord(model);
      if (!mounted) return;
      ref.read(tripBridgeProvider).selectUndoneTr();
    }
    ToastUtils.show(S.current.g_key_nft_41);
    _setLoadState(Load.finish);
    Navigator.pop(context, true);
  }

  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
