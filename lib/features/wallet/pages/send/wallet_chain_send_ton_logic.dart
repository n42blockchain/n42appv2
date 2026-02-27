part of 'wallet_chain_send_ton.dart';

/// Business logic mixin for [_WalletChainSendTonState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _TonSendLogicMixin on ConsumerState<WalletChainSendTon> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get regular => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

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
      load = Load.finish;
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState(() {});
      return;
    }
  }

  // 获取矿工费
  Future<void> getGasPrice() async {
    totalGasPrice = BigInt.from(1000000); // gasPrice * gas
    load = Load.finish;
    setState(() {});
  }

  // eth 模拟交易
  Future<dynamic> estimateGasEthLocal({bool checkAddress = true}) async {
    closeKeyboard();
    if (gasLimitLoad == Load.loading) return;
    setState(() {
      gasLimitLoad = Load.loading;
    });
    if (widget.coinModel.coin['blockchainType'] !=
            BlockchainType.Ethereum.name &&
        widget.coinModel.coin['blockchainType'] != BlockchainType.Tron.name) {
      return;
    }
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
      final String price = valueTextEditingController.text;
      if (price == "") return;

      bool addLatest = true;
      if (widget.coinModel.coin['coinType'] == CoinType.OKT.name ||
          widget.coinModel.coin['coinType'] == CoinType.MTR.name ||
          widget.coinModel.coin['coinType'] == CoinType.METIS.name ||
          widget.coinModel.coin['coinType'] == CoinType.VIC.name ||
          widget.coinModel.coin['coinType'] == CoinType.BOBA.name ||
          widget.coinModel.coin['coinType'] == CoinType.OP.name ||
          widget.coinModel.coin['coinType'] == CoinType.GO.name) {
        addLatest = false;
      }

      final BigInt gaslimit = BigInt.from(getCoinGas(
        widget.coinModel.coin['coinType'],
        contract: widget.coinModel.coin['isContract'],
      ));
      final MessageModel ethMessage;

      if (widget.coinModel.coin['blockchainType'] == BlockchainType.Tron.name) {
        final TrxApi trxApi = TrxApi();
        ethMessage = await trxApi.getGasEstimateTrx(
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
      } else {
        final String rpc = widget.coinModel.isTest
            ? widget.coinModel.coin['service_test']
            : widget.coinModel.coin['service'];
        final EthAPI ethAPI = EthAPI.init(null, rpc, null);
        ethMessage = await ethAPI.getGasLimit(
          widget.coinModel.address,
          toAddr,
          gasPrice,
          ethToWeiString(price, widget.coinModel.coin['decimals']),
          gaslimit,
          contract: widget.coinModel.isTest
              ? widget.coinModel.coin['contract_test']
              : widget.coinModel.coin['contract'],
          isTest: widget.coinModel.isTest,
          addLatest: addLatest,
        );
      }

      if (ethMessage.error == false) {
        gas = ethMessage.data;
        if (widget.coinModel.coin['coinType'] == CoinType.BOBA.name ||
            widget.coinModel.coin['coinType'] == CoinType.OP.name) {
          gas = BigInt.from(gas.toInt() * 1.5);
        }
        if (widget.coinModel.coin['blockchainType'] ==
                BlockchainType.Ethereum.name &&
            widget.coinModel.coin['isContract'] == false) {
          final String note = noteTextEditingController.text.trim();
          if (note != "") {
            final String noteHex = bytesToHex(note.codeUnits);
            gas = gas + BigInt.from((noteHex.length * 8));
          }
        }
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

  // 检查 amount 输入是否正确
  void amountCheck({String value = ""}) {
    if (value == "") {
      value = valueTextEditingController.text;
    }
    final int minValue = widget.coinModel.coin['decimals'] == 0 ? 1 : 0;

    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    bool checkValue1 = false;
    if (widget.coinModel.coin['decimals'] == 0) {
      checkValue1 = regular.regularNums(value);
      if (checkValue1 == false) {
        amountErrorMessage = S.of(context).g_key_134;
        setState(() {});
        return;
      }
    } else {
      checkValue1 = regular.regularNums(value);
    }

    final bool checkValue = regular.regularDouble(value);
    final double dValue = double.parse(value);

    if (checkValue == false && checkValue1 == false) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    } else if (dValue < minValue || dValue == 0) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
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
    if (!check ||
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
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      setState(() {
        load = Load.finish;
      });
      return;
    }

    if (!mounted) return;
    transferValue = ethToWeiString(
      valueTextEditingController.text,
      widget.coinModel.coin['decimals'],
    );

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
