part of 'wallet_chain_send_dot.dart';

/// Business logic mixin for [_WalletChainSendDotState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _DotSendLogicMixin on ConsumerState<WalletChainSendDot> {
  CoinModel? chainModel;

  final Regular _regular = Regular();
  final DataUtils dataUtils = DataUtils();
  final DotApi dotApi = DotApi();
  final TokenViewApi tokenViewApi = TokenViewApi();

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
  }

  // 获取余额
  Future<void> getBalance() async {
    setState(() => load = Load.loading);
    final bool isOk = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (!isOk) {
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
    }
    setState(() => load = Load.finish);
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
    if (value.isEmpty) value = valueTextEditingController.text;
    final int decimals = widget.coinModel.coin['decimals'] as int;
    final int minValue = decimals == 0 ? 1 : 0;

    if (value.isEmpty) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }

    final bool isInteger = _regular.regularNums(value);
    // 整数精度币种输入非整数时直接拒绝
    if (decimals == 0 && !isInteger) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }

    final bool isDouble = _regular.regularDouble(value);
    if (!isDouble && !isInteger) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }

    final double dValue = double.parse(value);
    if (dValue <= 0 || dValue < minValue) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }

    final BigInt valueBi =
        ethToWeiString(value, widget.coinModel.coin['decimals']);
    if (!widget.coinModel.coin['isContract'] &&
        valueBi + totalGasPrice > widget.coinModel.balance) {
      _setAmountError(S.of(context).g_key_47);
      return;
    }

    transferValue = valueBi;
    amountErrorMessage = "";
    setState(() {});
  }

  void _setAmountError(String message) {
    amountErrorMessage = message;
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

    final bool valid = await Trustdart()
        .validateAddress(widget.coinModel.coin['coinType'], addr);
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
      _finishLoading();
      return;
    }

    final TransationRecordModel trModel = TransationRecordModel()
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
      ..price = transferValue
      ..returnSignHash = true;

    final String txHash = await signTx(trModel);
    await getGasPrice(txHash);
    if (!mounted) return;
    if (errorMessage.isNotEmpty) {
      _finishLoading();
      return;
    }

    final BigInt uBalance = widget.coinModel.coin['isContract']
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      _finishLoading();
      return;
    }

    final String feeUnit =
        (chainModel ?? widget.coinModel).coin['unit'].toString().toUpperCase();
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
      _finishLoading();
    }
  }

  void _finishLoading() => setState(() => load = Load.finish);

  Future<dynamic> signTx(TransationRecordModel trModel) async {
    try {
      final MessageModel mm = await TransferApi().transferWallet(
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
        if (!trModel.returnSignHash) {
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
    valueTextEditingController.text = widget.coinModel.balanceStringAll();
    if (widget.coinModel.coin['isContract']) {
      transferValue = widget.coinModel.balance;
    } else {
      transferValue = widget.coinModel.balance - totalGasPrice;
      valueTextEditingController.text = _regular.formartNum(
        toEther(transferValue.toString(), widget.coinModel.coin['decimals'])
            .toDouble(),
        14,
        isCrop: true,
        isFill0: false,
      );
    }
    amountErrorMessage = "";
    setState(() {});
  }

  // 关闭键盘
  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void faceMatchTypeWidget() {
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final textStyle = TextStyle(
      fontSize: ScreenUtil().setWidth(32.0),
      color: textColor,
    );

    Widget faceOption(int type, String label) {
      return InkWell(
        onTap: () async {
          final String? address = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FaceMatch(type)),
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
          child: Text(label, style: textStyle, textAlign: TextAlign.center),
        ),
      );
    }

    final Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        faceOption(1, S.of(context).photograph),
        faceOption(2, S.of(context).g_key_nft_16),
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
