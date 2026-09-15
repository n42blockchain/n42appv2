part of 'wallet_chain_send_apt.dart';

/// Business logic mixin for [_WalletChainSendAptState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, gas fetching, input validation, and transaction submission.
mixin _AptSendLogicMixin on ConsumerState<WalletChainSendApt> {
  CoinModel? chainModel;

  Regular? _logicRegular;
  Regular get regular => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

  final NumberFormat oCcy = NumberFormat('#,##0.00########', 'en_US');
  final TextEditingController toTextEditingController = TextEditingController();
  final TextEditingController valueTextEditingController =
      TextEditingController();
  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();

  String toErrorMessage = '';
  String amountErrorMessage = '';
  String errorMessage = '';

  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gas = BigInt.zero;
  BigInt transferValue = BigInt.zero;

  Load load = Load.loading;

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
      if (cIndex != -1) {
        // indexWhere 找不到返回 -1，直接下标会 RangeError。
        chainModel = cIndex >= 0 ? wap.coinModels[cIndex] : null;
        if (chainModel != null) {
          await fetchCoinBalance(chainModel!, ref.read(wapBridgeProvider));
        }
        if (!mounted) return;
        setState(() {});
      }
    }
    gas = BigInt.from(
      getCoinGas(
        widget.coinModel.config.coinType,
        contract: widget.coinModel.config.isContract,
      ),
    );
    await getBalance();
    await getGasPrice();
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

  Future<void> getGasPrice() async {
    setState(() => load = Load.loading);
    try {
      final aptApi = AptApi(isTest: widget.coinModel.isTest);
      final mmGas = await aptApi.getGasPrice();
      if (!mounted) return;
      if (!mmGas.error) {
        gasPrice = mmGas.data as BigInt;
      }
    } catch (_) {
      gasPrice = BigInt.from(100);
    }
    totalGasPrice = gasPrice * gas;
    if (!mounted) return;
    setState(() => load = Load.finish);
  }

  void _setAmountError(String msg) {
    amountErrorMessage = msg;
    setState(() {});
  }

  void amountCheck({String value = ''}) {
    if (value.isEmpty) value = valueTextEditingController.text;
    if (value.isEmpty) {
      _setAmountError(S.of(context).g_key_46(0));
      return;
    }
    final checkValue = regular.regularDouble(value);
    final checkInt = regular.regularNums(value);
    final dValue = double.tryParse(value) ?? 0;
    if (!checkValue && !checkInt) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }
    if (dValue <= 0) {
      _setAmountError(S.of(context).g_key_46(0));
      return;
    }
    final valueBi = ethToWeiString(value, widget.coinModel.coin['decimals']);
    if (widget.coinModel.coin['isContract'] == false) {
      if (valueBi + totalGasPrice > widget.coinModel.balance) {
        _setAmountError(S.of(context).g_key_47);
        return;
      }
    }
    transferValue = valueBi;
    _setAmountError('');
  }

  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }
    final valid = await Trustdart().validateAddress(
      widget.coinModel.config.coinType,
      addr,
    );
    if (!mounted) return null;

    final isSelfAddress =
        addr.toUpperCase() == widget.coinModel.address.toString().toUpperCase();
    if (!valid || isSelfAddress) {
      toErrorMessage = S.current.g_key_t_50;
      setState(() {});
      return null;
    }
    toErrorMessage = '';
    setState(() {});
    return addr;
  }

  void _finishLoading() {
    setState(() => load = Load.finish);
  }

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show('loading');
      return;
    }
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage.isNotEmpty) return;

    setState(() => load = Load.loading);

    final String? toAddr = await toAddressCheck(
      toTextEditingController.text.trim(),
    );
    if (toAddr == null) {
      _finishLoading();
      return;
    }

    if (widget.coinModel.balance == BigInt.zero) {
      _finishLoading();
      return;
    }

    final BigInt uBalance = widget.coinModel.config.isContract
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;

    if (totalGasPrice > uBalance) {
      _finishLoading();
      return;
    }

    final trModel = TransationRecordModel()
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
      ..price = transferValue
      ..coinId = widget.coinModel.isTest
          ? widget.coinModel.coin['chainId_test']
          : widget.coinModel.coin['chainId'];

    if (!mounted) return;
    final bool? check = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletBaseSend(
          trModel,
          null,
          (chainModel == null
                  ? widget.coinModel.coin['unit']
                  : chainModel!.coin['unit'])
              .toString()
              .toUpperCase(),
        ),
      ),
    );
    if (!mounted) return;
    if (check == true) {
      signTx(trModel);
    } else {
      _finishLoading();
    }
  }

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
          "m/44'/637'/0'/0'/0'";
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

  Future<void> maxTag() async {
    if (widget.coinModel.config.isContract) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
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
    amountErrorMessage = '';
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
