import 'dart:async';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/home/widgets/face_recognition_public.dart';
import 'package:n42_wallet/features/home/widgets/gesture_password/gesture_password.dart';
import 'package:n42_wallet/features/login/pages/login_page.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'unlock_ui.dart';

/// Unlock Page - Migrated to Riverpod
///
/// Uses ConsumerStatefulWidget for:
/// - Screen lock state management via screenLockProvider
/// - Biometric and password verification
class Unlock extends ConsumerStatefulWidget {
  const Unlock({super.key});
  @override
  ConsumerState<Unlock> createState() => _UnlockState();
}

class _UnlockState extends ConsumerState<Unlock> {
  String inputPassword = "";
  bool check = false;
  bool obscure = true;

  final TapGestureRecognizer _loginTapRecognizer = TapGestureRecognizer();

  bool faceShow = false;
  bool gestureShow = false;
  bool passwordShow = false;
  int gestureErrorCount = 0;
  int passwordErrorCount = 0;
  int passwordUnlock = 60;
  Timer? passwordTimer;

  /// True when device passed [checkBiometrics] — we can offer a retry.
  bool _biometricAvailable = false;
  /// True when the last biometric attempt failed or was cancelled by user.
  bool _biometricFailed = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    faceShow = false;
    gestureShow = false;
    passwordShow = false;
    gestureErrorCount = 0;
    passwordErrorCount = 0;
    passwordUnlock = 60;

    final lockState = ref.read(screenLockProvider);
    final dOld = lockState.passwordLockTimestamp;

    if (dOld != 0) {
      int dNow = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final elapsed = dNow - dOld;
      if (elapsed < 60) {
        setState(() {
          passwordUnlock = 60 - elapsed;
        });
        passwordLock(setData: false);
        return;
      }
      ref.read(screenLockProvider.notifier).setPasswordLockTimestamp(0);
    }

    if (lockState.faceEnabled) {
      initFace();
    } else {
      faceShow = true;
    }

    if (!lockState.gestureEnabled) {
      gestureShow = true;
    }

    if (!lockState.isLocked) {
      passwordShow = true;
    }
  }

  Future<void> initFace() async {
    final lockState = ref.read(screenLockProvider);
    if (!lockState.faceEnabled) {
      setState(() => faceShow = true);
      return;
    }

    final frp = FaceRecognitionPublic();
    final canAuth = await frp.checkBiometrics();
    if (!mounted) return;

    if (!canAuth) {
      ToastUtils.show(S.of(context).g_lock_key7);
      setState(() {
        _biometricAvailable = false;
        faceShow = true;
      });
      return;
    }

    setState(() => _biometricAvailable = true);

    final result = await frp.authenticateWithBiometrics();
    if (!mounted) return;

    _handleBiometricResult(result);
  }

  /// Retry biometric auth without resetting to the loading state.
  Future<void> _retryBiometric() async {
    setState(() => _biometricFailed = false);

    final frp = FaceRecognitionPublic();
    final result = await frp.authenticateWithBiometrics();
    if (!mounted) return;

    _handleBiometricResult(result);
  }

  /// Handle biometric auth result (shared by initFace and _retryBiometric).
  void _handleBiometricResult(BiometricAuthResult result) {
    if (result == BiometricAuthResult.success) {
      check = true;
      back();
      return;
    }

    switch (result) {
      case BiometricAuthResult.userCancelled:
        setState(() {
          _biometricFailed = true;
          faceShow = true;
        });
      case BiometricAuthResult.notEnrolled:
        ToastUtils.show(S.of(context).g_biometric_not_enrolled);
        setState(() {
          _biometricAvailable = false;
          faceShow = true;
        });
      case BiometricAuthResult.lockedOut:
        ToastUtils.show(S.of(context).g_biometric_locked_out);
        setState(() {
          _biometricFailed = true;
          faceShow = true;
        });
      case BiometricAuthResult.notAvailable:
        ToastUtils.show(S.of(context).g_lock_key7);
        setState(() {
          _biometricAvailable = false;
          faceShow = true;
        });
      default:
        ToastUtils.show(S.of(context).g_unlock_key7);
        setState(() {
          _biometricFailed = true;
          faceShow = true;
        });
    }
  }

  Widget buildBiometricRetryButton() {
    return Container(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: _retryBiometric,
        icon: Icon(
          Icons.fingerprint,
          size: ScreenUtil().setWidth(40.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
        label: Text(
          S.of(context).g_biometric_retry,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            fontSize: ScreenUtil().setSp(26.0),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordTimer?.cancel();
    passwordTimer = null;
    _loginTapRecognizer.dispose();
    super.dispose();
  }

  void back() {
    Navigator.pop(context, true);
  }

  bool checkPwd() {
    final pwdStr = inputPassword;
    final lockState = ref.read(screenLockProvider);

    if (!lockState.verifyPassword(pwdStr)) {
      setState(() {
        passwordErrorCount++;
        inputPassword = "";
      });
      if (passwordErrorCount >= 3) {
        setState(() {
          passwordShow = true;
        });
        passwordLock();
      }
      return false;
    }

    check = true;
    back();
    return true;
  }

  Future<void> passwordLock({bool setData = true}) async {
    if (setData) {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await ref.read(screenLockProvider.notifier).setPasswordLockTimestamp(timestamp);
    }

    passwordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (passwordUnlock > 1) {
        setState(() => passwordUnlock--);
      } else {
        timer.cancel();
        initData();
        setState(() {});
      }
    });
  }

  Future<bool> _pageBack() {
    if (check) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        SystemNavigator.pop();
      }
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return buildUnlockWidget();
  }

  List<int> stringToIntArray(String answer) {
    return answer.split(',').map((value) => int.parse(value)).toList();
  }
}
