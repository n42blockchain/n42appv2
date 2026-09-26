import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as native_crypto;
import 'package:integration_test/integration_test.dart';
import 'package:matrix/matrix.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as plain;
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:vodozemac/vodozemac.dart' as crypto;

const fixtureKey = 'isolated-test-key-only';

Future<void> verifyTorusCompatibility() async {
  final vectors = await const MethodChannel(
    'com.n42.android_native_smoke/vectors',
  ).invokeMapMethod<String, String>('compatibility');
  // The private-key API's result is an upstream Torus behavior. These fixed
  // values protect existing account identity across the BC provider change.
  expect(vectors, {
    '0:fromPublic': '0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf',
    '0:fromPrivate': '0x2A908Ffb91e7a9e9702622FE93c8BfBa86c02224',
    '1:fromPublic': '0xFCAd0B19bB29D4674531d6f115237E16AfCE377c',
    '1:fromPrivate': '0xfaE32E526812ac9E6aeb235137D25e0afab7ff07',
  });
  print('Torus public test-vector addresses: $vectors');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native SQLCipher, Matrix, and Vodozemac smoke', (tester) async {
    await tester.runAsync(() async {
      const phase = String.fromEnvironment('N42_SMOKE_PHASE');
      if (phase == 'compatibility') {
        await verifyTorusCompatibility();
        return;
      }
      final directory = await plain.getDatabasesPath();
      final oldPath = p.join(directory, 'native_smoke_old_cipher.db');
      final plainPath = p.join(directory, 'native_smoke_plaintext.db');
      final migratedPath = p.join(directory, 'native_smoke_migrated.db');

      if (phase == 'seed') {
        final seedProbe = raw.sqlite3.openInMemory();
        try {
          expect(
            seedProbe.select('PRAGMA cipher_version;').single.values.single,
            startsWith('4.10.'),
          );
        } finally {
          seedProbe.close();
        }
        await cipher.deleteDatabase(oldPath);
        await plain.deleteDatabase(plainPath);
        await cipher.deleteDatabase(migratedPath);

        final old = await cipher.openDatabase(oldPath, password: fixtureKey);
        await old.execute('CREATE TABLE fixture (value TEXT NOT NULL)');
        await old.insert('fixture', {'value': 'saved by SQLCipher 4.10'});
        await old.close();

        final plaintext = await plain.openDatabase(plainPath);
        await plaintext.execute('CREATE TABLE fixture (value TEXT NOT NULL)');
        await plaintext.insert('fixture', {'value': 'plaintext archive'});
        await plaintext.close();
        expect(File(oldPath).existsSync(), isTrue);
        expect(File(plainPath).existsSync(), isTrue);
        return;
      }

      expect(phase, 'verify');
      expect(File(oldPath).existsSync(), isTrue);
      expect(File(plainPath).existsSync(), isTrue);

      final ffiProbe = raw.sqlite3.openInMemory();
      try {
        final versions = ffiProbe.select('PRAGMA cipher_version;');
        expect(versions, hasLength(1));
        expect(versions.single.values.single.toString(), startsWith('4.19.'));
      } finally {
        ffiProbe.close();
      }

      // The same on-device file survives replacement of the 4.10 AAR.
      final old = await cipher.openDatabase(oldPath, password: fixtureKey);
      try {
        expect(await old.rawQuery('SELECT value FROM fixture'), [
          {'value': 'saved by SQLCipher 4.10'},
        ]);
      } finally {
        await old.close();
      }

      Future<void> readWithKey(String? key) async {
        final database = await cipher.openDatabase(oldPath, password: key);
        try {
          await database.rawQuery('SELECT value FROM fixture');
        } finally {
          await database.close();
        }
      }

      await expectLater(
        readWithKey('wrong-test-key'),
        throwsA(isA<Exception>()),
      );
      await expectLater(readWithKey(null), throwsA(isA<Exception>()));

      // Match the archive migration's SQLCipher FFI attach/export flow.
      await cipher.deleteDatabase(migratedPath);
      final plaintext = raw.sqlite3.open(plainPath);
      try {
        plaintext.execute(
          "ATTACH DATABASE '$migratedPath' AS encrypted KEY '$fixtureKey';",
        );
        plaintext.select("SELECT sqlcipher_export('encrypted');");
        plaintext.execute('DETACH DATABASE encrypted;');
      } finally {
        plaintext.close();
      }
      final migrated = raw.sqlite3.open(migratedPath);
      try {
        migrated.execute("PRAGMA key = '$fixtureKey';");
        expect(
          migrated.select('SELECT value FROM fixture').single.values.single,
          'plaintext archive',
        );
      } finally {
        migrated.close();
      }

      // MatrixSdkDatabase uses the host's separate, unkeyed sqflite database.
      final matrixPath = p.join(directory, 'native_smoke_matrix.db');
      await plain.deleteDatabase(matrixPath);
      final matrixSqlite = await plain.openDatabase(matrixPath);
      final matrix = await MatrixSdkDatabase.init(
        'native_smoke_matrix',
        database: matrixSqlite,
      );
      await matrix.close();
      expect(
        File(matrixPath).readAsBytesSync().take(16).toList(),
        'SQLite format 3\u0000'.codeUnits,
      );

      await native_crypto.init();
      final sender = crypto.GroupSession();
      final receiver = crypto.InboundGroupSession(sender.sessionKey);
      expect(
        receiver.decrypt(sender.encrypt('native crypto handshake')).plaintext,
        'native crypto handshake',
      );

      expect(
        await const MethodChannel('com.n42.android_native_smoke/vectors')
            .invokeMethod<bool>('verify'),
        isTrue,
      );
      await verifyTorusCompatibility();
    });
  });
}
