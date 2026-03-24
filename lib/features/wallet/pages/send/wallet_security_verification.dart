import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart' as auth_android;
import 'package:local_auth_darwin/local_auth_darwin.dart' as auth_ios;
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_password.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_6.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

part 'wallet_security_verification_widgets.dart';
part 'wallet_security_verification_sections.dart';

class WalletSecurityVerification extends ConsumerStatefulWidget {
  const WalletSecurityVerification({super.key});

  @override
  ConsumerState<WalletSecurityVerification> createState() =>
      _WalletSecurityVerificationState();
}

class _WalletSecurityVerificationState
    extends ConsumerState<WalletSecurityVerification> {
  final TextEditingController pwdTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController googleTextEditingController =
      TextEditingController();

  bool obscure = true;
  String pwdErrorMessage = '';
  String emailErrorMessage = '';
  String googleErrorMessage = '';
  String faceErrorMessage = '';
  int faceCheck = 0; // 0未验证，1验证成功，2验证失败
  int emailSendWaitNum = 60;
  bool emailSendWait = false;
  Load load = Load.finish;
  Load emailLoad = Load.finish;
  bool showWalletPassword = false;
  Timer? _emailTimer;

  // 账号安全开关
  Map<String, dynamic> securityMap = {
    'email': false,
    'google': false,
    'face': false,
  };

  late UserInfoApi userInfoApi;

  @override
  void initState() {
    super.initState();
    userInfoApi = UserInfoApi();
    initSecurity();
  }

  @override
  void dispose() {
    _emailTimer?.cancel();
    pwdTextEditingController.dispose();
    emailTextEditingController.dispose();
    googleTextEditingController.dispose();
    super.dispose();
  }

  Future<void> initSecurity() async {
    final s = await SPUtil().getSecurity();
    final userMap = s?[AppGlobals.userInfo?.uuid ?? ''];
    if (userMap is Map<String, dynamic>) {
      securityMap['email'] = userMap['email'] ?? false;
      securityMap['google'] = userMap['google'] ?? false;
      securityMap['face'] = userMap['face'] ?? false;
    }
    if (!mounted) return;
    showWalletPassword =
        ref.read(wapBridgeProvider).walletInfo.password != '';
    setState(() {});
  }

  bool checkPwd() {
    final String pwdStr = pwdTextEditingController.text;
    final String oldPwdStr =
        ref.read(wapBridgeProvider).walletInfo.password ?? '';
    final bool match = oldPwdStr == pwdStr;
    setState(() => pwdErrorMessage = match ? '' : S.of(context).g_key_t_34);
    return match;
  }

  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> getEmailVerification() async {
    if (emailLoad == Load.loading || emailSendWait) return;
    setState(() => emailLoad = Load.loading);
    final MessageModel mm = await userInfoApi.getEmailVerification();
    if (!mounted) return;
    if (mm.error) {
      ToastUtils.show(S.of(context).email_code_error);
    } else {
      ToastUtils.show(S.of(context).email_code_finish);
      emailSendWait = true;
      _startEmailCountdown();
    }
    setState(() => emailLoad = Load.finish);
  }

  void _startEmailCountdown() {
    _emailTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        emailSendWaitNum--;
      });
      if (emailSendWaitNum <= 0) {
        emailSendWaitNum = 60;
        emailSendWait = false;
      } else {
        _startEmailCountdown();
      }
    });
  }

  // 验证邮箱验证码
  Future<bool> checkEmailVerification() async {
    final codeStr = emailTextEditingController.text;
    if (codeStr.isEmpty) {
      setState(() => emailErrorMessage = S.of(context).rest_Please_enter);
      return false;
    }
    if (codeStr.length != 6) {
      setState(() => emailErrorMessage = S.of(context).email_code_input_error);
      return false;
    }
    final mm = await userInfoApi.checkEmailVerification(codeStr);
    setState(() => emailErrorMessage = mm.error ? S.of(context).email_code_input_error : '');
    return !mm.error;
  }

  // 谷歌验证码验证
  Future<bool> checkGoogleVerification() async {
    final codeStr = googleTextEditingController.text.trim();
    if (codeStr.isEmpty) {
      setState(() => googleErrorMessage = S.of(context).rest_Please_enter);
      return false;
    }
    if (codeStr.length != 6 || !RegExp(r'^\d{6}$').hasMatch(codeStr)) {
      setState(() => googleErrorMessage = S.of(context).g_2fa_invalid_format);
      return false;
    }
    final mm = await userInfoApi.checkGoogle(codeStr);
    setState(() => googleErrorMessage = mm.error ? S.of(context).email_code_input_error : '');
    return !mm.error;
  }

  Future<void> faceVerification() async {
    final LocalAuthentication auth = LocalAuthentication();
    await _checkBiometrics(auth);
  }

  Future<void> _checkBiometrics(LocalAuthentication auth) async {
    bool canCheck;
    try {
      canCheck = await auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      canCheck = false;
    }
    if (canCheck) {
      final available = await auth.getAvailableBiometrics();
      canCheck = available.any(const {
        BiometricType.face,
        BiometricType.strong,
        BiometricType.weak,
        BiometricType.fingerprint,
      }.contains);
    }
    if (!canCheck) {
      setState(() => faceErrorMessage = S.of(context).g_lock_key7);
      return;
    }
    setState(() => faceErrorMessage = '');
    await _authenticateWithBiometrics(auth);
  }

  Future<void> _authenticateWithBiometrics(LocalAuthentication auth) async {
    bool authenticated;
    try {
      final authMessage = Platform.isIOS
          ? auth_ios.IOSAuthMessages(
              cancelButton: S.of(context).g_key_79,
              localizedFallbackTitle: S.of(context).g_face_8,
            )
          : auth_android.AndroidAuthMessages(
              signInHint: S.of(context).g_face_1,
              cancelButton: S.of(context).g_key_79,
              signInTitle: S.of(context).g_face_7,
            );
      authenticated = await auth.authenticate(
        localizedReason: S.of(context).g_face_10,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        authMessages: [authMessage],
      );
    } on PlatformException catch (e) {
      setState(() {
        faceCheck = 2;
        faceErrorMessage = e.toString();
      });
      return;
    }
    setState(() {
      faceCheck = authenticated ? 1 : 2;
      faceErrorMessage = authenticated ? '' : S.of(context).g_lock_key6;
    });
  }

  Future<void> pushSetting() async {
    await Navigator.pushNamed(context, 'securitySetting');
    initSecurity();
  }

  Future<void> pushEditWallet() async {
    final int wIndex = ref.read(wapBridgeProvider).walletIndex;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWalletPassword(
          ref.read(wapBridgeProvider).walletInfo,
          wIndex,
        ),
      ),
    );
    initSecurity();
  }

  Future<bool> _pageBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    } else {
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  /// 重置 loading 状态
  void _finishLoading() => setState(() => load = Load.finish);

  bool get _anySecurityEnabled =>
      showWalletPassword ||
      securityMap['face'] == true ||
      securityMap['email'] == true ||
      securityMap['google'] == true;

  Future<void> _onConfirm() async {
    closeKeyboard();
    if (load == Load.loading || !_anySecurityEnabled) return;

    if (securityMap['face'] == true) {
      if (faceCheck != 1) {
        setState(() => faceErrorMessage = S.of(context).verification);
        return;
      }
      setState(() => faceErrorMessage = '');
    }

    setState(() => load = Load.loading);

    if (showWalletPassword && !checkPwd()) { _finishLoading(); return; }

    if (securityMap['email'] == true) {
      if (!await checkEmailVerification()) { if (mounted) _finishLoading(); return; }
    }
    if (securityMap['google'] == true) {
      if (!await checkGoogleVerification()) { if (mounted) _finishLoading(); return; }
    }

    if (!mounted) return;
    _finishLoading();
    Navigator.pop(context, true);
  }

  Future<void> showLoginDialog() async {
    final flag = await tipsDialog6(
      context,
      title: S.of(context).login_need_login,
    );
    if (!mounted) return;
    if (flag == true) {
      await Navigator.pushNamed(context, '/LoginPage');
      if (!mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).s_key_11,
          actions: [
            InkWell(
              onTap: pushSetting,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(30.0)),
                child: Image.asset(
                  'assets/img/Setting.png',
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  width: ScreenUtil().setWidth(40.0),
                  height: ScreenUtil().setWidth(40.0),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                  child: Column(
                    children: _buildVerificationWidgets(),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: _buildBottomBar(_anySecurityEnabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
