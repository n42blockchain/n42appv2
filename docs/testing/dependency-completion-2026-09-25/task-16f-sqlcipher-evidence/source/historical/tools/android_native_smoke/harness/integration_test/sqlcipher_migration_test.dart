import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:matrix/matrix.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as plain;
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:sqlite3/sqlite3.dart' as raw;

const fixtureKey = 'sqlcipher-16k-synthetic-key';
const receiptPrefix = 'N42_SQLCIPHER_RECEIPT ';
const runtimeChannel = MethodChannel('com.n42.android_native_smoke/vectors');

Future<void> printRuntimeReceipt(
  String phase,
  List<String> databasePaths,
) async {
  final apkPath = await runtimeChannel.invokeMethod<String>('sqlcipherApkPath');
  expect(apkPath, isNotNull);
  final apk = File(apkPath!);
  expect(await apk.exists(), isTrue);
  final digest = await sha256.bind(apk.openRead()).first;
  final maps = await File('/proc/self/maps').readAsLines();
  final executableApkMaps = maps
      .where((line) => line.contains(apkPath) && line.contains('r-xp'))
      .toList();
  final directLibraryMaps = maps
      .where((line) => line.contains('libsqlcipher.so'))
      .toList();
  expect(executableApkMaps.isNotEmpty || directLibraryMaps.isNotEmpty, isTrue);
  final databaseSha256 = <String, String>{};
  for (final path in databasePaths) {
    databaseSha256[path] = (await sha256.bind(File(path).openRead()).first)
        .toString();
  }
  final nonce = List<int>.generate(12, (_) => Random.secure().nextInt(256));
  print(
    '$receiptPrefix${jsonEncode({'phase': phase, 'pid': pid, 'nonce': base64Url.encode(nonce), 'apkPath': apkPath, 'apkSha256': digest.toString(), 'executableApkMaps': executableApkMaps, 'directLibraryMaps': directLibraryMaps, 'databaseSha256': databaseSha256})}',
  );
}

Future<void> seedDatabases(String directory) async {
  final ffiProbe = raw.sqlite3.openInMemory();
  try {
    expect(
      ffiProbe.select('PRAGMA cipher_version;').single.values.single,
      startsWith('4.10.'),
    );
  } finally {
    ffiProbe.close();
  }
  final seededPaths = <String>[];
  for (final label in ['official', 'candidate']) {
    final path = p.join(directory, 'sqlcipher_16k_old_$label.db');
    seededPaths.add(path);
    await cipher.deleteDatabase(path);
    final database = await cipher.openDatabase(path, password: fixtureKey);
    try {
      await database.execute('CREATE TABLE fixture (value TEXT NOT NULL)');
      await database.insert('fixture', {'value': 'saved by SQLCipher 4.10'});
    } finally {
      await database.close();
    }
    expect(await File(path).exists(), isTrue);
  }
  final plainPath = p.join(directory, 'sqlcipher_16k_plaintext.db');
  await plain.deleteDatabase(plainPath);
  final plaintext = await plain.openDatabase(plainPath);
  try {
    await plaintext.execute('CREATE TABLE fixture (value TEXT NOT NULL)');
    await plaintext.insert('fixture', {'value': 'plaintext source'});
  } finally {
    await plaintext.close();
  }
  expect(await File(plainPath).exists(), isTrue);
  await printRuntimeReceipt('seed', seededPaths);
}

Future<void> verifyDatabase(String directory, String phase) async {
  final oldPath = p.join(directory, 'sqlcipher_16k_old_$phase.db');
  final plainPath = p.join(directory, 'sqlcipher_16k_plaintext.db');
  final migratedPath = p.join(directory, 'sqlcipher_16k_export_$phase.db');
  expect(await File(oldPath).exists(), isTrue);
  expect(await File(plainPath).exists(), isTrue);

  final ffiProbe = raw.sqlite3.openInMemory();
  try {
    expect(
      ffiProbe.select('PRAGMA cipher_version;').single.values.single,
      startsWith('4.19.'),
    );
  } finally {
    ffiProbe.close();
  }

  final java = await cipher.openDatabase(oldPath, password: fixtureKey);
  try {
    expect(await java.rawQuery('SELECT value FROM fixture'), [
      {'value': 'saved by SQLCipher 4.10'},
    ]);
    await java.insert('fixture', {'value': 'temporary row'});
    expect(
      await java.update(
        'fixture',
        {'value': 'updated temporary row'},
        where: 'value = ?',
        whereArgs: ['temporary row'],
      ),
      1,
    );
    expect(
      await java.delete(
        'fixture',
        where: 'value = ?',
        whereArgs: ['updated temporary row'],
      ),
      1,
    );
    await java.insert('fixture', {'value': 'verified by SQLCipher 4.19'});
  } finally {
    await java.close();
  }
  final reopened = await cipher.openDatabase(oldPath, password: fixtureKey);
  try {
    expect(
      await reopened.rawQuery('SELECT value FROM fixture ORDER BY rowid'),
      [
        {'value': 'saved by SQLCipher 4.10'},
        {'value': 'verified by SQLCipher 4.19'},
      ],
    );
  } finally {
    await reopened.close();
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
    readWithKey('wrong-synthetic-key'),
    throwsA(isA<Exception>()),
  );
  await expectLater(readWithKey(null), throwsA(isA<Exception>()));
  final afterRejectedKeys = await cipher.openDatabase(
    oldPath,
    password: fixtureKey,
  );
  try {
    expect(
      await afterRejectedKeys.rawQuery('SELECT count(*) AS count FROM fixture'),
      [
        {'count': 2},
      ],
    );
  } finally {
    await afterRejectedKeys.close();
  }

  void readWithFfiKey(String? key) {
    final database = raw.sqlite3.open(oldPath);
    try {
      if (key != null) database.execute("PRAGMA key = '$key';");
      database.select('SELECT value FROM fixture');
    } finally {
      database.close();
    }
  }

  expect(
    () => readWithFfiKey('wrong-synthetic-key'),
    throwsA(isA<Exception>()),
  );
  expect(() => readWithFfiKey(null), throwsA(isA<Exception>()));

  final ffiOld = raw.sqlite3.open(oldPath);
  try {
    ffiOld.execute("PRAGMA key = '$fixtureKey';");
    expect(
      ffiOld
          .select('SELECT value FROM fixture ORDER BY rowid')
          .map((row) => row.values.single)
          .toList(),
      ['saved by SQLCipher 4.10', 'verified by SQLCipher 4.19'],
    );
  } finally {
    ffiOld.close();
  }

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
      'plaintext source',
    );
  } finally {
    migrated.close();
  }
  final javaMigrated = await cipher.openDatabase(
    migratedPath,
    password: fixtureKey,
  );
  try {
    expect(await javaMigrated.rawQuery('SELECT value FROM fixture'), [
      {'value': 'plaintext source'},
    ]);
  } finally {
    await javaMigrated.close();
  }

  final matrixPath = p.join(directory, 'sqlcipher_16k_matrix_$phase.db');
  await plain.deleteDatabase(matrixPath);
  final matrixSqlite = await plain.openDatabase(matrixPath);
  final matrix = await MatrixSdkDatabase.init(
    'sqlcipher_16k_matrix_$phase',
    database: matrixSqlite,
  );
  await matrix.close();
  expect(
    File(matrixPath).readAsBytesSync().take(16).toList(),
    'SQLite format 3\u0000'.codeUnits,
  );
  await printRuntimeReceipt(phase, [oldPath]);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('synthetic SQLCipher 4.10 to 4.19 Java and FFI migration', (
    tester,
  ) async {
    await tester.runAsync(() async {
      const phase = String.fromEnvironment('N42_SQLCIPHER_PHASE');
      expect(['seed', 'official', 'candidate'], contains(phase));
      final directory = await plain.getDatabasesPath();
      if (phase == 'seed') {
        await seedDatabases(directory);
      } else {
        await verifyDatabase(directory, phase);
      }
    });
  });
}
