import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../core/services/speech_to_text_service.dart';

/// 通话实时字幕服务
///
/// 从 WebRTC/LiveKit 音轨中周期性截取音频片段，送到已有的
/// [SpeechToTextService] 做 STT（Google / Azure / Whisper），
/// 再把识别到的文字通过 [captionStream] 推送给 UI 层显示。
class LiveCaptionService {
  LiveCaptionService({SpeechToTextService? sttService})
      : _stt = sttService ?? SpeechToTextService();

  final SpeechToTextService _stt;
  final StreamController<CaptionSegment> _controller =
      StreamController<CaptionSegment>.broadcast();
  Timer? _pollingTimer;
  Future<Uint8List?> Function()? _audioSampler;
  final List<CaptionSegment> _history = [];

  Stream<CaptionSegment> get captionStream => _controller.stream;
  final ValueNotifier<String> latestCaption = ValueNotifier('');
  List<CaptionSegment> get history => List.unmodifiable(_history);

  void start({
    required Future<Uint8List?> Function() audioSampler,
    int intervalSeconds = 3,
    String language = 'zh',
  }) {
    _audioSampler = audioSampler;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _processChunk(language),
    );
  }

  void stop() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _audioSampler = null;
  }

  Future<void> _processChunk(String language) async {
    final sampler = _audioSampler;
    if (sampler == null) return;
    try {
      final bytes = await sampler();
      if (bytes == null || bytes.isEmpty) return;

      final dir = await getTemporaryDirectory();
      final tmpFile = File(p.join(dir.path, 'caption_chunk.wav'));
      await tmpFile.writeAsBytes(bytes);

      final text = await _stt.transcribe(tmpFile.path, language: language);
      if (text != null && text.trim().isNotEmpty) {
        final segment = CaptionSegment(
          text: text.trim(),
          timestamp: DateTime.now(),
        );
        _history.add(segment);
        _controller.add(segment);
        latestCaption.value = segment.text;
      }

      try {
        await tmpFile.delete();
      } catch (_) {}
    } catch (e) {
      debugPrint('LiveCaption: STT error - $e');
    }
  }

  Future<void> dispose() async {
    stop();
    latestCaption.dispose();
    await _controller.close();
  }
}

class CaptionSegment {
  const CaptionSegment({
    required this.text,
    required this.timestamp,
    this.speakerId,
    this.speakerName,
  });

  final String text;
  final DateTime timestamp;
  final String? speakerId;
  final String? speakerName;
}
