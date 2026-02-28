part of 'wallet_chain_send_btc.dart';

/// Business logic mixin for [_WalletChainSendBtcState].
///
/// Declares all shared state fields and contains initialization, fee loading,
/// fee model building, and input validation methods.
mixin _BtcSendLogicMixin on ConsumerState<WalletChainSendBtc> {
  // -- Lazy-initialized service objects --

  TransferApi? _logicTransferApi;
  TransferApi get transferApi => _logicTransferApi ??= TransferApi();

  Regular? _logicRegular;
  Regular get regular => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

  TokenViewApi? _logicTokenViewApi;
  TokenViewApi get tokenViewApi => _logicTokenViewApi ??= TokenViewApi();

  // -- Controllers & focus nodes --

  final TextEditingController toTextEditingController = TextEditingController();
  final TextEditingController valueTextEditingController =
      TextEditingController();
  final TextEditingController byteFeeTextEditingController =
      TextEditingController();
  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();
  final FocusNode byteFeeNode = FocusNode();

  // -- Validation error messages --

  String toErrorMessage = '';
  String amountErrorMessage = '';
  String bytefeeErrorMessage = '';
  String errorMessage = '';

  // -- State --

  Load utxoLoad = Load.finish;
  Load load = Load.loading;
  int price = 0;

  /// Selected UTXOs that will be used as inputs for the next transaction.
  List<Map<String, dynamic>> inputUTXO = [];

  // UTXO pagination
  int utxoPageSize = 50;
  int utxoPageNum = 1;
  bool utxoLastPage = false;

  /// Full UTXO list fetched from the server.
  List<dynamic> unspents = [];

  /// When false the address/amount fields are locked (e.g. called from DApp).
  bool toTextFieldEnabel = true;

  NonEvmFeeModel? _btcFeeModel;

  Map<String, dynamic> gasFeeLevel = {
    'error': false,
    'averageValue': 5,
    'loading': false,
    'gasFeeRate': 5,
    'gasFees': 0,
    'signByteSize': 0,
    'maxValue': 0,
  };

  // -- Initialization --

  Future<void> initData() async {
    await checkLastTx();
    await getGasFeeBtc();
    await getBalance();
  }

  Future<void> checkLastTx() async {
    final checkLastModel = await transferApi.checkLastTxBtc(
      widget.coinModel.coin['coinType'],
      widget.coinModel.address,
    );
    if (checkLastModel.error) {
      errorMessage = checkLastModel.data;
    }
    setState(() {});
  }

  Future<void> getGasFeeBtc() async {
    if (widget.coinModel.coin['coinType'] == CoinType.BTC.name) {
      if (gasFeeLevel['loading'] as bool) return;
      gasFeeLevel['loading'] = true;
      setState(() {});
      final gasFeeMM = await tokenViewApi.getGasFeeBtc(
        isTest: widget.coinModel.isTest,
      );
      if (gasFeeMM.error) {
        gasFeeLevel['error'] = true;
        errorMessage = S.current.g_key_t_44;
      } else {
        gasFeeLevel['error'] = false;
        gasFeeLevel['averageValue'] = gasFeeMM.data;
        gasFeeLevel['gasFeeRate'] = gasFeeMM.data;
      }
      gasFeeLevel['loading'] = false;
    } else {
      final averageValue = getCoinGas(widget.coinModel.coin['coinType']);
      gasFeeLevel['averageValue'] = averageValue;
      gasFeeLevel['gasFeeRate'] = averageValue;
    }
    byteFeeTextEditingController.text = gasFeeLevel['averageValue'].toString();
    _buildBtcFeeModel();
    setState(() {});
  }

  void _buildBtcFeeModel() {
    final avgRate = gasFeeLevel['averageValue'] as int;
    final coinType = widget.coinModel.coin['coinType']?.toString() ?? 'BTC';
    final unit =
        (widget.coinModel.coin['unit'] ?? coinType).toString().toUpperCase();
    const estBytes = 250;
    _btcFeeModel = NonEvmFeeModel.forBtcLike(
      averageRateSatPerByte: avgRate,
      calcFeeByRate: (rate) => rate * estBytes,
      chainSymbol: coinType,
      unit: unit,
    );
  }

  Future<void> _openBtcGasSettings() async {
    if (_btcFeeModel == null) return;
    final result = await Navigator.push<NonEvmGasResult>(
      context,
      MaterialPageRoute(
        builder: (_) => NonEvmGasSettingsPage(feeModel: _btcFeeModel!),
      ),
    );
    if (result == null || !mounted) return;
    _btcFeeModel = result.feeModel;
    final rate = result.effectiveFeeRate ??
        _btcFeeModel!.currentOption.feeRate ??
        (gasFeeLevel['averageValue'] as int);
    gasFeeLevel['gasFeeRate'] = rate;
    byteFeeTextEditingController.text = rate.toString();
    setState(() {});
    calculateGasFee();
  }

  String _btcSpeedLabel(NonEvmFeeSpeed speed) => switch (speed) {
    NonEvmFeeSpeed.slow => S.current.g_key_gas_slow,
    NonEvmFeeSpeed.standard => S.current.g_key_gas_standard,
    NonEvmFeeSpeed.fast => S.current.g_key_gas_fast,
  };

  Future<void> getBalance() async {
    try {
      final isOk = await widget.coinModel.getBalance();
      if (isOk == false) {
        load = Load.finish;
        errorMessage = S.current.g_key_t_44;
        ToastUtils.show(errorMessage);
        setState(() {});
        return;
      }
    } catch (e) {
      errorMessage = e.toString();
      ToastUtils.show(errorMessage);
    } finally {
      load = Load.finish;
      setState(() {});
    }
  }

  // -- Abstract methods provided by _BtcSendTxMixin --

  Future<void> calculateGasFee();
  Future<void> maxTag();

  // -- Input validation --

  Future<void> toAddressCheck(String addr) async {
    if (widget.coinModel.isTest) return;
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return;
    }
    final valid = await Trustdart()
        .validateAddress(widget.coinModel.coin['coinType'], addr);

    final isSelfAddress = addr.toUpperCase() == widget.coinModel.address.toUpperCase();
    toErrorMessage = (valid && !isSelfAddress) ? '' : S.current.g_key_t_50;
    setState(() {});
  }

  void _setAmountError(String msg) {
    amountErrorMessage = msg;
    setState(() {});
  }

  void amountCheck({String value = ''}) {
    if (gasFeeLevel['maxValue'] != 0) return;
    if (value.isEmpty) value = valueTextEditingController.text;

    if (value.isEmpty) {
      _setAmountError(S.of(context).g_key_46(0));
      return;
    }
    final checkValue = regular.regularDouble(value);
    final checkInt = regular.regularNums(value);
    if (!checkValue && !checkInt) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }
    if (double.parse(value) <= 0) {
      _setAmountError(S.of(context).g_key_46(0));
      return;
    }
    final transactionTotal = dec.Decimal.parse(value) +
        dec.Decimal.parse(
            toEther(gasFeeLevel['gasFees'].toString(), 8).toString());
    if (transactionTotal.toDouble() > widget.coinModel.balanceDoubleAll()) {
      _setAmountError(S.of(context).g_key_47);
      return;
    }
    if (widget.coinModel.coin['coinType'] == CoinType.BTC.name) {
      if (double.parse(value) < 0.00001) {
        _setAmountError(S.of(context).g_key_135(0.00001));
        return;
      }
    }
    amountErrorMessage = '';
    price = ethToWeiString(value, 8).toInt();
    gasFeeLevel['maxValue'] = 0;
    calculateGasFee();
    setState(() {});
  }

  void byteFeeCheck({String value = ''}) {
    if (value.isEmpty) value = byteFeeTextEditingController.text;
    if (value.isEmpty) {
      _setAmountError(S.of(context).g_key_46(0));
      return;
    }
    if (!isInt(value)) {
      _setAmountError(S.of(context).g_key_t_43);
      return;
    }
    final valueInt = int.parse(value);
    if (valueInt <= 0) {
      _setAmountError(S.of(context).g_key_t_43);
      return;
    }
    gasFeeLevel['gasFeeRate'] = valueInt;
    if (gasFeeLevel['max'] != 0) {
      maxTag();
    } else {
      calculateGasFee();
    }
  }
}
