part of 'security_google_vedification.dart';

({int nextCount, bool keepWaiting}) advanceSecurityEmailCountdown(int current) {
  if (current <= 1) {
    return (nextCount: 60, keepWaiting: false);
  }
  return (nextCount: current - 1, keepWaiting: true);
}

/// Business logic mixin for SecurityGoogleVedification page.
///
/// Contains controllers, state variables, verification methods,
/// security settings load/save, and timer management.
mixin _SecurityGoogleVedificationLogic on State<SecurityGoogleVedification> {
  static final RegExp _totpCodeRegExp = RegExp(r'^\d{6}$');

  final TextEditingController pwdTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController googleTextEditingController =
      TextEditingController();

  bool obscure = true;
  String pwdErrorMessage = "";
  String emailErrorMessage = "";
  String googleErrorMessage = "";

  int emailSendWaitNum = 60;
  bool emailSendWait = false;
  Load load = Load.finish;
  Load emailLoad = Load.finish;
  Load googleLoad = Load.finish;
  Timer? _emailCountdownTimer;

  String walletName = "";

  Map<String, dynamic> securityMap = {
    "email": false,
    "google": false,
    "face": false,
  };

  @override
  void initState() {
    super.initState();
    _loadWalletName();
    _loadSecuritySettings();
  }

  Future<void> _loadWalletName() async {
    final walletService = ServiceLocatorSetup.walletService;
    if (walletService == null) {
      walletName = '${S.current.g_key_6} ';
      if (!mounted) return;
      setState(() {});
      return;
    }
    final mainWallet = walletService.getMainWallet();
    walletName = '${S.current.g_key_6} ${mainWallet?.name ?? ""}';
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadSecuritySettings() async {
    Map<String, dynamic>? s = await SPUtil().getSecurity();
    if (!mounted) return;
    if (s != null) {
      Map<String, dynamic>? userSecurityMap =
          s[AppGlobals.userInfo?.uuid ?? ""];
      if (userSecurityMap != null) {
        setState(() {
          securityMap['email'] = userSecurityMap['email'];
          securityMap['google'] = userSecurityMap['google'];
          securityMap['face'] = userSecurityMap['face'] ?? false;
        });
      }
    }
  }

  Future<void> getEmailVerification() async {
    if (emailLoad == Load.loading || emailSendWait) return;
    setState(() {
      emailLoad = Load.loading;
      emailSendWait = true;
    });
    ToastUtils.show(S.of(context).email_code_finish);
    _startEmailCountdown();
    if (mounted) setState(() => emailLoad = Load.finish);
  }

  void _startEmailCountdown() {
    _emailCountdownTimer?.cancel();
    _emailCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final nextState = advanceSecurityEmailCountdown(emailSendWaitNum);
      setState(() {
        emailSendWaitNum = nextState.nextCount;
        emailSendWait = nextState.keepWaiting;
      });

      if (!nextState.keepWaiting) {
        timer.cancel();
        _emailCountdownTimer = null;
      }
    });
  }

  Future<bool> checkPwd() async {
    final pwdStr = pwdTextEditingController.text;
    if (pwdStr.isEmpty) {
      setState(() {
        pwdErrorMessage = S.of(context).g_key_t_33;
      });
      return false;
    }

    final walletAll = await SPUtil().getWalletInfo();
    if (!mounted) return false;
    WalletInfo? walletInfo;

    if (walletAll != null) {
      final userUUID = AppGlobals.userInfo?.uuid ?? "";
      final walletUser = walletAll[userUUID] as Map<String, dynamic>?;
      if (walletUser != null) {
        final walletInfos = walletUser["wallet"] as List<dynamic>? ?? [];
        final walletList = walletInfos
            .map((e) => WalletInfo.fromJson(e as Map<String, dynamic>))
            .toList();

        final mainIndex = walletList.indexWhere((e) => e.mainWallet == true);
        if (mainIndex != -1) {
          walletInfo = walletList[mainIndex];
        } else if (walletList.isNotEmpty) {
          walletInfo = walletList.first;
        }
      }
    }

    final oldPwdStr = walletInfo?.password ?? "";
    if (oldPwdStr != pwdStr) {
      setState(() {
        pwdErrorMessage = S.of(context).g_key_t_34;
      });
      return false;
    }
    setState(() {
      pwdErrorMessage = "";
    });
    return true;
  }

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
    setState(() => emailErrorMessage = "");
    return true;
  }

  Future<bool> checkGoogleVerification() async {
    final codeStr = googleTextEditingController.text.trim();
    if (codeStr.isEmpty) {
      setState(() => googleErrorMessage = S.of(context).rest_Please_enter);
      return false;
    }
    if (codeStr.length != 6 || !_totpCodeRegExp.hasMatch(codeStr)) {
      setState(() => googleErrorMessage = S.of(context).g_2fa_invalid_format);
      return false;
    }
    if (AppGlobals.userInfo!.bindGoogleAuthState == false) {
      AppGlobals.userInfo!.bindGoogleAuthState = true;
      await SPUtil().saveUserInfo(AppGlobals.userInfo!);
      if (!mounted) return false;
    }
    setState(() => googleErrorMessage = "");
    return true;
  }

  Future<void> _saveSecurity() async {
    final spUtils = SPUtil();
    Map<String, dynamic>? s = await spUtils.getSecurity();
    s ??= {};
    s[AppGlobals.userInfo?.uuid ?? ""] = securityMap;
    await spUtils.setSecurity(s);
    if (!mounted) return;
    setState(() {});
  }

  void closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// Handle submit button press - validate all fields and save.
  Future<void> _handleSubmit() async {
    if (load == Load.loading) return;
    bool completedWithExit = false;
    setState(() {
      load = Load.loading;
    });

    try {
      bool rValue = await checkPwd();
      if (!mounted) return;
      if (!rValue) {
        return;
      }

      if (securityMap['email']) {
        rValue = await checkEmailVerification();
        if (!mounted) return;
        if (!rValue) {
          return;
        }
      }

      if (securityMap['google'] == false) {
        rValue = await checkGoogleVerification();
        if (!mounted) return;
        if (!rValue) {
          return;
        }
      }

      securityMap['google'] = true;
      await _saveSecurity();
      if (!mounted) return;
      setState(() {
        load = Load.finish;
      });
      completedWithExit = true;
      Navigator.popUntil(context, ModalRoute.withName('/securitySetting'));
    } catch (e) {
      if (mounted) {
        ToastUtils.show(e.toString());
      }
    } finally {
      if (mounted && !completedWithExit) {
        setState(() {
          load = Load.finish;
        });
      }
    }
  }

  void toggleObscure() {
    setState(() {
      obscure = !obscure;
    });
  }

  void pasteGoogleCode(String text) {
    googleTextEditingController.text = text;
    setState(() {});
  }

  @override
  void dispose() {
    _emailCountdownTimer?.cancel();
    pwdTextEditingController.dispose();
    emailTextEditingController.dispose();
    googleTextEditingController.dispose();
    super.dispose();
  }
}
