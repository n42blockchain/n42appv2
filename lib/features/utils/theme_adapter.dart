import 'package:flutter/material.dart';

class ThemeAdapter {
  static const _accent = Color(0xFF448BDF);
  static const _lightText = Color(0xff222222);
  static const _darkText = Color(0xffffffff);

  static ThemeData themeDataLight = ThemeData.light().copyWith(
    scaffoldBackgroundColor:
        AppThemeUtils.lightMap[AppThemeKeys.backGroundColor.name],
    primaryColor: const Color(0xffF9f9f9),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(color: _lightText),
      actionsIconTheme: IconThemeData(color: _lightText),
      toolbarTextStyle: TextStyle(color: _lightText),
      iconTheme: IconThemeData(color: _lightText),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: _accent),
      unselectedIconTheme: IconThemeData(color: _darkText),
      selectedItemColor: _accent,
      unselectedItemColor: _lightText,
    ),
    iconTheme: const IconThemeData(color: _lightText),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Color(0xFFBAC2CC), fontSize: 16),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: _accent),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xffc6c6c6)),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xffd9445a)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
    ),
    buttonTheme: const ButtonThemeData(buttonColor: _accent),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _accent,
      linearTrackColor: Colors.white24,
      refreshBackgroundColor: Colors.white24,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xffD9D9D9),
      space: 0,
      thickness: 1,
      indent: 10,
      endIndent: 10,
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: _accent),
  );

  static ThemeData themeDataDark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor:
        AppThemeUtils.darkMap[AppThemeKeys.backGroundColor.name],
    cardTheme: const CardThemeData(
      shadowColor: Color(0xff444444),
      color: Color(0xff2b2b2b),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(color: _darkText),
      toolbarTextStyle: TextStyle(color: _darkText),
      actionsIconTheme: IconThemeData(color: _darkText),
      iconTheme: IconThemeData(color: _darkText),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: _accent),
      unselectedIconTheme: IconThemeData(color: _darkText),
      selectedItemColor: _accent,
      unselectedItemColor: Color(0xff888888),
    ),
    iconTheme: const IconThemeData(color: _darkText),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Color(0xFFBEBEBE), fontSize: 16),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: _accent),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff545454)),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xffd9445a)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
    ),
    buttonTheme: const ButtonThemeData(buttonColor: _accent),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _accent,
      linearTrackColor: Colors.white24,
      refreshBackgroundColor: Colors.white24,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xff303239),
      space: 0,
      thickness: 1,
      indent: 10,
      endIndent: 10,
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: _accent),
  );
}

class AppThemeUtils {
  static Color getColorByKey(BuildContext? context, String key) {
    if (context == null) return Colors.red;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? darkMap : lightMap)[key] ?? const Color(0xff000000);
  }

  /// 亮色颜色定义
  static final lightMap = {
    AppThemeKeys.backGroundColor.name: const Color(0xffF5F5F5),
    AppThemeKeys.backGroundColor2.name: const Color(0xffFFF3F3),
    AppThemeKeys.backGroundColor3.name: const Color(0xffFFFFFF),
    AppThemeKeys.linearGradient1.name: const Color(0xFFFFFFFF),
    AppThemeKeys.linearGradient2.name: Colors.white54,
    AppThemeKeys.mainBlueColor.name: const Color(0xFF1976F9),
    AppThemeKeys.mainTextColor.name: const Color(0xFF222222),
    AppThemeKeys.mainTextColor3.name: const Color(0xFFbebebe),
    AppThemeKeys.mainTextColor4.name: const Color(0xFF8A8A8E),
    AppThemeKeys.mainTextColor5.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainTextColor6.name: const Color(0xFF5C616D),
    AppThemeKeys.mainTextColor7.name: const Color(0xFF0d0d0d),
    AppThemeKeys.mainTextColor8.name: const Color(0xFF808084),
    AppThemeKeys.mainTextColor10.name: const Color(0xFF8E8E93),
    AppThemeKeys.mainWhiteColor.name: Colors.white,
    AppThemeKeys.mainBlockColor.name: Colors.black,
    AppThemeKeys.refreshBGColor.name: const Color(0xFF1976F9),
    AppThemeKeys.refreshValueColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.ff888888.name: const Color(0xFF888888),
    AppThemeKeys.itemBgColor.name: const Color(0xffffffff),
    AppThemeKeys.itemBgColor2.name: const Color(0xffF9FAFB),
    AppThemeKeys.itemBgColor4.name: const Color(0xFFFFFFFF),
    AppThemeKeys.itemBgColor5.name: const Color(0xFFEDEFF2),
    AppThemeKeys.itemBgColor6.name: const Color(0xFFE6E6E7),
    AppThemeKeys.itemBgColor8.name: const Color(0xFFEBEBEB),
    AppThemeKeys.itemTextColor.name: const Color(0xFF222222),
    AppThemeKeys.itemSubtitleTextColor.name: const Color(0xFF8F8F8F),
    AppThemeKeys.itemBorderColor.name: const Color(0xFFD9D9D9),
    AppThemeKeys.itemLineColor.name: const Color(0xFFE4E4E4),
    AppThemeKeys.errorBgColor.name: const Color(0xFFFFF3EC),
    AppThemeKeys.errorBgColor2.name:
        const Color(0xFFF03450).withAlpha(51),
    AppThemeKeys.errorTextColor.name: const Color(0xFFF03450),
    AppThemeKeys.rightTextColor.name: const Color(0xff44A677),
    AppThemeKeys.textColorOrange.name: const Color(0xFFFF6F16),
    AppThemeKeys.dividerColor.name: const Color(0xffD9D9D9),
    AppThemeKeys.mainButtonBgColor.name: const Color(0xFF1976F9),
    AppThemeKeys.mainButtonBgColor3.name: const Color(0xFFD1E4FE),
    AppThemeKeys.mainButtonTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainButtonTextColor3.name: const Color(0xFF1976F9),
    AppThemeKeys.transparentBgColor.name:
        const Color.fromRGBO(0, 0, 0, 0.2),
    AppThemeKeys.alertBgColor.name:
        const Color(0xFF000000).withAlpha(204),
    AppThemeKeys.textColorGrey.name: const Color(0xFFCDCBCB),
    AppThemeKeys.mainGreyColor.name: Colors.grey,
    AppThemeKeys.ff444444.name: const Color(0xFF444444),
    AppThemeKeys.textFieldHintColor.name: const Color(0xFFBAC2CC),
    AppThemeKeys.hintTextColor.name: const Color(0xFFCCCCCC),
    AppThemeKeys.iconTextDisableColor.name: const Color(0xffEDEFF2),
    AppThemeKeys.timeBorderColor.name: const Color(0xffD1E4FE),
  };

  /// 暗色颜色定义
  static final darkMap = {
    AppThemeKeys.backGroundColor.name: const Color(0xFF121212),
    AppThemeKeys.backGroundColor2.name: const Color(0xFF121212),
    AppThemeKeys.backGroundColor3.name: const Color(0xff000000),
    AppThemeKeys.linearGradient1.name: const Color(0xff232323),
    AppThemeKeys.linearGradient2.name: Color(0x80000000),
    AppThemeKeys.mainBlueColor.name: const Color(0xFF1976F9),
    AppThemeKeys.mainTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainTextColor3.name: const Color(0xFFbebebe),
    AppThemeKeys.mainTextColor4.name: const Color(0xFF8A8A8E),
    AppThemeKeys.mainTextColor5.name: const Color(0xFF222222),
    AppThemeKeys.mainTextColor6.name: const Color(0xFFBEBEBE),
    AppThemeKeys.mainTextColor7.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainTextColor8.name: const Color(0xFFBEBEBE),
    AppThemeKeys.mainTextColor10.name: const Color(0xFFD9D9D9),
    AppThemeKeys.mainWhiteColor.name: Colors.white,
    AppThemeKeys.mainBlockColor.name: Colors.black,
    AppThemeKeys.refreshBGColor.name: const Color(0xFF1976F9),
    AppThemeKeys.refreshValueColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.ff888888.name: Colors.white38,
    AppThemeKeys.itemBgColor.name: const Color(0xFF1E1E1E),
    AppThemeKeys.itemBgColor2.name: const Color(0xFF232427),
    AppThemeKeys.itemBgColor4.name: const Color(0xFF373739),
    AppThemeKeys.itemBgColor5.name: const Color(0xFF232323),
    AppThemeKeys.itemBgColor6.name: const Color(0xFF1E1E1E),
    AppThemeKeys.itemBgColor8.name: const Color(0xFFEBEBEB),
    AppThemeKeys.itemTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.itemSubtitleTextColor.name: const Color(0xFF8F8F8F),
    AppThemeKeys.itemBorderColor.name: const Color(0xFF303239),
    AppThemeKeys.itemLineColor.name: const Color(0x50E4E4E4),
    AppThemeKeys.errorBgColor.name: const Color(0xFFFFF3EC),
    AppThemeKeys.errorBgColor2.name:
        const Color(0xFFF03450).withAlpha(51),
    AppThemeKeys.errorTextColor.name: const Color(0xFFF03450),
    AppThemeKeys.rightTextColor.name: const Color(0xff44A677),
    AppThemeKeys.textColorOrange.name: const Color(0xFFFF6F16),
    AppThemeKeys.dividerColor.name: const Color(0xff303239),
    AppThemeKeys.mainButtonBgColor.name: const Color(0xFF1976F9),
    AppThemeKeys.mainButtonBgColor3.name: const Color(0xFF2A3D5C),
    AppThemeKeys.mainButtonTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainButtonTextColor3.name: const Color(0xFF6B9ADB),
    AppThemeKeys.transparentBgColor.name:
        const Color.fromRGBO(0, 0, 0, 0.2),
    AppThemeKeys.alertBgColor.name: const Color(0xFFffffff),
    AppThemeKeys.textColorGrey.name: const Color(0xFFCDCBCB),
    AppThemeKeys.mainGreyColor.name: Colors.grey,
    AppThemeKeys.ff444444.name: Colors.white70,
    AppThemeKeys.textFieldHintColor.name: const Color(0xFFBEBEBE),
    AppThemeKeys.hintTextColor.name: const Color(0xFF545454),
    AppThemeKeys.iconTextDisableColor.name: const Color(0xff373739),
    AppThemeKeys.timeBorderColor.name: const Color(0xff373739),
  };
}

enum AppThemeKeys {
  backGroundColor, //背景色
  backGroundColor2, //背景色2
  backGroundColor3,
  linearGradient1, //线性渐变色1
  linearGradient2, //线性渐变色2
  mainBlueColor, //蓝色
  mainTextColor, //主要文本颜色
  mainTextColor3,
  mainTextColor4,
  mainTextColor5, //主要文本颜色，与mainTextColor颜色相反
  mainTextColor6,
  mainTextColor7,
  mainTextColor8,
  mainTextColor10,
  mainWhiteColor,
  mainBlockColor,
  refreshBGColor, //下拉刷新widget 背景颜色
  refreshValueColor, //下拉刷新进度 颜色
  ff888888,
  itemBgColor, //列表项背景
  itemBgColor2, //列表项背景，文本输入框
  itemBgColor4,
  itemBgColor5,
  itemBgColor6,
  itemBgColor8,
  itemTextColor, //列表项文本主颜色
  itemSubtitleTextColor, //列表项文本副标题颜色
  itemBorderColor, //列表项边框颜色
  itemLineColor,
  errorBgColor, //错误文本背景色
  errorBgColor2,
  errorTextColor, //错误文本颜色
  rightTextColor, //正确文本颜色
  textColorOrange, //橙色
  dividerColor, //隔断线颜色
  mainButtonBgColor, //按钮背景颜色
  mainButtonBgColor3,
  mainButtonTextColor, //按钮字体颜色
  mainButtonTextColor3,
  transparentBgColor, //半透明背景色
  alertBgColor, //弹出层背景色
  textColorGrey,
  mainGreyColor,
  ff444444,
  textFieldHintColor,
  hintTextColor,
  iconTextDisableColor,
  timeBorderColor
}
