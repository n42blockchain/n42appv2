part of 'account_create_and_reset.dart';

/// UI widget builders for AccountCreateAndReset page.
extension _AccountCreateAndResetWidgets on _AccountCreateAndResetState {
  Widget _buildPageTitle(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
      child: Text(
        _currentType == HandType.restPassword
            ? S.of(context).rest_your_password
            : S.of(context).Create_your_account,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(48.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoginTitle(
          title: S.of(context).login_email,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
          must: true,
        ),
        SizedBox(height: ScreenUtil().setWidth(10)),
        textFieldStyle3(
          context,
          onEditingComplete: () {
            FocusScope.of(context).requestFocus(_uPasswordFocusNode);
          },
          controller: _unameController,
          focusNode: _unameFocusNode,
          hintText: S.of(context).login_email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorMessage: unameErrorMessage,
          hintStyle: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
            fontSize: ScreenUtil().setSp(30.0),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoginTitle(
          title: _currentType == HandType.restPassword
              ? S.of(context).g_lock_key11
              : S.of(context).login_password,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
          must: true,
        ),
        SizedBox(height: ScreenUtil().setWidth(10)),
        textFieldStyle3(
          context,
          onEditingComplete: () {
            FocusScope.of(context).requestFocus(_uPasswordConfirmFocusNode);
          },
          controller: _uPasswordController,
          focusNode: _uPasswordFocusNode,
          hintText: S.of(context).rest_Choose_password,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          errorMessage: uPasswordErrorMessage,
          hintStyle: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
            fontSize: ScreenUtil().setSp(30.0),
          ),
          obscure: showPwd1,
          rightWidget1: _buildPasswordToggleIcon(showPwd1),
          rightOnTap1: toggleShowPwd1,
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoginTitle(
          title: _currentType == HandType.restPassword
              ? S.of(context).g_lock_key12
              : S.of(context).rest_Confirm_password,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
          must: true,
        ),
        SizedBox(height: ScreenUtil().setWidth(10)),
        textFieldStyle3(
          context,
          onEditingComplete: () {
            if (_currentType == HandType.createAccount) {
              FocusScope.of(context).requestFocus(_inviteCodeFocusNode);
            } else {
              FocusScope.of(context).requestFocus(_uCodeFocusNode);
            }
          },
          controller: _uPasswordConfirmController,
          focusNode: _uPasswordConfirmFocusNode,
          hintText: S.of(context).rest_Enter_the_password_again,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          errorMessage: uPasswordConfirmErrorMessage,
          hintStyle: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
            fontSize: ScreenUtil().setSp(30.0),
          ),
          obscure: showPwd2,
          rightWidget1: _buildPasswordToggleIcon(showPwd2),
          rightOnTap1: toggleShowPwd2,
        ),
      ],
    );
  }

  Widget _buildPasswordToggleIcon(bool isObscured) {
    return Container(
      width: ScreenUtil().setWidth(50.0),
      height: ScreenUtil().setWidth(50.0),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/login/${isObscured ? "icon_denglu_yincang" : "icon_denglu_xianshi"}.png',
        width: ScreenUtil().setWidth(34.0),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor3.name),
      ),
    );
  }

  Widget _buildInviteView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: ScreenUtil().setHeight(20)),
        LoginTitle(
          title: S.of(context).login_invite_code_title,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
        ),
        SizedBox(height: ScreenUtil().setWidth(10)),
        textFieldStyle3(
          context,
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
          },
          controller: _inviteCodeController,
          focusNode: _inviteCodeFocusNode,
          hintText: S.of(context).login_invite_code,
          keyboardType: TextInputType.numberWithOptions(),
          textInputAction: TextInputAction.done,
          hintStyle: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
            fontSize: ScreenUtil().setSp(30.0),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCodeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoginTitle(
          title: S.of(context).rest_Verification_code,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor10.name),
          must: true,
        ),
        SizedBox(height: ScreenUtil().setWidth(10)),
        textFieldStyle3(
          context,
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
          },
          focusNode: _uCodeFocusNode,
          controller: _uCodeController,
          hintText: S.of(context).rest_Please_enter,
          keyboardType: TextInputType.numberWithOptions(),
          textInputAction: TextInputAction.done,
          hintStyle: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.hintTextColor.name),
            fontSize: ScreenUtil().setSp(30.0),
          ),
          rightOnTap1: () {},
          rightWidget1: _buildOtpRightWidget(),
        ),
      ],
    );
  }

  Widget _buildOtpRightWidget() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_countdown == 61 && codeLoad == Load.finish)
            InkWell(
              onTap: _requestVerificationCode,
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(10),
                    horizontal: ScreenUtil().setWidth(8)),
                child: Text(
                  S.of(context).g_key_48,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32.0),
                    color: AppThemeUtils.getColorByKey(
                        context,
                        (_countdown == 61)
                            ? AppThemeKeys.mainBlueColor.name
                            : AppThemeKeys.mainTextColor10.name),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (codeLoad == Load.loading)
            SizedBox(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              child: CircularProgressIndicator(),
            ),
          if (_countdown != 61 && codeLoad == Load.finish)
            Container(
              alignment: Alignment.center,
              child: Text(
                "${S.of(context).login_message_6} $_countdown",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor3.name),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    Color textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: S.of(context).login_forgot_password,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(32.0),
                      color: textColor,
                      fontWeight: FontWeight.w500),
                  recognizer: TapGestureRecognizer()
                    ..onTap = switchToResetPassword,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30.0),
          vertical: ScreenUtil().setWidth(60.0)),
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: S.of(context).login_message_2,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: S.of(context).g_key_login,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontWeight: FontWeight.w400,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  Navigator.pop(context);
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSubmitButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Divider(height: 1, indent: 0, endIndent: 0),
          Container(
            height: ScreenUtil().setWidth(148),
            width: double.infinity,
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name),
            child: buttonStyle6(
              context,
              () async { await _handleSubmit(); },
              S.of(context).g_key_78,
              AppThemeUtils.getColorByKey(
                  context,
                  sendLoad == Load.loading
                      ? AppThemeKeys.mainButtonBgColor3.name
                      : AppThemeKeys.mainButtonBgColor.name),
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonTextColor.name),
              sendLoad == Load.loading,
            ),
          ),
        ],
      ),
    );
  }
}
