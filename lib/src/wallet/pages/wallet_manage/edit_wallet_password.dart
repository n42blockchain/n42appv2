import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/widgets/login_title.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EditWalletPassword extends StatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const EditWalletPassword(this.walletInfo,this.walletIndex,{super.key});

  @override
  State<EditWalletPassword> createState() => _EditWalletPasswordState();
}

class _EditWalletPasswordState extends State<EditWalletPassword> {
  final TextEditingController _uPasswordController = TextEditingController();
  final TextEditingController _uPasswordConfirmController = TextEditingController();
  final TextEditingController _lPasswordController = TextEditingController();
  final FocusNode _uPasswordFocusNode = FocusNode();
  final FocusNode _uPasswordConfirmFocusNode = FocusNode();
  final FocusNode _lPasswordFocusNode = FocusNode();
  String uPasswordErrorMessage="";
  String uPasswordConfirmErrorMessage="";
  String lPasswordErrorMessage="";
  bool showPwd1=true;
  bool showPwd2=true;
  bool showPwd=true;//显示密码
  Load load=Load.finish;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _uPasswordController.dispose();
    _uPasswordConfirmController.dispose();
    _lPasswordController.dispose();
    _uPasswordFocusNode.dispose();
    _uPasswordConfirmFocusNode.dispose();
    _lPasswordFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:S.of(context).g_key_206,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoginTitle(
                      title: S.of(context).g_key_207,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                      must: true,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: ScreenUtil().setWidth(108.0),
                      ),
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(10),bottom: ScreenUtil().setWidth(20)),
                      width: double.infinity,
                      child: TextFieldStyle3(
                          context,
                          onEditingComplete:(){
                            FocusScope.of(context).requestFocus(_uPasswordFocusNode);
                          },
                          height: ScreenUtil().setWidth(108.0),
                          controller:_lPasswordController,
                          focusNode: _lPasswordFocusNode,
                          hintText:S.of(context).rest_Choose_password,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          //bgColor: Colors.transparent,
                          //padding: EdgeInsets.all(0),
                          hintStyle: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                          obscure: showPwd,
                          errorMessage: lPasswordErrorMessage,
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
                    ),
                    LoginTitle(
                      title: S.of(context).login_password,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                      must: true,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: ScreenUtil().setWidth(108.0),
                      ),
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(10),bottom: ScreenUtil().setWidth(20)),
                      width: double.infinity,
                      child: TextFieldStyle3(
                          context,
                          onEditingComplete:(){
                            FocusScope.of(context).requestFocus(_uPasswordConfirmFocusNode);
                          },
                          height: ScreenUtil().setWidth(108.0),
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
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            ),
                          ),
                          rightOnTap1: (){
                            setState(() {
                              showPwd1=!showPwd1;
                            });
                          }
                      ),
                    ),
                    LoginTitle(
                      title: S.of(context).rest_Confirm_password,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                      must: true,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: ScreenUtil().setWidth(108.0),
                      ),
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(10),),
                      width: double.infinity,
                      child: TextFieldStyle3(
                          context,
                          onEditingComplete:(){
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          height: ScreenUtil().setWidth(108.0),
                          controller:_uPasswordConfirmController,
                          focusNode: _uPasswordConfirmFocusNode,
                          hintText:S.of(context).repeatPassword,
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
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            ),
                          ),
                          rightOnTap1: (){
                            setState(() {
                              showPwd2=!showPwd2;
                            });
                          }
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(148.0),),
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
                    height: ScreenUtil().setWidth(148.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                    width: double.infinity,
                    child: ButtonStyle6(context,
                          ()async{
                        // 数据的校验
                        final password = _uPasswordController.text.trim();
                        final rPassword = _uPasswordConfirmController.text.trim();
                        final lPassword = _lPasswordController.text.trim();
                        if (password.isEmpty) {
                          uPasswordErrorMessage=S.of(context).g_key_21;
                          ToastUtils.show(uPasswordErrorMessage);
                          return;
                        }
                        //if (password.length < AppConfig.walletPasswordLength) {
                        if (!Regular().isPassword(password)) {
                          uPasswordErrorMessage=S.of(context).rest_Choose_password;//S.of(context).g_key_wallet_m7(AppConfig.walletPasswordLength);
                          ToastUtils.show(uPasswordErrorMessage);
                          return;
                        }
                        setState(() {
                          uPasswordErrorMessage="";
                        });
                        if (rPassword.isEmpty) {
                          uPasswordConfirmErrorMessage=S.of(context).g_key_21;
                          ToastUtils.show(uPasswordConfirmErrorMessage);
                          return;
                        }
                        if (password != rPassword) {
                          uPasswordConfirmErrorMessage=S.of(context).g_key_25;
                          ToastUtils.show(uPasswordConfirmErrorMessage);
                          return;
                        }
                        setState(() {
                          uPasswordConfirmErrorMessage="";
                        });
                        if(lPassword.isEmpty){
                          lPasswordErrorMessage=S.of(context).g_key_21;
                          ToastUtils.show(lPasswordErrorMessage);
                          return;
                        }
                        if(widget.walletInfo.password != lPassword.trim()){
                          lPasswordErrorMessage=S.of(context).g_key_146;
                          ToastUtils.show(lPasswordErrorMessage);
                          return;
                        }
                        setState(() {
                          lPasswordErrorMessage="";
                        });
                        try {
                          setState(() {
                            load=Load.loading;
                          });
                          widget.walletInfo.password=password;
                          final wap = Provider.of<WalletActionProvider>(context,listen: false);
                          final successMessage = S.of(context).g_key_185;
                          await wap.saveWalletInfo(widget.walletInfo,widget.walletIndex);
                          if (!context.mounted) return;
                          ToastUtils.show(successMessage);
                          Navigator.pop(context,widget.walletInfo);
                        } catch (err) {
                          ToastUtils.show(err.toString());
                        } finally {
                          setState(() {
                            load=Load.finish;
                          });
                        }
                      },
                      S.of(context).g_key_115,
                      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
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
    );
  }
}
