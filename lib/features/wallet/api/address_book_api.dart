import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/models/address_book_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:n42_wallet/core/app/app_globals.dart';

class AddressBookApi {
  AddressBookApi({AppDatabase? database, String Function()? currentOwner})
    : appDatabase = database ?? AppDatabase(),
      _currentOwner = currentOwner ?? (() => AppGlobals.walletStorageUuid) {
    ownerUuid = _currentOwner();
    if (ownerUuid.isEmpty) throw StateError('Address book owner required');
  }
  final AppDatabase appDatabase;
  final String Function() _currentOwner;
  late final String ownerUuid;
  bool get isOwnerCurrent => _currentOwner() == ownerUuid;
  void _checkOwner() {
    if (!isOwnerCurrent) throw StateError('Address book account changed');
  }

  Future<Database> _database() async {
    _checkOwner();
    final db = await appDatabase.database;
    _checkOwner();
    return db;
  }

  ///保存数据
  Future<int> saveAddressBookItem(AddressBookModel info) async {
    Database db = await _database();
    var raw = await db.insert("AddressBook", {
      ...info.toJson(),
      'userUuid': ownerUuid,
    }, conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }

  ///列表查询
  Future<List<AddressBookModel>> getAddressBookList(String coinName) async {
    final db = await _database();
    var response = await db.query(
      "AddressBook",
      where: coinName == "" ? "userUuid = ?" : "userUuid = ? AND coinName = ?",
      whereArgs: coinName == "" ? [ownerUuid] : [ownerUuid, coinName],
    );
    _checkOwner();
    List<AddressBookModel> list = response
        .map((c) => AddressBookModel.fromJson(c))
        .toList();
    return list;
  }

  ///更新数据
  Future<int> updateAddressBookItem(AddressBookModel info) async {
    final db = await _database();
    var raw = await db.update(
      "AddressBook",
      {...info.toJson(), 'userUuid': ownerUuid},
      where: "id = ? AND userUuid = ?",
      whereArgs: [info.id, ownerUuid],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
    return raw;
  }

  ///删除数据
  Future<int> deleteAddressBookItem(AddressBookModel info) async {
    final db = await _database();
    var raw = await db.delete(
      "AddressBook",
      where: "id = ? AND userUuid = ?",
      whereArgs: [info.id, ownerUuid],
    );
    return raw;
  }

  /// 全文搜索（名称、备注、地址模糊匹配）
  Future<List<AddressBookModel>> searchAddressBook(String query) async {
    final db = await _database();
    final q = '%$query%';
    final response = await db.query(
      'AddressBook',
      where: 'userUuid = ? AND (name LIKE ? OR desc LIKE ? OR address LIKE ?)',
      whereArgs: [ownerUuid, q, q, q],
    );
    _checkOwner();
    return response.map((c) => AddressBookModel.fromJson(c)).toList();
  }
}
