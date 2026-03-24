import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/payment_amount_utils.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/payment_request_utils.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'payment_page_widgets.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final String? amount;
  final String? address;
  final String? coinType;
  final String? uuid;
  const PaymentPage(
    this.amount,
    this.uuid,
    this.coinType,
    this.address, {
    super.key,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String amount = "";
  String address = "";
  String coinType = "";
  String uuid = "";
  UserInfo? userInfo;
  Map<String, dynamic>? usdtInfo;
  String usdtAmount = "";
  List<CoinModel> coinModels = [];
  CoinModel? coinMain;
  int coinModelIndex = -1;
  Load load = Load.refresh;
  String errorMessage = "";
  late final Regular regular = Regular();
  final UserInfoApi _userInfoApi = UserInfoApi();
  final oCcy = NumberFormat("#,##0.0#", "en_US");
  int _coinSelectionGeneration = 0;

  @override
  void initState() {
    super.initState();
    final request = sanitizePaymentRequest(
      amount: widget.amount,
      address: widget.address,
      coinType: widget.coinType,
      uuid: widget.uuid,
    );
    amount = request.amount;
    address = request.address;
    coinType = request.coinType;
    uuid = request.uuid;
    _initData();
  }

  Future<void> _initData() async {
    _initUserInfo();
    await _initCoinInfo();
    await _initCoinModel();
  }

  Future<void> _initUserInfo() async {
    if (uuid.isEmpty) return;
    final mm = await _userInfoApi.getUserInfoWithUUID(uuid);
    if (!mm.error && mm.data != null) {
      try {
        userInfo = UserInfo.fromJson(Map<String, dynamic>.from(mm.data as Map));
      } catch (e) {
        debugPrint('initUserInfo parse error: $e');
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _initCoinInfo() async {
    usdtInfo = ref.read(wapBridgeProvider).getCoinPriceWithUnit("usdt");
    final list = await MarketApi().getWalletCoinsInfo("usdt");
    if (!mounted) return;
    if (list['error']) {
      errorMessage = S.current.g_key_5;
      setState(() => load = Load.finish);
    } else {
      final coinMarketInfo = extractMarketCoinItems(list['data']);
      for (final element in coinMarketInfo) {
        if (element['coin'].toString().toLowerCase() == "usdt") {
          usdtInfo = {
            "icon": element['image'],
            'coinPrice': Decimal.parse(element['price'].toString()).toDouble(),
            'percentage': Decimal.parse(
              element['price_change_per_24h'].toString(),
            ).toDouble(),
          };
          break;
        }
      }
    }
    final double coinPrice = usdtInfo?['coinPrice'] ?? 0.0;
    final double amountVal = double.tryParse(amount) ?? 0.0;
    final double uAmount = calculatePaymentTokenAmount(
      fiatAmount: amountVal,
      tokenPriceUsd: coinPrice,
    );
    usdtAmount = DataUtils().formatNum(uAmount, 2);
    setState(() {});
  }

  Future<void> _initCoinModel() async {
    final wap = ref.read(wapBridgeProvider);
    coinModels.clear();
    for (final cm in wap.coinList) {
      if (cm.coin['coinType'].toString().toLowerCase() ==
              coinType.toLowerCase() &&
          cm.coin['miniName'].toString().toLowerCase() == "usdt") {
        coinModels.add(cm);
      }
    }
    if (coinModels.isNotEmpty) {
      await _selectCoinModel(0);
    } else {
      errorMessage = S.current.g_key_payment_usdt_not_found;
    }
    if (!mounted) return;
    setState(() => load = Load.finish);
  }

  Future<void> _selectCoinModel(int index) async {
    final int generation = ++_coinSelectionGeneration;
    setState(() {
      coinModelIndex = index;
      coinMain = null;
      errorMessage = '';
    });
    await _initCoinMainModel(generation: generation);
  }

  Future<void> _initCoinMainModel({required int generation}) async {
    final wap = ref.read(wapBridgeProvider);
    final selectedCoin = coinModels[coinModelIndex];
    final cIndex = wap.coinModels.indexWhere((element) {
      if (element.coin['coinType'] != selectedCoin.coin['coinType']) {
        return false;
      }
      if (selectedCoin.privateKey == null) return true;
      return element.privateKey == selectedCoin.privateKey;
    });
    if (cIndex != -1) {
      coinMain = wap.coinModels[cIndex];
      await coinMain?.getBalance();
    }
    if (!mounted || generation != _coinSelectionGeneration) return;
    _syncSelectionError();
    setState(() {});
  }

  void _syncSelectionError() {
    final issue = resolvePaymentAvailabilityIssue(
      hasSelectedToken:
          coinModelIndex >= 0 && coinModelIndex < coinModels.length,
      tokenBalance: coinModelIndex >= 0 && coinModelIndex < coinModels.length
          ? coinModels[coinModelIndex].balanceDoubleAll()
          : 0,
      requiredTokenAmount: double.tryParse(usdtAmount) ?? 0,
      hasNativeToken: coinMain != null,
      nativeBalance: coinMain?.balance ?? BigInt.zero,
    );
    errorMessage = switch (issue) {
      PaymentAvailabilityIssue.tokenUnavailable =>
        S.current.g_key_payment_usdt_not_found,
      PaymentAvailabilityIssue.tokenInsufficient =>
        S.current.g_key_payment_usdt_insufficient,
      PaymentAvailabilityIssue.nativeUnavailable =>
        S.current.g_key_payment_native_not_found,
      PaymentAvailabilityIssue.nativeInsufficient =>
        S.current.g_key_payment_native_insufficient,
      PaymentAvailabilityIssue.none => "",
    };
  }

  Future<void> web3Transaction() async {
    setState(() => load = Load.loading);
    try {
      final payToken = coinModels[coinModelIndex];
      final double transferAmount = usdtAmount.isNotEmpty
          ? (double.tryParse(usdtAmount) ?? 0.0)
          : (double.tryParse(amount) ?? 0.0);
      if (!transferAmount.isFinite || transferAmount <= 0) {
        errorMessage = S.current.g_key_payment_amount_invalid;
        setState(() => load = Load.finish);
        return;
      }
      final rData = await TransferApi().transfer(
        payToken.coin['coinType'],
        address,
        transferAmount,
        fromAddress: payToken.address,
        contractAddress: payToken.isTest
            ? (payToken.coin['contract_test'] ?? payToken.coin['contract'])
            : payToken.coin['contract'],
        isTest: payToken.isTest,
      );
      if (rData.error) {
        errorMessage = rData.data;
      } else {
        errorMessage = "";
        if (uuid.isNotEmpty) {
          _notifyPayee(
            txHash: rData.data?.toString() ?? "",
            coinType: payToken.coin['coinType'],
          );
        }
        ToastUtils.show(S.current.g_key_payment_success);
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (mounted) setState(() => load = Load.finish);
    }
  }

  void _notifyPayee({required String txHash, required String coinType}) {
    _userInfoApi
        .sendPaymentReceipt(
          toUuid: uuid,
          txHash: txHash,
          amount: amount,
          tokenAmount: usdtAmount,
          coinType: coinType,
          tokenName: "USDT",
        )
        .catchError((Object e) {
          debugPrint('sendPaymentReceipt error: $e');
          return MessageModel.error();
        });
  }

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  String get _buttonLabel => switch (load) {
    Load.loading => 'Paying...',
    Load.refresh => 'Loading...',
    _ => 'Payment',
  };

  @override
  Widget build(BuildContext context) {
    final mainText = _themeColor(AppThemeKeys.mainTextColor);
    final bgColor = _themeColor(AppThemeKeys.backGroundColor);
    final su = ScreenUtil();
    final s = S.of(context);
    final userName = userInfo?.name ?? "";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBarWidget(text: s.g_key_payment_title),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(su.setWidth(30)),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(su.setWidth(30)),
                      decoration: BoxDecoration(
                        color: _themeColor(AppThemeKeys.itemBgColor),
                        borderRadius: BorderRadius.circular(su.setWidth(16)),
                      ),
                      child: Column(
                        children: [
                          if (userName.isNotEmpty)
                            Text(
                              userName,
                              style: TextStyle(
                                color: mainText,
                                fontSize: su.setSp(30),
                              ),
                            ),
                          EnsAddressDisplay(
                            address: address,
                            coinType: coinType.isNotEmpty ? coinType : 'ETH',
                            style: EnsDisplayStyle.compact,
                            showAvatar: false,
                            showCopy: false,
                            textColor: mainText,
                            fontSize: su.setSp(30),
                          ),
                          Text(
                            "\$ $amount",
                            style: TextStyle(
                              color: mainText,
                              fontSize: su.setSp(100),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            s.g_key_payment_approx_usdt(usdtAmount),
                            style: TextStyle(
                              color: mainText,
                              fontSize: su.setSp(60),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    walletWidget(),
                    if (coinMain != null) mainCoin(),
                    if (coinModelIndex != -1) usdtCoin(),
                    if (errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(su.setWidth(30)),
                        margin: EdgeInsets.only(top: su.setWidth(30)),
                        decoration: BoxDecoration(
                          color: _themeColor(AppThemeKeys.errorBgColor2),
                          borderRadius: BorderRadius.circular(su.setWidth(16)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: _themeColor(AppThemeKeys.errorTextColor),
                            fontSize: su.setSp(26),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: su.setWidth(148)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Divider(height: su.setWidth(1), indent: 0, endIndent: 0),
                  Container(
                    padding: EdgeInsets.all(su.setWidth(30.0)),
                    height: su.setWidth(148.0),
                    color: bgColor,
                    child: buttonStyle6(
                      context,
                      () async {
                        if (errorMessage.isNotEmpty && load != Load.refresh) {
                          return;
                        }
                        final r = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WalletSecurityVerification(),
                          ),
                        );
                        if (r == true) web3Transaction();
                      },
                      _buttonLabel,
                      _themeColor(
                        load == Load.finish
                            ? AppThemeKeys.mainButtonBgColor
                            : AppThemeKeys.mainButtonBgColor3,
                      ),
                      _themeColor(AppThemeKeys.mainButtonTextColor),
                      load == Load.loading || load == Load.refresh,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
