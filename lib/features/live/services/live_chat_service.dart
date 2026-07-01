import 'dart:async';
import 'dart:convert';

import 'package:n42_chat/n42_chat.dart';
// matrix 为 n42_chat 传递依赖；此处仅借用其 Client 类型读写自定义 room state
// （直播判活心跳），不经 n42_chat 封装（其仓库接口未暴露任意 state event 读写）。
// ignore: depend_on_referenced_packages
import 'package:matrix/matrix.dart' show Client;
// 仓库接口未从 n42_chat 公共入口导出，经实现导入访问（集中于本文件）。
// ignore_for_file: implementation_imports
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/domain/repositories/conversation_repository.dart';
import 'package:n42_chat/src/domain/repositories/group_repository.dart';
import 'package:n42_chat/src/domain/repositories/message_repository.dart';
import 'package:get_it/get_it.dart';

import 'live_bootstrap.dart';

/// 直播结构化事件（礼物 / 预测同步等），经 Matrix 文本 timeline 承载。
///
/// 复用已验证可靠的 `sendTextMessage`/`watchMessages` 通道，载荷为
/// `<哨兵前缀><JSON>` 的文本消息；直播 UI 据此还原事件，并在弹幕中过滤掉它们。
class LiveEvent {
  const LiveEvent({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.isMe,
    required this.timestamp,
    required this.data,
  });

  /// 来源消息 id（用于去重 / 事件溯源定序）。
  final String id;
  final String senderId;
  final String senderName;
  final bool isMe;
  final DateTime timestamp;

  /// 事件载荷（含类型字段 `t` 与各事件自有字段）。
  final Map<String, dynamic> data;

  /// 事件类型（如 `gift` / `pred`）。
  String get kind => data['t'] as String? ?? '';
}

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
    required this.isLive,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final int memberCount;

  /// 是否正在直播（由房间 topic 心跳标记推算，见 [LiveChatService] 的 live 标记）。
  final bool isLive;
  final String? avatarUrl;
}

/// 直播弹幕服务：复用 n42_chat（Matrix）。每个直播间 = 一个 Matrix room，
/// 弹幕走该 room 的 timeline。
class LiveChatService {
  /// 弹幕展示上限（取最近 N 条，避免高频弹幕重建整列表）。
  static const int maxDanmu = 100;

  /// 直播结构化事件的文本哨兵前缀（控制字符开头，避免与正常弹幕碰撞）。
  /// 形如 `n42live:{json}`；弹幕流过滤掉这些消息，事件流只取它们。
  static const String _eventPrefix = 'n42live:';

  /// 直播判活状态写入**自定义 Matrix state event**（不复用 `m.room.topic`）：
  /// 避免与房间真实公告字段冲突——若主播/协作者用聊天原生「群信息」页编辑
  /// 话题，不会误摧毁判活标记；反过来直播心跳也不会污染用户可见的群公告。
  /// state event type/内容：`{'live': bool, 'ts': <毫秒>}`（`live=false` 或
  /// 缺失即非直播）。读写走 [Client.getRoomById]/[Client.setRoomStateWithKey]，
  /// 与 `topic` 同样存于本地已同步的 `room.states`，零额外订阅成本。
  static const String _liveStateType = 'n42.live.status';

  /// 直播心跳上报间隔（主播端周期刷新 state event 时间戳）。
  static const Duration heartbeatInterval = Duration(seconds: 30);

  /// 直播存活窗口：超过该时长无心跳即判定为已结束（主播崩溃/划掉时自动失活，
  /// 不留幽灵直播间）。须 > [heartbeatInterval] 以容忍一次丢拍。
  static const Duration liveTtl = Duration(seconds: 90);

  IMessageRepository get _msg => GetIt.instance<IMessageRepository>();
  IConversationRepository get _conv =>
      GetIt.instance<IConversationRepository>();
  IGroupRepository get _group => GetIt.instance<IGroupRepository>();
  Client? get _client => GetIt.instance<MatrixClientManager>().client;

  /// 当前 Matrix 用户 id（预测事件溯源用来识别"我的"持仓 / 余额；未登录为 null）。
  String? get myUserId => _client?.userID;

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
      final texts =
          window
              .where(
                (m) =>
                    m.type == MessageType.text &&
                    !m.content.startsWith(_eventPrefix),
              )
              .toList()
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

  /// 发送一条直播结构化事件（礼物 / 预测同步等）。[data] 须含类型字段 `t`。
  Future<void> sendEvent(String roomId, Map<String, dynamic> data) async {
    await _msg.sendTextMessage(roomId, '$_eventPrefix${jsonEncode(data)}');
  }

  /// 订阅房间内所有直播事件（按时间升序的完整日志，供预测事件溯源重放）。
  Stream<List<LiveEvent>> watchEvents(String roomId) {
    return _msg.watchMessages(roomId).map((messages) {
      final events = <LiveEvent>[];
      for (final m in messages) {
        final e = _parseEvent(m);
        if (e != null) events.add(e);
      }
      events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return events;
    });
  }

  /// 订阅"新到达"的直播事件（每条仅发一次，供礼物等一次性触发的动画）。
  /// 首帧已存在的历史事件视为已消费、不重放，避免进房时补放一堆旧礼物。
  Stream<LiveEvent> watchNewEvents(String roomId) async* {
    final seen = <String>{};
    var primed = false;
    await for (final list in watchEvents(roomId)) {
      if (!primed) {
        for (final e in list) {
          seen.add(e.id);
        }
        primed = true;
        continue;
      }
      for (final e in list) {
        if (seen.add(e.id)) yield e;
      }
    }
  }

  LiveEvent? _parseEvent(MessageEntity m) {
    if (m.type != MessageType.text) return null;
    if (!m.content.startsWith(_eventPrefix)) return null;
    try {
      final decoded = jsonDecode(m.content.substring(_eventPrefix.length));
      if (decoded is! Map<String, dynamic>) return null;
      return LiveEvent(
        id: m.id,
        senderId: m.senderId,
        senderName: m.senderName,
        isMe: m.isFromMe,
        timestamp: m.timestamp,
        data: decoded,
      );
    } catch (_) {
      // 非法载荷（截断/伪造）忽略，不影响弹幕与其他事件。
      return null;
    }
  }

  /// 离开房间（观众退出 / 直播结束 / 开播中途失败回滚）。失败静默——清理是
  /// 尽力而为，不应再向上层抛错覆盖原始失败原因。
  Future<void> leave(String roomId) async {
    try {
      await _conv.leaveConversation(roomId);
    } catch (_) {
      // 已不在房内或网络问题；忽略。
    }
  }

  /// 主播端：上报/刷新直播心跳（写入自定义 state event 的当前时间戳）。
  /// 开播后立即调一次、之后每 [heartbeatInterval] 调一次。失败静默。
  Future<void> markLive(String roomId) async {
    try {
      final ms = DateTime.now().millisecondsSinceEpoch;
      await _client?.setRoomStateWithKey(roomId, _liveStateType, '', {
        'live': true,
        'ts': ms,
      });
    } catch (_) {
      // 网络/权限问题；下一拍心跳会重试。
    }
  }

  /// 主播端：标记直播结束（停止心跳后调用，使房间立即从列表失活）。失败静默。
  Future<void> markEnded(String roomId) async {
    try {
      await _client?.setRoomStateWithKey(roomId, _liveStateType, '', {
        'live': false,
      });
    } catch (_) {
      // 即便写失败，心跳停止后房间也会在 liveTtl 内自动失活。
    }
  }

  /// 观众端：**持续**订阅房间是否在直播（用于进死房/中途下播都能给出正确
  /// 反馈，而非只在进房那一刻判一次——此前的真实缺口：一次性判定要么把
  /// 网络抖动导致的瞬时误判永久锁死为"已结束"，要么对主播中途下播/崩溃
  /// 毫无反应，一直显示"直播中"直到用户重新进房）。
  ///
  /// 双路触发保证及时性与自愈：①房间任意状态变化（含主播心跳，最及时，
  /// 通常心跳本身就是一次状态变化）；②定期兜底重算（应对房间彻底安静、
  /// 无任何后续事件时 TTL 到期仍需自然生效——只靠状态变化触发的话，最后
  /// 一次心跳之后房间再无任何事件，观众端会一直卡在"直播中"）。
  ///
  /// 仅在确实读到房间信息且其标记为非直播时判死；读不到房间（加载失败/
  /// 未知）时不武断判死，按"可能在播"放行，交由视频层呈现。
  Stream<bool> watchIsRoomLive(String roomId) {
    late StreamController<bool> controller;
    StreamSubscription<void>? convSub;
    Timer? ticker;

    bool computeNow() {
      try {
        final room = _client?.getRoomById(roomId);
        if (room == null) return true;
        return _parseLive(room.getState(_liveStateType)?.content);
      } catch (_) {
        return true;
      }
    }

    void emit() {
      if (!controller.isClosed) controller.add(computeNow());
    }

    controller = StreamController<bool>.broadcast(
      onListen: () {
        emit();
        convSub = _conv.watchConversation(roomId).listen((_) => emit());
        ticker = Timer.periodic(const Duration(seconds: 5), (_) => emit());
      },
      onCancel: () {
        convSub?.cancel();
        ticker?.cancel();
      },
    );
    return controller.stream;
  }

  /// 解析自定义 state event 内容的直播标记：`live==true` 且最后心跳时间戳在
  /// [liveTtl] 窗口内才判活。
  static bool _parseLive(Map<String, dynamic>? content) {
    if (content == null || content['live'] != true) return false;
    final ms = content['ts'];
    if (ms is! int) return false;
    final last = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime.now().difference(last) < liveTtl;
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
              isLive: _parseLive(
                _client?.getRoomById(c.id)?.getState(_liveStateType)?.content,
              ),
            ),
          )
          .toList();
      return rooms;
    });
  }
}
