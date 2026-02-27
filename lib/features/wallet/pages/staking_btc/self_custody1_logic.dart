part of 'self_custody1.dart';

mixin _SelfCustody1LogicMixin on ConsumerState<SelfCustody1> {

  // 以下字段由 _SelfCustody1State 声明，mixin 通过 abstract getter 访问
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
  List<Map<String,dynamic>> get inputUTXO;
  set inputUTXO(List<Map<String,dynamic>> value);
  Map<String,dynamic> get gasFeeLevel;

  Future<void> testdata()async{
    int nowTime=(DateTime.now().millisecondsSinceEpoch~/1000)+(0.005*86400).toInt();
    lockTimeInt=nowTime;
    await createP2WSH(nowTime);
    if (!mounted) return;
    String p2wshAddr=p2wshAddress!.toAddress(BitcoinNetwork.testnet);
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletChainSendBtc(widget.coinModel,toAddress: p2wshAddr,toAmount: "0.0012",)));

  }

  Future<void> createWallet()async{
    //9804a241a85bba9480c7e99b23a201f30b48c0d5e990f42e1ed32b19117d99b1
    privateKey = ECPrivate.fromWif("cVbQm3SVhN3sHD2mhbucpyz99mH6WNRcAKhzur3SP5hX4Ca53m15", netVersion: BitcoinNetwork.mainnet.wifNetVer);
    //String mm=ref.read(wapBridgeProvider).walletInfo.mnemonic??"";
    //String walletPK=await Trustdart().getPrivateKey(mm, CoinType.BTC.name, "m/84'/0'/0'/0/0");
    //privateKey=ECPrivate.fromBytes(base64Decode(walletPK));

    //String bpk=base64.encode(privateKey!.toBytes());
    final publicKey = privateKey!.getPublic();
    //String bpub=base64.encode(publicKey.toBytes());
    // 3️⃣ 生成比特币地址（P2PKH）
    address = publicKey.toSegwitAddress().toAddress(BitcoinNetwork.mainnet);
    MessageModel rdata=await getUTXO(address??"");
    if(rdata.error==false){
      unspents=rdata.data;
    }
    //sendTrx();
    //sendTrx1();

  }
  Future<void> createWallet2()async{
    ref.read(wapBridgeProvider).walletInfo.mnemonic;
    String pk=await Trustdart().getPrivateKey(ref.read(wapBridgeProvider).walletInfo.mnemonic??"", CoinType.BTC.name, "m/84'/4'/0'/0/0");
    bytesToHex(base64.decode(pk));
    privateKey=ECPrivate.fromHex(bytesToHex(base64.decode(pk)));
    //String mm=ref.read(wapBridgeProvider).walletInfo.mnemonic??"";
    //String walletPK=await Trustdart().getPrivateKey(mm, CoinType.BTC.name, "m/84'/0'/0'/0/0");
    //privateKey=ECPrivate.fromBytes(base64Decode(walletPK));
    final publicKey = privateKey!.getPublic();
    // 3️⃣ 生成比特币地址（P2PKH）
    address = publicKey.toSegwitAddress().toAddress(BitcoinNetwork.mainnet);
    MessageModel rdata=await getUTXO2(address??"") ?? MessageModel.error();
    if(rdata.error==false){
      unspents=rdata.data;
    }
    //sendTrx();
    //sendTrx1();

  }
  Future<String?> createP2WSH(int lockTime,{String? uPubKey,String? cPubKey})async{
    // 1️⃣ 用户 & Canister 公钥 (HEX 格式)
    if(uPubKey==null){
      //ref.read(wapBridgeProvider).walletInfo.mnemonic;
      //String pk=await Trustdart().getPrivateKey(ref.read(wapBridgeProvider).walletInfo.mnemonic??"", CoinType.BTC.name, "m/84'/4'/0'/0/0");
      if (!mounted) return null;
      final wap = ref.read(wapBridgeProvider);
      String pubKey=await Trustdart().getPublicKey(CoinType.BTC.name, "m/84'/4'/0'/0/0",mnemonic: wap.walletInfo.mnemonic??"",pk: wap.walletInfo.privateKey??"");
      publicKey=bytesToHex(base64Decode(pubKey));
      await Trustdart().getPrivateKey(wap.walletInfo.mnemonic??"",CoinType.BTC.name, "m/84'/4'/0'/0/0",);
      uPubKey = publicKey;
          //privateKey!.getPublic().toHex();
      //03ed20061b9a0417a06ab80d063962c12ed80c9924b1d4da3628705b5b9ac9cecb
      //93fc44de3a7f96887b4159bc9b860ab701afa2e006ba03c720a640b30c5afd81
      //k/xE3jp/loh7QVm8m4YKtwGvouAGugPHIKZAswxa/YE=
      //1743037697
    }
    cPubKey ??= '03ed20061b9a0417a06ab80d063962c12ed80c9924b1d4da3628705b5b9ac9cecb';
    //cPubKey='03ed20061b9a0417a06ab80d063962c12ed80c9924b1d4da3628705b5b9ac9cecb';
    // 2️⃣ 质押时间（秒级时间戳）
    //requestMintVbtc("tb1qw39qrupll6xwmazqplpjgaclexjsd48jms2gwzk2xeuhqen9qxusem966j","0xC2090f16f165e7fc813DdaD0e29D73EB07F0E0A5",130000,"tb1qflj70wxx0s2kpxzpmr9wy9e7860eryag5v246j",1743160567,"03a7460e0d1a959592022042d57e165ead714a788415a898a59a541079a81da2a1");
    //int stakeTime = 1743160567; // 例如: 2023-11-14 12:00:00 UTC
    //03a7460e0d1a959592022042d57e165ead714a788415a898a59a541079a81da2a1
    //02a075b5988699e95802fe94590908de9370588cacc750d6f538d76fe6e9b8d6ad
    // 3️⃣ 生成 lock_script
    Script newScript =
    Script(script: [
      lockTime,
      'OP_CHECKLOCKTIMEVERIFY',
      'OP_DROP',
      2,
      uPubKey,
      cPubKey,
      2,
      'OP_CHECKMULTISIG']);
    if (kDebugMode) debugPrint(newScript.toHex());
    // 5️⃣ 生成 P2WSH 地址（主网示例）
    p2wshAddress =P2wshAddress.fromScript(script: newScript);
    if (kDebugMode) debugPrint(p2wshAddress!.toAddress(BitcoinNetwork.testnet));
    return p2wshAddress!.toAddress(BitcoinNetwork.testnet);
    //ref.read(wapBridgeProvider).walletInfo.mnemonic;
    //String pk=await Trustdart().getPrivateKey(ref.read(wapBridgeProvider).walletInfo.mnemonic??"", CoinType.BTC.name, "m/84'/4'/0'/0/0");
    //Trustdart().testSign_btc('cVbQm3SVhN3sHD2mhbucpyz99mH6WNRcAKhzur3SP5hX4Ca53m15');
    //Trustdart().testSign_btc(pk);
    //CreateBtcTX2().createMessage(privateKey!, "Hello", privateKey!.getPublic());
    //sendTrx1(newScript);
  }
  Future<void> sendTrx1(Script scriptP2wsh)async{

    int sendAmount = ethToWeiString('0.001', 8).toInt();
    int fee = 1000;
    int totalInputAmount = 0;

    List<TxInput> selectedUTXOs = [];
    List<BigInt> txAmount=[];
    List<Script> txInputScript=[];
    for (Map utxo in unspents) {
      MessageModel utxoTx = await getUTXOTxid(utxo['txid']);
      if (utxoTx.error == false) {
        String scriptpk = utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey'] ?? "";
        if (scriptpk != "") {
          txInputScript.add(P2wpkhAddress.fromAddress(address: utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey_address'] ?? "", network: BitcoinNetwork.testnet).toScriptPubKey());
          totalInputAmount += utxo['value'] as int;
          selectedUTXOs.add(TxInput(txId: utxo['txid'], txIndex: utxo['vout']));
          txAmount.add(BigInt.from(utxo['value']));
        }
      }


      if (totalInputAmount >= (sendAmount + fee)) break;
    }

    int changeAmount = totalInputAmount - sendAmount - fee;
    List<TxOutput> txOutputs=[];

    Script scriptPubKey=P2wpkhAddress.fromAddress(address: 'tb1queqpeqalteucdndy4llnmz8l39ugtklypvw6v8', network: BitcoinNetwork.testnet).toScriptPubKey();
    Script scriptPubkey1=p2wshAddress!.toScriptPubKey();
    String p=p2wshAddress!.toAddress(BitcoinNetwork.mainnet);
    if (kDebugMode) debugPrint(p);
    //P2wshAddress.fromAddress(address: p2wshAddress!.toAddress(BitcoinNetwork.testnet), network: BitcoinNetwork.testnet).toScriptPubKey();
    //Script scriptPubkey2=Script(script: []);
    txOutputs.add(TxOutput(amount: BigInt.from(sendAmount), scriptPubKey: scriptPubkey1));
    txOutputs.add(TxOutput(amount: BigInt.from(changeAmount), scriptPubKey: scriptPubKey));

    //txInputScript.add(privateKey!.getPublic().toSegwitAddress().toScriptPubKey());
    //txInputScript.add(privateKey!.getPublic().toSegwitAddress().toScriptPubKey());
    //String txHash=CreateBtcTX2().createSegwit(privateKey!,selectedUTXOs,txAmount,txInputScript,txOutputs);
    String txHash=CreateBtcTX2().createSegwitV2(privateKey!,p2wshAddress!);
    if (kDebugMode) debugPrint(txHash);
  }
  Future<void> sendTrx2(Script scriptP2wsh)async{

    int sendAmount = ethToWeiString('0.0001', 8).toInt();
    int fee = 1000;
    int totalInputAmount = 0;

    List<TxInput> selectedUTXOs = [];
    List<BigInt> txAmount=[];
    List<Script> txInputScript=[];
    for (Map utxo in unspents) {
      selectedUTXOs.add(TxInput(txId: utxo['txid'], txIndex: utxo['vout']));
      /*MessageModel utxoTx = await getUTXOTxid(utxo['txid']);
      if (utxoTx.error == false) {
        String scriptpk = utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey'] ?? "";
        if (scriptpk != "") {
          txInputScript.add(P2wpkhAddress.fromAddress(address: utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey_address'] ?? "", network: BitcoinNetwork.testnet).toScriptPubKey());
          txInputScript.add(Script(script: [scriptpk]));
          totalInputAmount += utxo['value'] as int;
          selectedUTXOs.add(TxInput(txId: utxo['txid'], txIndex: utxo['vout']));
          txAmount.add(BigInt.from(utxo['value']));
        }
      }*/


      if (totalInputAmount >= (sendAmount + fee)) break;
    }

    int changeAmount = totalInputAmount - sendAmount - fee;
    List<TxOutput> txOutputs=[];

    Script scriptPubKey=P2wpkhAddress.fromAddress(address: address??"", network: BitcoinNetwork.testnet).toScriptPubKey();
    Script scriptPubkey1=p2wshAddress!.toScriptPubKey();
    //P2wshAddress.fromAddress(address: p2wshAddress!.toAddress(BitcoinNetwork.testnet), network: BitcoinNetwork.testnet).toScriptPubKey();
    //Script scriptPubkey2=Script(script: []);
    txOutputs.add(TxOutput(amount: BigInt.from(sendAmount), scriptPubKey: scriptPubkey1));
    txOutputs.add(TxOutput(amount: BigInt.from(changeAmount), scriptPubKey: scriptPubKey));

    //txInputScript.add(privateKey!.getPublic().toSegwitAddress().toScriptPubKey());
    //txInputScript.add(privateKey!.getPublic().toSegwitAddress().toScriptPubKey());
    String txHash=CreateBtcTX2().createSegwit(privateKey!,selectedUTXOs,txAmount,txInputScript,txOutputs);
    if (kDebugMode) debugPrint(txHash);
  }
  Future<void> sendTrx()async{
    String hex=await CreateBTCTXV1().createV2(
      //privateKey!.toWif(),
      'cVbQm3SVhN3sHD2mhbucpyz99mH6WNRcAKhzur3SP5hX4Ca53m15',
      //p2wshAddress!.toAddress(BitcoinNetwork.testnet),
      //"bc1qr0fv30e6cygd4h373kvpr7a2sgnp6el0fqfrlf",
      'tb1queqpeqalteucdndy4llnmz8l39ugtklypvw6v8',
      0.001,
      unspents,
      address!,
      Uint8List.fromList(privateKey!.getPublic().toBytes()),
      privateKey!.getPublic().toHex(),
      "",
      //p2wshAddress!.pubKeyHash(),
      Uint8List(2),
      //scriptByte!,
      privateKey!,
    );
    sendTx(hex);
  }

  Future<MessageModel?> getUTXO2(String address)async{
    try{
      MessageModel mm=await TokenViewApi().getUTXOBtc(widget.coinModel.coin['coinType'],address,pageSize: 10,pageNum: 1);
      if(mm.error){
      }else{
        MessageModel mm1=MessageModel();
        mm1.data=mm.data;
        return mm1;
      }
    }catch(e){
      setState(() {});
    }
    return null;
  }

  Future<MessageModel> getUTXOTxid(String txid)async{
    try{
      String uri="https://mempool.space/testnet4/api/tx/$txid";
      var data= await BaseApi.requestEmptyH.get(uri,
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  Future<MessageModel> getUTXO(String address)async{
    try{
      String uri="https://mempool.space/testnet4/api/address/$address/utxo";
      var data= await BaseApi.requestEmptyH.get(uri,
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  Future<MessageModel> sendTx(String hex)async{
    try{
      String uri="https://mempool.space/testnet4/api/tx";
      var data= await BaseApi.requestEmptyH.post(uri,
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"text/plain",
        },
        data: hex
      );
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }

  //计算gas费
  Future<void> calculateGasFee()async{
    if(price==0){
      gasFeeLevel['gasFees']=0;
      setState(() {});
      return;
    }
    if(unspents.isEmpty){
      getUTXO(address??"");
      return;
    }
    List<Map<String,dynamic>> utxos=[];//输出账单
    int input2Price=0;//实际输入金额
    bool inputValueOK=false;
    for(Map<String,dynamic> unspent in unspents){
      BigInt amount=ethToWeiString(unspent['value'].toString(),8) ;
      input2Price+=amount.toInt();
      utxos.add({
        "txid":unspent['txid'],
        "vout":unspent['vout'],//
        "value": amount.toString(),//BigInt.from(amount*100000000).toString(),
        "script": unspent['hex'],//unspent['script]
      });

      //int signByteSize=utxos.length*148+84;
      //int gasFee=gasFeeLevel['gasFeeRate'];
      //int byteSizeFees=signByteSize*gasFee;//计算公式  inputNum*148 + outputNum *34 +10 (+/-)40
      //int outputByteSizeFess=34*gasFee;
      //如果 当前gas费——转账金额 小于 账单金额； 需要加入找零字节数
      //gasFeeLevel['gasFees']=byteSizeFees;
      if(price<input2Price){
        //如果 当前input gas费+转账金额+output gas费 == 账单金额; 退出循环，返回 outputByteSizeFess +inputByteSizeFees
        int byteSize=await getSignByteSize(utxos);
        if(byteSize !=0){
          int gasFee=gasFeeLevel['gasFeeRate'];
          int byteSizeFees=byteSize*gasFee;
          gasFeeLevel['gasFees']=byteSizeFees;
          inputValueOK=true;
          break;
        }
      }
    }
    inputUTXO=utxos;
    setState(() {});
    if(inputValueOK==false){
      getUTXO(address??"");
    }
  }
  //计算 打包 字段数
  Future<int> getSignByteSize(List<Map<String,dynamic>> utxos,{bool max=false})async{
    //await toAddress_check(toTextEditingController.text);
    //if(toErrorMessage !="")return;
    Map<String,dynamic> btcTxMap={
      "utxo":utxos,
      "toAddress":"bc1q4q83qn0r4ndkpldfkypttncfrjxu4zdeeuz40s",//toTextEditingController.text,
      "amount":price,
      "byteFee":gasFeeLevel['gasFeeRate'],
      "changeAddress":widget.coinModel.address,
      "max":max,
    };
    String signByteSize=await transferApi.transactionMaxValue(
      widget.coinModel.coin['blockchainType'],
      widget.coinModel.coin['coinType'],
      btcTxMap,
      getPathWithIndex(widget.coinModel.coin['path'][widget.coinModel.addrType], widget.coinModel.pathIndex),
      privateKey: widget.coinModel.privateKey,
    );
    if(signByteSize == ""){
      return 0;
    }else{
      return int.parse(signByteSize);
    }
  }
}
