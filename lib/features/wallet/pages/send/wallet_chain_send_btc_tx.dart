part of 'wallet_chain_send_btc.dart';

mixin _BtcSendTxMixin on _BtcSendLogicMixin {
  Future<void> getUTXO({bool allUTXO = false}) async {
    if (utxoLoad == Load.loading || utxoLastPage) return;
    utxoLoad = Load.loading;
    setState(() {});
    try {
      final utxoPath = widget.coinModel.coin['coinType'] == CoinType.BCH.name
          ? widget.coinModel.addressType['legacy'] as String
          : widget.coinModel.address;
      final mm = await tokenViewApi.getUTXOBtc(
        widget.coinModel.coin['coinType'],
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

  void _showUtxoError(String msg) {
    errorMessage = msg;
    ToastUtils.show(errorMessage);
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

  @override
  Future<void> calculateGasFee() async {
    if (price == 0) {
      gasFeeLevel['gasFees'] = 0;
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

      if (price < input2Price) {
        final byteSize = await getSignByteSize(utxos);
        if (byteSize != 0) {
          gasFeeLevel['gasFees'] =
              byteSize * (gasFeeLevel['gasFeeRate'] as int);
          inputValueOK = true;
          break;
        }
      }
    }
    inputUTXO = utxos;
    if (!mounted) return;
    setState(() {});
    if (!inputValueOK) getUTXO();
  }

  Future<void> signTx(BtcTransactionRecodeModel trModel) async {
    load = Load.loading;
    setState(() {});
    if (unspents.isEmpty) {
      ToastUtils.show(S.current.g_key_2);
      return;
    }
    trModel = await transatroinBuilder1To1(trModel, unspents);
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
      widget.coinModel.coin['coinType'] ?? '',
      toTextEditingController.text.trim(),
    );
    if (!mounted) return;
    ToastUtils.show(S.current.g_key_nft_41);
    Navigator.pop(context, toTextFieldEnabel ? null : trModel.txHash);
  }

  Future<BtcTransactionRecodeModel> transatroinBuilder1To1(
    BtcTransactionRecodeModel btcTransactionRecodeModel,
    List<dynamic> unspents,
  ) async {
    try {
      btcTransactionRecodeModel.inputModels = [
        for (final Map<String, dynamic> unspent in inputUTXO)
          InputModel(
            txid: unspent['txid'],
            vout: unspent['vout'],
            value: int.parse(unspent['value']),
            script: unspent['script'],
          )..address = [widget.coinModel.address.toString()],
      ];

      btcTransactionRecodeModel
        ..gas = gasFeeLevel['gasFeeRate']
        ..gasPrice = gasFeeLevel['gasFees'] as int
        ..addrType = widget.coinModel.addrType
        ..max = gasFeeLevel['maxValue'] != 0
        ..isTest = widget.coinModel.isTest ? 1 : 0;

      final rmm = await transferApi.transferWallet(
        trModelBtc: btcTransactionRecodeModel,
        pathIndex: widget.coinModel.pathIndex,
        privateKey: widget.coinModel.privateKey,
      );
      if (rmm.error) {
        errorMessage = rmm.data;
      } else {
        btcTransactionRecodeModel.txHash = rmm.data;
      }
      return btcTransactionRecodeModel;
    } catch (e) {
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
    final int gasFee = gasFeeLevel['gasFeeRate'];
    gasFeeLevel['gasFees'] = byteSize * gasFee;
    price = widget.coinModel.balance.toInt() - (byteSize * gasFee);
    gasFeeLevel['maxValue'] = price;
    valueTextEditingController.text = toEther(price.toString(), 8).toString();
    amountErrorMessage = '';
    setState(() {});
  }

  Future<int> getSignByteSize(
    List<Map<String, dynamic>> utxos, {
    bool max = false,
  }) async {
    final btcTxMap = {
      'utxo': utxos,
      'toAddress': 'bc1q4q83qn0r4ndkpldfkypttncfrjxu4zdeeuz40s',
      'amount': price,
      'byteFee': gasFeeLevel['gasFeeRate'],
      'changeAddress': widget.coinModel.address,
      'max': max,
    };
    final signByteSize = await transferApi.transactionMaxValue(
      widget.coinModel.coin['blockchainType'],
      widget.coinModel.coin['coinType'],
      btcTxMap,
      getPathWithIndex(
        widget.coinModel.coin['path'][widget.coinModel.addrType],
        widget.coinModel.pathIndex,
      ),
      privateKey: widget.coinModel.privateKey,
    );
    if (signByteSize == '') return 0;
    return int.parse(signByteSize);
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
