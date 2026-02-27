part of 'wallet_chain_send_dot.dart';

/// Business logic mixin for [_WalletChainSendDotState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _DotSendLogicMixin on ConsumerState<WalletChainSendDot> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get _regular => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

  DotApi? _logicDotApi;
  DotApi get dotApi => _logicDotApi ??= DotApi();

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
    /*await getGasPrice();
    if(getEthLayer2(widget.coinModel.coin['coinType'])){
      gasEth=BigInt.from(getCoinGas(CoinType.ETH.name));
      await getGasPrice_layer2();
    }*/
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
    }
    setState(() {
      load = Load.finish;
    });
  }

  // 获取旷工费
  Future<void> getGasPrice(String txHash) async {
    setState(() {
      load = Load.loading;
    });
    final MessageModel rmm = await dotApi.getGasPrice(
      txHash,
      isTest: widget.coinModel.isTest,
    );
    if (!mounted) return;
    if (rmm.error == false) {
      totalGasPrice = BigInt.parse(rmm.data['partialFee']);
    } else {
      errorMessage = rmm.data;
    }
    load = Load.finish;
    setState(() {});
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
    final bool check = await Trustdart()
        .validateAddress(widget.coinModel.coin['coinType'], addr);
    if (check) {
      if (addr.toUpperCase() ==
          widget.coinModel.address.toString().toUpperCase()) {
        toErrorMessage = S.current.g_key_t_50;
        setState(() {});
        return null;
      } else {
        /*if(widget.coinModel.coin['blockchainType']==BlockchainType.Tezos.name){
          checkAccount_XTZ(addr);
        }*/
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
    if (!mounted) return;
    if (toAddr == null) {
      setState(() {
        load = Load.finish;
      });
      return;
    }

    final TransationRecordModel trModel = TransationRecordModel();
    trModel.address = widget.coinModel.address.toString();
    trModel.from1 = widget.coinModel.address.toString();
    trModel.to1 = toAddr; // toTextEditingController.text;
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
    trModel.returnSignHash = true;
    final String txHash = await signTx(trModel);
    await getGasPrice(txHash);
    if (!mounted) return;
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
    trModel.returnSignHash = false;
    if (check) {
      signTx(trModel);
    } else {
      setState(() {
        load = Load.finish;
      });
    }
  }

  Future<dynamic> signTx(TransationRecordModel trModel) async {
    try {
      final TransferApi transferApi = TransferApi();
      final MessageModel mm = await transferApi.transferWallet(
        trModel: trModel,
        privateKey: widget.coinModel.privateKey,
        pathIndex: widget.coinModel.pathIndex,
      );
      if (mm.error) {
        errorMessage = mm.data;
        if (trModel.returnSignHash) {
          return "";
        }
      } else {
        if (trModel.returnSignHash == false) {
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
        } else {
          return mm.data;
        }
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
      // estimateGas_eth_local();
    } else {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      const bool rOK = true; // await estimateGas_eth_local();
      if (rOK) {
        transferValue = widget.coinModel.balance - totalGasPrice;
        valueTextEditingController.text = _regular.formartNum(
          toEther(transferValue.toString(), widget.coinModel.coin['decimals'])
              .toDouble(),
          14,
          isCrop: true,
          isFill0: false,
        );
      }
    }
    amountErrorMessage = "";
    setState(() {});
  }

  // 关闭键盘
  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void faceMatchTypeWidget() {
    final Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            final String? address = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FaceMatch(1)),
            );
            if (!mounted) return;
            if (address != null) {
              toTextEditingController.text = address;
              toAddressCheck(address);
            }
            Navigator.pop(context);
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(88.0),
            width: double.infinity,
            child: Text(
              S.of(context).photograph,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final String? address = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FaceMatch(2)),
            );
            if (!mounted) return;
            if (address != null) {
              toTextEditingController.text = address;
              toAddressCheck(address);
            }
            Navigator.pop(context);
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(88.0),
            width: double.infinity,
            child: Text(
              S.of(context).g_key_nft_16,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
    sheetBottom(context, S.of(context).g_face_match_key1, child);
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
