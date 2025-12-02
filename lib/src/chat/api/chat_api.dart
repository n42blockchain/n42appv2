import 'dart:convert';

import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

class ChatApi{
  late String url;
  late Map<String,String> header;
  ChatApi(){
    url=AppConfig.getApiUrl_online('imHttpHost');
    header={'content-type': 'application/json'};
  }
  ///   ---------------   消息    ---------------------
  Future msgList(
      int last_msg_id,
      ) async {
    Map<String, dynamic> params = {};
    params["last_msg_id"] = last_msg_id;
    params["uuid"] = Application.userInfo?.uuid;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/chat/msg/list', data: params, params: {},header: header,);
    return data;
  }

  //离线消息 不支持漫游
  Future offlineMsg() async {
    Map<String, dynamic> params = {};
    params["uuid"] = Application.userInfo?.uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/chat/msg/offline', params: params, data: params,header: header,);
    return data;
  }

  // send message
  Future sendMessage(
      {required String fromUUID,
        required String receiveId,
        required String content}) async {
    Map<String, dynamic> params = {};
    params["content"] = content;
    params["from_uuid"] = fromUUID;
    params["receiver_uuid"] = receiveId;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/chat/send/one', params: params, data: params,header: header,);
    return data;
  }
  Future sendMessage_red({
    required String fromUUID,
    required String receiveId,
    required String content,
    required int count,
    required double value,
    required String tx_raw,
    required int type,
    required String description,
  })async{
    Map<String, dynamic> params = {};
    params["content"] = content;
    params["from_uuid"] = fromUUID;
    params["receiver_uuid"] = receiveId;
    params["count"] = count;
    params["tx_raw"] = tx_raw;
    params["value"] = value;
    params["type"] = type;
    params["description"] = description;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/red/send', params: params, data: params,header: header,);
    return data;
  }
  //获取红包详情
  Future getRedDetails({
    required int messageId,
  })async{
    Map<String, dynamic> params = {
      "message_id":messageId,
      "Source":"app",
      "Uuid":Application.userInfo!.uuid,
      "Token":Application.userInfo!.token,
    };
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/red/details', params: params, data: params,header: header,);
    if(data['code']==200){
      MessageModel mm =MessageModel();
      mm.data=data['data'];
      return mm;
    }else{
      MessageModel mm=MessageModel.error();
      mm.data=data['msg'].toString();
      return mm;
    }
    return data;
  }
  //领取红包
  Future getRedReceive({
    required int messageId,
  })async{
    Map<String, dynamic> params = {
      "message_id":messageId,
      "Source":"app",
      "Uuid":Application.userInfo!.uuid,
      "Token":Application.userInfo!.token,
    };
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/red/receive', params: params, data: params,header: header,);
    if(data['code']==200){
      MessageModel rmm=MessageModel();
      rmm.data=data['data'];
      return rmm;
    }else{
      MessageModel rmm=MessageModel.error();
      rmm.data=data['msg'];
      return rmm;
    }
  }


  ///   ---------------   好友    ---------------------
  // 同意
  Future friendAccept(
      String sender_uuid, String target_uuid, String remarks) async {
    Map<String, dynamic> params = {};
    params["sender_uuid"] = sender_uuid;
    params["target_uuid"] = target_uuid;
    params["remarks"] = remarks;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/friend/accept', params: params, data: params,header: header,);
    return data;
  }

  //reason 申请理由
  // remarks备注昵称
  // target_uuid 好友请求接收者的uuid
  Future friendAdd(String reason, String remarks, String sender_uuid,
      String target_uuid) async {
    Map<String, dynamic> params = {};
    params["reason"] = reason;
    params["remarks"] = remarks;
    params["sender_uuid"] = sender_uuid;
    params["target_uuid"] = target_uuid;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/friend/add', params: params, data: params,header: header,);
    return data;
  }

  //好友申请列表
  Future friendApplyList() async {
    Map<String, dynamic> params = {};
    params["uuid"] = Application.userInfo?.uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/friend/apply/list', params: params, data: params,header: header,);
    return data;
  }

  //好友列表
  Future friendList() async {
    Map<String, dynamic> params = {};
    params["uuid"] = Application.userInfo?.uuid;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/friend/list', params: params, data: params,header: header,);
    return data;
  }

  //搜索好友
  Future searchFriend(String email) async {
    Map<String, dynamic> params = {};
    params["email"] = email;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/friend/search', params: params, data: params,header: header,);
    return data;
  }

  //获取用户信息
  Future getUserInfo(String user_id) async {
    Map<String, dynamic> params = {};
    params["uuid"] = user_id;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/user/info/get', params: params, data: params,header: header,);
    return data;
  }

  //删除好友
  Future deleteFriend(String user_id) async {
    Map<String, dynamic> params = {};
    params["friend"] = user_id;
    params["uuid"] = Application.userInfo?.uuid;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/friend/delete', params: {}, data: params,header: header,);
    return data;
  }

  //拉黑好友
  Future blockFriend(String friendId) async {
    Map<String, dynamic> params = {};
    params["friend"] = friendId;
    params["uuid"] = Application.userInfo?.uuid;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/friend/block', params: {}, data: params,header: header,);
    return data;
  }

  //移除黑名单
  Future removeBlockFriend(String friendId) async {
    Map<String, dynamic> params = {};
    params["friend"] = friendId;
    params["uuid"] = Application.userInfo?.uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/friend/blacklist/remove', params: {}, data: params,header: header,);
    return data;
  }

  //查询当前用户的黑名单列表
  Future blockFriendList() async {
    Map<String, dynamic> params = {};
    params["uuid"] = Application.userInfo?.uuid;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/friend/blacklist', params: {}, data: params,header: header,);
    return data;
  }

  ///   ---------------   群组    ---------------------

  // extra	string
  // 附加字段
  // group_name*	string
  // 群组名称
  // introduction	string
  // 群简介
  // members*	[
  // 群成员，数量必须大于2
  // string]
  // o_uuid*	string
  //创建群组
  Future createGroup(String extra, String group_name,
      String introduction, String o_uuid, List<String?> uuids) async {
    Map<String, dynamic> params = {};
    params["o_uuid"] = o_uuid;
    params["members"] = uuids;
    params["introduction"] = introduction;
    params["group_name"] = group_name;
    params["extra"] = extra;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/group/create', params: params, data: params,header: header,);
    return data;
  }

  //查询群组信息
  Future groupInfo(String gid) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gid;
    params["m_uuid"] = Application.userInfo?.uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/info/query', params: params, data: params,header: header,);
    return data;
  }

  //修改群组信息
  Future updateGroupInfo(
      {required String g_introduction,
        required String g_uuid,
        required String group_name,
        required String m_uuid}) async {
    Map<String, dynamic> params = {};
    params["g_introduction"] = g_introduction;
    params["g_uuid"] = g_uuid;
    params["g_name"] = group_name;
    params["m_uuid"] = m_uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/info/update', params: params, data: params,header: header,);
    return data;
  }

  //添加群成员
  // "g_uuid": "string",
  // "inviter": "string",
  // "members": [
  // "string"
  // ]
  Future addGroupMembers(
      String g_uuid, String inviter, List members) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["inviter"] = inviter;
    params["members"] = members;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/members/add', params: params, data: params,header: header,);
    return data;
  }

  //移除群成员
  // {
  //   "admin": "string",
  //   "g_uuid": "string",
  //   "members": [
  //     "string"
  //   ]
  // }
  Future deleteGroupMembers(String g_uuid, List members) async {
    Map<String, dynamic> params = {};
    params["admin"] = Application.userInfo?.uuid;
    params["g_uuid"] = g_uuid;
    params["members"] = members;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/members/delete', params: params, data: params,header: header,);
    return data;
  }

  //查询群组成员
  Future groupMembers(
      String g_uuid,
      String m_uuid,
      ) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["m_uuid"] = m_uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/members/query', params: params, data: params,header: header,);
    return data;
  }

  //解散群
  Future groupDisband(
      String g_uuid,
      String m_uuid,
      ) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["o_uuid"] = m_uuid;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/group/disband', params: params, data: params,header: header,);
    return data;
  }

  //退出群聊
  Future leaveGroup(
      String g_uuid,
      String m_uuid,
      ) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["l_uuid"] = m_uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/user/leave', params: params, data: params,header: header,);
    return data;
  }

//群消息确认
  Future groupMsgAck(String g_uuid, String m_uuid, int seq) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["user_id"] = m_uuid;
    params["seq"] = seq;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/group/msg/ack', params: params, data: params,header: header,);
    return data;
  }

  //拉取各个群的最后一条离线消息
  //测试 实际返回的群的最后一条消息，跟离线消息没有关系
  Future groupOfflineLastMsg() async {
    Map<String, dynamic> params = {};
    params["uuid"] = Application.userInfo?.uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/msg/offline/last', params: params, data: params,header: header,);
    return data;
  }

  //拉取某个群的所有离线消息
  Future groupOfflineMsg(String g_uuid, int last_seq) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["last_seq"] = last_seq;
    params["m_uuid"] = Application.userInfo?.uuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/msg/offline/total', params: params, data: params,header: header,);
    return data;
  }

  //创建群之后上传群成员秘文
  Future uploadGroupMemberSS(
      String g_uuid, Map<String, dynamic> ssList) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["data"] = ssList;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/group/upload/ss', params: {}, data: params,header: header,);
    return data;
  }

  //查询用户在当前群中的SS
  Future checkGroupSSById(String g_uuid) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["m_uuid"] = Application.userInfo?.uuid;
    final data =
    await BaseApi.RequestEmpty_h.post('$url/v1/group/query/ss', params: params, data: params,header: header,);
    return data;
  }

  //从后往前拉取 这个接口主要是进入群聊时先调取一次最新消息，显示给用户
  //因为上边的群离线消息获取是从起始开始拉取 数据大会太过耗时
  Future getGroupOfflineLastMessage(String g_uuid, int last_seq) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = g_uuid;
    params["last_seq"] = last_seq;
    params["m_uuid"] = Application.userInfo?.uuid;
    params["msg_num"] = 100;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/group/msg/offline/part', params: params, data: params,header: header,);
    return data;
  }

  //举报用户违规
  Future reportUser(String reportReason,
      {int tag = 1,int? messageId, String? targetUuid}) async {
    Map<String, dynamic> params = {};
    params["message_id"] = messageId;
    params["reason"] = reportReason;
    params["uuid"] = Application.userInfo?.uuid;
    params["email"] = Application.userInfo?.email;
    params["tag"] = tag;
    params["target_uuid"] = targetUuid;
    final data = await BaseApi.RequestEmpty_h
        .post('$url/v1/chat/message/report', params: params, data: params,header: header,);
    return data;
  }
}