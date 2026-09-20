import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSecureStore implements SecureStore {
  final Map<String, String> values = {};
  final Set<String> failingWrites = {};
  final List<String> writtenKeys = [];

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
    writtenKeys.add(key);
    if (failingWrites.contains(key)) throw StateError('Storage unavailable');
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
      return SecurePreferences.test(prefs: prefs, secureStorage: secureStore);
    }

    test(
      'migrates plaintext sensitive key into secure storage on init',
      () async {
        final subject = await createSubject();
        await prefs.setString('walletInfo', '{"user":1}');

        await subject.init();

        expect(prefs.getString('walletInfo'), isNull);
        expect(secureStore.values['walletInfo'], '{"user":1}');
      },
    );

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

    test(
      'removes plaintext sensitive key even when secure storage already has value',
      () async {
        final subject = await createSubject();
        secureStore.values['walletInfo'] = '{"secure":true}';
        await prefs.setString('walletInfo', '{"legacy":true}');

        await subject.init();

        expect(prefs.getString('walletInfo'), isNull);
        expect(secureStore.values['walletInfo'], '{"secure":true}');
      },
    );

    test('clearSensitiveData removes all secure sensitive keys', () async {
      final subject = await createSubject();
      secureStore.values.addAll({
        'walletInfo': '{}',
        'security': '{}',
        'userInfo': '{}',
        'miningData': '{}',
      });

      await subject.clearSensitiveData();

      expect(secureStore.values, isEmpty);
    });

    test(
      'failed migration preserves the only copy and continues other keys',
      () async {
        final subject = await createSubject();
        await prefs.setString('walletInfo', '{"wallet":"local-test"}');
        await prefs.setString('security', '{"lock":true}');
        secureStore.failingWrites.add('walletInfo');

        await subject.init();

        expect(prefs.getString('walletInfo'), '{"wallet":"local-test"}');
        expect(secureStore.values.containsKey('walletInfo'), isFalse);
        expect(prefs.containsKey('security'), isFalse);
        expect(await subject.getSecurity(), {'lock': true});
      },
    );

    test('concurrent initialization performs each migration once', () async {
      final subject = await createSubject();
      await prefs.setString('walletInfo', '{"wallet":"local-test"}');
      final first = subject.init();
      final second = subject.init();
      expect(identical(first, second), isTrue);
      await Future.wait([first, second]);
      expect(secureStore.writtenKeys, ['walletInfo']);
      expect(prefs.containsKey('walletInfo'), isFalse);
    });

    test('wallet and user records stay out of plaintext preferences', () async {
      final subject = await createSubject();
      await subject.setWalletInfo({'walletId': 'test-wallet'});
      await subject.setSecurity({'requireUnlock': true});
      await subject.setUserInfo({'id': 'test-user'});
      expect(await subject.getWalletInfo(), {'walletId': 'test-wallet'});
      expect(await subject.getSecurity(), {'requireUnlock': true});
      expect(await subject.getUserInfo(), {'id': 'test-user'});
      expect(prefs.getKeys(), isEmpty);
      await subject.removeWalletInfo();
      await subject.setUserInfo(null);
      expect(await subject.getWalletInfo(), isNull);
      expect(await subject.getUserInfo(), isNull);
      expect(await subject.getSecurity(), {'requireUnlock': true});
    });

    test(
      'updating mining data preserves other users and replaces own record',
      () async {
        final subject = await createSubject();
        await subject.setMiningData('alice', {'round': 1});
        await subject.setMiningData('bob', {'round': 2});
        await subject.setMiningData('alice', {'round': 3});
        expect(await subject.getMiningData('alice'), {'round': 3});
        expect(await subject.getMiningData('bob'), {'round': 2});
        expect(await subject.getMiningData('unknown'), isNull);
        expect(prefs.containsKey('miningData'), isFalse);
      },
    );

    for (final corrupted in ['', 'not-json', '[]', '42']) {
      test('corrupted secure JSON returns absent data: $corrupted', () async {
        final subject = await createSubject();
        secureStore.values['walletInfo'] = corrupted;
        expect(await subject.getWalletInfo(), isNull);
        expect(secureStore.values['walletInfo'], corrupted);
      });
    }

    test(
      'clearing sensitive data preserves unrelated secrets and preferences',
      () async {
        final subject = await createSubject();
        await subject.setWalletInfo({'walletId': 'test'});
        secureStore.values['unrelated'] = 'keep';
        await subject.setThemeMode(2);
        await subject.clearSensitiveData();
        expect(secureStore.values, {'unrelated': 'keep'});
        expect(await subject.getThemeMode(), 2);
        await subject.clearAll();
        expect(secureStore.values, isEmpty);
        expect(prefs.getKeys(), isEmpty);
      },
    );

    test('consent defaults to unaccepted and revocation persists', () async {
      final subject = await createSubject();
      expect(await subject.getReadLoginClause(), isFalse);
      expect(await subject.hasAcceptedChatTerms(), isFalse);
      expect(await subject.getShowTermsOfService(), isFalse);
      await subject.setReadLoginClause(true);
      await subject.setHasAcceptedChatTerms(true);
      await subject.setShowTermsOfService(true);
      expect(prefs.getBool('readLoginClause'), isTrue);
      expect(prefs.getBool('hasAcceptedChatTerms'), isTrue);
      expect(prefs.getBool('showTermsOfService'), isTrue);
      await subject.setHasAcceptedChatTerms(false);
      expect(await subject.hasAcceptedChatTerms(), isFalse);
      expect(prefs.getBool('hasAcceptedChatTerms'), isFalse);
      expect(secureStore.values, isEmpty);
    });

    test(
      'browser settings tolerate malformed disk contents without rewriting',
      () async {
        final subject = await createSubject();
        expect(await subject.getBrowserSetting(), isNull);
        await prefs.setString('browserSetting', '{broken');
        expect(await subject.getBrowserSetting(), isNull);
        expect(prefs.getString('browserSetting'), '{broken');
        await subject.setBrowserSetting({'privateMode': true});
        expect(await subject.getBrowserSetting(), {'privateMode': true});
        expect(secureStore.values, isEmpty);
      },
    );
  });
}
