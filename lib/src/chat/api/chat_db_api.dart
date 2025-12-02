import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:sqflite/sqflite.dart';

class ChatDBApi{
  AppDatabase? _appDatabase;
  AppDatabase get appDatabase{
    if(_appDatabase==null) {
      _appDatabase=AppDatabase();
    }
    return _appDatabase!;
  }
  ///保存数据
  Future<int> saveMessage(ChatMessageModel info) async {
    Database db = await appDatabase.database;
    final userId = Application.userInfo?.uuid;
    Map<String, dynamic> map = info.toMap();
    map["user_id"] = userId;
    var raw = await db.insert("Messages", map,
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }

  ///会话列表查询
  Future<List<Map<String, dynamic>>> getChatConversations() async {
    Database db = await appDatabase.database;
    String userId = Application.userInfo?.uuid ?? '';
    return await db.rawQuery('''
    SELECT m.*
    FROM Messages m
    JOIN (
        SELECT MAX(timestamp) AS last_timestamp,
               targetId
        FROM Messages
        WHERE user_id = ?
        GROUP BY targetId
    ) last_msgs ON m.timestamp = last_msgs.last_timestamp AND m.targetId = last_msgs.targetId
    WHERE m.user_id = ?
    ORDER BY m.timestamp DESC;
  ''', [userId, userId]);
  }

  ///根据 fromUuid 和  targetUuid
  ///查询聊天详情 可以查个人或者群消息
  /// 这种分页的查询方式在一边聊天 一边查询时 会导致加载数据时重复展示
  // static Future<List<ChatMessageModel>?> getChatDetailByFromAndTarget(
  //   String targetUuid,
  //   int pageIndex, {
  //   int pageSize = 20,
  // }) async {
  //   Database db = await WalletDatabaseProvider.dbProvider.database;
  //   int offset = pageIndex * pageSize;
  //   debugPrint("offset===:$offset");
  //   String userId = Application.userInfo?.uuid ?? '';
  //   var response = await db.query(
  //     "Messages",
  //     columns: null,
  //     where: "user_id = ? and targetId = ?",
  //     whereArgs: [userId, targetUuid],
  //     orderBy: 'timestamp DESC',
  //     limit: pageSize,
  //     offset: offset,
  //   );
  //   if (response.isNotEmpty) {
  //     List<ChatMessageModel> list =
  //         response.map((c) => ChatMessageModel.fromDBMap(c)).toList();
  //     return list;
  //   }
  //   return null;
  // }

  Future<List<ChatMessageModel>?> getChatDetailByFromAndTarget(
      String targetUuid,
      int lastMessageTimestamp, // 添加一个参数来表示上次加载的最后一条消息的时间戳
          {
        int pageSize = 20,
      }) async {
    Database db = await appDatabase.database;
    String userId = Application.userInfo?.uuid ?? '';
    var response = await db.query(
      "Messages",
      columns: null,
      where: "user_id = ? and targetId = ?",
      whereArgs: [userId, targetUuid, ],
      // 仅获取时间戳小于上次加载的消息时间戳的消息
      orderBy: 'timestamp DESC',
      limit: pageSize,
    );
    /*var response = await db.query(
      "Messages",
      columns: null,
      where: "user_id = ? and targetId = ? and timestamp < ?",
      whereArgs: [userId, targetUuid, lastMessageTimestamp],
      // 仅获取时间戳小于上次加载的消息时间戳的消息
      orderBy: 'timestamp DESC',
      limit: pageSize,
    );*/
    if (response.isNotEmpty) {
      List<ChatMessageModel> list =
      response.map((c) {
        ChatMessageModel cmm=ChatMessageModel.fromDBMap(c);
        return cmm;
      }).toList();
      return list;
    }
    return null;
  }

  ///删除聊天记录
  Future<int> deleteMessageByTargetId(
      String targetUuid,
      ) async {
    Database db = await appDatabase.database;
    String userId = Application.userInfo?.uuid ?? '';
    var raw = await db.delete(
      "Messages",
      where: "user_id = ? and targetId = ?",
      whereArgs: [userId, targetUuid],
    );
    return raw;
  }

  /// 根据message_id查询单条消息
  Future<ChatMessageModel?> getMessageByMessageId(int messageId) async {
    Database db = await appDatabase.database;
    var response = await db.query(
      "Messages",
      where: "messageId = ?",
      whereArgs: [messageId],
    );
    if (response.isNotEmpty) {
      List<ChatMessageModel> list =
      response.map((c) => ChatMessageModel.fromDBMap(c)).toList();
      return list.first;
    }
    return null;
  }

  ///更新数据单个消息数据
  Future<int> updateMessage(ChatMessageModel info) async {
    Database db = await appDatabase.database;
    var raw = await db.update("Messages", info.toMap(),
        where: "messageId = ?",
        whereArgs: [info.messageId],
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }

  ///删除某个消息
  Future<int> deleteMessage(ChatMessageModel info) async {
    Database db = await appDatabase.database;
    var raw = await db.delete(
      "Messages",
      where: "messageId = ?",
      whereArgs: [info.messageId],
    );
    return raw;
  }
}