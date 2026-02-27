// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'reset_password_page.dart';

/// 重置密码页面的步骤指示器
class _ResetPasswordStepIndicator extends StatelessWidget {
  final int currentStep;

  const _ResetPasswordStepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStepDot(context, 0, S.of(context).g_key_step_email),
        _buildStepLine(context, 0),
        _buildStepDot(context, 1, S.of(context).g_key_step_verify),
        _buildStepLine(context, 1),
        _buildStepDot(context, 2, S.of(context).g_key_step_password),
      ],
    );
  }

  Widget _buildStepDot(BuildContext context, int step, String label) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;

    return Column(
      children: [
        Container(
          width: ScreenUtil().setWidth(40),
          height: ScreenUtil().setWidth(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            border: isCurrent
                ? Border.all(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    width: 2,
                  )
                : null,
          ),
          child: Center(
            child: isActive && !isCurrent
                ? Icon(Icons.check, color: Colors.white, size: ScreenUtil().setWidth(24))
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: isActive
                ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name)
                : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, int afterStep) {
    final isActive = currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(32)),
        color: isActive
            ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
    );
  }
}

/// 重置密码页面的通用输入字段
class _ResetPasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int? maxLength;
  final double? letterSpacing;
  final String? Function(String?)? validator;

  const _ResetPasswordInputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.prefixIcon,
    this.maxLength,
    this.letterSpacing,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            letterSpacing: letterSpacing,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(maxLength != null ? 30 : 28),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              letterSpacing: letterSpacing,
            ),
            filled: true,
            fillColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(16),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  )
                : null,
            counterText: maxLength != null ? '' : null,
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// 重置密码页面的密码输入字段（带可见性切换）
class _ResetPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;

  const _ResetPasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
            filled: true,
            fillColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(16),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              onPressed: onToggle,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).g_key_password_required;
            }
            if (value.length < 6) {
              return S.of(context).g_key_password_min_length;
            }
            return null;
          },
        ),
      ],
    );
  }
}
