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

  bool _signing = false;
  String? _acceptedHash;

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
      // indexWhere 找不到返回 -1，直接下标会 RangeError。
      chainModel = cIndex >= 0 ? wap.coinModels[cIndex] : null;
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
        await (widget.gasPriceLoader?.call(widget.coinModel) ??
            tokenViewApi.getGasPrice(
              coin['blockchainType'],
              coin['coinType'],
              isTest: widget.coinModel.isTest,
              rpc: rpc,
            )) ??
        MessageModel.error();
    if (!mounted) return;
    if (!mm.error) {
      gasPrice = mm.data;
      totalGasPrice = suiTransferGasBudget;
    } else {
      gasPrice = BigInt.zero;
      totalGasPrice = BigInt.zero;
      errorMessage = mm.data.toString();
      ToastUtils.show(errorMessage);
    }
    setState(() => load = Load.finish);
  }

  /// 获取持有的所有可用 SUI 资产 (Coin objects)
  Future<void> getOwnerObjects() async {
    final List<dynamic> v =
        await (widget.ownedObjectsLoader?.call(widget.coinModel) ??
            SuiApi(isTest: widget.coinModel.isTest)
                .getOwnedObjects(widget.coinModel.address));
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
        final parts = toAddr.split(":");
        if (parts.length == 2) toAddr = parts[1];
      }
      if (toErrorMessage.isNotEmpty) return;
      final price = valueTextEditingController.text;
      if (price.isEmpty) return;

      final exactAmount = suiAmountToBaseUnits(
        price,
        widget.coinModel.config.decimals,
      );
      if (exactAmount == null || exactAmount <= BigInt.zero) {
        errorMessage = S.current.g_key_134;
        return false;
      }
      final signData = <String, dynamic>{
        "type": "SUI_TRANSFER",
        "fromAddress": widget.coinModel.address,
        "referenceGasPrice": gasPrice.toString(),
        "gasBudget": suiTransferGasBudget.toString(),
        "toAddress": toAddr,
        "amount": exactAmount.toString(),
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
      final signed = SuiSignedTransaction.parse(signStr);
      if (signed == null) {
        errorMessage = S.current.g_key_wallet_m6;
        return false;
      }
      final MessageModel suiMessage = await suiApi.dryRunTransactionBlock(
        signed.transaction,
      );
      if (!mounted) return false;

      if (!suiMessage.error) {
        // Keep the full signing budget reserved; net simulated gas can include rebates.
        totalGasPrice = suiTransferGasBudget;
        errorMessage = "";
        return true;
      }
      errorMessage = suiMessage.data;
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      if (mounted) {
        setState(() {
          gasLimitLoad = Load.finish;
        });
      }
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
    final BigInt? parsedValue = suiAmountToBaseUnits(
      value,
      (coin['decimals'] as num).toInt(),
    );
    if (parsedValue == null) {
      setError(S.of(context).g_key_134);
      return;
    }
    final BigInt valueBi = parsedValue;
    if (valueBi == BigInt.zero) {
      setError(S.of(context).g_key_46(minValue));
      return;
    }
    if (valueBi.isNegative) {
      setError(S.of(context).g_key_134);
      return;
    }

    final dValue = double.parse(value);
    if (dValue <= 0 || dValue < minValue) {
      setError(S.of(context).g_key_46(minValue));
      return;
    }

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
    if (_acceptedHash != null || _signing) return;
    if (load == Load.loading) {
      ToastUtils.show("loading");
      return;
    }
    if (amountErrorMessage != "") return;
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage != "") return;

    final requestedRecipient = toTextEditingController.text.trim();
    final requestedAmount = valueTextEditingController.text;
    final requestedValue = transferValue;
    final requestedUser = AppGlobals.userInfo?.uuid ?? "";
    final requestedWallet = ref.read(wapBridgeProvider).walletIndex;
    final requestedAddress = widget.coinModel.address;
    final requestedNetwork = widget.coinModel.isTest;
    final requestedPathIndex = widget.coinModel.pathIndex;
    final requestedAddressType = widget.coinModel.addrType;
    bool requestIsCurrent() =>
        mounted &&
        (AppGlobals.userInfo?.uuid ?? "") == requestedUser &&
        toTextEditingController.text.trim() == requestedRecipient &&
        valueTextEditingController.text == requestedAmount &&
        ref.read(wapBridgeProvider).walletIndex == requestedWallet &&
        widget.coinModel.address == requestedAddress &&
        widget.coinModel.isTest == requestedNetwork &&
        widget.coinModel.pathIndex == requestedPathIndex &&
        widget.coinModel.addrType == requestedAddressType;

    setState(() => load = Load.loading);

    final String? toAddr = await toAddressCheck(requestedRecipient);
    if (!mounted) return;
    if (!requestIsCurrent()) {
      _resetLoad();
      return;
    }
    if (toAddr == null) {
      _resetLoad();
      return;
    }

    final estimated = await estimateGasEthLocal(checkAddress: false);
    if (!mounted) return;
    if (!requestIsCurrent() || estimated != true || errorMessage != "") {
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
    trModel.price = requestedValue;
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
    if (check == true && requestIsCurrent()) {
      await signTx(trModel);
    } else {
      _resetLoad();
    }
  }

  Future<void> signTx(TransationRecordModel trModel) async {
    if (!mounted || _signing || _acceptedHash != null) return;
    bool ownerIsCurrent() =>
        mounted &&
        (AppGlobals.userInfo?.uuid ?? '') == trModel.userUuid &&
        ref.read(wapBridgeProvider).walletIndex == trModel.walletIndex &&
        widget.coinModel.address == trModel.from1 &&
        widget.coinModel.isTest == (trModel.isTest == 1);
    if (!ownerIsCurrent()) return;
    final writeRecord =
        widget.transactionWriter ??
        (record) => AppDatabase().insertTransationRecord(record);
    _signing = true;
    bool completedWithExit = false;
    try {
      final coinType = widget.coinModel.config.coinType;
      // 派生参数必须跟随发起账户：token 模型的 addrType/pathIndex 复制自其所
      // 属主链账户，而 chainModel 只是「首个 coinType 匹配」的主链模型，多账
      // 户时可能属于别的账户——用它的 pathIndex 签名会跟 from 地址对不上。
      // chainModel 只允许充当 path 模板缺失时的回退来源。
      final addrType = widget.coinModel.addrType;
      final basePath =
          widget.coinModel.config.pathForAddrType(addrType) ??
          chainModel?.config.pathForAddrType(addrType) ??
          "m/44'/784'/0'/0'/0'";
      final path = getPathWithIndex(basePath, widget.coinModel.pathIndex);
      final decimals =
          (widget.coinModel.coin['decimals'] as num?)?.toInt() ?? 18;

      final send =
          widget.transactionSender ??
          SenderFactory.instance.getSender(coinType).send;
      final result = await send(
        SendParams(
          coinType: coinType,
          fromAddress: trModel.from1,
          toAddress: trModel.to1,
          amount: toEther(trModel.price.toString(), decimals).toDouble(),
          decimals: decimals,
          valueWeiOverride: trModel.price,
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

      if (result.success) {
        trModel.txHash = result.txHash ?? '';
        _acceptedHash = trModel.txHash;
        trModel.trId = await writeRecord(trModel);
        if (trModel.trId <= 0) throw StateError('Transaction was not saved');
        if (!ownerIsCurrent()) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(coinType, trModel.to1);
        if (!ownerIsCurrent()) return;
        ToastUtils.show(S.current.g_key_nft_41);
        completedWithExit = true;
        Navigator.pop(context);
      } else {
        if (!ownerIsCurrent()) return;
        errorMessage = result.error ?? '';
        ToastUtils.show(errorMessage);
      }
    } catch (e) {
      if (ownerIsCurrent()) {
        errorMessage = _acceptedHash == null
            ? e.toString()
            : '${S.current.g_key_nft_41}: $_acceptedHash. $e';
        ToastUtils.show(errorMessage);
      }
    } finally {
      _signing = false;
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
      ToastUtils.show(S.current.g_key_t_29(chainModel?.config.coinType ?? ""));
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
