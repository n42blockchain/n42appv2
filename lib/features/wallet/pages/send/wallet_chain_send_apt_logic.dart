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
    if (widget.coinModel.coin['isContract'] == true) {
      WalletActionProvider wap = ref.read(wapBridgeProvider);
      int cIndex = wap.coinModels.indexWhere((element) {
        if (element.coin['coinType'] == widget.coinModel.coin['coinType']) {
          if (widget.coinModel.privateKey != null) {
            return element.privateKey == widget.coinModel.privateKey;
          }
          return true;
        }
        return false;
      });
      if (cIndex != -1) {
        chainModel = wap.coinModels[cIndex];
        await chainModel?.getBalance();
        if (!mounted) return;
        setState(() {});
      }
    }
    gas = BigInt.from(getCoinGas(widget.coinModel.coin['coinType'],
        contract: widget.coinModel.coin['isContract']));
    await getBalance();
    await getGasPrice();
  }

  Future<void> getBalance() async {
    setState(() {
      load = Load.loading;
    });
    bool isOk = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (!isOk) {
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
    }
    setState(() {
      load = Load.finish;
    });
  }

  Future<void> getGasPrice() async {
    setState(() {
      load = Load.loading;
    });
    try {
      final aptApi = AptApi(isTest: widget.coinModel.isTest);
      final mmGas = await aptApi.getGasPrice();
      if (!mounted) return;
      if (!mmGas.error) {
        gasPrice = mmGas.data as BigInt;
      }
    } catch (_) {
      // 降级：使用默认 gas price
      gasPrice = BigInt.from(100);
    }
    totalGasPrice = gasPrice * gas;
    if (!mounted) return;
    setState(() {
      load = Load.finish;
    });
  }

  void amountCheck({String value = ''}) {
    if (value.isEmpty) {
      value = valueTextEditingController.text;
    }
    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    bool checkValue = regular.regularDouble(value);
    bool checkInt = regular.regularNums(value);
    double dValue = double.tryParse(value) ?? 0;
    if (!checkValue && !checkInt) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    } else if (dValue <= 0) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    BigInt valueBi = ethToWeiString(value, widget.coinModel.coin['decimals']);
    if (widget.coinModel.coin['isContract'] == false) {
      if (valueBi + totalGasPrice > widget.coinModel.balance) {
        amountErrorMessage = S.of(context).g_key_47;
        setState(() {});
        return;
      }
    }
    transferValue = valueBi;
    amountErrorMessage = '';
    setState(() {});
  }

  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }
    bool check = await Trustdart()
        .validateAddress(widget.coinModel.coin['coinType'], addr);
    if (!mounted) return null;
    if (check) {
      if (addr.toUpperCase() ==
          widget.coinModel.address.toString().toUpperCase()) {
        toErrorMessage = S.current.g_key_t_50;
        setState(() {});
        return null;
      }
      toErrorMessage = '';
      setState(() {});
      return addr;
    } else {
      toErrorMessage = S.current.g_key_t_50;
      setState(() {});
      return null;
    }
  }

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show('loading');
      return;
    }
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage.isNotEmpty) return;

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

    if (widget.coinModel.balance == BigInt.zero) {
      setState(() {
        load = Load.finish;
      });
      return;
    }

    final BigInt uBalance = widget.coinModel.coin['isContract'] == true
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;

    if (totalGasPrice > uBalance) {
      setState(() {
        load = Load.finish;
      });
      return;
    }

    TransationRecordModel trModel = TransationRecordModel();
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
    trModel.coinId = widget.coinModel.isTest
        ? widget.coinModel.coin['chainId_test']
        : widget.coinModel.coin['chainId'];

    final bool check = await Navigator.push(
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
        AppDatabase appDatabase = AppDatabase();
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

  Future<void> maxTag() async {
    if (widget.coinModel.coin['isContract'] == true) {
      valueTextEditingController.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
    } else {
      final BigInt maxValue = widget.coinModel.balance - totalGasPrice;
      if (maxValue > BigInt.zero) {
        transferValue = maxValue;
        valueTextEditingController.text =
            toEther(transferValue.toString(), widget.coinModel.coin['decimals'])
                .toString();
      }
    }
    amountErrorMessage = '';
    setState(() {});
  }

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
