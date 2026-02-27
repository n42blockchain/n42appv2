part of 'wallet_chain_send_fil.dart';

/// Business logic mixin for [_WalletChainSendFilState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas estimation, input validation, and transaction submission.
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
      setState(() {});
    }
    gas = BigInt.from(getCoinGas(
      widget.coinModel.coin['coinType'],
      contract: widget.coinModel.coin['isContract'],
    ));
    await getBalance();
  }

  // 获取余额
  Future<void> getBalance() async {
    setState(() {
      load = Load.loading;
    });
    final bool isOk = await widget.coinModel.getBalance(getToken: false);
    if (isOk == false) {
      load = Load.finish;
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState(() {});
      return;
    } else {
      setState(() {
        load = Load.finish;
      });
    }
  }

  // 检查 amount 输入是否正确
  void amountCheck({String value = ""}) {
    if (value == "") {
      value = valueTextEditingController.text;
    }
    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    final bool checkValue = regular.regularDouble(value.toString());
    final bool checkValue1 = regular.regularNums(value.toString());
    if (checkValue == false && checkValue1 == false) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    } else if (double.parse(value) <= 0) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    if (widget.coinModel.coin['blockchainType'] == BlockchainType.Ripple.name) {
      final BigInt valueBi =
          ethToWeiString(value, widget.coinModel.coin['decimals']);
      if (valueBi + totalGasPrice >
          widget.coinModel.balance -
              ethToWeiString("10", widget.coinModel.coin['decimals'])) {
        amountErrorMessage = S.of(context).g_key_47;
        setState(() {});
        return;
      }
    } else {
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
    }
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
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage != "") return;
    setState(() {
      load = Load.loading;
    });
    final String? toAddr =
        await toAddressCheck(toTextEditingController.text);
    if (toAddr == null) {
      setState(() {
        load = Load.finish;
      });
      return;
    }
    await estimateGasEthLocal();
    if (errorMessage != "") {
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
    final FilApi filApi = FilApi();
    final MessageModel rDataNonce = await filApi.getNonce(
      widget.coinModel.address.toString(),
      isTest: widget.coinModel.isTest,
    );
    if (!mounted) return;
    if (rDataNonce.error) {
      setState(() {
        errorMessage = rDataNonce.data;
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
    trModel.gasPriceValue = BigInt.zero;
    trModel.price = transferValue;
    trModel.other = FilTrModel(gasFeeCap, gasPremium);
    trModel.nonce = rDataNonce.data.toString();

    final bool check = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WalletBaseSend(trModel, null, widget.coinModel.coin['unit']),
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
    if (signTxCheck() == false) return;
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
        trModel.txHash = mm.data['/'];
        trModel.trId = await AppDatabase().insertTransationRecord(trModel);
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
      setState(() {});
    }
  }

  bool signTxCheck() {
    return true;
  }

  Future<bool?> estimateGasEthLocal() async {
    closeKeyboard();
    if (gasLimitLoad == Load.loading) return null;
    setState(() {
      gasLimitLoad = Load.loading;
    });
    try {
      if (amountErrorMessage != "") return null;
      final String? toAddr =
          await toAddressCheck(toTextEditingController.text);
      if (toAddr == null) return null;
      if (toErrorMessage != "") return null;
      final String price = valueTextEditingController.text;
      if (price == "") return null;
      final BigInt gaslimit =
          BigInt.from(getCoinGas(widget.coinModel.coin['coinType']));
      final FilApi filApi = FilApi();
      final MessageModel ethMessage = await filApi.getGasLimit(
        widget.coinModel.address,
        toAddr,
        gaslimit,
        value:
            ethToWeiString(price, widget.coinModel.coin['decimals']).toString(),
        isTest: widget.coinModel.isTest,
      );
      if (ethMessage.error == false) {
        gas = BigInt.parse(ethMessage.data['GasLimit'].toString());
        gasFeeCap = ethMessage.data['GasFeeCap'];
        gasPremium = ethMessage.data['GasPremium'];
        gasPrice = BigInt.parse(gasFeeCap);
        totalGasPrice = gasPrice * gas;
        errorMessage = "";
        return true;
      } else {
        errorMessage = ethMessage.data;
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
    valueTextEditingController.text = widget.coinModel.balanceStringAll();
    final bool? rOK = await estimateGasEthLocal();
    if (rOK != null && rOK) {
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
}
