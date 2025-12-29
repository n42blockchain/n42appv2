import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget TextFieldStyle2(
    BuildContext context,
    {
      dynamic onChanged,
      dynamic onEditingComplete,
      dynamic onSubmitted,
      TextEditingController? controller,
      FocusNode? focusNode,
      bool enabled=true,
      String hintText="",
      Widget? suffix,
      EdgeInsets? contentPadding,
      TextStyle? style,
      TextStyle? hintStyle,
      TextInputAction? textInputAction,
      TextInputType? keyboardType,
      double? height,
      EdgeInsets? padding,
      BorderRadius? borderRadius,
      Color? bgColor,
      BoxShadow? boxShadow,
      double? fontSize,
      int? maxLines,
      String message="",
      String errorMessage="",
      EdgeInsetsGeometry? messageMargin,
      double borderWidth=0,
      Color? borderColor,
      Widget? rightWidget1,
      dynamic rightOnTap1,
      Widget? rightWidget2,
      dynamic rightOnTap2,
      Widget? rightWidget3,
      dynamic rightOnTap3,
      Widget? leftWidget,
      dynamic leftOnTap,
    }){
  Color bdColor=borderColor??AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name);
  Color textColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name);
  if(errorMessage !=""){
    bdColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    textColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
  }else{
    if(focusNode !=null){
      if(focusNode.hasFocus){
        bdColor=borderColor??AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
      }
    }
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: padding??EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          borderRadius:borderRadius?? BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
          color: bgColor??AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name),
          boxShadow: [
            boxShadow??BoxShadow(
              color: Color(0xff101828).withAlpha((0.05 * 255).round()),  //底色,阴影颜色
              offset: Offset(0, 1), //阴影位置,从什么位置开始
              blurRadius: ScreenUtil().setWidth(4.0),  // 阴影模糊层度
              spreadRadius: 0, )
          ],
          border: borderWidth==0?null:Border.all(
            width: borderWidth,
            color: bdColor,
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: height??ScreenUtil().setWidth(88.0),
          minHeight: height??ScreenUtil().setWidth(88.0),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            if(leftWidget !=null)
              InkWell(
                onTap: (){
                  if(leftOnTap !=null)
                    leftOnTap();
                },
                child: leftWidget,
              ),
            Expanded(
              flex: 1,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                style: style??TextStyle(
                  color: textColor,
                  fontSize: fontSize??ScreenUtil().setSp(32.0),
                ),
                textInputAction: textInputAction??TextInputAction.next,
                keyboardType: keyboardType??TextInputType.text,
                decoration: InputDecoration(
                  contentPadding:contentPadding??
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                  isCollapsed: true,
                  hintText: hintText,
                  hintStyle: hintStyle,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffix: suffix,
                ),
                maxLines: maxLines??1,
                onEditingComplete: () {
                  if(onEditingComplete !=null)
                    onEditingComplete();
                },
                onChanged: (value) {
                  if(onChanged !=null)
                    onChanged(value);
                },
                onSubmitted: (value){
                  if(onSubmitted !=null)
                    onSubmitted(value);
                },
              ),
            ),
            if(rightWidget3 !=null)
              InkWell(
                onTap: (){
                  if(rightOnTap2 !=null)
                    rightOnTap3();
                },
                child: rightWidget3,
              ),
            if(rightWidget1 !=null)
              InkWell(
                onTap: (){
                  if(rightOnTap1 !=null)
                    rightOnTap1();
                },
                child: rightWidget1,
              ),
            if(rightWidget2 !=null)
              InkWell(
                onTap: (){
                  if(rightOnTap2 !=null)
                    rightOnTap2();
                },
                child: rightWidget2,
              ),
          ],
        ),
      ),
      if(message !="" && errorMessage=="")
        Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
          margin: messageMargin,
          width: double.infinity,
          child: Text(
            message,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
        ),
      if(errorMessage !="")
        Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
          margin: messageMargin,
          width: double.infinity,
          child: Text(
            errorMessage,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
        ),
    ],
  );
}
Widget TextFieldStyle3(
    BuildContext context,
    {
      dynamic onChanged,
      dynamic onEditingComplete,
      dynamic onSubmitted,
      TextEditingController? controller,
      FocusNode? focusNode,
      bool enabled=true,
      String hintText="",
      Widget? suffix,
      EdgeInsets? contentPadding,
      TextStyle? style,
      TextStyle? hintStyle,
      TextInputAction? textInputAction,
      TextInputType? keyboardType,
      double? height,
      EdgeInsets? padding,
      BorderRadius? borderRadius,
      Color? bgColor,
      //BoxShadow? boxShadow,
      double? fontSize,
      int? maxLines,
      int? maxLengths,
      String message="",
      String errorMessage="",
      EdgeInsetsGeometry? messageMargin,
      double borderWidth=0,
      Color? borderColor,
      bool obscure=false,
      Widget? rightWidget1,
      dynamic rightOnTap1,
      Widget? rightWidget2,
      dynamic rightOnTap2,
      Widget? leftWidget,
      dynamic leftOnTap,
    }){
  Color bdColor=borderColor??AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name);
  Color textColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name);
  if(errorMessage !=""){
    bdColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    textColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
  }else{
    if(focusNode !=null){
      if(focusNode.hasFocus){
        bdColor=borderColor??AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
      }
    }
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: padding??EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          borderRadius:borderRadius?? BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
          color: bgColor??AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name),
          /*boxShadow: [
            boxShadow??BoxShadow(
              color: Color(0xff101828).withOpacity(0.05),  //底色,阴影颜色
              offset: Offset(0, 1), //阴影位置,从什么位置开始
              blurRadius: scr.setWidth(4.0),  // 阴影模糊层度
              spreadRadius: 0, )
          ],*/
          border: borderWidth==0?null:Border.all(
            width: borderWidth,
            color: bdColor,
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: height??ScreenUtil().setWidth(88.0),
          minHeight: height??ScreenUtil().setWidth(88.0),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            if(leftWidget !=null)
              InkWell(
                onTap: (){
                  if(leftOnTap !=null)
                    leftOnTap();
                },
                child: leftWidget,
              ),
            Expanded(
              flex: 1,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                style: style??TextStyle(
                  color: textColor,
                  fontSize: fontSize??ScreenUtil().setSp(32.0),
                ),
                textInputAction: textInputAction??TextInputAction.next,
                keyboardType: keyboardType??TextInputType.text,
                obscureText:obscure,
                decoration: InputDecoration(
                  contentPadding:contentPadding??
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                  isCollapsed: true,
                  hintText: hintText,
                  hintStyle: hintStyle,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffix: suffix,
                ),
                maxLines: maxLines??1,
                maxLength: maxLengths,
                onEditingComplete: () {
                  if(onEditingComplete !=null)
                    onEditingComplete();
                },
                onChanged: (value) {
                  if(onChanged !=null)
                    onChanged(value);
                },
                onSubmitted: (value){
                  if(onSubmitted !=null)
                    onSubmitted(value);
                },
              ),
            ),
            if(rightWidget1 !=null)
              InkWell(
                onTap: (){
                  if(rightOnTap1 !=null)
                    rightOnTap1();
                },
                child: rightWidget1,
              ),
            if(rightWidget2 !=null)
              InkWell(
                onTap: (){
                  if(rightOnTap2 !=null)
                    rightOnTap2();
                },
                child: rightWidget2,
              ),
          ],
        ),
      ),
      if(message !="" && errorMessage=="")
        Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
          margin: messageMargin,
          width: double.infinity,
          child: Text(
            message,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
        ),
      if(errorMessage !="")
        Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
          margin: messageMargin,
          width: double.infinity,
          child: Row(
            children: [
              Image.asset(
                "assets/img/details.png",
                width: ScreenUtil().setWidth(30.0),
                height: ScreenUtil().setWidth(30.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
              ),
              SizedBox(width: 5,),
              Expanded(
                flex: 1,
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}