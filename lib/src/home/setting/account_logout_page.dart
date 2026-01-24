import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/home/models/exchange_account_model.dart';
import 'package:n42appv2/src/login/api/handtype.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/login/widgets/input_field.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/exchange_api.dart';
import 'package:n42appv2/src/wallet/api/market_api.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42appv2/src/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountLogoutPage extends StatefulWidget {
  const AccountLogoutPage({super.key});

  @override
  State<AccountLogoutPage> createState() => _AccountLogoutPageState();
}

class _AccountLogoutPageState extends State<AccountLogoutPage> {
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  Load load=Load.finish;
  final TextEditingController _uCodeController = TextEditingController();
  //final TextEditingController _uPasswordController = TextEditingController();
  //final TextEditingController _uGoogleCodeController = TextEditingController();
  bool canClick = false;
  //String password = '';
  String emailCode = '';
  //String googleCode = '';

  //bool googleCodeSure = false;

  //bool openGoogleAuth = false;

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

    /*_uPasswordController.addListener(() {
      password = _uPasswordController.text.trim();
      checkStatus();
    });

    _uGoogleCodeController.addListener(() {
      googleCode = _uPasswordController.text.trim();
      checkStatus();
    });*/
    // checkExchangeBalance();
    //initData();
  }

  /*initData() async {
    Map<String, dynamic>? s = await SPUtil().getSecurity();
    if (s != null) {
      Map<String, dynamic>? userSecurityMap = s[AppGlobals.userInfo?.uuid??""];
      if (userSecurityMap != null) {
        if (userSecurityMap['google']) {
          openGoogleAuth = true;
          if (mounted) {
            setState(() {});
          }
        }
      }
    }
  }*/

  //检查交易所是否还有余额
  Future<void> checkExchangeBalance() async {
    try {
      setState(() {
        loading = true;
      });
      ExchangeApi exchangeApi=ExchangeApi();
      final data = await exchangeApi.exchangeBalance('', "binance");
      if (data != null && data["code"] == 200) {
        balanceData = (data["data"] as List)
            .map((e) => ExchangeAccountModel.fromJson(e))
            .toList();
        await getCoinInfo(balanceData);
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getCoinInfo(List<ExchangeAccountModel> eams) async {
    String searchStr = "";
    for (ExchangeAccountModel eam in eams) {
      searchStr += "${eam.coin!.toLowerCase()},";
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
    if (//googleCode.isNotEmpty &&
        //password.isNotEmpty &&
        emailCode.isNotEmpty &&
        regular.isCaptcha(emailCode)) {
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
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_m8,
      ),
      body: loading?
      const LoadingPage():
      SafeArea(child: Container(
        padding: EdgeInsets.all( ScreenUtil().setWidth(30)),
        child: _buildContent(context),
      )),
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
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(28)),
                  child: Text(
                    S.of(context).g_key_wallet_m9,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemBgColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                      border: Border.all(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name))),
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
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

                //if (openGoogleAuth) _googleAuthWidget()
              ],
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(88),
          width: double.infinity,
          child: buttonStyle2(context, ()async{
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

            /*if (openGoogleAuth) {
              final googleCode = _uGoogleCodeController.text.trim();
              if (googleCode.isEmpty) {
                ToastUtils.show(S.of(context).g_key_wallet_m17);
              }
              UserInfoApi userInfoAPI=UserInfoApi();
              //直接对code进行验证
              MessageModel mm = await userInfoAPI.checkGoogle(googleCode);
              if (mm.error) {
                // error message
                ToastUtils.show(mm.data);
                return;
              }
            }*/

            final res = await tipsDialog2(
                this.context, S.of(this.context).g_key_wallet_m11,
                cancelText: S.of(this.context).g_key_79,
                sureText: S.of(this.context).g_key_wallet_m13);
            if (res != null && res) {
              setState(() {
                load=Load.loading;
              });
              UserInfoApi loginApi=UserInfoApi();
              final data = await loginApi.unRegisterAccount(code);
              if (data != null && data["code"] == 200) {
                try {
                  ToastUtils.show("Account has been cancelled");
                  //退出登陆
                  await AppGlobals.logout();
                  //退出第3方登录
                  //await FireBaseUtils.signOut();
                  /*Navigator.pushAndRemoveUntil(
                    this.context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const GuidePage()),
                        (route) => false,
                  );*/
                } catch (err) {
                  debugPrint("err: ${err.toString()}");
                } finally {
                  setState(() {
                    load=Load.finish;
                  });
                }
              } else {
                //注销失败
                ToastUtils.show("${data['err']}");
                setState(() {
                  load=Load.finish;
                });
              }
            }
          }, S.of(context).g_key_154,),
        ),
      ],
    );
  }
/*
  _googleAuthWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            S.of(context).g_key_wallet_m10,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor)),
          ),
        ),
        Container(
            decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBoxColor),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xffefefef))),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: InputField(
                    type: InputFieldType.email,
                    controller: _uGoogleCodeController,
                    hintText: S.of(context).g_key_wallet_m10,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    ClipboardData? clipboardData =
                    await Clipboard.getData(Clipboard.kTextPlain);
                    if (clipboardData != null) {
                      final text = clipboardData.text;
                      if (text != null && text != "null") {
                        _uGoogleCodeController.text = text;
                      }
                    }
                  },
                  child: Text(
                    S.of(context).g_key_166,
                    style:
                    const TextStyle(color: Colors.blueAccent, fontSize: 15),
                  ),
                )
              ],
            )),
      ],
    );
  }*/
}
