import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/btc_api.dart';
import 'package:n42appv2/src/wallet/api/redeem_token.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:web3dart/crypto.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart';
import 'package:bitcoin_base/bitcoin_base.dart';

class Redeem extends StatefulWidget {
  final CoinModel coinModel;
  const Redeem(this.coinModel,{super.key});

  @override
  State<Redeem> createState() => _RedeemState();
}

class _RedeemState extends State<Redeem> {
  late WebViewController _controller;
  TransferApi? _transferApi;
  TransferApi get transferApi{
    _transferApi ??= TransferApi();
    return _transferApi!;
  }
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
  @override
  void initState() {
    // TODO: implement initState
    //testData();
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
      ..loadRequest(Uri.parse('${AppConfig.getApiUrlOnline('btcStaking')}/redeem?walletAddress=${widget.coinModel.address}'))
      ..addJavaScriptChannel("N42APP", onMessageReceived: (JavaScriptMessage message) async{
        Map<String,dynamic>?rdata=jsonDecode(message.message);
        if(rdata !=null){
          if(rdata['type']=="redeem"){
            String signStr=await redeem(rdata['p2wsh_address'],rdata['lock_time']);
            _controller.runJavaScript('request_withdraw_vbtc("${rdata['p2wsh_address']}","$signStr");');
          }else if(rdata['type']=="request_withdraw_vbtc"){
            _controller.runJavaScript('alert("来自Flutter的消息，我收到了:${rdata['result']}");');
          }
        }
      });
    super.initState();
  }
  Future<void> testData()async{
    redeem("tb1q229k7jwjlq6n3tdc0gmmhyxylze24ddvl9qext78sd2t3cyj9xvql3r07k",1742812372);
    //await redeem("tb1qxk5fqvludl0ec3zuy7m90u6w0v8sw993738qudpr68dad9ctaxjs5lavda");
  }
  int gasFeeRate=4;
  int gasFees=0;
  int input2Price=0;//实际输入金额
  bool inputValueOK=false;
  List<Map<String,dynamic>> inputUTXO=[];
  Future<void> redeem(String address,int lockTime)async{
    //await redeemEth(address);
    await getGasFeeBtc();
    //address="tb1qw39qrupll6xwmazqplpjgaclexjsd48jms2gwzk2xeuhqen9qxusem966j";
    //lockTime=1743160567;
    await getUTXO(address);
    /*inputUTXO.add({
      "vout":0,
      "script":"00144fe5e7b8c67c15609841d8cae2173e3e9f9193a8",
      "txid":"c93120b7b5cd46f5691310f42a2362336c04d49ed213f75b3467a70970050388",
      "value":"100000",
    });*/
    String witnessScriptValue=await createP2WSH(lockTime);
    inputUTXO[0]['witnessValue']=witnessScriptValue;
    inputUTXO[0]['lockTime']=lockTime;
    signP2WSH();
    /*BtcTransactionRecodeModel trModel=BtcTransactionRecodeModel();//交易数据
    trModel.address=widget.coinModel.address;
    trModel.to1=widget.coinModel.address;
    trModel.coin=widget.coinModel.coin;
    trModel.coinMiniName=widget.coinModel.coin['coinType'];
    trModel.walletIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
    trModel.price=100000;
    transatroinBuilder1To1(trModel,);*/
  }
  Future<void> redeemEth(String p2wshAddress)async{
    String serviceUrl=RequestUrl().getUrl2(CoinType.ETH.name, 'rpc',isTest: widget.coinModel.isTest);
    String privateKey;
    if(widget.coinModel.privateKey==null || widget.coinModel.privateKey==""){
      String pk=await Trustdart().getPrivateKey(Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"", CoinType.ETH.name, "m/44'/60'/0'/0/0");
      privateKey=bytesToHex(base64Decode(pk));
    }else{
      privateKey=bytesToHex(base64Decode(widget.coinModel.privateKey??""));
    }
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    if (kDebugMode) debugPrint(credentials.address.hex);
    RedeemToken rt=RedeemToken.init(address: EthereumAddress.fromHex("0x6c30A50430cC615C4659DF2dBe3E42036583bE7E"), client: Web3Client(serviceUrl, Client()),chainId: 11155111);
    final rData=await rt.reedem(p2wshAddress,credentials: credentials);
    if (kDebugMode) debugPrint(rData);
  }
  Future<String> createP2WSH(int lockTime,{String? uPubKey,String? cPubKey})async{
    // 1️⃣ 用户 & Canister 公钥 (HEX 格式)
    if(uPubKey==null){
      //Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic;
      //String pk=await Trustdart().getPrivateKey(Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"", CoinType.BTC.name, "m/84'/4'/0'/0/0");
      String pubKey=await Trustdart().getPublicKey(CoinType.BTC.name, "m/84'/4'/0'/0/0",mnemonic: Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"",pk: Provider.of<WalletActionProvider>(context,listen: false).walletInfo.privateKey??"");
      uPubKey=bytesToHex(base64Decode(pubKey));
      //String privatKey1=await Trustdart().getPrivateKey(Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"",CoinType.BTC.name, "m/84'/4'/0'/0/0",);
      //String privatKeyStr=bytesToHex(base64Decode(privatKey1));
      
      //privateKey!.getPublic().toHex();
      //03ed20061b9a0417a06ab80d063962c12ed80c9924b1d4da3628705b5b9ac9cecb
      //93fc44de3a7f96887b4159bc9b860ab701afa2e006ba03c720a640b30c5afd81
      //k/xE3jp/loh7QVm8m4YKtwGvouAGugPHIKZAswxa/YE=
      //1743037697
    }
    cPubKey ??= '02a075b5988699e95802fe94590908de9370588cacc750d6f538d76fe6e9b8d6ad';
    //cPubKey='03ed20061b9a0417a06ab80d063962c12ed80c9924b1d4da3628705b5b9ac9cecb';
    // 2️⃣ 质押时间（秒级时间戳）
    //int stakeTime = 1742981833; // 例如: 2023-11-14 12:00:00 UTC
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
    //print(P2wshAddress.fromScript(script: newScript).toAddress(BitcoinNetwork.testnet));
    return newScript.toHex();
    /*print(newScript.toHex());
    // 5️⃣ 生成 P2WSH 地址（主网示例）
    p2wshAddress =P2wshAddress.fromScript(script: newScript);
    if (kDebugMode) debugPrint(p2wshAddress!.toAddress(BitcoinNetwork.testnet));
    return p2wshAddress!.toAddress(BitcoinNetwork.testnet);*/
  }
  //获取 比特币的gasFee等级
  Future<void> getGasFeeBtc()async{
    MessageModel gasFeeMM=await tokenViewApi.getGasFeeBtc(isTest: widget.coinModel.isTest);
    if(gasFeeMM.error){
    }else{
      gasFeeRate=gasFeeMM.data;
    }
    setState(() {});
  }
  Future<void> signP2WSH()async{
    Map<String,dynamic> btcTxMap={
      "utxo":inputUTXO,
      "toAddress":widget.coinModel.address,
      "amount":99500,
      "byteFee":1,
      "changeAddress":widget.coinModel.address,
      "change":0,
      "max":true
    };
    if (kDebugMode) debugPrint(json.encode(btcTxMap));
    await Trustdart().signTransactionBtcP2wsh(CoinType.BTC.name, "m/84'/4'/0'/0/0", btcTxMap,pk: Provider.of<WalletActionProvider>(context,listen: false).walletInfo.privateKey??"");
  }
  //交易打包
  //unspents 未消费列表
  Future<BtcTransactionRecodeModel> transatroinBuilder1To1(BtcTransactionRecodeModel btcTransactionRecodeModel)async{
    try{
      Map<String,dynamic> btcTxMap={
        "utxo":inputUTXO,
        "toAddress":btcTransactionRecodeModel.to1,
        "amount":btcTransactionRecodeModel.price,
        "byteFee":500,
        "changeAddress":btcTransactionRecodeModel.address,
        "change":0,
      };
      //List<Map<String,dynamic>> utxos=[];//输出账单
      btcTransactionRecodeModel.inputModels=[];
      for(Map<String,dynamic> unspent in inputUTXO){
        input2Price+=int.parse(unspent['value']);
        InputModel im=InputModel(
          txid:unspent['txid'],
          vout: unspent['vout'],
          value:int.parse(unspent['value']),
          script:unspent['script'],
          witnessValue: unspent['witnessValue'],
          lockTime: unspent['lockTime'],
        );
        im.address=[widget.coinModel.address.toString()];
        btcTransactionRecodeModel.inputModels!.add(
          im,
        );
      }
      //int gasFees=await getSignByteSize(inputUTXO);
      btcTxMap['change']=0;
      btcTxMap['fees']=gasFees;
      btcTxMap['utxo']=inputUTXO;

      btcTransactionRecodeModel.price=btcTransactionRecodeModel.price-gasFees;
      btcTransactionRecodeModel.gas=gasFeeRate;
      btcTransactionRecodeModel.gasPrice=gasFees;
      btcTransactionRecodeModel.addrType=widget.coinModel.addrType;
      btcTransactionRecodeModel.max=true;
      btcTransactionRecodeModel.isTest=widget.coinModel.isTest?1:0;
      MessageModel rmm=await transferApi.transferWallet(
        trModelBtc:btcTransactionRecodeModel,
        pathIndex: widget.coinModel.pathIndex,
        privateKey: widget.coinModel.privateKey,
      );
      if(rmm.error){
        ToastUtils.show(rmm.data);
      }else{
        btcTransactionRecodeModel.txHash=rmm.data;
      }
      /*
      WalletInfo wi=ProviderUtil.walletActionProvider().walletInfoLsit[ProviderUtil.walletActionProvider().walletIndex];
      String signStr=await Trustdart.signTransaction(wi.mnemonic!, _trModel.coin['coinType'], _trModel.coin['path'][_coinModel!.addrType], btcTxMap,"","");
      btcTransactionRecodeModel.signStr=signStr;
       */
      return btcTransactionRecodeModel;
    }catch(e){
      return btcTransactionRecodeModel;
    }
  }
  Future<int> getSignByteSize(List<Map<String,dynamic>> utxos,{bool max=true})async{
    //await toAddress_check(toTextEditingController.text);
    //if(toErrorMessage !="")return;
    Map<String,dynamic> btcTxMap={
      "utxo":utxos,
      "toAddress":widget.coinModel.address,//toTextEditingController.text,
      "amount":0.001,
      "byteFee":gasFeeRate,
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
//获取 账簿
  Future<void> getUTXO(String address)async{
    try{
      MessageModel mm=await tokenViewApi.getUTXOBtc(widget.coinModel.coin['coinType'], address,pageSize: 1,pageNum: 10,isTest: widget.coinModel.isTest);
      if(mm.error){
        ToastUtils.show(mm.data);
        setState(() {});
      }else{
        await calculateGasFee(mm.data);
      }
    }catch(e){
      ToastUtils.show(e.toString());
      setState(() {});
    }
  }
  Future<void> calculateGasFee(List<dynamic> unspents)async{
    List<Map<String,dynamic>> utxos=[];//输出账单
    for(Map<String,dynamic> unspent in unspents){
      if(widget.coinModel.isTest){
        if(unspent['hex']==null){
          MessageModel utxoTx = await BtcApi(test: true).getUTXOTxid(unspent['txid']);
          if (utxoTx.error == false) {
            unspent['hex'] = utxoTx.data['vout']?[unspent['vout']]?['scriptpubkey'];
          }
        }
        int amount=unspent['value'];
        input2Price+=amount.toInt();
        utxos.add({
          "txid":unspent['txid'],
          "vout":unspent['vout'],
          "value": amount.toString(),
          "script": unspent['hex'],
        });
      }else{
        BigInt amount=ethToWeiString(double.parse(unspent['value']).toString(),8) ;
        input2Price+=amount.toInt();
        utxos.add({
          "txid":unspent['txid'],
          "vout":unspent['output_no'],//
          "value": amount.toString(),//BigInt.from(amount*100000000).toString(),
          "script": unspent['hex'],//unspent['script]
        });
      }
      int byteSize=338;
      //await getSignByteSize(utxos);
      if(byteSize !=0){
        gasFees=byteSize*gasFeeRate;
        inputValueOK=true;
        break;
      }
    }
    inputUTXO=utxos;
    setState(() {});
  }
  Future<void> initEthToken(String p2wshAddr)async{
    Web3Client client = Web3Client("https://eth-sepolia.public.blastapi.io", Client());
    RedeemToken token = RedeemToken.init(
        address: EthereumAddress.fromHex("0x6c30A50430cC615C4659DF2dBe3E42036583bE7E"), client: client);
    WalletInfo walletInfo=Provider.of<WalletActionProvider>(context,listen: false).walletInfo;
    String privateKey=walletInfo.privateKey??"";
    if(privateKey==""){
      privateKey=await Trustdart().getPrivateKey(walletInfo.mnemonic??"", CoinType.ETH.name, "m/44'/60'/0'/0/0",);
    }
    EthPrivateKey epk=EthPrivateKey(base64Decode(privateKey));
    final rData=await token.getDepositAmount(p2wshAddr, credentials: epk);
    if (kDebugMode) debugPrint(rData);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redeem'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
