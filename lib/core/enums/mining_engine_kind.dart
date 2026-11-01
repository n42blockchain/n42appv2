import 'package:flutter/foundation.dart';

/// Which mining engine the app runs; only one runs at a time.
///
/// - [v1]: APOS mining through the Go evmsdk (`Evmsdk.emit`).
/// - [v2]: beacon-chain staking through the Rust mobile SDK.
/// - [v3]: N42 mobile verification (`/mobileverify`): the phone
///   re-executes blocks and attests them, through the Go evmsdk's
///   MobileVerifySession.
enum MiningEngineKind {
  v1,
  v2,
  v3;

  /// The kind stored under [name], or null for an unknown value.
  static MiningEngineKind? fromName(String? name) {
    for (final kind in values) {
      if (kind.name == name) return kind;
    }
    return null;
  }

  /// The pre-v3 setting was a bool: true for v2, false for v1.
  static MiningEngineKind fromUseV2(bool useV2) => useV2 ? v2 : v1;
}

/// V3 has native bridges on Android and iOS in all build modes.
bool get miningV3Available =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
