import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:livekit_client/livekit_client.dart';
// matrix 为 n42_chat 传递依赖；此处仅借用其 Client 类型换取 LiveKit token。
// ignore: depend_on_referenced_packages
import 'package:matrix/matrix.dart' show Client;
import 'package:n42_chat/n42_chat.dart';

// 以下为 n42_chat 内部实现，未从 package:n42_chat/n42_chat.dart 导出。
// 直播复用其自部署 LiveKit 底座，必须经实现导入访问；全部集中在本文件，
// 作为唯一对 n42_chat src 的耦合点，便于 n42_chat 升级时定位适配。
// ignore_for_file: implementation_imports
import 'package:n42_chat/src/core/utils/livekit_call_utils.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/services/voip/livekit_service.dart';

import 'live_bootstrap.dart';

/// 直播视频服务：复用 n42_chat 自部署 LiveKit SFU 做"一主播多观众"广播。
///
/// - 观众：以 `enableVideo=false` 加入，仅订阅主播轨道。
/// - 主播：以 `enableVideo=true` 加入，发布摄像头/麦克风。
///
/// 注意：直接驱动 [LiveKitService]（经 `N42Chat.callManager.liveKitService` 暴露），
/// 绕开 `CallManager.joinMeeting`（后者会强制导航到 n42_chat 自带的 GroupCallScreen）。
/// 角色权限（can_publish）最终由 LiveKit JWT 端点按角色签发，见 P1 后端改造；
/// 在此之前 `enableVideo` 仅控制本端是否发布。
class LiveVideoService {
  LiveKitService? _service;

  /// 服务是否已释放（页面销毁）。`_join()` 在每个关键 await 点后检查此标志，
  /// 若页面在加入流程完成前就销毁了本实例，一旦 join 最终完成会立即自我清理
  /// 刚建立的连接——否则会孤立一条无人再调用 [leave] 的 LiveKit 会话（主播端
  /// 场景下即摄像头/麦克风被永久占用，只能杀进程才能停止）。
  bool _disposed = false;

  /// 当前已加入的 LiveKit 会话（[ChangeNotifier]，UI 可直接监听）。
  LiveKitService? get service => _service;

  /// 供 UI 监听会话变化的 [Listenable]（隐藏 n42_chat src 类型）。
  Listenable? get listenable => _service;

  /// 是否已在会议中。
  bool get isInMeeting => _service?.isInMeeting ?? false;

  /// 主播视频轨道（观众端渲染用）：取第一个有画面的远端参与者。
  VideoTrack? get primaryVideoTrack {
    final svc = _service;
    if (svc == null) return null;
    for (final p in svc.participants) {
      if (!p.isLocal && p.videoTrack != null) return p.videoTrack;
    }
    // 兜底：任意有画面的轨道（含本地，便于主播自预览）。
    for (final p in svc.participants) {
      if (p.videoTrack != null) return p.videoTrack;
    }
    return null;
  }

  /// 本地视频轨道（主播自预览用）。
  VideoTrack? get localVideoTrack {
    final svc = _service;
    if (svc == null) return null;
    for (final p in svc.participants) {
      if (p.isLocal && p.videoTrack != null) return p.videoTrack;
    }
    return null;
  }

  /// 在线人数（含主播）。
  int get participantCount => _service?.participants.length ?? 0;

  /// 麦克风是否静音（主播端）。
  bool get isMuted => _service?.isMuted ?? false;

  /// 切换前后摄像头（主播端）。
  Future<void> switchCamera() => _service?.switchCamera() ?? Future.value();

  /// 切换麦克风静音（主播端）。
  Future<void> toggleMicrophone() =>
      _service?.toggleMicrophone() ?? Future.value();

  /// 以观众身份加入直播间（仅订阅）。
  Future<LiveKitService> joinAsViewer(String matrixRoomId) =>
      _join(matrixRoomId, broadcaster: false);

  /// 以主播身份加入直播间（发布摄像头 + 麦克风）。
  Future<LiveKitService> joinAsBroadcaster(String matrixRoomId) =>
      _join(matrixRoomId, broadcaster: true);

  Future<LiveKitService> _join(
    String matrixRoomId, {
    required bool broadcaster,
  }) async {
    if (_disposed) throw StateError('LiveVideoService 已释放');
    await ensureLiveChatReady();
    if (_disposed) throw StateError('LiveVideoService 已释放');
    await ensureAnonymousLogin();
    if (_disposed) throw StateError('LiveVideoService 已释放');
    // 登录在 N42Chat.initialize 之后发生，需手动触发 LiveKit 配置发现。幂等。
    await N42Chat.initializeCallManager();
    if (_disposed) throw StateError('LiveVideoService 已释放');

    var cm = N42Chat.callManager;
    if (cm == null) {
      throw StateError('CallManager 不可用');
    }

    // n42_chat 的 LiveKitService 为单例，且 leaveMeeting 后状态停留在
    // disconnected，而 joinMeeting 仅允许从 idle 进入——直接复用会导致
    // “看完一个房间再进下一个房间”必然失败。切房前若上一场未复位，
    // 重建 CallManager 以获得全新 idle 会话。
    var svc = cm.liveKitService;
    if (svc != null && svc.state != MeetingState.idle) {
      await N42Chat.disposeCallManager();
      await N42Chat.initializeCallManager();
      cm = N42Chat.callManager;
      if (cm == null) {
        throw StateError('CallManager 不可用');
      }
      svc = cm.liveKitService;
    }

    if (!cm.config.hasLiveKitConfig) {
      throw StateError('LiveKit 未配置（.well-known 发现失败）');
    }
    if (svc == null) {
      throw StateError('LiveKitService 不可用');
    }

    final client = GetIt.instance<MatrixClientManager>().client;
    final identity = client?.userID;
    if (client == null || identity == null) {
      throw StateError('Matrix 客户端未登录');
    }
    final displayName = N42Chat.currentUser?.displayName;
    final participantName =
        (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : identity;

    final roomName = buildLiveKitRoomName(matrixRoomId);
    final token = await _fetchToken(
      client,
      roomName: roomName,
      identity: identity,
      name: participantName,
      conversationId: matrixRoomId,
      enableVideo: broadcaster,
    );
    if (_disposed) throw StateError('LiveVideoService 已释放');

    final ok = await svc.joinMeeting(
      roomName: roomName,
      token: token,
      participantName: participantName,
      enableVideo: broadcaster,
      enableAudio: broadcaster,
    );
    if (!ok) {
      throw StateError('加入 LiveKit 房间失败');
    }
    if (_disposed) {
      // 页面在加入完成前已销毁：不留孤儿连接（尤其主播端会持续占用摄像头/
      // 麦克风），立即退出刚建立好的会话，不赋给 _service。
      try {
        await svc.leaveMeeting();
      } catch (_) {
        // 清理是尽力而为，失败静默——反正实例已作废，无人再依赖其状态。
      }
      throw StateError('LiveVideoService 已释放');
    }
    _service = svc;
    return svc;
  }

  /// 离开当前直播间。失败静默——清理是尽力而为，调用方多为 fire-and-forget
  /// 的 dispose 路径，不应让未处理异常向上抛出。
  Future<void> leave() async {
    final svc = _service;
    _service = null;
    try {
      await svc?.leaveMeeting();
    } catch (_) {
      // 忽略：会话可能已处于非法状态离会，无需向上层暴露。
    }
  }

  /// 释放本服务实例：标记 [_disposed] 并离会。若 `_join()` 仍在进行中，其
  /// 完成后会检测到本标志并自我清理刚建立的连接（见 `_join` 内的检查点）。
  /// 幂等——可安全重复调用（如"用户点关闭"与 widget 框架 dispose 都会触发）。
  Future<void> dispose() async {
    _disposed = true;
    await leave();
  }

  /// 向 LiveKit JWT 端点换取 token（先 POST 后 GET 兜底），逻辑对齐
  /// n42_chat `CallManager._fetchLiveKitToken`。
  Future<String> _fetchToken(
    Client client, {
    required String roomName,
    required String identity,
    required String name,
    required String conversationId,
    required bool enableVideo,
  }) async {
    final jwtUrl = N42Chat.liveKitJwtUrl;
    if (jwtUrl == null || jwtUrl.isEmpty) {
      throw StateError('liveKitJwtUrl 为空');
    }
    final headers = <String, String>{
      'Authorization': 'Bearer ${client.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final body = jsonEncode(<String, Object?>{
        'room': roomName,
        'identity': identity,
        'name': name,
        'video': enableVideo,
        // 角色前向兼容：服务端实现按角色签发 can_publish 后即可读取，
        // 在此之前服务端忽略该字段（见计划"后端改造"）。
        'role': enableVideo ? 'broadcaster' : 'viewer',
        'conversation_id': conversationId,
        'metadata': jsonEncode(<String, Object?>{
          'conversation_id': conversationId,
          'video': enableVideo,
          'role': enableVideo ? 'broadcaster' : 'viewer',
        }),
      });
      final resp = await client.httpClient.post(
        Uri.parse(jwtUrl),
        headers: headers,
        body: body,
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final token = extractLiveKitToken(resp.body);
        if (token != null) return token;
      }
    } catch (_) {
      // 落到 GET 兜底
    }

    final getUri = buildLiveKitTokenUri(
      jwtUrl,
      roomName: roomName,
      participantId: identity,
      participantName: name,
      enableVideo: enableVideo,
      conversationId: conversationId,
    );
    final resp = await client.httpClient.get(getUri, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final token = extractLiveKitToken(resp.body);
      if (token != null) return token;
    }
    throw StateError('LiveKit token 获取失败 (${resp.statusCode})');
  }
}
