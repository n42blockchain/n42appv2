import 'package:n42appv2/src/login/widgets/view_pwd_icon.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 账号输入 密码输入
enum InputFieldType { account, password }
class CommInput extends StatefulWidget {
  final InputFieldType type;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final bool autofocus;
  final int? maxLength;
  final int? maxLines;
  final TextStyle? style;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final bool isCollapsed;

  //是否可用
  final bool? enabled;

  const CommInput({required this.type,
    this.controller,
    this.keyboardType,
    this.hintText = '',
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.style,
    this.enabled = true,
    this.inputFormatters,
    this.focusNode,
    this.textAlign,
    this.contentPadding,  this.isCollapsed = false,super.key});

  @override
  State<CommInput> createState() => _CommInputState(type == InputFieldType.password);
}

class _CommInputState extends State<CommInput> {
  bool obscure;

  _CommInputState(this.obscure);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextField(
              decoration: InputDecoration(
                  hintText: widget.hintText ?? '',
                  //文本框，提示文本颜色
                  hintStyle: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.hintTextColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                  //textField设定高度后,文字无法居中
                  isCollapsed: widget.isCollapsed,
                  border: InputBorder.none,
                  //contentPadding: padding(),
                  enabledBorder: const UnderlineInputBorder(
                    //没有焦点时
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    //有焦点时
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: widget.contentPadding ??
                      EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24))),
              style: widget.style ??
                  TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(32),
                  ),
              controller: widget.controller,
              obscureText: obscure,
              keyboardType: (widget.keyboardType != null &&
                  widget.keyboardType == TextInputType.number)
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              autofocus: widget.autofocus,
              focusNode: widget.focusNode,
              toolbarOptions: null,
              inputFormatters: widget.inputFormatters,
              enabled: widget.enabled,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              textAlign: widget.textAlign ?? TextAlign.start,
            )),
        if (widget.type == InputFieldType.password) _buildRightView()
      ],
    );
  }

  /// 密码右侧的显示隐藏按钮
  _buildRightView() {
    return ViewPwdIcon(
      onTap: () => setState(() => obscure = !obscure),
    );
  }
}
