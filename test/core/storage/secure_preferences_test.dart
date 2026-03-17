import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSecureStore implements SecureStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    values.clear();
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecurePreferences', () {
    late SharedPreferences prefs;
    late FakeSecureStore secureStore;

    Future<SecurePreferences> createSubject() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      secureStore = FakeSecureStore();
      return SecurePreferences.test(
        prefs: prefs,
        secureStorage: secureStore,
      );
    }

    test('migrates plaintext sensitive key into secure storage on init', () async {
      final subject = await createSubject();
      await prefs.setString('walletInfo', '{"user":1}');

      await subject.init();

      expect(prefs.getString('walletInfo'), isNull);
      expect(secureStore.values['walletInfo'], '{"user":1}');
    });

    test('migrates legacy mining data from shared preferences', () async {
      final subject = await createSubject();
      await prefs.setString('miningData', '{"user-1":{"status":"active"}}');

      await subject.init();

      expect(prefs.getString('miningData'), isNull);
      expect(
        secureStore.values['miningData'],
        '{"user-1":{"status":"active"}}',
      );
    });

    test('removes plaintext sensitive key even when secure storage already has value', () async {
      final subject = await createSubject();
      secureStore.values['walletInfo'] = '{"secure":true}';
      await prefs.setString('walletInfo', '{"legacy":true}');

      await subject.init();

      expect(prefs.getString('walletInfo'), isNull);
      expect(secureStore.values['walletInfo'], '{"secure":true}');
    });

    test('clearSensitiveData removes all secure sensitive keys', () async {
      final subject = await createSubject();
      secureStore.values.addAll({
        'walletInfo': '{}',
        'security': '{}',
        'lockScreen': '{}',
        'userInfo': '{}',
        'miningData': '{}',
      });

      await subject.clearSensitiveData();

      expect(secureStore.values, isEmpty);
    });
  });
}
