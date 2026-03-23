part of 'security_google_vedification.dart';

/// UI widget builders for SecurityGoogleVedification page.
extension _SecurityGoogleVedificationWidgets
    on SecurityGoogleVedificationState {

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      height: ScreenUtil().setWidth(150.0),
      child: Container(
        height: ScreenUtil().setWidth(100.0),
        width: double.infinity,
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.backGroundColor.name),
        padding: EdgeInsets.only(
          bottom: ScreenUtil().setWidth(36.0),
          top: ScreenUtil().setWidth(26.0),
          left: ScreenUtil().setWidth(30.0),
          right: ScreenUtil().setWidth(30.0),
        ),
        child: buttonStyle2(
          context,
          _handleSubmit,
          S.of(context).g_key_154,
        ),
      ),
    );
  }

  /// Error message row used by multiple sections.
  Widget _buildErrorMessage(String message) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        message,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
          fontSize: ScreenUtil().setSp(26.0),
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  /// Standard input container decoration.
  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      borderRadius:
          BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemBgColor.name),
    );
  }

  /// Standard input container constraints.
  BoxConstraints _inputBoxConstraints() {
    return BoxConstraints(
      minHeight: ScreenUtil().setWidth(88.0),
      maxHeight: ScreenUtil().setWidth(88.0),
    );
  }

  //谷歌验证控件
  Widget buildGoogleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).google_verification_message19,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(28.0),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(10.0)),
        Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0)),
          decoration: _inputBoxDecoration(),
          constraints: _inputBoxConstraints(),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                  controller: googleTextEditingController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(18.0)),
                    hintText: S.of(context).rest_Please_enter,
                    hintStyle: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  maxLines: 1,
                  onEditingComplete: closeKeyboard,
                ),
              ),
              _buildPasteButton(),
            ],
          ),
        ),
        _buildErrorMessage(googleErrorMessage),
        SizedBox(height: ScreenUtil().setWidth(40.0)),
      ],
    );
  }

  Widget _buildPasteButton() {
    return InkWell(
      onTap: () async {
        final cd = await Clipboard.getData(Clipboard.kTextPlain);
        final text = cd?.text;
        if (text != null && text != "null") {
          pasteGoogleCode(text);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(10.0),
            horizontal: ScreenUtil().setWidth(20.0)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
        ),
        child: Text(
          S.of(context).g_key_166,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonTextColor.name),
          ),
        ),
      ),
    );
  }

  //邮箱验证
  Widget buildEmailSection() {
    if (!securityMap['email']) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).google_verification_message20,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(28.0),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(10.0)),
        Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0)),
          decoration: _inputBoxDecoration(),
          constraints: _inputBoxConstraints(),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                  controller: emailTextEditingController,
                  textInputAction: TextInputAction.done,
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: S.of(context).rest_Please_enter,
                    hintStyle: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(18.0)),
                  ),
                  maxLines: 1,
                  onEditingComplete: closeKeyboard,
                ),
              ),
              _buildEmailVerificationButton(),
            ],
          ),
        ),
        _buildErrorMessage(emailErrorMessage),
        SizedBox(height: ScreenUtil().setWidth(40.0)),
      ],
    );
  }

  //发送邮箱验证码按钮
  Widget _buildEmailVerificationButton() {
    final buttonTextColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainButtonTextColor.name);
    Widget leftWidget;
    if (emailLoad == Load.loading) {
      leftWidget = SizedBox(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        child: CircularProgressIndicator(color: buttonTextColor),
      );
    } else if (emailSendWait) {
      leftWidget = Padding(
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(6.0)),
        child: Text(
          '($emailSendWaitNum)',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30.0),
            color: buttonTextColor,
          ),
        ),
      );
    } else {
      leftWidget = const SizedBox.shrink();
    }
    return InkWell(
      onTap: getEmailVerification,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(10.0),
            horizontal: ScreenUtil().setWidth(20.0)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leftWidget,
            Text(
              S.of(context).Verification,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //钱包密码
  Widget buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).google_verification_message21(walletName),
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(30.0),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(10.0)),
        Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(30.0)),
          decoration: _inputBoxDecoration(),
          constraints: _inputBoxConstraints(),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                  obscureText: obscure,
                  controller: pwdTextEditingController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: S.of(context).g_key_t_35,
                    hintStyle: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(18.0)),
                    isCollapsed: true,
                  ),
                  maxLines: 1,
                  onEditingComplete: closeKeyboard,
                ),
              ),
              InkWell(
                onTap: toggleObscure,
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: Image.asset(
                    "assets/login/${obscure ? 'icon_denglu_yincang' : 'icon_denglu_xianshi'}.png",
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildErrorMessage(pwdErrorMessage),
        SizedBox(height: ScreenUtil().setWidth(40.0)),
      ],
    );
  }
}
