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
    if (widget.coinModel.config.isContract) {
      final wap = ref.read(wapBridgeProvider);
      final coinType = widget.coinModel.config.coinType;
      final idx = wap.coinModels.indexWhere((m) {
        if (m.config.coinType != coinType) return false;
        final pk = widget.coinModel.privateKey;
        return pk == null || m.privateKey == pk;
      });
      if (idx >= 0) {
        chainModel = wap.coinModels[idx];
        await fetchCoinBalance(chainModel!, ref.read(wapBridgeProvider));
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
    // 非 EVM 链 gas 固定为 gas 单位（无需 gasPrice rpc 查询）
    totalGasPrice = gas;

    await loadBalance();
  }

  bool get _isEgldNative =>
      widget.coinModel.config.coinType == 'EGLD' &&
      !widget.coinModel.config.isContract;
  EgldFeeQuote? _egldQuote;
  Object? _egldContext;
  int _egldVersion = 0;
  EgldFeeQuote? get _currentEgldQuote =>
      _egldContext == _formContext ? _egldQuote : null;

  void _invalidateEgldQuote() {
    if (mounted && _egldQuote != null && _egldContext != _formContext) {
      setState(() => _egldQuote = null);
    }
  }

  Future<bool> prepareEgldQuote({bool maximum = false}) async {
    _egldQuote = null;
    if (widget.coinModel.loadError) {
      setState(() => errorMessage = S.of(context).g_audit_quote_changed);
      return false;
    }
    final opening = _formContext;
    final version = ++_egldVersion;
    bool current() =>
        mounted && opening == _formContext && version == _egldVersion;
    try {
      final quote = await (widget.egldQuotes ?? EgldQuoteService()).quote(
        isTest: widget.coinModel.isTest,
        decimals: widget.coinModel.coin['decimals'] as int,
        memo: memoCtrl.text.trim(),
      );
      if (!current()) return false;
      final amount = maximum
          ? widget.coinModel.balance - quote.fee
          : transferValue;
      if (amount <= BigInt.zero ||
          amount + quote.fee > widget.coinModel.balance) {
        setState(() => amountError = S.of(context).g_key_47);
        return false;
      }
      if (maximum) {
        transferValue = amount;
        valueCtrl.text = toEther(
          amount.toString(),
          widget.coinModel.coin['decimals'] as int,
        ).toString();
      }
      _egldQuote = quote;
      _egldContext = _formContext;
      totalGasPrice = quote.fee;
      gas = quote.gasLimit;
      gasPrice = BigInt.from(quote.gasPrice);
      amountError = '';
      errorMessage = '';
      setState(() {});
      return true;
    } catch (_) {
      if (current()) {
        setState(() => errorMessage = S.of(context).g_audit_quote_changed);
      }
      return false;
    }
  }

  bool get _isCardanoNative =>
      widget.coinModel.config.coinType == 'ADA' &&
      !widget.coinModel.config.isContract;
  CardanoTransferPlan? _cardanoPlan;
  Object? _cardanoContext;
  int _cardanoVersion = 0;
  CardanoTransferPlan? get _currentCardanoPlan =>
      _cardanoContext == _formContext ? _cardanoPlan : null;

  Future<bool> prepareCardanoQuote(
    String recipient, {
    bool maximum = false,
  }) async {
    final version = ++_cardanoVersion;
    final openingForm = _formContext;
    final contextKey = (
      RecentAddressService.currentUser,
      widget.coinModel.address.toString(),
      widget.coinModel.isTest,
      toCtrl.text,
      valueCtrl.text,
    );
    bool current() =>
        mounted &&
        version == _cardanoVersion &&
        openingForm == _formContext &&
        contextKey ==
            (
              RecentAddressService.currentUser,
              widget.coinModel.address.toString(),
              widget.coinModel.isTest,
              toCtrl.text,
              valueCtrl.text,
            );
    _cardanoPlan = null;
    try {
      final plan = await (widget.cardanoQuotes ?? CardanoQuoteService()).quote(
        sender: contextKey.$2,
        recipient: recipient,
        amount: transferValue,
        isTest: contextKey.$3,
        maximum: maximum,
        isCurrent: current,
      );
      if (!current()) return false;
      if (maximum) {
        transferValue = plan.amount;
        valueCtrl.text = toEther(plan.amount.toString(), 6).toString();
      }
      _cardanoPlan = plan;
      _cardanoContext = _formContext;
      totalGasPrice = plan.fee;
      errorMessage = '';
      amountError = '';
      setState(() {});
      return true;
    } catch (_) {
      if (current()) {
        setState(() => errorMessage = S.of(context).g_audit_quote_changed);
      }
      return false;
    }
  }

  StellarSpendableBalance? _stellarFunds;
  (String, String, bool)? _stellarQuoteContext;
  StellarSpendableBalance? get _currentStellarFunds =>
      _stellarQuoteContext ==
          (
            RecentAddressService.currentUser,
            widget.coinModel.address.toString(),
            widget.coinModel.isTest,
          )
      ? _stellarFunds
      : null;
  int _balanceVersion = 0;
  bool get _isStellarNative =>
      widget.coinModel.config.coinType == 'XLM' &&
      !widget.coinModel.config.isContract;

  Future<void> loadBalance() async {
    final version = ++_balanceVersion;
    final owner = RecentAddressService.currentUser;
    final address = widget.coinModel.address.toString();
    final isTest = widget.coinModel.isTest;
    bool current() =>
        mounted &&
        version == _balanceVersion &&
        RecentAddressService.currentUser == owner &&
        widget.coinModel.address.toString() == address &&
        widget.coinModel.isTest == isTest;
    setState(() {
      load = Load.loading;
      _stellarFunds = null;
      _egldQuote = null;
    });
    var ok = false;
    try {
      ok = await fetchCoinBalance(
        widget.coinModel,
        ref.read(wapBridgeProvider),
        getToken: false,
      );
      if (!current()) return;
      if (_isStellarNative) {
        final api = widget.stellarApi ?? XlmApi();
        final account = await api.getAccount(address, isTest: isTest);
        if (!current()) return;
        if (account.error ||
            account.data is! Map ||
            account.data['account_id'] != address) {
          throw const FormatException('Stellar account quote mismatch');
        }
        final ledger = await api.getLatestLedger(isTest: isTest);
        if (!current()) return;
        if (ledger.error) {
          throw const FormatException('Stellar ledger unavailable');
        }
        final funds = StellarSpendableBalance.parse(account.data, ledger.data);
        _stellarFunds = funds;
        _stellarQuoteContext = (owner, address, isTest);
        totalGasPrice = funds.fee;
        ok = true;
      }
    } catch (_) {
      if (!current()) return;
      ok = false;
    } finally {
      if (mounted && version == _balanceVersion && !current()) {
        setState(() {
          load = Load.finish;
          errorMessage = S.current.g_audit_quote_changed;
        });
      }
    }
    if (!current()) return;
    errorMessage = ok ? '' : S.current.g_key_t_44;
    if (!ok) ToastUtils.show(S.current.g_key_t_44);
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

    final decimals = (widget.coinModel.coin['decimals'] as num).toInt();
    if (!hasNoNonZeroBeyondDecimalPlaces(value, decimals)) {
      amountError = S.of(context).g_key_134;
      setState(() {});
      return;
    }
    final BigInt valueBi = ethToWeiString(
      value,
      widget.coinModel.coin['decimals'] as int,
    );
    if (valueBi <= BigInt.zero) {
      amountError = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }
    if (_isStellarNative && _currentStellarFunds == null) {
      amountError = S.of(context).g_audit_quote_changed;
      setState(() {});
      return;
    }
    if ((_isStellarNative && valueBi > _currentStellarFunds!.spendable) ||
        (!_isStellarNative &&
            !_isCardanoNative &&
            !_isEgldNative &&
            widget.coinModel.coin['isContract'] != true &&
            valueBi + totalGasPrice > widget.coinModel.balance)) {
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

    final coinType = widget.coinModel.config.coinType;
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

  // Bind all asynchronous preparation and confirmation to the opening form.
  Object get _formContext => (
    RecentAddressService.currentUser,
    ref.read(wapBridgeProvider).walletIndex,
    widget.coinModel,
    widget.coinModel.address.toString(),
    widget.coinModel.isTest,
    widget.coinModel.config.coinType,
    toCtrl.text,
    valueCtrl.text,
    memoCtrl.text,
  );

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show('loading');
      return;
    }
    closeKeyboard();
    amountCheck();
    if (amountError.isNotEmpty) return;

    setState(() => load = Load.loading);

    final openingForm = _formContext;
    final String? toAddr = await toAddressCheck(toCtrl.text);
    if (!mounted) return;
    if (openingForm != _formContext) {
      setState(() {
        load = Load.finish;
        errorMessage = S.of(context).g_audit_quote_changed;
      });
      return;
    }
    if (toAddr == null) {
      setState(() => load = Load.finish);
      return;
    }
    if (_isStellarNative && _currentStellarFunds == null) {
      setState(() {
        load = Load.finish;
        amountError = S.of(context).g_audit_quote_changed;
      });
      return;
    }

    if (_isEgldNative && !await prepareEgldQuote()) {
      if (mounted) setState(() => load = Load.finish);
      return;
    }
    if (_isCardanoNative && !await prepareCardanoQuote(toAddr)) {
      if (mounted) setState(() => load = Load.finish);
      return;
    }
    if (!mounted) return;

    final BigInt uBalance = widget.coinModel.config.isContract
        ? (chainModel?.balance ?? BigInt.zero)
        : (_isStellarNative
              ? _currentStellarFunds!.balance
              : (_isCardanoNative
                    ? _currentCardanoPlan!.available
                    : widget.coinModel.balance));

    if (totalGasPrice > uBalance || uBalance == BigInt.zero) {
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
      ..coinMiniName = widget.coinModel.config.coinType
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = widget.coinModel.isTest
          ? (widget.coinModel.config.contractTest)
          : (widget.coinModel.config.contract)
      ..isTest = widget.coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = gasPrice
      ..price = transferValue
      ..message = memoCtrl.text.trim().isEmpty ? null : memoCtrl.text.trim();

    final String unitLabel = chainModel != null
        ? (chainModel!.coin['unit'] as String? ?? '').toUpperCase()
        : (widget.coinModel.coin['unit'] as String? ?? '').toUpperCase();

    if (!mounted) return;
    final bool confirmed =
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => WalletBaseSend(trModel, null, unitLabel),
          ),
        ) ??
        false;

    if (!mounted) return;
    if (openingForm != _formContext) {
      setState(() {
        load = Load.finish;
        errorMessage = S.of(context).g_audit_quote_changed;
      });
      return;
    }
    if (confirmed) {
      await signTx(trModel);
    } else {
      setState(() => load = Load.finish);
    }
  }

  bool _signing = false;
  String? _preparedHash;
  TransationRecordModel? _preparedRecord;

  Future<int> _persistTransaction(TransationRecordModel record) =>
      widget.persistTransaction?.call(record) ??
      AppDatabase().insertTransationRecord(record);

  Future<void> signTx(TransationRecordModel trModel) async {
    if (_signing || _preparedHash != null || !mounted) return;
    _signing = true;
    final recentAddressOwner = trModel.userUuid.isNotEmpty
        ? trModel.userUuid
        : RecentAddressService.currentUser;
    bool completedWithExit = false;
    bool blockedByPending = false;
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
          "m/44'/60'/0'/0/0";
      final path = getPathWithIndex(basePath, widget.coinModel.pathIndex);
      final decimals =
          (widget.coinModel.coin['decimals'] as num?)?.toInt() ?? 18;

      final submit =
          widget.transactionSender ??
          SenderFactory.instance.getSender(coinType).send;
      final result = await submit(
        SendParams(
          coinType: coinType,
          fromAddress: trModel.from1,
          toAddress: trModel.to1,
          amount: toEther(trModel.price.toString(), decimals).toDouble(),
          decimals: decimals,
          path: path,
          sendMax: false,
          expectedFeeBaseUnits:
              (_isStellarNative || _isCardanoNative || _isEgldNative)
              ? trModel.gasPrice
              : null,
          isTest: widget.coinModel.isTest,
          contractAddress: trModel.contract,
          tokenDecimals: 0,
          memo: trModel.message,
          privateKey: widget.coinModel.privateKey,
          chainConfig: widget.coinModel.coin,
          decimalAmountOverride: toEther(
            trModel.price.toString(),
            decimals,
          ).toString(),
          onBroadcastStarting: {'ADA', 'XLM', 'EGLD', 'NEAR'}.contains(coinType)
              ? (hash) async {
                  final original = _preparedRecord;
                  if (!mounted ||
                      RecentAddressService.currentUser != recentAddressOwner ||
                      original == null ||
                      hash != _preparedHash) {
                    throw StateError('Transaction preparation changed');
                  }
                  final marked =
                      await (widget.markTransactionDispatch?.call(original) ??
                          AppDatabase().markMemoTransactionDispatch(original));
                  if (!marked ||
                      !mounted ||
                      RecentAddressService.currentUser != recentAddressOwner) {
                    throw StateError('Transaction dispatch was not recorded');
                  }
                }
              : null,
          beforeBroadcast: {'ADA', 'XLM', 'EGLD', 'NEAR'}.contains(coinType)
              ? (hash) async {
                  if (!mounted ||
                      RecentAddressService.currentUser != recentAddressOwner) {
                    throw StateError('Wallet context changed');
                  }
                  trModel.txHash = hash;
                  try {
                    trModel.trId =
                        await (widget.persistTransaction?.call(trModel) ??
                            AppDatabase().reserveMemoTransaction(
                              trModel,
                              trackDispatch: true,
                            ));
                  } on PendingMemoTransactionException {
                    blockedByPending = true;
                    rethrow;
                  }
                  if (trModel.trId <= 0) {
                    throw StateError('Transaction was not saved');
                  }
                  _preparedHash = hash;
                  _preparedRecord = TransationRecordModel.fromMap(
                    trModel.toMap(),
                  );
                  if (!mounted ||
                      RecentAddressService.currentUser != recentAddressOwner) {
                    throw StateError('Wallet context changed');
                  }
                }
              : null,
        ),
      );

      if (blockedByPending) {
        if (mounted) ToastUtils.show(S.current.g_key_bridge_tx_pending);
        return;
      }
      if (result.definitelyNotSubmitted) {
        final original = _preparedRecord;
        if (original != null && result.txHash == _preparedHash) {
          final released =
              await (widget.releaseUnsubmittedTransaction?.call(original) ??
                  AppDatabase().releaseUnsubmittedMemoTransaction(original));
          if (released) {
            _preparedRecord = null;
            _preparedHash = null;
            trModel.trId = 0;
            trModel.txHash = '';
          }
        }
        if (mounted) {
          ToastUtils.show(result.error ?? S.current.g_key_bridge_tx_pending);
        }
        return;
      }
      if (result.success ||
          (_preparedHash != null && result.txHash == _preparedHash)) {
        // A returned hash cannot replace the durable original submission ID.
        if (_preparedHash != null && result.txHash != _preparedHash) {
          throw StateError('Transaction result does not match saved hash');
        }
        trModel.txHash = _preparedHash ?? result.txHash ?? '';
        if (trModel.trId == 0) {
          trModel.trId = await _persistTransaction(trModel);
        }
        if (!mounted ||
            RecentAddressService.currentUser != recentAddressOwner) {
          return;
        }
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(
          coinType,
          trModel.to1,
          userUuid: recentAddressOwner,
        );
        if (!mounted) return;
        ToastUtils.show(
          result.success
              ? S.current.g_key_nft_41
              : S.current.g_key_bridge_tx_pending,
        );
        completedWithExit = true;
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        errorMessage = result.error ?? '';
        final friendly = _isFriendlyError(errorMessage)
            ? S.current.g_key_chain_transfer_not_supported
            : errorMessage;
        ToastUtils.show(friendly);
      }
    } catch (e) {
      errorMessage = blockedByPending
          ? S.current.g_key_bridge_tx_pending
          : e.toString();
      if (mounted) ToastUtils.show(errorMessage);
    } finally {
      _signing = false;
      load = Load.finish;
      if (mounted && !completedWithExit) setState(() {});
    }
  }

  /// 判断是否为"链未实现"类型的错误（区别于网络错误）
  bool _isFriendlyError(String msg) {
    const keywords = ['not supported', 'not implemented', 'unsupported'];
    final lower = msg.toLowerCase();
    return keywords.any(lower.contains);
  }

  Future<void> maxTag() async {
    if (_isEgldNative) {
      if (load == Load.loading) return;
      setState(() => load = Load.loading);
      try {
        await prepareEgldQuote(maximum: true);
      } finally {
        if (mounted) setState(() => load = Load.finish);
      }
      return;
    }
    if (_isCardanoNative) {
      if (load == Load.loading) return;
      setState(() => load = Load.loading);
      try {
        final openingForm = _formContext;
        final recipient = await toAddressCheck(toCtrl.text);
        if (!mounted) return;
        if (openingForm != _formContext) {
          setState(() => errorMessage = S.of(context).g_audit_quote_changed);
          return;
        }
        if (recipient != null) {
          await prepareCardanoQuote(recipient, maximum: true);
        }
      } finally {
        if (mounted) setState(() => load = Load.finish);
      }
      return;
    }
    if (_isStellarNative) {
      final funds = _currentStellarFunds;
      if (funds == null || funds.spendable <= BigInt.zero) {
        amountError = funds == null
            ? S.of(context).g_audit_quote_changed
            : S.of(context).g_key_47;
        setState(() {});
        return;
      }
      transferValue = funds.spendable;
      valueCtrl.text = toEther(transferValue.toString(), 7).toString();
    } else if (widget.coinModel.config.isContract) {
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
    FocusScope.of(context).unfocus();
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
