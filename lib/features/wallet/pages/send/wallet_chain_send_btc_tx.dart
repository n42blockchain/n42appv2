part of 'wallet_chain_send_btc.dart';

// Dummy address used only for signing-byte-size estimation; never receives funds.
const _kBtcFeeEstimationAddress = 'bc1q4q83qn0r4ndkpldfkypttncfrjxu4zdeeuz40s';

mixin _BtcSendTxMixin on _BtcSendLogicMixin {
  Future<void> getUTXO({bool allUTXO = false}) async {
    if (utxoLoad == Load.loading || utxoLastPage) return;
    utxoLoad = Load.loading;
    setState(() {});
    try {
      final utxoPath = widget.coinModel.config.coinType == CoinType.BCH.name
          ? widget.coinModel.addressType['legacy'] as String
          : widget.coinModel.address;
      final mm = await tokenViewApi.getUTXOBtc(
        widget.coinModel.config.coinType,
        utxoPath,
        pageSize: utxoPageSize,
        pageNum: utxoPageNum,
        isTest: widget.coinModel.isTest,
      );
      if (mm.error) {
        _showUtxoError(mm.data);
        return;
      }
      unspents.addAll(mm.data);
      if (unspents.length < utxoPageSize * utxoPageNum) {
        utxoLastPage = true;
      } else {
        utxoPageNum++;
      }
      utxoLoad = Load.finish;
      setState(() {});
      if (allUTXO) {
        getUTXO(allUTXO: allUTXO);
      } else {
        calculateGasFee();
      }
    } catch (e) {
      _showUtxoError(e.toString());
    }
  }

  // Quality#8: only show inline error, not duplicate toast.
  void _showUtxoError(String msg) {
    errorMessage = msg;
    utxoLoad = Load.finish;
    setState(() {});
  }

  Map<String, dynamic> _buildUtxoEntry(Map<String, dynamic> unspent) {
    if (widget.coinModel.isTest) {
      return {
        'txid': unspent['txid'],
        'vout': unspent['vout'],
        'value': (unspent['value'] as int).toString(),
        'script': unspent['hex'],
      };
    }
    final BigInt amount = ethToWeiString(
      double.parse(unspent['value']).toString(),
      8,
    );
    return {
      'txid': unspent['txid'],
      'vout': unspent['output_no'],
      'value': amount.toString(),
      'script': unspent['hex'],
    };
  }

  int _utxoAmount(Map<String, dynamic> unspent) {
    if (widget.coinModel.isTest) return unspent['value'] as int;
    return ethToWeiString(double.parse(unspent['value']).toString(), 8).toInt();
  }

  // Bug#1 + Perf#3: use the standard byte-size formula to select UTXOs in the
  // loop (no native call per iteration), then call getSignByteSize() exactly
  // once at the end for accurate fee display.
  // Formula: (n_inputs * 148 + 78) * sat_per_byte  (P2PKH conservative estimate;
  // overestimates SegWit slightly, which is safe).
  @override
  Future<void> calculateGasFee() async {
    if (price == 0) {
      _fee.totalFees = 0;
      setState(() {});
      return;
    }
    if (unspents.isEmpty) {
      getUTXO();
      return;
    }

    final List<Map<String, dynamic>> utxos = [];
    int input2Price = 0;
    bool inputValueOK = false;

    for (final Map<String, dynamic> unspent in unspents) {
      if (widget.coinModel.isTest && unspent['hex'] == null) {
        final utxoTx = await BtcApi(test: true).getUTXOTxid(unspent['txid']);
        if (utxoTx.error == false) {
          unspent['hex'] =
              utxoTx.data['vout']?[unspent['vout']]?['scriptpubkey'];
        }
      }
      input2Price += _utxoAmount(unspent);
      utxos.add(_buildUtxoEntry(unspent));

      // Formula-based check: price + estimated_fee <= available inputs.
      final estimatedFee = (utxos.length * 148 + 78) * _fee.selectedRate;
      if (price + estimatedFee <= input2Price) {
        inputValueOK = true;
        break;
      }
    }

    inputUTXO = utxos;

    if (!inputValueOK) {
      if (!mounted) return;
      setState(() {});
      getUTXO();
      return;
    }

    // Single native call for accurate fee after UTXO set is finalised.
    final byteSize = await getSignByteSize(utxos);
    if (!mounted) return;
    if (byteSize != 0) {
      _fee.totalFees = byteSize * _fee.selectedRate;
      // If accurate fee exceeds available inputs, we need one more UTXO.
      if (price + _fee.totalFees > input2Price) {
        getUTXO();
        return;
      }
    }
    setState(() {});
  }

  // Bug#2: reset load on early return so the send button is not stuck loading.
  Future<void> signTx(BtcTransactionRecodeModel trModel) async {
    load = Load.loading;
    setState(() {});
    if (unspents.isEmpty) {
      load = Load.finish;
      setState(() {});
      ToastUtils.show(S.current.g_key_2);
      return;
    }
    trModel = await transactionBuilder1To1(trModel, unspents);
    if (!mounted) return;
    if (trModel.txHash == '') {
      ToastUtils.show(errorMessage);
      load = Load.finish;
      setState(() {});
      return;
    }
    await AppDatabase().insertBtcTransactionRecord(trModel);
    if (!mounted) return;
    ref.read(tripBridgeProvider).addUndoneTr(trModel, 0);
    await RecentAddressService.save(
      widget.coinModel.config.coinType,
      toTextEditingController.text.trim(),
    );
    if (!mounted) return;
    ToastUtils.show(S.current.g_key_nft_41);
    Navigator.pop(context, toTextFieldEnabel ? null : trModel.txHash);
  }

  // Quality#7: renamed from transatroinBuilder1To1.
  Future<BtcTransactionRecodeModel> transactionBuilder1To1(
    BtcTransactionRecodeModel btcTransactionRecodeModel,
    List<dynamic> unspents,
  ) async {
    try {
      final coinType = widget.coinModel.config.coinType as String? ?? 'BTC';
      final addrType = widget.coinModel.addrType;
      final pathKey = widget.coinModel.coin['path'] as Map<String, dynamic>?;
      final basePath = pathKey?[addrType]?.toString() ?? "m/44'/0'/0'/0/0";
      final path = getPathWithIndex(basePath, widget.coinModel.pathIndex);
      final isMaxSend = _fee.maxPrice != 0;
      final amount = toEther(
        btcTransactionRecodeModel.price.toString(),
        8,
      ).toDouble();

      final result = await BtcSender().send(
        SendParams(
          coinType: coinType,
          fromAddress: widget.coinModel.address.toString(),
          toAddress: btcTransactionRecodeModel.to1,
          amount: amount,
          decimals: 8,
          path: path,
          sendMax: isMaxSend,
          isTest: widget.coinModel.isTest,
          contractAddress: '',
          tokenDecimals: 0,
          privateKey: widget.coinModel.privateKey,
          chainConfig: widget.coinModel.coin,
          btcFeeRate: _fee.selectedRate,
          prebuiltUtxos: inputUTXO.isNotEmpty ? List.from(inputUTXO) : null,
        ),
      );

      if (result.success) {
        btcTransactionRecodeModel.txHash = result.txHash ?? '';
      } else {
        errorMessage = result.error ?? '';
      }
      btcTransactionRecodeModel
        ..gas = _fee.selectedRate
        ..gasPrice = _fee.totalFees
        ..addrType = addrType
        ..max = isMaxSend
        ..isTest = widget.coinModel.isTest ? 1 : 0;
      return btcTransactionRecodeModel;
    } catch (e) {
      errorMessage = e.toString();
      return btcTransactionRecodeModel;
    }
  }

  @override
  Future<void> maxTag() async {
    price = widget.coinModel.balance.toInt();
    await getUTXO(allUTXO: true);
    if (errorMessage != '') return;
    final utxos = [
      for (final Map<String, dynamic> unspent in unspents)
        _buildUtxoEntry(unspent),
    ];
    inputUTXO = utxos;
    final byteSize = await getSignByteSize(utxos, max: true);
    if (!mounted) return;
    _fee.totalFees = byteSize * _fee.selectedRate;
    price = widget.coinModel.balance.toInt() - _fee.totalFees;
    _fee.maxPrice = price;
    valueTextEditingController.text = toEther(price.toString(), 8).toString();
    amountErrorMessage = '';
    setState(() {});
  }

  Future<int> getSignByteSize(
    List<Map<String, dynamic>> utxos, {
    bool max = false,
  }) async {
    final coinType = widget.coinModel.config.coinType
        .toUpperCase();
    final path = getPathWithIndex(
      widget.coinModel.config.pathForAddrType(widget.coinModel.addrType)!,
      widget.coinModel.pathIndex,
    );
    final btcTxMap = <String, dynamic>{
      'utxo': utxos,
      'toAddress': _kBtcFeeEstimationAddress,
      'amount': price,
      'byteFee': _fee.selectedRate,
      'changeAddress': widget.coinModel.address,
      'max': max,
    };
    final String result;
    if (widget.coinModel.privateKey?.isNotEmpty ?? false) {
      result = await Trustdart().signTransactionMaxValue(
        coinType,
        '',
        btcTxMap,
        pk: widget.coinModel.privateKey!,
      );
    } else {
      result = await Trustdart().signTransactionMaxValue(
        coinType,
        path,
        btcTxMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    }
    if (result.isEmpty) return 0;
    return int.parse(result);
  }

  Future<void> scanQR() async {
    final String? scanValue = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
    if (!mounted) return;
    if (scanValue != null) {
      toTextEditingController.text = scanValue;
      toAddressCheck(scanValue);
    }
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
