// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/create_btc_tx_1.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/create_btc_tx_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:web3dart/web3dart.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:n42_wallet/core/utils/js_escape_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'self_custody1_logic.dart';

class SelfCustody1 extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const SelfCustody1(this.coinModel,{super.key});

  @override
  ConsumerState<SelfCustody1> createState() => _SelfCustody1State();
}
//01000000000103b4e1d30cf774b846bc6147f99f8ef11a6c300c61387a040dc68356e04c127bfb0000000000ffffffff607b3facebc1aedfb6c0a1448a37a1f727851e49c3135adaf8f81edc0e3feaa30000000000ffffffffc28c3d24f622f79dce51518a5a09cc7748e4baef93778e2327f5bd73b751a9d20500000000ffffffff02a086010000000000160014e6401c83bf5e7986cda4afff3d88ff897885dbe49e6a373000000000160014e6401c83bf5e7986cda4afff3d88ff897885dbe40140e69d8fec799297dd42ad45491d36e05e64c9dfaa6c8544b666b81b100aaf44242be38b37c6bfd096dc7dd2490bdac08a76db5e313f4619f460db8a5db764f9ea00000000
//02000000000103b4e1d30cf774b846bc6147f99f8ef11a6c300c61387a040dc68356e04c127bfb0000000000ffffffff607b3facebc1aedfb6c0a1448a37a1f727851e49c3135adaf8f81edc0e3feaa30000000000ffffffffc28c3d24f622f79dce51518a5a09cc7748e4baef93778e2327f5bd73b751a9d20500000000ffffffff02a086010000000000160014e6401c83bf5e7986cda4afff3d88ff897885dbe49e6a373000000000160014e6401c83bf5e7986cda4afff3d88ff897885dbe4034064a9ed7a202a05831461b0ffe898e0b500e6b8472d083ba0a819eef044200ab95c3a9ee4518785c7104c5a17d7be51adc99724dba24e270d18cae623589ba20f40f724540c07ead1c412f6fb5a7ef204e36ed3e47bdd036d83754e2e6f2bdeff9a9a4fd72fbe794d75de673473f909dc01b0dddc0625b93f0846d944ffd01e7dc4406f4b37f0fcbdca1aaeda926af92e70b52327425a5f118d5b7c03e62c171a9174d3b296382aac93440a4fec103c2567c538101b690e5e236eb8a1af4ee2f3b79200000000
class _SelfCustody1State extends ConsumerState<SelfCustody1> with _SelfCustody1LogicMixin {
  late WebViewController _controller;

  /// 是否显示顶部风险提醒横幅（用户可手动关闭）
  bool _showBanner = true;

  TransferApi? _transferApi;
  @override
  TransferApi get transferApi{
    _transferApi ??= TransferApi();
    return _transferApi!;
  }
  @override
  String? address;
  @override
  ECPrivate? privateKey;
  @override
  P2wshAddress? p2wshAddress;
  Uint8List? scriptByte;
  String? lockAmount;
  //String? lockTimeStr;
  @override
  int? lockTimeInt;
  @override
  String? publicKey;

  @override
  List<dynamic> unspents=[];//可用余额列表
  @override
  int price=10000;
  @override
  List<Map<String,dynamic>> inputUTXO=[];//交易输入utxo列表
  @override
  Map<String,dynamic> gasFeeLevel={
    "error":false,
    "averageValue":5,//服务器获取的平均价格 gas
    "loading":false,
    "gasFeeRate":5,//用户输入的 gas
    "gasFees":0,//根据用户转账amount 和选择的gasFeeLevel 计算出gasFee
    "signByteSize":0,//签名返回的 数据包大小
    "maxValue":0,//全部转出的金额
  };

  /// 获取 Staking WebView URL
  String _getStakingUrl() {
    return AppConfig.getApiUrlOnline('btcStaking');
  }

  @override
  void initState() {
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
            String? p2wshAddr=await createP2WSH(nowTime,cPubKey: pKey);
            //CreateP2WSH().p2wsh(rdata['lockupTime']);
            lockAmount=rdata['amount'];
            _controller.runJavaScript('is_p2wsh_address_valid("${JsEscapeUtils.escapeJs(p2wshAddr ?? "")}");');
          }else if(rdata['type']=="is_p2wsh_address_valid"){
            if(rdata["result"]==true){
              String p2wshAddr=p2wshAddress!.toAddress(BitcoinNetwork.testnet);
              final value=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletChainSendBtc(widget.coinModel,toAddress: p2wshAddr,toAmount: lockAmount!,)));
              if (!mounted) return;
              if(value !=null){

                String ethAddress=ref.read(wapBridgeProvider).getAddress(CoinType.N.name);
                BigInt lockAmountInt=ethToWeiString(lockAmount!, 8);
                //String alertStr='requestMintVbtc("${p2wshAddr}","${ethAddress}",${lockAmountInt},"${value}","${widget.coinModel.address}",${lockTimeInt},"${publicKey}");';
                String alertStr='requestMintVbtc("${JsEscapeUtils.escapeJs(p2wshAddr)}","${JsEscapeUtils.escapeJs(ethAddress)}",$lockAmountInt,"${JsEscapeUtils.escapeJs(widget.coinModel.address)}",$lockTimeInt,"${JsEscapeUtils.escapeJs(publicKey ?? "")}");';
                if (kDebugMode) debugPrint(alertStr);
                _controller.runJavaScript(alertStr);
              }
            }
          }else if(rdata['type']=="request_mint_vbtc"){
            _controller.runJavaScript('alert("来自Flutter的消息，我收到了:${JsEscapeUtils.escapeJs(rdata['result']?.toString() ?? "")}");');
          }
        }

      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_btc_stake_title),
      body: Column(
        children: [
          // ── 可关闭的风险提醒横幅 ──────────────────────────────
          if (_showBanner) _buildReminderBanner(context, s),

          // ── WebView 填充剩余空间 ──────────────────────────────
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderBanner(BuildContext context, S s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(12),
      ),
      color: Colors.orange.withAlpha(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.orange,
            size: ScreenUtil().setWidth(28),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              s.g_key_btc_stake_reminder,
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
