import 'package:n42_wallet/features/login/api/handtype.dart';
import 'package:n42_wallet/features/login/widgets/captcha_button.dart';
import 'package:n42_wallet/features/login/widgets/view_pwd_icon.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum InputFieldType { email, password, captcha, number }

class InputField extends StatefulWidget {
  final InputFieldType type;
  final TextEditingController controller;
  final OnTap? onCaptcha;
  final bool? enabled;
  final FocusNode? focusNode;
  final int? inputLength;

  final String hintText;
  final HandType? codeType;
  final VoidCallback? onEditingComplete;
  const InputField({
    required this.type,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.codeType,
    this.onCaptcha,
    this.enabled,
    this.onEditingComplete,
    this.inputLength = 8,
    super.key,
  });

  bool get cleanable => type == InputFieldType.email;

  TextInputType get keyboardType {
    if (type == InputFieldType.email) return TextInputType.emailAddress;
    if (type == InputFieldType.captcha || type == InputFieldType.number) {
      return TextInputType.datetime;
    }
    return TextInputType.visiblePassword;
  }
  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool obscure;
  bool cleanable = false;

  @override
  void initState() {
    super.initState();
    obscure = widget.type == InputFieldType.password;
    widget.controller.addListener(() {
      bool isNotEmpty = widget.controller.text.isNotEmpty;
      if (widget.cleanable && cleanable != isNotEmpty) {
        setState(() => cleanable = isNotEmpty);
      }
    });
  }

  Widget cleanIcon() => GestureDetector(
        onTap: () => widget.controller.text = '',
        child: const Icon(Icons.cancel_outlined, size: 18),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(96),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.hintText,
                //文本框，提示文本颜色
                hintStyle: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
                border: InputBorder.none,
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
              ),
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32),
              ),
              enabled: widget.enabled,
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: obscure,
              keyboardType: widget.keyboardType,
              textInputAction: TextInputAction.done,
              enableInteractiveSelection: widget.type != InputFieldType.password,
              inputFormatters: widget.type == InputFieldType.captcha
                  ? [LengthLimitingTextInputFormatter(widget.inputLength)]
                  : null,
              onEditingComplete: widget.onEditingComplete,
            ),
          ),
          _buildRightView(context)
        ],
      ),
    );
  }

  Widget _buildRightView(BuildContext context) {
    if (widget.type == InputFieldType.captcha) {
      return CaptchaButton(
        onTap: widget.onCaptcha!,
        codeType: widget.codeType,
      );
    } else if (widget.type == InputFieldType.password) {
      return ViewPwdIcon(
        onTap: () => setState(() => obscure = !obscure),
      );
    }  else {
      return (widget.cleanable && cleanable) ? cleanIcon() : const SizedBox();
    }
  }
}
