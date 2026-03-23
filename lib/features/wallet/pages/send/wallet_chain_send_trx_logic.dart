part of 'wallet_chain_send_trx.dart';

/// Business logic mixin for [_WalletChainSendTrxState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _TrxSendLogicMixin on ConsumerState<WalletChainSendTrx> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get _regular => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

  TokenViewApi? _logicTokenViewApi;
  TokenViewApi get tokenViewApi => _logicTokenViewApi ??= TokenViewApi();

  final NumberFormat oCcy = NumberFormat("#,##0.00########", "en_US");

  final TextEditingController toTextEditingController = TextEditingController();
  final TextEditingController valueTextEditingController =
      TextEditingController();
  final TextEditingController noteTextEditingController =
      TextEditingController();
  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();
  final FocusNode noteNode = FocusNode();

  String toErrorMessage = "";
  String noteErrorMessage = "";
  String amountErrorMessage = "";
  String errorMessage = "";

  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gas = BigInt.zero;
  BigInt transferValue = BigInt.zero; // 转账金额

  Load load = Load.loading;
  Load gasLimitLoad = Load.finish;

  Future<void> initData() async {
    // 判断是否是代币
    if (widget.coinModel.coin['isContract']) {
      final WalletActionProvider wap = ref.read(wapBridgeProvider);
      final int cIndex = wap.coinModels.indexWhere((element) {
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
    await getBalance();
    await getGasPrice();
  }

  Future<void> getBalance() async {
    load = Load.loading;
    setState(() {});
    final bool isOk = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (!isOk) {
      load = Load.finish;
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(errorMessage);
      setState(() {});
    }
  }

  Future<void> getGasPrice() async {
    load = Load.loading;
    setState(() {});
    var mm = await tokenViewApi.getGasPriceTrx(isTest: widget.coinModel.isTest);
    if (mm.error) {
      mm = await TrxApi().getGasPriceTrx(isTest: widget.coinModel.isTest);
    }
    if (!mounted) return;
    if (!mm.error) {
      gasPrice = mm.data;
    } else {
      errorMessage = mm.data.toString();
      ToastUtils.show(errorMessage);
    }
    totalGasPrice = gasPrice * gas;
    load = Load.finish;
    setState(() {});
  }

  Future<dynamic> estimateGasEthLocal({bool checkAddress = true}) async {
    closeKeyboard();
    if (gasLimitLoad == Load.loading) return;
    gasLimitLoad = Load.loading;
    setState(() {});
    try {
      String? toAddr;
      if (checkAddress) {
        if (amountErrorMessage != "") return;
        toAddr = await toAddressCheck(toTextEditingController.text.trim());
        if (toAddr == null) return;
      } else {
        toAddr = toTextEditingController.text.trim();
      }
      if (toErrorMessage != "") return;
      final price = valueTextEditingController.text;
      if (price == "") return;

      final gaslimit = BigInt.from(
        getCoinGas(
          widget.coinModel.coin['coinType'],
          contract: widget.coinModel.coin['isContract'],
        ),
      );
      final ethMessage = await TrxApi().getGasEstimateTrx(
        widget.coinModel.address,
        toAddr,
        gasPrice,
        ethToWeiString(price, widget.coinModel.coin['decimals']),
        gaslimit,
        contract: widget.coinModel.isTest
            ? widget.coinModel.coin['contract_test']
            : widget.coinModel.coin['contract'],
        isTest: widget.coinModel.isTest,
      );
      if (!mounted) return false;

      if (!ethMessage.error) {
        gas = ethMessage.data;
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
      gasLimitLoad = Load.finish;
      if (mounted) setState(() {});
    }
  }

  void amountCheck({String value = ""}) {
    if (value.isEmpty) {
      value = valueTextEditingController.text;
    }
    final int decimals = widget.coinModel.coin['decimals'] as int;
    final int minValue = decimals == 0 ? 1 : 0;

    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    final bool isInteger = _regular.regularNums(value);
    final bool isDouble = _regular.regularDouble(value);

    // 整数精度币种必须为整数
    if (decimals == 0 && !isInteger) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    }
    if (!isDouble && !isInteger) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    }

    final double dValue = double.parse(value);
    if (dValue <= 0 || dValue < minValue) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    final BigInt valueBi = ethToWeiString(value, decimals);
    if (widget.coinModel.coin['isContract'] == false &&
        valueBi + totalGasPrice > widget.coinModel.balance) {
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
    if (parts.length == 2) {
      addr = parts[1];
    }
    final isValid = await Trustdart().validateAddress(
      widget.coinModel.coin['coinType'],
      addr,
    );
    if (!isValid ||
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
    if (amountErrorMessage != "") return;
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage != "") return;

    setState(() => load = Load.loading);

    final String? toAddr = await toAddressCheck(
      toTextEditingController.text.trim(),
    );
    if (toAddr == null) {
      setState(() => load = Load.finish);
      return;
    }
    await estimateGasEthLocal(checkAddress: false);
    if (errorMessage != "") {
      setState(() => load = Load.finish);
      return;
    }
    final BigInt uBalance = widget.coinModel.coin['isContract']
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      setState(() => load = Load.finish);
      return;
    }
    if (!mounted) return;

    final trModel = TransationRecordModel()
      ..address = widget.coinModel.address.toString()
      ..from1 = widget.coinModel.address.toString()
      ..to1 = toAddr
      ..addrType = widget.coinModel.addrType
      ..coin = widget.coinModel.coin
      ..coinMiniName = widget.coinModel.coin['coinType']
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = widget.coinModel.isTest
          ? widget.coinModel.coin['contract_test']
          : widget.coinModel.coin['contract']
      ..isTest = widget.coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = gasPrice
      ..price = transferValue;

    final feeUnit = (chainModel ?? widget.coinModel).coin['unit']
        .toString()
        .toUpperCase();
    final bool check = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletBaseSend(trModel, null, feeUnit),
      ),
    );
    if (!mounted) return;
    if (check) {
      signTx(trModel);
    } else {
      setState(() => load = Load.finish);
    }
  }

  Future<void> signTx(TransationRecordModel trModel) async {
    try {
      final TransferApi transferApi = TransferApi();
      final MessageModel mm = await transferApi.transferWallet(
        trModel: trModel,
        privateKey: widget.coinModel.privateKey,
        pathIndex: widget.coinModel.pathIndex,
      );
      if (!mounted) return;
      if (mm.error) {
        errorMessage = mm.data;
      } else {
        trModel.txHash = mm.data;
        final AppDatabase appDatabase = AppDatabase();
        trModel.trId = await appDatabase.insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(
          widget.coinModel.coin['coinType'] ?? '',
          toTextEditingController.text.trim(),
        );
        ToastUtils.show(S.current.g_key_nft_41);
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      errorMessage = e.toString();
      ToastUtils.show(e.toString());
    } finally {
      load = Load.finish;
      if (mounted) setState(() {});
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
    Navigator.pop(context);
  }

  Future<void> maxTag() async {
    if (gasLimitLoad == Load.loading) return;
    if (widget.coinModel.coin['isContract']) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
      estimateGasEthLocal();
    } else {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      final bool? rOK = await estimateGasEthLocal();
      if (!mounted) return;
      if (rOK != null && rOK) {
        transferValue = maxTransferableAmount(
          balance: widget.coinModel.balance,
          fee: totalGasPrice,
        );
        valueTextEditingController.text = _regular.formartNum(
          toEther(
            transferValue.toString(),
            widget.coinModel.coin['decimals'],
          ).toDouble(),
          14,
          isCrop: true,
          isFill0: false,
        );
      }
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
