part of 'self_custody1.dart';

mixin _SelfCustody1LogicMixin on ConsumerState<SelfCustody1> {

  String? get address;
  set address(String? value);
  ECPrivate? get privateKey;
  set privateKey(ECPrivate? value);
  P2wshAddress? get p2wshAddress;
  set p2wshAddress(P2wshAddress? value);
  String? get publicKey;
  set publicKey(String? value);
  int? get lockTimeInt;
  set lockTimeInt(int? value);
  TransferApi get transferApi;
  List<dynamic> get unspents;
  set unspents(List<dynamic> value);
  int get price;
  List<Map<String, dynamic>> get inputUTXO;
  set inputUTXO(List<Map<String, dynamic>> value);
  Map<String, dynamic> get gasFeeLevel;

  Future<void> testdata() async {
    final nowTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + (0.005 * 86400).toInt();
    lockTimeInt = nowTime;
    await createP2WSH(nowTime);
    if (!mounted) return;
    final p2wshAddr = p2wshAddress!.toAddress(BitcoinNetwork.testnet);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletChainSendBtc(
          widget.coinModel,
          toAddress: p2wshAddr,
          toAmount: "0.0012",
        ),
      ),
    );
  }

  Future<void> createWallet() async {
    final wap = ref.read(wapBridgeProvider);
    final pk = await Trustdart().getPrivateKey(
      wap.walletInfo.mnemonic ?? "",
      CoinType.BTC.name,
      "m/84'/4'/0'/0/0",
    );
    privateKey = ECPrivate.fromHex(bytesToHex(base64.decode(pk)));
    final pub = privateKey!.getPublic();
    address = pub.toSegwitAddress().toAddress(BitcoinNetwork.mainnet);
    final rdata = await getUTXO(address ?? "");
    if (!rdata.error) {
      unspents = rdata.data;
    }
  }

  Future<void> createWallet2() async {
    final wap = ref.read(wapBridgeProvider);
    final pk = await Trustdart().getPrivateKey(
      wap.walletInfo.mnemonic ?? "",
      CoinType.BTC.name,
      "m/84'/4'/0'/0/0",
    );
    privateKey = ECPrivate.fromHex(bytesToHex(base64.decode(pk)));
    final pub = privateKey!.getPublic();
    address = pub.toSegwitAddress().toAddress(BitcoinNetwork.mainnet);
    final rdata =
        await getUTXO2(address ?? "") ?? MessageModel.error();
    if (!rdata.error) {
      unspents = rdata.data;
    }
  }

  Future<String?> createP2WSH(int lockTime,
      {String? uPubKey, String? cPubKey}) async {
    if (uPubKey == null) {
      if (!mounted) return null;
      final wap = ref.read(wapBridgeProvider);
      final pubKey = await Trustdart().getPublicKey(
        CoinType.BTC.name,
        "m/84'/4'/0'/0/0",
        mnemonic: wap.walletInfo.mnemonic ?? "",
        pk: wap.walletInfo.privateKey ?? "",
      );
      publicKey = bytesToHex(base64Decode(pubKey));
      await Trustdart().getPrivateKey(
        wap.walletInfo.mnemonic ?? "",
        CoinType.BTC.name,
        "m/84'/4'/0'/0/0",
      );
      uPubKey = publicKey;
    }
    cPubKey ??=
        '03ed20061b9a0417a06ab80d063962c12ed80c9924b1d4da3628705b5b9ac9cecb';

    final newScript = Script(script: [
      lockTime,
      'OP_CHECKLOCKTIMEVERIFY',
      'OP_DROP',
      2,
      uPubKey,
      cPubKey,
      2,
      'OP_CHECKMULTISIG',
    ]);
    AppLogger.d('BTCStaking', newScript.toHex());
    p2wshAddress = P2wshAddress.fromScript(script: newScript);
    AppLogger.d('BTCStaking', p2wshAddress!.toAddress(BitcoinNetwork.testnet));
    return p2wshAddress!.toAddress(BitcoinNetwork.testnet);
  }

  /// Historical exploration code from the early BTC self-custody staking
  /// design. **Not wired to any UI path** as of 2026-05 — `sendTrx1` and
  /// `sendTrx2` were left in the file when the flow shifted to `sendTrx()`
  /// (which uses `CreateBTCTXV1.createV2` with a real UTXO set instead of
  /// the hardcoded sample UTXO in `CreateBtcTX2.createSegwitV2`).
  ///
  /// Kept for reference until BTC self-custody staking ships and we can
  /// confirm none of these branches are needed. Do NOT call from production
  /// code — `CreateBtcTX2.createSegwitV2` uses a baked-in testnet UTXO
  /// hash and the multisig signing callback throws `UnimplementedError`
  /// for any pubkey other than the example one.
  @Deprecated('Unused dev exploration code; pending product decision to delete')
  Future<void> sendTrx1(Script scriptP2wsh) async {
    if (privateKey == null || p2wshAddress == null || address == null) return;

    final txHash =
        CreateBtcTX2().createSegwitV2(privateKey!, p2wshAddress!);
    AppLogger.d('BTCStaking', 'tx hash: $txHash');
  }

  @Deprecated('Unused dev exploration code; pending product decision to delete')
  Future<void> sendTrx2(Script scriptP2wsh) async {
    if (privateKey == null || p2wshAddress == null || address == null) return;
    final sendAmount = ethToWeiString('0.0001', 8).toInt();
    final fee = 1000;
    int totalInputAmount = 0;

    final List<TxInput> selectedUTXOs = [];
    final List<BigInt> txAmount = [];
    final List<Script> txInputScript = [];
    for (final utxo in unspents) {
      selectedUTXOs
          .add(TxInput(txId: utxo['txid'], txIndex: utxo['vout']));
      totalInputAmount += (utxo['value'] as int?) ?? 0;
      if (totalInputAmount >= (sendAmount + fee)) break;
    }

    final changeAmount = totalInputAmount - sendAmount - fee;
    final scriptPubKey = P2wpkhAddress.fromAddress(
      address: address!,
      network: BitcoinNetwork.testnet,
    ).toScriptPubKey();
    final scriptPubkey1 = p2wshAddress!.toScriptPubKey();

    final txOutputs = [
      TxOutput(amount: BigInt.from(sendAmount), scriptPubKey: scriptPubkey1),
      TxOutput(amount: BigInt.from(changeAmount), scriptPubKey: scriptPubKey),
    ];

    final txHash = CreateBtcTX2()
        .createSegwit(privateKey!, selectedUTXOs, txAmount, txInputScript, txOutputs);
    AppLogger.d('BTCStaking', 'tx hash: $txHash');
  }

  @Deprecated('Unused dev exploration code; pending product decision to delete')
  Future<void> sendTrx() async {
    if (privateKey == null || address == null) return;
    final wifKey = privateKey!.toWif(network: BitcoinNetwork.testnet);
    final hex = await CreateBTCTXV1().createV2(
      wifKey,
      address!,
      0.001,
      unspents,
      address!,
      Uint8List.fromList(privateKey!.getPublic().toBytes()),
      privateKey!.getPublic().toHex(),
      "",
      Uint8List(2),
      privateKey!,
    );
    sendTx(hex);
  }

  /// Fetch UTXOs from TokenViewApi
  Future<MessageModel?> getUTXO2(String address) async {
    try {
      final mm = await TokenViewApi().getUTXOBtc(
        widget.coinModel.coin['coinType'],
        address,
        pageSize: 10,
        pageNum: 1,
      );
      if (!mm.error) {
        return MessageModel()..data = mm.data;
      }
    } catch (e) {
      AppLogger.w('BTCStaking', 'getUTXO2 error: $e');
      if (mounted) setState(() {});
    }
    return null;
  }

  /// Helper for mempool testnet API calls
  Future<MessageModel> _mempoolGet(String uri) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        uri,
        params: {},
        defaultReturn: false,
        header: {"Content-Type": "application/json"},
      );
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  Future<MessageModel> getUTXOTxid(String txid) =>
      _mempoolGet("https://mempool.space/testnet4/api/tx/$txid");

  Future<MessageModel> getUTXO(String address) =>
      _mempoolGet("https://mempool.space/testnet4/api/address/$address/utxo");

  Future<MessageModel> sendTx(String hex) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        "https://mempool.space/testnet4/api/tx",
        params: {},
        defaultReturn: false,
        header: {"Content-Type": "text/plain"},
        data: hex,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  Future<void> calculateGasFee() async {
    if (price == 0) {
      gasFeeLevel['gasFees'] = 0;
      setState(() {});
      return;
    }
    if (unspents.isEmpty) {
      getUTXO(address ?? "");
      return;
    }

    final List<Map<String, dynamic>> utxos = [];
    int input2Price = 0;
    bool inputValueOK = false;

    for (final unspent in unspents) {
      final amount = ethToWeiString(unspent['value'].toString(), 8);
      input2Price += amount.toInt();
      utxos.add({
        "txid": unspent['txid'],
        "vout": unspent['vout'],
        "value": amount.toString(),
        "script": unspent['hex'],
      });

      if (price < input2Price) {
        final byteSize = await getSignByteSize(utxos);
        if (byteSize != 0) {
          final gasFee = gasFeeLevel['gasFeeRate'] as int;
          gasFeeLevel['gasFees'] = byteSize * gasFee;
          inputValueOK = true;
          break;
        }
      }
    }
    inputUTXO = utxos;
    if (!mounted) return;
    setState(() {});
    if (!inputValueOK) {
      getUTXO(address ?? "");
    }
  }

  Future<int> getSignByteSize(List<Map<String, dynamic>> utxos,
      {bool max = false}) async {
    final btcTxMap = {
      "utxo": utxos,
      "toAddress": "bc1q4q83qn0r4ndkpldfkypttncfrjxu4zdeeuz40s",
      "amount": price,
      "byteFee": gasFeeLevel['gasFeeRate'],
      "changeAddress": widget.coinModel.address,
      "max": max,
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
    return signByteSize.isEmpty ? 0 : int.parse(signByteSize);
  }
}
