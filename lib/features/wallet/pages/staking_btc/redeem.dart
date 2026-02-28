// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/redeem_token.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:n42_wallet/core/utils/js_escape_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Redeem extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const Redeem(this.coinModel,{super.key});

  @override
  ConsumerState<Redeem> createState() => _RedeemState();
}

class _RedeemState extends ConsumerState<Redeem> {
  late WebViewController _controller;

  /// WebView 触发赎回时记录的锁定到期时间戳（Unix 秒）
  /// null 表示尚未收到赎回请求
  int? _lockTimeUnix;

  /// 是否显示顶部状态横幅（用户可关闭）
  bool _showBanner = true;

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
      ..setBackgroundColor(const Color(0xFF121212))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('${AppConfig.getApiUrlOnline('btcStaking')}/redeem?walletAddress=${widget.coinModel.address}'))
      ..addJavaScriptChannel("N42APP", onMessageReceived: (JavaScriptMessage message) async{
        Map<String,dynamic>?rdata=jsonDecode(message.message);
        if(rdata !=null){
          if(rdata['type']=="redeem"){
            final int lockTime = (rdata['lock_time'] as num).toInt();
            // 记录锁定时间以便 UI 展示状态
            if (mounted) setState(() => _lockTimeUnix = lockTime);
            String signStr=await redeem(rdata['p2wsh_address'], lockTime);
            _controller.runJavaScript('request_withdraw_vbtc("${JsEscapeUtils.escapeJs(rdata['p2wsh_address']?.toString() ?? "")}","${JsEscapeUtils.escapeJs(signStr)}");');
          }else if(rdata['type']=="request_withdraw_vbtc"){
            _controller.runJavaScript('alert("来自Flutter的消息，我收到了:${JsEscapeUtils.escapeJs(rdata['result']?.toString() ?? "")}");');
          }
        }
      });
    super.initState();
  }
  int gasFeeRate=4;
  int gasFees=0;
  int input2Price=0;//实际输入金额
  bool inputValueOK=false;
  List<Map<String,dynamic>> inputUTXO=[];
  Future<String> redeem(String address,int lockTime)async{
    await getGasFeeBtc();
    await getUTXO(address);
    String witnessScriptValue=await createP2WSH(lockTime);
    inputUTXO[0]['witnessValue']=witnessScriptValue;
    inputUTXO[0]['lockTime']=lockTime;
    return await signP2WSH();
  }
  Future<void> redeemEth(String p2wshAddress)async{
    String serviceUrl=RequestUrl().getUrl2(CoinType.ETH.name, 'rpc',isTest: widget.coinModel.isTest);
    String privateKey;
    if(widget.coinModel.privateKey==null || widget.coinModel.privateKey==""){
      String pk=await Trustdart().getPrivateKey(ref.read(wapBridgeProvider).walletInfo.mnemonic??"", CoinType.ETH.name, "m/44'/60'/0'/0/0");
      privateKey=bytesToHex(base64Decode(pk));
    }else{
      privateKey=bytesToHex(base64Decode(widget.coinModel.privateKey??""));
    }
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    if (kDebugMode) debugPrint(credentials.address.eip55With0x);
    RedeemToken rt=RedeemToken.init(address: EthereumAddress.fromHex("0x6c30A50430cC615C4659DF2dBe3E42036583bE7E"), client: Web3Client(serviceUrl, Client()),chainId: 11155111);
    final rData=await rt.reedem(p2wshAddress,credentials: credentials);
    if (kDebugMode) debugPrint(rData);
  }
  Future<String> createP2WSH(int lockTime,{String? uPubKey,String? cPubKey})async{
    if(uPubKey==null){
      String pubKey=await Trustdart().getPublicKey(CoinType.BTC.name, "m/84'/4'/0'/0/0",mnemonic: ref.read(wapBridgeProvider).walletInfo.mnemonic??"",pk: ref.read(wapBridgeProvider).walletInfo.privateKey??"");
      uPubKey=bytesToHex(base64Decode(pubKey));
    }
    cPubKey ??= '02a075b5988699e95802fe94590908de9370588cacc750d6f538d76fe6e9b8d6ad';
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
    return newScript.toHex();
  }
  Future<void> getGasFeeBtc()async{
    MessageModel gasFeeMM=await tokenViewApi.getGasFeeBtc(isTest: widget.coinModel.isTest);
    if(gasFeeMM.error){
      debugPrint('getGasFeeBtc error: ${gasFeeMM.data}');
    }else{
      gasFeeRate=gasFeeMM.data;
    }
    if (mounted) setState(() {});
  }
  Future<String> signP2WSH()async{
    Map<String,dynamic> btcTxMap={
      "utxo":inputUTXO,
      "toAddress":widget.coinModel.address,
      "amount":99500,
      "byteFee":gasFeeRate, // 使用动态 gas 费率，不再硬编码为 1
      "changeAddress":widget.coinModel.address,
      "change":0,
      "max":true
    };
    if (kDebugMode) debugPrint(json.encode(btcTxMap));
    return await Trustdart().signTransactionBtcP2wsh(CoinType.BTC.name, "m/84'/4'/0'/0/0", btcTxMap,pk: ref.read(wapBridgeProvider).walletInfo.privateKey??"");
  }
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
        btcTransactionRecodeModel.inputModels!.add(im);
      }
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
      return btcTransactionRecodeModel;
    }catch(e){
      return btcTransactionRecodeModel;
    }
  }
  Future<int> getSignByteSize(List<Map<String,dynamic>> utxos,{bool max=true})async{
    Map<String,dynamic> btcTxMap={
      "utxo":utxos,
      "toAddress":widget.coinModel.address,
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
  Future<void> getUTXO(String address)async{
    try{
      MessageModel mm=await tokenViewApi.getUTXOBtc(widget.coinModel.coin['coinType'], address,pageSize: 1,pageNum: 10,isTest: widget.coinModel.isTest);
      if(mm.error){
        ToastUtils.show(mm.data);
        if (mounted) setState(() {});
      }else{
        await calculateGasFee(mm.data);
      }
    }catch(e){
      ToastUtils.show(e.toString());
      if (mounted) setState(() {});
    }
  }
  Future<void> calculateGasFee(List<dynamic> unspents)async{
    List<Map<String,dynamic>> utxos=[];
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
          "vout":unspent['output_no'],
          "value": amount.toString(),
          "script": unspent['hex'],
        });
      }
      int byteSize=338;
      if(byteSize !=0){
        gasFees=byteSize*gasFeeRate;
        inputValueOK=true;
        break;
      }
    }
    inputUTXO=utxos;
    if (mounted) setState(() {});
  }
  Future<void> initEthToken(String p2wshAddr)async{
    Web3Client client = Web3Client("https://eth-sepolia.public.blastapi.io", Client());
    RedeemToken token = RedeemToken.init(
        address: EthereumAddress.fromHex("0x6c30A50430cC615C4659DF2dBe3E42036583bE7E"), client: client);
    WalletInfo walletInfo=ref.read(wapBridgeProvider).walletInfo;
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
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_btc_redeem_title),
      body: Column(
        children: [
          // ── 顶部锁定状态 / 提醒横幅 ──────────────────────────
          if (_showBanner) _buildStatusBanner(context, s),

          // ── WebView 填充剩余空间 ──────────────────────────────
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, S s) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final bool isUnlocked = _lockTimeUnix != null && _lockTimeUnix! <= now;
    final bool isStillLocked = _lockTimeUnix != null && _lockTimeUnix! > now;

    // 决定横幅颜色与内容
    final Color bgColor;
    final Color iconColor;
    final IconData bannerIcon;
    final String bannerText;

    if (isUnlocked) {
      bgColor = Colors.green.withAlpha(30);
      iconColor = Colors.green;
      bannerIcon = Icons.lock_open_outlined;
      bannerText = s.g_key_btc_redeem_unlocked;
    } else if (isStillLocked) {
      final dt = DateTime.fromMillisecondsSinceEpoch(_lockTimeUnix! * 1000);
      final dateStr =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      bgColor = Colors.red.withAlpha(25);
      iconColor = Colors.red;
      bannerIcon = Icons.lock_outline;
      bannerText = '${s.g_key_btc_redeem_still_locked}  ·  ${s.g_key_btc_redeem_locked_until} $dateStr';
    } else {
      // 尚未收到赎回消息，显示通用提醒
      bgColor = Colors.orange.withAlpha(25);
      iconColor = Colors.orange;
      bannerIcon = Icons.info_outline_rounded;
      bannerText = s.g_key_btc_redeem_reminder;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(12),
      ),
      color: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(bannerIcon, color: iconColor, size: ScreenUtil().setWidth(28)),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              bannerText,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                height: 1.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showBanner = false),
            child: Icon(
              Icons.close,
              size: ScreenUtil().setWidth(28),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
    );
  }
}
