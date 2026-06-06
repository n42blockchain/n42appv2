import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gesture_password_widget/gesture_password_widget.dart';
import 'package:n42_wallet/core/security/totp_util.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart' as auth_android;
import 'package:local_auth_darwin/local_auth_darwin.dart' as auth_ios;
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_password.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/generated/l10n.dart';

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

  bool obscure = true;
  String pwdErrorMessage = '';
  String faceErrorMessage = '';
  String gestureErrorMessage = '';
  String googleAuthErrorMessage = '';
  int faceCheck = 0; // 0未验证，1验证成功，2验证失败
  int gestureCheck = 0; // 0未验证，1验证成功，2验证失败
  int googleAuthCheck = 0; // 0未验证，1验证成功，2验证失败
  Load load = Load.finish;
  bool showWalletPassword = false;

  Map<String, dynamic> securityMap = {
    'face': false,
    'gesture': false,
    'gesturePwd': '',
    'google': false,
    'googleSecret': '',
  };

  @override
  void initState() {
    super.initState();
    initSecurity();
  }

  @override
  void dispose() {
    pwdTextEditingController.dispose();
    super.dispose();
  }

  Future<void> initSecurity() async {
    final s = await SPUtil().getSecurity();
    final userMap = s?[AppGlobals.userInfo?.uuid ?? ''];
    if (userMap is Map<String, dynamic>) {
      securityMap['face'] = userMap['face'] ?? false;
      securityMap['gesture'] = userMap['gesture'] ?? false;
      securityMap['gesturePwd'] = userMap['gesturePwd'] ?? '';
      securityMap['google'] = userMap['google'] ?? false;
      securityMap['googleSecret'] = userMap['googleSecret'] ?? '';
    }
    if (!mounted) return;
    showWalletPassword = ref.read(wapBridgeProvider).walletInfo.password != '';
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
    FocusScope.of(context).unfocus();
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
    if (!mounted) return;
    if (canCheck) {
      final available = await auth.getAvailableBiometrics();
      if (!mounted) return;
      canCheck = available.any(
        const {
          BiometricType.face,
          BiometricType.strong,
          BiometricType.weak,
          BiometricType.fingerprint,
        }.contains,
      );
    }
    if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        faceCheck = 2;
        faceErrorMessage = e.toString();
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      faceCheck = authenticated ? 1 : 2;
      faceErrorMessage = authenticated ? '' : S.of(context).g_lock_key6;
    });
  }

  Future<void> pushSetting() async {
    await Navigator.pushNamed(context, '/securitySetting');
    if (!mounted) return;
    initSecurity();
  }

  Future<void> pushEditWallet() async {
    final int wIndex = ref.read(wapBridgeProvider).walletIndex;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditWalletPassword(ref.read(wapBridgeProvider).walletInfo, wIndex),
      ),
    );
    if (!mounted) return;
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

  void gestureVerification(String value) {
    final pwd = securityMap['gesturePwd'] as String;
    if (value == pwd) {
      setState(() {
        gestureCheck = 1;
        gestureErrorMessage = '';
      });
    } else {
      setState(() {
        gestureCheck = 2;
        gestureErrorMessage = S.of(context).g_lock_key6;
      });
    }
  }

  void googleAuthVerify(String code) {
    final secret = securityMap['googleSecret'] as String;
    if (TotpUtil.verify(secret, code)) {
      setState(() {
        googleAuthCheck = 1;
        googleAuthErrorMessage = '';
      });
    } else {
      setState(() {
        googleAuthCheck = 2;
        googleAuthErrorMessage = S.of(context).g_google_auth_key6;
      });
    }
  }

  bool get _anySecurityEnabled =>
      showWalletPassword ||
      securityMap['face'] == true ||
      securityMap['gesture'] == true ||
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

    if (securityMap['gesture'] == true) {
      if (gestureCheck != 1) {
        setState(() => gestureErrorMessage = S.of(context).verification);
        return;
      }
      setState(() => gestureErrorMessage = '');
    }

    if (securityMap['google'] == true) {
      if (googleAuthCheck != 1) {
        setState(() => googleAuthErrorMessage = S.of(context).verification);
        return;
      }
      setState(() => googleAuthErrorMessage = '');
    }

    setState(() => load = Load.loading);

    if (showWalletPassword && !checkPwd()) {
      _finishLoading();
      return;
    }

    if (!mounted) return;
    _finishLoading();
    Navigator.pop(context, true);
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
                  horizontal: ScreenUtil().setWidth(30.0),
                ),
                child: Image.asset(
                  'assets/img/Setting.png',
                  color: AppColorTokens.of(context).textPrimary,
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
                  child: Column(children: _buildVerificationWidgets()),
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
