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
    _emailTimer = null;
    pwdTextEditingController.dispose();
    emailTextEditingController.dispose();
    googleTextEditingController.dispose();
    emailSendWaitNum = 0;
    super.dispose();
  }

  Future<void> initSecurity() async {
    final Map<String, dynamic>? s = await SPUtil().getSecurity();
    if (s != null) {
      final Map<String, dynamic>? userSecurityMap =
          s[AppGlobals.userInfo?.uuid ?? ''];
      if (userSecurityMap != null) {
        setState(() {
          securityMap['email'] = userSecurityMap['email'];
          securityMap['google'] = userSecurityMap['google'] ?? false;
          securityMap['face'] = userSecurityMap['face'] ?? false;
        });
      }
    }
    if (!mounted) return;
    if (ref.read(wapBridgeProvider).walletInfo.password != '') {
      showWalletPassword = true;
    }
    setState(() {});
  }

  // 验证钱包密码
  bool checkPwd() {
    final String pwdStr = pwdTextEditingController.text;
    final String oldPwdStr =
        ref.read(wapBridgeProvider).walletInfo.password ?? '';
    if (oldPwdStr != pwdStr) {
      setState(() {
        pwdErrorMessage = S.of(context).g_key_t_34;
      });
      return false;
    }
    setState(() {
      pwdErrorMessage = '';
    });
    return true;
  }

  // 关闭键盘
  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // 获取邮箱验证码
  Future<void> getEmailVerification() async {
    if (emailLoad == Load.loading) return;
    if (emailSendWait) return;
    setState(() {
      emailLoad = Load.loading;
    });
    final MessageModel mm = await userInfoApi.getEmailVerification();
    if (!mounted) return;
    if (mm.error) {
      ToastUtils.show(S.of(context).email_code_error);
    } else {
      ToastUtils.show(S.of(context).email_code_finish);
      emailSendWait = true;
      _startEmailCountdown();
    }
    setState(() {
      emailLoad = Load.finish;
    });
  }

  // 邮件发送倒计时
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
    final String codeStr = emailTextEditingController.text;
    if (codeStr.isEmpty) {
      setState(() {
        emailErrorMessage = S.of(context).rest_Please_enter;
      });
      return false;
    }
    if (codeStr.length != 6) {
      setState(() {
        emailErrorMessage = S.of(context).email_code_input_error;
      });
      return false;
    }
    final MessageModel mm =
        await userInfoApi.checkEmailVerification(codeStr);
    if (mm.error) {
      setState(() {
        emailErrorMessage = S.of(context).email_code_input_error;
      });
      return false;
    }
    setState(() {
      emailErrorMessage = '';
    });
    return true;
  }

  // 谷歌验证码验证
  Future<bool> checkGoogleVerification() async {
    final String codeStr = googleTextEditingController.text.trim();
    if (codeStr.isEmpty) {
      setState(() {
        googleErrorMessage = S.of(context).rest_Please_enter;
      });
      return false;
    }
    if (codeStr.length != 6 || !RegExp(r'^\d{6}$').hasMatch(codeStr)) {
      setState(() {
        googleErrorMessage = S.of(context).g_2fa_invalid_format;
      });
      return false;
    }
    final MessageModel mm = await userInfoApi.checkGoogle(codeStr);
    if (mm.error) {
      setState(() {
        googleErrorMessage = S.of(context).email_code_input_error;
      });
      return false;
    }
    setState(() {
      googleErrorMessage = '';
    });
    return true;
  }

  // 生物识别入口
  Future<void> faceVerification() async {
    final LocalAuthentication auth = LocalAuthentication();
    await _checkBiometrics(auth);
  }

  // 检查生物特征是否可用
  Future<void> _checkBiometrics(LocalAuthentication auth) async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      canCheckBiometrics = false;
    }
    if (canCheckBiometrics) {
      final List<BiometricType> available =
          await auth.getAvailableBiometrics();
      canCheckBiometrics = available.isNotEmpty &&
          (available.contains(BiometricType.face) ||
              available.contains(BiometricType.strong) ||
              available.contains(BiometricType.weak) ||
              available.contains(BiometricType.fingerprint));
    }
    if (canCheckBiometrics) {
      setState(() {
        faceErrorMessage = '';
      });
      await _authenticateWithBiometrics(auth);
    } else {
      setState(() {
        faceErrorMessage = S.of(context).g_lock_key7;
      });
    }
  }

  // 执行生物特征验证
  Future<void> _authenticateWithBiometrics(LocalAuthentication auth) async {
    bool authenticated = false;
    try {
      final dynamic authMessage = Platform.isIOS
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
      faceErrorMessage =
          authenticated ? '' : S.of(context).g_lock_key6;
    });
  }

  // 跳转安全设置页
  Future<void> pushSetting() async {
    await Navigator.pushNamed(context, 'securitySetting');
    initSecurity();
  }

  // 跳转编辑钱包密码页
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

  // 确认按钮：依次校验所有安全项
  Future<void> _onConfirm() async {
    closeKeyboard();
    if (load == Load.loading) return;
    final bool anyEnabled = showWalletPassword ||
        securityMap['face'] == true ||
        securityMap['email'] == true ||
        securityMap['google'] == true;
    if (!anyEnabled) return;

    if (securityMap['face'] == true) {
      if (faceCheck != 1) {
        setState(() {
          faceErrorMessage = S.of(context).verification;
        });
        return;
      } else {
        setState(() {
          faceErrorMessage = '';
        });
      }
    }

    setState(() {
      load = Load.loading;
    });

    if (showWalletPassword) {
      if (!checkPwd()) {
        setState(() {
          load = Load.finish;
        });
        return;
      }
    }

    if (securityMap['email'] == true) {
      final bool ok = await checkEmailVerification();
      if (!context.mounted) return;
      if (!ok) {
        setState(() {
          load = Load.finish;
        });
        return;
      }
    }

    if (securityMap['google'] == true) {
      final bool ok = await checkGoogleVerification();
      if (!context.mounted) return;
      if (!ok) {
        setState(() {
          load = Load.finish;
        });
        return;
      }
    }

    if (!context.mounted) return;
    setState(() {
      load = Load.finish;
    });
    // mounted 已检查，此处使用 context 安全
    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  // 登录提醒对话框
  Future<void> showLoginDialog() async {
    final flag = await tipsDialog6(
      context,
      title: S.of(context).login_need_login,
    );
    if (!mounted) return;
    if (flag != null && flag) {
      await Navigator.pushNamed(context, '/LoginPage');
      if (!mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool anyEnabled = showWalletPassword ||
        securityMap['face'] == true ||
        securityMap['email'] == true ||
        securityMap['google'] == true;

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
                child: _buildBottomBar(anyEnabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
