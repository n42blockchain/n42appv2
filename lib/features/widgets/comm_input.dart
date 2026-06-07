import 'package:n42_wallet/features/widgets/view_pwd_icon.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/services.dart';

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

  const CommInput({
    required this.type,
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
    this.contentPadding,
    this.isCollapsed = false,
    super.key,
  });

  @override
  State<CommInput> createState() => _CommInputState();
}

class _CommInputState extends State<CommInput> {
  late bool obscure;

  @override
  void initState() {
    super.initState();
    obscure = widget.type == InputFieldType.password;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: widget.hintText ?? '',
              //文本框，提示文本颜色
              hintStyle: AppTypography.body.copyWith(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.hintTextColor.name,
                ),
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
              contentPadding:
                  widget.contentPadding ??
                  EdgeInsets.symmetric(horizontal: AppSpacing.space6),
            ),
            style:
                widget.style ??
                AppTypography.headline.copyWith(
                  color: AppColorTokens.of(context).textPrimary,
                ),
            controller: widget.controller,
            obscureText: obscure,
            keyboardType:
                (widget.keyboardType != null &&
                    widget.keyboardType == TextInputType.number)
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            autofocus: widget.autofocus,
            focusNode: widget.focusNode,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            textAlign: widget.textAlign ?? TextAlign.start,
          ),
        ),
        if (widget.type == InputFieldType.password) _buildRightView(),
      ],
    );
  }

  /// 密码右侧的显示隐藏按钮
  Widget _buildRightView() {
    return ViewPwdIcon(onTap: () => setState(() => obscure = !obscure));
  }
}
