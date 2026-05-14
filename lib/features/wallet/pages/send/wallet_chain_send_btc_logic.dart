part of 'wallet_chain_send_btc.dart';

/// Fee state for a BTC-family send operation.
class _BtcFee {
  bool loading;
  bool error;
  int averageRate;  // API-fetched sat/byte
  int selectedRate; // user-selected sat/byte
  int totalFees;    // computed fee in satoshis
  int maxPrice;     // satoshis in "send max" mode; 0 = not max

  _BtcFee()
      : loading = false,
        error = false,
        averageRate = 5,
        selectedRate = 5,
        totalFees = 0,
        maxPrice = 0;
}

/// Business logic mixin for [_WalletChainSendBtcState].
mixin _BtcSendLogicMixin on ConsumerState<WalletChainSendBtc> {
  Regular? _logicRegular;
  Regular get regular => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

  TokenViewApi? _logicTokenViewApi;
  TokenViewApi get tokenViewApi => _logicTokenViewApi ??= TokenViewApi();

  final TextEditingController toTextEditingController = TextEditingController();
  final TextEditingController valueTextEditingController = TextEditingController();
  final TextEditingController byteFeeTextEditingController = TextEditingController();
  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();
  final FocusNode byteFeeNode = FocusNode();

  String toErrorMessage = '';
  String amountErrorMessage = '';
  String errorMessage = '';

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
  final _BtcFee _fee = _BtcFee();

  // Debounce for amount input — avoids triggering UTXO/native calls per keystroke.
  Timer? _amountDebounce;

  // Perf#4: fetch fee rate and balance in parallel.
  Future<void> initData() async {
    await Future.wait([getGasFeeBtc(), getBalance()]);
  }

  Future<void> getGasFeeBtc() async {
    if (widget.coinModel.coin['coinType'] == CoinType.BTC.name) {
      if (_fee.loading) return;
      _fee.loading = true;
      setState(() {});
      final gasFeeMM = await tokenViewApi.getGasFeeBtc(
        isTest: widget.coinModel.isTest,
      );
      if (!mounted) return;
      if (gasFeeMM.error) {
        _fee.error = true;
        errorMessage = S.current.g_key_t_44;
      } else {
        _fee.error = false;
        _fee.averageRate = gasFeeMM.data as int;
        _fee.selectedRate = gasFeeMM.data as int;
      }
      _fee.loading = false;
    } else {
      final averageValue = getCoinGas(widget.coinModel.coin['coinType']);
      _fee.averageRate = averageValue;
      _fee.selectedRate = averageValue;
    }
    byteFeeTextEditingController.text = _fee.averageRate.toString();
    _buildBtcFeeModel();
    setState(() {});
  }

  void _buildBtcFeeModel() {
    final coinType = widget.coinModel.coin['coinType']?.toString() ?? 'BTC';
    final unit = (widget.coinModel.coin['unit'] ?? coinType).toString().toUpperCase();
    const estBytes = 250;
    _btcFeeModel = NonEvmFeeModel.forBtcLike(
      averageRateSatPerByte: _fee.averageRate,
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
    final rate =
        result.effectiveFeeRate ??
        _btcFeeModel!.currentOption.feeRate ??
        _fee.averageRate;
    _fee.selectedRate = rate;
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
      final isOk = await fetchCoinBalance(widget.coinModel, ref.read(wapBridgeProvider));
      if (!mounted) return;
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
      if (mounted) setState(() {});
    }
  }

  Future<void> calculateGasFee();
  Future<void> maxTag();

  Future<void> toAddressCheck(String addr) async {
    if (widget.coinModel.isTest) return;
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return;
    }
    final valid = await Trustdart().validateAddress(
      widget.coinModel.coin['coinType'],
      addr,
    );
    if (!mounted) return;

    final isSelfAddress =
        addr.toUpperCase() == widget.coinModel.address.toUpperCase();
    toErrorMessage = (valid && !isSelfAddress) ? '' : S.current.g_key_t_50;
    setState(() {});
  }

  void _setAmountError(String msg) {
    amountErrorMessage = msg;
    setState(() {});
  }

  // Quality#9: fee used here is the last computed value — approximate but
  // gives immediate feedback. calculateGasFee() corrects it afterward.
  void amountCheck({String value = ''}) {
    if (_fee.maxPrice != 0) return;
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
    // Quick balance check using last-known fee as estimate.
    final transactionTotal =
        dec.Decimal.parse(value) +
        dec.Decimal.parse(toEther(_fee.totalFees.toString(), 8).toString());
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
    _fee.maxPrice = 0;
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
    _fee.selectedRate = valueInt;
    if (_fee.maxPrice != 0) {
      maxTag();
    } else {
      calculateGasFee();
    }
  }
}
