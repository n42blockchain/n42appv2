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
    'averageValue': 5, // server-provided average sat/byte rate
    'loading': false,
    'gasFeeRate': 5, // user-selected sat/byte rate
    'gasFees': 0, // calculated total fee in satoshis
    'signByteSize': 0, // serialized tx byte count
    'maxValue': 0, // satoshi amount when sending max
  };

  // -- Initialization --

  Future<void> initData() async {
    await checkLastTx();
    await getGasFeeBtc();
    await getBalance();
  }

  // Verify whether the last transaction succeeded.
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

  // Fetch the BTC gas fee levels from the server.
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

  /// Build Slow/Standard/Fast fee model using ~250 bytes as a typical BTC tx estimate.
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

  /// Open the non-EVM gas settings page and apply the selection result.
  Future<void> _openBtcGasSettings() async {
    if (_btcFeeModel == null) return;
    final result = await Navigator.push<NonEvmGasResult>(
      context,
      MaterialPageRoute(
        builder: (_) => NonEvmGasSettingsPage(feeModel: _btcFeeModel!),
      ),
    );
    if (result != null && mounted) {
      _btcFeeModel = result.feeModel;
      final rate = result.effectiveFeeRate ??
          _btcFeeModel!.currentOption.feeRate ??
          (gasFeeLevel['averageValue'] as int);
      gasFeeLevel['gasFeeRate'] = rate;
      byteFeeTextEditingController.text = rate.toString();
      setState(() {});
      calculateGasFee();
    }
  }

  /// Speed level label for the fee selector.
  String _btcSpeedLabel(NonEvmFeeSpeed speed) {
    switch (speed) {
      case NonEvmFeeSpeed.slow:
        return S.current.g_key_gas_slow;
      case NonEvmFeeSpeed.standard:
        return S.current.g_key_gas_standard;
      case NonEvmFeeSpeed.fast:
        return S.current.g_key_gas_fast;
    }
  }

  // Refresh wallet balance.
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

  /// Recalculates the gas fee whenever price or fee rate changes.
  Future<void> calculateGasFee();

  /// Sets the send amount to the maximum spendable value after fees.
  Future<void> maxTag();

  // -- Input validation --

  // Validate the recipient address.
  Future<void> toAddressCheck(String addr) async {
    if (widget.coinModel.isTest) return;
    if (addr == '') {
      toErrorMessage = S.current.g_key_41;
    } else {
      final check = await Trustdart()
          .validateAddress(widget.coinModel.coin['coinType'], addr);
      if (check) {
        if (addr.toUpperCase() == widget.coinModel.address.toUpperCase()) {
          toErrorMessage = S.current.g_key_t_50;
        } else {
          toErrorMessage = '';
        }
      } else {
        toErrorMessage = S.current.g_key_t_50;
      }
    }
    setState(() {});
  }

  // Validate the transfer amount field.
  void amountCheck({String value = ''}) {
    if (gasFeeLevel['maxValue'] != 0) return;
    if (value == '') {
      value = valueTextEditingController.text;
    }
    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    final checkValue = regular.regularDouble(value);
    final checkValue1 = regular.regularNums(value);
    final transactionTotal = dec.Decimal.parse(value) +
        dec.Decimal.parse(
            toEther(gasFeeLevel['gasFees'].toString(), 8).toString());
    if (!checkValue && !checkValue1) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    } else if (double.parse(value) <= 0) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    } else if (transactionTotal.toDouble() >
        widget.coinModel.balanceDoubleAll()) {
      amountErrorMessage = S.of(context).g_key_47;
      setState(() {});
      return;
    }
    if (widget.coinModel.coin['coinType'] == CoinType.BTC.name) {
      if (double.parse(value) < 0.00001) {
        amountErrorMessage = S.of(context).g_key_135(0.00001);
        setState(() {});
        return;
      }
    }
    amountErrorMessage = '';
    price = ethToWeiString(value, 8).toInt();
    gasFeeLevel['maxValue'] = 0;
    calculateGasFee();
    setState(() {});
  }

  // Validate the byte fee field.
  void byteFeeCheck({String value = ''}) {
    if (value == '') {
      value = byteFeeTextEditingController.text;
    }
    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    if (!isInt(value)) {
      amountErrorMessage = S.of(context).g_key_t_43;
      setState(() {});
      return;
    }
    final valueInt = int.parse(value);
    if (valueInt <= 0) {
      amountErrorMessage = S.of(context).g_key_t_43;
      setState(() {});
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
