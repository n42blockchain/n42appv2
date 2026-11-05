import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';

class _RecordingStorage extends TestFlutterSecureStoragePlatform {
  _RecordingStorage() : super({});
  final reads = <Map<String, String>>[];

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    reads.add(Map.of(options));
    return super.read(key: key, options: options);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Android wallet and preferences select their verified legacy import namespaces', () async {
    final original = FlutterSecureStoragePlatform.instance;
    final recording = _RecordingStorage();
    FlutterSecureStoragePlatform.instance = recording;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await SecureStorage().getToken();
      await FlutterSecureStore().read(key: 'walletInfo');
      expect(recording.reads.map((o) => o['storageNamespace']), [
        'n42_secure_v11_wallet',
        'n42_secure_v11_preferences',
      ]);
      expect(recording.reads.map((o) => o['preferencesKeyPrefix']), [
        'n42_',
        'sp_',
      ]);
      expect(
        recording.reads.every((o) => o['resetOnError'] == 'false'),
        isTrue,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
      FlutterSecureStoragePlatform.instance = original;
    }
  });

  test('iOS keeps both existing keychain accounts and accessibility', () async {
    final original = FlutterSecureStoragePlatform.instance;
    final recording = _RecordingStorage();
    FlutterSecureStoragePlatform.instance = recording;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await SecureStorage().getToken();
      await FlutterSecureStore().read(key: 'walletInfo');
      expect(recording.reads.map((o) => o['accountName']), [
        'n42wallet',
        'n42wallet_prefs',
      ]);
      expect(
        recording.reads.every(
          (o) => o['accessibility'] == 'first_unlock_this_device',
        ),
        isTrue,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
      FlutterSecureStoragePlatform.instance = original;
    }
  });
}
