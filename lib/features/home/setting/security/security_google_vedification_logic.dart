part of 'security_google_vedification.dart';

/// Business logic mixin for SecurityGoogleVedification page.
///
/// Contains controllers, state variables, verification methods,
/// security settings load/save, and timer management.
mixin _SecurityGoogleVedificationLogic
    on State<SecurityGoogleVedification> {
  final TextEditingController pwdTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController googleTextEditingController = TextEditingController();

  bool obscure = true;
  String pwdErrorMessage = "";
  String emailErrorMessage = "";
  String googleErrorMessage = "";

  int emailSendWaitNum = 60;
  bool emailSendWait = false;
  Load load = Load.finish;
  Load emailLoad = Load.finish;
  Load googleLoad = Load.finish;

  String walletName = "";

  //账号安全
  Map<String, dynamic> securityMap = {
    "email": false,
    "google": false,
    "face": false,
  };

  UserInfoApi? _userInfoAPI;
  UserInfoApi get userInfoAPI {
    _userInfoAPI ??= UserInfoApi();
    return _userInfoAPI!;
  }

  @override
  void initState() {
    super.initState();
    _loadWalletName();
    _loadSecuritySettings();
  }

  // 加载钱包名 - 使用 IWalletService 替代 WalletActionProvider
  Future<void> _loadWalletName() async {
    final walletService = ServiceLocatorSetup.walletService;
    if (walletService == null) {
      walletName = '${S.current.g_key_6} ';
      setState(() {});
      return;
    }
    final mainWallet = walletService.getMainWallet();
    walletName = '${S.current.g_key_6} ${mainWallet?.name ?? ""}';
    setState(() {});
  }

  //加载安全设置
  Future<void> _loadSecuritySettings() async {
    Map<String, dynamic>? s = await SPUtil().getSecurity();
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

  //获取邮箱验证码
  Future<void> getEmailVerification() async {
    if (emailLoad == Load.loading) return;
    if (emailSendWait) return;
    setState(() {
      emailLoad = Load.loading;
    });
    MessageModel mm = await userInfoAPI.getEmailVerification();
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

  //开启emailsendwait倒计时
  void _startEmailCountdown() {
    Timer(Duration(seconds: 1), () {
      setState(() {
        emailSendWaitNum--;
      });
      debugPrint('$emailSendWaitNum');
      if (emailSendWaitNum <= 0) {
        emailSendWaitNum = 60;
        emailSendWait = false;
      } else {
        _startEmailCountdown();
      }
    });
  }

  // 验证密码 - 使用 SPUtil 直接读取钱包信息验证密码
  Future<bool> checkPwd() async {
    String pwdStr = pwdTextEditingController.text;
    if (pwdStr == "") {
      setState(() {
        pwdErrorMessage = S.of(context).g_key_t_33;
      });
      return false;
    }

    // 从 SPUtil 获取钱包列表进行密码验证
    Map<String, dynamic>? walletAll = await SPUtil().getWalletInfo();
    WalletInfo? walletInfo;

    if (walletAll != null) {
      String userUUID = AppGlobals.userInfo?.uuid ?? "";
      Map<String, dynamic>? walletUser = walletAll[userUUID];
      if (walletUser != null) {
        List<dynamic> walletInfos = walletUser["wallet"] ?? [];
        List<WalletInfo> walletList = walletInfos
            .map((e) => WalletInfo.fromJson(e as Map<String, dynamic>))
            .toList();

        // 查找主钱包
        int mainIndex = walletList.indexWhere((e) => e.mainWallet == true);
        if (mainIndex != -1) {
          walletInfo = walletList[mainIndex];
        } else if (walletList.isNotEmpty) {
          walletInfo = walletList.first;
        }
      }
    }

    String oldPwdStr = walletInfo?.password ?? "";
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

  //验证邮箱验证码
  Future<bool> checkEmailVerification() async {
    String codeStr = emailTextEditingController.text;
    if (codeStr == "") {
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
    MessageModel mm = await userInfoAPI.checkEmailVerification(codeStr);
    if (mm.error) {
      setState(() {
        emailErrorMessage = S.of(context).email_code_input_error;
      });
      return false;
    } else {
      setState(() {
        emailErrorMessage = "";
      });
      return true;
    }
  }

  //谷歌验证
  Future<bool> checkGoogleVerification() async {
    String codeStr = googleTextEditingController.text.trim();
    if (codeStr == "") {
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
    MessageModel mm = await userInfoAPI.checkGoogle(codeStr);
    if (mm.error) {
      setState(() {
        googleErrorMessage = S.of(context).email_code_input_error;
      });
      return false;
    } else {
      if (AppGlobals.userInfo!.bindGoogleAuthState == false) {
        AppGlobals.userInfo!.bindGoogleAuthState = true;
        await SPUtil().saveUserInfo(AppGlobals.userInfo!);
      }
      setState(() {
        googleErrorMessage = "";
      });
      return true;
    }
  }

  //保存设置
  Future<void> _saveSecurity() async {
    SPUtil sPUtils = SPUtil();
    Map<String, dynamic>? s = await sPUtils.getSecurity();
    s ??= {};
    s[AppGlobals.userInfo?.uuid ?? ""] = securityMap;
    await sPUtils.setSecurity(s);
    setState(() {});
  }

  //关闭键盘
  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Handle submit button press - validate all fields and save.
  Future<void> _handleSubmit() async {
    if (load == Load.loading) return;
    setState(() {
      load = Load.loading;
    });

    bool rValue = await checkPwd();
    if (!rValue) {
      setState(() { load = Load.finish; });
      return;
    }

    if (securityMap['email']) {
      rValue = await checkEmailVerification();
      if (!rValue) {
        setState(() { load = Load.finish; });
        return;
      }
    }

    if (securityMap['google'] == false) {
      rValue = await checkGoogleVerification();
      if (!rValue) {
        setState(() { load = Load.finish; });
        return;
      }
    }

    securityMap['google'] = true;
    _saveSecurity();
    setState(() {
      load = Load.finish;
    });
    if (!context.mounted) return;
    Navigator.popUntil(context, ModalRoute.withName('/securitySetting'));
  }

  void toggleObscure() {
    setState(() { obscure = !obscure; });
  }

  void pasteGoogleCode(String text) {
    googleTextEditingController.text = text;
    setState(() {});
  }
}
