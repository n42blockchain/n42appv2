part of 'wallet_chain_send_zil.dart';

/// Business logic mixin for [_WalletChainSendZilState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _ZilSendLogicMixin on ConsumerState<WalletChainSendZil> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get _regular => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

  final oCcy = NumberFormat("#,##0.00########", "en_US");

  final TextEditingController toTextEditingController = TextEditingController();
  final TextEditingController valueTextEditingController =
      TextEditingController();
  final TextEditingController noteTextEditingController =
      TextEditingController();
  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();
  final FocusNode noteNode = FocusNode();

  String toErrorMessage = '';
  String noteErrorMessage = '';
  String amountErrorMessage = '';
  String errorMessage = '';

  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gas = BigInt.zero;
  BigInt transferValue = BigInt.zero;

  Load load = Load.loading;
  Load gasLimitLoad = Load.finish;

  TokenViewApi? _logicTokenViewApi;
  TokenViewApi get tokenViewApi => _logicTokenViewApi ??= TokenViewApi();

  Future<void> initData() async {
    final coin = widget.coinModel.coin;
    if (coin['isContract']) {
      final wap = ref.read(wapBridgeProvider);
      final cIndex = wap.coinModels.indexWhere(
        (e) =>
            e.coin['coinType'] == coin['coinType'] &&
            (widget.coinModel.privateKey == null ||
                e.privateKey == widget.coinModel.privateKey),
      );
      chainModel = wap.coinModels[cIndex];
      await chainModel?.getBalance();
      if (!mounted) return;
      setState(() {});
    }
    gas = BigInt.from(
      getCoinGas(coin['coinType'], contract: coin['isContract']),
    );
    await getBalance();
    await getGasPrice();
  }

  Future<void> getBalance() async {
    setState(() => load = Load.loading);
    final isOk = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (!isOk) {
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(errorMessage);
    }
    setState(() => load = Load.finish);
  }

  Future<void> getGasPrice() async {
    setState(() => load = Load.loading);
    final zilApi = ZilApi(isTest: widget.coinModel.isTest);
    final mm = await zilApi.getMinimumGasPrice();
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

  void amountCheck({String value = ''}) {
    if (value.isEmpty) value = valueTextEditingController.text;

    final coin = widget.coinModel.coin;
    final int decimals = coin['decimals'];
    final int minValue = decimals == 0 ? 1 : 0;

    // Empty input
    if (value.isEmpty) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }

    // Integer-only check when decimals == 0
    final isValidInt = _regular.regularNums(value);
    if (decimals == 0 && !isValidInt) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }

    // Numeric format check
    final isValidDouble = _regular.regularDouble(value);
    if (!isValidDouble && !isValidInt) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }

    // Value range check
    final dValue = double.parse(value);
    if (dValue <= 0 || dValue < minValue) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }

    // Balance check for non-contract coins
    final valueBi = ethToWeiString(value, decimals);
    if (coin['isContract'] == false &&
        valueBi + totalGasPrice > widget.coinModel.balance) {
      _setAmountError(S.of(context).g_key_47);
      return;
    }

    transferValue = valueBi;
    _setAmountError('');
  }

  void _setAmountError(String msg) {
    amountErrorMessage = msg;
    setState(() {});
  }

  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }
    final parts = addr.split(':');
    if (parts.length == 2) addr = parts[1];

    final isValid = await Trustdart().validateAddress(
      widget.coinModel.coin['coinType'],
      addr,
    );
    if (!mounted) return null;

    final isSelfSend =
        addr.toUpperCase() == widget.coinModel.address.toString().toUpperCase();
    if (!isValid || isSelfSend) {
      toErrorMessage = S.current.g_key_t_50;
      setState(() {});
      return null;
    }

    toErrorMessage = '';
    setState(() {});
    return addr;
  }

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show('loading');
      return;
    }
    if (amountErrorMessage.isNotEmpty) return;
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage.isNotEmpty) return;

    setState(() => load = Load.loading);
    final toAddr = await toAddressCheck(toTextEditingController.text.trim());
    if (!mounted) return;
    if (toAddr == null) {
      setState(() => load = Load.finish);
      return;
    }

    final coin = widget.coinModel.coin;
    final uBalance = coin['isContract']
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      setState(() => load = Load.finish);
      return;
    }

    final ownerAddr = widget.coinModel.address.toString();
    final trModel = TransationRecordModel()
      ..address = ownerAddr
      ..from1 = ownerAddr
      ..to1 = toAddr
      ..addrType = widget.coinModel.addrType
      ..coin = coin
      ..coinMiniName = coin['coinType']
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = widget.coinModel.isTest
          ? coin['contract_test']
          : coin['contract']
      ..isTest = widget.coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = gasPrice
      ..price = transferValue;

    final feeUnit = (chainModel ?? widget.coinModel).coin['unit']
        .toString()
        .toUpperCase();
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => WalletBaseSend(trModel, null, feeUnit)),
    );
    if (!mounted) return;
    if (confirmed == true) {
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
        if (!mounted) return;
        ToastUtils.show(S.current.g_key_nft_41);
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

  Future<void> scanQR() async {
    final scanValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
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
    amountErrorMessage = '';
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
