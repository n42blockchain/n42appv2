// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:local_auth_android/local_auth_android.dart' as auth_android;
import 'package:local_auth_darwin/local_auth_darwin.dart' as auth_ios;

/// Detailed result of a biometric authentication attempt.
///
/// Callers should use this instead of a plain `bool` to give users
/// meaningful, localised feedback.
enum BiometricAuthResult {
  /// Authentication succeeded.
  success,

  /// User explicitly dismissed the prompt (Cancel button / Home button).
  /// No error toast should be shown.
  userCancelled,

  /// Device has biometric hardware but the user has not enrolled any
  /// credential (fingerprint/face).  Direct user to system Settings.
  notEnrolled,

  /// Too many consecutive failures — the OS has temporarily or permanently
  /// locked biometric authentication.
  lockedOut,

  /// Biometric hardware absent, disabled by MDM, or OS otherwise reports
  /// it is unavailable.
  notAvailable,

  /// Auth was attempted but the biometric did not match.
  failed,
}

/// Singleton-style helper for local biometric authentication.
///
/// Wraps [LocalAuthentication] with:
/// - Device-support guard (`isDeviceSupported` + `canCheckBiometrics`)
/// - Enrolled-biometrics check (rejects empty or weak-only credential sets)
/// - Per-error-code [PlatformException] mapping for Android and iOS
/// - Platform-specific dialog messages
class FaceRecognitionPublic {
  final LocalAuthentication auth = LocalAuthentication();

  // ────────────────────────────────────────────────────────────────────────
  // Availability check
  // ────────────────────────────────────────────────────────────────────────

  /// Returns `true` when the device supports biometric auth **and** at least
  /// one acceptable credential (face / fingerprint / hardware-backed strong)
  /// is enrolled.
  ///
  /// Returns `false` on any error, including [PlatformException].
  Future<bool> checkBiometrics() async {
    try {
      // Step 1: hardware + OS support (Secure Enclave / TEE present)
      final bool deviceSupported = await auth.isDeviceSupported();
      if (!deviceSupported) return false;

      // Step 2: enrolled credentials exist at all
      final bool canCheck = await auth.canCheckBiometrics;
      if (!canCheck) return false;

      // Step 3: at least one credential of acceptable security level
      final List<BiometricType> available =
          await auth.getAvailableBiometrics();
      if (available.isEmpty) return false;

      // Accept face, fingerprint, and hardware-backed "strong" biometrics.
      // BiometricType.weak covers software-only face unlock on some Android
      // OEMs — insufficient security for a crypto wallet; intentionally
      // excluded here.
      return available.any((t) =>
          t == BiometricType.face ||
          t == BiometricType.fingerprint ||
          t == BiometricType.strong);
    } on PlatformException catch (e) {
      debugPrint('[Biometric] checkBiometrics error: ${e.code} – ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[Biometric] checkBiometrics unexpected: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Authentication
  // ────────────────────────────────────────────────────────────────────────

  /// Triggers the OS biometric prompt and returns a [BiometricAuthResult].
  ///
  /// Call [checkBiometrics] first; if it returns `false` this method will
  /// always return [BiometricAuthResult.notAvailable].
  Future<BiometricAuthResult> authenticateWithBiometrics() async {
    try {
      // Build platform-specific auth messages inline to avoid depending on
      // the AuthMessages abstract type (not directly exported in local_auth 3.x).
      final dynamic authMessage = Platform.isIOS
          ? auth_ios.IOSAuthMessages(
              cancelButton: S.current.g_key_79,
              localizedFallbackTitle: S.current.g_face_8,
            )
          : auth_android.AndroidAuthMessages(
              signInHint: S.current.g_face_1,
              cancelButton: S.current.g_key_79,
              signInTitle: S.current.g_face_7,
            );

      final bool authenticated = await auth.authenticate(
        localizedReason: S.current.g_face_10,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        authMessages: [authMessage],
      );

      // `authenticate()` returns `false` (without exception) when the user
      // taps Cancel or dismisses the dialog — treat as userCancelled.
      return authenticated
          ? BiometricAuthResult.success
          : BiometricAuthResult.userCancelled;
    } on PlatformException catch (e) {
      return _mapPlatformException(e);
    } catch (e) {
      debugPrint('[Biometric] authenticateWithBiometrics unexpected: $e');
      return BiometricAuthResult.failed;
    }
  }

  /// Maps [PlatformException] error codes from both Android and iOS to a
  /// [BiometricAuthResult].
  ///
  /// Android codes:  `NotEnrolled`, `LockedOut`, `PermanentlyLockedOut`,
  ///                 `NotAvailable`, `PasscodeNotSet`
  /// iOS codes:      `NotEnrolled`, `LockedOut`, `NotAvailable`,
  ///                 `PasscodeNotSet`
  BiometricAuthResult _mapPlatformException(PlatformException e) {
    debugPrint('[Biometric] PlatformException: ${e.code} – ${e.message}');
    switch (e.code) {
      case 'NotEnrolled':
        return BiometricAuthResult.notEnrolled;
      case 'LockedOut':
      case 'PermanentlyLockedOut':
        return BiometricAuthResult.lockedOut;
      case 'NotAvailable':
      case 'PasscodeNotSet':
        return BiometricAuthResult.notAvailable;
      default:
        return BiometricAuthResult.failed;
    }
  }
}
