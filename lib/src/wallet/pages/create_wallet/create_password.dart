import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/src/login/widgets/login_title.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:provider/provider.dart';

class CreatePassword extends StatefulWidget {
  WalletInfo wInfo;
  String createMetod;//Create,Import,PrivateKey
  CreatePassword(this.wInfo,{this.createMetod="Create",super.key});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  final TextEditingController _titleController = TextEditingController();
  TextEditingController _uPasswordController = TextEditingController();
  TextEditingController _uPasswordConfirmController = TextEditingController();
  FocusNode _uPasswordFocusNode = FocusNode();
  FocusNode _titleFocusNode = FocusNode();
  FocusNode _uPasswordConfirmFocusNode = FocusNode();
  String titleErrorMessage="";
  String uPasswordErrorMessage="";
  String uPasswordConfirmErrorMessage="";
  bool showPwd1=true;
  bool showPwd2=true;
  @override
  void dispose() {
    // TODO: implement dispose
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
    // TODO: implement initState
    widget.wInfo.walletName="Account${Provider.of<WalletActionProvider>(context,listen: false).walletInfoLsit.length+1}";
    _titleController.text=widget.wInfo.walletName??"";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> titleChild=[
      Container(
        height: ScreenUtil().setWidth(10.0),
        width: ScreenUtil().setWidth(88.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
      ),
      SizedBox(width: ScreenUtil().setWidth(20.0),),
      Container(
        height: ScreenUtil().setWidth(10.0),
        width: ScreenUtil().setWidth(88.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
      ),
    ];
    if(widget.createMetod=="Create"){
      titleChild.addAll([
        SizedBox(width: ScreenUtil().setWidth(20.0),),
        Container(
          height: ScreenUtil().setWidth(10.0),
          width: ScreenUtil().setWidth(88.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(20.0),),
        Container(
          height: ScreenUtil().setWidth(10.0),
          width: ScreenUtil().setWidth(88.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
      ]);
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
                      child: TextFieldStyle3(
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
                      title: '${S.of(context).login_password}',
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
                      must: true,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: ScreenUtil().setWidth(108.0),
                      ),
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(10),bottom: ScreenUtil().setWidth(20),),
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
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: ButtonStyle6(context,
                            ()async{
                      String wName=_titleController.text.trim();
                      if(wName.isEmpty){
                        titleErrorMessage=S.of(context).g_key_wallet_c34;
                        ToastUtils.show(titleErrorMessage);
                        return;
                      }
                      setState(() {
                        titleErrorMessage="";
                      });
                      // 数据的校验
                      final password = _uPasswordController.text.trim();
                      final rPassword = _uPasswordConfirmController.text.trim();
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
