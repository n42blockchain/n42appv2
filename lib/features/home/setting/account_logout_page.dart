import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/home/models/exchange_account_model.dart';
import 'package:n42_wallet/features/login/api/handtype.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/login/widgets/input_field.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/exchange_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/features/utils/chat_logout_compat.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountLogoutPage extends StatefulWidget {
  const AccountLogoutPage({super.key});

  @override
  State<AccountLogoutPage> createState() => _AccountLogoutPageState();
}

class _AccountLogoutPageState extends State<AccountLogoutPage> {
  Regular? _regular;
  Regular get regular {
    _regular ??= Regular();
    return _regular!;
  }

  Load load = Load.finish;
  final TextEditingController _uCodeController = TextEditingController();
  bool canClick = false;
  String emailCode = '';

  double totalBalance = 0.0;

  bool loading = false;

  List<ExchangeAccountModel> balanceData = [];

  @override
  void initState() {
    super.initState();
    _uCodeController.addListener(() {
      emailCode = _uCodeController.text.trim();
      checkStatus();
    });
  }

  @override
  void dispose() {
    _uCodeController.dispose();
    super.dispose();
  }

  //检查交易所是否还有余额
  Future<void> checkExchangeBalance() async {
    try {
      setState(() {
        loading = true;
      });
      ExchangeApi exchangeApi = ExchangeApi();
      final data = await exchangeApi.exchangeBalance('', "binance");
      if (data != null && data["code"] == 200) {
        balanceData = (data["data"] as List)
            .map((e) => ExchangeAccountModel.fromJson(e))
            .toList();
        await getCoinInfo(balanceData);
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> getCoinInfo(List<ExchangeAccountModel> eams) async {
    String searchStr = "";
    for (ExchangeAccountModel eam in eams) {
      searchStr += "${(eam.coin ?? '').toLowerCase()},";
    }
    if (searchStr == "") {
      return;
    }
    var list = await MarketApi().getWalletCoinsInfo(searchStr);
    if (list['error']) {
      totalBalance = 0.0;
      ToastUtils.show(S.current.g_key_5);
    } else {
      List<dynamic> coinMarketInfo = list['data']['data'];
      double total = 0.0;
      for (ExchangeAccountModel eam in eams) {
        double coinPrice = getCoinPriceWithUnit(eam.coin!, coinMarketInfo);
        total +=
            coinPrice * (double.parse(eam.over!) + double.parse(eam.lock!));
      }
      totalBalance = total;
    }
  }

  double getCoinPriceWithUnit(String unit, List<dynamic> coinMarketInfo) {
    String keyStr = unit.toLowerCase();
    for (var element in coinMarketInfo) {
      if (element['coin'] == keyStr) {
        return element['price'] * 1.0;
      }
    }
    return 0.0;
  }

  void checkStatus() {
    if ( //googleCode.isNotEmpty &&
    //password.isNotEmpty &&
    emailCode.isNotEmpty && regular.isCaptcha(emailCode)) {
      canClick = true;
    } else {
      canClick = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_wallet_m8),
      body: loading
          ? const LoadingPage()
          : SafeArea(
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: _buildContent(context),
              ),
            ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(28),
                  ),
                  child: Text(
                    S.of(context).g_key_wallet_m9,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemBgColor.name,
                    ),
                    borderRadius: BorderRadius.circular(
                      ScreenUtil().setWidth(16),
                    ),
                    border: Border.all(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemBgColor2.name,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(24),
                  ),
                  child: InputField(
                    type: InputFieldType.captcha,
                    controller: _uCodeController,
                    hintText: S.of(context).rest_Please_enter,
                    codeType: HandType.unRegister,
                    inputLength: 6,
                    //这里如果是验证码输入框
                    onCaptcha: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      return AppGlobals.userInfo?.email;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(88),
          width: double.infinity,
          child: buttonStyle2(context, () async {
            final code = _uCodeController.text.trim();
            if (code.isEmpty) {
              ToastUtils.show(S.of(context).please_enter_code);
              return;
            }

            if (!regular.isCaptcha(code)) {
              //请输入验证码
              ToastUtils.show(S.of(context).code_err_tips);
              return;
            }

            final res = await tipsDialog2(
              this.context,
              S.of(this.context).g_key_wallet_m11,
              cancelText: S.of(this.context).g_key_79,
              sureText: S.of(this.context).g_key_wallet_m13,
            );
            if (!mounted) return;
            if (res != null && res) {
              setState(() {
                load = Load.loading;
              });
              UserInfoApi loginApi = UserInfoApi();
              final data = await loginApi.unRegisterAccount(code);
              if (data != null && data["code"] == 200) {
                try {
                  ToastUtils.show("Account has been cancelled");
                  await purgeCancelledChatSessionCompat();
                  await AppGlobals.logout();
                } catch (err) {
                  debugPrint("err: ${err.toString()}");
                } finally {
                  if (mounted) {
                    setState(() {
                      load = Load.finish;
                    });
                  }
                }
              } else {
                //注销失败
                ToastUtils.show(data?['err']?.toString() ?? S.current.g_key_5);
                if (mounted) {
                  setState(() {
                    load = Load.finish;
                  });
                }
              }
            }
          }, S.of(context).g_key_154),
        ),
      ],
    );
  }
}
