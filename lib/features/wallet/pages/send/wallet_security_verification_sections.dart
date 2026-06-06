part of 'wallet_security_verification.dart';

/// Common input text style used across all verification sections.
TextStyle _inputTextStyle(BuildContext context) => TextStyle(
  color: AppColorTokens.of(context).textPrimary,
  fontSize: ScreenUtil().setSp(28.0),
);

/// Common hint text style used across all verification sections.
TextStyle _hintTextStyle(BuildContext context) => TextStyle(
  fontSize: ScreenUtil().setSp(28.0),
  color: AppColorTokens.of(context).textSubtitle,
);

/// Common InputDecoration with no borders.
InputDecoration _noBorderDecoration(
  BuildContext context,
  String hintText, {
  String? counterText,
}) => InputDecoration(
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
              decoration: _noBorderDecoration(
                context,
                S.of(context).g_key_t_35,
              ),
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
              style: _inputTextStyle(
                context,
              ).copyWith(fontSize: ScreenUtil().setSp(24.0)),
            ),
          ),
          _PillButton(label: S.of(context).Verification, onTap: onVerify),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _GoogleAuthSection extends StatefulWidget {
  const _GoogleAuthSection({
    required this.enabled,
    required this.verified,
    required this.errorMessage,
    required this.onVerify,
    required this.onSetup,
  });

  final bool enabled;
  final bool verified;
  final String errorMessage;
  final ValueChanged<String> onVerify;
  final VoidCallback onSetup;

  @override
  State<_GoogleAuthSection> createState() => _GoogleAuthSectionState();
}

class _GoogleAuthSectionState extends State<_GoogleAuthSection> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(S.of(context).g_google_auth_key1),
          SizedBox(height: ScreenUtil().setWidth(10.0)),
          if (widget.enabled) ...[
            _buildInput(context),
            _ErrorMessage(widget.errorMessage),
          ] else
            _SetupPromptRow(
              message: S.of(context).g_google_auth_key7,
              buttonLabel: S.of(context).google_verification_message10,
              onSetup: widget.onSetup,
            ),
          SizedBox(height: ScreenUtil().setWidth(40.0)),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final Color mainText = AppColorTokens.of(context).textPrimary;
    final Color subtitleColor = AppColorTokens.of(context).textSubtitle;
    final Color mainBlue = AppColorTokens.of(context).brand;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(32.0)),
      decoration: _inputBoxDecoration(context),
      height: ScreenUtil().setWidth(100.0),
      child: Row(
        children: [
          Expanded(
            child: widget.verified
                ? Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: mainBlue,
                        size: ScreenUtil().setWidth(36.0),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(10.0)),
                      Text(
                        S.of(context).g_lock_key5,
                        style: _inputTextStyle(
                          context,
                        ).copyWith(fontSize: ScreenUtil().setSp(26.0)),
                      ),
                    ],
                  )
                : TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(
                      color: mainText,
                      fontSize: ScreenUtil().setSp(28.0),
                      letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      hintText: S.of(context).g_google_auth_key4,
                      hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: subtitleColor,
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: widget.onVerify,
                  ),
          ),
          if (!widget.verified)
            _PillButton(
              label: S.of(context).Verification,
              onTap: () => widget.onVerify(_ctrl.text.trim()),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _GestureSection extends StatelessWidget {
  const _GestureSection({
    required this.enabled,
    required this.gesturePwd,
    required this.gestureCheck,
    required this.gestureErrorMessage,
    required this.onComplete,
    required this.onSetup,
  });

  final bool enabled;
  final String gesturePwd;
  final int gestureCheck; // 0=未验证 1=成功 2=失败
  final String gestureErrorMessage;
  final ValueChanged<String> onComplete;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(S.of(context).g_lock_key16),
          SizedBox(height: ScreenUtil().setWidth(10.0)),
          if (enabled) ...[
            _buildGestureArea(context),
            _ErrorMessage(gestureErrorMessage),
          ] else
            _SetupPromptRow(
              message: S.of(context).g_lock_key28,
              buttonLabel: S.of(context).google_verification_message10,
              onSetup: onSetup,
            ),
          SizedBox(height: ScreenUtil().setWidth(40.0)),
        ],
      ),
    );
  }

  Widget _buildGestureArea(BuildContext context) {
    final double gridSize = ScreenUtil().setWidth(480.0);
    final double identifySize = ScreenUtil().setWidth(160.0);
    final double bigWidth = identifySize / 2;
    final double miniWidth = identifySize / 4;

    final Color mainBlue = AppColorTokens.of(context).brand;
    final Color errorColor = AppColorTokens.of(context).danger;
    final Color subtitleColor = AppColorTokens.of(context).textSubtitle;
    final Color bgColor = AppColorTokens.of(context).bgSurface;

    final List<int>? answer = gestureCheck == 1
        ? null
        : gesturePwd.isNotEmpty
        ? gesturePwd.split(',').map(int.parse).toList()
        : null;

    return Container(
      decoration: _inputBoxDecoration(context),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
      child: Column(
        children: [
          if (gestureCheck == 1)
            SizedBox(
              height: ScreenUtil().setWidth(60.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: mainBlue,
                    size: ScreenUtil().setWidth(40.0),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10.0)),
                  Text(
                    S.of(context).g_lock_key5,
                    style: _inputTextStyle(
                      context,
                    ).copyWith(fontSize: ScreenUtil().setSp(26.0)),
                  ),
                ],
              ),
            )
          else
            Center(
              child: SizedBox(
                width: gridSize,
                height: gridSize,
                child: KeyedSubtree(
                  key: ValueKey(gestureCheck),
                  child: GesturePasswordWidget(
                    size: gridSize,
                    lineColor: mainBlue,
                    errorLineColor: errorColor,
                    singleLineCount: 3,
                    identifySize: identifySize,
                    minLength: 4,
                    hitShowMilliseconds: 40,
                    answer: answer,
                    color: bgColor,
                    normalItem: Container(
                      height: miniWidth,
                      width: miniWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(miniWidth),
                        ),
                        color: subtitleColor,
                      ),
                    ),
                    selectedItem: Container(
                      width: bigWidth,
                      height: bigWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(bigWidth),
                        ),
                        color: mainBlue.withAlpha((0.5 * 255).round()),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: miniWidth,
                        height: miniWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(miniWidth),
                          ),
                          color: mainBlue,
                        ),
                      ),
                    ),
                    hitItem: Container(
                      width: bigWidth,
                      height: bigWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(bigWidth),
                        ),
                        color: mainBlue.withAlpha((0.5 * 255).round()),
                      ),
                    ),
                    errorItem: Container(
                      width: bigWidth,
                      height: bigWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(bigWidth),
                        ),
                        color: errorColor.withAlpha((0.5 * 255).round()),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: miniWidth,
                        height: miniWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(miniWidth),
                          ),
                          color: errorColor,
                        ),
                      ),
                    ),
                    onComplete: (data) => onComplete(data.join(',')),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
