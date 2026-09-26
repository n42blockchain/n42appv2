import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as native_crypto;
import 'package:integration_test/integration_test.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/encryption/utils/pickle_key.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as plain;
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:vodozemac/vodozemac.dart' as crypto;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('packaged Apple SQLCipher and legacy Vodozemac compatibility', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'n42-apple-fixture-',
      );
      try {
        final ffi = raw.sqlite3.openInMemory();
        expect(
          ffi.select('PRAGMA cipher_version').single.values.single,
          startsWith('4.19.'),
        );
        ffi.execute(
          'CREATE TABLE changes (id INTEGER PRIMARY KEY, value TEXT)',
        );
        final session = raw.Session(ffi);
        session.attach('changes');
        ffi.execute("INSERT INTO changes VALUES (1, 'ffi-session')");
        expect(session.isNotEmpty, isTrue);
        expect(session.changeset().bytes, isNotEmpty);
        session.delete();
        ffi.close();
        final oldPath = p.join(directory.path, 'old.db');
        final bytes = await rootBundle.load(
          'fixtures/sqlcipher-4.10-archive.db',
        );
        await File(oldPath).writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
        final old = raw.sqlite3.open(oldPath);
        old.execute('PRAGMA key = "x\'${'a' * 64}\'";');
        expect(old.select('PRAGMA integrity_check').single.values.single, 'ok');
        expect(
          old.select('SELECT count(*) FROM sqlite_master').single.values.single,
          greaterThan(0),
        );
        old.close();
        for (final key in [null, 'wrong-public-key']) {
          final wrong = raw.sqlite3.open(oldPath);
          try {
            if (key != null) wrong.execute("PRAGMA key = '$key'");
            expect(
              () => wrong.select('SELECT * FROM sqlite_master'),
              throwsA(isA<raw.SqliteException>()),
            );
          } finally {
            wrong.close();
          }
        }
        final walletPath = p.join(directory.path, 'wallet.db');
        final wallet = await cipher.openDatabase(
          walletPath,
          password: 'fixture-only-key',
        );
        expect(
          (await wallet.rawQuery('PRAGMA cipher_version')).single.values.single,
          startsWith('4.19.'),
        );
        await wallet.execute(
          'CREATE TABLE wallet (id INTEGER PRIMARY KEY, value TEXT)',
        );
        await wallet.insert('wallet', {'id': 1, 'value': 'saved'});
        await wallet.close();
        for (final key in [null, 'wrong']) {
          await expectLater(() async {
            final wrong = await cipher.openDatabase(
              walletPath,
              password: key,
              singleInstance: false,
            );
            try {
              await wrong.rawQuery('SELECT * FROM wallet');
            } finally {
              await wrong.close();
            }
          }(), throwsA(isA<Exception>()));
        }
        final reopened = await cipher.openDatabase(
          walletPath,
          password: 'fixture-only-key',
        );
        expect(await reopened.query('wallet'), [
          {'id': 1, 'value': 'saved'},
        ]);
        await reopened.close();
        final cross = raw.sqlite3.open(walletPath);
        cross.execute("PRAGMA key = 'fixture-only-key'");
        expect(
          cross.select('SELECT value FROM wallet').single.values.single,
          'saved',
        );
        cross.close();
        final plainPath = p.join(directory.path, 'plain.db');
        final encryptedPath = p.join(directory.path, 'exported.db');
        final source = raw.sqlite3.open(plainPath);
        source.execute('CREATE TABLE archive (value TEXT)');
        source.execute("INSERT INTO archive VALUES ('historical plaintext')");
        source.execute(
          "ATTACH DATABASE '$encryptedPath' AS encrypted KEY 'fixture-only-key'",
        );
        source.select("SELECT sqlcipher_export('encrypted')");
        source.execute('DETACH DATABASE encrypted');
        source.close();
        final exported = await cipher.openDatabase(
          encryptedPath,
          password: 'fixture-only-key',
        );
        expect(await exported.query('archive'), [
          {'value': 'historical plaintext'},
        ]);
        await exported.close();
        final matrixPath = p.join(directory.path, 'matrix.db');
        final db = await plain.openDatabase(matrixPath);
        final matrix = await MatrixSdkDatabase.init(
          'apple-smoke',
          database: db,
        );
        await matrix.close();
        expect(
          File(matrixPath).readAsBytesSync().take(16).toList(),
          'SQLite format 3\u0000'.codeUnits,
        );
        // Default loader exercises the actual maintained plugin framework.
        await native_crypto.init();
        final legacy = jsonDecode(
          await rootBundle.loadString('fixtures/vodozemac-0.5-pickles.json'),
        ) as Map<String, dynamic>;
        final pickleKey = (legacy['user_id'] as String).toPickleKey();
        final account = crypto.Account.fromPickleEncrypted(
          pickle: legacy['account_pickle'] as String,
          pickleKey: pickleKey,
        );
        expect(account.ed25519Key.toBase64(), legacy['account_ed25519']);
        expect(account.curve25519Key.toBase64(), legacy['account_curve25519']);
        final inbound = crypto.InboundGroupSession.fromPickleEncrypted(
          pickle: legacy['inbound_pickle'] as String,
          pickleKey: pickleKey,
        );
        expect(
          inbound.decrypt(legacy['ciphertext'] as String).plaintext,
          legacy['plaintext'],
        );
        final outbound = crypto.GroupSession.fromPickleEncrypted(
          pickle: legacy['outbound_pickle'] as String,
          pickleKey: pickleKey,
        );
        expect(
          inbound
              .decrypt(outbound.encrypt('continued Apple history'))
              .plaintext,
          'continued Apple history',
        );
        expect(
          () => crypto.Account.fromPickleEncrypted(
            pickle: legacy['account_pickle'] as String,
            pickleKey: Uint8List(32),
          ),
          throwsA(anything),
        );
        print(
          'SQLCipher FFI/FMDB4.19, historical4.10, Matrix plaintext, export, session and packaged Vodozemac checks passed',
        );
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });
  testWidgets(
    'isolated Apple Keychain accounts preserve reads',
    (tester) async {
      await tester.runAsync(() async {
        for (final account in [
          'n42_smoke_wallet',
          'n42_smoke_prefs',
          'n42_smoke_default',
        ]) {
          FlutterSecureStorage store() => FlutterSecureStorage(
            iOptions: IOSOptions(
              accountName: account,
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
            mOptions: MacOsOptions(
              accountName: account,
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );
          final key = 'fixture-${DateTime.now().microsecondsSinceEpoch}';
          try {
            await store().write(key: key, value: 'test-value');
            expect(await store().read(key: key), 'test-value');
            expect(await store().containsKey(key: key), isTrue);
            expect((await store().readAll())[key], 'test-value');
          } finally {
            await store().delete(key: key);
          }
          expect(await store().read(key: key), isNull);
        }
      });
    },
    skip: Platform.isMacOS,
  ); // Data-protection Keychain requires a provisioned macOS app.
}
