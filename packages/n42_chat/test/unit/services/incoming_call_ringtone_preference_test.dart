import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/voip/incoming_call_ringtone_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('IncomingCallRingtonePreference.fromSelection', () {
    test('maps system ringtone choices to system default CallKit path', () {
      final preference = IncomingCallRingtonePreference.fromSelection(
        key: 'pixel_sounds_01',
        label: 'Pixel Sounds',
        isSystemRingtone: true,
      );

      expect(preference.mode, IncomingCallRingtoneMode.system);
      expect(preference.androidRingtonePath, 'system_ringtone_default');
      expect(preference.iosRingtonePath, 'system_ringtone_default');
    });

    test('maps silent choice to silent Android asset and safe iOS fallback', () {
      final preference = IncomingCallRingtonePreference.fromSelection(
        key: 'silent',
        label: 'Silent',
      );

      expect(preference.mode, IncomingCallRingtoneMode.silent);
      expect(preference.androidRingtonePath, 'silent');
      expect(preference.iosRingtonePath, 'system_ringtone_default');
    });

    test('maps vibrate choice to silent Android asset and safe iOS fallback', () {
      final preference = IncomingCallRingtonePreference.fromSelection(
        key: 'vibrate',
        label: 'Vibrate',
      );

      expect(preference.mode, IncomingCallRingtoneMode.vibrate);
      expect(preference.androidRingtonePath, 'silent');
      expect(preference.iosRingtonePath, 'system_ringtone_default');
    });
  });

  group('IncomingCallRingtonePreference storage', () {
    test('loadIfPresent returns null when storage is empty', () async {
      final preference = await IncomingCallRingtonePreference.loadIfPresent();

      expect(preference, isNull);
    });

    test('loads default preference when storage is empty', () async {
      final preference = await IncomingCallRingtonePreference.load();

      expect(preference.mode, IncomingCallRingtoneMode.system);
      expect(preference.label, 'Default Ringtone');
    });

    test('round-trips stored preference JSON', () async {
      await IncomingCallRingtonePreference.saveSelection(
        key: 'silent',
        label: 'Silent',
      );

      final reloaded = await IncomingCallRingtonePreference.load();
      expect(reloaded.mode, IncomingCallRingtoneMode.silent);
      expect(reloaded.label, 'Silent');
      expect(reloaded.sourceKey, 'silent');

      final present = await IncomingCallRingtonePreference.loadIfPresent();
      expect(present, isNotNull);
      expect(present!.mode, IncomingCallRingtoneMode.silent);
    });
  });
}
