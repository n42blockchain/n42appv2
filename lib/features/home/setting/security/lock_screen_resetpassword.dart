import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
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
  bool obscureOld=true;
  bool obscureNew=true;
  bool obscureConfirm=true;
  String oldErrorMessage="";
  String newErrorMessage="";
  String confirmErrorMessage="";

  @override
  void dispose() {
    oldEditingController.dispose();
    newEditingController.dispose();
    confirmEditingController.dispose();
    oldFocusNode.dispose();
    newFocusNode.dispose();
    confirmFocusNode.dispose();
    super.dispose();
  }
  /// Validate a field: check length and numeric format.
  /// Returns an error message or empty string on success.
  String _validatePassword(String value) {
    if (!checkStrLength(value)) return S.of(context).g_lock_key13;
    if (!Regular().regularNums(value)) return S.of(context).g_lock_key13;
    return "";
  }

  void sure(){
    final screenLockState = ref.read(screenLockProvider);

    if(widget.type==1){
      //旧密码
      final oldStr = oldEditingController.text;
      oldErrorMessage = checkStrLength(oldStr) ? "" : S.of(context).g_lock_key13;
      if(oldErrorMessage.isEmpty && oldStr != screenLockState.lockPassword){
        oldErrorMessage = S.of(context).g_key_t_34;
      }
      if(oldErrorMessage.isNotEmpty){ setState(() {}); return; }
    }
    //新密码
    final newStr = newEditingController.text;
    newErrorMessage = _validatePassword(newStr);
    if(newErrorMessage.isNotEmpty){ setState(() {}); return; }

    //确认密码
    final confirmStr = confirmEditingController.text;
    confirmErrorMessage = _validatePassword(confirmStr);
    if(confirmErrorMessage.isEmpty && newStr != confirmStr){
      confirmErrorMessage = S.of(context).password_diff;
    }
    if(confirmErrorMessage.isNotEmpty){ setState(() {}); return; }

    ref.read(screenLockProvider.notifier).setLockPassword(confirmStr);
    Navigator.pop(context,true);
  }
  //检查输入字符串的位数
  bool checkStrLength(String inputStr) => inputStr.length == 6;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_lock_key9,
        ),
        body: SafeArea(
          child: oldWidget(),
        ),

    );
  }
  Widget oldWidget(){
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
                child: buttonStyle2(context, sure, S.of(context).g_key_78),
              ),
            ],
          ),
        ),
      ],
    );
  }
  /// Builds a password field section with title, input, error, and divider.
  Widget _buildPasswordSection({
    required String title,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintStr,
    required bool obscure,
    required VoidCallback onFinish,
    required VoidCallback onToggleObscure,
    required String errorMessage,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(title),
          passwordWidget(controller, focusNode, hintStr, obscure, onFinish, onToggleObscure),
          errorMessageWidget(errorMessage),
          Divider(height: ScreenUtil().setWidth(1.0), indent: 0, endIndent: 0),
        ],
      ),
    );
  }

  Widget oldPWWidget() => _buildPasswordSection(
    title: S.of(context).g_lock_key10,
    controller: oldEditingController,
    focusNode: oldFocusNode,
    hintStr: "6-digit number",
    obscure: obscureOld,
    onFinish: () => FocusScope.of(context).requestFocus(newFocusNode),
    onToggleObscure: () => setState(() => obscureOld = !obscureOld),
    errorMessage: oldErrorMessage,
  );

  Widget newPWWidget() => _buildPasswordSection(
    title: S.of(context).g_lock_key11,
    controller: newEditingController,
    focusNode: newFocusNode,
    hintStr: S.of(context).g_lock_key13,
    obscure: obscureNew,
    onFinish: () => FocusScope.of(context).requestFocus(confirmFocusNode),
    onToggleObscure: () => setState(() => obscureNew = !obscureNew),
    errorMessage: newErrorMessage,
  );

  Widget confirmPWWidget() => _buildPasswordSection(
    title: S.of(context).g_lock_key12,
    controller: confirmEditingController,
    focusNode: confirmFocusNode,
    hintStr: S.of(context).g_lock_key13,
    obscure: obscureConfirm,
    onFinish: () => FocusScope.of(context).requestFocus(
      widget.type == 1 ? oldFocusNode : newFocusNode,
    ),
    onToggleObscure: () => setState(() => obscureConfirm = !obscureConfirm),
    errorMessage: confirmErrorMessage,
  );
  Widget titleWidget(String title){
    return Text(
      title,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        fontSize: ScreenUtil().setSp(30.0),
      ),
    );
  }
  Widget passwordWidget(
      TextEditingController controller,
      FocusNode fn,
      String hintStr,
      bool obscure,
      VoidCallback finishTap,
      VoidCallback obscureChange,
      ){
    return SizedBox(
      height: ScreenUtil().setWidth(72.0),
      child: TextField(
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
        obscureText: obscure,
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
            onTap: obscureChange,
            child: SizedBox(
              height: ScreenUtil().setSp(40.0),
              width: ScreenUtil().setSp(40.0),
              child: Image.asset(
                "assets/login/${obscure ? 'icon_denglu_yincang' : 'icon_denglu_xianshi'}.png",
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ),
        ),
        maxLines: 1,
        onEditingComplete: finishTap,
      ),
    );
  }
  Widget errorMessageWidget(String message){
    if(message.isEmpty) return const SizedBox.shrink();
    return Text(
      message,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
        fontSize: ScreenUtil().setSp(20.0),
      ),
    );
  }
}