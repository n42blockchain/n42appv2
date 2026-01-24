import 'dart:convert';

import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/core/di/service_locator_setup.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet_connect/widgets/wallet_connect_alert_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:provider/provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:web3dart/crypto.dart' as crypto;
import 'package:web3dart/web3dart.dart' as web3;

class WalletConnectProvider with ChangeNotifier{
  /*DataUtils? dataUtils;
  DataUtils get _dataUtils{
    if(dataUtils==null){
      dataUtils=DataUtils();
    }
    return dataUtils!;
  }*/
  Trustdart? _trustdart;
  Trustdart get trustdart{
    _trustdart ??= Trustdart();
    return _trustdart!;
  }
  bool pageOpen=false;
  wallet_connect.ReownWalletKit? signClient;
  //Web3Wallet? wcClient;
  web3.Web3Client? web3client;
  String? dAppTopic;

  late web3.EthPrivateKey privateKey;
  //List<PairingInfo> pairings = [];
  //int pairIndex=-1;
  int coinModelsIndex=-1;
  List<CoinModel> coinModels=[];//eth币模型
  setCoinModelsIndex(int value){
    coinModelsIndex=value;
    notifyListeners();
  }
  List<String> chainEvent=[
    'chainChanged',
    'accountsChanged'
  ];
  //wallet_connect.ProposalRequiredNamespaces? namespace_optional;
  Map<String, wallet_connect.Namespace>? namespace;
  WalletConnectState walletConnectState=WalletConnectState.loading;
  String errorMessage="";
  wallet_connect.PairingMetadata ? metadata;
  Load load=Load.finish;
  dynamic actionData;
  Map<String,dynamic>? actionDataMap;
  //dataType: transaction,message
  setActionDataMap(wallet_connect.SessionRequestEvent eventData
      //SessionRequestEvent data
      )async{
    //final session = signClient!.session.get(eventData.topic!);
    await web3client_init_fromChainId(eventData.chainId);
    switch (eventData.method) {
      case "personal_sign":
        final requestParams =
        (eventData.params! as List).cast<String>();
        final dataToSign = requestParams[0];
        final address = requestParams[1];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "from":address,
          "data":dataToSign,
          "signType":"message",
        };
        viewState_deal(WalletConnectState.messageSignOK);
        //return _onSign(eventData.id!, eventData.topic!, session, message);
        break;
      case "eth_sign":
        final requestParams =
        (eventData.params! as List).cast<String>();
        final dataToSign = requestParams[1];
        final address = requestParams[0];
        /*final message = WCEthSignMessage(
          data: dataToSign,
          address: address,
          type: WCSignType.MESSAGE,
        );*/
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "from":address,
          "data":dataToSign,
          "signType":"message",
        };
        viewState_deal(WalletConnectState.messageSignOK);
        break;
      case "eth_signTypedData":
      case "eth_signTypedData_v3":
      case "eth_signTypedData_v4":
        final requestParams = (eventData.params! as List).cast<String>();
        final dataToSign = requestParams[1];
        final address = requestParams[0];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "from":address,
          "data":dataToSign,
          "signType":"message",
        };
        viewState_deal(WalletConnectState.messageSignOK);
        break;
      case "eth_signTransaction":
        Map<String,dynamic> trMap=eventData.params![0];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "gas":crypto.hexToInt(trMap['gas']??"0x0").toInt().toString(),
          //_dataUtils.hexToInt(trMap['gas']??"0x0").toInt().toString(),
          "from":trMap['from']??"0x",
          "to":trMap['to']??"0x",
          "data":trMap['data']??"0x",
          "signType":"transaction",
        };
        viewState_deal(WalletConnectState.transactionOK);
        break;
      case "tron_signTransaction":
        Map<String,dynamic> trMap=eventData.params!['transaction'];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "gas":trMap['transaction']['fee_limit'].toString(),
          "from":trMap['transaction']['raw_data']['fee_limit']??"0",
          "to":trMap['transaction']['raw_data']['to']??"",
          "data":trMap['transaction']['raw_data_hex']??"",
          "signType":"transaction",
        };
        Map<String, dynamic> txData = {
          "ownerAddress": trMap['transaction']['raw_data']['contract']['parameter']['value']['owner_address']??"",
          "toAddress": trMap['transaction']['raw_data']['to']??"",
          "timestamp": trMap['transaction']['raw_data']['timestamp'] as int,
          "blockTime": trMap['transaction']['raw_data']['to']??"",
          "txTrieRoot": trMap['transaction']['raw_data']['to']??"",
          "witnessAddress": trMap['transaction']['raw_data']['to']??"",
          "parentHash": trMap['transaction']['raw_data']['to']??"",
          "version": trMap['transaction']['raw_data']['to']??"",
          "number": trMap['transaction']['raw_data']['to']??"",
          "feeLimit": trMap['transaction']['raw_data']['fee_limit'] as int,
        };
        if (trMap['transaction']['raw_data']['contract']['parameter']['value']['owner_address']??"" != "") {
          txData['cmd'] = "TRC20";
          txData['contractAddress'] = trMap['transaction']['raw_data']['contract']['parameter']['value']['owner_address']??"";
          txData['amount'] = "";
        }
        viewState_deal(WalletConnectState.transactionOK);
        break;
      case "eth_sendTransaction":
      /*final ethereumTransaction = WCEthSignTransaction.fromJson(
            eventData.params!.request.params.first);
        return _onSendTransaction(
          eventData.id!,
          int.parse(eventData.params!.chainId.split(':').last),
          session,
          ethereumTransaction,
        );*/
        Map<String,dynamic> trMap=eventData.params![0];
        //eventData.params!.request.params.first;
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "gas":crypto.hexToInt(trMap['gas']??"0x0").toInt().toString(),
          "from":trMap['from']??"0x",
          "to":trMap['to']??"0x",
          "data":trMap['data']??"0x",
          "signType":"transaction",
        };
        viewState_deal(WalletConnectState.transactionOK);
        break;
      case "tron_signMessage":
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        final address = requestParams["address"];
        /*final message = WCEthSignMessage(
          data: dataToSign,
          address: address,
          type: WCSignType.TYPED_MESSAGE_V4,
        );*/
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "from":address,
          "data":dataToSign,
          "signType":"message",
        };
        viewState_deal(WalletConnectState.messageSignOK);
        break;
      default:
        debugPrint('Unsupported request.');
    }
    actionData=eventData;
  }
  connect_init()async{
    try{
      signClient=await wallet_connect.ReownWalletKit.createInstance(
        projectId: "18a60a7cb862aad161fecd764ecc736a",
        metadata: wallet_connect.PairingMetadata(
          name: AppConfig.apiUrl['walletName'],
          description: AppConfig.apiUrl['walletName'],
          url: AppConfig.apiUrl['walletamazeBrowser']!,
          icons: ["https://n42.ai/static/n42.png"],
        ),
      );
      coinModel_init();
      setChainInfo();
    }catch(e){
      viewState_deal(WalletConnectState.error,params: e.toString());
    }
  }
  pair(String relayUrl)async{
    try{
      if(Uri.tryParse(relayUrl) !=null){
        //viewState_deal(WalletConnectV2State.part);
        await signClient!.pair(uri:Uri.parse(relayUrl));
      }
      notifyListeners();
    }catch(e){
      viewState_deal(WalletConnectState.error,params: e.toString());
    }
  }
  // 创建web3实例 - 使用 IWalletService 获取钱包信息
  web3client_init() async {
    try {
      CoinModel cm = coinModels[coinModelsIndex];
      web3client = web3.Web3Client(cm.isTest ? cm.coin['service_test'] : cm.coin['service'], Client());
      
      // 使用 IWalletService 获取当前钱包的私钥和助记词
      final walletService = ServiceLocatorSetup.walletService;
      if (walletService == null) {
        viewState_deal(WalletConnectState.error, params: "Wallet service not available");
        return false;
      }
      
      final currentIndex = walletService.miningWalletIndex >= 0 
          ? walletService.miningWalletIndex 
          : 0;
      String? pKey = await walletService.getPrivateKeyForWallet(currentIndex);
      
      if (pKey == null) {
        final mnemonic = await walletService.getMnemonicForWallet(currentIndex);
        if (mnemonic != null) {
          pKey = await trustdart.getPrivateKey(mnemonic, cm.coin['coinType'], getPathWithIndex(cm.coin['path']['legacy'], cm.pathIndex));
        }
      }
      
      if (pKey == null) {
        viewState_deal(WalletConnectState.error, params: "Could not get private key");
        return false;
      }
      
      privateKey = web3.EthPrivateKey(base64Decode(pKey));
      return true;
    } catch (e) {
      viewState_deal(WalletConnectState.error, params: e.toString());
      return false;
    }
  }
  web3client_init_fromChainId(String eip155)async{
    String chainId=eip155.split(":")[1];
    int chainIndex=coinModels.indexWhere((element){
      String eChainId=(element.isTest?element.coin['chainId_test']:element.coin['chainId']).toString();
      if(eChainId==chainId){
        return true;
      }
      return false;
    });
    if(chainIndex==-1){
      viewState_deal(WalletConnectState.error,params: "Error");
      return false;
    }
    if(coinModelsIndex !=chainIndex){
      setCoinModelsIndex(chainIndex);
      return await web3client_init();
    }
    if(web3client==null){
      return await web3client_init();
    }
    return true;
  }

  //获取ETH类的主链
  coinModel_init({int chainId=-1}){
    try{
      List<CoinModel> cms=Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).coinModels;
      coinModels=[];
      for(CoinModel cm in cms){
        if(cm.coin['blockchainType']==BlockchainType.Ethereum.name){
          coinModels.add(cm);
          if(chainId==-1){
            //setCoinModelsIndex(coinModels.length-1);
          }else{
            if(cm.isTest){
              if(cm.coin['chainId_test']==chainId){
                setCoinModelsIndex(coinModels.length-1);
              }
            }else{
              if(cm.coin['chainId']==chainId){
                setCoinModelsIndex(coinModels.length-1);
              }
            }

          }
        }
      }
      if(coinModels.isNotEmpty && chainId ==-1){
        setCoinModelsIndex(0);
      }
    }catch(e){
      viewState_deal(WalletConnectState.error,params: e.toString());
    }
  }
  //查找不支持的链
  coinModel_find(String chainId){
    int rIndex=coinModels.indexWhere((element){
      String cId="";
      if(element.coin['blockchainType']==BlockchainType.Ethereum.name){
        dynamic id=element.isTest?element.coin['chainId_test']:element.coin['chainId'];
        cId="eip155:$id";
      }else if(element.coin['blockchainType']==BlockchainType.Tron.name){
        cId="tron:0x2b6653dc";
      }
      if(cId==chainId){
        return true;
      }else{
        return false;
      }
    });
    if(rIndex ==-1){
      return null;
    }
    return coinModels[rIndex];
  }

  /*static const namespace = 'eip155';
  static const pSign = 'personal_sign';
  static const eSign = 'eth_sign';
  static const eSignTransaction = 'eth_signTransaction';
  static const eSignTypedData = 'eth_signTypedData';
  static const eSendTransaction = 'eth_sendTransaction';*/
  setChainInfo(){
    try{
      if(signClient !=null){
        signClient!.onSessionProposal.subscribe((wallet_connect.SessionProposalEvent? args)async{
          //final eventData= args as wallet_connect.SessionProposalEvent<wallet_connect.RequestSessionPropose>;
          if(args !=null){
            actionData=args;
            metadata=args.params.proposer.metadata;
            Map<String,wallet_connect.RequiredNamespace> optional=args.params.optionalNamespaces;
            Map<String,wallet_connect.RequiredNamespace> required=args.params.requiredNamespaces;
            List<String> chainType=optional.keys.toList();
            List<String> chainType_required=required.keys.toList();
            List<String> accounts=[];
            List<String> accounts_tron=[];
            List<CoinModel> rCoinModel=[];
            for(String chain in chainType){
              if(chain=="eip155"){
                if(optional[chain]!.chains==null)continue;
                for(int i=0;i<optional[chain]!.chains!.length;i++){
                  CoinModel? cm=coinModel_find(optional[chain]!.chains![i]);
                  if(cm !=null){
                    rCoinModel.add(cm);
                  }
                }
              }else if(chain=="tron"){
                if(optional[chain]!.chains==null)continue;
                for(String c in (optional[chain]!.chains!)){
                  CoinModel? cm=coinModel_find(c);
                  if(cm !=null){
                    rCoinModel.add(cm);
                  }
                }
              }
            }
            for(String chain in chainType_required){
              if(chain=="eip155"){
                if(required[chain]!.chains==null)continue;
                for(int i=0;i<required[chain]!.chains!.length;i++){
                  if(optional.isNotEmpty){
                    int fIndex=optional[chain]!.chains!.indexWhere((element) => required[chain]!.chains![i]==element);
                    if(fIndex !=-1){
                      continue;
                    }
                  }
                  CoinModel? cm=coinModel_find(required[chain]!.chains![i]);
                  if(cm !=null){
                    rCoinModel.insert(0,cm);
                  }
                }
              }else if(chain=="tron"){
                if(required[chain]!.chains==null)continue;
                for(int i=0;i<required[chain]!.chains!.length;i++){
                  int fIndex=optional[chain]!.chains!.indexWhere((element) => required[chain]!.chains![i]==element);
                  if(fIndex !=-1){
                    continue;
                  }
                  CoinModel? cm=coinModel_find(required[chain]!.chains![i]);
                  if(cm !=null){
                    rCoinModel.insert(0,cm);
                  }
                }
              }
            }
            coinModels=rCoinModel;
            coinModelsIndex=coinModels.length-1;

            for(int i=coinModels.length-1;i>=0;i--){
              if(coinModels[i].coin['blockchainType']==BlockchainType.Ethereum.name){
                String chainId="eip155:${coinModels[i].isTest?coinModels[i].coin['chainId_test']:coinModels[i].coin['chainId']}";
                accounts.add("$chainId:${coinModels[i].address.toString()}");
                signClient!.registerRequestHandler(chainId: chainId, method: "eth_sendTransaction");
                signClient!.registerRequestHandler(chainId: chainId, method: "eth_signTransaction");
                signClient!.registerRequestHandler(chainId: chainId, method: "eth_sign");
                signClient!.registerRequestHandler(chainId: chainId, method: "personal_sign");
                signClient!.registerRequestHandler(chainId: chainId, method: "eth_signTypedData");
                signClient!.registerRequestHandler(chainId: chainId, method: "eth_signTypedData_v4");
                signClient!.registerAccount(chainId: chainId, accountAddress: coinModels[i].address.toString());
              }else if(coinModels[i].coin['blockchainType']==BlockchainType.Tron.name){
                /*accounts_tron.add("tron:0xcd8690dc:${coinModels[i].address.toString()}");//测试
                signClient!.registerRequestHandler(chainId: "tron:0xcd8690dc", method: "tron_signTransaction");
                signClient!.registerRequestHandler(chainId: "tron:0xcd8690dc", method: "tron_signMessage");
                signClient!.registerAccount(chainId: "tron:0xcd8690dc", accountAddress: coinModels[i].address.toString());*/
                accounts_tron.add("tron:0x2b6653dc:${coinModels[i].address.toString()}");//主
                signClient!.registerRequestHandler(chainId: "tron:0x2b6653dc", method: "tron_signTransaction");
                signClient!.registerRequestHandler(chainId: "tron:0x2b6653dc", method: "tron_signMessage");
                signClient!.registerAccount(chainId: "tron:0x2b6653dc", accountAddress: coinModels[i].address.toString());
              }

            }
            namespace={
              "eip155":wallet_connect.Namespace(
                accounts: accounts,
                methods: [
                  "eth_sendTransaction",
                  "eth_signTransaction",
                  "eth_sign",
                  "personal_sign",
                  "eth_signTypedData",
                  "eth_signTypedData_v4"
                ],
                events: [
                  'chainChanged',
                  'accountsChanged'
                ],
              ),
            };
            if(accounts_tron.isNotEmpty){
              namespace!['tron']=wallet_connect.Namespace(
                accounts: accounts_tron,
                methods: [
                  "tron_signTransaction",
                  "tron_signMessage"
                ],
                events: [
                  'chainChanged',
                  'accountsChanged'
                ],
              );
            }
            viewState_deal(WalletConnectState.selectChain);
          }
          else{
            viewState_deal(WalletConnectState.error,params: "Error");
          }
        });
        //signClient!.registerRequestHandler(chainId: "tron:0xcd8690dc", method: "tron_signTransaction");
        //signClient!.registerAccount(chainId: "tron:0xcd8690dc", accountAddress: accountAddress);
        signClient!.onSessionRequest.subscribe((wallet_connect.SessionRequestEvent? args) async{
          setActionDataMap(args);
        });
        signClient!.onSessionDelete.subscribe(( args) async{
          //print(args!.topic);
          if(dAppTopic !=null && dAppTopic==args.topic){
            viewState_deal(WalletConnectState.disconnect);
          }
        });
        signClient!.onSessionProposalError.subscribe((wallet_connect.SessionProposalErrorEvent? args) async{
          viewState_deal(WalletConnectState.error,params: args?.error.message??"Error");
        });
        signClient!.onSessionConnect.subscribe((args) async{
          //print(args!.session.topic);
          //dAppTopic=args!.session.pairingTopic;
          //print("");
        });
        signClient!.onSessionPing.subscribe((args) async{
          //print('');
        });
        signClient!.onSessionExpire.subscribe((args) async{
          //print('');
        });
        signClient!.onProposalExpire.subscribe((wallet_connect.SessionProposalEvent? args) async{
          //print('');
        });
      }
    }catch(e){
      viewState_deal(WalletConnectState.error,params: e.toString());
    }
  }

  Future messageSignTap() async {
    try {
      if(walletConnectState==WalletConnectState.messageSign)return;
      viewState_deal(WalletConnectState.messageSign);
      final eventData = actionData as wallet_connect.SessionRequestEvent;
      String signedDataHex;
      if(eventData.method == "personal_sign"){
        final requestParams =
        (eventData.params! as List).cast<String>();
        String dataToSign = requestParams[0];
        dataToSign=crypto.strip0x(requestParams[0]);
        //final address = requestParams[1];
        final encodedMessage = crypto.hexToBytes(dataToSign);
        final signedData =
        await privateKey.signPersonalMessageToUint8List(encodedMessage);
        signedDataHex = bytesToHex(signedData,include0x: true);
      }
      else if (eventData.method == "eth_signTypedData") {
        final requestParams =
        (eventData.params! as List).cast<String>();
        signedDataHex = EthSigUtil.signTypedData(
          privateKeyInBytes: privateKey.privateKey,
          jsonData: requestParams[1],
          version: TypedDataVersion.V4,
        );
      } else if (eventData.method == "eth_signTypedData_v3") {
        final requestParams =
        (eventData.params! as List).cast<String>();
        signedDataHex = EthSigUtil.signTypedData(
          privateKeyInBytes: privateKey.privateKey,
          jsonData: requestParams[1],
          version: TypedDataVersion.V3,
        );
      } else if (eventData.method == "eth_signTypedData_v4") {
        final requestParams =
        (eventData.params! as List).cast<String>();
        signedDataHex = EthSigUtil.signTypedData(
          privateKeyInBytes: privateKey.privateKey,
          jsonData: requestParams[1],
          version: TypedDataVersion.V4,
        );
      } else if (eventData.method == "tron_signMessage") {
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        CoinModel cm = coinModels[2];
        
        // 使用 IWalletService 获取私钥和助记词
        final walletService = ServiceLocatorSetup.walletService;
        final currentIndex = walletService?.miningWalletIndex ?? 0;
        final mnemonic = await walletService?.getMnemonicForWallet(currentIndex) ?? "";
        final pk = await walletService?.getPrivateKeyForWallet(currentIndex) ?? "";
        
        String path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
        signedDataHex = await trustdart.signMessage(CoinType.TRX.name, path, dataToSign, mnemonic: mnemonic, pk: pk);
      }
      else {
        final requestParams =
        (eventData.params! as List).cast<String>();
        String dataToSign = requestParams[1];
        dataToSign=crypto.strip0x(dataToSign);
        if(coinModels[coinModelsIndex].coin['coinType']==CoinType.N.name){
          signedDataHex=await trustdart.signMessage(CoinType.N.name, "", dataToSign, pk: base64Encode(privateKey.privateKey));
          signedDataHex="0x$signedDataHex";
        }else{
          final encodedMessage =  crypto.hexToBytes(dataToSign);
          final signedData =
          await privateKey.signPersonalMessageToUint8List(encodedMessage);
          signedDataHex = bytesToHex(signedData,include0x: true);
        }
      }
      signClient!.respondSessionRequest(topic: eventData.topic, response: wallet_connect.JsonRpcResponse(id: eventData.id,
        result: signedDataHex,));
      viewState_deal(WalletConnectState.connect);
    } catch (e) {
      viewState_deal(WalletConnectState.error,params: e.toString());
    }
  }
  Future transactionSignTap() async {
    try {
      if(walletConnectState==WalletConnectState.transaction)return;
      viewState_deal(WalletConnectState.transaction);
      final eventData = actionData as wallet_connect.SessionRequestEvent;
      bool initOk=await web3client_init_fromChainId(eventData.chainId);
      if(initOk==false)return;
      if (eventData.method == "tron_signTransaction") {
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        CoinModel cm = coinModels[2];
        
        // 使用 IWalletService 获取私钥和助记词
        final walletService = ServiceLocatorSetup.walletService;
        final currentIndex = walletService?.miningWalletIndex ?? 0;
        final mnemonic = await walletService?.getMnemonicForWallet(currentIndex) ?? "";
        final pk = await walletService?.getPrivateKeyForWallet(currentIndex) ?? "";
        
        String path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
        String returnStr = await trustdart.signTransaction(CoinType.TRX.name, path, dataToSign, mnemonic: mnemonic, pk: pk);
        signClient!.respondSessionRequest(
          topic: eventData.topic,
          response: wallet_connect.JsonRpcResponse(
            id: eventData.id,
            result: returnStr,
          ),);
        viewState_deal(WalletConnectState.connect);
        return ;
      }
      Map<String,dynamic> parameters=eventData.params.first;
      String from=parameters['from'];
      String? to=parameters['to'];
      String? value=parameters['value'];
      String? nonce=parameters['nonce'];
      String? gasPrice=parameters['gasPrice'];
      String? maxFeePerGas=parameters['maxFeePerGas'];
      String? maxPriorityFeePerGas=parameters['maxPriorityFeePerGas'];
      //String? gas=parameters['gas'];
      String? gasLimit=parameters['gasLimit'];
      String? data=parameters['data'];
      final transaction = web3.Transaction(
        from: web3.EthereumAddress.fromHex(from),
        to: web3.EthereumAddress.fromHex(to??"0x"),
        value: web3.EtherAmount.fromBigInt(web3.EtherUnit.wei, BigInt.tryParse(value??"0x") ?? BigInt.zero,),
        gasPrice: gasPrice != null
            ? web3.EtherAmount.fromBigInt(
          web3.EtherUnit.gwei,
          BigInt.tryParse(gasPrice) ?? BigInt.zero,
        )
            : null,
        maxFeePerGas: maxFeePerGas != null
            ? web3.EtherAmount.fromBigInt(
          web3.EtherUnit.gwei,
          BigInt.tryParse(maxFeePerGas) ?? BigInt.zero,
        )
            : null,
        maxPriorityFeePerGas: maxPriorityFeePerGas != null
            ? web3.EtherAmount.fromBigInt(
          web3.EtherUnit.gwei,
          BigInt.tryParse(maxPriorityFeePerGas) ??
              BigInt.zero,
        )
            : null,
        maxGas: int.tryParse(gasLimit ?? ''),
        nonce: int.tryParse(nonce ?? ''),
        data: (data != null && data != '0x')
            ?  crypto.hexToBytes(data)
            : null,
      );
      String returnStr="";
      if(eventData.method == "eth_signTransaction"){
        Uint8List sig = await web3client!.signTransaction(
          privateKey,
          transaction,
        );
        returnStr= bytesToHex(sig,include0x: true);
      }else if(eventData.method == "eth_sendTransaction"){
        returnStr = await web3client!.sendTransaction(
          privateKey,
          transaction,
          chainId: coinModels[coinModelsIndex].isTest?coinModels[coinModelsIndex].coin['chainId_test']:coinModels[coinModelsIndex].coin['chainId'],
        );
      }
      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          result: returnStr,
        ),);
      viewState_deal(WalletConnectState.connect);
    } catch (e) {
      viewState_deal(WalletConnectState.error,params: e.toString());
    }
  }
  /*
  Future ethSignTypedData(String topic, dynamic parameters) async {
    final String data = parameters[1];
    return EthSigUtil.signTypedData(
      privateKeyInBytes: privateKey.privateKey,
      jsonData: data,
      version: TypedDataVersion.V4,
    );
  }
   */
  /*
  approveSession(int id,Map<String,Namespace> namespace)async{
    await wcClient!.approveSession(id: id, namespaces: namespace);
  }
  rejectSession(int id,WalletConnectError reason)async{
    await wcClient!.rejectSession(id: id, reason: reason);
  }*/
  //取消交易或签名等
  cancelTap(WalletConnectState state)async{
    viewState_deal(state);
    final eventData = actionData as wallet_connect.SessionRequestEvent;
    signClient!
        .respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(id: eventData.id,
            error: wallet_connect.JsonRpcError(
                code: 4001,
                message: "User rejected."
            ))).then((value){
      viewState_deal(WalletConnectState.connect);
    });
  }
  /*approveTap()async{
    viewState_deal(WalletConnectV2State.transaction);
    SessionRequestEvent requestEvent=actionData as SessionRequestEvent;
    String txHash=await ethSignTransaction(requestEvent.topic,requestEvent.params);
    await wcClient!.respondSessionRequest(topic: requestEvent.topic, response: JsonRpcResponse(id: requestEvent.id,result: txHash));
    //await approveSession(requestEvent.id,namespace!);
    viewState_deal(WalletConnectV2State.connect);
  }*/
  disconnectOnTap()async{
    await signClient!.disconnectSession(
        topic: dAppTopic??"",
      reason: wallet_connect.Errors.getSdkError(wallet_connect.Errors.USER_DISCONNECTED).toSignError(),
    );
  }
  viewState_deal(WalletConnectState state,{dynamic params})async{
    switch(state){
      case WalletConnectState.loading:
        await connect_init();
        await pair(params as String);
        break;
    /*case WalletConnectV2State.part:
        break;*/
      case WalletConnectState.selectChain:
        break;
      case WalletConnectState.connectOK:
      //chainRegister();
      //SessionProposalEvent args=actionData as SessionProposalEvent;
        wallet_connect.SessionProposalEvent args=actionData as wallet_connect.SessionProposalEvent;
        try{
          signClient!.approveSession(id:args.id,namespaces:namespace! ).then((value)
          async{
            dAppTopic=value.topic;
            viewState_deal(WalletConnectState.connect);
          }).catchError(( error){
            ToastUtils.show(error.toString());
            viewState_deal(WalletConnectState.disconnect);
          });
        }catch(e){
          ToastUtils.show("Connection error:${e.toString()}");
          viewState_deal(WalletConnectState.disconnect);
        }

        //wcClient!.approveSession(id: args!.id, namespaces: namespace!);
        break;
      case WalletConnectState.connect:
        break;
      case WalletConnectState.disconnect:
      //await signClient!.disconnectSession(topic: dAppTopic??"", reason: wallet_connect.Errors.getSdkError(wallet_connect.Errors.USER_DISCONNECTED));
        cleanData();
        break;
      case WalletConnectState.reconnect:

        break;
      case WalletConnectState.transactionOK:
        if(pageOpen==false){
          showAlertWidget();
        }
        break;
      case WalletConnectState.transaction:
        break;
      case WalletConnectState.messageSignOK:
        if(pageOpen==false){
          showAlertWidget();
        }
        break;
      case WalletConnectState.messageSign:
        break;
      case WalletConnectState.error:
        errorMessage=params as String;
        break;
    }
    walletConnectState=state;
    notifyListeners();
  }
  showAlertWidget(){
    SheetBottom(
      AppGlobals.navigatorKey.currentContext!,
      "",
      WalletConnectAlertWidget(metadata!, actionDataMap!),
    );
  }
  //清理数据
  cleanData(){
    dAppTopic=null;
    errorMessage="";
    walletConnectState=WalletConnectState.loading;
  }
  cleannData_loginout(){
    if(dAppTopic !=null){
      disconnectOnTap();
    }else{
      cleanData();
    }
    /*if(walletConnectV2State !=WalletConnectV2State.loading){
      viewState_deal(WalletConnectV2State.disconnect);
    }*/
  }
}
//页面状态
enum WalletConnectState{
  loading,//加载
  //part,//配对中
  selectChain,//选择链
  connectOK,//确认连接
  connect,//连接
  disconnect,//连接断开
  reconnect,//重连
  transactionOK,//交易确认
  transaction,//交易中
  messageSignOK,//签名消息确认
  messageSign,//签名消息确认中
  error,
}