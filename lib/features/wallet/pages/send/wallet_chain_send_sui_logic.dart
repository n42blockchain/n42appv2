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
    await getGasPrice();
    await getOwnerObjects();
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
      load = Load.finish;
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState(() {});
    }
  }

  Future<void> getGasPrice() async {
    setState(() => load = Load.loading);
    final coin = widget.coinModel.coin;
    final rpc = coin['custom'] == true ? coin['service'] as String? : null;
    final mm =
        await tokenViewApi.getGasPrice(
          coin['blockchainType'],
          coin['coinType'],
          isTest: widget.coinModel.isTest,
          rpc: rpc,
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
    setState(() => load = Load.finish);
  }

  /// 获取持有的所有可用 SUI 资产 (Coin objects)
  Future<void> getOwnerObjects() async {
    final List<dynamic> v = await SuiApi(
      isTest: widget.coinModel.isTest,
    ).getOwnedObjects(widget.coinModel.address);
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
      if (toErrorMessage.isNotEmpty) return;
      final price = valueTextEditingController.text;
      if (price.isEmpty) return;

      final signData = <String, dynamic>{
        "referenceGasPrice": totalGasPrice.toInt(),
        "gasBudget": (totalGasPrice.toDouble() * 1.2).toInt(),
        "toAddress": toTextEditingController.text,
        "amount": transferValue.toInt(),
        "utxo": utxos,
      };
      final SuiApi suiApi = SuiApi(isTest: widget.coinModel.isTest);
      final String path = getPathWithIndex(
        widget.coinModel.config.pathForAddrType(widget.coinModel.addrType)!,
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
      final MessageModel suiMessage = await suiApi.dryRunTransactionBlock(
        signStr,
      );
      if (!mounted) return false;

      if (!suiMessage.error) {
        gasPrice = suiMessage.data;
        totalGasPrice = gasPrice;
        errorMessage = "";
        return true;
      }
      errorMessage = suiMessage.data;
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setState(() {
        gasLimitLoad = Load.finish;
      });
    }
  }

  void amountCheck({String value = ""}) {
    if (value.isEmpty) value = valueTextEditingController.text;
    final coin = widget.coinModel.coin;
    final int minValue = coin['decimals'] == 0 ? 1 : 0;

    void setError(String msg) {
      amountErrorMessage = msg;
      setState(() {});
    }

    if (value.isEmpty) {
      setError(S.of(context).g_key_46(minValue));
      return;
    }

    final isInt = regular.regularNums(value);
    final isDouble = regular.regularDouble(value);
    if (coin['decimals'] == 0 && !isInt) {
      setError(S.of(context).g_key_134);
      return;
    }
    if (!isDouble && !isInt) {
      setError(S.of(context).g_key_134);
      return;
    }

    final dValue = double.parse(value);
    if (dValue <= 0 || dValue < minValue) {
      setError(S.of(context).g_key_46(minValue));
      return;
    }

    final valueBi = ethToWeiString(value, coin['decimals']);
    if (!coin['isContract'] &&
        valueBi + totalGasPrice > widget.coinModel.balance) {
      setError(S.of(context).g_key_47);
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

    final List<String> addrList = addr.split(":");
    if (addrList.length == 2) addr = addrList[1];

    final bool valid = await Trustdart().validateAddress(
      widget.coinModel.config.coinType,
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

    final String? toAddr = await toAddressCheck(
      toTextEditingController.text.trim(),
    );
    if (toAddr == null) {
      _resetLoad();
      return;
    }

    await estimateGasEthLocal(checkAddress: false);
    if (!mounted) return;
    if (errorMessage != "") {
      _resetLoad();
      return;
    }

    final BigInt uBalance = widget.coinModel.config.isContract
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance) {
      _resetLoad();
      return;
    }
    if (widget.coinModel.balance == BigInt.zero) {
      _resetLoad();
      return;
    }
    if (!mounted) return;
    final TransationRecordModel trModel = TransationRecordModel();
    trModel.address = widget.coinModel.address.toString();
    trModel.from1 = widget.coinModel.address.toString();
    trModel.to1 = toAddr;
    trModel.addrType = widget.coinModel.addrType;
    trModel.coin = widget.coinModel.coin;
    trModel.coinMiniName = widget.coinModel.config.coinType;
    trModel.walletIndex = ref.read(wapBridgeProvider).walletIndex;
    trModel.contract = widget.coinModel.isTest
        ? widget.coinModel.config.contractTest
        : widget.coinModel.config.contract;
    trModel.isTest = widget.coinModel.isTest ? 1 : 0;
    trModel.gasPrice = totalGasPrice;
    trModel.gas = gas.toInt();
    trModel.gasPriceValue = gasPrice;
    trModel.price = transferValue;
    if (widget.coinModel.config.blockchainType ==
        BlockchainType.Ethereum.name) {
      trModel.message = noteTextEditingController.text.trim();
    }
    final String feeUnit = chainModel == null
        ? widget.coinModel.coin['unit'].toString().toUpperCase()
        : chainModel!.coin['unit'].toString().toUpperCase();
    final bool? check = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => WalletBaseSend(trModel, null, feeUnit),
      ),
    );
    if (!mounted) return;
    if (check == true) {
      signTx(trModel);
    } else {
      _resetLoad();
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

  bool signTxCheck() {
    if (widget.coinModel.config.blockchainType !=
        BlockchainType.Ethereum.name) {
      return true;
    }
    if (!widget.coinModel.config.isContract) return true;

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
    if (widget.coinModel.config.isContract) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
      estimateGasEthLocal();
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
