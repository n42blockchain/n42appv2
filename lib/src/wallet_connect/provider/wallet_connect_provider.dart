import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/core/di/service_locator_setup.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';
import 'package:n42appv2/src/wallet_connect/widgets/wallet_connect_alert_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:eip712/eip712.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:wallet/wallet.dart' as wallet_types;
import 'package:web3dart/web3dart.dart' as crypto;
import 'package:web3dart/web3dart.dart' as web3;

class WalletConnectProvider with ChangeNotifier, WidgetsBindingObserver {
  WalletConnectProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// 公开的刷新方法，用于通知监听者数据已更新
  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelReconnectTimer();
    web3client?.dispose();
    web3client = null;
    if (signClient != null) {
      try {
        signClient!.core.relayClient.disconnect();
      } catch (e) {
        if (kDebugMode) debugPrint('[WalletConnect] disconnect error: $e');
      }
      signClient = null;
    }
    // 清除敏感数据，避免内存泄漏
    actionData = null;
    actionDataMap = {};
    errorMessage = '';
    super.dispose();
  }

  // ── App lifecycle ──────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  /// Called when app returns to foreground.
  /// Re-establishes the relay WebSocket that may have been closed by the OS.
  void _onAppResumed() {
    if (signClient == null || dAppTopic == null) return;
    try {
      // The SDK call is a no-op when already connected, safe to always call.
      signClient!.core.relayClient.connect().catchError((e) {
        debugPrint('[WalletConnect] Resume relay reconnect error: $e');
      });
    } catch (e) {
      debugPrint('[WalletConnect] Resume relay reconnect: $e');
    }
  }

  // ── Reconnect timer ───────────────────────────────────────────────────────

  Timer? _reconnectTimer;
  static const _maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;

  void _scheduleReconnect() {
    _cancelReconnectTimer();
    if (signClient == null || _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts && dAppTopic != null) {
        ToastUtils.show('Connection lost. Please reconnect.');
        viewStateDeal(WalletConnectState.disconnect);
      }
      return;
    }
    // Exponential back-off: 2s, 4s, 8s, 16s, 30s
    final seconds = (_reconnectAttempts < 4) ? (2 << _reconnectAttempts) : 30;
    _reconnectTimer = Timer(Duration(seconds: seconds), _tryReconnect);
    debugPrint('[WalletConnect] Reconnect attempt ${_reconnectAttempts + 1} in ${seconds}s');
  }

  Future<void> _tryReconnect() async {
    _reconnectAttempts++;
    try {
      await signClient!.core.relayClient.connect();
      _reconnectAttempts = 0;
      debugPrint('[WalletConnect] Relay reconnected');
    } catch (e) {
      debugPrint('[WalletConnect] Reconnect #$_reconnectAttempts failed: $e');
      _scheduleReconnect();
    }
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

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

  /// Guard: prevent duplicate WalletKit event subscriptions when connectInit
  /// is called again (e.g. user scans a new QR after disconnect).
  bool _eventsRegistered = false;

  /// True while the user-initiated disconnect is in progress.
  /// Suppresses the DApp-disconnect Toast from [onSessionDelete] in that window.
  bool _disconnectingByUser = false;

  late web3.EthPrivateKey privateKey;
  //List<PairingInfo> pairings = [];
  //int pairIndex=-1;
  int coinModelsIndex=-1;
  List<CoinModel> coinModels=[];//eth币模型
  void setCoinModelsIndex(int value){
    coinModelsIndex=value;
    notifyListeners();
  }
  Map<String, wallet_connect.Namespace>? namespace;
  WalletConnectState walletConnectState=WalletConnectState.loading;
  String errorMessage="";
  wallet_connect.PairingMetadata ? metadata;
  Load load=Load.finish;
  dynamic actionData;
  Map<String,dynamic>? actionDataMap;
  Future<void> setActionDataMap(wallet_connect.SessionRequestEvent eventData)async{
    if (eventData.params == null) {
      viewStateDeal(WalletConnectState.error, params: 'Invalid request: params is null');
      return;
    }
    if (coinModelsIndex < 0 || coinModelsIndex >= coinModels.length) {
      viewStateDeal(WalletConnectState.error, params: 'No valid chain selected');
      return;
    }
    await web3clientInitFromChainId(eventData.chainId);
    switch (eventData.method) {
      case "personal_sign":
        final requestParams =
        (eventData.params! as List).cast<String>();
        if (requestParams.length < 2) {
          viewStateDeal(WalletConnectState.error, params: 'Invalid personal_sign params: expected 2, got ${requestParams.length}');
          return;
        }
        final dataToSign = requestParams[0];
        final address = requestParams[1];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "from":address,
          "data":dataToSign,
          "signType":"message",
        };
        viewStateDeal(WalletConnectState.messageSignOK);
        break;
      case "eth_sign":
        final requestParams =
        (eventData.params! as List).cast<String>();
        final dataToSign = requestParams[1];
        final address = requestParams[0];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "from":address,
          "data":dataToSign,
          "signType":"message",
        };
        viewStateDeal(WalletConnectState.messageSignOK);
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
        viewStateDeal(WalletConnectState.messageSignOK);
        break;
      case "eth_signTransaction":
        Map<String,dynamic> trMap=eventData.params![0];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "gas":crypto.hexToInt(trMap['gas']??"0x0").toInt().toString(),
          "from":trMap['from']??"0x",
          "to":trMap['to']??"0x",
          "data":trMap['data']??"0x",
          "value":trMap['value']??"0x0",
          "signType":"transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);
        break;
      case "tron_signTransaction":
        final rawTronParams = eventData.params;
        if (rawTronParams == null || rawTronParams is! Map || !rawTronParams.containsKey('transaction')) {
          viewStateDeal(WalletConnectState.error, params: 'Invalid TRON transaction: missing params');
          break;
        }
        final Map<String,dynamic> trMap = Map<String,dynamic>.from(rawTronParams['transaction'] as Map);
        final tronInnerTx = trMap['transaction'] as Map<String, dynamic>? ?? {};
        final tronRawData = tronInnerTx['raw_data'] as Map<String, dynamic>? ?? {};
        // contract 字段在标准 TRON 格式中为 List，但部分实现为 Map
        final tronContractRaw = tronRawData['contract'];
        String tronContractType = '';
        Map<String, dynamic> tronContractValue = {};
        if (tronContractRaw is List && tronContractRaw.isNotEmpty) {
          final item = tronContractRaw[0] as Map<String, dynamic>;
          tronContractType = item['type'] as String? ?? '';
          tronContractValue = (item['parameter']?['value'] as Map<String, dynamic>?) ?? {};
        } else if (tronContractRaw is Map<String, dynamic>) {
          tronContractType = tronContractRaw['type'] as String? ?? '';
          tronContractValue = (tronContractRaw['parameter']?['value'] as Map<String, dynamic>?) ?? {};
        }
        final tronOwnerAddr = tronContractValue['owner_address'] as String? ?? '';
        final tronToAddr = tronContractValue['to_address'] as String? ?? '';
        final tronContractAddr = tronContractValue['contract_address'] as String? ?? '';
        final tronFeeLimit = tronRawData['fee_limit'] as int? ?? 0;
        // TriggerSmartContract = TRC20；TransferContract = TRX 原生转账
        final isTrc20 = tronContractType == 'TriggerSmartContract';
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "gas":tronFeeLimit.toString(),
          "from":tronOwnerAddr,
          "to":isTrc20 ? tronContractAddr : tronToAddr,
          "data":tronInnerTx['raw_data_hex'] as String? ?? "",
          "signType":"transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);
        break;
      case "eth_sendTransaction":
        Map<String,dynamic> trMap=eventData.params![0];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "gas":crypto.hexToInt(trMap['gas']??"0x0").toInt().toString(),
          "from":trMap['from']??"0x",
          "to":trMap['to']??"0x",
          "data":trMap['data']??"0x",
          "value":trMap['value']??"0x0",
          "signType":"transaction",
        };
        viewStateDeal(WalletConnectState.transactionOK);
        break;
      case "tron_signMessage":
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        final address = requestParams["address"];
        actionDataMap={
          "network":coinModels[coinModelsIndex].coin['name'],
          "from":address,
          "data":dataToSign,
          "signType":"message",
        };
        viewStateDeal(WalletConnectState.messageSignOK);
        break;
      default:
        debugPrint('Unsupported request.');
    }
    actionData=eventData;
  }
  Future<void> connectInit()async{
    try{
      if (signClient != null) {
        // Already initialised — re-use the existing client and just
        // refresh the coin model for the new pairing attempt.
        coinModelInit();
        return;
      }
      signClient=await wallet_connect.ReownWalletKit.createInstance(
        projectId: "18a60a7cb862aad161fecd764ecc736a",
        metadata: wallet_connect.PairingMetadata(
          name: AppConfig.apiUrl['walletName'],
          description: AppConfig.apiUrl['walletName'],
          url: AppConfig.apiUrl['walletamazeBrowser']!,
          icons: ["https://n42.ai/static/n42.png"],
        ),
      );
      coinModelInit();
      setChainInfo();
    }catch(e){
      viewStateDeal(WalletConnectState.error,params: e.toString());
    }
  }
  Future<void> pair(String relayUrl)async{
    try{
      if(Uri.tryParse(relayUrl) !=null){
        //viewStateDeal(WalletConnectV2State.part);
        await signClient!.pair(uri:Uri.parse(relayUrl));
      }
      notifyListeners();
    }catch(e){
      viewStateDeal(WalletConnectState.error,params: e.toString());
    }
  }
  // 创建web3实例 - 使用 IWalletService 获取钱包信息
  Future<bool> web3clientInit() async {
    try {
      CoinModel cm = coinModels[coinModelsIndex];
      web3client = web3.Web3Client(cm.isTest ? cm.coin['service_test'] : cm.coin['service'], Client());
      
      // 使用 IWalletService 获取当前钱包的私钥和助记词
      final walletService = ServiceLocatorSetup.walletService;
      if (walletService == null) {
        viewStateDeal(WalletConnectState.error, params: "Wallet service not available");
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
        viewStateDeal(WalletConnectState.error, params: "Could not get private key");
        return false;
      }
      
      // 验证 base64 格式并确认解码后为 32 字节私钥
      final Uint8List decodedKey;
      try {
        decodedKey = base64Decode(pKey);
      } on FormatException catch (e) {
        viewStateDeal(WalletConnectState.error, params: 'Invalid private key encoding: ${e.message}');
        return false;
      }
      if (decodedKey.length != 32) {
        viewStateDeal(WalletConnectState.error, params: 'Invalid private key length: expected 32 bytes');
        return false;
      }
      privateKey = web3.EthPrivateKey(decodedKey);
      return true;
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
      return false;
    }
  }
  Future<bool> web3clientInitFromChainId(String eip155)async{
    String chainId=eip155.split(":")[1];
    int chainIndex=coinModels.indexWhere((element){
      String eChainId=(element.isTest?element.coin['chainId_test']:element.coin['chainId']).toString();
      if(eChainId==chainId){
        return true;
      }
      return false;
    });
    if(chainIndex==-1){
      viewStateDeal(WalletConnectState.error,params: "Error");
      return false;
    }
    if(coinModelsIndex !=chainIndex){
      setCoinModelsIndex(chainIndex);
      return await web3clientInit();
    }
    if(web3client==null){
      return await web3clientInit();
    }
    return true;
  }

  //获取ETH类的主链
  void coinModelInit({int chainId=-1}){
    try{
      List<CoinModel> cms=globalWapAdapter.coinModels;
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
      viewStateDeal(WalletConnectState.error,params: e.toString());
    }
  }
  //查找不支持的链
  CoinModel? coinModelFind(String chainId){
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

  void setChainInfo(){
    // Guard: subscribe only once per client instance.
    if (_eventsRegistered) return;
    _eventsRegistered = true;
    try{
      if(signClient !=null){
        // ── Relay client monitoring ──────────────────────────────────────────
        // Re-establish the WebSocket when the OS closed it while in background.
        try {
          signClient!.core.relayClient.onRelayClientDisconnect.subscribe((_) {
            debugPrint('[WalletConnect] Relay disconnected');
            if (dAppTopic != null) _scheduleReconnect();
          });
          signClient!.core.relayClient.onRelayClientConnect.subscribe((_) {
            debugPrint('[WalletConnect] Relay connected');
            _reconnectAttempts = 0;
            _cancelReconnectTimer();
          });
          signClient!.core.relayClient.onRelayClientError.subscribe((_) {
            debugPrint('[WalletConnect] Relay error');
          });
        } catch (e) {
          debugPrint('[WalletConnect] Relay event subscription unavailable: $e');
        }

        signClient!.onSessionProposal.subscribe((wallet_connect.SessionProposalEvent? args)async{
          if(args !=null){
            actionData=args;
            metadata=args.params.proposer.metadata;
            Map<String,wallet_connect.RequiredNamespace> optional=args.params.optionalNamespaces;
            Map<String,wallet_connect.RequiredNamespace> required=args.params.requiredNamespaces;
            List<String> chainType=optional.keys.toList();
            List<String> chainTypeRequired=required.keys.toList();
            List<String> accounts=[];
            List<String> accountsTron=[];
            List<CoinModel> rCoinModel=[];
            for(String chain in chainType){
              if(chain=="eip155"){
                if(optional[chain]!.chains==null)continue;
                for(int i=0;i<optional[chain]!.chains!.length;i++){
                  CoinModel? cm=coinModelFind(optional[chain]!.chains![i]);
                  if(cm !=null){
                    rCoinModel.add(cm);
                  }
                }
              }else if(chain=="tron"){
                if(optional[chain]!.chains==null)continue;
                for(String c in (optional[chain]!.chains!)){
                  CoinModel? cm=coinModelFind(c);
                  if(cm !=null){
                    rCoinModel.add(cm);
                  }
                }
              }
            }
            // 用 Set 预处理 optional 链 ID，将嵌套 O(n²) 查找降为 O(1)
            final optionalEip155Set = Set<String>.from(
              optional['eip155']?.chains ?? [],
            );
            final optionalTronSet = Set<String>.from(
              optional['tron']?.chains ?? [],
            );
            for(String chain in chainTypeRequired){
              if(chain=="eip155"){
                if(required[chain]!.chains==null)continue;
                for(final chainId in required[chain]!.chains!){
                  if(optional.isNotEmpty && optionalEip155Set.contains(chainId)){
                    continue;
                  }
                  CoinModel? cm=coinModelFind(chainId);
                  if(cm !=null){
                    rCoinModel.insert(0,cm);
                  }
                }
              }else if(chain=="tron"){
                if(required[chain]!.chains==null)continue;
                for(final chainId in required[chain]!.chains!){
                  if(optionalTronSet.contains(chainId)){
                    continue;
                  }
                  CoinModel? cm=coinModelFind(chainId);
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
                accountsTron.add("tron:0x2b6653dc:${coinModels[i].address.toString()}");
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
            if(accountsTron.isNotEmpty){
              namespace!['tron']=wallet_connect.Namespace(
                accounts: accountsTron,
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
            viewStateDeal(WalletConnectState.selectChain);
          }
          else{
            viewStateDeal(WalletConnectState.error,params: "Error");
          }
        });
        signClient!.onSessionRequest.subscribe((wallet_connect.SessionRequestEvent? args) async{
          if (args != null) {
            setActionDataMap(args);
          }
        });
        signClient!.onSessionDelete.subscribe((args) async{
          // Only notify when the DApp (remote peer) initiated the disconnect.
          // User-initiated disconnects are handled in [disconnectOnTap].
          if (dAppTopic != null && dAppTopic == args.topic && !_disconnectingByUser) {
            ToastUtils.show('DApp has disconnected');
            viewStateDeal(WalletConnectState.disconnect);
          }
        });
        signClient!.onSessionProposalError.subscribe((wallet_connect.SessionProposalErrorEvent? args) async{
          viewStateDeal(WalletConnectState.error,params: args?.error.message??"Error");
        });
        signClient!.onSessionConnect.subscribe((args) async{
        });
        signClient!.onSessionPing.subscribe((args) async{
        });
        signClient!.onSessionExpire.subscribe((args) async{
          // Session TTL (default 7 days) has passed; must reconnect from scratch.
          if (dAppTopic != null) {
            ToastUtils.show('Session has expired');
            viewStateDeal(WalletConnectState.disconnect);
          }
        });
        signClient!.onProposalExpire.subscribe((wallet_connect.SessionProposalEvent? args) async{
          // QR-code scan window timed out (typically 5 minutes).
          viewStateDeal(WalletConnectState.error, params: 'Connection request timed out');
        });
      }
    }catch(e){
      viewStateDeal(WalletConnectState.error,params: e.toString());
    }
  }

  Future messageSignTap() async {
    try {
      if(walletConnectState==WalletConnectState.messageSign)return;
      viewStateDeal(WalletConnectState.messageSign);
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
        privateKey.signPersonalMessageToUint8List(encodedMessage);
        signedDataHex = bytesToHex(signedData,include0x: true);
      }
      else if (eventData.method == "eth_signTypedData") {
        final requestParams =
        (eventData.params! as List).cast<String>();
        signedDataHex = _signTypedData(
          privateKey: privateKey,
          jsonData: requestParams[1],
          version: TypedDataVersion.v4,
        );
      } else if (eventData.method == "eth_signTypedData_v3") {
        final requestParams =
        (eventData.params! as List).cast<String>();
        signedDataHex = _signTypedData(
          privateKey: privateKey,
          jsonData: requestParams[1],
          version: TypedDataVersion.v3,
        );
      } else if (eventData.method == "eth_signTypedData_v4") {
        final requestParams =
        (eventData.params! as List).cast<String>();
        signedDataHex = _signTypedData(
          privateKey: privateKey,
          jsonData: requestParams[1],
          version: TypedDataVersion.v4,
        );
      } else if (eventData.method == "tron_signMessage") {
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        final CoinModel? cm = coinModels.where((c) => c.coin['coinType'] == CoinType.TRX.name).firstOrNull;
        if (cm == null) {
          viewStateDeal(WalletConnectState.error, params: 'TRON chain not supported');
          return;
        }
        
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
          privateKey.signPersonalMessageToUint8List(encodedMessage);
          signedDataHex = bytesToHex(signedData,include0x: true);
        }
      }
      signClient!.respondSessionRequest(topic: eventData.topic, response: wallet_connect.JsonRpcResponse(id: eventData.id,
        result: signedDataHex,));
      viewStateDeal(WalletConnectState.connect);
    } catch (e) {
      viewStateDeal(WalletConnectState.error,params: e.toString());
    }
  }
  Future transactionSignTap() async {
    try {
      if(walletConnectState==WalletConnectState.transaction)return;
      viewStateDeal(WalletConnectState.transaction);
      final eventData = actionData as wallet_connect.SessionRequestEvent;
      bool initOk=await web3clientInitFromChainId(eventData.chainId);
      if(initOk==false)return;
      if (eventData.method == "tron_signTransaction") {
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        final CoinModel? cm = coinModels.where((c) => c.coin['coinType'] == CoinType.TRX.name).firstOrNull;
        if (cm == null) {
          viewStateDeal(WalletConnectState.error, params: 'TRON chain not supported');
          return;
        }
        
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
        viewStateDeal(WalletConnectState.connect);
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
        from: wallet_types.EthereumAddress.fromHex(from),
        to: wallet_types.EthereumAddress.fromHex(to??"0x"),
        value: wallet_types.EtherAmount.fromBigInt(wallet_types.EtherUnit.wei, BigInt.tryParse(value??"0x") ?? BigInt.zero,),
        gasPrice: gasPrice != null
            ? wallet_types.EtherAmount.fromBigInt(
          wallet_types.EtherUnit.gwei,
          BigInt.tryParse(gasPrice) ?? BigInt.zero,
        )
            : null,
        maxFeePerGas: maxFeePerGas != null
            ? wallet_types.EtherAmount.fromBigInt(
          wallet_types.EtherUnit.gwei,
          BigInt.tryParse(maxFeePerGas) ?? BigInt.zero,
        )
            : null,
        maxPriorityFeePerGas: maxPriorityFeePerGas != null
            ? wallet_types.EtherAmount.fromBigInt(
          wallet_types.EtherUnit.gwei,
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
      viewStateDeal(WalletConnectState.connect);
    } catch (e) {
      viewStateDeal(WalletConnectState.error,params: e.toString());
    }
  }
  //取消交易或签名等
  Future<void> cancelTap(WalletConnectState state)async{
    viewStateDeal(state);
    final eventData = actionData as wallet_connect.SessionRequestEvent;
    signClient!
        .respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(id: eventData.id,
            error: wallet_connect.JsonRpcError(
                code: 4001,
                message: "User rejected."
            ))).then((value){
      viewStateDeal(WalletConnectState.connect);
    });
  }
  Future<void> disconnectOnTap() async {
    final topic = dAppTopic;
    if (topic == null) {
      // Nothing to disconnect; just reset state.
      viewStateDeal(WalletConnectState.disconnect);
      return;
    }
    _disconnectingByUser = true;
    try {
      await signClient!.disconnectSession(
        topic: topic,
        reason: wallet_connect.Errors.getSdkError(
          wallet_connect.Errors.USER_DISCONNECTED,
        ).toSignError(),
      );
    } catch (e) {
      // Session may already be gone (e.g. network drop, DApp crashed).
      // We still want to clean up local state.
      if (kDebugMode) debugPrint('[WalletConnect] Disconnect error: $e');
    } finally {
      _disconnectingByUser = false;
      viewStateDeal(WalletConnectState.disconnect);
    }
  }
  Future<void> viewStateDeal(WalletConnectState state,{dynamic params})async{
    switch(state){
      case WalletConnectState.loading:
        await connectInit();
        await pair(params as String);
        break;
      case WalletConnectState.selectChain:
        break;
      case WalletConnectState.connectOK:
        wallet_connect.SessionProposalEvent args=actionData as wallet_connect.SessionProposalEvent;
        try{
          signClient!.approveSession(id:args.id,namespaces:namespace! ).then((value)
          async{
            dAppTopic=value.topic;
            viewStateDeal(WalletConnectState.connect);
          }).catchError(( error){
            ToastUtils.show(error.toString());
            viewStateDeal(WalletConnectState.disconnect);
          });
        }catch(e){
          ToastUtils.show("Connection error:${e.toString()}");
          viewStateDeal(WalletConnectState.disconnect);
        }

        //wcClient!.approveSession(id: args!.id, namespaces: namespace!);
        break;
      case WalletConnectState.connect:
        break;
      case WalletConnectState.disconnect:
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
    // 状态未变且非 error 时跳过通知，避免不必要的 UI 重建
    if (walletConnectState == state && state != WalletConnectState.error) return;
    walletConnectState=state;
    notifyListeners();
  }
  void showAlertWidget(){
    sheetBottom(
      AppGlobals.navigatorKey.currentContext!,
      "",
      WalletConnectAlertWidget(metadata!, actionDataMap!),
    );
  }
  //清理数据
  void cleanData(){
    dAppTopic=null;
    errorMessage="";
    walletConnectState=WalletConnectState.loading;
  }
  void cleanDataLogout(){
    if(dAppTopic !=null){
      disconnectOnTap();
    }else{
      cleanData();
    }
  }

  /// Sign typed data using EIP-712 standard
  String _signTypedData({
    required web3.EthPrivateKey privateKey,
    required String jsonData,
    required TypedDataVersion version,
  }) {
    try {
      // Parse JSON data to TypedMessage
      final Map<String, dynamic> typedData = json.decode(jsonData);
      final typedMessage = TypedMessage.fromJson(typedData);

      // Hash the typed data using EIP-712
      final hash = hashTypedData(
        typedData: typedMessage,
        version: version,
      );

      // Sign the hash with private key
      final signature = privateKey.signToEcSignature(hash);

      // Encode signature to hex (r + s + v format)
      final r = signature.r.toRadixString(16).padLeft(64, '0');
      final s = signature.s.toRadixString(16).padLeft(64, '0');
      final v = (signature.v).toRadixString(16).padLeft(2, '0');

      return '0x$r$s$v';
    } catch (e) {
      debugPrint('Error signing typed data: $e');
      rethrow;
    }
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