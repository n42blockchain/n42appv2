import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/login/widgets/login_title.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class CreatePassword extends ConsumerStatefulWidget {
  final WalletInfo wInfo;
  final String createMetod;//Create,Import,PrivateKey
  const CreatePassword(this.wInfo,{this.createMetod="Create",super.key});

  @override
  ConsumerState<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends ConsumerState<CreatePassword> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _uPasswordController = TextEditingController();
  final TextEditingController _uPasswordConfirmController = TextEditingController();
  final FocusNode _uPasswordFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _uPasswordConfirmFocusNode = FocusNode();
  String titleErrorMessage="";
  String uPasswordErrorMessage="";
  String uPasswordConfirmErrorMessage="";
  bool showPwd1=true;
  bool showPwd2=true;
  @override
  void dispose() {
    _titleController.dispose();
    _uPasswordController.dispose();
    _uPasswordConfirmController.dispose();
    _titleFocusNode.dispose();
    _uPasswordFocusNode.dispose();
    _uPasswordConfirmFocusNode.dispose();
    super.dispose();
  }
  @override
  void initState() {
    widget.wInfo.walletName="Account${ref.read(wapBridgeProvider).walletInfoLsit.length+1}";
    _titleController.text=widget.wInfo.walletName??"";
    super.initState();
  }
  Widget _stepIndicator() {
    return Container(
      height: ScreenUtil().setWidth(10.0),
      width: ScreenUtil().setWidth(88.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
      ),
    );
  }

  Widget _stepGap() => SizedBox(width: ScreenUtil().setWidth(20.0));

  @override
  Widget build(BuildContext context) {
    final int stepCount = widget.createMetod == "Create" ? 4 : 2;
    final List<Widget> titleChild = [];
    for (int i = 0; i < stepCount; i++) {
      if (i > 0) titleChild.add(_stepGap());
      titleChild.add(_stepIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        title: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: titleChild,
          ),
        ),
        actions: [
          SizedBox(width: ScreenUtil().setWidth(130.0),),
        ],
        leadingWidth: ScreenUtil().setWidth(130.0),
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
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0),bottom: ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0),),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_key_wallet_c47,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    LoginTitle(
                      title: S.of(context).g_key_wallet_c48,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                      must: true,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: ScreenUtil().setWidth(108.0),
                      ),
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(10),bottom: ScreenUtil().setWidth(20),),
                      width: double.infinity,
                      child: textFieldStyle3(
                        context,
                        onEditingComplete:(){
                          FocusScope.of(context).requestFocus(_uPasswordFocusNode);
                          },
                        height: ScreenUtil().setWidth(108.0),
                        maxLengths: AppConfig.walletNameMaxLength,
                        controller:_titleController,
                        focusNode: _titleFocusNode,
                        hintText:S.of(context).g_key_wallet_c34,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        errorMessage: titleErrorMessage,
                          //bgColor: Colors.transparent,
                          //padding: EdgeInsets.all(0),
                        hintStyle: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
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
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(10),bottom: ScreenUtil().setWidth(20),),
                      width: double.infinity,
                      child: textFieldStyle3(
                          context,
                          onEditingComplete:(){
                            FocusScope.of(context).requestFocus(_uPasswordConfirmFocusNode);
                          },
                          height: ScreenUtil().setWidth(108.0),
                          controller:_uPasswordController,
                          focusNode: _uPasswordFocusNode,
                          hintText:S.of(context).rest_Choose_password,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
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
                      child: textFieldStyle3(
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
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: buttonStyle6(context,
                            ()async{
                      final wName=_titleController.text.trim();
                      final password = _uPasswordController.text.trim();
                      final rPassword = _uPasswordConfirmController.text.trim();

                      // 数据的校验
                      String titleErr="", pwdErr="", confirmErr="";
                      if(wName.isEmpty){
                        titleErr=S.of(context).g_key_wallet_c34;
                      } else if (password.isEmpty) {
                        pwdErr=S.of(context).g_key_21;
                      } else if (!Regular().isPassword(password)) {
                        pwdErr=S.of(context).rest_Choose_password;
                      } else if (rPassword.isEmpty) {
                        confirmErr=S.of(context).g_key_21;
                      } else if (password != rPassword) {
                        confirmErr=S.of(context).g_key_25;
                      }

                      titleErrorMessage=titleErr;
                      uPasswordErrorMessage=pwdErr;
                      uPasswordConfirmErrorMessage=confirmErr;

                      final firstError = [titleErr, pwdErr, confirmErr].firstWhere((e) => e.isNotEmpty, orElse: () => "");
                      if(firstError.isNotEmpty){
                        ToastUtils.show(firstError);
                        setState(() {});
                        return;
                      }

                      widget.wInfo.password=password;
                      widget.wInfo.walletName=wName;
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateFinish(wInfo:widget.wInfo,createMetod: widget.createMetod,)));
                        },
                        S.of(context).g_key_115,
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        false
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
