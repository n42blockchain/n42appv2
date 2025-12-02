import 'dart:convert';

import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_data.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';
import 'package:n42appv2/src/chat/models/group_member_info.dart';
import 'package:n42appv2/src/utils/sp_util.dart';

class ChatSPUtil {

  //保存用户好友列表
  Future saveFriendsList(List<FriendInfo> list) async {
    final chatCacheKey = "${Application.userInfo?.uuid}_friend_list";
    return await SPUtil().putObject(chatCacheKey, list);
  }

  //获取用户好友列表
  Future<List<FriendInfo>> getFriendList() async {
    final chatCacheKey = "${Application.userInfo?.uuid}_friend_list";
    Object? cacheData = await SPUtil().getListObject(chatCacheKey);

    if (cacheData != null && cacheData is List) {
      return cacheData.map((e) => FriendInfo.fromJson(e)).toList();
    }
    return [];
  }

  //根据friend id 查FriendInfo
  Future<FriendInfo?> getFriendInfoById(String id) async {
    final list = await getFriendList();
    for (FriendInfo info in list) {
      if (info.uuid == id) {
        return info;
      }
    }
    return null;
  }

  //保存或者更新FriendInfo
  Future saveOrUpdateFriendInfo(FriendInfo info) async {
    final chatCacheKey = "${Application.userInfo?.uuid}_friend_list";
    final list = await getFriendList();
    int index = list.indexWhere((element) => element.uuid == info.uuid);
    if (index != -1) {
      // 更新数据
      list[index] = info;
    } else {
      // 保存数据list
      list.add(info);
    }
    return await SPUtil().putObject(chatCacheKey, list);
  }

  //保存群组信息 这个不区分用户 主要是为了查询群组信息方便而使用
  Future saveOrUpdateGroupInfo(GroupInfo info) async {
    const groupListKey = "groupList";
    final list = await getGroupList();
    //查看缓存中是否已经存在当前群组信息
    int index = list.indexWhere((element) => element.g_uuid == info.g_uuid);
    if (index != -1) {
      // 更新数据
      list[index] = info;
    } else {
      // 保存数据list
      list.add(info);
    }
    return await SPUtil().putObject(groupListKey, list);
  }

  //获取group list
  Future<List<GroupInfo>> getGroupList() async {
    const groupListKey = "groupList";
    Object? cacheData = await SPUtil().getListObject(groupListKey);
    if (cacheData != null && cacheData is List) {
      return cacheData.map((e) => GroupInfo.fromJson(e)).toList();
    }
    return [];
  }

  //根据group id 查找group info
  Future<GroupInfo?> getGroupInfoById(String groupId) async {
    final list = await getGroupList();
    for (GroupInfo info in list) {
      if (info.g_uuid == groupId) {
        return info;
      }
    }
    return null;
  }

  //保存群成员
  Future saveGroupMembers(
      String groupId, List<GroupMemberInfo> list) async {
    final chatCacheKey = "${groupId}_group_members";
    return await SPUtil().putObject(chatCacheKey, list);
  }

  //获取群成员
  Future<List<GroupMemberInfo>> getGroupMembersById(
      String groupId) async {
    final chatCacheKey = "${groupId}_group_members";
    Object? cacheData = await SPUtil().getListObject(chatCacheKey);
    if (cacheData != null && cacheData is List) {
      return cacheData.map((e) => GroupMemberInfo.fromJson(e)).toList();
    }
    return [];
  }

  //保存群密码信息
  Future<void> saveGroupDataIfNotExists(GroupData groupData) async {
    final groupDataListJson = SPUtil().prefs?.getStringList('groupPwdDataList') ?? [];

    // 检查是否已经存在相同的groupId
    final exists = groupDataListJson.any((jsonString) {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      final existingGroupData = GroupData.fromMap(map);
      return existingGroupData.groupId == groupData.groupId;
    });

    if (!exists) {
      // 如果不存在相同的groupId，则保存新的GroupData对象
      final newGroupDataMap = groupData.toMap();
      groupDataListJson.add(jsonEncode(newGroupDataMap));
      await SPUtil().prefs?.setStringList('groupPwdDataList', groupDataListJson);
    }
  }

  //获取群密码信息
  Future<GroupData?> getGroupDataByGroupId(String groupId) async {
    final groupDataListJson = SPUtil().prefs?.getStringList('groupPwdDataList') ?? [];

    for (final jsonString in groupDataListJson) {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      final existingGroupData = GroupData.fromMap(map);
      if (existingGroupData.groupId == groupId) {
        return existingGroupData;
      }
    }

    return null; // 未找到匹配的groupId
  }

  ///-------在删除好友时 仍然需要展示用户信息 所以增加以下缓存------------

  //获取本机缓存的用户信息，只存不删
  //不需要区分账号 切换账号仍然可以快速从本地缓存中取出信息展示
  Future<List<FriendInfo>> getNavUserInfoList() async {
    const chatCacheKey = "chat_user_list";
    Object? cacheData = await SPUtil().getListObject(chatCacheKey);
    if (cacheData != null && cacheData is List) {
      return cacheData.map((e) => FriendInfo.fromJson(e)).toList();
    }
    return [];
  }

  //根据user_id 查user_id
  Future<FriendInfo?> getNavUserInfo(String id) async {
    final list = await getNavUserInfoList();
    for (FriendInfo info in list) {
      if (info.uuid == id) {
        return info;
      }
    }
    return null;
  }
  //根据user_id 查user_id
  Future<FriendInfo?> getNavUserInfo_remark(String id) async {
    final list = await getFriendList();
    for (FriendInfo info in list) {
      if (info.uuid == id) {
        return info;
      }
    }
    return null;
  }

  //保存或者更新userInfo
  Future saveOrUpdateUserInfo(FriendInfo info) async {
    try {
      const chatCacheKey = "chat_user_list";
      final list = await getNavUserInfoList();
      int index = list.indexWhere((element) => element.uuid == info.uuid);
      if (index != -1) {
        // 更新数据
        list[index] = info;
      } else {
        // 保存数据list
        list.add(info);
      }
      return await SPUtil().putObject(chatCacheKey, list);
    } catch (err) {
      //err
    }
  }
}