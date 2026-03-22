// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/staking_btc/staking_btc_utils.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:n42_wallet/core/utils/js_escape_utils.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex;
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Redeem extends ConsumerStatefulWidget {
  final CoinModel coinModel;

  const Redeem(this.coinModel, {super.key});

  @override
  ConsumerState<Redeem> createState() => _RedeemState();
}

class _RedeemState extends ConsumerState<Redeem> {
  late WebViewController _controller;

  /// WebView 触发赎回时记录的锁定到期时间戳（Unix 秒），null 表示尚未收到赎回请求
  int? _lockTimeUnix;
  bool _showBanner = true;

  TransferApi? _transferApi;
  TransferApi get transferApi => _transferApi ??= TransferApi();

  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi => _tokenViewApi ??= TokenViewApi();

  int gasFeeRate = 4;
  int gasFees = 0;
  int input2Price = 0;
  bool inputValueOK = false;
  List<Map<String, dynamic>> inputUTXO = [];

  CoinModel get _coin => widget.coinModel;
  WalletInfo get _walletInfo => ref.read(wapBridgeProvider).walletInfo;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final PlatformWebViewControllerCreationParams params;
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
          onProgress: (progress) => debugPrint('WebView loading: $progress%'),
          onPageStarted: (url) => debugPrint('Page started: $url'),
          onNavigationRequest: (_) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(
        Uri.parse(
          '${AppConfig.getApiUrlOnline('btcStaking')}/redeem?walletAddress=${_coin.address}',
        ),
      )
      ..addJavaScriptChannel("N42APP", onMessageReceived: _onJsMessage);
  }

  Future<void> _onJsMessage(JavaScriptMessage message) async {
    final Map<String, dynamic>? rdata = jsonDecode(message.message);
    if (rdata == null) return;

    switch (rdata['type']) {
      case 'redeem':
        final int lockTime = (rdata['lock_time'] as num).toInt();
        if (mounted) setState(() => _lockTimeUnix = lockTime);
        final signStr = await redeem(rdata['p2wsh_address'], lockTime);
        final addr = JsEscapeUtils.escapeJs(
          rdata['p2wsh_address']?.toString() ?? '',
        );
        final sig = JsEscapeUtils.escapeJs(signStr);
        _controller.runJavaScript('request_withdraw_vbtc("$addr","$sig");');
      case 'request_withdraw_vbtc':
        final result = JsEscapeUtils.escapeJs(
          rdata['result']?.toString() ?? '',
        );
        _controller.runJavaScript('alert("来自Flutter的消息，我收到了:$result");');
    }
  }

  Future<String> redeem(String address, int lockTime) async {
    inputUTXO = [];
    input2Price = 0;
    inputValueOK = false;
    await getGasFeeBtc();
    await getUTXO(address);
    if (inputUTXO.isEmpty) {
      ToastUtils.show('UTXO unavailable');
      return '';
    }
    final witnessScriptValue = await createP2WSH(lockTime);
    inputUTXO[0]['witnessValue'] = witnessScriptValue;
    inputUTXO[0]['lockTime'] = lockTime;
    return signP2WSH();
  }

  Future<String> createP2WSH(
    int lockTime, {
    String? uPubKey,
    String? cPubKey,
  }) async {
    if (uPubKey == null) {
      final pubKey = await Trustdart().getPublicKey(
        CoinType.BTC.name,
        "m/84'/4'/0'/0/0",
        mnemonic: _walletInfo.mnemonic ?? '',
        pk: _walletInfo.privateKey ?? '',
      );
      uPubKey = bytesToHex(base64Decode(pubKey));
    }
    cPubKey ??=
        '02a075b5988699e95802fe94590908de9370588cacc750d6f538d76fe6e9b8d6ad';
    final newScript = Script(
      script: [
        lockTime,
        'OP_CHECKLOCKTIMEVERIFY',
        'OP_DROP',
        2,
        uPubKey,
        cPubKey,
        2,
        'OP_CHECKMULTISIG',
      ],
    );
    return newScript.toHex();
  }

  Future<void> getGasFeeBtc() async {
    final gasFeeMM = await tokenViewApi.getGasFeeBtc(isTest: _coin.isTest);
    if (gasFeeMM.error) {
      debugPrint('getGasFeeBtc error: ${gasFeeMM.data}');
    } else {
      gasFeeRate = gasFeeMM.data;
    }
    if (mounted) setState(() {});
  }

  Future<String> signP2WSH() async {
    final btcTxMap = {
      'utxo': inputUTXO,
      'toAddress': _coin.address,
      'amount': 99500,
      'byteFee': gasFeeRate,
      'changeAddress': _coin.address,
      'change': 0,
      'max': true,
    };
    if (kDebugMode) debugPrint(json.encode(btcTxMap));
    return Trustdart().signTransactionBtcP2wsh(
      CoinType.BTC.name,
      "m/84'/4'/0'/0/0",
      btcTxMap,
      pk: _walletInfo.privateKey ?? '',
    );
  }

  Future<BtcTransactionRecodeModel> transatroinBuilder1To1(
    BtcTransactionRecodeModel btcTransactionRecodeModel,
  ) async {
    try {
      final btcTxMap = <String, dynamic>{
        'utxo': inputUTXO,
        'toAddress': btcTransactionRecodeModel.to1,
        'amount': btcTransactionRecodeModel.price,
        'byteFee': 500,
        'changeAddress': btcTransactionRecodeModel.address,
        'change': 0,
      };
      btcTransactionRecodeModel.inputModels = [];
      input2Price = 0;
      for (final unspent in inputUTXO) {
        input2Price += int.parse(unspent['value']);
        final im = InputModel(
          txid: unspent['txid'],
          vout: unspent['vout'],
          value: int.parse(unspent['value']),
          script: unspent['script'],
          witnessValue: unspent['witnessValue'],
          lockTime: unspent['lockTime'],
        );
        im.address = [_coin.address.toString()];
        btcTransactionRecodeModel.inputModels!.add(im);
      }
      btcTxMap['change'] = 0;
      btcTxMap['fees'] = gasFees;
      btcTxMap['utxo'] = inputUTXO;

      btcTransactionRecodeModel.price =
          btcTransactionRecodeModel.price - gasFees;
      btcTransactionRecodeModel.gas = gasFeeRate;
      btcTransactionRecodeModel.gasPrice = gasFees;
      btcTransactionRecodeModel.addrType = _coin.addrType;
      btcTransactionRecodeModel.max = true;
      btcTransactionRecodeModel.isTest = _coin.isTest ? 1 : 0;
      final rmm = await transferApi.transferWallet(
        trModelBtc: btcTransactionRecodeModel,
        pathIndex: _coin.pathIndex,
        privateKey: _coin.privateKey,
      );
      if (rmm.error) {
        ToastUtils.show(rmm.data);
      } else {
        btcTransactionRecodeModel.txHash = rmm.data;
      }
      return btcTransactionRecodeModel;
    } catch (e) {
      return btcTransactionRecodeModel;
    }
  }

  Future<int> getSignByteSize(
    List<Map<String, dynamic>> utxos, {
    bool max = true,
  }) async {
    final btcTxMap = {
      'utxo': utxos,
      'toAddress': _coin.address,
      'amount': 0.001,
      'byteFee': gasFeeRate,
      'changeAddress': _coin.address,
      'max': max,
    };
    final signByteSize = await transferApi.transactionMaxValue(
      _coin.coin['blockchainType'],
      _coin.coin['coinType'],
      btcTxMap,
      getPathWithIndex(_coin.coin['path'][_coin.addrType], _coin.pathIndex),
      privateKey: _coin.privateKey,
    );
    return signByteSize.isEmpty ? 0 : int.parse(signByteSize);
  }

  Future<void> getUTXO(String address) async {
    try {
      inputUTXO = [];
      input2Price = 0;
      inputValueOK = false;
      final mm = await tokenViewApi.getUTXOBtc(
        _coin.coin['coinType'],
        address,
        pageSize: kStakingRedeemUtxoPageSize,
        pageNum: kStakingRedeemUtxoPageNum,
        isTest: _coin.isTest,
      );
      if (mm.error) {
        ToastUtils.show(mm.data);
        if (mounted) setState(() {});
      } else {
        await calculateGasFee(mm.data);
      }
    } catch (e) {
      ToastUtils.show(e.toString());
      if (mounted) setState(() {});
    }
  }

  Future<void> calculateGasFee(List<dynamic> unspents) async {
    input2Price = 0;
    gasFees = 0;
    inputValueOK = false;
    final List<Map<String, dynamic>> utxos = [];
    for (final Map<String, dynamic> unspent in unspents) {
      if (_coin.isTest) {
        if (unspent['hex'] == null) {
          final utxoTx = await BtcApi(test: true).getUTXOTxid(unspent['txid']);
          if (!utxoTx.error) {
            unspent['hex'] =
                utxoTx.data['vout']?[unspent['vout']]?['scriptpubkey'];
          }
        }
        final int amount = unspent['value'];
        input2Price += amount;
        utxos.add({
          'txid': unspent['txid'],
          'vout': unspent['vout'],
          'value': amount.toString(),
          'script': unspent['hex'],
        });
      } else {
        final BigInt amount = ethToWeiString(
          double.parse(unspent['value']).toString(),
          8,
        );
        input2Price += amount.toInt();
        utxos.add({
          'txid': unspent['txid'],
          'vout': unspent['output_no'],
          'value': amount.toString(),
          'script': unspent['hex'],
        });
      }
      const byteSize = 338;
      gasFees = byteSize * gasFeeRate;
      inputValueOK = true;
      break;
    }
    inputUTXO = utxos;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_btc_redeem_title),
      body: Column(
        children: [
          if (_showBanner) _buildStatusBanner(s),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }

  ({Color bg, Color icon, IconData iconData, String text}) _resolveBannerStatus(
    S s,
  ) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_lockTimeUnix != null && _lockTimeUnix! <= now) {
      return (
        bg: Colors.green.withAlpha(30),
        icon: Colors.green,
        iconData: Icons.lock_open_outlined,
        text: s.g_key_btc_redeem_unlocked,
      );
    }
    if (_lockTimeUnix != null && _lockTimeUnix! > now) {
      final dt = DateTime.fromMillisecondsSinceEpoch(_lockTimeUnix! * 1000);
      final dateStr =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return (
        bg: Colors.red.withAlpha(25),
        icon: Colors.red,
        iconData: Icons.lock_outline,
        text:
            '${s.g_key_btc_redeem_still_locked}  ·  ${s.g_key_btc_redeem_locked_until} $dateStr',
      );
    }
    return (
      bg: Colors.orange.withAlpha(25),
      icon: Colors.orange,
      iconData: Icons.info_outline_rounded,
      text: s.g_key_btc_redeem_reminder,
    );
  }

  Widget _buildStatusBanner(S s) {
    final status = _resolveBannerStatus(s);
    final sw = ScreenUtil().setWidth;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: sw(20), vertical: sw(12)),
      color: status.bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.iconData, color: status.icon, size: sw(28)),
          SizedBox(width: sw(10)),
          Expanded(
            child: Text(
              status.text,
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
              size: sw(28),
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
