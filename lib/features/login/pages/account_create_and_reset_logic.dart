part of 'account_create_and_reset.dart';

/// Business logic mixin for AccountCreateAndReset page.
///
/// Contains controllers, state variables, timer management,
/// API calls, and form validation.
mixin _AccountCreateAndResetLogic on ConsumerState<AccountCreateAndReset> {
  final TextEditingController _unameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();
  final TextEditingController _uPasswordController = TextEditingController();
  final TextEditingController _uPasswordConfirmController =
      TextEditingController();
  final TextEditingController _uCodeController = TextEditingController();
  final FocusNode _unameFocusNode = FocusNode();
  final FocusNode _inviteCodeFocusNode = FocusNode();
  final FocusNode _uPasswordFocusNode = FocusNode();
  final FocusNode _uPasswordConfirmFocusNode = FocusNode();
  final FocusNode _uCodeFocusNode = FocusNode();

  String unameErrorMessage = "";
  String uPasswordErrorMessage = "";
  String uPasswordConfirmErrorMessage = "";
  String uCodeErrorMessage = "";
  bool showPwd1 = true;
  bool showPwd2 = true;

  Timer? _timer;
  int _countdown = 61;
  Load codeLoad = Load.finish;
  Load sendLoad = Load.finish;
  late HandType _currentType;

  late final UserInfoApi userInfoApi = UserInfoApi();

  @override
  void initState() {
    super.initState();
    _currentType = widget.type;
    _loadSavedEmail();
    _loadInviterEmail();
  }

  @override
  void dispose() {
    _unameController.dispose();
    _inviteCodeController.dispose();
    _uPasswordController.dispose();
    _uPasswordConfirmController.dispose();
    _uCodeController.dispose();
    _unameFocusNode.dispose();
    _inviteCodeFocusNode.dispose();
    _uPasswordFocusNode.dispose();
    _uPasswordConfirmFocusNode.dispose();
    _uCodeFocusNode.dispose();
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  /// Load previously saved user email into the email field.
  Future<void> _loadSavedEmail() async {
    final data = await SPUtil().getUserInfo();
    if (!mounted) return;
    if (data != null) {
      UserInfo info = UserInfo.fromJson(data);
      _unameController.text = info.email ?? "";
      setState(() {});
    }
  }

  /// Fetch inviter code from device info and populate invite code field.
  Future<void> _loadInviterEmail() async {
    DeviceInfoUtil deviceInfoUtil = DeviceInfoUtil();
    Map<String, dynamic>? infoMap = await deviceInfoUtil.getDeviceInfo();
    if (!mounted) return;
    if (infoMap != null) {
      UserInfoApi loginApi = UserInfoApi();
      String? email = await loginApi.getInviterCode(
        infoMap["mobileModel"],
        infoMap["mobileName"],
        infoMap["os"],
      );
      if (!mounted) return;
      if (email != null) {
        _inviteCodeController.text = email;
        setState(() {});
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        _countdown--;
      } else {
        _countdown = 61;
        timer.cancel();
      }
      setState(() {});
    });
  }

  void sendEmailCode(String email, String type) async {
    try {
      setState(() {
        codeLoad = Load.loading;
      });
      final data = await userInfoApi.sendEmailCode(email, type);
      if (!mounted) return;
      if (data["code"] == 200) {
        setState(() => _countdown -= 1);
        _startTimer();
        ToastUtils.show(S.of(context).login_message_7);
      } else if (data["code"] == -1402) {
        ToastUtils.show(S.of(context).login_message_8);
      } else {
        ToastUtils.show(S.of(context).login_message_9);
      }
    } finally {
      if (mounted) {
        setState(() {
          codeLoad = Load.finish;
        });
      }
    }
  }

  Future<bool> login(String email, String password) async {
    final data = await userInfoApi.login(
      email,
      Md5Util().generateMd5(password),
    );
    if (!mounted) return false;
    if (data != null) {
      if (data["code"] == 200) {
        UserInfo userInfo = UserInfo.fromJson(data['data']);
        await SPUtil().saveUserInfo(userInfo);
        if (!mounted) return false;
        await AppGlobals.login(userInfo);
        return true;
      } else if (data["code"] == -403) {
        ToastUtils.showFtToast(title: S.of(context).code_403);
        return false;
      } else {
        ToastUtils.showFtToast(title: data["err"]);
        return false;
      }
    }
    return false;
  }

  /// Validate all form fields and submit create/reset request.
  Future<void> _handleSubmit() async {
    final email = _unameController.value.text.trim();
    final password = _uPasswordController.value.text.trim();
    final confirmPassword = _uPasswordConfirmController.value.text.trim();
    final Regular regular = Regular();

    // Validate email
    if (email.isEmpty) {
      setState(() {
        unameErrorMessage = S.of(context).please_enter_email;
      });
      ToastUtils.show(S.of(context).please_enter_email);
      return;
    }
    if (!regular.isEmail(email)) {
      setState(() {
        unameErrorMessage = S.of(context).email_error;
      });
      ToastUtils.show(S.of(context).email_error);
      return;
    }
    unameErrorMessage = "";

    // Validate password
    if (password.isEmpty) {
      setState(() {
        uPasswordErrorMessage = S.of(context).please_enter_password;
      });
      ToastUtils.show(S.of(context).please_enter_password);
      return;
    }
    if (!regular.isPassword(password)) {
      setState(() {
        uPasswordErrorMessage = S.of(context).rest_Choose_password;
      });
      ToastUtils.show(S.of(context).rest_Choose_password);
      return;
    }
    uPasswordErrorMessage = "";

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      setState(() {
        uPasswordConfirmErrorMessage = S.of(context).please_enter_password;
      });
      ToastUtils.show(S.of(context).please_enter_password);
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        uPasswordConfirmErrorMessage = S.of(context).password_diff;
      });
      ToastUtils.show(S.of(context).password_diff);
      return;
    }
    uPasswordConfirmErrorMessage = "";

    // Validate verification code
    final code = _uCodeController.value.text.trim();
    if (code.isEmpty) {
      setState(() {
        uCodeErrorMessage = S.of(context).please_enter_code;
      });
      ToastUtils.show(S.of(context).please_enter_code);
      return;
    }
    if (_currentType == HandType.createAccount) {
      if (!regular.isCaptcha(code)) {
        setState(() {
          uCodeErrorMessage = S.of(context).code_err_tips;
        });
        ToastUtils.show(S.of(context).code_err_tips);
        return;
      }
    } else {
      if (!regular.isCaptcha2(code)) {
        setState(() {
          uCodeErrorMessage = S.of(context).code_err_tips;
        });
        ToastUtils.show(S.of(context).code_err_tips);
        return;
      }
    }
    uCodeErrorMessage = "";
    setState(() {});

    final inviteCode = _inviteCodeController.text.trim();
    try {
      setState(() {
        sendLoad = Load.loading;
      });
      if (_currentType == HandType.createAccount) {
        await _submitCreateAccount(email, password, code, inviteCode);
      } else {
        await _submitResetPassword(email, password, code);
      }
    } catch (err) {
      ToastUtils.show(err.toString());
    } finally {
      if (mounted) {
        setState(() {
          sendLoad = Load.finish;
        });
      }
    }
  }

  Future<void> _submitCreateAccount(
    String email,
    String password,
    String code,
    String inviteCode,
  ) async {
    final data = await userInfoApi.registerEmail(
      email,
      Md5Util().generateMd5(password),
      code,
      inviteCode: inviteCode,
    );
    if (!mounted) return;
    if (data["code"] == 200) {
      ToastUtils.show(S.of(context).login_message_10);
      bool rData = await login(email, password);
      if (!mounted) return;
      if (rData && widget.pushType == 0) {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context);
      }
    } else {
      ToastUtils.show(data["err"]);
    }
  }

  Future<void> _submitResetPassword(
    String email,
    String password,
    String code,
  ) async {
    final data = await userInfoApi.emailResetPwd(
      email,
      Md5Util().generateMd5(password),
      code,
    );
    if (!mounted) return;
    if (data["code"] == 200) {
      ToastUtils.show(S.of(context).login_message_11);
      bool rData = await login(email, password);
      if (!mounted) return;
      if (rData && widget.pushType == 0) {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context);
      }
    } else {
      ToastUtils.show(data["err"]);
    }
  }

  void toggleShowPwd1() {
    setState(() {
      showPwd1 = !showPwd1;
    });
  }

  void toggleShowPwd2() {
    setState(() {
      showPwd2 = !showPwd2;
    });
  }

  void switchToResetPassword() {
    setState(() {
      _currentType = HandType.restPassword;
    });
  }

  /// Validate email and request verification code.
  void _requestVerificationCode() {
    if (_countdown != 61) return;
    final email = _unameController.value.text.trim();
    if (email.isEmpty) {
      setState(() {
        unameErrorMessage = S.of(context).please_enter_email;
      });
      ToastUtils.show(S.of(context).please_enter_email);
      return;
    }
    Regular regular = Regular();
    if (!regular.isEmail(email)) {
      setState(() {
        unameErrorMessage = S.of(context).email_error;
      });
      ToastUtils.show(S.of(context).email_error);
      return;
    }
    unameErrorMessage = "";
    sendEmailCode(
      email,
      _currentType == HandType.restPassword ? "resetPwd" : "register",
    );
  }
}
