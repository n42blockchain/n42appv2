import 'dart:async';

import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/api/handtype.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 点击事件，返回true继续后续操作，返回false不再倒计时
typedef String? OnTap();
class CaptchaButton extends StatefulWidget {
  final OnTap onTap;
  final HandType? codeType;

  const CaptchaButton({required this.onTap, this.codeType,super.key});

  @override
  State<CaptchaButton> createState() => _CaptchaButtonState();
}

class _CaptchaButtonState extends State<CaptchaButton> with WidgetsBindingObserver{
  Timer? _timer;
  int _countdown = 61;
  String? mobile;
  DateTime? last;
  UserInfoApi? _loginApi;
  UserInfoApi get loginApi{
    if(_loginApi==null){
      _loginApi=UserInfoApi();
    }
    return _loginApi!;
  }
  Load load=Load.finish;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        if (_countdown != 61) {
          last = DateTime.now();
          _timer!.cancel();
        }
        break;
      case AppLifecycleState.resumed:
        if (_countdown != 61 && last != null) {
          final sub = DateTime.now().difference(last!).inSeconds;
          if (_countdown > sub) {
            setState(() => _countdown -= sub);
            _startTimer();
          } else {
            setState(() => _countdown = 61);
          }
        }
        break;
      default:
        break;
    }
  }

  bool canClick = true;

  void _onTaped() {
    mobile = widget.onTap();
    if (mobile == null) return;
    if (canClick) {
      canClick = false;
      if(widget.codeType == HandType.unRegister){
        /// 注销账号 单独接口
        _unRegisterAccount();
      }else{
        ///如果接口发送验证码成功 开始倒计时
        //发送验证码type 必传 register 注册验 | resetPwd 重置密码
        _sendEmailCode(mobile!,
            widget.codeType == HandType.restPassword ? "resetPwd" : "register");
      }

    }
  }


  void _unRegisterAccount() async{
    try {
      setState(() {
        load=Load.loading;
      });
      //发送 获取验证码接口
      final data = await loginApi.sendUnRegisterEmailCode();

      if (data["code"] == 200) {
        //success
        setState(() => _countdown -= 1);
        _startTimer();
        ToastUtils.show("send code success");
      } else if (data["code"] == -1402) {
        // 失败
        ToastUtils.show("email unregistered");
      } else {
        ToastUtils.show("send code error");
      }
    } finally {
      canClick = true;
      setState(() {
        load=Load.finish;
      });
    }
  }



  void _sendEmailCode(String email, String type) async {
    try {
      setState(() {
        load=Load.loading;
      });
      //发送 获取验证码接口
      final data = await loginApi.sendEmailCode(email, type);
      if (data["code"] == 200) {
        //success
        setState(() => _countdown -= 1);
        _startTimer();
        ToastUtils.show("send code success");
      } else if (data["code"] == -1402) {
        // 失败
        ToastUtils.show("email unregistered");
      } else {
        ToastUtils.show("send code error");
      }
    } finally {
      canClick = true;
      setState(() {
        load=Load.finish;
      });
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

  @override
  Widget build(BuildContext context) {
    if(load==Load.loading){
      return Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(28), vertical: ScreenUtil().setWidth(12)),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        alignment: Alignment.center,
        child: Container(
          width: ScreenUtil().setWidth(40.0),
          height: ScreenUtil().setWidth(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    return GestureDetector(
      onTap: _countdown == 61 ? _onTaped : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(28), vertical: ScreenUtil().setWidth(12)),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Text(
          _countdown == 61
              ? S.of(context).rest_Verification_code
              : '${_countdown}s',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
