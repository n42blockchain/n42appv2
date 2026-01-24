import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

class ChatApi{
  late String url;
  late Map<String,String> header;
  ChatApi(){
    url=AppConfig.getApiUrlOnline('imHttpHost');
    header={'content-type': 'application/json'};
  }
  ///   ---------------   消息    ---------------------
  Future<dynamic> msgList(
      int lastMsgId,
      ) async {
    Map<String, dynamic> params = {};
    params["last_msg_id"] = lastMsgId;
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/chat/msg/list', data: params, params: {},header: header,);
    return data;
  }

  //离线消息 不支持漫游
  Future<dynamic> offlineMsg() async {
    Map<String, dynamic> params = {};
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/chat/msg/offline', params: params, data: params,header: header,);
    return data;
  }

  // send message
  Future<dynamic> sendMessage(
      {required String fromUUID,
        required String receiveId,
        required String content}) async {
    Map<String, dynamic> params = {};
    params["content"] = content;
    params["from_uuid"] = fromUUID;
    params["receiver_uuid"] = receiveId;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/chat/send/one', params: params, data: params,header: header,);
    return data;
  }
  Future<dynamic> sendMessageRed({
    required String fromUUID,
    required String receiveId,
    required String content,
    required int count,
    required double value,
    required String txRaw,
    required int type,
    required String description,
  })async{
    Map<String, dynamic> params = {};
    params["content"] = content;
    params["from_uuid"] = fromUUID;
    params["receiver_uuid"] = receiveId;
    params["count"] = count;
    params["tx_raw"] = txRaw;
    params["value"] = value;
    params["type"] = type;
    params["description"] = description;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/red/send', params: params, data: params,header: header,);
    return data;
  }
  //获取红包详情
  Future<MessageModel> getRedDetails({
    required int messageId,
  })async{
    Map<String, dynamic> params = {
      "message_id":messageId,
      "Source":"app",
      "Uuid":AppGlobals.userInfo!.uuid,
      "Token":AppGlobals.userInfo!.token,
    };
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/red/details', params: params, data: params,header: header,);
    if(data['code']==200){
      MessageModel mm =MessageModel();
      mm.data=data['data'];
      return mm;
    }else{
      MessageModel mm=MessageModel.error();
      mm.data=data['msg'].toString();
      return mm;
    }
  }
  //领取红包
  Future<MessageModel> getRedReceive({
    required int messageId,
  })async{
    Map<String, dynamic> params = {
      "message_id":messageId,
      "Source":"app",
      "Uuid":AppGlobals.userInfo!.uuid,
      "Token":AppGlobals.userInfo!.token,
    };
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/red/receive', params: params, data: params,header: header,);
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
  Future<dynamic> friendAccept(
      String senderUuid, String targetUuid, String remarks) async {
    Map<String, dynamic> params = {};
    params["sender_uuid"] = senderUuid;
    params["target_uuid"] = targetUuid;
    params["remarks"] = remarks;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/friend/accept', params: params, data: params,header: header,);
    return data;
  }

  //reason 申请理由
  // remarks备注昵称
  // target_uuid 好友请求接收者的uuid
  Future<dynamic> friendAdd(String reason, String remarks, String senderUuid,
      String targetUuid) async {
    Map<String, dynamic> params = {};
    params["reason"] = reason;
    params["remarks"] = remarks;
    params["sender_uuid"] = senderUuid;
    params["target_uuid"] = targetUuid;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/friend/add', params: params, data: params,header: header,);
    return data;
  }

  //好友申请列表
  Future<dynamic> friendApplyList() async {
    Map<String, dynamic> params = {};
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/friend/apply/list', params: params, data: params,header: header,);
    return data;
  }

  //好友列表
  Future<dynamic> friendList() async {
    Map<String, dynamic> params = {};
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/friend/list', params: params, data: params,header: header,);
    return data;
  }

  //搜索好友
  Future<dynamic> searchFriend(String email) async {
    Map<String, dynamic> params = {};
    params["email"] = email;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/friend/search', params: params, data: params,header: header,);
    return data;
  }

  //获取用户信息
  Future<dynamic> getUserInfo(String userId) async {
    Map<String, dynamic> params = {};
    params["uuid"] = userId;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/user/info/get', params: params, data: params,header: header,);
    return data;
  }

  //删除好友
  Future<dynamic> deleteFriend(String userId) async {
    Map<String, dynamic> params = {};
    params["friend"] = userId;
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/friend/delete', params: {}, data: params,header: header,);
    return data;
  }

  //拉黑好友
  Future<dynamic> blockFriend(String friendId) async {
    Map<String, dynamic> params = {};
    params["friend"] = friendId;
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/friend/block', params: {}, data: params,header: header,);
    return data;
  }

  //移除黑名单
  Future<dynamic> removeBlockFriend(String friendId) async {
    Map<String, dynamic> params = {};
    params["friend"] = friendId;
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/friend/blacklist/remove', params: {}, data: params,header: header,);
    return data;
  }

  //查询当前用户的黑名单列表
  Future<dynamic> blockFriendList() async {
    Map<String, dynamic> params = {};
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/friend/blacklist', params: {}, data: params,header: header,);
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
  Future<dynamic> createGroup(String extra, String groupName,
      String introduction, String oUuid, List<String?> uuids) async {
    Map<String, dynamic> params = {};
    params["o_uuid"] = oUuid;
    params["members"] = uuids;
    params["introduction"] = introduction;
    params["group_name"] = groupName;
    params["extra"] = extra;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/group/create', params: params, data: params,header: header,);
    return data;
  }

  //查询群组信息
  Future<dynamic> groupInfo(String gid) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gid;
    params["m_uuid"] = AppGlobals.userInfo?.uuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/group/info/query', params: params, data: params,header: header,);
    return data;
  }

  //修改群组信息
  Future<dynamic> updateGroupInfo(
      {required String gIntroduction,
        required String gUuid,
        required String groupName,
        required String mUuid}) async {
    Map<String, dynamic> params = {};
    params["g_introduction"] = gIntroduction;
    params["g_uuid"] = gUuid;
    params["g_name"] = groupName;
    params["m_uuid"] = mUuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/group/info/update', params: params, data: params,header: header,);
    return data;
  }

  //添加群成员
  // "g_uuid": "string",
  // "inviter": "string",
  // "members": [
  // "string"
  // ]
  Future<dynamic> addGroupMembers(
      String gUuid, String inviter, List members) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["inviter"] = inviter;
    params["members"] = members;
    final data = await BaseApi.requestEmptyH
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
  Future<dynamic> deleteGroupMembers(String gUuid, List members) async {
    Map<String, dynamic> params = {};
    params["admin"] = AppGlobals.userInfo?.uuid;
    params["g_uuid"] = gUuid;
    params["members"] = members;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/group/members/delete', params: params, data: params,header: header,);
    return data;
  }

  //查询群组成员
  Future<dynamic> groupMembers(
      String gUuid,
      String mUuid,
      ) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["m_uuid"] = mUuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/group/members/query', params: params, data: params,header: header,);
    return data;
  }

  //解散群
  Future<dynamic> groupDisband(
      String gUuid,
      String mUuid,
      ) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["o_uuid"] = mUuid;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/group/disband', params: params, data: params,header: header,);
    return data;
  }

  //退出群聊
  Future<dynamic> leaveGroup(
      String gUuid,
      String mUuid,
      ) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["l_uuid"] = mUuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/group/user/leave', params: params, data: params,header: header,);
    return data;
  }

//群消息确认
  Future<dynamic> groupMsgAck(String gUuid, String mUuid, int seq) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["user_id"] = mUuid;
    params["seq"] = seq;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/group/msg/ack', params: params, data: params,header: header,);
    return data;
  }

  //拉取各个群的最后一条离线消息
  //测试 实际返回的群的最后一条消息，跟离线消息没有关系
  Future<dynamic> groupOfflineLastMsg() async {
    Map<String, dynamic> params = {};
    params["uuid"] = AppGlobals.userInfo?.uuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/group/msg/offline/last', params: params, data: params,header: header,);
    return data;
  }

  //拉取某个群的所有离线消息
  Future<dynamic> groupOfflineMsg(String gUuid, int lastSeq) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["last_seq"] = lastSeq;
    params["m_uuid"] = AppGlobals.userInfo?.uuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/group/msg/offline/total', params: params, data: params,header: header,);
    return data;
  }

  //创建群之后上传群成员秘文
  Future<dynamic> uploadGroupMemberSS(
      String gUuid, Map<String, dynamic> ssList) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["data"] = ssList;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/group/upload/ss', params: {}, data: params,header: header,);
    return data;
  }

  //查询用户在当前群中的SS
  Future<dynamic> checkGroupSSById(String gUuid) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["m_uuid"] = AppGlobals.userInfo?.uuid;
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/group/query/ss', params: params, data: params,header: header,);
    return data;
  }

  //从后往前拉取 这个接口主要是进入群聊时先调取一次最新消息，显示给用户
  //因为上边的群离线消息获取是从起始开始拉取 数据大会太过耗时
  Future<dynamic> getGroupOfflineLastMessage(String gUuid, int lastSeq) async {
    Map<String, dynamic> params = {};
    params["g_uuid"] = gUuid;
    params["last_seq"] = lastSeq;
    params["m_uuid"] = AppGlobals.userInfo?.uuid;
    params["msg_num"] = 100;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/group/msg/offline/part', params: params, data: params,header: header,);
    return data;
  }

  //举报用户违规
  Future<dynamic> reportUser(String reportReason,
      {int tag = 1,int? messageId, String? targetUuid}) async {
    Map<String, dynamic> params = {};
    params["message_id"] = messageId;
    params["reason"] = reportReason;
    params["uuid"] = AppGlobals.userInfo?.uuid;
    params["email"] = AppGlobals.userInfo?.email;
    params["tag"] = tag;
    params["target_uuid"] = targetUuid;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/chat/message/report', params: params, data: params,header: header,);
    return data;
  }
}
