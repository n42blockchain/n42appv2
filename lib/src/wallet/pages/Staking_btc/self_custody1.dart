import 'dart:convert';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/utils/create_btc_tx_1.dart';
import 'package:n42appv2/src/wallet/utils/create_btc_tx_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
class SelfCustody1 extends StatefulWidget {
  final CoinModel coinModel;
  const SelfCustody1(this.coinModel,{super.key});

  @override
  State<SelfCustody1> createState() => _SelfCustody1State();
}
//01000000000103b4e1d30cf774b846bc6147f99f8ef11a6c300c61387a040dc68356e04c127bfb0000000000ffffffff607b3facebc1aedfb6c0a1448a37a1f727851e49c3135adaf8f81edc0e3feaa30000000000ffffffffc28c3d24f622f79dce51518a5a09cc7748e4baef93778e2327f5bd73b751a9d20500000000ffffffff02a086010000000000160014e6401c83bf5e7986cda4afff3d88ff897885dbe49e6a373000000000160014e6401c83bf5e7986cda4afff3d88ff897885dbe40140e69d8fec799297dd42ad45491d36e05e64c9dfaa6c8544b666b81b100aaf44242be38b37c6bfd096dc7dd2490bdac08a76db5e313f4619f460db8a5db764f9ea00000000
//02000000000103b4e1d30cf774b846bc6147f99f8ef11a6c300c61387a040dc68356e04c127bfb0000000000ffffffff607b3facebc1aedfb6c0a1448a37a1f727851e49c3135adaf8f81edc0e3feaa30000000000ffffffffc28c3d24f622f79dce51518a5a09cc7748e4baef93778e2327f5bd73b751a9d20500000000ffffffff02a086010000000000160014e6401c83bf5e7986cda4afff3d88ff897885dbe49e6a373000000000160014e6401c83bf5e7986cda4afff3d88ff897885dbe4034064a9ed7a202a05831461b0ffe898e0b500e6b8472d083ba0a819eef044200ab95c3a9ee4518785c7104c5a17d7be51adc99724dba24e270d18cae623589ba20f40f724540c07ead1c412f6fb5a7ef204e36ed3e47bdd036d83754e2e6f2bdeff9a9a4fd72fbe794d75de673473f909dc01b0dddc0625b93f0846d944ffd01e7dc4406f4b37f0fcbdca1aaeda926af92e70b52327425a5f118d5b7c03e62c171a9174d3b296382aac93440a4fec103c2567c538101b690e5e236eb8a1af4ee2f3b79200000000
class _SelfCustody1State extends State<SelfCustody1> {
  late WebViewController _controller;
  TransferApi? _transferApi;
  TransferApi get transferApi{
    _transferApi ??= TransferApi();
    return _transferApi!;
  }
  String? address;
  ECPrivate? privateKey;
  P2wshAddress? p2wshAddress;
  Uint8List? scriptByte;
  String? lockAmount;
  //String? lockTimeStr;
  int? lockTimeInt;
  String? publicKey;

  /// 获取 Staking WebView URL
  String _getStakingUrl() {
    return AppConfig.getApiUrlOnline('btcStaking');
  }

  @override
  void initState() {
    // TODO: implement initState
    //createWallet();
    //testdata();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    _controller =
        WebViewController.fromPlatformCreationParams(params);
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor( const Color(0xFF121212))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
          },
          onWebResourceError: (WebResourceError error) {
          },
          onNavigationRequest: (NavigationRequest request) {
            bool r=true;
            if(r==true){
              return NavigationDecision.navigate;
            }else{
              return NavigationDecision.prevent;
            }
          },
          onUrlChange: (UrlChange change) {
          },
        ),
      )
      ..loadRequest(Uri.parse(_getStakingUrl()))
      ..addJavaScriptChannel("N42APP", onMessageReceived: (JavaScriptMessage message) async{
        Map<String,dynamic>?rdata=jsonDecode(message.message);
        if(rdata !=null){
          if(rdata['type']=="get_canister_ecdsa_public_key"){
            Map<String,dynamic> ecdsaKeyMap=jsonDecode(rdata['ecdsaKey']);
            List<int> ecdsaKeyList = ecdsaKeyMap.values.map((e) => e as int).toList();
            String pKey=bytesToHex(ecdsaKeyList);
            int nowTime=(DateTime.now().millisecondsSinceEpoch~/1000)+(double.parse(rdata['lockupTime']!)*86400).toInt();
            lockTimeInt=nowTime;
            String? p2wshAddress=await createP2WSH(nowTime,cPubKey: pKey);
            //CreateP2WSH().p2wsh(rdata['lockupTime']);
            lockAmount=rdata['amount'];
            _controller.runJavaScript('is_p2wsh_address_valid("$p2wshAddress");');
          }else if(rdata['type']=="is_p2wsh_address_valid"){
            if(rdata["result"]==true){
              String p2wshAddr=p2wshAddress!.toAddress(BitcoinNetwork.testnet);
              final value=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletChainSendBtc(widget.coinModel,toAddress: p2wshAddr,toAmount: lockAmount!,)));
              if (!mounted) return;
              if(value !=null){

                String ethAddress=Provider.of<WalletActionProvider>(context,listen: false).getAddress(CoinType.N.name);
                BigInt lockAmountInt=ethToWeiString(lockAmount!, 8);
                //String alertStr='requestMintVbtc("${p2wshAddr}","${ethAddress}",${lockAmountInt},"${value}","${widget.coinModel.address}",${lockTimeInt},"${publicKey}");';
                String alertStr='requestMintVbtc("$p2wshAddr","$ethAddress",$lockAmountInt,"${widget.coinModel.address}",$lockTimeInt,"$publicKey");';
                if (kDebugMode) debugPrint(alertStr);
                _controller.runJavaScript(alertStr);
              }
            }
          }else if(rdata['type']=="request_mint_vbtc"){
            _controller.runJavaScript('alert("来自Flutter的消息，我收到了:${rdata['result']}");');
          }
        }

      });

    super.initState();
  }
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
    //String mm=Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"";
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
    Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic;
    String pk=await Trustdart().getPrivateKey(Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"", CoinType.BTC.name, "m/84'/4'/0'/0/0");
    bytesToHex(base64.decode(pk));
    privateKey=ECPrivate.fromHex(bytesToHex(base64.decode(pk)));
    //String mm=Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"";
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
      //Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic;
      //String pk=await Trustdart().getPrivateKey(Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"", CoinType.BTC.name, "m/84'/4'/0'/0/0");
      if (!mounted) return null;
      final wap = Provider.of<WalletActionProvider>(context,listen: false);
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
    //print(lockTime);
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
    //Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic;
    //String pk=await Trustdart().getPrivateKey(Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"", CoinType.BTC.name, "m/84'/4'/0'/0/0");
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
          //final p2wpkh=P2wpkhAddress.fromAddress(address: utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey_address'] ?? "", network: BitcoinNetwork.testnet);
          txInputScript.add(P2wpkhAddress.fromAddress(address: utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey_address'] ?? "", network: BitcoinNetwork.testnet).toScriptPubKey());
          /*Script p2wpkhScript=Script(script: [
            'OP_0',
            'OP_PUSHBYTES_20',
            p2wpkh.addressProgram
          ]);
          txInputScript.add(p2wpkhScript);*/
          //txInputScript.add(Script(script: [scriptpk]));
          totalInputAmount += utxo['value'] as int;
          selectedUTXOs.add(TxInput(txId: utxo['txid'], txIndex: utxo['vout']));
          txAmount.add(BigInt.from(utxo['value']));
        }
      }
      

      if (totalInputAmount >= (sendAmount + fee)) break;
    }

    int changeAmount = totalInputAmount - sendAmount - fee;
    List<TxOutput> txOutputs=[];
    
    //print(privateKey!.getPublic().toSegwitAddress().toAddress(BitcoinNetwork.testnet));
    Script scriptPubKey=P2wpkhAddress.fromAddress(address: 'tb1queqpeqalteucdndy4llnmz8l39ugtklypvw6v8', network: BitcoinNetwork.testnet).toScriptPubKey();
    //print(scriptPubKey.toHex());
    Script scriptPubkey1=p2wshAddress!.toScriptPubKey();
    String p=p2wshAddress!.toAddress(BitcoinNetwork.mainnet);
    if (kDebugMode) debugPrint(p);
    //print(scriptPubkey1.toHex());
    //print(txInputScript[0].toHex());
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

    //print(privateKey!.getPublic().toSegwitAddress().toAddress(BitcoinNetwork.testnet));
    Script scriptPubKey=P2wpkhAddress.fromAddress(address: address??"", network: BitcoinNetwork.testnet).toScriptPubKey();
    //print(scriptPubKey.toHex());
    Script scriptPubkey1=p2wshAddress!.toScriptPubKey();
    //print(scriptPubkey1.toHex());
    //print(txInputScript[0].toHex());
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

  List<dynamic> unspents=[];//可用余额列表
  int price=10000;
  List<Map<String,dynamic>> inputUTXO=[];//交易输入utxo列表
  Map<String,dynamic> gasFeeLevel={
    "error":false,
    "averageValue":5,//服务器获取的平均价格 gas
    "loading":false,
    "gasFeeRate":5,//用户输入的 gas
    "gasFees":0,//根据用户转账amount 和选择的gasFeeLevel 计算出gasFee
    "signByteSize":0,//签名返回的 数据包大小
    "maxValue":0,//全部转出的金额
  };
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Self-Custody'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
