import 'dart:async';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/api/handtype.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/login/widgets/login_title.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:n42appv2/src/utils/device_info_util.dart';
import 'package:n42appv2/src/utils/md5_util.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/text_field_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

/// Account Create and Reset Page - Migrated to Riverpod
class AccountCreateAndReset extends ConsumerStatefulWidget {
  final HandType type;
  final int pushType; // 0 push, 1 content
  const AccountCreateAndReset({required this.type, this.pushType = 0, super.key});

  @override
  ConsumerState<AccountCreateAndReset> createState() => _AccountCreateAndResetState();
}

class _AccountCreateAndResetState extends ConsumerState<AccountCreateAndReset> {
  final TextEditingController _unameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();
  final TextEditingController _uPasswordController = TextEditingController();
  final TextEditingController _uPasswordConfirmController = TextEditingController();
  final TextEditingController _uCodeController = TextEditingController();
  final FocusNode _unameFocusNode = FocusNode();
  final FocusNode _inviteCodeFocusNode = FocusNode();
  final FocusNode _uPasswordFocusNode = FocusNode();
  final FocusNode _uPasswordConfirmFocusNode = FocusNode();
  final FocusNode _uCodeFocusNode = FocusNode();
  String unameErrorMessage="";
  String uPasswordErrorMessage="";
  String uPasswordConfirmErrorMessage="";
  String uCodeErrorMessage="";
  bool showPwd1=true;
  bool showPwd2=true;
  //var eventBusFn;

  Timer? _timer;
  int _countdown = 61;
  Load codeLoad=Load.finish;
  Load sendLoad=Load.finish;
  late HandType _currentType;
  UserInfoApi? _userInfoApi;
  UserInfoApi get userInfoApi{
    _userInfoApi ??= UserInfoApi();
    return _userInfoApi!;
  }
  @override
  void initState() {
    super.initState();
    _currentType = _currentType;
    init();
    getInviterEmail();
    /*eventBusFn=eventBus.on().listen((event) {
      if (event is EventPublic && event.type == EventPublicType.finishPage) {
        Navigator.of(context).pop();
      }
    });*/
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _unameController.dispose();
    _inviteCodeController.dispose();
    _uPasswordController.dispose();
    _uPasswordConfirmController.dispose();
    _uCodeController.dispose();
    _unameFocusNode.dispose();
    _inviteCodeFocusNode.dispose();
    _uPasswordFocusNode.dispose();
    _uPasswordConfirmFocusNode.dispose();
    _uCodeFocusNode.dispose();
    //eventBusFn.cancel();
    if(_timer !=null ){
      if(_timer!.isActive){
        _timer!.cancel();
        _timer=null;
      }
    }
    super.dispose();
  }

  Future<void> getInviterEmail() async {
    DeviceInfoUtil deviceInfoUtil = DeviceInfoUtil();
    Map<String, dynamic>? infoMap = await deviceInfoUtil.getDeviceInfo();
    if (infoMap != null) {
      UserInfoApi loginApi=UserInfoApi();
      String? email = await loginApi.getInviterCode(
          infoMap["mobileModel"], infoMap["mobileName"], infoMap["os"]);
      if (email != null) {
        _inviteCodeController.text = email;
        setState(() {});
      }
    }
  }
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        _countdown--;
      } else {
        _countdown = 61;
        timer.cancel();
      }
      setState(() {});
    });
  }
  void sendEmailCode(String email, String type) async {
    try {
      setState(() {
        codeLoad=Load.loading;
      });
      //发送 获取验证码接口
      final data = await userInfoApi.sendEmailCode(email, type);
      if (!mounted) return;
      if (data["code"] == 200) {
        //success
        setState(() => _countdown -= 1);
        _startTimer();
        ToastUtils.show(S.of(context).login_message_7);
      } else if (data["code"] == -1402) {
        // 失败
        ToastUtils.show(S.of(context).login_message_8);
      } else {
        ToastUtils.show(S.of(context).login_message_9);
      }
    } finally {
      setState(() {
        codeLoad=Load.finish;
      });
      //EasyLoading.dismiss();
    }
  }
  Future<bool> login(String email,String password)async{
    final data = await userInfoApi.login(
        email, Md5Util().generateMd5(password));
    if (!mounted) return false;
    if (data != null) {
      if (data["code"] == 200) {
        //AmplitudeUtils.accountLoggedIn();
        UserInfo userInfo = UserInfo.fromJson(data['data']);
        await SPUtil().saveUserInfo(userInfo);
        if (!mounted) return false;
        AppGlobals.login(userInfo);
        // 使用 Riverpod 设置用户信息
        ref.read(currentUserProvider.notifier).setUser(
          SharedUserInfo.fromLegacyUserInfo(userInfo),
        );
        return true;
      }
      else if (data["code"] == -403) {
        ToastUtils.showFtToast(
            title: S.of(context).code_403);
        return false;
      } else {
        ToastUtils.showFtToast(title: data["err"]);
        return false;
      }
    }
    return false;
  }
  void init() async {
    final data = await SPUtil().getUserInfo();
    if (data != null) {
      UserInfo info = UserInfo.fromJson(data);
      _unameController.text = info.email??"";
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildInviteView(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: ScreenUtil().setHeight(20),
        ),
        LoginTitle(
          title: S.of(context).login_invite_code_title,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(10),
        ),
        //邀请码
        textFieldStyle3(
          context,
          onEditingComplete:(){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          controller:_inviteCodeController,
          focusNode: _inviteCodeFocusNode,
          hintText:S.of(context).login_invite_code,
          keyboardType: TextInputType.numberWithOptions(),
          textInputAction: TextInputAction.done,
          //bgColor: Colors.transparent,
          //padding: EdgeInsets.all(0),
          hintStyle: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
            fontSize: ScreenUtil().setSp(30.0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(
        text: _currentType == HandType.restPassword ? S.of(context).rest_your_password : S.of(context).Create_your_account,
      ),
      body: SafeArea(
        child: GestureDetector(
          // onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                  //color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
                        child: Text(
                          _currentType == HandType.restPassword
                              ? S.of(context).rest_your_password
                              : S.of(context).Create_your_account,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(48.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      LoginTitle(
                        title: S.of(context).login_email,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                        must: true,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(10),
                      ),
                      textFieldStyle3(
                        context,
                        onEditingComplete:(){
                          FocusScope.of(context).requestFocus(_uPasswordFocusNode);
                        },
                        controller:_unameController,
                        focusNode: _unameFocusNode,
                        hintText:S.of(context).login_email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        errorMessage: unameErrorMessage,
                        //bgColor: Colors.transparent,
                        //padding: EdgeInsets.all(0),
                        hintStyle: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(20),
                      ),
                      LoginTitle(
                        title: _currentType == HandType.restPassword?S.of(context).g_lock_key11:S.of(context).login_password,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                        must: true,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(10),
                      ),
                      textFieldStyle3(
                          context,
                          onEditingComplete:(){
                            FocusScope.of(context).requestFocus(_uPasswordConfirmFocusNode);
                          },
                          controller:_uPasswordController,
                          focusNode: _uPasswordFocusNode,
                          hintText:S.of(context).rest_Choose_password,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          errorMessage: uPasswordErrorMessage,
                          //bgColor: Colors.transparent,
                          //padding: EdgeInsets.all(0),
                          hintStyle: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                          obscure: showPwd1,
                          rightWidget1: Container(
                            width: ScreenUtil().setWidth(50.0),
                            height: ScreenUtil().setWidth(50.0),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/login/${showPwd1?"icon_denglu_yincang":"icon_denglu_xianshi"}.png',
                              width: ScreenUtil().setWidth(34.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor3.name),
                            ),
                          ),
                          rightOnTap1: (){
                            setState(() {
                              showPwd1=!showPwd1;
                            });
                          }
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(20),
                      ),
                      LoginTitle(
                        title: _currentType == HandType.restPassword?S.of(context).g_lock_key12:S.of(context).rest_Confirm_password,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                        must: true,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(10),
                      ),
                      textFieldStyle3(
                          context,
                          onEditingComplete:(){
                            if (_currentType == HandType.createAccount){
                              FocusScope.of(context).requestFocus(_inviteCodeFocusNode);
                            }
                            else{
                              FocusScope.of(context).requestFocus(_uCodeFocusNode);
                            }
                          },
                          controller:_uPasswordConfirmController,
                          focusNode: _uPasswordConfirmFocusNode,
                          hintText:S.of(context).rest_Enter_the_password_again,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          errorMessage: uPasswordConfirmErrorMessage,
                          //bgColor: Colors.transparent,
                          //padding: EdgeInsets.all(0),
                          hintStyle: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                          obscure: showPwd2,
                          rightWidget1: Container(
                            width: ScreenUtil().setWidth(50.0),
                            height: ScreenUtil().setWidth(50.0),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/login/${showPwd2?"icon_denglu_yincang":"icon_denglu_xianshi"}.png',
                              width: ScreenUtil().setWidth(34.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor3.name),
                            ),
                          ),
                          rightOnTap1: (){
                            setState(() {
                              showPwd2=!showPwd2;
                            });
                          }
                      ),
                      if (_currentType == HandType.createAccount)
                        _buildInviteView(context),
                      SizedBox(
                        height: ScreenUtil().setHeight(20),
                      ),
                      LoginTitle(
                        title: S.of(context).rest_Verification_code,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                        must: true,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(10),
                      ),
                      textFieldStyle3(
                        context,
                        onEditingComplete:(){
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        focusNode: _uCodeFocusNode,
                        controller:_uCodeController,
                        hintText:S.of(context).rest_Please_enter,
                        keyboardType: TextInputType.numberWithOptions(),
                        textInputAction: TextInputAction.done,
                        //bgColor: Colors.transparent,
                        //padding: EdgeInsets.all(0),
                        hintStyle: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                        rightOnTap1: (){

                        },
                        rightWidget1: otpRightWidget(),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(44),
                      ),
                      if (_currentType == HandType.createAccount)
                        _buildText(context),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(60.0)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: S.of(context).login_message_2,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(32.0),
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                    text: S.of(context).g_key_login,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(32.0),
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        Navigator.pop(context);
                                        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                                      }
                                ),
                              ]
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(148.0),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Divider(
                      height: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    Container(
                      height: ScreenUtil().setWidth(148),
                      width: double.infinity,
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0),),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                      child: buttonStyle6(
                        context,
                            ()async{
                          final email = _unameController.value.text.trim();
                          final password = _uPasswordController.value.text.trim();
                          final confirmPassword =
                          _uPasswordConfirmController.value.text.trim();
                          if (email.isEmpty) {
                            setState(() {
                              unameErrorMessage=S.of(context).please_enter_email;
                            });
                            ToastUtils.show(S.of(context).please_enter_email);
                            return;
                          }
                          Regular regular=Regular();
                          if (!regular.isEmail(email)) {
                            setState(() {
                              unameErrorMessage=S.of(context).email_error;
                            });
                            ToastUtils.show(S.of(context).email_error);
                            return;
                          }
                          unameErrorMessage="";
                          if (password.isEmpty) {
                            setState(() {
                              uPasswordErrorMessage=S.of(context).please_enter_password;
                            });
                            ToastUtils.show(S.of(context).please_enter_password);
                            return;
                          }
                          if(!regular.isPassword(password)){
                            setState(() {
                              uPasswordErrorMessage=S.of(context).rest_Choose_password;
                            });
                            ToastUtils.show(S.of(context).rest_Choose_password);
                            return;
                          }
                          uPasswordErrorMessage="";
                          if (confirmPassword.isEmpty) {
                            setState(() {
                              uPasswordConfirmErrorMessage=S.of(context).please_enter_password;
                            });
                            ToastUtils.show(S.of(context).please_enter_password);
                            return;
                          }

                          if (password != confirmPassword) {
                            setState(() {
                              uPasswordConfirmErrorMessage=S.of(context).password_diff;
                            });
                            ToastUtils.show(S.of(context).password_diff);
                            return;
                          }
                          uPasswordConfirmErrorMessage="";

                          final code = _uCodeController.value.text.trim();

                          if (code.isEmpty) {
                            setState(() {
                              uCodeErrorMessage=S.of(context).please_enter_code;
                            });
                            ToastUtils.show(S.of(context).please_enter_code);
                            return;
                          }
                          if (_currentType == HandType.createAccount) {
                            if (!regular.isCaptcha(code)) {
                              setState(() {
                                uCodeErrorMessage=S.of(context).code_err_tips;
                              });
                              ToastUtils.show(S.of(context).code_err_tips);
                              return;
                            }
                          } else {
                            if (!regular.isCaptcha2(code)) {
                              setState(() {
                                uCodeErrorMessage=S.of(context).code_err_tips;
                              });
                              ToastUtils.show(S.of(context).code_err_tips);
                              return;
                            }
                          }
                          uCodeErrorMessage="";
                          setState(() {});
                          final inviteCode = _inviteCodeController.text.trim();
                          try {
                            setState(() {
                              sendLoad=Load.loading;
                            });
                            if (_currentType == HandType.createAccount) {
                              final data = await userInfoApi.registerEmail(email,
                                  Md5Util().generateMd5(password), code,
                                  inviteCode: inviteCode);
                              if (!context.mounted) return;
                              if (data["code"] == 200) {
                                //AmplitudeUtils.accountCreated(AccountStatus.created);
                                ToastUtils.show(S.of(context).login_message_10);
                                bool rData=await login(email,password);
                                if (!context.mounted) return;
                                if(rData==true){
                                  if(widget.pushType==0){
                                    Navigator.pop(context, true);
                                  }else{
                                    Navigator.pop(context);
                                  }
                                }else{
                                  Navigator.pop(context);
                                }
                                /*Navigator.pushAndRemoveUntil(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                                  (route) => route.isFirst || route.isCurrent,
                            );*/
                              } else {
                                ToastUtils.show(data["err"]);
                              }
                            } else {
                              final data = await userInfoApi.emailResetPwd(email,
                                  Md5Util().generateMd5(password), code);
                              if (!context.mounted) return;
                              if (data["code"] == 200) {
                                //AmplitudeUtils.accountCreated(AccountStatus.missing);
                                ToastUtils.show(S.of(context).login_message_11);
                                bool rData=await login(email,password);
                                if (!context.mounted) return;
                                if(rData==true){
                                  if(widget.pushType==0){
                                    Navigator.pop(context, true);
                                  }else{
                                    Navigator.pop(context);
                                  }
                                }else{
                                  Navigator.pop(context);
                                  /*Navigator.pushAndRemoveUntil(
                                this.context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                                // ModalRoute.withName('/'),
                                    (route) => route.isFirst || route.isCurrent,
                              );*/
                                }
                              } else {
                                ToastUtils.show(data["err"]);
                              }
                            }
                          } catch (err) {
                            ToastUtils.show(err.toString());
                          } finally {
                            setState(() {
                              sendLoad=Load.finish;
                            });
                          }
                        },
                        S.of(context).g_key_78,
                        AppThemeUtils.getColorByKey(context, sendLoad==Load.loading?AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name),
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        sendLoad==Load.loading?true:false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildText(BuildContext context) {
    Color textColor =
    AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RichText(
            text:TextSpan(
              //style: TextStyle(fontSize: scr.setSp(32.0),),
                children: [
                  TextSpan(
                    text: S.of(context).login_forgot_password,
                    style: TextStyle(fontSize: ScreenUtil().setSp(32.0), color: textColor,fontWeight: FontWeight.w500),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                      setState(() {
                        _currentType=HandType.restPassword;
                      });
                        /*Navigator.pushReplacement(context,MaterialPageRoute(
                            builder: (_) => AccountCreateAndReset(
                              type: HandType.restPassword,
                            )));*/
                      },
                  ),
                ]),
          ),
        ],
      ),
    );
  }
  Widget otpRightWidget(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(_countdown == 61 && codeLoad==Load.finish)
            InkWell(
              onTap: (){
                if(_countdown == 61){
                  final email = _unameController.value.text.trim();
                  if (email.isEmpty) {
                    setState(() {
                      unameErrorMessage=S.of(context).please_enter_email;
                    });
                    ToastUtils.show(S.of(context).please_enter_email);
                    return;
                  }
                  Regular regular=Regular();
                  if (!regular.isEmail(email)) {
                    setState(() {
                      unameErrorMessage=S.of(context).email_error;
                    });
                    ToastUtils.show(S.of(context).email_error);
                    return;
                  }
                  unameErrorMessage="";
                  sendEmailCode(email,_currentType == HandType.restPassword ? "resetPwd" : "register");
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10),horizontal: ScreenUtil().setWidth(8)),
                child: Text(
                  S.of(context).g_key_48,//login_resend,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32.0),
                    color:  AppThemeUtils.getColorByKey(context, ( _countdown == 61)?AppThemeKeys.mainBlueColor.name:AppThemeKeys.mainTextColor10.name),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if(codeLoad==Load.loading)
            SizedBox(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              child: CircularProgressIndicator(),
            ),
          if( _countdown != 61 && codeLoad==Load.finish)
            Container(
              alignment: Alignment.center,
              child: Text(
                "${S.of(context).login_message_6} $_countdown",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor3.name),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
