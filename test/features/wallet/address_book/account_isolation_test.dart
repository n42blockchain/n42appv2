import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/address_book_api.dart';
import 'package:n42_wallet/features/wallet/models/address_book_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _DelayedDatabase extends AppDatabase {
  _DelayedDatabase(this.connection, this.gate);
  final Database connection;
  final Completer<void> gate;
  @override
  Future<Database> get database async {
    await gate.future;
    return connection;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppDatabase app;
  late Database db;
  late String owner;
  AddressBookApi api() =>
      AddressBookApi(database: app, currentOwner: () => owner);
  AddressBookModel entry(String name, String coin) => AddressBookModel()
    ..name = name
    ..coinName = coin
    ..address = 'address-$name'
    ..desc = 'note-$name';
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });
  setUp(() async {
    directory = Directory.systemTemp.createTempSync('address_owner_');
    await databaseFactory.setDatabasesPath(directory.path);
    app = AppDatabase();
    db = await app.database;
    owner = 'DXX';
  });
  tearDown(() async {
    await db.close();
    await directory.delete(recursive: true);
  });
  test(
    'switching accounts isolates list, coin filter, search, update and delete',
    () async {
      final a = api();
      final private = entry('xing01', 'BTC');
      private.id = await a.saveAddressBookItem(private);
      owner = 'xing01';
      final b = api();
      expect(await b.getAddressBookList(''), isEmpty);
      expect(await b.getAddressBookList('BTC'), isEmpty);
      expect(await b.searchAddressBook('xing01'), isEmpty);
      expect(await b.searchAddressBook(''), isEmpty);
      private.name = 'forged edit';
      expect(await b.updateAddressBookItem(private), 0);
      expect(await b.deleteAddressBookItem(private), 0);
      final own = entry('personal', 'ETH');
      own.id = await b.saveAddressBookItem(own);
      expect((await b.getAddressBookList('')).single.name, 'personal');
      expect((await b.searchAddressBook('note-')).single.name, 'personal');
      await expectLater(
        a.saveAddressBookItem(entry('stale', 'BTC')),
        throwsStateError,
      );
      owner = 'DXX';
      expect((await a.getAddressBookList('BTC')).single.name, 'xing01');
      private.name = 'renamed';
      expect(await a.updateAddressBookItem(private), 1);
      expect(await a.deleteAddressBookItem(private), 1);
      owner = 'xing01';
      expect((await b.getAddressBookList('')).single.name, 'personal');
    },
  );
  test('v7 migration preserves unattributed records without assigning them to a login', () async {
    await db.close();
    final path = '${directory.path}/astranet.db';
    await databaseFactory.deleteDatabase(path);
    final old = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 7,
        onCreate: (db, _) => db.execute(
          'CREATE TABLE AddressBook(id INTEGER PRIMARY KEY, coinIcon TEXT, coinName TEXT, address TEXT, name TEXT, desc TEXT)',
        ),
      ),
    );
    await old.insert('AddressBook', entry('legacy-private', 'BTC').toJson());
    await old.close();
    app = AppDatabase();
    db = await app.database;
    expect((await db.query('AddressBook')).single['userUuid'], isNull);
    for (final account in ['DXX', 'xing01', 'AstranetWallet']) {
      owner = account;
      expect(await api().getAddressBookList(''), isEmpty);
      expect(await api().searchAddressBook('legacy'), isEmpty);
    }
  });
  test(
    'account switch during database acquisition prevents reads and writes',
    () async {
      for (final write in [false, true]) {
        owner = 'DXX';
        final gate = Completer<void>();
        final delayed = AddressBookApi(
          database: _DelayedDatabase(db, gate),
          currentOwner: () => owner,
        );
        final operation = write
            ? delayed.saveAddressBookItem(entry('late', 'BTC'))
            : delayed.getAddressBookList('');
        final rejected = expectLater(operation, throwsStateError);
        owner = 'xing01';
        gate.complete();
        await rejected;
      }
      expect(await db.query('AddressBook'), isEmpty);
    },
  );
}
