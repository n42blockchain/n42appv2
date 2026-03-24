part of 'wallet_chain_send_ton.dart';

/// Business logic mixin for [_WalletChainSendTonState].
mixin _TonSendLogicMixin on ConsumerState<WalletChainSendTon> {
  CoinModel? chainModel;

  late final Regular regular = Regular();
  late final DataUtils dataUtils = DataUtils();

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

  Load load = Load.loading;
  Load gasLimitLoad = Load.finish;

  Map<String, dynamic> get _coin => widget.coinModel.coin;
  String get _coinType => _coin['coinType']?.toString() ?? '';
  bool get _isContract => _coin['isContract'] == true;
  int get _decimals => (_coin['decimals'] as num?)?.toInt() ?? 18;
  String get _blockchainType => _coin['blockchainType']?.toString() ?? '';

  String get _contract =>
      (widget.coinModel.isTest ? _coin['contract_test'] : _coin['contract'])
          as String? ??
      '';

  static const _noLatestCoinTypes = {
    'OKT',
    'MTR',
    'METIS',
    'VIC',
    'BOBA',
    'OP',
    'GO',
  };

  Future<void> initData() async {
    if (_coinType.isEmpty || _blockchainType.isEmpty) {
      errorMessage = 'Invalid coin configuration';
      ToastUtils.show(errorMessage);
      if (mounted) setState(() => load = Load.finish);
      return;
    }
    if (_isContract) {
      final WalletActionProvider wap = ref.read(wapBridgeProvider);
      final int cIndex = wap.coinModels.indexWhere((element) {
        if (element.coin['coinType'] != _coinType) return false;
        if (widget.coinModel.privateKey != null) {
          return element.privateKey == widget.coinModel.privateKey;
        }
        return true;
      });
      if (cIndex < 0) {
        errorMessage = 'Missing parent chain for $_coinType';
        ToastUtils.show(errorMessage);
        if (mounted) setState(() => load = Load.finish);
        return;
      }
      chainModel = wap.coinModels[cIndex];
      await chainModel?.getBalance();
      if (!mounted) return;
      setState(() {});
    }
    gas = BigInt.from(getCoinGas(_coinType, contract: _isContract));
    await getBalance();
    await getGasPrice();
  }

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

  Future<void> getGasPrice() async {
    totalGasPrice = BigInt.from(1000000);
    setState(() => load = Load.finish);
  }

  Future<dynamic> estimateGasEthLocal({bool checkAddress = true}) async {
    closeKeyboard();
    if (gasLimitLoad == Load.loading) return;
    setState(() => gasLimitLoad = Load.loading);

    final isEthereum = _blockchainType == BlockchainType.Ethereum.name;
    final isTron = _blockchainType == BlockchainType.Tron.name;
    if (!isEthereum && !isTron) return;

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

      final BigInt gaslimit = BigInt.from(
        getCoinGas(_coinType, contract: _isContract),
      );
      final BigInt weiValue = ethToWeiString(price, _decimals);
      final MessageModel ethMessage;

      if (isTron) {
        final TrxApi trxApi = TrxApi();
        ethMessage = await trxApi.getGasEstimateTrx(
          widget.coinModel.address,
          toAddr,
          gasPrice,
          weiValue,
          gaslimit,
          contract: _contract,
          isTest: widget.coinModel.isTest,
        );
      } else {
        final String rpc =
            (widget.coinModel.isTest ? _coin['service_test'] : _coin['service'])
                as String;
        final EthAPI ethAPI = EthAPI.init(null, rpc, null);
        ethMessage = await ethAPI.getGasLimit(
          widget.coinModel.address,
          toAddr,
          gasPrice,
          weiValue,
          gaslimit,
          contract: _contract,
          isTest: widget.coinModel.isTest,
          addLatest: !_noLatestCoinTypes.contains(_coinType),
        );
      }

      if (ethMessage.error == false) {
        gas = ethMessage.data;
        if (_coinType == CoinType.BOBA.name || _coinType == CoinType.OP.name) {
          gas = BigInt.from(gas.toInt() * 1.5);
        }
        if (isEthereum && !_isContract) {
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
      if (mounted) {
        setState(() => gasLimitLoad = Load.finish);
      }
    }
  }

  void amountCheck({String value = ""}) {
    if (value.isEmpty) value = valueTextEditingController.text;
    final int minValue = _decimals == 0 ? 1 : 0;

    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    final checkValue1 = regular.regularNums(value);
    if (_decimals == 0 && !checkValue1) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    }

    final checkValue = regular.regularDouble(value);
    final dValue = double.parse(value);

    if (!checkValue && !checkValue1) {
      amountErrorMessage = S.of(context).g_key_134;
    } else if (dValue <= 0 || dValue < minValue) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
    } else {
      amountErrorMessage = "";
    }
    setState(() {});
  }

  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }
    final parts = addr.split(":");
    if (parts.length == 2) addr = parts[1];

    final valid = await Trustdart().validateAddress(_coinType, addr);
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
      setState(() => load = Load.finish);
      return;
    }

    final uBalance = _isContract
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;
    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      setState(() => load = Load.finish);
      return;
    }

    if (!mounted) return;
    transferValue = ethToWeiString(valueTextEditingController.text, _decimals);

    final TransationRecordModel trModel = TransationRecordModel();
    trModel.address = widget.coinModel.address.toString();
    trModel.from1 = widget.coinModel.address.toString();
    trModel.to1 = toAddr;
    trModel.addrType = widget.coinModel.addrType;
    trModel.coin = _coin;
    trModel.coinMiniName = _coinType;
    trModel.walletIndex = ref.read(wapBridgeProvider).walletIndex;
    trModel.contract = _contract;
    trModel.isTest = widget.coinModel.isTest ? 1 : 0;
    trModel.gasPrice = totalGasPrice;
    trModel.gas = gas.toInt();
    trModel.gasPriceValue = gasPrice;
    trModel.price = transferValue;

    final String feeUnit = chainModel == null
        ? _coin['unit'].toString().toUpperCase()
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
      setState(() => load = Load.finish);
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
          _coinType,
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
    if (_isContract) {
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
        _decimals,
      ).toString();
    }
    amountErrorMessage = "";
    setState(() {});
  }

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
