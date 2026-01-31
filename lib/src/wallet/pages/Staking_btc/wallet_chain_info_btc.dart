import 'dart:async';
import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/api/transaction_api.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/pages/Staking_btc/redeem.dart';
import 'package:n42appv2/src/wallet/pages/Staking_btc/self_custody1.dart';
import 'package:n42appv2/src/wallet/pages/market/market_coin_info.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42appv2/src/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42appv2/src/wallet/pages/wallet_receive_qr.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/browser_address.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:crypto/crypto.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WalletChainInfoBtc extends StatefulWidget {
  final CoinModel coinModel;
  const WalletChainInfoBtc(this.coinModel,{super.key});

  @override
  State<WalletChainInfoBtc> createState() => _WalletChainInfoBtcState();
}

class _WalletChainInfoBtcState extends State<WalletChainInfoBtc> {
  AppDatabase? _db;
  AppDatabase get db{
    _db ??= AppDatabase();
    return _db!;
  }
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
  late WebViewController _controller;
  int txListIndex=1;
  String chainName = "";
  String chainSymbol = "";
  String? tokenName;
  String? tokenSymbol;
  CoinModel? chainCoinModel;
  Map<String, dynamic>? marketInfo;
  String browserUrl = "";
  ScrollController scrollController = ScrollController();
  Load load = Load.finish;
  int pageSize = 10;
  int page = 1;
  bool lastPage = false;
  List<dynamic> transactionList = [];
  StreamSubscription? eventBusFn;

  @override
  void initState() {
    super.initState();
    initWebView();
    initData();
    scrollController.addListener(() {
      var maxScroll = scrollController.position.maxScrollExtent;
      var pixel = scrollController.position.pixels;
      if (pixel > maxScroll - 200) {
        getTransactionData(Load.nextPage);
        getTransactionDataNetwork(Load.nextPage);
      }
    });
    eventBusFn = eventBus.on().listen((event) async {
      if (event is EventPublic && event.type == EventPublicType.transferOk) {
        getTransactionData(Load.refresh);
        getTransactionDataNetwork(Load.refresh);
        await widget.coinModel.getBalance();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    eventBusFn?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> initData() async{
    //createWallet();
    chainName = widget.coinModel.coin['name'];
    chainSymbol = widget.coinModel.coin['miniName'];
    browserUrl = getBrowserAddress(
        widget.coinModel.coin['coinType'], widget.coinModel.address,
        isTest: widget.coinModel.isTest);
    marketInfo = Provider.of<WalletActionProvider>(context,listen: false)
        .getCoinPriceWithUnitAll(widget.coinModel.coin['unit']);
    getTransactionData(Load.refresh);
    getTransactionDataNetwork(Load.refresh);
    await getBalance();
    /*if(widget.coinModel.balance !=0){
      getUTXO();
    }
    p2wsh();*/
  }
  void initWebView(){
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
      ..setBackgroundColor(const Color(0x00000000))
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
      // BTC Staking Redeem URL - requires HTTPS in production
      ..loadRequest(Uri.parse('https://api.n42.ai/btc-staking/redeem?walletAddress=${widget.coinModel.address}'))
      ..addJavaScriptChannel("N42APP", onMessageReceived: (JavaScriptMessage message) async{
        Map<String,dynamic>?rdata=jsonDecode(message.message);
        if(rdata !=null){
          if(rdata['type']=="get_canister_ecdsa_public_key"){

            _controller.runJavaScript('is_p2wsh_address_valid("");');
          }else if(rdata['type']=="is_p2wsh_address_valid"){

          }else if(rdata['type']=="request_mint_vbtc"){
            _controller.runJavaScript('alert("来自Flutter的消息，我收到了:${rdata['result']}");');
          }
        }

      });
  }
  void createWallet(){
    final privateKey =
    ECPrivate.fromWif("cVbQm3SVhN3sHD2mhbucpyz99mH6WNRcAKhzur3SP5hX4Ca53m15", netVersion: BitcoinNetwork.testnet.wifNetVer);
    final publicKey = privateKey.getPublic();

    // 3️⃣ 生成比特币地址（P2PKH）
    final address = publicKey.toSegwitAddress();
    debugPrint(address.toAddress(BitcoinNetwork.testnet));
  }
  //获取余额
  Future<void> getBalance()async{
    try{
      bool isOk=await widget.coinModel.getBalance();
      if(isOk==false){
        load=Load.finish;
        setState(() {});
        return;
      }
    } catch (_) {
      // 错误安全忽略
    } finally {
      load=Load.finish;
      setState(() {});
    }
  }
  /*Load utxoLoad=Load.finish;//加载utxo
  BigInt aBalance=BigInt.zero;//可用余额
  String get ABalance{
    double b=toEther(aBalance.toString(), widget.coinModel.coin['decimals']??0).toDouble();
    return "${b}";
  }
  String get ABalancePrice{
    if(aBalance==BigInt.zero){
      return"0";
    }
    double b=toEther(aBalance.toString(), widget.coinModel.coin['decimals']??0).toDouble();
    return _oCcy.format(b*widget.coinModel.coinPrice);
  }
  BigInt lBalance=BigInt.zero;//锁定余额
  String get LBalance{
    double b=toEther(lBalance.toString(), widget.coinModel.coin['decimals']??0).toDouble();
    return "${b}";
  }
  String get LBalancePrice{
    if(lBalance==BigInt.zero){
      return"0";
    }
    double b=toEther(lBalance.toString(), widget.coinModel.coin['decimals']??0).toDouble();
    return _oCcy.format(b*widget.coinModel.coinPrice);
  }
  List<dynamic> unspents=[];//可用余额列表
  //获取 账簿
  getUTXO()async{
    try{
      if(utxoLoad==Load.loading)return;
      utxoLoad=Load.loading;
      setState(() {});
      String utxoPath=widget.coinModel.address;
      MessageModel mm=await BtcApi().getUtxos(utxoPath);
      if(mm.error){
        //errorMessage=mm.data;
        //ToastUtils.show(errorMessage);
      }else{
        initAvailableBalance(mm.data);
      }
    }catch(e){
      utxoLoad=Load.finish;
      setState(() {});
    }
  }
  //计算可用余额
  initAvailableBalance(List<dynamic> data)async{
    for(Map<String,dynamic> unspent in data){
      /*{
        "txid": "bdb56a54acb823b51eee657f74636ec78db8137322b967ad1ce26bfacc740298",
        "vout": 0,
        "status": {
            "confirmed": true,
            "block_height": 859951,
            "block_hash": "000000000000000000028fa21bd878f4dfe2d2a2444b77f43ac7d930867f138a",
            "block_time": 1725515308
        },
        "value": 10000
    },*/
      BigInt value = BigInt.from(unspent["value"]);
      Map<String,dynamic>? status = unspent["status"];
      bool confirmed = status?["confirmed"];
      if (confirmed) {
        aBalance += value;
        unspents.add(unspent);
      } else {
        lBalance += value;
      }
    }
    setState(() {
      utxoLoad=Load.finish;
    });
  }
*/
  Future<void> getTransactionData(Load loadType) async {
    if (load == Load.finish) {
      if (loadType == Load.nextPage) {
        if (lastPage) return;
      }
      if (loadType == Load.refresh) {
        page = 1;
      } else {
        page += 1;
      }
      load = loadType;
      String addr = widget.coinModel.address.toString();
      String coinKey = widget.coinModel.coin['coinType'];
      String contract = widget.coinModel.coin['contract'];
      List<dynamic>? txList;
      if (widget.coinModel.coin['blockchainType'] ==
          BlockchainType.Bitcoin.name) {
        txList = await db
            .selectBtcTransationRecord(
            AppGlobals.userInfo?.uuid ?? "", addr, coinKey, 0,
            pageSize: pageSize, pageNum: page);
      } else {
        txList = await db
            .selectTransationRecordMiniName(addr, coinKey, 0,
            contract: contract,
            pageSize: pageSize,
            pageNum: page,
            isTest: widget.coinModel.isTest ? 1 : 0);
      }
      if (loadType == Load.refresh) {
        transactionList = txList;
      } else {
        transactionList.add(txList);
      }
      if (txList.length < pageSize) {
        lastPage = true;
      }
      setState(() {
        load = Load.finish;
      });
    }
  }

  Future<void> getTransactionDataNetwork(Load loadType)async{
    String addr = widget.coinModel.address.toString();
    String coinKey = widget.coinModel.coin['coinType'];
    String contract = widget.coinModel.coin['contract'];
    //List<CommonResponseItemModel>? cril;
    MessageModel mm;
    if(contract==""){
      mm=await TransactionApi().getTransactionList(coinKey, addr,isTest: widget.coinModel.isTest);
    }else{
      mm=await TransactionApi().getContractTransactionList(coinKey, addr, contract,isTest: widget.coinModel.isTest);
    }
    if(mm.error==false){
      //cril=mm.data;
      if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Bitcoin.name){
        getTransactionDataNetworkBtc(mm.data);
      }
    }
  }
  Future<void> getTransactionDataNetworkBtc(List<BtcTranDetail>? cril)async{
    if(cril !=null){
      bool isEdit=false;
      for(int i=cril.length-1;i>=0;i--){
        BtcTranDetail cri=cril[i];
        List<BtcTransactionRecodeModel> rtrm=await db.selectBtcTransationRecordTxHash(cri.hash);
        if (!mounted) return;
        if(rtrm.isEmpty){
          BtcTransactionRecodeModel transationRecordModel=BtcTransactionRecodeModel();
          transationRecordModel.addrType=widget.coinModel.addrType;
          transationRecordModel.coin=widget.coinModel.coin;
          transationRecordModel.address=widget.coinModel.address??"";
          transationRecordModel.price=cri.total;
          transationRecordModel.gasPrice=cri.fees;
          transationRecordModel.to1="";
          transationRecordModel.walletIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
          //transationRecordModel.nonce="0";
          transationRecordModel.txHash=cri.hash;
          //transationRecordModel.gasPrice=BigInt.parse(cri.gasPrice??"0");
          //transationRecordModel.gas=int.parse(cri.gas??"0");
          transationRecordModel.txTime=(DateTime.parse(cri.confirmed??"").millisecondsSinceEpoch~/1000).toString();
          transationRecordModel.state=cri.confirmations>=6?1:0;//int.parse(cri.txreceipt_status??"0");
          transationRecordModel.coinMiniName=widget.coinModel.coin['coinType'];
          transationRecordModel.isTest=widget.coinModel.isTest?1:0;
          bool isIn=false;//是否是转入
          if(cri.inputs!=null){
            transationRecordModel.inputModels=[];
            for(Input input in cri.inputs!){
              InputModel im=InputModel();
              im.vout=input.outputValue;
              im.txid=input.prevHash;
              im.script=input.script??"";
              im.address=input.addresses;
              int aIndex=im.address.indexWhere((e){
                if(e.toUpperCase()==transationRecordModel.address.toUpperCase()){
                  return true;
                }
                return false;
              });
              if(aIndex==-1){
                isIn=true;
              }
              transationRecordModel.inputModels!.add(im);
            }
          }
          if(cri.outputs!=null){
            transationRecordModel.outputModels=[];
            int outputPrice=0;
            for(Output output in cri.outputs!){
              OutputModel om=OutputModel();
              om.price=output.value;
              om.script=output.script??"";
              om.address=output.addresses??[];
              int aIndex=om.address.indexWhere((e){
                if(e.toUpperCase()==transationRecordModel.address.toUpperCase()){
                  return true;
                }
                return false;
              });
              if(isIn){
                if(aIndex !=-1){
                  outputPrice+=output.value;
                }
              }else{
                if(aIndex ==-1){
                  outputPrice+=output.value;
                }
              }
              transationRecordModel.outputModels!.add(om);
            }
            transationRecordModel.price=outputPrice;
          }
          //transationRecordModel.input

          await db.insertBtcTransactionRecord(transationRecordModel);
          isEdit=true;
          //getTxInfo_network(transationRecordModel);
        }
        else{
          BtcTransactionRecodeModel transationRecordModel=rtrm[0];
          String cDate=(DateTime.parse(cri.confirmed??"").millisecondsSinceEpoch~/1000).toString();
          if(transationRecordModel.inputsAddressList.isEmpty){
            if(cri.inputs!=null){
              transationRecordModel.inputModels=[];
              for(Input input in cri.inputs!){
                InputModel im=InputModel();
                im.vout=input.outputValue;
                im.txid=input.prevHash;
                im.script=input.script??"";
                im.address=input.addresses;
                transationRecordModel.inputModels!.add(im);
              }
            }
            if(cri.outputs!=null){
              transationRecordModel.outputModels=[];
              for(Output output in cri.outputs!){
                OutputModel om=OutputModel();
                om.price=output.value;
                om.script=output.script??"";
                om.address=output.addresses??[];
                transationRecordModel.outputModels!.add(om);
              }
            }
            transationRecordModel.txTime=cDate;
            await db.updateBtcTransactionRecord(transationRecordModel);
            isEdit=true;
          }
          if(transationRecordModel.txTime != cDate){
            transationRecordModel.txTime=cDate;
            /*if(transationRecordModel.state!=1){
            transationRecordModel.state=int.parse(cri.txreceipt_status??"0");
          }*/
            await db.updateBtcTransactionRecord(transationRecordModel);
            isEdit=true;
          }
        }
      }
      if(isEdit){
        getTransactionData(Load.refresh);
      }
    }
  }

  Future<void> getTxInfoNetworkBtc(BtcTransactionRecodeModel transationRecordModel)async{
    BtcTransactionRecodeModel rtrm=await Provider.of<TransactionRecordItemProvider>(context,listen: false).checkUndoneTrBtcReturn(transationRecordModel) ?? transationRecordModel;
    transactionList.firstWhere((element){
      TransationRecordModel trm=element as TransationRecordModel;
      if(trm.txHash==rtrm.txHash){
        trm.state=rtrm.state;
        return true;
      }
      return false;
    });
    setState(() {});
  }


  void p2wsh() async{
    // 示例：用户公钥和 Canister 公钥
    final userPubKey = Uint8List.fromList(hexToBytes('02a50eb66887d03fe186b608f477d99bc7631f56e34e3a4843565c55f1aa0c043a'));
    final canisterPubKey = Uint8List.fromList(hexToBytes('03b4af8d061b6b320cce6c63bc4ec7894dce107b48a097a3a6d835c16b2b17c0c7'));

    // 质押时间（区块高度）
    final lockTime = 800000;

    // 构建锁定脚本
    final redeemScript = buildRedeemScript(userPubKey, canisterPubKey, lockTime);
    final scriptHash = sha256a(redeemScript);

    // 生成 P2WSH 地址
    final p2wshAddress = createP2WSHAddress(scriptHash);
    debugPrint("p2wsh:$p2wshAddress:${p2wshAddress.length}");
  }
  /// 构建锁定脚本
  Uint8List buildRedeemScript(Uint8List userPubKey, Uint8List canisterPubKey, int lockTime) {
    List<int> script1=[0x63];
    script1.addAll(encodeNumber(lockTime).toList());
    script1.addAll([0xb1, 0x75]);
    script1.addAll(userPubKey.toList());
    script1.addAll([0xac]);
    script1.addAll([0x67]);
    script1.addAll(canisterPubKey.toList());
    script1.addAll([0xac]);
    script1.addAll([0x68]);

    return Uint8List.fromList(script1);
  }

  /// 将数字编码为比特币脚本格式
  Uint8List encodeNumber(int number) {
    if (number == 0) {
      return Uint8List.fromList([0x00]);
    }
    final bytes = Uint8List(8);
    var value = number;
    var length = 0;
    while (value != 0) {
      bytes[length] = value & 0xff;
      value >>= 8;
      length++;
    }
    return bytes.sublist(0, length);
  }
  /// 计算 SHA-256 哈希
  Uint8List sha256a(Uint8List data) {
    final hash = sha256.convert(data);
    return Uint8List.fromList(hash.bytes);
  }
  /// 生成 P2WSH 地址
  String createP2WSHAddress(Uint8List scriptHash) {
    // 生成 P2WSH 地址
    final p2wshAddress = bech32Encode('bc', scriptHash);
    debugPrint('P2WSH Address: $p2wshAddress');
    return p2wshAddress;
  }
  /// Bech32 字符集
  final String _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

  /// Bech32 编码
  String bech32Encode(String hrp, Uint8List data) {
    // 1. 将 HRP 转换为小写
    hrp = hrp.toLowerCase();

    // 2. 将数据部分转换为 5 位一组
    final converted = _convertBits(data, 8, 5, true);

    // 3. 计算校验和
    final checksum = _createChecksum(hrp, converted);

    // 4. 组合 HRP、数据和校验和
    final combined = Uint8List(converted.length + checksum.length)
      ..setAll(0, converted)
      ..setAll(converted.length, checksum);

    // 5. 将数据编码为 Bech32 字符串
    final bech32 = StringBuffer('${hrp}1');
    for (final value in combined) {
      bech32.write(_charset[value]);
    }

    return bech32.toString();
  }

  /// 将数据从 fromBits 转换为 toBits
  Uint8List _convertBits(Uint8List data, int fromBits, int toBits, bool pad) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];
    final maxv = (1 << toBits) - 1;

    for (var i = 0; i < data.length; i++) {
      acc = (acc << fromBits) | data[i];
      bits += fromBits;
      while (bits >= toBits) {
        bits -= toBits;
        result.add((acc >> bits) & maxv);
      }
    }

    if (pad && bits > 0) {
      result.add((acc << (toBits - bits)) & maxv);
    }

    return Uint8List.fromList(result);
  }

  /// 创建校验和
  Uint8List _createChecksum(String hrp, Uint8List data) {
    final values = _hrpExpand(hrp) + data.toList();
    final polymod = _polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1;
    final checksum = <int>[];
    for (var i = 0; i < 6; i++) {
      checksum.add((polymod >> 5 * (5 - i)) & 31);
    }
    return Uint8List.fromList(checksum);
  }

  /// 扩展 HRP
  List<int> _hrpExpand(String hrp) {
    final result = <int>[];
    for (var i = 0; i < hrp.length; i++) {
      result.add(hrp.codeUnitAt(i) >> 5);
    }
    result.add(0);
    for (var i = 0; i < hrp.length; i++) {
      result.add(hrp.codeUnitAt(i) & 31);
    }
    return result;
  }

  /// 计算 polymod
  int _polymod(List<int> values) {
    const generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];
    var chk = 1;
    for (final value in values) {
      final top = chk >> 25;
      chk = (chk & 0x1ffffff) << 5 ^ value;
      for (var i = 0; i < 5; i++) {
        if ((top >> i) & 1 == 1) {
          chk ^= generator[i];
        }
      }
    }
    return chk;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$chainSymbol ($chainName)",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32.0),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if(tokenSymbol!=null)
              Text(
                "$tokenSymbol($tokenName)",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          if(widget.coinModel.coin['coinType'] == CoinType.N.name || widget.coinModel.coin['coinType'] == CoinType.BTC.name)
            InkWell(
              onTap: () async {
                showtestAndMainnetWidget();
              },
              child: SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                //padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
                child: Image.asset(
                  "assets/wallet/${widget.coinModel.isTest ? "testnet" : "mainnet"}.png",
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          InkWell(
            onTap: (){
              if (marketInfo != null) {
                if(marketInfo!["coin_gecko_id"]=="")return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MarketCoinInfo(marketInfo ?? {})));
              }
            },
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(right:ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(20.0),),
              child: Image.asset(
                'assets/wallet/marketInfo.png',
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child:Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  getTransactionData(Load.refresh);
                  getTransactionDataNetwork(Load.refresh);
                  await widget.coinModel.getBalance();
                },
                backgroundColor: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor.name),
                color:
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                displacement: ScreenUtil().setWidth(72.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    /*
                    WalletChainInfoBoard(
                      address: widget.coinModel.address,
                      balanceStr:
                      '${widget.coinModel.balanceStringAll()}${widget.coinModel.coin['unit'].toString().toUpperCase()}',
                      balanceDollarStr: '\$${widget.coinModel.valueString()}',
                      marketValueStr:
                      '\$${widget.coinModel.coinPriceString()}',
                      sendTap: () async {
                        WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
                        if(wap.walletInfo.password==""){
                          final flag= await tipsDialog7(context);
                          if (flag != null && flag) {
                            Navigator.push(context, MaterialPageRoute(
                                settings: RouteSettings(
                                  name: 'BackupOne',
                                ),
                                builder: (context)=>BackupOne(wap.walletInfo,wap.walletIndex)));
                          }
                          return;
                        }
                        if (widget.coinModel.coin['blockchainType'] ==
                            BlockchainType.Bitcoin.name) {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WalletChainSendBtc(widget.coinModel),
                              ));
                        } else if(widget.coinModel.coin['blockchainType']==BlockchainType.Solana.name){
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WalletChainSendSol(widget.coinModel),
                              ));
                        }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Tron.name){
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WalletChainSendTrx(widget.coinModel),
                              ));
                        }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Algorand.name){
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WalletChainSendAlgo(widget.coinModel),
                              ));
                        }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Ripple.name){
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WalletChainSendXrp(widget.coinModel),
                              ));
                        }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Filecoin.name){
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WalletChainSendFil(widget.coinModel),
                              ));
                        }else {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WalletChainSend(widget.coinModel),
                              ));
                        }
                        getTransactionData(Load.refresh);
                      },
                      receiveTap: () async{
                        WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
                        if(wap.walletInfo.password==""){
                          final flag= await tipsDialog7(context);
                          if (flag != null && flag) {
                            Navigator.push(context, MaterialPageRoute(
                                settings: RouteSettings(
                                  name: 'BackupOne',
                                ),
                                builder: (context)=>BackupOne(wap.walletInfo,wap.walletIndex)));
                          }
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WalletReceiveQr(
                              chainCoinModel == null
                                  ? widget.coinModel
                                  : chainCoinModel!,
                              tokenCoinModel: chainCoinModel == null
                                  ? null
                                  : widget.coinModel,
                            ),
                          ),
                        );
                      },
                      browserTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BrowserPage(
                                  browserUrl,
                                  //S.of(context).g_key_m_15
                                )));
                      },
                      tokenAddTap: (widget.coinModel.privateKey == null ||
                          widget.coinModel.coin['blockchainType'] ==
                              BlockchainType.Bitcoin.name ||
                          widget.coinModel.coin['isContract'] == true)
                          ? null
                          : () async {
                        bool r = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalletCoinTokenAdd2(
                                  widget.coinModel,)));
                        if (r) {
                          Provider.of<WalletActionProvider>(context).initWallet(shouldInitCoinInfo: true);
                          Navigator.pop(context);
                        }
                      },
                    ),
                    */
                    chainInfoBoard(),
                    Divider(
                      height: ScreenUtil().setWidth(1),
                      endIndent: 0,
                      indent: 0,
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20.0),),
                      margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(30.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: (){
                                if(txListIndex==0)return;
                                setState(() {
                                  txListIndex=0;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  S.of(context).g_coin_key_1,
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(
                                        context, txListIndex==0?AppThemeKeys.mainBlueColor.name:AppThemeKeys.mainTextColor.name),
                                    fontSize: ScreenUtil().setSp(30.0),
                                    fontWeight: txListIndex==0?FontWeight.bold:null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: (){
                                if(txListIndex==1)return;
                                setState(() {
                                  txListIndex=1;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "Self-Custody List",
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(
                                        context, txListIndex==1?AppThemeKeys.mainBlueColor.name:AppThemeKeys.mainTextColor.name),
                                    fontSize: ScreenUtil().setSp(30.0),
                                    fontWeight: txListIndex==1?FontWeight.bold:null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ),
                    transactionsWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
  Widget chainInfoBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0),),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.coinModel.address,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: (){
                  ToastUtils.init(context);
                  Clipboard.setData(ClipboardData(text: widget.coinModel.address));
                  ToastUtils.showFtToast(child:successViewV1(S.of(context).copy),duration: 3);
                },
                child: Container(
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                  width: ScreenUtil().setWidth(60.0),
                  height: ScreenUtil().setWidth(60.0),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                  child: Icon(
                    Icons.copy,
                    size: ScreenUtil().setWidth(36.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Available',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Text(
            '${widget.coinModel.balanceDoubleAll()}${widget.coinModel.coin['unit'].toString().toUpperCase()}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(40.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
            maxLines: 2,
          ),
          /*Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0)),
            child: Text(
              '\$${widget.coinModel.coinPriceString()}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 2,
            ),
          ),*/
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0),bottom: ScreenUtil().setWidth(20.0)),
            child: Text(
              '≈ \$${widget.coinModel.coinPriceString()}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 2,
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(40.0),
            indent: 0,
            endIndent: 0,
          ),
          Text(
            'Self-custody',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Text(
            '${0}${widget.coinModel.coin['unit'].toString().toUpperCase()}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(40.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
            maxLines: 2,
          ),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0),bottom: ScreenUtil().setWidth(20.0)),
            child: Text(
              '≈ \$${0}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 2,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0),
                ),
                height: ScreenUtil().setWidth(80.0),
                child:
                buttonStyle3(
                  context,
                      (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SelfCustody1(widget.coinModel)));
                      },
                  "Self-Custody",
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  borderRadius:ScreenUtil().setWidth(16.0),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0),
                ),
                height: ScreenUtil().setWidth(80.0),
                child: buttonStyle3(
                  context,
                      (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Redeem(widget.coinModel)));
                      },
                  "Redeem",
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  borderRadius:ScreenUtil().setWidth(16.0),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(40.0),),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ScreenUtil().setWidth(80),
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
                alignment: Alignment.center,
                child: buttonStyle3(
                  context,
                      ()async {
                    WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
                    if(wap.walletInfo.password==""){
                      final flag= await tipsDialog7(context);
                      if (!mounted) return;
                      if (flag != null && flag) {
                        Navigator.push(context, MaterialPageRoute(
                            settings: RouteSettings(
                              name: 'BackupOne',
                            ),
                            builder: (context)=>BackupOne(wap.walletInfo,wap.walletIndex)));
                      }
                      return;
                    }
                    if (widget.coinModel.coin['blockchainType'] ==
                        BlockchainType.Bitcoin.name) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WalletChainSendBtc(widget.coinModel),
                          ));
                      getTransactionData(Load.refresh);
                    }
                  },
                  S.of(context).g_key_48,
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                  borderRadius:ScreenUtil().setWidth(16.0),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
              Container(
                height: ScreenUtil().setWidth(80),
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
                alignment: Alignment.center,
                child: buttonStyle3(
                  context,
                      () async{
                    WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
                    if(wap.walletInfo.password==""){
                      final flag= await tipsDialog7(context);
                      if (!mounted) return;
                      if (flag != null && flag) {
                        Navigator.push(context, MaterialPageRoute(
                            settings: RouteSettings(
                              name: 'BackupOne',
                            ),
                            builder: (context)=>BackupOne(wap.walletInfo,wap.walletIndex)));
                      }
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalletReceiveQr(
                          chainCoinModel == null
                              ? widget.coinModel
                              : chainCoinModel!,
                          tokenCoinModel: chainCoinModel == null
                              ? null
                              : widget.coinModel,
                        ),
                      ),
                    );
                  },
                  S.of(context).g_key_33,
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                  borderRadius:ScreenUtil().setWidth(16.0),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
              Container(
                height: ScreenUtil().setWidth(80),
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
                alignment: Alignment.center,
                child: buttonStyle3(
                  context,
                      () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BrowserPage(
                              browserUrl,
                              //S.of(context).g_key_m_15
                            )));
                  },
                  S.of(context).g_key_196,
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                  borderRadius:ScreenUtil().setWidth(16.0),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget transactionsWidget() {
    if(txListIndex==0){
      if (transactionList.isEmpty) {
        //IntrinsicHeight: Dynamically calculated height
        return const IntrinsicHeight(
          child: Center(
            child: EmptyView(),
          ),
        );
      }
      int itemCount=transactionList.length;
      if(widget.coinModel.coin['coinType']==CoinType.N.name){
        if(itemCount==10){
          itemCount++;
        }
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        itemCount: transactionList.length+1,
        itemBuilder: (context, int index) {

          if(transactionList.length==index){
            return InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionHistoryList(widget.coinModel)));
              },
              child: Container(
                height: ScreenUtil().setWidth(80.0),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  S.of(context).g_mining_key_49,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            );
          }
          if (widget.coinModel.coin['blockchainType'] ==
              BlockchainType.Bitcoin.name) {
            BtcTransactionRecodeModel trm = transactionList[index];
            return WalletChainInfoTransactionsItem(
                coinModel: widget.coinModel, type: 0, transactionModel: trm, onBack: (){
                  getTransactionData(Load.refresh);
                });
          } else {
            TransationRecordModel trm = transactionList[index];
            return WalletChainInfoTransactionsItem(
              type: 1, transactionModel: trm,coinModel: widget.coinModel,onBack: (){
              getTransactionData(Load.refresh);
            },);
          }

        },
      );
    }else{
      return Container(
        width: double.infinity,
        height: ScreenUtil().setWidth(2000.0),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        child: WebViewWidget(
          controller: _controller,
          gestureRecognizers: {},
        ),
      );
    }
  }

  //显示切换主网和测试网的弹层
  void showtestAndMainnetWidget() {
    List<Widget> childs = [];
    bool isTest = widget.coinModel.isTest;
    Color mainColor =
    AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name);
    Color testColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    if (isTest) {
      testColor =
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
      mainColor = AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemSubtitleTextColor.name);
    }
    childs.add(InkWell(
      onTap: () {
        if (isTest == false) {
          Navigator.pop(context);
          return;
        }
        changeNet(
          false,
          Load.refresh,
        );
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                child: Image.asset(
                  'assets/wallet/mainnet.png',
                  color: mainColor,
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20.0),
              ),
              Text(
                S.of(context).g_key_148,
                style: TextStyle(
                  color: mainColor,
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          )),
    ));
    childs.add(InkWell(
      onTap: () {
        if (isTest) {
          Navigator.pop(context);
          return;
        }
        changeNet(true, Load.refresh);
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                child: Image.asset(
                  'assets/wallet/testnet.png',
                  color: testColor,
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20.0),
              ),
              Text(
                S.of(context).g_key_147,
                style: TextStyle(
                  color: testColor,
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          )),
    ));
    sheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
  //切换网络，测试网络还是主网
  Future<void> changeNet(bool isTest, Load loadType) async {
    try {
      WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
      wap.walletMap[widget.coinModel.coin['coinType']]['isTest'] = isTest;
      widget.coinModel.isTest = isTest;
      await wap.saveWalletInfo(wap.walletInfo, wap.walletIndex);
      await widget.coinModel.getBalance();
      widget.coinModel.address=null;
      await widget.coinModel.buildWallet();
      await widget.coinModel.getBalance();
      setState(() {});
      initData();
    } catch (e) {
      ToastUtils.show(e.toString());
    }
  }
}
