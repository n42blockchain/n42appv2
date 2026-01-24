import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockScreenResetPassword extends ConsumerStatefulWidget{
  final int type;//0 设置新密码，1重设密码
  const LockScreenResetPassword(this.type,{super.key});
  @override
  ConsumerState<LockScreenResetPassword> createState()=>_LockScreenResetPasswordState();
}
class _LockScreenResetPasswordState extends ConsumerState<LockScreenResetPassword>{
  TextEditingController oldEditingController=TextEditingController();//旧密码
  TextEditingController newEditingController=TextEditingController();//新密码
  TextEditingController confirmEditingController=TextEditingController();//确认密码
  FocusNode oldFocusNode=FocusNode();
  FocusNode newFocusNode=FocusNode();
  FocusNode confirmFocusNode=FocusNode();
  bool obscure_old=true;
  bool obscure_new=true;
  bool obscure_confirm=true;
  String oldErrorMessage="";
  String newErrorMessage="";
  String confirmErrorMessage="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    oldEditingController.dispose();
    newEditingController.dispose();
    confirmEditingController.dispose();
    oldFocusNode.dispose();
    newFocusNode.dispose();
    confirmFocusNode.dispose();
    super.dispose();
  }
  sure(){
    final screenLockState = ref.read(screenLockProvider);
    
    if(widget.type==1){
      //旧密码
      String oldStr=oldEditingController.text;
      bool oldOk=checkStrLength(oldStr);
      if(oldOk){
        oldErrorMessage="";
      }else{
        oldErrorMessage="6-digit number";
        setState(() {
        });
        return;
      }
      if(oldStr==screenLockState.lockPassword){
        oldErrorMessage="";
      }
      else{
        oldErrorMessage=S.of(context).g_key_t_34;
        setState(() {
        });
        return;
      }
    }
    //新密码
    String newStr=newEditingController.text;
    bool newOk=checkStrLength(newStr);
    if(newOk){
      newErrorMessage="";
    }else{
      newErrorMessage="6-digit number";
      setState(() {
      });
      return;
    }
    Regular regular=Regular();
    newOk=regular.regular_nums(newStr);
    if(newOk){
      newErrorMessage="";
    }else{
      newErrorMessage="6-digit number";
      setState(() {
      });
      return;
    }
    //确认密码
    String confirmStr=confirmEditingController.text;
    bool confirmOk=checkStrLength(confirmStr);
    if(confirmOk){
      confirmErrorMessage="";
    }else{
      confirmErrorMessage="6-digit number";
      setState(() {
      });
      return;
    }
    confirmOk=regular.regular_nums(confirmStr);
    if(confirmOk){
      confirmErrorMessage="";
    }else{
      confirmErrorMessage="6-digit number";
      setState(() {
      });
      return;
    }
    if(newStr==confirmStr){
      confirmErrorMessage="";
    }else{
      confirmErrorMessage=S.of(context).password_diff;
      setState(() {
      });
      return;
    }
    ref.read(screenLockProvider.notifier).setLockPassword(confirmStr);
    Navigator.pop(context,true);
  }
  //检查输入字符串的位数
  checkStrLength(String inputStr){
    int len=inputStr.length;
    if(len ==6){
      return true;
    }else{
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_lock_key9,
        ),
        body: SafeArea(
          child: oldWidget(),
        ),

    );
  }
  oldWidget(){
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(30.0),
              top: ScreenUtil().setWidth(60.0),
            ),
            child: Column(
              children: [
                if(widget.type==1)
                  oldPWWidget(),
                newPWWidget(),
                confirmPWWidget(),
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
              Divider(
                height: ScreenUtil().setWidth(1),
                indent: 0,
                endIndent: 0,
              ),
              Container(
                height: ScreenUtil().setWidth(148.0),
                width: double.infinity,
                padding: EdgeInsets.all(
                  ScreenUtil().setWidth(30.0),
                ),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                child:ButtonStyle2(
                  context,
                      ()async{
                    sure();
                  },
                  S.of(context).g_key_78,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  //旧密码
  oldPWWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(S.of(context).g_lock_key10),
          passwordWidget(
            oldEditingController,
            oldFocusNode,
            "6-digit number",
            obscure_old,
                (){
              FocusScope.of(context).requestFocus(newFocusNode);
            },
                (){
              setState(() {
                obscure_old=!obscure_old;
              });
            },
          ),
          errorMessageWidget(oldErrorMessage),
          Divider(
            height: ScreenUtil().setWidth(1.0),
            indent: 0,
            endIndent: 0,
          ),
        ],
      ),
    );
  }
  //旧密码
  newPWWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(S.of(context).g_lock_key11),
          passwordWidget(
            newEditingController,
            newFocusNode,
            S.of(context).g_lock_key13,
            obscure_new,
                (){
              FocusScope.of(context).requestFocus(confirmFocusNode);
            }, (){
            setState(() {
              obscure_new=!obscure_new;
            });
          },
          ),
          errorMessageWidget(newErrorMessage),
          Divider(
            height: ScreenUtil().setWidth(1.0),
            indent: 0,
            endIndent: 0,
          ),
        ],
      ),
    );
  }
  //旧密码
  confirmPWWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(S.of(context).g_lock_key12),
          passwordWidget(
              confirmEditingController,
              confirmFocusNode,
              S.of(context).g_lock_key13,
              obscure_confirm,
                  (){
                if(widget.type==1){
                  FocusScope.of(context).requestFocus(oldFocusNode);
                }else{
                  FocusScope.of(context).requestFocus(newFocusNode);
                }
              },
                  (){
                setState(() {
                  obscure_confirm=!obscure_confirm;
                });
              }
          ),
          errorMessageWidget(confirmErrorMessage),
          Divider(
            height: ScreenUtil().setWidth(1.0),
            indent: 0,
            endIndent: 0,
          ),
        ],
      ),
    );
  }
  titleWidget(String title){
    return Text(
      title,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        fontSize: ScreenUtil().setSp(30.0),
      ),
    );
  }
  passwordWidget(
      TextEditingController controller,
      FocusNode fn,
      String hintStr,
      bool obscure,
      Function finishTap,
      Function obscureChange
      ){
    return Container(
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(72.0),
        minHeight: ScreenUtil().setWidth(72.0),
      ),
      child: TextField(
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
        obscureText:obscure,
        controller: controller,
        focusNode: fn,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hintStr,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
          suffix: InkWell(
            onTap: (){
              obscureChange();
            },
            child: SizedBox(
              height: ScreenUtil().setSp(40.0),
              width: ScreenUtil().setSp(40.0),
              child: Image.asset(
                "assets/login/${obscure?'icon_denglu_yincang':'icon_denglu_xianshi'}.png",
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ),
        ),
        maxLines: 1,
        onEditingComplete: (){
          finishTap();
        },
      ),
    );
  }
  errorMessageWidget(String message){
    if(message==""){
      return SizedBox();
    }
    return Text(
      message,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
        fontSize: ScreenUtil().setSp(20.0),
      ),
    );
  }
}