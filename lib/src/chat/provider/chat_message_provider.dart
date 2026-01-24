import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_apply_info.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';
import 'package:n42appv2/src/chat/utils/cache_read_message_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_data_util.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:flutter/material.dart';

class ChatMessageProvider extends ChangeNotifier {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  ChatDataUtil? _chatDataUtil;
  ChatDataUtil get chatDataUtil{
    _chatDataUtil ??= ChatDataUtil();
    return _chatDataUtil!;
  }
  ChatDBApi? _chatDBApi;
  ChatDBApi get chatDBApi{
    _chatDBApi ??= ChatDBApi();
    return _chatDBApi!;
  }
  ChatSPUtil? _chatSPUtil;
  ChatSPUtil get chatSPUtil{
    _chatSPUtil ??= ChatSPUtil();
    return _chatSPUtil!;
  }
  int _haveNewFriend = 0;

  int get haveNewFriend => _haveNewFriend;

  void setNewFriendStatus(int flag) {
    _haveNewFriend= flag;
    notifyListeners();
  }
  void setNewFriendStatusAdd(){
    _haveNewFriend++;
    notifyListeners();
  }

  List<ChatMessageModel> _chatConversationList = [];

  Future<void> setChatConversationList(List<ChatMessageModel> list) async{
    _chatConversationList = list;
    updateUnReadMessNum();
    notifyListeners();
  }


  List<ChatMessageModel> get chatConversationList => _chatConversationList;

  //当前打开的聊天对象的uuid
  String? currOpenChatTargetUuid;

  void setTargetUuid(String? uuid) {
    currOpenChatTargetUuid = uuid;
  }


  //未读消息的数（有几个联系人的消息未读，并不是总计多少条消息未读）
  int _unReadMessageUUIDs = 0;
  int  get unReadMessageUUIDs => _unReadMessageUUIDs;

  void setUnReadMessIdNum(int num) {
    _unReadMessageUUIDs = num;
    notifyListeners();
  }

  Future<void> updateUnReadMessNum() async{
    ///更新table角标未读消息数
    _unReadMessageUUIDs = 0;
    final unReadIds = await CacheMessageIsReadUtils().getUnReadIds();
    if (unReadIds != null && unReadIds is List) {
      int count = 0;
      for (var element in _chatConversationList) {
        if(unReadIds.contains(element.targetId)){
          count++;
        }
      }
      _unReadMessageUUIDs = count;
      notifyListeners();
    }
    debugPrint("_unReadMessageUUIDs:$_unReadMessageUUIDs");
  }


  //应用启动时 初始化一些聊天所需要的数据
  //例如：获取好友列表 更新缓存
  Future<void> initData() async {
    try {
      //更新好友信息
      await upDateFriendList();

      //获取离线消息
      await initOffLineMessage();
    } catch (err) {
      debugPrint("ChatMessageProvider init err:${err.toString()}");
    }
  }

  Future<void> upDateFriendList() async {
    try {
      final data = await chatApi.friendList();
      if (data != null && data["code"] == 200) {
        List<FriendInfo> list =
        (data["data"] as List).map((e) => FriendInfo.fromJson(e)).toList();
        // 返回列表中 把自己排除在外
        list.removeWhere(
                (element) => element.uuid == AppGlobals.userInfo?.uuid);
        //本地缓存好友列表
        final flag = await chatSPUtil.saveFriendsList(list);
        if (flag) {
          debugPrint("---保存好友列表成功----");
        }
      }
    } catch (err) {
      // err
    }
  }

  //查询会话列表
  Future<void> getChatConversationList() async {
    final list = await chatDBApi.getChatConversations();
    // debugPrint("会话列表查询 list：$list");
    List<ChatMessageModel> msgList =
    list.map((e) => ChatMessageModel.fromDBMap(e)).toList();
    debugPrint("会话列表查询 msgList length：${msgList.length}");
    // debugPrint("会话列表查询 msgList data：${json.encode(msgList)}");
    _chatConversationList = msgList;
    try {
      await updateChatConversationList();
    } catch (err) {
      debugPrint("updateChatConversationList err:${err.toString()}");
    }
  }

  //获取离线消息 保存数据库
  Future<void> initOffLineMessage() async {
    await getSingleChatOfflineData();
    await getGroupOfflineMessage();

    //更新好友申请状态
    updateNewFriendStatus();
  }

  Future<void> updateNewFriendStatus() async {
    try{
      final data = await chatApi.friendApplyList();
      if (data != null && data["code"] == 200) {
        List<FriendApplyInfo> friendList = (data["data"] as List)
            .map((e) => FriendApplyInfo.fromJson(e))
            .toList();
        int index = 0;
        for (var element in friendList) {
          if (element.status == 0 && element.direction == 0) {
            index++;
            //申请添加我为好友并且本人没有同意
            //可以设置一个过期时间
            //int? time = element.createTime;
            //判断是否超过7天 todo
            //index = friendList.indexOf(element);
          }
        }

        //ChatSPUtils().setNewFriendStatus(index != -1);
        setNewFriendStatus(index);
      }
    }catch(err){
      //err:
      debugPrint("updateNewFriendStatus err:${err.toString()}");
    }
  }

  //获取单聊的离线消息
  Future<void> getSingleChatOfflineData() async {
    try {
      //单聊离线消息
      final offlineData = await chatApi.offlineMsg();
      // {message_id: 6487189513904083,
      // code: 100,
      // content: eyJmcm9tIjoiODMyODBhZDktYzE0Zi00Nzk0LWI3MzQtOWQ5M2Y4ZjZkMTg3IiwiY29udGVudCI6eyJtZW50aW9uZWRUeXBlIjowLCJtZW50aW9uZWRUYXJnZXRzIjpbXSwidHlwZSI6MSwic2VhcmNoYWJsZUNvbnRlbnQiOiLlt7LmlLbliLAifSwibWVzc2FnZUlkIjoxNjkzNTM4MDk2NjgxLCJkaXJlY3Rpb24iOjAsInN0YXR1cyI6MCwibWVzc2FnZVVpZCI6MCwidGltZXN0YW1wIjoxNjkzNTM4MDk2NjgxLCJ0b3MiOiIiLCJjb252ZXJzYXRpb25UeXBlIjowLCJ0YXJnZXQiOiIxZWUwZWRhYy0xMzExLTg4NjMtM2NkMS1mY2RmNzhmMzk5YTQiLCJsaW5lIjowfQ==,
      // seq: 27,
      // send_time: 1693538096689
      // }
      // {code: 200, msg: OK, data: {msg_list: null, has_more: false}}
      if (offlineData != null && offlineData["code"] == 200) {
        final list = offlineData["data"]["msg_list"];
        if (list != null && list is List) {
          for (var element in list) {
            try {
              final pushCode = element["code"];
              List<int> byteData = base64.decode(element["content"]);
              String jsonStr = utf8.decode(byteData);
              // debugPrint("Decoded JSON String: $jsonStr");
              final content = json.decode(jsonStr);
              // debugPrint("JSON Content: $content");
              // debugPrint("initOffLineMessage pushCode: $pushCode");
              if (pushCode == 100) {
                //单聊用户消息
                ChatMessageModel md = ChatMessageModel.fromMap(content);
                await chatDataUtil.handleMessage(pushCode, md);
                //设置消息未读
                CacheMessageIsReadUtils().saveUnReadMessageId(md.getTargetId());
              }
            } catch (err) {
              //消息有误 继续下条消息解析
              break;
            }
          }
          //更新会话列表
          eventBus.fire(EventPublic(EventPublicType.updateChatConversationList));
        }
      }
      //如果还有未读消息继续拉取
      if (offlineData != null && offlineData["code"] == 200) {
        final hasMore = offlineData["data"]["has_more"];
        if (hasMore != null && hasMore) {
          await getSingleChatOfflineData();
        }
      }
    } catch (err) {
      //err
    }
  }

  //获取群离线消息
  Future<void> getGroupOfflineMessage() async {
    final offlineData = await chatApi.groupOfflineLastMsg();
    if (offlineData != null && offlineData["code"] == 200) {
      final list = offlineData["data"];
      if (list != null && list is List) {
        for (var element in list) {
          try{
            final base64Content = element["last_msg"]["content"];
            List<int> byteData = base64.decode(base64Content);
            String jsonStr = utf8.decode(byteData);
            // debugPrint("Decoded JSON String: $jsonStr");
            final content = json.decode(jsonStr);
            debugPrint("JSON Content: $content");

            ChatMessageModel md = ChatMessageModel.fromMap(content);
            //设置为 接收类型
            md.direction = 0;
            md.sMessageId=element["last_msg"]['message_id'];
            MessageContent mc = md.content;

            if (mc.type == 90) {
              Map pushContent = json.decode(mc.pushContent ?? "");
              // debugPrint("pushContent:$pushContent");
              final String? whiteUuid = pushContent["white_uuid"];
              final String? blackUuid = pushContent["black_uuid"];

              if (whiteUuid != null && whiteUuid.isNotEmpty) {
                if (AppGlobals.userInfo?.uuid == whiteUuid) {
                  await saveGroupOfflineMessage(md);
                }
              } else if (blackUuid != null && blackUuid.isNotEmpty) {
                if (AppGlobals.userInfo?.uuid != blackUuid) {
                  await saveGroupOfflineMessage(md);
                }
              } else {
                await saveGroupOfflineMessage(md);
              }
              //设置消息未读
              CacheMessageIsReadUtils().saveUnReadMessageId(md.getTargetId());

            } else {
              if (md.from != AppGlobals.userInfo?.uuid) {
                await saveGroupOfflineMessage(md);
                //设置消息未读
                CacheMessageIsReadUtils().saveUnReadMessageId(md.getTargetId());

                //当前群组是否有人@我 如果有存入到集合中
                if(md.isMentioned != null && md.isMentioned == 1){
                  List<dynamic> list = md.mentionedUserIds != null ? json.decode(md.mentionedUserIds! ) : [];
                  bool flag = false;
                  for (var element in list) {
                    if(element == AppGlobals.userInfo?.uuid){
                      flag = true;
                    }
                  }
                  if(flag){
                    CacheGroupMentionUtils().saveMentionGroupId(md.getTargetId());
                  }
                }

              }else{
                //自发送的 不需要任何处理
              }
            }

          }catch(err){
            break;
          }
        }

        eventBus
            .fire(EventPublic(EventPublicType.updateChatConversationList));

      }
    }
  }

  //群聊的离线消息 如果用户没有执行 ack 操作 每次登录都会获取到 不能重复插入数据库
  Future<void> saveGroupOfflineMessage(ChatMessageModel model) async {
    if (await chatDBApi.getMessageByMessageId(model.messageId) == null) {
      final raw = await chatDBApi.saveMessage(model);
      debugPrint("saveGroupOfflineMessage status:$raw ${raw == 0 ? "失败" : "成功"}");
    }
  }

  //更新会话列表群和好友的个人信息
  Future<void> updateChatConversationList() async {
    var list = _chatConversationList;
    for (var element in list) {
      try{
        //从缓存中查找用户信息 不存在 从网络上请求
        final targetId = element.targetId;
        // debugPrint("targetId: $targetId");
        // 0 单聊 1群组
        if (element.conversationType == 0) {
          FriendInfo? info = await chatSPUtil.getNavUserInfo(targetId);
          FriendInfo? infoR= await chatSPUtil.getNavUserInfoRemark(targetId);
          if (info != null) {
            // debugPrint("从缓存中拿到了friendInfo数据");
            element.friendInfo = info;
            element.friendInfo?.remarks=infoR?.remarks;
          } else {
            final friendData = await chatApi.getUserInfo(targetId);
            if (friendData != null && friendData["code"] == 200) {
              FriendInfo fInfo = FriendInfo.fromJson(friendData["data"]);
              element.friendInfo = fInfo;
              //更新缓存
              chatSPUtil.saveOrUpdateUserInfo(fInfo);
            }
          }
        } else {
          final GroupInfo? groupInfo =
          await chatSPUtil.getGroupInfoById(targetId);
          if (groupInfo != null) {
            // debugPrint("从缓存中拿到了groupInfo");
            element.groupInfo = groupInfo;
          } else {
            final groupData = await chatApi.groupInfo(element.targetId);
            if (groupData != null && groupData["code"] == 200) {
              GroupInfo gInfo = GroupInfo.fromJson(groupData["data"]);
              element.groupInfo = gInfo;
              //保存到数据库
              chatSPUtil.saveOrUpdateGroupInfo(gInfo);
            }
          }

          //会话列表生成打招呼
          if (element.content.type == 90) {
            element.content.pushContent2 ??=
            await chatDataUtil.generateGroupTips(
                json.decode(element.content.pushContent ?? ''));

            //update db
            chatDBApi.updateMessage(element);
          }
        }
      }catch(err){
        //err
        debugPrint("err:${err.toString()}");
        break;
      }
    }
    setChatConversationList(list);
  }
}
