import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:n42appv2/application.dart';

class ToastUtils{
  static show(String s){
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 7,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
        textColor: Color(0xffffffff),
        fontSize: 14.0
    );
  }

  ///----------自定义ui toast-------------

  static  FToast? fToast;

  /// 1 、使用时先init
  static  init(BuildContext context){
    fToast ??= FToast();
    fToast?.init(context);

  }

  ///2 、可修改样式的toast
  static showFtToast({Widget? child,String? title,int duration=2}){
    fToast?.showToast(
      child:child ??  _buildChild(title ??""),
      gravity: ToastGravity.CENTER,
      toastDuration:  Duration(seconds: duration),
    );

  }

  /// 3 、destory
  static dispose(){
    if(fToast != null){
      fToast!.removeCustomToast();
    }

  }
  static Widget _buildChild(String title){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.blueGrey,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:  [
          //const Icon(Icons.check),
          Text(title,style: TextStyle(color: AppThemeUtils.getColorByKey(Application.navigatorKey.currentContext, AppThemeKeys.mainTextColor.name)),),
        ],
      ),
    );
  }
}