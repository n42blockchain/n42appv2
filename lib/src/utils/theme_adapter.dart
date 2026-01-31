import 'package:flutter/material.dart';
class ThemeAdapter{
  static ThemeData themeDataLight=ThemeData.light().copyWith(
      scaffoldBackgroundColor:AppThemeUtils.lightMap[AppThemeKeys.backGroundColor.name],
    primaryColor: Color(0xffF9f9f9),
    //头部导航样式
    appBarTheme: AppBarTheme(
      centerTitle:true,
      elevation: 0,//去掉阴影
      titleTextStyle: TextStyle(
        color: Color(0xff222222),
      ),
      actionsIconTheme: IconThemeData(
        color: Color(0xff222222),
      ),
      toolbarTextStyle: TextStyle(
        color: Color(0xff222222),
      ),
      iconTheme: IconThemeData(
        color: Color(0xff222222),
      ),
    ),
    //底部导航样式
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: Color(0xFF448BDF)),
      unselectedIconTheme: IconThemeData(color: Color(0xffffffff)),
      selectedItemColor: Color(0xFF448BDF),
      unselectedItemColor: Color(0xff222222),
    ),
    iconTheme: IconThemeData(color: Color(0xff222222)),


    ///输入框style
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        color: Color(0xFFBAC2CC),//文本框，提示文本颜色
        fontSize: 16,
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF448BDF),
          //width: 1,
          style: BorderStyle.solid,
        ),
      ),
      /*labelStyle: TextStyle(
        color: Color(0xff888888),//文本框，提示文本颜色
      ),*/

      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xffc6c6c6),
          //width: 1,
          style: BorderStyle.solid,
        ),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xffd9445a),
          //width: 1,
          style: BorderStyle.solid,
        ),
      ),
    ),
    /*textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: ButtonStyleButton.allOrNull<Color>(Colors.cyanAccent),
      ),
    ),*/
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
    ),
    buttonTheme: ButtonThemeData(
        buttonColor: Color(0xFF448BDF)
    ),
    //进度条样式
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Color(0xFF448BDF),
      linearTrackColor:Colors.white24,
      refreshBackgroundColor: Colors.white24,
    ),
    //分割线样式
    dividerTheme:DividerThemeData(
        color: Color(0xffD9D9D9),
        space: 0,
        thickness: 1,
        indent: 10,
        endIndent: 10
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Color(0xFF448BDF),
    ),
  );

  static ThemeData themeDataDark=ThemeData.dark().copyWith(
    scaffoldBackgroundColor:AppThemeUtils.darkMap[AppThemeKeys.backGroundColor.name],
    cardTheme: CardThemeData(
      shadowColor: Color(0xff444444),
      color: Color(0xff2b2b2b),
    ),
    //头部导航样式
    appBarTheme: AppBarTheme(
      centerTitle:true,
      elevation: 0,//去掉阴影
      titleTextStyle: TextStyle(
        color: Color(0xffffffff),
      ),
      toolbarTextStyle: TextStyle(
        color: Color(0xffffffff),
      ),
      actionsIconTheme: IconThemeData(
        color: Color(0xffffffff),
      ),
      iconTheme: IconThemeData(
        color: Color(0xffffffff),
      ),
    ),
    //底部导航样式
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: Color(0xFF448BDF)),
      unselectedIconTheme: IconThemeData(color: Color(0xffffffff)),
      selectedItemColor: Color(0xFF448BDF),
      unselectedItemColor: Color(0xff888888),
    ),
    iconTheme: IconThemeData(color: Color(0xffffffff)),

    //cardColor: Color(0xff888888),

    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Color(0xFFBEBEBE),//文本框，提示文本颜色
        fontSize: 16,
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF448BDF),
          //width: 1,
          style: BorderStyle.solid,
        ),
      ),
      /*labelStyle: TextStyle(
        color: Color(0xff888888),//文本框，提示文本颜色
      ),*/

      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xff545454),
          //width: 1,
          style: BorderStyle.solid,
        ),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xffd9445a),
          //width: 1,
          style: BorderStyle.solid,
        ),
      ),
    ),
    /*textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: ButtonStyleButton.allOrNull<Color>(Colors.cyanAccent),
      ),
    ),*/
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
    ),
    buttonTheme: ButtonThemeData(
        buttonColor: Color(0xFF448BDF)
    ),
    //进度条样
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Color(0xFF448BDF),
      linearTrackColor:Colors.white24,
      refreshBackgroundColor: Colors.white24,
    ),
    //分割线样式
    dividerTheme:DividerThemeData(
        color: Color(0xff303239),
        space: 0,
        thickness: 1,
        indent: 10,
        endIndent: 10
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Color(0xFF448BDF),
    ),
  );
}
class AppThemeUtils{
  ///根据key返回颜色
  static Color getColorByKey(BuildContext? context,String key){
    if(context == null) return  Colors.red;
    //判断当前主题是什么主题
    Color? color;
    if(Theme.of(context).brightness == Brightness.dark){
      color =  darkMap[key];
    }else{
      color = lightMap[key];
    }
    //如果没有颜色 返回黑色
    // assert(color != null);
    color = color?? const Color(0xff000000);
    return color;

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
    AppThemeKeys.itemBorderColor.name:const Color(0xFFD9D9D9),
    AppThemeKeys.itemLineColor.name:const Color(0xFFE4E4E4),
    AppThemeKeys.errorBgColor.name:const Color(0xFFFFF3EC),
    AppThemeKeys.errorBgColor2.name:const Color(0xFFF03450).withAlpha((0.2 * 255).round()),
    AppThemeKeys.errorTextColor.name:const Color(0xFFF03450),
    AppThemeKeys.rightTextColor.name:const Color(0xff44A677),
    AppThemeKeys.textColorOrange.name:const Color(0xFFFF6F16),
    AppThemeKeys.dividerColor.name:const Color(0xffD9D9D9),
    AppThemeKeys.mainButtonBgColor.name: const Color(0xFF1976F9),
    AppThemeKeys.mainButtonBgColor3.name: const Color(0xFFD1E4FE),
    AppThemeKeys.mainButtonTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainButtonTextColor3.name: Color(0xFF1976F9),
    AppThemeKeys.transparentBgColor.name:const Color.fromRGBO(0, 0, 0, 0.2),
    AppThemeKeys.alertBgColor.name: Color(0xFF000000).withAlpha((0.8 * 255).round()),
    AppThemeKeys.textColorGrey.name:const Color(0xFFCDCBCB),
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
    AppThemeKeys.itemBorderColor.name:const Color(0xFF303239),
    AppThemeKeys.itemLineColor.name: const Color(0x50E4E4E4),
    AppThemeKeys.errorBgColor.name:const Color(0xFFFFF3EC),
    AppThemeKeys.errorBgColor2.name:const Color(0xFFF03450).withAlpha((0.2 * 255).round()),
    AppThemeKeys.errorTextColor.name:const Color(0xFFF03450),
    AppThemeKeys.rightTextColor.name:const Color(0xff44A677),
    AppThemeKeys.textColorOrange.name:const Color(0xFFFF6F16),
    AppThemeKeys.dividerColor.name:const Color(0xff303239),
    AppThemeKeys.mainButtonBgColor.name: const Color(0xFF1976F9),
    AppThemeKeys.mainButtonBgColor3.name: const Color(0xFF2A3D5C),
    AppThemeKeys.mainButtonTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainButtonTextColor3.name: const Color(0xFF6B9ADB),
    AppThemeKeys.transparentBgColor.name:const Color.fromRGBO(0, 0, 0, 0.2),
    AppThemeKeys.alertBgColor.name:const Color(0xFFffffff),
    AppThemeKeys.textColorGrey.name:const Color(0xFFCDCBCB),
    AppThemeKeys.mainGreyColor.name: Colors.grey,
    AppThemeKeys.ff444444.name: Colors.white70,
    AppThemeKeys.textFieldHintColor.name: const Color(0xFFBEBEBE),
    AppThemeKeys.hintTextColor.name: const Color(0xFF545454),
    AppThemeKeys.iconTextDisableColor.name: const Color(0xff373739),
    AppThemeKeys.timeBorderColor.name: const Color(0xff373739),
  };

}
enum AppThemeKeys{
  backGroundColor,//背景色
  backGroundColor2,//背景色2
  backGroundColor3,
  //borderSide,//阴影颜色
  //mainBoxColor,//widget背景色
  linearGradient1,//线性渐变色1
  linearGradient2,//线性渐变色2
  mainBlueColor,//蓝色
  mainTextColor,//主要文本颜色
  mainTextColor3,
  mainTextColor4,
  mainTextColor5,//主要文本颜色，与mainTextColor颜色相反
  mainTextColor6,
  mainTextColor7,
  mainTextColor8,
  mainTextColor10,
  mainWhiteColor,
  mainBlockColor,
  refreshBGColor,//下拉刷新widget 背景颜色
  refreshValueColor,//下拉刷新进度 颜色
  ff888888,
  itemBgColor,//列表项背景
  itemBgColor2,//列表项背景，文本输入框
  itemBgColor4,
  itemBgColor5,
  itemBgColor6,
  itemBgColor8,
  itemTextColor,//列表项文本主颜色
  itemSubtitleTextColor,//列表项文本副标题颜色
  itemBorderColor,//列表项边框颜色
  itemLineColor,
  errorBgColor,//错误文本背景色
  errorBgColor2,
  errorTextColor,//错误文本颜色
  rightTextColor,//正确文本颜色
  textColorOrange,//橙色
  dividerColor,//隔断线颜色
  mainButtonBgColor,//按钮背景颜色
  mainButtonBgColor3,
  mainButtonTextColor,//按钮字体颜色
  mainButtonTextColor3,
  transparentBgColor,//半透明背景色
  alertBgColor,//弹出层背景色
  textColorGrey,
  mainGreyColor,
  ff444444,
  textFieldHintColor,
  hintTextColor,
  iconTextDisableColor,
  timeBorderColor
}
/// app主色key定义
/// todo 如果 添加了一个key 请在上边设置对应的颜色
class AppThemeKeys1{

  // app页面背景色
  static const String backGroundColor = "backGroundColor";
  static const String backGroundColor2 = "backGroundColor2";
  static const String backGroundColor3 = "backGroundColor3";
  static const String backGroundColor4 = "backGroundColor4";
  // 页面 div/box 背景色
  static const String mainBoxColor = "mainBoxColor";
  // appBarColor
  static const String appBarColor = "appBarColor";
  //appBarTextColor
  static const String appBarTextColor = "appBarTextColor";
  // app 常用字体颜色
  static const String mainTextColor = "mainTextColor";
  //app 常用字体颜色2
  static const String mainTextColor2 = "mainTextColor2";
  //app 常用字体颜色2
  static const String mainTextColor3 = "mainTextColor3";
  //app 常用字体颜色
  static const String mainTextColor4 ="mainTextColor4";
  //app 常用字体颜色 反过来
  static const String mainTextColor5 ="mainTextColor5";
  //app 常用字体颜色
  static const String mainTextColor6 ="mainTextColor6";
  //app 常用字体颜色
  static const String mainTextColor7 ="mainTextColor7";
  //app 常用字体颜色
  static const String mainTextColor8 ="mainTextColor8";
  static const String mainTextColor9 ="mainTextColor9";
  static const String mainTextColor10 ="mainTextColor10";

  //app 灰色色值
  static const String mainGreyColor = "mainGreyColor";
  //白色值
  static const String mainWhiteColor = "mainWhiteColor";
  //黑色
  static const String mainBlackColor = "mainBlackColor";
  //按钮背景色
  static const String mainButtonBgColor = "mainButtonBgColor";
  //按钮字体颜色
  static const String mainButtonTextColor = "mainButtonTextColor";
  //按钮背景色2
  static const String mainButtonBgColor2 = "mainButtonBgColor2";
  //按钮背景色 不可用
  static const String mainButtonBgColor3 = "mainButtonBgColor3";
  //按钮字体颜色2
  static const String mainButtonTextColor2 = "mainButtonTextColor2";
  //按钮字体颜色3
  static const String mainButtonTextColor3 = "mainButtonTextColor3";
  //icon字体不可用颜色
  static const String iconTextDisableColor = "iconTextDisableColor";
  //列表item 背景色
  static const String itemBgColor = "itemBgColor";
  static const String itemBgColor2 = "itemBgColor2";
  static const String itemBgColor3 = "itemBgColor3";
  static const String itemBgColor4 = "itemBgColor4";
  static const String itemBgColor5 = "itemBgColor5";
  static const String itemBgColor6 = "itemBgColor6";
  static const String itemBgColor7 = "itemBgColor7";
  static const String itemBgColor8 = "itemBgColor8";
  //列表item 文字颜色
  static const String itemTextColor = "itemTextColor";
  // item 副标题颜色
  static const String itemSubtitleTextColor = "itemSubtitleTextColor";
  //hintTextColor
  static const String hintTextColor = "hintTextColor";
  static const String hintTextColor2 = "hintTextColor2";
  /// #FF666666
  static const String ff666666 = "FF666666";
  static const String ff444444 = "FF444444";
  static const String ff888888 = "FF888888";
  static const String ffE0E6ED = "ffE0E6ED";
  static const String ffEDEFF2 ="ffEDEFF2";
  //橘黄色
  static const String textColorOrange="textColorOrange";
  static const String textColorOrange1="textColorOrange1";
  static const String bgColorOrange="bgColorOrange";
  //黄
  static const String textColorYellow="textColorYellow";
  //深蓝
  static const String textColorDarkBlue="textColorDarkBlue";
  //绿
  static const String textColorGreen="textColorGreen";
  //灰
  static const String textColorGrey="textColorGrey";
  //item边框颜色
  static const String itemBorderColor="itemBorderColor";
  //应用分割线颜色
  static const String itemLineColor="itemLineColor";
  //错误提示背景色
  static const String errorMessageBgColor="errorMessageBgColor";
  //错误提示背景色2
  static const String errorMessageBgColor2="errorMessageBgColor2";
  //正确提示背景色
  static const String rightMessageBgColor="rightMessageBgColor";
  //错误提示文本颜色
  static const String errorMessageTextColor="errorMessageTextColor";
  //正确提示文本颜色
  static const String rightMessageTextColor="rightMessageTextColor";
  //透明背景
  static const String transparentBgColor="transparentBgColor";
  //目前这个blue就是应用的 主题色
  static const String mainBlueColor="mainBlueColor";
  static const String mainBlueColor1="mainBlueColor1";
  //高斯模糊
  static const String leftMenuBlurColor="leftMenuBlurColor";
  //文本输入框 提示文本颜色
  static const String textFieldHintColor="textFieldHintColor";
  //列表分割线颜色
  static const String dividerColor="dividerColor";
  //倒计时边框
  static const String timeBorderColor="timeBorderColor";
  //弹出提示背景颜色
  static const String alertBgColor="alertBgColor";

}