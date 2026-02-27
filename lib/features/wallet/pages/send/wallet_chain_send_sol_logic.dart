part of 'wallet_chain_send_sol.dart';

/// Business logic mixin for [_WalletChainSendSolState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _SolSendLogicMixin on ConsumerState<WalletChainSendSol> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get _regular => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

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
  }

  // 获取余额
  Future<void> getBalance() async {
    setState(() {
      load = Load.loading;
    });
    final bool isOk = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (isOk == false) {
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
    }
    setState(() {
      load = Load.finish;
    });
  }

  // 获取矿工费
  Future<void> getGasPrice() async {
    if (widget.coinModel.coin['isContract'] == false) {
      totalGasPrice = BigInt.from(5000) * gas;
    } else {
      totalGasPrice = BigInt.from(35000) * gas;
    }
  }

  // 模拟交易
  Future<bool> simulateTransaction() async {
    final MessageModel bhmm = await SolApi()
        .getLatestBlockhash(isTest: widget.coinModel.isTest);
    if (!mounted) return false;
    if (bhmm.error) {
      errorMessage = bhmm.data;
      ToastUtils.show(bhmm.data);
      return false;
    }
    final String toAddr = toTextEditingController.text.trim();
    Map<String, dynamic> txData;
    if (widget.coinModel.coin['isContract'] == false) {
      txData = {
        "type": "SOL",
        "recentBlockhash": bhmm.data,
        "transferTransaction": {
          "recipient": toAddr,
          "value": "1000000",
        },
        "encodeType": "base58",
      };
    } else {
      final String contractAddress = widget.coinModel.isTest
          ? widget.coinModel.coin['contract_test']
          : widget.coinModel.coin['contract'];
      final String recipientTokenAddress =
          await Trustdart().getPubKeySOL(toAddr, contractAddress);
      if (!mounted) return false;
      if (recipientTokenAddress == "") {
        errorMessage = "Error";
        ToastUtils.show("Error");
        setState(() {
          load = Load.finish;
        });
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
          "decimals": widget.coinModel.coin['decimals'].toString(),
        },
        "encodeType": "base58",
      };
    }
    final String path = getPathWithIndex(
      widget.coinModel.coin['path'][widget.coinModel.addrType],
      widget.coinModel.pathIndex,
    );
    final walletInfo = ref.read(wapBridgeProvider).walletInfo;
    final String signStr = await Trustdart().signTransaction(
      widget.coinModel.coin['coinType'],
      path,
      txData,
      mnemonic: walletInfo.mnemonic ?? "",
      pk: walletInfo.privateKey ?? "",
    );
    if (!mounted) return false;
    if (signStr == "") {
      errorMessage = "Error";
      ToastUtils.show("Error");
      setState(() {
        load = Load.finish;
      });
      return false;
    }
    final MessageModel ffmmm = await SolApi()
        .simulateTransaction(signStr, isTest: widget.coinModel.isTest);
    if (ffmmm.error) {
      return false;
    }
    return true;
  }

  // 检查 amount 输入是否正确
  void amountCheck({String value = ""}) {
    if (value == "") {
      value = valueTextEditingController.text;
    }
    int minValue = 0;
    if (widget.coinModel.coin['decimals'] == 0) {
      minValue = 1;
    }
    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }
    bool checkValue1 = false;
    if (widget.coinModel.coin['decimals'] == 0) {
      checkValue1 = _regular.regularNums(value.toString());
      if (checkValue1 == false) {
        amountErrorMessage = S.of(context).g_key_134;
        setState(() {});
        return;
      }
    } else {
      checkValue1 = _regular.regularNums(value.toString());
    }
    final bool checkValue = _regular.regularDouble(value.toString());
    final double dValue = double.parse(value);
    if (checkValue == false && checkValue1 == false) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    } else if (dValue < minValue) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    } else if (dValue == 0) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }
    final BigInt valueBi =
        ethToWeiString(value, widget.coinModel.coin['decimals']);
    if (widget.coinModel.coin['isContract'] == false) {
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

  // 检查转账地址是否正确
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
    final bool check =
        await Trustdart().validateAddress(widget.coinModel.coin['coinType'], addr);
    if (check) {
      if (addr.toUpperCase() ==
          widget.coinModel.address.toString().toUpperCase()) {
        toErrorMessage = S.current.g_key_t_50;
        setState(() {});
        return null;
      } else {
        toErrorMessage = "";
        setState(() {});
        return addr;
      }
    } else {
      toErrorMessage = S.current.g_key_t_50;
      setState(() {});
      return null;
    }
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
    setState(() {
      load = Load.loading;
    });
    final String? toAddr =
        await toAddressCheck(toTextEditingController.text.trim());
    if (toAddr == null) {
      setState(() {
        load = Load.finish;
      });
      return;
    }

    BigInt uBalance = widget.coinModel.balance;
    if (widget.coinModel.coin['isContract']) {
      uBalance = chainModel?.balance ?? BigInt.zero;
    }
    if (totalGasPrice > uBalance) {
      setState(() {
        load = Load.finish;
      });
      return;
    }
    if (widget.coinModel.balance == BigInt.zero) {
      setState(() {
        load = Load.finish;
      });
      return;
    }
    await simulateTransaction();
    if (!mounted) return;
    if (errorMessage != "") {
      setState(() {
        load = Load.finish;
      });
      return;
    }
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
      setState(() {
        load = Load.finish;
      });
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
    if (widget.coinModel.coin['isContract']) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
      simulateTransaction();
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
