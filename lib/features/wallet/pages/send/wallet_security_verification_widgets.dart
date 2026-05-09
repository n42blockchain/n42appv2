// ignore_for_file: invalid_use_of_protected_member
part of 'wallet_security_verification.dart';

// 安全验证页面 — 共用小组件 + State 构建辅助方法

// ---------------------------------------------------------------------------
// 共用无状态小组件
// ---------------------------------------------------------------------------

/// 节名标签（统一样式）
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemSubtitleTextColor.name,
        ),
        fontSize: ScreenUtil().setSp(28.0),
      ),
    );
  }
}

/// 错误提示行（空字符串时隐藏）
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        message,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.errorTextColor.name,
          ),
          fontSize: ScreenUtil().setSp(26.0),
        ),
        textAlign: TextAlign.end,
      ),
    );
  }
}

/// 胶囊形主色按钮
class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(10.0),
          horizontal: ScreenUtil().setWidth(20.0),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainButtonBgColor.name,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil().setWidth(30.0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonTextColor.name,
            ),
          ),
        ),
      ),
    );
  }
}

/// 统一输入框背景装饰
BoxDecoration _inputBoxDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
  );
}

/// 未启用时的「去设置」引导行
class _SetupPromptRow extends StatelessWidget {
  const _SetupPromptRow({
    required this.message,
    required this.buttonLabel,
    required this.onSetup,
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainButtonBgColor.name,
              ),
              fontSize: ScreenUtil().setSp(26.0),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _PillButton(label: buttonLabel, onTap: onSetup),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// State 构建辅助方法（extension 共享私有成员，part of 同库无保护限制）
// ---------------------------------------------------------------------------

extension _SecurityVerificationBuild on _WalletSecurityVerificationState {
  // 按优先级排列：已启用的安全项插入头部，未启用的追加到末尾
  List<Widget> _buildVerificationWidgets() {
    return [
      _WalletPasswordSection(
        showPasswordInput: showWalletPassword,
        pwdController: pwdTextEditingController,
        obscure: obscure,
        pwdErrorMessage: pwdErrorMessage,
        onToggleObscure: () => setState(() => obscure = !obscure),
        onSetupPassword: pushEditWallet,
        onEditingComplete: closeKeyboard,
      ),
      _FaceSection(
        enabled: securityMap['face'] == true,
        faceCheck: faceCheck,
        faceErrorMessage: faceErrorMessage,
        onVerify: faceVerification,
        onSetup: pushSetting,
      ),
      _GestureSection(
        enabled: securityMap['gesture'] == true,
        gesturePwd: securityMap['gesturePwd'] as String? ?? '',
        gestureCheck: gestureCheck,
        gestureErrorMessage: gestureErrorMessage,
        onComplete: gestureVerification,
        onSetup: pushSetting,
      ),
      _GoogleAuthSection(
        enabled: securityMap['google'] == true,
        verified: googleAuthCheck == 1,
        errorMessage: googleAuthErrorMessage,
        onVerify: googleAuthVerify,
        onSetup: pushSetting,
      ),
      SizedBox(height: ScreenUtil().setWidth(50.0)),
    ];
  }

  Widget _buildBottomBar(bool anyEnabled) {
    final su = ScreenUtil();
    final h88 = su.setWidth(88.0);
    final pad30 = su.setWidth(30.0);

    Color themeColor(String key) => AppThemeUtils.getColorByKey(context, key);

    return Column(
      children: [
        Divider(height: su.setWidth(1), indent: 0, endIndent: 0),
        Container(
          height: su.setWidth(148.0),
          padding: EdgeInsets.all(pad30),
          color: themeColor(AppThemeKeys.backGroundColor.name),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: h88,
                  child: buttonStyle5(
                    context,
                    () {
                      closeKeyboard();
                      if (load == Load.loading) return;
                      Navigator.pop(context, false);
                    },
                    S.of(context).g_key_79,
                    themeColor(
                      (load == Load.finish
                              ? AppThemeKeys.mainButtonTextColor
                              : AppThemeKeys.mainButtonBgColor3)
                          .name,
                    ),
                    themeColor(AppThemeKeys.mainButtonBgColor.name),
                    borderColor: themeColor(
                      AppThemeKeys.mainButtonBgColor.name,
                    ),
                  ),
                ),
              ),
              SizedBox(width: pad30),
              Expanded(
                child: SizedBox(
                  height: h88,
                  child: buttonStyle6(
                    context,
                    _onConfirm,
                    S.of(context).g_key_78,
                    themeColor(
                      ((load == Load.finish && anyEnabled)
                              ? AppThemeKeys.mainButtonBgColor
                              : AppThemeKeys.mainButtonBgColor3)
                          .name,
                    ),
                    themeColor(AppThemeKeys.mainButtonTextColor.name),
                    load == Load.loading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
