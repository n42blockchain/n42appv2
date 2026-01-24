import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/storage/sp_util.dart';

class CacheMessageIsReadUtils {
  Future<bool> saveUnReadMessageId(String uuid) async {
    SPUtil sPUtils=SPUtil();
    final cacheList = await sPUtils.getListObject(generateSpKey());
    Set messageIds = {};
    if (cacheList != null && cacheList is List) {
      messageIds = cacheList.toSet();
    }
    messageIds.add(uuid);
    return await sPUtils.putObject(generateSpKey(), messageIds.toList());
  }

  Future<bool> removeUnReadMessageId(String uuid) async {
    SPUtil sPUtils=SPUtil();
    final cacheList = await sPUtils.getListObject(generateSpKey());
    Set messageIds = {};
    if (cacheList != null && cacheList is List) {
      messageIds = cacheList.toSet();
      messageIds.remove(uuid);
    }
    return await sPUtils.putObject(generateSpKey(), messageIds.toList());
  }

  Future<bool> isRead(String uuid) async {
    final cacheList = await SPUtil().getListObject(generateSpKey());
    Set messageIds = {};
    if (cacheList != null && cacheList is List) {
      messageIds = cacheList.toSet();
    }
    return !messageIds.contains(uuid);
  }


  Future<Object?> getUnReadIds() async {
    return await SPUtil().getListObject(generateSpKey());
  }


  String generateSpKey() {
    return "${AppGlobals.userInfo?.uuid}_message_read_list";
  }
}

//处理@功能工具
class CacheGroupMentionUtils {
  String generateSpKey() {
    return "${AppGlobals.userInfo?.uuid}_mention_list";
  }

  Future<bool> saveMentionGroupId(String groupId) async {
    SPUtil sPUtils=SPUtil();
    final cacheList = await sPUtils.getListObject(generateSpKey());
    Set messageIds = {};
    if (cacheList != null && cacheList is List) {
      messageIds = cacheList.toSet();
    }
    messageIds.add(groupId);
    return await sPUtils.putObject(generateSpKey(), messageIds.toList());
  }

  Future<bool> removeMentionGroupId(String groupId) async {
    SPUtil sPUtils=SPUtil();
    final cacheList = await sPUtils.getListObject(generateSpKey());
    Set messageIds = {};
    if (cacheList != null && cacheList is List) {
      messageIds = cacheList.toSet();
      messageIds.remove(groupId);
    }
    return await sPUtils.putObject(generateSpKey(), messageIds.toList());
  }

  //当前group是否@了我
  Future<bool> isMention(String groupId) async {
    SPUtil sPUtils=SPUtil();
    final cacheList = await sPUtils.getListObject(generateSpKey());
    Set messageIds = {};
    if (cacheList != null && cacheList is List) {
      messageIds = cacheList.toSet();
    }
    return messageIds.contains(groupId);
  }
}