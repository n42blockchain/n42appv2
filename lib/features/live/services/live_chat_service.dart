import 'package:n42_chat/n42_chat.dart';
// 仓库接口未从 n42_chat 公共入口导出，经实现导入访问（集中于本文件）。
// ignore_for_file: implementation_imports
import 'package:n42_chat/src/domain/repositories/conversation_repository.dart';
import 'package:n42_chat/src/domain/repositories/group_repository.dart';
import 'package:n42_chat/src/domain/repositories/message_repository.dart';
import 'package:get_it/get_it.dart';

import 'live_bootstrap.dart';

/// 一条弹幕（直播间评论）。
class LiveDanmu {
  const LiveDanmu({
    required this.id,
    required this.sender,
    required this.text,
    required this.isMe,
  });

  final String id;
  final String sender;
  final String text;
  final bool isMe;
}

/// 直播间摘要（用于直播列表）。
class LiveRoomSummary {
  const LiveRoomSummary({
    required this.id,
    required this.name,
    required this.memberCount,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final int memberCount;
  final String? avatarUrl;
}

/// 直播弹幕服务：复用 n42_chat（Matrix）。每个直播间 = 一个 Matrix room，
/// 弹幕走该 room 的 timeline。
class LiveChatService {
  /// 弹幕展示上限（取最近 N 条，避免高频弹幕重建整列表）。
  static const int maxDanmu = 100;

  IMessageRepository get _msg => GetIt.instance<IMessageRepository>();
  IConversationRepository get _conv =>
      GetIt.instance<IConversationRepository>();
  IGroupRepository get _group => GetIt.instance<IGroupRepository>();

  /// 进房：确保初始化 + 匿名登录 + 加入 Matrix room。
  Future<void> join(String roomId) async {
    await ensureLiveChatReady();
    await ensureAnonymousLogin();
    try {
      await _conv.joinConversation(roomId);
    } catch (_) {
      // 已在房内或加入失败时忽略；仍可订阅/发送。
    }
  }

  /// 订阅房间弹幕流（仅文本，按时间升序，取最近 [maxDanmu] 条）。
  Stream<List<LiveDanmu>> watchDanmu(String roomId) {
    return _msg.watchMessages(roomId).map((messages) {
      // 仅对尾部窗口排序，避免每次更新都对完整历史做 O(N·logN) 排序
      // （Matrix timeline 近似按时间升序，尾部即最新）。窗口取 maxDanmu*2
      // 以容纳交杂的非文本消息。
      final window = messages.length > maxDanmu * 2
          ? messages.sublist(messages.length - maxDanmu * 2)
          : messages;
      final texts = window.where((m) => m.type == MessageType.text).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final recent = texts.length > maxDanmu
          ? texts.sublist(texts.length - maxDanmu)
          : texts;
      return recent
          .map(
            (m) => LiveDanmu(
              id: m.id,
              sender: m.senderName,
              text: m.content,
              isMe: m.isFromMe,
            ),
          )
          .toList();
    });
  }

  /// 订阅进场事件（返回新加入成员的 userId），用于"xxx 来了"横幅。
  Stream<String> watchEnter(String roomId) =>
      _group.watchMemberJoinEvents(roomId);

  /// 发送一条弹幕。
  Future<void> send(String roomId, String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await _msg.sendTextMessage(roomId, t);
  }

  /// 进房列表（直播广场）：需先初始化 + 登录，返回已加入的房间。
  /// 直播客户端的匿名账户仅加入直播间，故这些会话即直播间。
  Future<Stream<List<LiveRoomSummary>>> watchRooms() async {
    await ensureLiveChatReady();
    await ensureAnonymousLogin();
    return _conv.watchConversations().map((list) {
      final rooms = list
          .where((c) => c.type != ConversationType.direct)
          .map(
            (c) => LiveRoomSummary(
              id: c.id,
              name: c.name,
              memberCount: c.memberCount,
              avatarUrl: c.avatarUrl,
            ),
          )
          .toList();
      return rooms;
    });
  }
}
