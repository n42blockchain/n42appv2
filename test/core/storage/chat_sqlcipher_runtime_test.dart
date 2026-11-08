import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

String cipherVersion() {
  final db = sqlite3.openInMemory();
  try {
    final rows = db.select('PRAGMA cipher_version;');
    return rows.isEmpty ? '' : rows.first.values.first.toString();
  } finally {
    db.close();
  }
}

void main() {
  test('host resolves SQLCipher for Chat archive connections', () {
    expect(cipherVersion(), isNotEmpty);
  });

  test('background isolates resolve the same SQLCipher engine', () async {
    expect(await Isolate.run(cipherVersion), isNotEmpty);
  });

  test('legacy plaintext can be exported without changing its source', () {
    final directory = Directory.systemTemp.createTempSync('n42-cipher-export-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final original = '${directory.path}/legacy.db';
    final encrypted = '${directory.path}/encrypted.db';
    final source = sqlite3.open(original);
    try {
      source.execute('CREATE TABLE messages (body TEXT NOT NULL);');
      source.execute('INSERT INTO messages VALUES (?)', ['legacy fixture']);
      source.execute('ATTACH DATABASE ? AS encrypted KEY ?', [
        encrypted,
        'fixture-export-key',
      ]);
      source.select("SELECT sqlcipher_export('encrypted');");
      source.execute('DETACH DATABASE encrypted;');
      expect(
        source.select('SELECT body FROM messages;').single['body'],
        'legacy fixture',
      );
    } finally {
      source.close();
    }
    expect(
      File(original).readAsBytesSync().take(16),
      orderedEquals('SQLite format 3\u0000'.codeUnits),
    );
    final target = sqlite3.open(encrypted);
    try {
      target.execute("PRAGMA key = 'fixture-export-key';");
      expect(
        target.select('SELECT body FROM messages;').single['body'],
        'legacy fixture',
      );
    } finally {
      target.close();
    }
  });

  test('encrypted Chat-shaped file rejects a wrong key and preserves data', () {
    final directory = Directory.systemTemp.createTempSync(
      'n42-cipher-fixture-',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    final path = '${directory.path}/archive.db';
    const key = 'fixture-only-passphrase';
    final created = sqlite3.open(path);
    try {
      created.execute("PRAGMA key = '$key';");
      created.execute('CREATE TABLE messages (body TEXT NOT NULL);');
      created.execute('INSERT INTO messages VALUES (?)', ['fixture message']);
    } finally {
      created.close();
    }
    expect(
      File(path).readAsBytesSync().take(16),
      isNot(orderedEquals('SQLite format 3\u0000'.codeUnits)),
    );
    final wrong = sqlite3.open(path);
    // This expected authentication failure must not corrupt --machine output
    // with native SQLCipher diagnostics on Linux runners.
    wrong.execute('PRAGMA cipher_log_level = NONE;');
    try {
      wrong.execute("PRAGMA key = 'wrong-fixture-key';");
      expect(
        () => wrong.select('SELECT body FROM messages;'),
        throwsA(isA<SqliteException>()),
      );
    } finally {
      wrong.execute('PRAGMA cipher_log_level = ERROR;');
      wrong.close();
    }
    final restored = sqlite3.open(path);
    try {
      restored.execute("PRAGMA key = '$key';");
      expect(
        restored.select('SELECT body FROM messages;').single['body'],
        'fixture message',
      );
    } finally {
      restored.close();
    }
  });
}
