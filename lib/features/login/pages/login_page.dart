import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/login/api/handtype.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/login/pages/account_create_and_reset.dart';
import 'package:n42_wallet/features/login/widgets/login_title.dart';
import 'package:n42_wallet/features/login/widgets/social_login_buttons.dart';
import 'package:n42_wallet/features/login/widgets/user_protocol.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/features/utils/device_info_util.dart';
import 'package:n42_wallet/features/utils/md5_util.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Login Page - Migrated to Riverpod
///
/// Handles user authentication
class LoginPage extends ConsumerStatefulWidget {
  final int type; // 0 push, 1 content
  const LoginPage({this.type = 0, super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _unameController = TextEditingController();
  final _uPasswordController = TextEditingController();
  final _unameFocusNode = FocusNode();
  final _uPasswordFocusNode = FocusNode();
  String unameErrorMessage = "";
  String uPasswordErrorMessage = "";
  bool isSelectedUserProtocol = false;
  bool showPwd = true; //显示密码
  Load load = Load.finish;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _unameController.dispose();
    _uPasswordController.dispose();
    _unameFocusNode.dispose();
    _uPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastUtils.init(context);
    return Scaffold(
      appBar: widget.type == 0
          ? AppBarWidget(text: S.of(context).login_button_text)
          : null,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(30.0),
                      vertical: ScreenUtil().setWidth(60.0),
                    ),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                            bottom: ScreenUtil().setWidth(50.0),
                          ),
                          child: Text(
                            S.of(context).g_key_login,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(48.0),
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainTextColor.name,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        LoginTitle(
                          title: S.of(context).login_email,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor10.name,
                          ),
                          must: true,
                        ),
                        SizedBox(height: ScreenUtil().setWidth(10)),
                        textFieldStyle3(
                          context,
                          onEditingComplete: () {
                            FocusScope.of(
                              context,
                            ).requestFocus(_uPasswordFocusNode);
                          },
                          controller: _unameController,
                          focusNode: _unameFocusNode,
                          hintText: S.of(context).login_email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          errorMessage: unameErrorMessage,
                          hintStyle: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.hintTextColor.name,
                            ),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setHeight(20)),
                        LoginTitle(
                          title: S.of(context).login_password,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor10.name,
                          ),
                          must: true,
                        ),
                        SizedBox(height: ScreenUtil().setWidth(10)),
                        textFieldStyle3(
                          context,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                          },
                          controller: _uPasswordController,
                          focusNode: _uPasswordFocusNode,
                          hintText: S.of(context).login_password,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          hintStyle: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.hintTextColor.name,
                            ),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                          obscure: showPwd,
                          rightWidget1: Container(
                            width: ScreenUtil().setWidth(50.0),
                            height: ScreenUtil().setWidth(50.0),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/login/${showPwd ? "icon_denglu_yincang" : "icon_denglu_xianshi"}.png',
                              width: ScreenUtil().setWidth(34.0),
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainBlueColor.name,
                              ),
                            ),
                          ),
                          rightOnTap1: () {
                            setState(() {
                              showPwd = !showPwd;
                            });
                          },
                        ),
                        SizedBox(height: ScreenUtil().setWidth(44)),
                        _buildText(context),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(30.0),
                            vertical: ScreenUtil().setWidth(60.0),
                          ),
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: S.of(context).login_message_1,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(32.0),
                                    color: AppThemeUtils.getColorByKey(
                                      context,
                                      AppThemeKeys.mainTextColor.name,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: S.of(context).Create_account,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(32.0),
                                    color: AppThemeUtils.getColorByKey(
                                      context,
                                      AppThemeKeys.mainBlueColor.name,
                                    ),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final navigator = Navigator.of(context);
                                      final rData = await navigator.push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => AccountCreateAndReset(
                                            type: HandType.createAccount,
                                            pushType: widget.type,
                                          ),
                                        ),
                                      );
                                      if (!mounted) return;
                                      if (rData == true) navigator.pop();
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Social login (Google / Apple)
                        SocialLoginButtons(
                          isSelectedUserProtocol: isSelectedUserProtocol,
                          onLoginSuccess: () {
                            if (widget.type == 0) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    UserProtocol(
                      onChanged: (value) {
                        isSelectedUserProtocol = value;
                        setState(() {});
                      },
                    ),
                    const Divider(height: 1),
                    Container(
                      height: ScreenUtil().setWidth(148),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.backGroundColor.name,
                      ),
                      child: buttonStyle6(
                        context,
                        _onLoginTap,
                        S.of(context).login_button_text,
                        AppThemeUtils.getColorByKey(
                          context,
                          load == Load.loading
                              ? AppThemeKeys.mainButtonBgColor3.name
                              : AppThemeKeys.mainButtonBgColor.name,
                        ),
                        AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainButtonTextColor.name,
                        ),
                        load == Load.loading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final textColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainBlueColor.name,
    );
    return Align(
      alignment: Alignment.centerRight,
      child: RichText(
        text: TextSpan(
          text: S.of(context).login_forgot_password,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32.0),
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final navigator = Navigator.of(context);
              final rData = await navigator.push<bool>(
                MaterialPageRoute(
                  builder: (_) => AccountCreateAndReset(
                    type: HandType.restPassword,
                    pushType: widget.type,
                  ),
                ),
              );
              if (!mounted) return;
              if (rData == true) navigator.pop();
            },
        ),
      ),
    );
  }

  Future<void> _init() async {
    final spUtil = SPUtil();
    final readLoginClause = await spUtil.getReadLoginClause();
    if (!mounted) return;
    isSelectedUserProtocol = readLoginClause;
    final data = await spUtil.getUserInfo();
    if (!mounted) return;
    if (data != null) {
      _unameController.text = UserInfo.fromJson(data).email ?? "";
    }
    setState(() {});
  }

  /// Validate inputs and perform login.
  Future<void> _onLoginTap() async {
    final s = S.of(context);
    final email = _unameController.text.trim();
    final password = _uPasswordController.text.trim();

    if (email.isEmpty) {
      setState(() => unameErrorMessage = s.please_enter_email);
      ToastUtils.show(s.please_enter_email);
      return;
    }
    if (!Regular().isEmail(email)) {
      setState(() => unameErrorMessage = s.email_error);
      ToastUtils.show(s.email_error);
      return;
    }
    unameErrorMessage = "";
    if (password.isEmpty) {
      setState(() => uPasswordErrorMessage = s.please_enter_password);
      ToastUtils.show(s.please_enter_password);
      return;
    }
    uPasswordErrorMessage = "";
    setState(() {});
    if (!isSelectedUserProtocol) {
      ToastUtils.show(s.selected_user_protocol);
      return;
    }
    bool completedWithExit = false;
    try {
      setState(() => load = Load.loading);
      final deviceInfo = await DeviceInfoUtil().getFullDeviceInfo();
      final data = await UserInfoApi().login(
        email,
        Md5Util().generateMd5(password),
        deviceInfo: deviceInfo,
      );
      if (!mounted) return;
      if (data == null) return;
      if (data["code"] == 200) {
        final userInfo = UserInfo.fromJson(data['data']);
        await SPUtil().saveUserInfo(userInfo);
        if (!mounted) return;
        await AppGlobals.login(userInfo);
        if (!mounted) return;
        if (widget.type == 0) {
          completedWithExit = true;
          Navigator.pop(context);
        }
      } else if (data["code"] == -403) {
        ToastUtils.showFtToast(title: s.code_403);
      } else if (data["code"] == -1301) {
        ToastUtils.showFtToast(title: s.g_key_error_1301);
      } else {
        ToastUtils.showFtToast(title: data["err"]);
      }
    } catch (err) {
      ToastUtils.show(err.toString());
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => load = Load.finish);
      }
    }
  }
}
