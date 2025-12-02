import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/utils/cache_read_message_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/utils/event_bus.dart';

class ChatDataUtil {
  Map<String, dynamic> generateSendData({
    //MessageContentType
    required int contentType,
    required String fromID,
    required String receiveId,
    required int conversationType,
    required String msg,
    // 0 接收 1 发出
    required int direction,
    //自己发送的消息 不需要解密了
    String? decryptionMessageContent,
    String? senderAesSecret,
    String? senderPubKey,
    String? receiverPubKey,
    String? receiverAesSecret,
    String? originalFileName,
    //消息回复和@功能
    int? reply_id,
    int? is_mentioned = 0,
    String? mentioned_user_ids
  }) {
    Map<String, dynamic> messageContent = {
      "conversationType": conversationType,
      "direction": direction,
      "from": fromID,
      "line": 0,
      "messageId": DateTime.now().millisecondsSinceEpoch,
      "status": 0,
      "target": receiveId,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "content": {
        "type": contentType,
        "content": contentType == 90 ? msg : "",
        "searchableContent": contentType != 90 ? msg : "",
        "pushContent": "",
        "binaryContent": "",
        "localContent": "",
        "mediaType": 0,
        "remoteMediaUrl": "",
        "localMediaPath": "",
        "mentionedType": 0,
        "senderAesSecret": senderAesSecret,
        "receiverAesSecret": receiverAesSecret,
        "senderPubKey": senderPubKey,
        "receiverPubKey": receiverPubKey,
        //发送图片，视频，文件时，原始的文件名称
        "originalFileName": originalFileName,
      },
      "decryptionMessageContent": decryptionMessageContent,
      "reply_id": reply_id,
      "is_mentioned": is_mentioned,
      "mentioned_user_ids": mentioned_user_ids
    };
    return messageContent;
  }

  //根据pushCode 处理接收消息
  handleMessage(int pushCode, ChatMessageModel model) async {
    try {
      // 0 接收 1 发出
      int direction = model.from == Application.userInfo?.uuid ? 1 : 0;
      // userID 或者 groupId
      String targetId = model.getTargetId();
      switch (pushCode) {
        case 100:
        // 用户消息
          if (direction == 0) {
            // status 1 代表消息接收成功
            model.status = 1;
            //设置为 接收类型
            model.direction = 0;
            model.targetId = model.getTargetId();
            final raw = await ChatDBApi().saveMessage(model);
            //发送消息给监听页面
            eventBus.fire(EventPublic(EventPublicType.chatMessage, param: model));
            //设置消息未读
            CacheMessageIsReadUtils().saveUnReadMessageId(targetId);
          }

          break;
      }
    }catch(err){
    }
  }

  ///群通知消息生成
  Future<String?> generateGroupTips(
      Map<String, dynamic> pushContent) async {
    try {
      String text = pushContent["text"];
      Map<String, dynamic> rule = pushContent["rule"];
      for (var entry in rule.entries) {
        String placeholder = entry.key;
        List<String> values = List<String>.from(entry.value);
        String replacement = "";
        for (var element in values) {
          FriendInfo? info = await ChatSPUtil().getFriendInfoById(element);
          if (info != null) {
            replacement += "${info.name}、";
          } else {
            try{
              ChatApi chatApi=ChatApi();
              final friendData = await chatApi.getUserInfo(element);
              FriendInfo fInfo = FriendInfo.fromJson(friendData["data"]);
              replacement += "${fInfo.name}、";
            }catch(err){
              //err
            }
          }
        }
        replacement=replacement.substring(0,replacement.length-1);
        text = text.replaceAll(placeholder, replacement);


      }
      return text;
    } catch (err) {
      return null;
    }
  }
}