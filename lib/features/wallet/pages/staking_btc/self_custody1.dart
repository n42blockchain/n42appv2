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
import 'package:n42_wallet/features/wallet/pages/staking_btc/staking_btc_utils.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
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
  const SelfCustody1(this.coinModel, {super.key});

  @override
  ConsumerState<SelfCustody1> createState() => _SelfCustody1State();
}

class _SelfCustody1State extends ConsumerState<SelfCustody1>
    with _SelfCustody1LogicMixin {
  late WebViewController _controller;

  bool _showBanner = true;

  TransferApi? _transferApi;
  @override
  TransferApi get transferApi {
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
  @override
  int? lockTimeInt;
  @override
  String? publicKey;
  @override
  List<dynamic> unspents = [];
  @override
  int price = 10000;
  @override
  List<Map<String, dynamic>> inputUTXO = [];
  @override
  Map<String, dynamic> gasFeeLevel = {
    "error": false,
    "averageValue": 5,
    "loading": false,
    "gasFeeRate": 5,
    "gasFees": 0,
    "signByteSize": 0,
    "maxValue": 0,
  };

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF121212))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (_) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.getApiUrlOnline('btcStaking')))
      ..addJavaScriptChannel("N42APP", onMessageReceived: _onJsMessage);
  }

  Future<void> _onJsMessage(JavaScriptMessage message) async {
    final rdata = jsonDecode(message.message) as Map<String, dynamic>?;
    if (rdata == null) return;

    switch (rdata['type']) {
      case 'get_canister_ecdsa_public_key':
        await _handleEcdsaPublicKey(rdata);
      case 'is_p2wsh_address_valid':
        await _handleP2wshValidation(rdata);
      case 'request_mint_vbtc':
        final result = JsEscapeUtils.escapeJs(
          rdata['result']?.toString() ?? '',
        );
        _controller.runJavaScript('alert("来自Flutter的消息，我收到了:$result");');
    }
  }

  Future<void> _handleEcdsaPublicKey(Map<String, dynamic> rdata) async {
    final ecdsaKeyMap = jsonDecode(rdata['ecdsaKey']) as Map<String, dynamic>;
    final ecdsaKeyList = ecdsaKeyMap.values.map((e) => e as int).toList();
    final pKey = bytesToHex(ecdsaKeyList);
    final lockupSeconds = parseStakingLockupSeconds(
      rdata['lockupTime']?.toString(),
    );
    final stakeAmount = rdata['amount']?.toString();
    if (lockupSeconds == null ||
        stakeAmount == null ||
        stakeAmount.trim().isEmpty) {
      return;
    }
    final nowTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + lockupSeconds;
    lockTimeInt = nowTime;
    final p2wshAddr = await createP2WSH(nowTime, cPubKey: pKey);
    lockAmount = stakeAmount;
    _controller.runJavaScript(
      'is_p2wsh_address_valid("${JsEscapeUtils.escapeJs(p2wshAddr ?? "")}");',
    );
  }

  Future<void> _handleP2wshValidation(Map<String, dynamic> rdata) async {
    if (rdata['result'] != true) return;
    final currentP2wshAddress = p2wshAddress;
    final currentLockAmount = lockAmount;
    if (currentP2wshAddress == null ||
        currentLockAmount == null ||
        currentLockAmount.isEmpty) {
      return;
    }

    final p2wshAddr = currentP2wshAddress.toAddress(BitcoinNetwork.testnet);
    final value = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletChainSendBtc(
          widget.coinModel,
          toAddress: p2wshAddr,
          toAmount: currentLockAmount,
        ),
      ),
    );
    if (!mounted || value == null) return;

    final ethAddress = ref.read(wapBridgeProvider).getAddress(CoinType.N.name);
    final lockAmountInt = ethToWeiString(currentLockAmount, 8);
    final alertStr =
        'requestMintVbtc('
        '"${JsEscapeUtils.escapeJs(p2wshAddr)}",'
        '"${JsEscapeUtils.escapeJs(ethAddress)}",'
        '$lockAmountInt,'
        '"${JsEscapeUtils.escapeJs(widget.coinModel.address)}",'
        '$lockTimeInt,'
        '"${JsEscapeUtils.escapeJs(publicKey ?? "")}");';
    if (kDebugMode) debugPrint(alertStr);
    _controller.runJavaScript(alertStr);
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
          Expanded(child: WebViewWidget(controller: _controller)),
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
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
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
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
