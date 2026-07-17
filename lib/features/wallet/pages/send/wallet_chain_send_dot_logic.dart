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
    if (widget.coinModel.config.isContract) {
      final wap = ref.read(wapBridgeProvider);
      final cIndex = wap.coinModels.indexWhere((element) {
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
  }

  Future<void> getBalance() async {
    setState(() => load = Load.loading);
    final isOk = await fetchCoinBalance(
      widget.coinModel,
      ref.read(wapBridgeProvider),
      getToken: false,
    );
    if (!mounted) return;
    if (!isOk) {
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
    }
    setState(() => load = Load.finish);
  }

  Future<void> getGasPrice(String txHash) async {
    setState(() => load = Load.loading);
    final rmm = await dotApi.getGasPrice(
      txHash,
      isTest: widget.coinModel.isTest,
    );
    if (!mounted) return;
    if (!rmm.error) {
      totalGasPrice = BigInt.parse(rmm.data['partialFee']);
    } else {
      errorMessage = rmm.data;
    }
    setState(() => load = Load.finish);
  }

  void amountCheck({String value = ""}) {
    if (value.isEmpty) value = valueTextEditingController.text;
    final int decimals = widget.coinModel.coin['decimals'] as int;
    final int minValue = decimals == 0 ? 1 : 0;

    if (value.isEmpty) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }

    final bool isInteger = _regular.regularNums(value);
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

    final BigInt valueBi = ethToWeiString(
      value,
      widget.coinModel.coin['decimals'],
    );
    if (!widget.coinModel.config.isContract &&
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

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show("loading");
      return;
    }
    if (amountErrorMessage.isNotEmpty) return;
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage.isNotEmpty) return;
    setState(() => load = Load.loading);
    final String? toAddr = await toAddressCheck(
      toTextEditingController.text.trim(),
    );
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
      ..coinMiniName = widget.coinModel.config.coinType
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = widget.coinModel.isTest
          ? widget.coinModel.config.contractTest
          : widget.coinModel.config.contract
      ..isTest = widget.coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = gasPrice
      ..price = transferValue;

    // Use fixed fee estimate for DOT/KSM (10000000 planck = 0.01 DOT)
    totalGasPrice = BigInt.from(10000000) * gas;
    trModel.gasPrice = totalGasPrice;

    final BigInt uBalance = widget.coinModel.config.isContract
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      _finishLoading();
      return;
    }

    final String feeUnit = (chainModel ?? widget.coinModel).coin['unit']
        .toString()
        .toUpperCase();
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
      _finishLoading();
    }
  }

  void _finishLoading() => setState(() => load = Load.finish);

  Future<void> signTx(TransationRecordModel trModel) async {
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
          "m/44'/354'/0'/0/0";
      final path = getPathWithIndex(basePath, widget.coinModel.pathIndex);
      final decimals =
          (widget.coinModel.coin['decimals'] as num?)?.toInt() ?? 10;

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

  Future<void> scanQR() async {
    final scanValue = await Navigator.push(
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
    if (widget.coinModel.config.isContract) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
    } else {
      transferValue = maxTransferableAmount(
        balance: widget.coinModel.balance,
        fee: totalGasPrice,
      );
      valueTextEditingController.text = _regular.formartNum(
        toEther(
          transferValue.toString(),
          widget.coinModel.coin['decimals'],
        ).toDouble(),
        14,
        isCrop: true,
        isFill0: false,
      );
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
