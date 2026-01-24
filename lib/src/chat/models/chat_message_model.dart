import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';
import 'package:n42appv2/src/chat/models/red_pocket_detail_model.dart';

class ChatMessageModel{
  // 0 单聊 1群组
  int conversationType;

  // 0 接收 1 发出
  int direction;

  // 发送人 uuid
  // 如果是 群通知消息 ; from = target = 群uuid
  // 如果是 群聊消息 ; from = 发送者uuid  ，target = 群uuid
  String from;
  int line;

  //时间戳
  int messageId;
  //服务器messageId
  int? sMessageId;
  //默认0
  int status;
  String target;
  int timestamp;
  MessageContent content;

  //消息解密之后的内容
  //通知消息不加密
  //文本消息：消息内容本身 文件消息：代表本地文件的存储路径
  String? decryptionMessageContent;

  //回复消息的id
  int? replyId;
  //是否@了别人 0为false，1为true.
  int? isMentioned;
  //@人员的数据集合【String】json
  String? mentionedUserIds;

  /// 消息所属的 群/个人 信息 本地使用
  GroupInfo? groupInfo;
  FriendInfo? friendInfo;

  //服务器返回数据时/本地发送消息时 自己赋值
  //代表和我聊天的对象（user_id 或者 group_id）
  String getTargetId() {
    if (conversationType == 0) {
      if (AppGlobals.userInfo?.uuid == from) {
        return target;
      }
      return from;
    }
    return target;
  }

  String targetId;

  RedPocketDetailModel? redPocketDetailModel;

  //数据库存储时使用
  Map<String, dynamic> toMap() {
    return {
      'conversationType': conversationType,
      'direction': direction,
      'fromUser': from,
      'line': line,
      'messageId': messageId,
      'sMessageId': sMessageId,
      'status': status,
      'target': target,
      'timestamp': timestamp,
      "targetId": getTargetId(),
      'content': json.encode(content),
      "decryptionMessageContent": decryptionMessageContent,
      "reply_id": replyId,
      "is_mentioned": isMentioned,
      "mentioned_user_ids": mentionedUserIds
    };
  }

  //解析服务器返回的数据时使用
  ChatMessageModel.fromMap(Map<String, dynamic> map)
      : conversationType = map['conversationType'],
        content = MessageContent.fromJson(map['content']),
        messageId = map['messageId'],
        sMessageId = map['sMessageId'],
        direction = map['direction'],
        from = map['from'],
        status = map['status'],
        timestamp = map['timestamp'],
        target = map['target'],
        targetId = map['targetId'] ?? '',
        decryptionMessageContent = map["decryptionMessageContent"],
        replyId = map["reply_id"],
        isMentioned = map["is_mentioned"],
        mentionedUserIds = map["mentioned_user_ids"],
        line = map['line'];

  //从数据库解析数据时使用
  ChatMessageModel.fromDBMap(Map<String, dynamic> map)
      : conversationType = map['conversationType'],
        content = MessageContent.fromJson(json.decode(map['content'])),
        messageId = map['messageId'],
        sMessageId = map['sMessageId'],
        direction = map['direction'],
        from = map['fromUser'],
        status = map['status'],
        timestamp = map['timestamp'],
        target = map['target'],
        targetId = map['targetId'],
        decryptionMessageContent = map["decryptionMessageContent"],
        replyId = map["reply_id"],
        isMentioned = map["is_mentioned"],
        mentionedUserIds = map["mentioned_user_ids"],
        line = map['line'];
}

class MessageContent {
  // 90 = 通知类型 取出 "pushContent":
  int type;
  String? content;
  String? searchableContent;
  String? pushContent;
  String? binaryContent;
  String? localContent;
  int? mediaType;
  String? remoteMediaUrl;
  String? localMediaPath;
  int? mentionedType;

  //发送着秘文
  String? senderAesSecret;

  //接收者秘文
  String? receiverAesSecret;

  //reportType = 1 消息被举报
  int? reportType;

  //发送着pub KEY
  String? senderPubKey;
  //接收者pub key
  String? receiverPubKey;
  //原始文件名称
  String? originalFileName;

  //nav 根据push content 动态生成
  String? pushContent2;

  MessageContent(
      this.type,
      this.content,
      this.searchableContent,
      this.pushContent,
      this.binaryContent,
      this.localContent,
      this.mediaType,
      this.remoteMediaUrl,
      this.localMediaPath,
      this.mentionedType,
      this.senderAesSecret,
      this.receiverAesSecret,
      this.senderPubKey,
      this.receiverPubKey,
      this.originalFileName,
      this.reportType,
      this.pushContent2);

  factory MessageContent.fromJson(Map<String, dynamic> map)=>
      MessageContent(
          map['type'] as int,
          map['content'] as String?,
          map['searchableContent'] as String?,
          map['pushContent'] as String?,
          map['binaryContent'] as String?,
          map['localContent'] as String?,
          map['mediaType'] as int?,
          map['remoteMediaUrl'] as String?,
          map['localMediaPath'] as String?,
          map['mentionedType'] as int?,
          map['senderAesSecret'] as String?,
          map['receiverAesSecret'] as String?,
          map['senderPubKey'] as String?,
          map['receiverPubKey'] as String?,
          map['originalFileName'] as String?,
          map['reportType'] as int?,
          map['pushContent2'] as String?,
      );


  Map<String, dynamic> toJson() {
    return {
      "type":type,
      "content":content,
      "searchableContent":searchableContent,
      "pushContent":pushContent,
      "binaryContent":binaryContent,
      "localContent":localContent,
      "mediaType":mediaType,
      "remoteMediaUrl":remoteMediaUrl,
      "localMediaPath":localMediaPath,
      "mentionedType":mentionedType,
      "senderAesSecret":senderAesSecret,
      "receiverAesSecret":receiverAesSecret,
      "senderPubKey":senderPubKey,
      "receiverPubKey":receiverPubKey,
      "originalFileName":originalFileName,
      "reportType":reportType,
      "pushContent2":pushContent2,
    };
  }
}
