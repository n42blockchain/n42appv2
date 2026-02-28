import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Resolves border and text colors based on error state and focus.
({Color borderColor, Color textColor}) _resolveColors(
  BuildContext context, {
  required String errorMessage,
  required Color? borderColorOverride,
  required FocusNode? focusNode,
}) {
  if (errorMessage != "") {
    final errorColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    return (borderColor: errorColor, textColor: errorColor);
  }

  final defaultBorder = borderColorOverride ??
      AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name);
  final textColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name);

  if (focusNode != null && focusNode.hasFocus) {
    final focusBorder = borderColorOverride ??
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    return (borderColor: focusBorder, textColor: textColor);
  }

  return (borderColor: defaultBorder, textColor: textColor);
}

/// Builds the common message widget shown below a text field.
Widget? _buildMessageWidget(
  BuildContext context, {
  required String message,
  required String errorMessage,
  required EdgeInsetsGeometry? messageMargin,
}) {
  if (errorMessage != "") {
    return Container(
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
    );
  }
  if (message != "") {
    return Container(
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
    );
  }
  return null;
}

/// Builds the common InputDecoration used by both text field styles.
InputDecoration _buildInputDecoration({
  required EdgeInsets? contentPadding,
  required String hintText,
  required TextStyle? hintStyle,
  required Widget? suffix,
}) {
  return InputDecoration(
    contentPadding: contentPadding ??
        EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
    isCollapsed: true,
    hintText: hintText,
    hintStyle: hintStyle,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    suffix: suffix,
  );
}

Widget textFieldStyle2(
    BuildContext context,
    {
      ValueChanged<String>? onChanged,
      VoidCallback? onEditingComplete,
      ValueChanged<String>? onSubmitted,
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
      VoidCallback? rightOnTap1,
      Widget? rightWidget2,
      VoidCallback? rightOnTap2,
      Widget? rightWidget3,
      VoidCallback? rightOnTap3,
      Widget? leftWidget,
      VoidCallback? leftOnTap,
    }) {
  final colors = _resolveColors(context,
      errorMessage: errorMessage, borderColorOverride: borderColor, focusNode: focusNode);
  final defaultHeight = ScreenUtil().setWidth(88.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
          color: bgColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name),
          boxShadow: [
            boxShadow ?? BoxShadow(
              color: Color(0xff101828).withAlpha((0.05 * 255).round()),
              offset: Offset(0, 1),
              blurRadius: ScreenUtil().setWidth(4.0),
              spreadRadius: 0,
            )
          ],
          border: borderWidth == 0 ? null : Border.all(
            width: borderWidth,
            color: colors.borderColor,
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: height ?? defaultHeight,
          minHeight: height ?? defaultHeight,
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            if (leftWidget != null)
              InkWell(onTap: leftOnTap, child: leftWidget),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                style: style ?? TextStyle(
                  color: colors.textColor,
                  fontSize: fontSize ?? ScreenUtil().setSp(32.0),
                ),
                textInputAction: textInputAction ?? TextInputAction.next,
                keyboardType: keyboardType ?? TextInputType.text,
                decoration: _buildInputDecoration(
                  contentPadding: contentPadding,
                  hintText: hintText,
                  hintStyle: hintStyle,
                  suffix: suffix,
                ),
                maxLines: maxLines ?? 1,
                onEditingComplete: onEditingComplete,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
            if (rightWidget3 != null)
              InkWell(onTap: rightOnTap3, child: rightWidget3),
            if (rightWidget1 != null)
              InkWell(onTap: rightOnTap1, child: rightWidget1),
            if (rightWidget2 != null)
              InkWell(onTap: rightOnTap2, child: rightWidget2),
          ],
        ),
      ),
      if (_buildMessageWidget(context, message: message, errorMessage: errorMessage, messageMargin: messageMargin) != null)
        _buildMessageWidget(context, message: message, errorMessage: errorMessage, messageMargin: messageMargin)!,
    ],
  );
}

Widget textFieldStyle3(
    BuildContext context,
    {
      ValueChanged<String>? onChanged,
      VoidCallback? onEditingComplete,
      ValueChanged<String>? onSubmitted,
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
      VoidCallback? rightOnTap1,
      Widget? rightWidget2,
      VoidCallback? rightOnTap2,
      Widget? leftWidget,
      VoidCallback? leftOnTap,
    }) {
  final colors = _resolveColors(context,
      errorMessage: errorMessage, borderColorOverride: borderColor, focusNode: focusNode);
  final defaultHeight = ScreenUtil().setWidth(88.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
          color: bgColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name),
          border: borderWidth == 0 ? null : Border.all(
            width: borderWidth,
            color: colors.borderColor,
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: height ?? defaultHeight,
          minHeight: height ?? defaultHeight,
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            if (leftWidget != null)
              InkWell(onTap: leftOnTap, child: leftWidget),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                style: style ?? TextStyle(
                  color: colors.textColor,
                  fontSize: fontSize ?? ScreenUtil().setSp(32.0),
                ),
                textInputAction: textInputAction ?? TextInputAction.next,
                keyboardType: keyboardType ?? TextInputType.text,
                obscureText: obscure,
                decoration: _buildInputDecoration(
                  contentPadding: contentPadding,
                  hintText: hintText,
                  hintStyle: hintStyle,
                  suffix: suffix,
                ),
                maxLines: maxLines ?? 1,
                maxLength: maxLengths,
                onEditingComplete: onEditingComplete,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
            if (rightWidget1 != null)
              InkWell(onTap: rightOnTap1, child: rightWidget1),
            if (rightWidget2 != null)
              InkWell(onTap: rightOnTap2, child: rightWidget2),
          ],
        ),
      ),
      // Style3 uses a Row with icon for error messages
      if (message != "" && errorMessage == "")
        _buildMessageWidget(context, message: message, errorMessage: "", messageMargin: messageMargin)!,
      if (errorMessage != "")
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
              SizedBox(width: 5),
              Expanded(
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
