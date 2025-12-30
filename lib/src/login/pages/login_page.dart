import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/api/handtype.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/login/pages/account_create_and_reset.dart';
import 'package:n42appv2/src/login/widgets/login_title.dart';
import 'package:n42appv2/src/login/widgets/user_protocol.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:n42appv2/src/utils/md5_util.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Login Page - Migrated to Riverpod
/// 
/// Handles user authentication
class LoginPage extends ConsumerStatefulWidget {
  int type; // 0 push, 1 content
  LoginPage({this.type = 0, super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _unameController = TextEditingController();
  final TextEditingController _uPasswordController = TextEditingController();
  final FocusNode _unameFocusNode=FocusNode();
  final FocusNode _uPasswordFocusNode=FocusNode();
  String unameErrorMessage="";
  String uPasswordErrorMessage="";
  bool isSelectedUserProtocol = false;
  bool showPwd=true;//显示密码
  Load load=Load.finish;

  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _unameController.dispose();
    _uPasswordController.dispose();
    _unameFocusNode.dispose();
    _uPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastUtils.init(context);
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).login_button_text,
      ),
      // backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
          child:Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Container(
                    padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
                          child: Text(
                            S.of(context).g_key_login,
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
                        TextFieldStyle3(
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
                          height: ScreenUtil().setHeight(20),
                        ),
                        LoginTitle(
                          title: S.of(context).login_password,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                          must: true,
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(10),
                        ),
                        TextFieldStyle3(
                            context,
                            onEditingComplete:(){
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            controller:_uPasswordController,
                            focusNode: _uPasswordFocusNode,
                            hintText:S.of(context).login_password,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            //bgColor: Colors.transparent,
                            //padding: EdgeInsets.all(0),
                            hintStyle: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
                              fontSize: ScreenUtil().setSp(30.0),
                            ),
                            obscure: showPwd,
                            rightWidget1: Container(
                              width: ScreenUtil().setWidth(50.0),
                              height: ScreenUtil().setWidth(50.0),
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/login/${showPwd?"icon_denglu_yincang":"icon_denglu_xianshi"}.png',
                                width: ScreenUtil().setWidth(34.0),
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                              ),
                            ),
                            rightOnTap1: (){
                              setState(() {
                                showPwd=!showPwd;
                              });
                            }
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(44),
                        ),
                        _buildText(context),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(60.0)),
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: S.of(context).login_message_1,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(32.0),
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                      text: S.of(context).Create_account,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(32.0),
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          bool? rData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountCreateAndReset(type: HandType.createAccount,pushType: widget.type,)));
                                          if(rData==true){
                                            Navigator.pop(context);
                                          }
                                        }
                                  ),
                                ]
                            ),
                          ),
                        ),
                        // google和facebook快捷登陆
                        //  OtherLogin(isSelectedUserProtocol: isSelectedUserProtocol,),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    UserProtocol(
                      onChanged: (value) {
                        isSelectedUserProtocol = value;
                        setState(() {});
                      },
                    ),
                    Divider(
                      height: 1,
                      endIndent: 0,
                      indent: 0,
                    ),
                    Container(
                      height: ScreenUtil().setWidth(148),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0),),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                      child: ButtonStyle6(
                        context,
                            () async {
                          final email = _unameController.value.text.trim();
                          final password = _uPasswordController.value.text.trim();
                          if (email.isEmpty) {
                            setState(() {
                              unameErrorMessage=S.of(context).please_enter_email;
                            });
                            ToastUtils.show(S.of(context).please_enter_email);
                            return;
                          }
                          if (!Regular().isEmail(email)) {
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
                          uPasswordErrorMessage="";
                          setState(() {});
                          if (!isSelectedUserProtocol) {
                            ToastUtils.show(S.of(context).selected_user_protocol);
                            return;
                          }
                          try {
                            setState(() {
                              load=Load.loading;
                            });
                            UserInfoApi loginApi=UserInfoApi();
                            final data = await loginApi.login(
                                email, Md5Util().generateMd5(password));
                            if (data != null) {
                              if (data["code"] == 200) {
                                //AmplitudeUtils.accountLoggedIn();
                                UserInfo userInfo = UserInfo.fromJson(data['data']);
                                await SPUtil().saveUserInfo(userInfo);
                                // 使用 Riverpod 设置用户信息
                                ref.read(currentUserProvider.notifier).setUser(
                                  SharedUserInfo.fromLegacyUserInfo(userInfo),
                                );
                                await AppGlobals.login(userInfo);
                                if(widget.type==0){
                                  Navigator.pop(context);
                                }
                                /*Navigator.pushAndRemoveUntil(this.context,
                                    MaterialPageRoute(builder: (_) => App()),
                                        (route) => false);*/
                              } else if (data["code"] == -403) {
                                ToastUtils.showFtToast(
                                    title: S.of(this.context).code_403);
                              } else if (data["code"] == -1301) {
                                ToastUtils.showFtToast(
                                    title: S.of(this.context).g_key_error_1301);
                              }else {
                                ToastUtils.showFtToast(title: data["err"]);
                              }
                            }
                          } catch (err) {
                            ToastUtils.show(err.toString());
                          } finally {
                            setState(() {
                              load=Load.finish;
                            });
                            //EasyLoading.dismiss();
                          }
                        },
                        S.of(context).login_button_text,
                        AppThemeUtils.getColorByKey(context, load==Load.loading?AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name),
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        load==Load.loading,
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
    return Container(
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
                      ..onTap = () async{
                        bool? rData=await Navigator.push(context,MaterialPageRoute(
                            builder: (_) =>  AccountCreateAndReset(
                              type: HandType.restPassword,
                              pushType: widget.type,
                            )));
                        if(rData==true){
                          Navigator.pop(context);
                        }
                      },
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  void init() async {
    SPUtil sPUtils=SPUtil();
    isSelectedUserProtocol = await sPUtils.getReadLoginClause();
    setState(() {});
    final data = await sPUtils.getUserInfo();
    if (data != null) {
      UserInfo info = UserInfo.fromJson(data!);
      if (data != null) {
        _unameController.text = info.email??"";
      }
      if (mounted) {
        setState(() {});
      }
    }
  }
}
