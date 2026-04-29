part of 'wallet_security_verification.dart';

/// Common input text style used across all verification sections.
TextStyle _inputTextStyle(BuildContext context) => TextStyle(
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
      fontSize: ScreenUtil().setSp(28.0),
    );

/// Common hint text style used across all verification sections.
TextStyle _hintTextStyle(BuildContext context) => TextStyle(
      fontSize: ScreenUtil().setSp(28.0),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
    );

/// Common InputDecoration with no borders.
InputDecoration _noBorderDecoration(BuildContext context, String hintText, {String? counterText}) =>
    InputDecoration(
      hintText: hintText,
      hintStyle: _hintTextStyle(context),
      border: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      counterText: counterText,
    );

class _WalletPasswordSection extends StatelessWidget {
  const _WalletPasswordSection({
    required this.showPasswordInput,
    required this.pwdController,
    required this.obscure,
    required this.pwdErrorMessage,
    required this.onToggleObscure,
    required this.onSetupPassword,
    required this.onEditingComplete,
  });

  final bool showPasswordInput;
  final TextEditingController pwdController;
  final bool obscure;
  final String pwdErrorMessage;
  final VoidCallback onToggleObscure;
  final VoidCallback onSetupPassword;
  final VoidCallback onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(S.of(context).g_key_t_32),
          SizedBox(height: ScreenUtil().setWidth(10.0)),
          if (showPasswordInput) ...[
            _buildInput(context),
            _ErrorMessage(pwdErrorMessage),
          ] else
            _SetupPromptRow(
              message: S.of(context).g_lock_key24,
              buttonLabel: S.of(context).google_verification_message10,
              onSetup: onSetupPassword,
            ),
          SizedBox(height: ScreenUtil().setWidth(40.0)),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(32.0)),
      decoration: _inputBoxDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: _inputTextStyle(context),
              obscureText: obscure,
              controller: pwdController,
              textInputAction: TextInputAction.done,
              decoration: _noBorderDecoration(context, S.of(context).g_key_t_35),
              maxLines: 1,
              onEditingComplete: onEditingComplete,
            ),
          ),
          InkWell(
            onTap: onToggleObscure,
            child: SizedBox(
              height: ScreenUtil().setWidth(40.0),
              width: ScreenUtil().setWidth(40.0),
              child: Image.asset(
                'assets/login/${obscure ? 'icon_denglu_yincang' : 'icon_denglu_xianshi'}.png',
                color: _hintTextStyle(context).color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceSection extends StatelessWidget {
  const _FaceSection({
    required this.enabled,
    required this.faceCheck,
    required this.faceErrorMessage,
    required this.onVerify,
    required this.onSetup,
  });

  final bool enabled;
  final int faceCheck;
  final String faceErrorMessage;
  final VoidCallback onVerify;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(S.of(context).g_lock_key1),
          SizedBox(height: ScreenUtil().setWidth(10.0)),
          if (enabled) ...[
            _buildFaceRow(context),
            _ErrorMessage(faceErrorMessage),
          ] else
            _SetupPromptRow(
              message: S.of(context).g_lock_key8,
              buttonLabel: S.of(context).google_verification_message10,
              onSetup: onSetup,
            ),
          SizedBox(height: ScreenUtil().setWidth(40.0)),
        ],
      ),
    );
  }

  Widget _buildFaceRow(BuildContext context) {
    final statusText = switch (faceCheck) {
      1 => S.of(context).g_lock_key5,
      2 => S.of(context).g_lock_key6,
      _ => '',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(32.0)),
      decoration: _inputBoxDecoration(context),
      height: ScreenUtil().setWidth(100.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              statusText,
              style: _inputTextStyle(context).copyWith(
                fontSize: ScreenUtil().setSp(24.0),
              ),
            ),
          ),
          _PillButton(label: S.of(context).Verification, onTap: onVerify),
        ],
      ),
    );
  }
}
