import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:local_auth_android/local_auth_android.dart' as authAndroid;
import 'package:local_auth_darwin/local_auth_darwin.dart' as authIos;
class FaceRecognitionPublic{
  final LocalAuthentication auth = LocalAuthentication();
  //_SupportState _supportState = _SupportState.unknown;

  //检查生物特征是否可用
  Future<bool> checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
    }
    /*if (!mounted) {
      return;
    }*/
    if(canCheckBiometrics){
      final List<BiometricType> availableBiometrics =
      await auth.getAvailableBiometrics();

      if (availableBiometrics.length==0) {
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
    if(canCheckBiometrics){
      return true;
    }else{
      return false;
    }
  }

  //人体特征验证
  Future<bool> authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      var authMessage;
      if(Platform.isIOS){
        authMessage=authIos.IOSAuthMessages(
          lockOut: S.current.g_face_9,
          goToSettingsButton: S.current.g_face_5,
          goToSettingsDescription: S.current.g_face_6,
          cancelButton: S.current.g_key_79,
          localizedFallbackTitle: S.current.g_face_8,
        );
      }else{
        authMessage=authAndroid.AndroidAuthMessages(
          biometricHint: S.current.g_face_1,
          biometricNotRecognized: S.current.g_face_2,
          biometricRequiredTitle: S.current.g_face_3,
          biometricSuccess: S.current.g_face_4,
          cancelButton: S.current.g_key_79,
          goToSettingsButton: S.current.g_face_5,
          goToSettingsDescription: S.current.g_face_6,
          signInTitle: S.current.g_face_7,
        );
      }
      authenticated = await auth.authenticate(
          localizedReason:
          S.current.g_face_10,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
          authMessages: [
            authMessage
          ]
      );
    } on PlatformException catch (e) {
      return false;
    }
    /*if (!mounted) {
      return;
    }*/
    if(authenticated){
      return true;
    }else{
      return false;
    }
  }
}
/*enum _SupportState {
  unknown,
  supported,
  unsupported,
}*/