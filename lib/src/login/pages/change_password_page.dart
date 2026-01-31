// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/utils/md5_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';

/// 修改密码页面（已登录用户，需要原密码）
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_change_password,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScreenUtil().setWidth(20)),

                // 说明文字
                Text(
                  S.of(context).g_key_change_password_desc,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),

                SizedBox(height: ScreenUtil().setWidth(40)),

                // 原密码
                _buildPasswordField(
                  controller: _oldPasswordController,
                  label: S.of(context).g_key_old_password,
                  hint: S.of(context).g_key_enter_old_password,
                  obscure: _obscureOldPassword,
                  onToggle: () {
                    setState(() => _obscureOldPassword = !_obscureOldPassword);
                  },
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

                SizedBox(height: ScreenUtil().setWidth(24)),

                // 新密码
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: S.of(context).g_key_new_password,
                  hint: S.of(context).g_key_enter_new_password,
                  obscure: _obscureNewPassword,
                  onToggle: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).g_key_password_required;
                    }
                    if (value.length < 6) {
                      return S.of(context).g_key_password_min_length;
                    }
                    if (value == _oldPasswordController.text) {
                      return S.of(context).g_key_new_password_same_as_old;
                    }
                    return null;
                  },
                ),

                SizedBox(height: ScreenUtil().setWidth(24)),

                // 确认新密码
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: S.of(context).g_key_confirm_new_password,
                  hint: S.of(context).g_key_enter_confirm_password,
                  obscure: _obscureConfirmPassword,
                  onToggle: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).g_key_password_required;
                    }
                    if (value != _newPasswordController.text) {
                      return S.of(context).g_key_passwords_not_match;
                    }
                    return null;
                  },
                ),

                SizedBox(height: ScreenUtil().setWidth(16)),

                // 密码要求提示
                _buildPasswordRequirements(),

                SizedBox(height: ScreenUtil().setWidth(48)),

                // 提交按钮
                SizedBox(
                  width: double.infinity,
                  height: ScreenUtil().setWidth(88),
                  child: buttonStyle6(
                    context,
                    _isLoading ? () {} : _onSubmit,
                    _isLoading
                        ? '${S.of(context).g_key_106}...'
                        : S.of(context).g_key_78,
                    AppThemeUtils.getColorByKey(
                      context,
                      _isLoading
                          ? AppThemeKeys.mainButtonBgColor3.name
                          : AppThemeKeys.mainButtonBgColor.name,
                    ),
                    AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainButtonTextColor.name,
                    ),
                    _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            filled: true,
            fillColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemBgColor.name,
            ),
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
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_password_requirements,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          _buildRequirementItem(S.of(context).g_key_password_req_length),
          _buildRequirementItem(S.of(context).g_key_password_req_different),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(4)),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: ScreenUtil().setWidth(24),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final oldPwdHash = Md5Util().generateMd5(_oldPasswordController.text);
      final newPwdHash = Md5Util().generateMd5(_newPasswordController.text);

      final result = await UserInfoApi().changePassword(oldPwdHash, newPwdHash);

      if (!mounted) return;

      if (result.error) {
        ToastUtils.show(result.data?.toString() ?? 'Failed');
      } else {
        ToastUtils.show(S.of(context).g_key_password_changed_success);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
