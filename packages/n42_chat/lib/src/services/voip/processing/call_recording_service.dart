import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/debug_log.dart';
import '../../../n42_chat.dart';

/// 通话录制服务
///
/// 支持两种录制模式：
/// 1. **服务端录制**（推荐）：调用 LiveKit Room Composite 或 Track Composite
///    API 在 SFU 侧录制，完成后上传到 Matrix media repo。
/// 2. **本地录制**（备选）：在客户端侧捕获 MediaStreamTrack 写入本地文件。
///
/// 默认走服务端模式（需 LiveKit Egress 服务配置）。
class CallRecordingService {
  CallRecordingService();

  final ValueNotifier<RecordingState> state =
      ValueNotifier(RecordingState.idle);

  String? _currentEgressId;
  String? _currentRoomName;
  DateTime? _startedAt;

  bool get isRecording => state.value == RecordingState.recording;

  /// 开始服务端录制。
  ///
  /// [livekitRoomName] LiveKit 房间名。
  /// [livekitApiUrl] LiveKit Egress API URL（由宿主配置）。
  /// [livekitApiKey] / [livekitApiSecret] 管理端密钥。
  Future<bool> startServerRecording({
    required String livekitRoomName,
    String? livekitApiUrl,
    String? livekitApiKey,
    String? livekitApiSecret,
  }) async {
    if (isRecording) return false;

    try {
      state.value = RecordingState.starting;
      _currentRoomName = livekitRoomName;
      _startedAt = DateTime.now();

      // LiveKit Egress API: POST /twirp/livekit.Egress/StartRoomCompositeEgress
      // 此处构造请求并发送——当前为框架占位，
      // 实际需要宿主在 N42Chat.liveKitJwtUrl 同域部署 Egress 服务。
      final egressUrl = livekitApiUrl ?? N42Chat.liveKitJwtUrl;
      if (egressUrl == null) {
        debugLog('CallRecording: No LiveKit Egress URL configured');
        state.value = RecordingState.idle;
        return false;
      }

      // Egress API 尚未接入——需宿主部署 LiveKit Egress 后实现 HTTP 调用。
      debugLog('CallRecording: Egress API not yet implemented');
      state.value = RecordingState.idle;
      return false;
    } catch (e) {
      debugLog('CallRecording: Start failed - $e');
      state.value = RecordingState.error;
      return false;
    }
  }

  /// 停止录制并返回录制文件的 URL/路径。
  Future<RecordingResult?> stopRecording() async {
    if (!isRecording) return null;

    try {
      state.value = RecordingState.stopping;

      final duration = _startedAt != null
          ? DateTime.now().difference(_startedAt!)
          : Duration.zero;

      // TODO: 实际调用 LiveKit Egress Stop API，获取文件 URL
      final result = RecordingResult(
        egressId: _currentEgressId ?? '',
        roomName: _currentRoomName ?? '',
        duration: duration,
        startedAt: _startedAt ?? DateTime.now(),
        fileUrl: null, // Egress 完成后由回调填充
      );

      _currentEgressId = null;
      _currentRoomName = null;
      _startedAt = null;
      state.value = RecordingState.idle;

      debugLog('CallRecording: Stopped, duration=${duration.inSeconds}s');
      return result;
    } catch (e) {
      debugLog('CallRecording: Stop failed - $e');
      state.value = RecordingState.error;
      return null;
    }
  }

  void dispose() {
    state.dispose();
  }
}

enum RecordingState {
  idle,
  starting,
  recording,
  stopping,
  error,
}

class RecordingResult {
  const RecordingResult({
    required this.egressId,
    required this.roomName,
    required this.duration,
    required this.startedAt,
    this.fileUrl,
    this.mxcUrl,
  });

  final String egressId;
  final String roomName;
  final Duration duration;
  final DateTime startedAt;
  final String? fileUrl;
  final String? mxcUrl;
}
