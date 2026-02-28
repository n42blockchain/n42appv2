part of 'wallet_chain_send_sui.dart';

/// Business logic mixin for [_WalletChainSendSuiState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _SuiSendLogicMixin on ConsumerState<WalletChainSendSui> {
  CoinModel? chainModel;

  late final Regular regular = Regular();
  late final DataUtils dataUtils = DataUtils();
  late final TokenViewApi tokenViewApi = TokenViewApi();

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
  BigInt gasPriceEth = BigInt.zero;
  BigInt gas = BigInt.zero;
  BigInt gasEth = BigInt.zero;
  BigInt transferValue = BigInt.zero;
  List<Map<String, dynamic>> utxos = [];

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
    gas = BigInt.from(getCoinGas(
      widget.coinModel.coin['coinType'],
      contract: widget.coinModel.coin['isContract'],
    ));
    await getBalance();
    await getGasPrice();
    await getOwnerObjects();
  }

  // 获取余额
  Future<void> getBalance() async {
    setState(() => load = Load.loading);
    final bool isOk = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (!isOk) {
      load = Load.finish;
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState(() {});
    }
  }

  // 获取旷工费
  Future<void> getGasPrice() async {
    setState(() => load = Load.loading);
    final String? rpc = widget.coinModel.coin['custom'] == true
        ? widget.coinModel.coin['service']
        : null;
    final MessageModel mm = await tokenViewApi.getGasPrice(
          widget.coinModel.coin['blockchainType'],
          widget.coinModel.coin['coinType'],
          isTest: widget.coinModel.isTest,
          rpc: rpc,
        ) ??
        MessageModel.error();
    if (!mounted) return;
    if (mm.error == false) {
      gasPrice = mm.data;
    } else {
      errorMessage = mm.data.toString();
      ToastUtils.show(errorMessage);
    }
    totalGasPrice = gasPrice * gas;
    load = Load.finish;
    setState(() {});
  }

  /// 获取持有的所有可用 SUI 资产 (Coin objects)
  Future<void> getOwnerObjects() async {
    final List<dynamic> v = await SuiApi(isTest: widget.coinModel.isTest)
        .getOwnedObjects(widget.coinModel.address);
    if (!mounted) return;
    utxos = [
      for (final Map utxo in v)
        {
          "objectId": utxo['data']['objectId'],
          "objectDigest": utxo['data']['digest'],
          "version": utxo['data']['version'],
          "balance": utxo['data']['content']['fields']['balance'],
        },
    ];
  }

  // eth 模拟交易
  Future<dynamic> estimateGasEthLocal({bool checkAddress = true}) async {
    closeKeyboard();
    if (gasLimitLoad == Load.loading) return;
    setState(() => gasLimitLoad = Load.loading);
    try {
      String? toAddr;
      if (checkAddress) {
        if (amountErrorMessage != "") return;
        toAddr = await toAddressCheck(toTextEditingController.text.trim());
        if (!mounted) return false;
        if (toAddr == null) return;
      } else {
        toAddr = toTextEditingController.text.trim();
      }
      if (toErrorMessage != "") return;
      final String price = valueTextEditingController.text;
      if (price == "") return;

      final Map<String, dynamic> signData = {
        "referenceGasPrice": totalGasPrice,
        "gasBudget": totalGasPrice.toInt() * 1.2,
        "toAddress": toTextEditingController.text,
        "amount": BigInt.parse(valueTextEditingController.text),
        "utxo": utxos,
      };
      final SuiApi suiApi = SuiApi(isTest: widget.coinModel.isTest);
      final String path = getPathWithIndex(
        widget.coinModel.coin['path'][widget.coinModel.addrType],
        widget.coinModel.pathIndex,
      );
      final String mnemonic =
          ref.read(wapBridgeProvider).walletInfo.mnemonic ?? "";
      final String signStr = await Trustdart().signTransaction(
        CoinType.SUI.name,
        path,
        signData,
        mnemonic: mnemonic,
        pk: widget.coinModel.privateKey ?? "",
      );
      if (!mounted) return false;
      final MessageModel suiMessage =
          await suiApi.dryRunTransactionBlock(signStr);
      if (!mounted) return false;

      if (suiMessage.error == false) {
        gasPrice = suiMessage.data;
        totalGasPrice = gasPrice;
        errorMessage = "";
        return true;
      } else {
        errorMessage = suiMessage.data;
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setState(() {
        gasLimitLoad = Load.finish;
      });
    }
  }

  // 检查 amount 输入是否正确
  void amountCheck({String value = ""}) {
    if (value.isEmpty) value = valueTextEditingController.text;

    final int minValue = widget.coinModel.coin['decimals'] == 0 ? 1 : 0;

    void setError(String msg) {
      amountErrorMessage = msg;
      setState(() {});
    }

    if (value.isEmpty) {
      setError(S.of(context).g_key_46(minValue));
      return;
    }

    final bool checkNums = regular.regularNums(value);
    if (widget.coinModel.coin['decimals'] == 0 && !checkNums) {
      setError(S.of(context).g_key_134);
      return;
    }

    final bool checkDouble = regular.regularDouble(value);
    final double dValue = double.parse(value);

    if (!checkDouble && !checkNums) {
      setError(S.of(context).g_key_134);
      return;
    }
    if (dValue <= 0 || dValue < minValue) {
      setError(S.of(context).g_key_46(minValue));
      return;
    }

    final BigInt valueBi =
        ethToWeiString(value, widget.coinModel.coin['decimals']);
    if (!widget.coinModel.coin['isContract'] &&
        valueBi + totalGasPrice > widget.coinModel.balance) {
      setError(S.of(context).g_key_47);
      return;
    }

    transferValue = valueBi;
    amountErrorMessage = "";
    setState(() {});
  }

  // 检查转账地址是否正确
  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }

    final List<String> addrList = addr.split(":");
    if (addrList.length == 2) addr = addrList[1];

    final bool valid =
        await Trustdart().validateAddress(widget.coinModel.coin['coinType'], addr);

    if (!valid || addr.toUpperCase() == widget.coinModel.address.toString().toUpperCase()) {
      toErrorMessage = S.current.g_key_t_50;
      setState(() {});
      return null;
    }

    toErrorMessage = "";
    setState(() {});
    return addr;
  }

  void _resetLoad() => setState(() => load = Load.finish);

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

    final String? toAddr =
        await toAddressCheck(toTextEditingController.text.trim());
    if (toAddr == null) { _resetLoad(); return; }

    await estimateGasEthLocal(checkAddress: false);
    if (!mounted) return;
    if (errorMessage != "") { _resetLoad(); return; }

    final BigInt uBalance = widget.coinModel.coin['isContract']
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance) { _resetLoad(); return; }
    if (widget.coinModel.balance == BigInt.zero) { _resetLoad(); return; }
    if (!mounted) return;
    final TransationRecordModel trModel = TransationRecordModel();
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
    if (widget.coinModel.coin['blockchainType'] ==
        BlockchainType.Ethereum.name) {
      trModel.message = noteTextEditingController.text.trim();
    }
    final String feeUnit = chainModel == null
        ? widget.coinModel.coin['unit'].toString().toUpperCase()
        : chainModel!.coin['unit'].toString().toUpperCase();
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
      _resetLoad();
    }
  }

  Future<void> signTx(TransationRecordModel trModel) async {
    if (!signTxCheck()) return;
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

  bool signTxCheck() {
    if (widget.coinModel.coin['blockchainType'] != BlockchainType.Ethereum.name) return true;
    if (!widget.coinModel.coin['isContract']) return true;

    final BigInt chainBalance = chainModel?.balance ?? BigInt.zero;
    if (chainBalance == BigInt.zero || totalGasPrice > chainBalance) {
      ToastUtils.show(
          S.current.g_key_t_29(chainModel?.coin['coinType'] ?? ""));
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
    Navigator.pop(context);
  }

  Future<void> maxTag() async {
    if (gasLimitLoad == Load.loading) return;
    if (widget.coinModel.coin['isContract']) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
      estimateGasEthLocal();
    } else {
      transferValue = widget.coinModel.balance - totalGasPrice;
      valueTextEditingController.text = toEther(
        transferValue.toString(),
        widget.coinModel.coin['decimals'],
      ).toString();
    }
    amountErrorMessage = "";
    setState(() {});
  }

  // 关闭键盘
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
