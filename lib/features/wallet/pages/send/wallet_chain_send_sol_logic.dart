part of 'wallet_chain_send_sol.dart';

/// Business logic mixin for [_WalletChainSendSolState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _SolSendLogicMixin on ConsumerState<WalletChainSendSol> {
  CoinModel? chainModel;

  late final Regular _regular = Regular();
  late final DataUtils dataUtils = DataUtils();

  final TextEditingController toTextEditingController = TextEditingController();
  final TextEditingController valueTextEditingController =
      TextEditingController();
  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();

  String toErrorMessage = "";
  String amountErrorMessage = "";
  String errorMessage = "";

  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gas = BigInt.zero;
  BigInt transferValue = BigInt.zero; // 转账金额

  Load load = Load.loading;

  Map<String, dynamic> get _coin => widget.coinModel.coin;
  String get _coinType => widget.coinModel.config.coinType;
  bool get _isContract => widget.coinModel.config.isContract;
  int get _decimals => (_coin['decimals'] as num?)?.toInt() ?? 18;

  Future<void> initData() async {
    if (_coinType.isEmpty) {
      errorMessage = 'Invalid coin configuration';
      ToastUtils.show(errorMessage);
      if (mounted) setState(() => load = Load.finish);
      return;
    }
    if (_isContract) {
      final wap = ref.read(wapBridgeProvider);
      final cIndex = wap.coinModels.indexWhere((e) {
        if (e.config.coinType != _coinType) return false;
        if (widget.coinModel.privateKey != null) {
          return e.privateKey == widget.coinModel.privateKey;
        }
        return true;
      });
      if (cIndex < 0) {
        errorMessage = 'Missing parent chain for $_coinType';
        ToastUtils.show(errorMessage);
        if (mounted) setState(() => load = Load.finish);
        return;
      }
      chainModel = wap.coinModels[cIndex];
      if (chainModel != null) {
        await fetchCoinBalance(chainModel!, ref.read(wapBridgeProvider));
      }
      if (!mounted) return;
      setState(() {});
    }
    gas = BigInt.from(getCoinGas(_coinType, contract: _isContract));
    await getBalance();
    await getGasPrice();
  }

  Future<void> getBalance() async {
    setState(() => load = Load.loading);
    final bool isOk = await fetchCoinBalance(
      widget.coinModel,
      ref.read(wapBridgeProvider),
      getToken: false,
    );
    if (!mounted) return;
    if (!isOk) {
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
    }
    setState(() => load = Load.finish);
  }

  Future<void> getGasPrice() async {
    totalGasPrice = BigInt.from(_isContract ? 35000 : 5000) * gas;
  }

  Future<bool> simulateTransaction() async {
    final MessageModel bhmm = await SolApi().getLatestBlockhash(
      isTest: widget.coinModel.isTest,
    );
    if (!mounted) return false;
    if (bhmm.error) {
      errorMessage = bhmm.data;
      ToastUtils.show(bhmm.data);
      return false;
    }
    final String toAddr = toTextEditingController.text.trim();
    Map<String, dynamic> txData;

    if (!_isContract) {
      txData = {
        "type": "SOL",
        "recentBlockhash": bhmm.data,
        "transferTransaction": {"recipient": toAddr, "value": "1000000"},
        "encodeType": "base58",
      };
    } else {
      final contractAddress = widget.coinModel.isTest
          ? widget.coinModel.config.contractTest
          : widget.coinModel.config.contract;
      final recipientTokenAddress = await Trustdart().getPubKeySOL(
        toAddr,
        contractAddress,
      );
      if (!mounted) return false;
      if (recipientTokenAddress.isEmpty) {
        errorMessage = "Error";
        ToastUtils.show("Error");
        setState(() => load = Load.finish);
        return false;
      }
      txData = {
        "type": "tokenCreate",
        "recentBlockhash": bhmm.data,
        "tokenTransferTransaction": {
          "tokenMintAddress": contractAddress,
          "senderTokenAddress": widget.coinModel.address,
          "recipientTokenAddress": recipientTokenAddress,
          "recipientMainAddress": toAddr,
          "amount": "1000000",
          "decimals": _decimals.toString(),
        },
        "encodeType": "base58",
      };
    }

    final path = getPathWithIndex(
      widget.coinModel.config.pathForAddrType(widget.coinModel.addrType)!,
      widget.coinModel.pathIndex,
    );
    final walletInfo = ref.read(wapBridgeProvider).walletInfo;
    final signStr = await Trustdart().signTransaction(
      _coinType,
      path,
      txData,
      mnemonic: walletInfo.mnemonic ?? "",
      pk: walletInfo.privateKey ?? "",
    );
    if (!mounted) return false;
    if (signStr.isEmpty) {
      errorMessage = "Error";
      ToastUtils.show("Error");
      setState(() => load = Load.finish);
      return false;
    }
    final ffmmm = await SolApi().simulateTransaction(
      signStr,
      isTest: widget.coinModel.isTest,
    );
    return !ffmmm.error;
  }

  void amountCheck({String value = ""}) {
    if (value.isEmpty) value = valueTextEditingController.text;
    final int minValue = _decimals == 0 ? 1 : 0;

    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    final checkValue1 = _regular.regularNums(value);
    if (_decimals == 0 && !checkValue1) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    }

    final checkValue = _regular.regularDouble(value);
    final dValue = double.parse(value);

    if (!checkValue && !checkValue1) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    }
    if (dValue <= 0 || dValue < minValue) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    final valueBi = ethToWeiString(value, _decimals);
    if (!_isContract && valueBi + totalGasPrice > widget.coinModel.balance) {
      amountErrorMessage = S.of(context).g_key_47;
      setState(() {});
      return;
    }
    transferValue = valueBi;
    amountErrorMessage = "";
    setState(() {});
  }

  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }
    final parts = addr.split(":");
    if (parts.length == 2) addr = parts[1];

    final valid = await Trustdart().validateAddress(_coinType, addr);
    if (!mounted) return null;
    if (!valid ||
        addr.toUpperCase() ==
            widget.coinModel.address.toString().toUpperCase()) {
      toErrorMessage = S.current.g_key_t_50;
      setState(() {});
      return null;
    }
    toErrorMessage = "";
    setState(() {});
    return addr;
  }

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show("loading");
      return;
    }
    if (amountErrorMessage.isNotEmpty) return;
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage.isNotEmpty) return;

    setState(() => load = Load.loading);

    final String? toAddr = await toAddressCheck(
      toTextEditingController.text.trim(),
    );
    if (!mounted) return;
    if (toAddr == null) {
      setState(() => load = Load.finish);
      return;
    }

    final uBalance = _isContract
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      setState(() => load = Load.finish);
      return;
    }

    await simulateTransaction();
    if (!mounted) return;
    if (errorMessage.isNotEmpty) {
      setState(() => load = Load.finish);
      return;
    }

    final contract = widget.coinModel.isTest
        ? widget.coinModel.config.contractTest
        : widget.coinModel.config.contract;
    final trModel = TransationRecordModel()
      ..address = widget.coinModel.address.toString()
      ..from1 = widget.coinModel.address.toString()
      ..to1 = toAddr
      ..addrType = widget.coinModel.addrType
      ..coin = _coin
      ..coinMiniName = _coinType
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = contract
      ..isTest = widget.coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = gasPrice
      ..price = transferValue;

    final feeUnit = (chainModel ?? widget.coinModel).coin['unit']
        .toString()
        .toUpperCase();
    final check = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => WalletBaseSend(trModel, null, feeUnit)),
    );
    if (!mounted) return;
    if (check == true) {
      signTx(trModel);
    } else {
      setState(() => load = Load.finish);
    }
  }

  Future<void> signTx(TransationRecordModel trModel) async {
    bool completedWithExit = false;
    try {
      final coinType = widget.coinModel.config.coinType;
      final addrType = widget.coinModel.addrType;
      final baseInfo =
          widget.coinModel.coin['baseInfo'] as Map<String, dynamic>?;
      final pathMap = baseInfo?['path'] as Map<String, dynamic>?;
      final basePath = pathMap?[addrType]?.toString() ?? "m/44'/60'/0'/0/0";
      final path = getPathWithIndex(basePath, widget.coinModel.pathIndex);
      final decimals =
          (widget.coinModel.coin['decimals'] as num?)?.toInt() ?? 18;

      final result = await SenderFactory.instance
          .getSender(coinType)
          .send(
            SendParams(
              coinType: coinType,
              fromAddress: trModel.from1,
              toAddress: trModel.to1,
              amount: toEther(trModel.price.toString(), decimals).toDouble(),
              decimals: decimals,
              path: path,
              sendMax: false,
              isTest: widget.coinModel.isTest,
              contractAddress: trModel.contract,
              tokenDecimals: 0,
              memo: trModel.message,
              privateKey: widget.coinModel.privateKey,
              chainConfig: widget.coinModel.coin,
            ),
          );

      if (!mounted) return;
      if (result.success) {
        trModel.txHash = result.txHash ?? '';
        trModel.trId = await AppDatabase().insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(
          coinType,
          toTextEditingController.text.trim(),
        );
        if (!mounted) return;
        ToastUtils.show(S.current.g_key_nft_41);
        completedWithExit = true;
        Navigator.pop(context);
      } else {
        errorMessage = result.error ?? '';
        ToastUtils.show(errorMessage);
      }
    } catch (e) {
      errorMessage = e.toString();
      ToastUtils.show(e.toString());
    } finally {
      load = Load.finish;
      if (mounted && !completedWithExit) setState(() {});
    }
  }

  void scanQR() => performScanQR(
    context,
    controller: toTextEditingController,
    onAddress: toAddressCheck,
  );

  void pasteAddress() => performPasteAddress(
    context,
    controller: toTextEditingController,
    onAddress: toAddressCheck,
  );

  Future<void> maxTag() async {
    if (_isContract) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
      simulateTransaction();
    } else {
      transferValue = maxTransferableAmount(
        balance: widget.coinModel.balance,
        fee: totalGasPrice,
      );
      valueTextEditingController.text = toEther(
        transferValue.toString(),
        _decimals,
      ).toString();
    }
    amountErrorMessage = "";
    setState(() {});
  }

  void closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void searchToAddressWidget() {
    showAddressPickerSheet(
      context,
      coinModel: widget.coinModel,
      onAddressSelected: (addr) {
        toTextEditingController.text = addr;
        toAddressCheck(addr);
      },
    );
  }
}
