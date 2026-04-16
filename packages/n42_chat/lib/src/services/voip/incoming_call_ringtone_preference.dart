import 'dart:convert';

import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/debug_log.dart';

enum IncomingCallRingtoneMode { system, silent, vibrate }

/// Stores the local incoming-call ringtone preference in a format that
/// foreground calls and background VoIP push can both consume.
class IncomingCallRingtonePreference {
  static const String _storageKey = 'n42_chat_incoming_call_ringtone';
  static const String systemDefaultRingtonePath = 'system_ringtone_default';
  static const String androidSilentRingtonePath = 'silent';

  final IncomingCallRingtoneMode mode;
  final String label;
  final String? sourceKey;

  const IncomingCallRingtonePreference({
    required this.mode,
    required this.label,
    this.sourceKey,
  });

  factory IncomingCallRingtonePreference.system({String label = 'Default Ringtone'}) {
    return IncomingCallRingtonePreference(
      mode: IncomingCallRingtoneMode.system,
      label: label,
      sourceKey: 'default',
    );
  }

  factory IncomingCallRingtonePreference.fromSelection({
    required String key,
    required String label,
    bool isSystemRingtone = false,
    bool isDefault = false,
  }) {
    if (key == 'silent') {
      return IncomingCallRingtonePreference(
        mode: IncomingCallRingtoneMode.silent,
        label: label,
        sourceKey: key,
      );
    }
    if (key == 'vibrate') {
      return IncomingCallRingtonePreference(
        mode: IncomingCallRingtoneMode.vibrate,
        label: label,
        sourceKey: key,
      );
    }

    return IncomingCallRingtonePreference(
      mode: IncomingCallRingtoneMode.system,
      label: label,
      sourceKey: isDefault ? 'default' : (isSystemRingtone ? key : 'default'),
    );
  }

  factory IncomingCallRingtonePreference.fromStoredValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return IncomingCallRingtonePreference.system();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return IncomingCallRingtonePreference.system(label: raw);
      }

      final modeName = decoded['mode'] as String? ?? 'system';
      final label = decoded['label'] as String? ?? 'Default Ringtone';
      final sourceKey = decoded['sourceKey'] as String?;

      return IncomingCallRingtonePreference(
        mode: IncomingCallRingtoneMode.values.firstWhere(
          (value) => value.name == modeName,
          orElse: () => IncomingCallRingtoneMode.system,
        ),
        label: label,
        sourceKey: sourceKey,
      );
    } catch (e) {
      debugLog('IncomingCallRingtonePreference: Failed to decode stored value - $e');
      return IncomingCallRingtonePreference.system(label: raw);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'label': label,
      'sourceKey': sourceKey,
    };
  }

  String encode() => jsonEncode(toJson());

  static Future<String?> loadRawValue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_storageKey);
    } catch (e) {
      debugLog(
        'IncomingCallRingtonePreference: Failed to load raw preference - $e',
      );
      return null;
    }
  }

  String get androidRingtonePath {
    return switch (mode) {
      IncomingCallRingtoneMode.system => systemDefaultRingtonePath,
      IncomingCallRingtoneMode.silent => androidSilentRingtonePath,
      IncomingCallRingtoneMode.vibrate => androidSilentRingtonePath,
    };
  }

  /// iOS CallKit only accepts a bundled sound name, not an Android-style
  /// ringtone URI. Until the host app ships dedicated silent/vibrate assets,
  /// fall back to the system default sound there.
  String get iosRingtonePath => systemDefaultRingtonePath;

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, encode());
  }

  static Future<IncomingCallRingtonePreference> load() async {
    final raw = await loadRawValue();
    return IncomingCallRingtonePreference.fromStoredValue(raw);
  }

  static Future<IncomingCallRingtonePreference?> loadIfPresent() async {
    final raw = await loadRawValue();
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return IncomingCallRingtonePreference.fromStoredValue(raw);
  }

  static Future<void> saveSelection({
    required String key,
    required String label,
    bool isSystemRingtone = false,
    bool isDefault = false,
  }) async {
    final preference = IncomingCallRingtonePreference.fromSelection(
      key: key,
      label: label,
      isSystemRingtone: isSystemRingtone,
      isDefault: isDefault,
    );
    await preference.persist();
  }
}

AndroidParams buildIncomingCallAndroidParams({
  required IncomingCallRingtonePreference ringtonePreference,
  String? avatarUrl,
  String incomingCallChannelName = 'Incoming call',
  String missedCallChannelName = 'Missed call',
}) {
  return AndroidParams(
    isCustomNotification: true,
    isShowLogo: true,
    ringtonePath: ringtonePreference.androidRingtonePath,
    backgroundColor: '#0955fa',
    backgroundUrl: avatarUrl,
    actionColor: '#4CAF50',
    textColor: '#ffffff',
    incomingCallNotificationChannelName: incomingCallChannelName,
    missedCallNotificationChannelName: missedCallChannelName,
    isShowCallID: false,
  );
}

IOSParams buildIncomingCallIOSParams({
  required IncomingCallRingtonePreference ringtonePreference,
}) {
  return IOSParams(
    iconName: 'CallKitLogo',
    handleType: 'generic',
    supportsVideo: true,
    maximumCallGroups: 1,
    maximumCallsPerCallGroup: 1,
    audioSessionMode: 'videoChat',
    audioSessionActive: true,
    audioSessionPreferredSampleRate: 44100.0,
    audioSessionPreferredIOBufferDuration: 0.005,
    supportsDTMF: false,
    supportsHolding: false,
    supportsGrouping: false,
    supportsUngrouping: false,
    ringtonePath: ringtonePreference.iosRingtonePath,
  );
}
