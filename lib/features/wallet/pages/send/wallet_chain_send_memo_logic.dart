part of 'wallet_chain_send_memo.dart';

/// Business logic mixin for [_WalletChainSendMemoState].
///
/// Declares all shared state fields and contains initialization, balance
/// loading, input validation, and transaction submission.
mixin _MemoSendLogicMixin on ConsumerState<WalletChainSendMemo> {
  CoinModel? chainModel; // 代币场景下的主链 model（提供 gas 余额）

  Regular? _logicRegular;
  Regular get _reg => _logicRegular ??= Regular();

  DataUtils? _logicDataUtils;
  DataUtils get dataUtils => _logicDataUtils ??= DataUtils();

  final TextEditingController toCtrl = TextEditingController();
  final TextEditingController valueCtrl = TextEditingController();
  final TextEditingController memoCtrl = TextEditingController();

  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();
  final FocusNode memoNode = FocusNode();

  String toError = '';
  String amountError = '';
  String errorMessage = '';

  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gas = BigInt.zero;
  BigInt transferValue = BigInt.zero;

  Load load = Load.loading;

  Future<void> initData() async {
    if (widget.coinModel.coin['isContract'] == true) {
      final wap = ref.read(wapBridgeProvider);
      final coinType = widget.coinModel.coin['coinType'];
      final idx = wap.coinModels.indexWhere((m) {
        if (m.coin['coinType'] != coinType) return false;
        final pk = widget.coinModel.privateKey;
        return pk == null || m.privateKey == pk;
      });
      if (idx >= 0) {
        chainModel = wap.coinModels[idx];
        await chainModel!.getBalance();
        if (!mounted) return;
        setState(() {});
      }
    }

    gas = BigInt.from(
      getCoinGas(
        widget.coinModel.coin['coinType'] as String? ?? '',
        contract: widget.coinModel.coin['isContract'] == true,
      ),
    );
    // 非 EVM 链 gas 固定为 gas 单位（无需 gasPrice rpc 查询）
    totalGasPrice = gas;

    await loadBalance();
  }

  Future<void> loadBalance() async {
    setState(() => load = Load.loading);
    final ok = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (!ok) {
      errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
    }
    setState(() => load = Load.finish);
  }

  void amountCheck({String value = ''}) {
    if (value.isEmpty) value = valueCtrl.text;
    final int minValue = widget.coinModel.coin['decimals'] == 0 ? 1 : 0;

    final String error = _validateAmount(value, minValue);
    if (error.isNotEmpty) {
      amountError = error;
      setState(() {});
      return;
    }

    final BigInt valueBi = ethToWeiString(
      value,
      widget.coinModel.coin['decimals'] as int,
    );
    if (widget.coinModel.coin['isContract'] != true &&
        valueBi + totalGasPrice > widget.coinModel.balance) {
      amountError = S.of(context).g_key_47;
      setState(() {});
      return;
    }
    transferValue = valueBi;
    amountError = '';
    setState(() {});
  }

  String _validateAmount(String value, int minValue) {
    if (value.isEmpty) return S.of(context).g_key_46(minValue);
    final bool isNum = _reg.regularNums(value) || _reg.regularDouble(value);
    if (!isNum) return S.of(context).g_key_134;
    final double dv = double.tryParse(value) ?? 0;
    if (dv <= 0 || dv < minValue) return S.of(context).g_key_46(minValue);
    return '';
  }

  Future<String?> toAddressCheck(String addr) async {
    addr = addr.trim();
    if (addr.isEmpty) {
      _setToError(S.current.g_key_41);
      return null;
    }
    // 剥离 "chainName:address" 格式
    final parts = addr.split(':');
    if (parts.length == 2) addr = parts[1];

    final coinType = widget.coinModel.coin['coinType'] as String? ?? '';
    final bool ok = await Trustdart().validateAddress(coinType, addr);
    if (!mounted) return null;

    final bool isSelfSend =
        addr.toUpperCase() == widget.coinModel.address.toString().toUpperCase();
    if (!ok || isSelfSend) {
      _setToError(S.current.g_key_t_50);
      return null;
    }
    _setToError('');
    return addr;
  }

  void _setToError(String msg) {
    toError = msg;
    setState(() {});
  }

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show('loading');
      return;
    }
    closeKeyboard();
    amountCheck();
    if (amountError.isNotEmpty) return;

    setState(() => load = Load.loading);

    final String? toAddr = await toAddressCheck(toCtrl.text);
    if (toAddr == null) {
      setState(() => load = Load.finish);
      return;
    }

    final BigInt uBalance = widget.coinModel.coin['isContract'] == true
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;

    if (totalGasPrice > uBalance || widget.coinModel.balance == BigInt.zero) {
      ToastUtils.show(S.current.g_key_47);
      setState(() => load = Load.finish);
      return;
    }

    final trModel = TransationRecordModel()
      ..address = widget.coinModel.address.toString()
      ..from1 = widget.coinModel.address.toString()
      ..to1 = toAddr
      ..addrType = widget.coinModel.addrType
      ..coin = widget.coinModel.coin
      ..coinMiniName = widget.coinModel.coin['coinType'] as String? ?? ''
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = widget.coinModel.isTest
          ? (widget.coinModel.coin['contract_test'] as String? ?? '')
          : (widget.coinModel.coin['contract'] as String? ?? '')
      ..isTest = widget.coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = gasPrice
      ..price = transferValue
      ..message = memoCtrl.text.trim().isEmpty ? null : memoCtrl.text.trim();

    final String unitLabel = chainModel != null
        ? (chainModel!.coin['unit'] as String? ?? '').toUpperCase()
        : (widget.coinModel.coin['unit'] as String? ?? '').toUpperCase();

    final bool confirmed =
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => WalletBaseSend(trModel, null, unitLabel),
          ),
        ) ??
        false;

    if (!mounted) return;
    if (confirmed) {
      await signTx(trModel);
    } else {
      setState(() => load = Load.finish);
    }
  }

  Future<void> signTx(TransationRecordModel trModel) async {
    try {
      final MessageModel mm = await TransferApi().transferWallet(
        trModel: trModel,
        privateKey: widget.coinModel.privateKey,
        pathIndex: widget.coinModel.pathIndex,
      );
      if (!mounted) return;
      if (mm.error) {
        errorMessage = mm.data?.toString() ?? '';
        ToastUtils.show(errorMessage);
      } else {
        trModel.txHash = mm.data?.toString() ?? '';
        final db = AppDatabase();
        trModel.trId = await db.insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(
          widget.coinModel.coin['coinType'] as String? ?? '',
          toCtrl.text.trim(),
        );
        ToastUtils.show(S.current.g_key_nft_41);
        Navigator.pop(context);
      }
    } catch (e) {
      errorMessage = e.toString();
      final friendly = _isFriendlyError(e.toString())
          ? S.current.g_key_chain_transfer_not_supported
          : e.toString();
      ToastUtils.show(friendly);
    } finally {
      load = Load.finish;
      if (mounted) setState(() {});
    }
  }

  /// 判断是否为"链未实现"类型的错误（区别于网络错误）
  bool _isFriendlyError(String msg) {
    const keywords = ['not supported', 'not implemented', 'unsupported'];
    final lower = msg.toLowerCase();
    return keywords.any(lower.contains);
  }

  void maxTag() {
    if (widget.coinModel.coin['isContract'] == true) {
      valueCtrl.text = widget.coinModel.balanceStringAll();
      transferValue = widget.coinModel.balance;
    } else {
      transferValue = maxTransferableAmount(
        balance: widget.coinModel.balance,
        fee: totalGasPrice,
      );
      valueCtrl.text = toEther(
        transferValue.toString(),
        widget.coinModel.coin['decimals'] as int,
      ).toString();
    }
    amountError = '';
    setState(() {});
  }

  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void scanQR() =>
      performScanQR(context, controller: toCtrl, onAddress: toAddressCheck);

  void pasteAddress() => performPasteAddress(
    context,
    controller: toCtrl,
    onAddress: toAddressCheck,
  );

  void showAddressPicker() {
    showAddressPickerSheet(
      context,
      coinModel: widget.coinModel,
      onAddressSelected: (addr) {
        toCtrl.text = addr;
        toAddressCheck(addr);
      },
    );
  }
}
