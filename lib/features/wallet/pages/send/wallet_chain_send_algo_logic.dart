part of 'wallet_chain_send_algo.dart';

/// Business logic mixin for [_WalletChainSendAlgoState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _AlgoSendLogicMixin on ConsumerState<WalletChainSendAlgo> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get regular => _logicRegular ??= Regular();

  TokenViewApi? _logicTokenViewApi;
  TokenViewApi get tokenViewApi => _logicTokenViewApi ??= TokenViewApi();

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
  BigInt transferValue = BigInt.zero;

  Load load = Load.loading;
  Load gasLimitLoad = Load.finish;
  bool showMaxButton = false;
  bool algoTokenAdd = true;

  Future<void> initData() async {
    if (widget.coinModel.coin['isContract']) {
      final wap = ref.read(wapBridgeProvider);
      final cIndex = wap.coinModels.indexWhere((element) {
        if (element.coin['coinType'] != widget.coinModel.coin['coinType']) {
          return false;
        }
        if (widget.coinModel.privateKey != null) {
          return element.privateKey == widget.coinModel.privateKey;
        }
        return true;
      });
      chainModel = wap.coinModels[cIndex];
      await chainModel?.getBalance();
      if (!mounted) return;
      setState(() {});
    }
    gas = BigInt.from(
      getCoinGas(
        widget.coinModel.coin['coinType'],
        contract: widget.coinModel.coin['isContract'],
      ),
    );
    showMaxButton = true;
    await getBalance();
    await getGasPrice();
    checkTokenAddAlgo();
  }

  Future<void> getBalance() async {
    setState(() {
      load = Load.loading;
    });
    final bool isOk = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (!isOk) {
      load = Load.finish;
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState(() {});
    }
  }

  Future<void> getGasPrice() async {
    setState(() {
      load = Load.loading;
    });
    final MessageModel mm =
        await tokenViewApi.getGasPrice(
          widget.coinModel.coin['blockchainType'],
          widget.coinModel.coin['coinType'],
          isTest: widget.coinModel.isTest,
          rpc: widget.coinModel.custom
              ? widget.coinModel.coin['service']
              : null,
        ) ??
        MessageModel.error();
    if (!mounted) return;
    if (!mm.error) {
      gasPrice = BigInt.from(mm.data['min-fee']);
    } else {
      errorMessage = mm.data.toString();
      ToastUtils.show(errorMessage);
    }
    totalGasPrice = gasPrice * gas;
    load = Load.finish;
    setState(() {});
  }

  void amountCheck({String value = ""}) {
    if (value == "") {
      value = valueTextEditingController.text;
    }
    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    final bool checkValue = regular.regularDouble(value);
    final bool checkValue1 = regular.regularNums(value);
    if (!checkValue && !checkValue1) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    }
    if (double.parse(value) <= 0) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    final BigInt valueBi = ethToWeiString(
      value,
      widget.coinModel.coin['decimals'],
    );
    if (!widget.coinModel.coin['isContract']) {
      if (valueBi + totalGasPrice > widget.coinModel.balance) {
        amountErrorMessage = S.of(context).g_key_47;
        setState(() {});
        return;
      }
    }
    transferValue = valueBi;
    amountErrorMessage = "";
    setState(() {});
  }

  Future<String?> toAddressCheck(String addr) async {
    if (addr == "") {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }
    final List<String> addrList = addr.split(":");
    if (addrList.length == 2) {
      addr = addrList[1];
    }
    final bool valid = await Trustdart().validateAddress(
      widget.coinModel.coin['coinType'],
      addr,
    );
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

  Future<void> checkTokenAddAlgo() async {
    if (widget.coinModel.other == null) return;
    final AlgoModel algo = widget.coinModel.other as AlgoModel;
    if (algo.code == 404) {
      algoTokenAdd = false;
      setState(() {});
    }
  }

  /// Resets load state and triggers a rebuild.
  void _finishLoading() {
    load = Load.finish;
    setState(() {});
  }

  /// The unit string used for the send confirmation page.
  String get _sendUnit => chainModel == null
      ? widget.coinModel.coin['unit']
      : chainModel!.coin['unit'];

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show("loading");
      return;
    }
    if (amountErrorMessage != "") return;
    setState(() {
      load = Load.loading;
    });
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage != "") return;

    final String? toAddr = await toAddressCheck(toTextEditingController.text);
    if (!mounted) return;
    if (toAddr == null) {
      _finishLoading();
      return;
    }

    final AlgoApi algoApi = AlgoApi();
    final String contract = widget.coinModel.isTest
        ? widget.coinModel.coin['contract_test']
        : widget.coinModel.coin['contract'];
    final MessageModel toBalanceMM = await algoApi.getBalance(
      toAddr,
      assetId: contract,
      isTest: widget.coinModel.isTest,
    );
    if (!mounted) return;
    if (toBalanceMM.error) {
      errorMessage = toBalanceMM.data;
      _finishLoading();
      return;
    }
    if (toBalanceMM.data['code'] == 404) {
      errorMessage =
          'To Address ($toAddr) did not add USDC ($contract) and cannot be traded.';
      _finishLoading();
      return;
    }
    errorMessage = "";

    BigInt uBalance = widget.coinModel.balance;
    if (widget.coinModel.coin['isContract']) {
      uBalance = chainModel?.balance ?? BigInt.zero;
    }
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      _finishLoading();
      return;
    }

    final TransationRecordModel trModel = _buildTransactionRecord(toAddr);
    await _confirmAndSign(trModel);
  }

  Future<void> sendTransactionAlgoTokenEdit(bool add) async {
    if (load == Load.loading) {
      ToastUtils.show("loading");
      return;
    }
    if (amountErrorMessage != "") return;
    setState(() {
      load = Load.loading;
    });
    closeKeyboard();
    if (errorMessage != "") {
      _finishLoading();
      return;
    }
    final BigInt uBalance = chainModel?.balance ?? BigInt.zero;
    if (totalGasPrice > uBalance) {
      _finishLoading();
      return;
    }

    final TransationRecordModel trModel = _buildTransactionRecord(
      widget.coinModel.address.toString(),
    );
    trModel.price = BigInt.zero;
    trModel.other = AlgoTrModel(add ? "Add" : "Delete");

    await _confirmAndSign(trModel);
  }

  /// Shows the send confirmation page and signs on approval.
  Future<void> _confirmAndSign(TransationRecordModel trModel) async {
    final bool check = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletBaseSend(trModel, null, _sendUnit),
      ),
    );
    if (!mounted) return;
    if (check) {
      signTx(trModel);
    } else {
      _finishLoading();
    }
  }

  /// Constructs a [TransationRecordModel] pre-filled with the current coin and
  /// wallet context. [toAddr] is the recipient address.
  TransationRecordModel _buildTransactionRecord(String toAddr) {
    final trModel = TransationRecordModel();
    trModel.address = widget.coinModel.address.toString();
    trModel.from1 = widget.coinModel.address.toString();
    trModel.to1 = toAddr;
    trModel.addrType = widget.coinModel.addrType;
    trModel.coin = widget.coinModel.coin;
    trModel.coinMiniName = widget.coinModel.coin['coinType'];
    trModel.walletIndex = ref.read(wapBridgeProvider).walletIndex;
    trModel.contract = widget.coinModel.isTest
        ? widget.coinModel.coin['contract_test']
        : widget.coinModel.coin['contract'];
    trModel.isTest = widget.coinModel.isTest ? 1 : 0;
    trModel.gasPrice = totalGasPrice;
    trModel.gas = gas.toInt();
    trModel.gasPriceValue = gasPrice;
    trModel.price = transferValue;
    return trModel;
  }

  Future<void> signTx(TransationRecordModel trModel) async {
    bool completedWithExit = false;
    try {
      final TransferApi transferApi = TransferApi();
      final MessageModel mm = await transferApi.transferWallet(
        trModel: trModel,
        privateKey: widget.coinModel.privateKey,
        pathIndex: widget.coinModel.pathIndex,
      );
      if (mm.error) {
        errorMessage = mm.data;
      } else {
        trModel.txHash = mm.data;
        trModel.trId = await AppDatabase().insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(
          widget.coinModel.coin['coinType'] ?? '',
          toTextEditingController.text.trim(),
        );
        ToastUtils.show(S.current.g_key_nft_41);
        if (!mounted) return;
        completedWithExit = true;
        Navigator.pop(context);
      }
    } catch (e) {
      errorMessage = e.toString();
      ToastUtils.show(e.toString());
    } finally {
      load = Load.finish;
      if (mounted && !completedWithExit) setState(() {});
    }
  }

  void scanQR() async {
    final String? scanValue = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
    if (!mounted) return;
    if (scanValue != null) {
      toTextEditingController.text = scanValue;
      toAddressCheck(scanValue);
    }
  }

  Future<void> maxTag() async {
    if (gasLimitLoad == Load.loading) return;
    if (widget.coinModel.coin['isContract']) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
    } else {
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
    FocusScope.of(context).requestFocus(FocusNode());
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
