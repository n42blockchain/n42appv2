import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';
import 'package:n42appv2/src/chat/provider/chat_message_provider.dart';
import 'package:n42appv2/src/chat/utils/cache_read_message_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/proto/connect.ext.pb.dart';
import 'package:n42appv2/src/proto/message.ext.pb.dart';
import 'package:n42appv2/src/proto/push.ext.pb.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/src/utils/notfication_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:n42appv2/generated/l10n.dart';

class WebSocketUtil {
  WebSocketUtil._init();

  static final WebSocketUtil _instance = WebSocketUtil._init();

  static WebSocketUtil get instance {
    return _instance;
  }

  BuildContext? contexts;

  WebSocketChannel? channel;

  Timer? _timer;

  //登录之后 建立socket链接
  void connect() {
    final wsUrl = Uri.parse(generateSocketUrl());
    //channel = WebSocketChannel.connect(wsUrl);
    HttpClient httpClient=HttpClient()..badCertificateCallback=(X509Certificate cert, String host, int port) => true;
    channel = IOWebSocketChannel.connect(
      wsUrl,
      headers: {
        "origin":AppConfig.getApiUrlOnline("imHttpHost"),
      },
      pingInterval: Duration(seconds: 30),
      customClient:httpClient,
    );
    if (channel != null) {
      // debugPrint("-----im socket connect succeed-----");
    }
    channel?.stream.listen(onData, onError: onError, onDone: onDone);
    // startCountdownTimer();
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (channel == null) {
        connect();
      }
    });
  }

  void sendMessage(dynamic data) {
    channel?.sink.add(data);
  }

  String generateSocketUrl() {
    final uuid = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    final socUrl =
        '${AppConfig.getApiUrlOnline('imWsHost')}/connect?uuid=$uuid&token=$token&source=app';
    return socUrl;
  }

  bool shouldReconnect = true;
  int reconnectCount = 0;

  void onDone() {
    // debugPrint("Socket is closed");
    if (shouldReconnect) {
      if (reconnectCount < 5) {
        // 前5次重连，每次等待时间递增10秒
        final waitTime = Duration(seconds: 5 * reconnectCount);
        Future.delayed(waitTime, () {
          final wsUrl = Uri.parse(generateSocketUrl());
          channel = WebSocketChannel.connect(wsUrl);
          channel?.stream.listen(onData, onError: onError, onDone: onDone);
        });
      } else {
        // 超过5次后，稳定在2分钟一次重连
        const waitTime = Duration(minutes: 2);
        Future.delayed(waitTime, () {
          final wsUrl = Uri.parse(generateSocketUrl());
          channel = WebSocketChannel.connect(wsUrl);
          channel?.stream.listen(onData, onError: onError, onDone: onDone);
        });
      }

      // 增加重连计数
      reconnectCount++;

      //10 分钟之后 仍然没有链接 再次初始化
      if (reconnectCount >= 10) {
        enableReconnect();
      }
    }
  }

  //用户退出登录时调用
  void userLogOut() {
    if (channel != null) {
      channel?.sink.close(status.goingAway);
      debugPrint("--socket close--");
      channel = null;
    }

    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }


  }



  // 在某个条件下，禁止重新连接，例如在用户主动断开连接后
  void disableReconnect() {
    shouldReconnect = false;
  }

  // 在需要重新连接时，启用重新连接
  void enableReconnect() {
    shouldReconnect = true;
    reconnectCount = 0; // 重置重连计数
  }

  void onError(dynamic err) {
    debugPrint(err.runtimeType.toString());
    WebSocketChannelException ex = err;
    debugPrint(ex.message);
  }

  Future<void> onData(dynamic event) async {
    debugPrint('---- web socket 收到消息:$event');
    //解析pb格式的消息体
    Output output = Output.fromBuffer(event);
    final dataList = output.data;
    Message message = Message.fromBuffer(dataList);
    ChatDBApi chatDBApi=ChatDBApi();
    final pushCode = message.code;
     debugPrint("push code : $pushCode");
     debugPrint("message content : ${message.content}");
    // code值有统一的定义，在push.ext.proto
    // PC_USER_MESSAGE = 100; // 用户消息
    // PC_GROUP_MESSAGE = 101; // 群组消息
    // PC_ADD_FRIEND = 110; // 添加好友请求
    // PC_AGREE_ADD_FRIEND = 111; // 同意添加好友
    // PC_UPDATE_GROUP = 120; // 更新群组
    if (pushCode == 100) {
      String jsonStr = utf8.decode(message.content);
      final content = json.decode(jsonStr);
      // debugPrint("push content : ${json.encode(content)}");
      ChatMessageModel md = ChatMessageModel.fromMap(content);
      md.sMessageId=message.messageId.toInt();
      //1 根据message id 查询数据库 存在的话更新数据库 不存在保存消息
      ChatMessageModel? model =
      await chatDBApi.getMessageByMessageId(md.messageId);
      // debugPrint("收到消息 id: ${model?.messageId ?? "数据不存在"}");
      //判断是自己发送的还是接收的消息
      int direction = 0;
      if (md.from == AppGlobals.userInfo?.uuid) {
        // 0 接收 1 发出
        direction = 1;
      } else {
        direction = 0;
      }

      String targetId;

      if (model != null) {
        model.status = 1;
        model.direction = direction;
        model.targetId = model.getTargetId();
        targetId = model.getTargetId();
        await chatDBApi.updateMessage(model);
        // debugPrint("单聊更新 status:$raw ${raw == 0 ? "失败" : "成功"}");
      } else {
        md.status = 1;
        md.direction = direction;
        md.targetId = md.getTargetId();
        targetId = md.getTargetId();
        await chatDBApi.saveMessage(md);
        // debugPrint("单聊消息保存 status:$raw ${raw == 0 ? "失败" : "成功"}");
      }

      ///对方发消息给我时：
      if (md.from != AppGlobals.userInfo?.uuid) {
        //发送消息给监听页面
        eventBus.fire(EventPublic(EventPublicType.chatMessage, param: md));
        //设置消息未读
        CacheMessageIsReadUtils().saveUnReadMessageId(targetId);

        //如果当前聊天的对象已经打开 就不在显示本地通知
        if (AppGlobals.appContext.mounted &&
            Provider.of<ChatMessageProvider>(AppGlobals.appContext,listen: false).currOpenChatTargetUuid != md.getTargetId()){
          //这里不做消息的解密 只展示收到消息的通知栏 具体消息内容点击查看
          final data = json.encode({
            "type": 100,
            "data": {
              "targetUuid" : md.getTargetId()
            }
          });
          notification.send(
              AppConfig.apiUrl['walletName'], "Receive encrypted message, click to view",
              notificationId: 100,
              params: data);
        }

      }

      eventBus.fire(EventPublic(EventPublicType.updateChatConversationList));
    }
    else if (pushCode == 101) {
      String jsonStr = utf8.decode(message.content);
      final content = json.decode(jsonStr);
      debugPrint("push content : ${json.encode(content)}");
      ChatMessageModel md = ChatMessageModel.fromMap(content);
      md.sMessageId=message.messageId.toInt();
      md.status = 1;
      MessageContent mc = md.content;
      md.targetId = md.getTargetId();

      if (mc.type == 90) {
        Map pushContent = json.decode(mc.pushContent ?? "");
        final String? whiteUuid = pushContent["white_uuid"];
        final String? blackUuid = pushContent["black_uuid"];

        if (whiteUuid != null && whiteUuid.isNotEmpty) {
          if (AppGlobals.userInfo?.uuid == whiteUuid) {
            //保存到本地数据库
            await chatDBApi.saveMessage(md);
          }
        } else if (blackUuid != null && blackUuid.isNotEmpty) {
          if (AppGlobals.userInfo?.uuid != blackUuid) {
            //保存到本地数据库
            await chatDBApi.saveMessage(md);
          }
        } else {
          //保存到本地数据库
          await chatDBApi.saveMessage(md);
          // debugPrint("群聊提示消息 status:$raw ${raw == 0 ? "失败" : "成功"}");
        }
        //发送消息给监听页面
        eventBus.fire(EventPublic(EventPublicType.chatMessage, param: md));
      }
      else {
        if (md.from != AppGlobals.userInfo?.uuid) {
          //不是自己发送的 保存到本地数据库
          md.direction = 0;
          await chatDBApi.saveMessage(md);
          //发送消息给监听页面
          eventBus.fire(EventPublic(EventPublicType.chatMessage, param: md));
          //设置消息未读
          CacheMessageIsReadUtils().saveUnReadMessageId(md.getTargetId());

          //如果当前聊天的对象已经打开 就不在显示本地通知
          if (AppGlobals.appContext.mounted &&
              Provider.of<ChatMessageProvider>(AppGlobals.appContext,listen: false).currOpenChatTargetUuid != md.getTargetId()){
            final data = json.encode({
              "type": 101,
              "data": {
                "targetUuid" : md.getTargetId()
              }
            });
            notification.send(
                AppConfig.apiUrl['walletName'], "Receive group encryption message, click to view",
                notificationId: 101,
                params: data);
          }

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

        }
        else{
          chatDBApi.updateMessage(md);
          eventBus.fire(EventPublic(EventPublicType.chatMessageRefresh, param: md));
        }
      }

      eventBus.fire(EventPublic(EventPublicType.updateChatConversationList));
    }
    else if (pushCode == 110) {
      AddFriendPush afp = AddFriendPush.fromBuffer(message.content);
      //ChatSPUtils().setNewFriendStatus(true);
      Provider.of<ChatMessageProvider>(AppGlobals.appContext,listen: false).setNewFriendStatusAdd();
      //弹出添加好友通知
      final data = json.encode({
        "type": 110,
        "data": {
          "friendId": afp.friendId,
          "nickname": afp.nickname,
          "avatarUrl": afp.avatarUrl,
          "description": afp.description,
        }
      });
      notification.send(
          S.current.g_chat_key_27, "${afp.nickname} ${S.current.g_chat_key_28}",
          notificationId: 110,
          params: data);
    }
    else if (pushCode == 111) {
      // 对方同意添加好友
      AddFriendPush afp = AddFriendPush.fromBuffer(message.content);
      final data = json.encode({
        "type": 111,
        "data": {
          "friendId": afp.friendId,
          "nickname": afp.nickname,
          "avatarUrl": afp.avatarUrl,
          "description": afp.description,
        }
      });
      notification.send(S.current.g_chat_key_29,
          S.current.g_chat_key_30,
          notificationId: 111,
          params: data);
    }
    else if (pushCode == 120) {
      String jsonStr = utf8.decode(message.content);
      final content = json.decode(jsonStr);
      //debugPrint("更新群组: ${json.encode(content)}");
      ChatMessageModel md = ChatMessageModel.fromMap(content);
      md.sMessageId=message.messageId.toInt();
      MessageContent mc = md.content;

      GroupInfo groupInfo = GroupInfo.fromJson(json.decode(mc.pushContent!));
      // debugPrint("更新群组 group info: ${groupInfo.name}");

      //更新本地群组信息缓存
      ChatSPUtil().saveOrUpdateGroupInfo(groupInfo);
      //更新会话列表
      eventBus.fire(EventPublic(EventPublicType.updateChatConversationList));
    }
  }

  void dispose() {
    if (channel != null) {
      channel?.sink.close(status.goingAway);
      debugPrint("--socket close--");
      channel = null;
    }

    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }
}