import 'dart:async';

import 'package:flutter/foundation.dart';

import 'speech_to_text_service.dart';
import 'voice_service.dart';
import '../utils/debug_log.dart';

/// 一条实时字幕
@immutable
class LiveCaption {
  final String text;
  final String? speaker;
  final DateTime at;

  const LiveCaption({required this.text, this.speaker, required this.at});
}

/// 实时字幕服务
///
/// 把音频分片转写为字幕流。**音频源可插拔**：
/// - `pushAudioChunk(path)`：调用方（通话音频管道 / 录音）喂入一段音频；
/// - `startMicCaptions()`：基于本机麦克风的字幕循环（非通话场景；通话中麦克风
///   被 WebRTC 占用，应改由通话音频帧管道喂 `pushAudioChunk`）。
///
/// 转写复用 [SpeechToTextService]（Google/Azure/Whisper），**需 host 配 STT key**，
/// 未配置时 transcribe 返回 null、字幕不更新（不误导为可用）。
class LiveCaptionService {
  final SpeechToTextService _stt;
  final VoiceService _voice;

  LiveCaptionService(this._stt, this._voice);

  /// 字幕列表（保留最近 N 条），UI 监听
  final ValueNotifier<List<LiveCaption>> captions =
      ValueNotifier<List<LiveCaption>>(const []);

  static const int _maxKeep = 20;
  bool _running = false;
  String _language = 'en-US';

  bool get isRunning => _running;

  /// 喂入一段音频做转写并追加字幕（音频源由调用方提供）
  Future<void> pushAudioChunk(String audioPath, {String? speaker}) async {
    try {
      final text = await _stt.transcribe(audioPath, language: _language);
      if (text == null || text.trim().isEmpty) return;
      final list = List<LiveCaption>.from(captions.value)
        ..add(LiveCaption(
            text: text.trim(), speaker: speaker, at: DateTime.now()));
      if (list.length > _maxKeep) {
        list.removeRange(0, list.length - _maxKeep);
      }
      captions.value = list;
    } catch (e) {
      debugLog('LiveCaptionService: transcribe failed: $e');
    }
  }

  /// 麦克风字幕循环（每 [chunk] 录一段→转写→追加）。非通话场景使用。
  Future<void> startMicCaptions({
    String language = 'en-US',
    Duration chunk = const Duration(seconds: 4),
  }) async {
    if (_running) return;
    _running = true;
    _language = language;
    while (_running) {
      final started = await _voice.startRecording();
      if (!started) break;
      await Future<void>.delayed(chunk);
      if (!_running) {
        await _voice.cancelRecording();
        break;
      }
      final result = await _voice.stopRecording();
      if (result != null) {
        await pushAudioChunk(result.path);
      }
    }
    _running = false;
  }

  void stop() => _running = false;

  void clear() => captions.value = const [];

  void dispose() {
    _running = false;
    captions.dispose();
  }
}
