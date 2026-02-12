import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:local_auth_android/local_auth_android.dart' as auth_android;
import 'package:local_auth_darwin/local_auth_darwin.dart' as auth_ios;

class FaceRecognitionPublic{
  final LocalAuthentication auth = LocalAuthentication();
  //_SupportState _supportState = _SupportState.unknown;

  /// 检查生物特征是否可用
  Future<bool> checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      canCheckBiometrics = false;
    }
    if(canCheckBiometrics){
      final List<BiometricType> availableBiometrics =
      await auth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        canCheckBiometrics=false;
      }
      if(availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak) ||
          availableBiometrics.contains(BiometricType.fingerprint)){
        canCheckBiometrics=true;
      }else{
        canCheckBiometrics=false;
      }
    }
    return canCheckBiometrics;
  }

  /// 人体特征验证
  Future<bool> authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      dynamic authMessage;
      if(Platform.isIOS){
        // local_auth 3.0.0: IOSAuthMessages 仅支持 cancelButton 和 localizedFallbackTitle
        authMessage=auth_ios.IOSAuthMessages(
          cancelButton: S.current.g_key_79,
          localizedFallbackTitle: S.current.g_face_8,
        );
      }else{
        // local_auth 3.0.0: AndroidAuthMessages 仅支持 signInHint, cancelButton, signInTitle
        authMessage=auth_android.AndroidAuthMessages(
          signInHint: S.current.g_face_1,
          cancelButton: S.current.g_key_79,
          signInTitle: S.current.g_face_7,
        );
      }
      // local_auth 3.0.0 API 变更
      authenticated = await auth.authenticate(
          localizedReason:
          S.current.g_face_10,
          biometricOnly: true,
          persistAcrossBackgrounding: true,
          authMessages: [
            authMessage
          ]
      );
    } on PlatformException catch (_) {
      return false;
    }
    return authenticated;
  }
}