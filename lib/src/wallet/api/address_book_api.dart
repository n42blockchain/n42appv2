import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/wallet/models/address_book_model.dart';
import 'package:sqflite/sqflite.dart';

class AddressBookApi{
  AppDatabase? _appDatabase;
  AppDatabase get appDatabase{
    if(_appDatabase==null){
      _appDatabase=AppDatabase();
    }
    return _appDatabase!;
  }
  ///保存数据
  Future<int> saveAddressBookItem(AddressBookModel info) async {
    Database db = await appDatabase.database;
    var raw = await db.insert("AddressBook", info.toJson(),
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }
  ///列表查询
  Future<List<AddressBookModel>> getAddressBookList(String coinName) async {
    final db = await appDatabase.database;
    var response = await db.query("AddressBook",where: coinName==""?"1=1":"coinName = '${coinName}'");
    List<AddressBookModel> list = response.map((c) => AddressBookModel.fromJson(c)).toList();
    return list;
  }
  ///更新数据
  Future<int> updateAddressBookItem(AddressBookModel info) async {
    final db = await appDatabase.database;
    var raw = await db.update("AddressBook", info.toJson(),
        where: "id = ?", whereArgs: [info.id],
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }
  ///删除数据
  Future<int> deleteAddressBookItem(AddressBookModel info) async {
    final db = await appDatabase.database;
    var raw = await db.delete("AddressBook",
      where: "id = ?", whereArgs: [info.id],);
    return raw;
  }
}
