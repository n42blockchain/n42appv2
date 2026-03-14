// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/home/setting/change_email_page.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/generated/l10n.dart';

mixin ChangeEmailPageLogicMixin on State<ChangeEmailPage> {
  int step = 0;
  bool chatAvailable = false;
  bool chatSyncEnabled = true;
  StreamSubscription? chatUserSubscription;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final n42CodeCtrl = TextEditingController();
  final chatCodeCtrl = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final n42CodeFocus = FocusNode();
  final chatCodeFocus = FocusNode();
  bool obscurePassword = true;

  bool sendingN42Code = false;
  bool confirmingN42 = false;
  bool requestingChatCode = false;
  bool confirmingChat = false;

  bool chatCodeSent = false;

  String? emailError;
  String? passwordError;
  String? n42CodeError;
  String? chatSyncError;

  int countdown = 0;
  Timer? countdownTimer;

  void initLogic() {
    _syncChatAvailability();
    chatUserSubscription = N42Chat.userStream.listen((_) {
      if (!mounted) return;
      _syncChatAvailability(fromStream: true);
    });
  }

  void disposeLogic() {
    countdownTimer?.cancel();
    chatUserSubscription?.cancel();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    n42CodeCtrl.dispose();
    chatCodeCtrl.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    n42CodeFocus.dispose();
    chatCodeFocus.dispose();
  }

  void _syncChatAvailability({bool fromStream = false}) {
    final nextChatAvailable = N42Chat.isInitialized && N42Chat.isLoggedIn;
    if (nextChatAvailable == chatAvailable && !fromStream) {
      return;
    }

    if (!mounted) {
      chatAvailable = nextChatAvailable;
      chatSyncEnabled = nextChatAvailable;
      return;
    }

    setState(() {
      final becameAvailable = nextChatAvailable && !chatAvailable;
      chatAvailable = nextChatAvailable;
      if (!nextChatAvailable) {
        chatSyncEnabled = false;
        passwordError = null;
        chatSyncError = null;
      } else if (becameAvailable && step == 0) {
        chatSyncEnabled = true;
      }
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  bool isValidEmail(String v) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$').hasMatch(v.trim());

  void startCountdown() {
    countdown = 60;
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        t.cancel();
      }
    });
  }

  // ─── Step 0 → 1: 发送 N42 验证码 ────────────────────────────────────────────

  Future<void> sendN42Code() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => emailError = S.of(context).g_email_error_empty);
      return;
    }
    if (!isValidEmail(email)) {
      setState(() => emailError = S.of(context).g_email_error_invalid);
      return;
    }
    if (email == (AppGlobals.userInfo?.email ?? '')) {
      setState(() => emailError = S.of(context).g_email_error_same);
      return;
    }
    if (chatSyncEnabled && chatAvailable && passwordCtrl.text.isEmpty) {
      setState(() => passwordError = S.of(context).g_email_pwd_required);
      return;
    }

    setState(() {
      emailError = null;
      passwordError = null;
      sendingN42Code = true;
    });

    try {
      final data =
          await UserInfoApi().sendEmailCode(email, 'changeEmail');
      if (!mounted) return;
      if (data['code'] == 200) {
        startCountdown();
        setState(() => step = 1);
        ToastUtils.show(S.of(context).g_email_code_sent_to(email));
      } else {
        ToastUtils.show(
            (data['err'] ?? data['msg'] ?? 'Failed to send code').toString());
      }
    } catch (e) {
      if (mounted) ToastUtils.show(e.toString());
    } finally {
      if (mounted) setState(() => sendingN42Code = false);
    }
  }

  Future<void> resendN42Code() async {
    if (countdown > 0 || sendingN42Code) return;
    setState(() => sendingN42Code = true);
    try {
      final data = await UserInfoApi()
          .sendEmailCode(emailCtrl.text.trim(), 'changeEmail');
      if (!mounted) return;
      if (data['code'] == 200) {
        startCountdown();
        ToastUtils.show(S.of(context).g_email_code_resent);
      } else {
        ToastUtils.show((data['err'] ?? 'Failed to resend').toString());
      }
    } catch (e) {
      if (mounted) ToastUtils.show(e.toString());
    } finally {
      if (mounted) setState(() => sendingN42Code = false);
    }
  }

  // ─── Step 1: 确认 N42 邮箱修改 ──────────────────────────────────────────────

  Future<void> confirmN42() async {
    final code = n42CodeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => n42CodeError = S.of(context).g_email_code_invalid);
      return;
    }

    setState(() {
      n42CodeError = null;
      confirmingN42 = true;
    });

    try {
      final result =
          await UserInfoApi().changeEmail(emailCtrl.text.trim(), code);
      if (!mounted) return;
      if (result.error == false) {
        AppGlobals.userInfo?.email = emailCtrl.text.trim();
        countdownTimer?.cancel();

        if (chatSyncEnabled && chatAvailable) {
          // 进入 Step 2：自动请求 Chat 验证码
          setState(() => step = 2);
          await requestChatCode();
        } else {
          ToastUtils.showSuccess(S.of(context).g_email_success);
          Navigator.pop(context, true);
        }
      } else {
        setState(() => n42CodeError =
            result.data?.toString() ?? S.of(context).g_email_code_wrong);
      }
    } catch (e) {
      if (mounted) setState(() => n42CodeError = e.toString());
    } finally {
      if (mounted) setState(() => confirmingN42 = false);
    }
  }

  // ─── Step 2: Chat 同步 ───────────────────────────────────────────────────────

  Future<void> requestChatCode() async {
    setState(() {
      requestingChatCode = true;
      chatSyncError = null;
      chatCodeSent = false;
      chatCodeCtrl.clear();
    });
    try {
      await N42Chat.requestChatEmailChange(
        passwordCtrl.text,
        emailCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        chatCodeSent = true;
        requestingChatCode = false;
      });
      startCountdown();
    } catch (e) {
      if (mounted) {
        setState(() {
          chatSyncError = e.toString();
          requestingChatCode = false;
        });
      }
    }
  }

  Future<void> resendChatCode() async {
    if (countdown > 0 || requestingChatCode) return;
    await requestChatCode();
  }

  Future<void> confirmChat() async {
    final code = chatCodeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => chatSyncError = S.of(context).g_email_code_invalid);
      return;
    }

    setState(() {
      chatSyncError = null;
      confirmingChat = true;
    });

    try {
      await N42Chat.confirmChatEmailChange(
        emailCtrl.text.trim(),
        code,
      );
      if (!mounted) return;
      ToastUtils.showSuccess(S.of(context).g_email_both_success);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          chatSyncError = e.toString();
          confirmingChat = false;
        });
      }
    }
  }

  /// 跳过 Chat 同步：N42 邮箱已更新，Chat 留给用户稍后手动处理
  void skipChatSync() {
    ToastUtils.show(S.of(context).g_email_n42_only);
    Navigator.pop(context, true);
  }
}
