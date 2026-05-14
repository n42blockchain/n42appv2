part of 'wallet_chain_send_xrp.dart';

/// Business logic mixin for [_WalletChainSendXrpState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, XRP account checking, input validation, and
/// transaction submission.
mixin _XrpSendLogicMixin on ConsumerState<WalletChainSendXrp> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get regular => _logicRegular ??= Regular();

  final NumberFormat oCcy = NumberFormat("#,##0.00########", "en_US");

  final TextEditingController toTextEditingController = TextEditingController();
  final TextEditingController valueTextEditingController =
      TextEditingController();
  final TextEditingController destTagCtrl = TextEditingController();
  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();
  final FocusNode destTagNode = FocusNode();

  String toErrorMessage = "";
  String amountErrorMessage = "";
  String errorMessage = "";

  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gas = BigInt.zero;
  BigInt transferValue = BigInt.zero;
  dec.Decimal lockValue = dec.Decimal.zero;

  Load load = Load.loading;
  Load gasLimitLoad = Load.finish;

  /// XRP recipient account status map.
  ///
  /// Keys: `address`, `error`, `account`, `load`, `isCreate`.
  Map<String, dynamic> accountXrp = {
    "address": "",
    "error": "",
    "account": "",
    "load": Load.finish,
    "isCreate": false,
  };

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
      if (chainModel != null) await fetchCoinBalance(chainModel!, ref.read(wapBridgeProvider));
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
    await getServiceState();
    lockValue = toEther(
      (widget.coinModel.other?.getLockAmount ?? 0).toString(),
      widget.coinModel.coin['decimals'],
    );
  }

  Future<void> getBalance() async {
    setState(() {
      load = Load.loading;
    });
    final bool isOk = await fetchCoinBalance(widget.coinModel, ref.read(wapBridgeProvider), getToken: false);
    if (!mounted) return;
    if (!isOk) {
      load = Load.finish;
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState(() {});
    }
  }

  /// Fetches XRP server state to obtain the base reserve and per-object reserve.
  Future<void> getServiceState() async {
    final MessageModel mm = await XrpApi().getServerStateXrp(
      isTest: widget.coinModel.isTest,
    );
    if (!mounted) return;
    if (!mm.error) {
      widget.coinModel.other?.setServiceState(mm.data);
    }
    setState(() {});
  }

  Future<void> getGasPrice() async {
    setState(() {
      load = Load.loading;
    });
    final TokenViewApi tokenViewApi = TokenViewApi();
    final MessageModel mm =
        await tokenViewApi.getGasPrice(
          widget.coinModel.coin['blockchainType'],
          widget.coinModel.coin['coinType'],
          isTest: widget.coinModel.isTest,
        ) ??
        MessageModel.error();
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
    final BigInt vb1 =
        widget.coinModel.balance -
        BigInt.from(widget.coinModel.other?.getLockAmount ?? 0);
    if (valueBi + totalGasPrice >= vb1) {
      amountErrorMessage = S.of(context).g_key_47;
      setState(() {});
      return;
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
    await checkAccountXRP(addr);
    if (!mounted) return null;
    toErrorMessage = "";
    setState(() {});
    return addr;
  }

  /// Queries the XRP network to determine whether [addr] has been activated.
  Future<void> checkAccountXRP(String addr) async {
    if (accountXrp['load'] == Load.loading) return;
    accountXrp['load'] = Load.loading;
    setState(() {});

    final MessageModel mm = await XrpApi().getAccountInfoXrp(
      addr,
      widget.coinModel.isTest,
    );
    if (!mounted) return;
    if (mm.error) {
      accountXrp['error'] = S.current.g_key_t_45(addr);
    } else {
      accountXrp['address'] = addr;
      if (mm.data['account'] == false) {
        accountXrp['account'] = S.current.g_key_t_49;
        accountXrp['isCreate'] = false;
      } else {
        accountXrp['account'] = S.current.g_key_t_51;
        accountXrp['isCreate'] = true;
      }
      accountXrp['error'] = "";
    }
    accountXrp['load'] = Load.finish;
    setState(() {});
  }

  /// Resets load state and triggers a rebuild.
  void _finishLoading() {
    load = Load.finish;
    if (mounted) setState(() {});
  }

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show("loading");
      return;
    }
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage != "") return;

    setState(() {
      load = Load.loading;
    });
    final String? toAddr = await toAddressCheck(toTextEditingController.text);
    if (!mounted) return;
    if (toAddr == null) {
      _finishLoading();
      return;
    }

    amountCheck();
    if (!mounted) return;
    if (widget.coinModel.balance == BigInt.zero) {
      _finishLoading();
      return;
    }

    if (accountXrp['isCreate'] == false) {
      if (transferValue < BigInt.from(widget.coinModel.other.reserveBase)) {
        errorMessage = S
            .of(context)
            .g_key_t_52(widget.coinModel.other.reserveBase);
        _finishLoading();
        return;
      }
    }
    errorMessage = "";

    final TransationRecordModel trModel = _buildTransactionRecord(toAddr);
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
    trModel.other = RippleTrModel(
      "XRP",
      widget.coinModel.other.sequence,
      destinationTag: destTagCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(destTagCtrl.text.trim()),
    );
    return trModel;
  }

  Future<void> signTx(TransationRecordModel trModel) async {
    if (!signTxCheck()) return;
    bool completedWithExit = false;
    try {
      const coinType = 'XRP';
      final addrType = widget.coinModel.addrType;
      final baseInfo = widget.coinModel.coin['baseInfo'] as Map<String, dynamic>?;
      final pathMap = baseInfo?['path'] as Map<String, dynamic>?;
      final basePath = pathMap?[addrType]?.toString() ?? "m/44'/144'/0'/0/0";
      final path = getPathWithIndex(basePath, widget.coinModel.pathIndex);
      final decimals = (widget.coinModel.coin['decimals'] as num?)?.toInt() ?? 6;
      final destTag = (trModel.other as RippleTrModel?)?.destinationTag;

      final result = await SenderFactory.instance.getSender(coinType).send(
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
          destinationTag: destTag,
        ),
      );

      if (!mounted) return;
      if (result.success) {
        trModel.txHash = result.txHash ?? '';
        trModel.trId = await AppDatabase().insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(coinType, toTextEditingController.text.trim());
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

  bool signTxCheck() {
    if (widget.coinModel.coin['blockchainType'] !=
        BlockchainType.Ethereum.name) {
      return true;
    }
    if (!widget.coinModel.coin['isContract']) return true;

    final BigInt chainBalance = chainModel?.balance ?? BigInt.zero;
    if (chainBalance == BigInt.zero || totalGasPrice > chainBalance) {
      ToastUtils.show(S.current.g_key_t_29(chainModel?.coin['coinType'] ?? ""));
      return false;
    }
    return true;
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
    transferValue = maxTransferableAmount(
      balance: widget.coinModel.balance,
      fee: totalGasPrice,
      reserve: BigInt.from(widget.coinModel.other.reserveBase),
    );
    valueTextEditingController.text = toEther(
      transferValue.toString(),
      widget.coinModel.coin['decimals'],
    ).toString();
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
