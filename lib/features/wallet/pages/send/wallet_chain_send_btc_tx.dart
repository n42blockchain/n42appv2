part of 'wallet_chain_send_btc.dart';

/// UTXO selection, transaction building, signing, and navigation helpers
/// for [_WalletChainSendBtcState].
///
/// Depends on [_BtcSendLogicMixin] for all shared state fields.
mixin _BtcSendTxMixin on _BtcSendLogicMixin {
  // Fetch UTXO list (paginated). Pass allUTXO=true to load all pages.
  Future<void> getUTXO({bool allUTXO = false}) async {
    try {
      if (utxoLoad == Load.loading) return;
      if (utxoLastPage) return;
      utxoLoad = Load.loading;
      setState(() {});
      String utxoPath = widget.coinModel.address;
      if (widget.coinModel.coin['coinType'] == CoinType.BCH.name) {
        utxoPath = widget.coinModel.addressType['legacy'];
      }
      final mm = await tokenViewApi.getUTXOBtc(
        widget.coinModel.coin['coinType'],
        utxoPath,
        pageSize: utxoPageSize,
        pageNum: utxoPageNum,
        isTest: widget.coinModel.isTest,
      );
      if (mm.error) {
        errorMessage = mm.data;
        ToastUtils.show(errorMessage);
        utxoLoad = Load.finish;
        setState(() {});
      } else {
        unspents.addAll(mm.data);
        if (unspents.length < (utxoPageSize * utxoPageNum)) {
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
      }
    } catch (e) {
      errorMessage = e.toString();
      ToastUtils.show(errorMessage);
      utxoLoad = Load.finish;
      setState(() {});
    }
  }

  // Calculate gas fee based on current price, UTXOs, and fee rate.
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
      if (widget.coinModel.isTest) {
        if (unspent['hex'] == null) {
          final utxoTx =
              await BtcApi(test: true).getUTXOTxid(unspent['txid']);
          if (utxoTx.error == false) {
            unspent['hex'] =
                utxoTx.data['vout']?[unspent['vout']]?['scriptpubkey'];
          }
        }
        final int amount = unspent['value'];
        input2Price += amount;
        utxos.add({
          'txid': unspent['txid'],
          'vout': unspent['vout'],
          'value': amount.toString(),
          'script': unspent['hex'],
        });
      } else {
        final BigInt amount =
            ethToWeiString(double.parse(unspent['value']).toString(), 8);
        input2Price += amount.toInt();
        utxos.add({
          'txid': unspent['txid'],
          'vout': unspent['output_no'],
          'value': amount.toString(),
          'script': unspent['hex'],
        });
      }

      if (price < input2Price) {
        final byteSize = await getSignByteSize(utxos);
        if (byteSize != 0) {
          final int gasFee = gasFeeLevel['gasFeeRate'];
          gasFeeLevel['gasFees'] = byteSize * gasFee;
          inputValueOK = true;
          break;
        }
      }
    }
    inputUTXO = utxos;
    setState(() {});
    if (!inputValueOK) {
      getUTXO();
    }
  }

  // Sign and broadcast the transaction.
  Future<void> signTx(BtcTransactionRecodeModel trModel) async {
    load = Load.loading;
    setState(() {});
    if (unspents.isEmpty) {
      ToastUtils.show(S.current.g_key_2);
      return;
    }
    trModel = await transatroinBuilder1To1(trModel, unspents);
    if (!mounted) return;
    if (trModel.txHash != '') {
      await AppDatabase().insertBtcTransactionRecord(trModel);
      if (!mounted) return;
      ref.read(tripBridgeProvider).addUndoneTr(trModel, 0);
      await RecentAddressService.save(
        widget.coinModel.coin['coinType'] ?? '',
        toTextEditingController.text.trim(),
      );
      ToastUtils.show(S.current.g_key_nft_41);
      if (toTextFieldEnabel == false) {
        Navigator.pop(context, trModel.txHash);
      } else {
        Navigator.pop(context);
      }
    } else {
      ToastUtils.show(errorMessage);
      load = Load.finish;
      setState(() {});
    }
  }

  // Build and sign a 1-to-1 BTC transaction from the UTXO list.
  Future<BtcTransactionRecodeModel> transatroinBuilder1To1(
    BtcTransactionRecodeModel btcTransactionRecodeModel,
    List<dynamic> unspents,
  ) async {
    try {
      btcTransactionRecodeModel.inputModels = [];

      for (final Map<String, dynamic> unspent in inputUTXO) {
        final im = InputModel(
          txid: unspent['txid'],
          vout: unspent['vout'],
          value: int.parse(unspent['value']),
          script: unspent['script'],
        );
        im.address = [widget.coinModel.address.toString()];
        btcTransactionRecodeModel.inputModels!.add(im);
      }

      final int gasFees = gasFeeLevel['gasFees'] as int;
      btcTransactionRecodeModel.gas = gasFeeLevel['gasFeeRate'];
      btcTransactionRecodeModel.gasPrice = gasFees;
      btcTransactionRecodeModel.addrType = widget.coinModel.addrType;
      btcTransactionRecodeModel.max = gasFeeLevel['maxValue'] != 0;
      btcTransactionRecodeModel.isTest = widget.coinModel.isTest ? 1 : 0;

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

  // Set amount to the maximum spendable value after fees.
  @override
  Future<void> maxTag() async {
    price = widget.coinModel.balance.toInt();
    await getUTXO(allUTXO: true);
    if (errorMessage != '') return;
    final List<Map<String, dynamic>> utxos = [];
    for (final Map<String, dynamic> unspent in unspents) {
      final BigInt amount =
          ethToWeiString(double.parse(unspent['value']).toString(), 8);
      utxos.add({
        'txid': unspent['txid'],
        'vout': unspent['output_no'],
        'value': amount.toString(),
        'script': unspent['hex'],
      });
    }
    inputUTXO = utxos;
    final byteSize = await getSignByteSize(utxos, max: true);
    final int gasFee = gasFeeLevel['gasFeeRate'];
    gasFeeLevel['gasFees'] = byteSize * gasFee;
    price = widget.coinModel.balance.toInt() - (byteSize * gasFee);
    gasFeeLevel['maxValue'] = price;
    valueTextEditingController.text = toEther(price.toString(), 8).toString();
    amountErrorMessage = '';
    setState(() {});
  }

  // Dry-run sign to obtain the serialized byte size for fee estimation.
  Future<int> getSignByteSize(
    List<Map<String, dynamic>> utxos, {
    bool max = false,
  }) async {
    final btcTxMap = {
      'utxo': utxos,
      // Placeholder address — only used for byte-size estimation.
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

  // -- Navigation & keyboard helpers --

  void scanQR() async {
    final String? scanValue = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
    if (!mounted) return;
    if (scanValue != null) {
      toTextEditingController.text = scanValue;
      toAddressCheck(scanValue);
    }
    Navigator.pop(context);
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
