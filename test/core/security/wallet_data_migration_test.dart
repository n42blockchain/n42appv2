import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/security/wallet_data_migration.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSecureStorage extends SecureStorage {
  final Map<String, String> mnemonics = {};
  final Map<String, String> privateKeys = {};
  final Map<String, Map<String, dynamic>> credentials = {};

  bool failOnMnemonicSave = false;

  @override
  Future<void> saveMnemonic({
    required String walletId,
    required String mnemonic,
  }) async {
    if (failOnMnemonicSave) {
      throw StateError('save mnemonic failed');
    }
    mnemonics[walletId] = mnemonic;
  }

  @override
  Future<void> savePrivateKey({
    required String address,
    required String privateKey,
  }) async {
    privateKeys[address] = privateKey;
  }

  @override
  Future<void> saveWalletCredentials({
    required String address,
    required Map<String, dynamic> credentials,
  }) async {
    this.credentials[address] = credentials;
  }

  @override
  Future<Map<String, dynamic>?> getWalletCredentials(String address) async {
    return credentials[address];
  }
}

class FakeSPUtil extends SPUtil {
  FakeSPUtil(this.walletInfo);

  Map<String, dynamic>? walletInfo;
  Map<String, dynamic>? lastSavedWalletInfo;

  @override
  Future<Map<String, dynamic>?> getWalletInfo() async => walletInfo;

  @override
  Future<void> setWalletInfo(Map<String, dynamic> map) async {
    lastSavedWalletInfo = map;
    walletInfo = map;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletDataMigration', () {
    late FakeSecureStorage secureStorage;
    late FakeSPUtil spUtil;
    late WalletDataMigration migration;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      secureStorage = FakeSecureStorage();
      spUtil = FakeSPUtil(null);
      migration = WalletDataMigration(
        secureStorage: secureStorage,
        spUtil: spUtil,
      );
    });

    test('migrates wallet secrets and sanitizes stored wallet info', () async {
      spUtil.walletInfo = {
        'user-1': {
          'wallet': [
            {
              'timestamp': '1700000000000',
              'mnemonic': 'seed words',
              'privateKey': '0xabc',
              'password': 'pw',
              'walletName': 'Main',
            },
          ],
        },
      };

      final count = await migration.migrate();

      expect(count, 1);
      expect(secureStorage.mnemonics['1700000000000'], 'seed words');
      expect(secureStorage.privateKeys['1700000000000'], '0xabc');
      expect(
        secureStorage.credentials['wallet_password_1700000000000'],
        {'password': 'pw'},
      );

      final savedWallet =
          (spUtil.lastSavedWalletInfo!['user-1'] as Map<String, dynamic>)['wallet']
              as List<dynamic>;
      final wallet = savedWallet.single as Map<String, dynamic>;
      expect(wallet['mnemonic'], isNull);
      expect(wallet['privateKey'], isNull);
      expect(wallet['password'], isNull);
      expect(await migration.needsMigration(), isFalse);
    });

    test('uses numeric timestamp values as wallet ids', () async {
      spUtil.walletInfo = {
        'user-1': {
          'wallet': [
            {
              'timestamp': 1700000000001,
              'mnemonic': 'seed words',
            },
          ],
        },
      };

      final count = await migration.migrate();

      expect(count, 1);
      expect(secureStorage.mnemonics['1700000000001'], 'seed words');
      expect(secureStorage.mnemonics.containsKey('user-1_0'), isFalse);
    });

    test('preserves malformed wallet entries instead of crashing', () async {
      spUtil.walletInfo = {
        'user-1': {
          'wallet': [
            null,
            'legacy-entry',
            {
              'timestamp': '1700000000002',
              'mnemonic': 'seed words',
            },
          ],
        },
      };

      final count = await migration.migrate();

      expect(count, 1);
      final savedWallets =
          (spUtil.lastSavedWalletInfo!['user-1'] as Map<String, dynamic>)['wallet']
              as List<dynamic>;
      expect(savedWallets[0], isNull);
      expect(savedWallets[1], 'legacy-entry');
      expect(
        (savedWallets[2] as Map<String, dynamic>)['mnemonic'],
        isNull,
      );
    });

    test('does not mark migration complete when secure save fails', () async {
      secureStorage.failOnMnemonicSave = true;
      spUtil.walletInfo = {
        'user-1': {
          'wallet': [
            {
              'timestamp': '1700000000003',
              'mnemonic': 'seed words',
            },
          ],
        },
      };

      await expectLater(migration.migrate(), throwsStateError);
      expect(await migration.needsMigration(), isTrue);
      expect(spUtil.lastSavedWalletInfo, isNull);
    });
  });
}
