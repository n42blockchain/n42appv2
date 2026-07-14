part of 'wallet_chain_send_fil.dart';

/// Business logic mixin for [_WalletChainSendFilState].
mixin _FilSendLogicMixin on ConsumerState<WalletChainSendFil> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get regular => _logicRegular ??= Regular();

  final NumberFormat oCcy = NumberFormat("#,##0.00########", "en_US");

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
  String gasFeeCap = "0";
  String gasPremium = "0";
  BigInt transferValue = BigInt.zero;

  Load load = Load.loading;
  Load gasLimitLoad = Load.finish;

  Future<void> initData() async {
    if (widget.coinModel.config.isContract) {
      final WalletActionProvider wap = ref.read(wapBridgeProvider);
      final int cIndex = wap.coinModels.indexWhere((element) {
        if (element.config.coinType != widget.coinModel.config.coinType) {
          return false;
        }
        if (widget.coinModel.privateKey != null) {
          return element.privateKey == widget.coinModel.privateKey;
        }
        return true;
      });
      chainModel = wap.coinModels[cIndex];
      if (chainModel != null) {
        await fetchCoinBalance(chainModel!, ref.read(wapBridgeProvider));
      }
      if (!mounted) return;
      setState(() {});
    }
    gas = BigInt.from(
      getCoinGas(
        widget.coinModel.config.coinType,
        contract: widget.coinModel.config.isContract,
      ),
    );
    await getBalance();
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

  void amountCheck({String value = ""}) {
    if (value.isEmpty) value = valueTextEditingController.text;

    final String? error = _validateAmount(value);
    amountErrorMessage = error ?? "";
    setState(() {});
  }

  String? _validateAmount(String value) {
    if (value.isEmpty) return S.of(context).g_key_46(0);

    final bool isValid =
        regular.regularDouble(value) || regular.regularNums(value);
    if (!isValid) return S.of(context).g_key_134;
    if (double.parse(value) <= 0) return S.of(context).g_key_46(0);

    final int decimals = widget.coinModel.coin['decimals'] as int;
    final BigInt valueBi = ethToWeiString(value, decimals);

    if (widget.coinModel.config.blockchainType == BlockchainType.Ripple.name) {
      final BigInt reserve = ethToWeiString("10", decimals);
      if (valueBi + totalGasPrice > widget.coinModel.balance - reserve) {
        return S.of(context).g_key_47;
      }
    } else {
      if (!widget.coinModel.config.isContract &&
          valueBi + totalGasPrice > widget.coinModel.balance) {
        return S.of(context).g_key_47;
      }
      transferValue = valueBi;
    }
    return null;
  }

  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }
    final List<String> parts = addr.split(":");
    if (parts.length == 2) addr = parts[1];

    final bool valid = await Trustdart().validateAddress(
      widget.coinModel.config.coinType,
      addr,
    );
    final bool isSelf =
        addr.toUpperCase() == widget.coinModel.address.toString().toUpperCase();
    if (!mounted) return null;

    if (!valid || isSelf) {
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
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage.isNotEmpty) return;

    setState(() => load = Load.loading);

    final String? toAddr = await toAddressCheck(toTextEditingController.text);
    if (toAddr == null) return _resetLoad();

    await estimateGasEthLocal();
    if (errorMessage.isNotEmpty) return _resetLoad();

    final BigInt uBalance = widget.coinModel.config.isContract
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      return _resetLoad();
    }

    final FilApi filApi = FilApi();
    final MessageModel rDataNonce = await filApi.getNonce(
      widget.coinModel.address.toString(),
      isTest: widget.coinModel.isTest,
    );
    if (!mounted) return;
    if (rDataNonce.error) {
      errorMessage = rDataNonce.data;
      return _resetLoad();
    }

    final String addr = widget.coinModel.address.toString();
    final TransationRecordModel trModel = TransationRecordModel()
      ..address = addr
      ..from1 = addr
      ..to1 = toAddr
      ..addrType = widget.coinModel.addrType
      ..coin = widget.coinModel.coin
      ..coinMiniName = widget.coinModel.config.coinType
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = widget.coinModel.isTest
          ? widget.coinModel.config.contractTest
          : widget.coinModel.config.contract
      ..isTest = widget.coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = BigInt.zero
      ..price = transferValue
      ..other = FilTrModel(gasFeeCap, gasPremium)
      ..nonce = rDataNonce.data.toString();

    final bool? check = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WalletBaseSend(trModel, null, widget.coinModel.coin['unit']),
      ),
    );
    if (!mounted) return;
    if (check == true) {
      signTx(trModel);
    } else {
      _resetLoad();
    }
  }

  void _resetLoad() {
    if (!mounted) return;
    setState(() => load = Load.finish);
  }

  Future<void> signTx(TransationRecordModel trModel) async {
    if (!signTxCheck()) return;
    bool completedWithExit = false;
    try {
      final coinType = widget.coinModel.config.coinType;
      final signingCoin = chainModel ?? widget.coinModel;
      final addrType = signingCoin.addrType;
      final basePath =
          signingCoin.config.pathForAddrType(addrType) ?? "m/44'/461'/0'/0/0";
      final path = getPathWithIndex(basePath, signingCoin.pathIndex);
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

  bool signTxCheck() => true;

  Future<bool?> estimateGasEthLocal() async {
    closeKeyboard();
    if (gasLimitLoad == Load.loading) return null;
    setState(() => gasLimitLoad = Load.loading);
    try {
      if (amountErrorMessage.isNotEmpty) return null;
      final String? toAddr = await toAddressCheck(toTextEditingController.text);
      if (toAddr == null || toErrorMessage.isNotEmpty) return null;
      final String price = valueTextEditingController.text;
      if (price.isEmpty) return null;

      final MessageModel ethMessage = await FilApi().getGasLimit(
        widget.coinModel.address,
        toAddr,
        BigInt.from(getCoinGas(widget.coinModel.config.coinType)),
        value: ethToWeiString(
          price,
          widget.coinModel.coin['decimals'],
        ).toString(),
        isTest: widget.coinModel.isTest,
      );
      if (!ethMessage.error) {
        gas = BigInt.parse(ethMessage.data['GasLimit'].toString());
        gasFeeCap = ethMessage.data['GasFeeCap'];
        gasPremium = ethMessage.data['GasPremium'];
        gasPrice = BigInt.parse(gasFeeCap);
        totalGasPrice = gasPrice * gas;
        errorMessage = "";
        return true;
      }
      errorMessage = ethMessage.data;
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      if (mounted) {
        setState(() => gasLimitLoad = Load.finish);
      }
    }
  }

  Future<void> scanQR() async {
    final scanValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
    );
    if (!mounted || scanValue == null) return;
    toTextEditingController.text = scanValue;
    toAddressCheck(scanValue);
  }

  Future<void> maxTag() async {
    if (gasLimitLoad == Load.loading) return;
    valueTextEditingController.text = widget.coinModel.balanceStringAll();
    final bool? rOK = await estimateGasEthLocal();
    if (rOK != null && rOK) {
      transferValue = maxTransferableAmount(
        balance: widget.coinModel.balance,
        fee: totalGasPrice,
      );
      valueTextEditingController.text = toEther(
        transferValue.toString(),
        widget.coinModel.coin['decimals'],
      ).toString();
    }
    amountErrorMessage = "";
    setState(() {});
  }

  void closeKeyboard() {
    FocusScope.of(context).unfocus();
  }
}
