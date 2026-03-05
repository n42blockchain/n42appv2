import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:n42_wallet/core/app/app_globals.dart';

class ToastUtils {
  static void show(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 7,
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
      textColor: const Color(0xffffffff),
      fontSize: 14.0,
    );
  }

  static FToast? fToast;

  static void init(BuildContext context) {
    fToast ??= FToast();
    fToast?.init(context);
  }

  static void showFtToast({Widget? child, String? title, int duration = 2}) {
    fToast?.showToast(
      child: child ?? _buildChild(title ?? ""),
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: duration),
    );
  }

  static void dispose() {
    fToast?.removeCustomToast();
  }

  static Widget _buildChild(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.blueGrey,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  AppGlobals.navigatorKey.currentContext,
                  AppThemeKeys.mainTextColor.name),
            ),
          ),
        ],
      ),
    );
  }
}
