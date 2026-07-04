import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import '../utils/debug_log.dart';

/// TTS 播放状态
enum TtsState { stopped, playing, paused }

/// 文字转语音服务
///
/// 提供消息朗读功能，支持多语言自动检测
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  FlutterTts? _tts;
  TtsState _state = TtsState.stopped;
  String? _currentMessageId;

  /// 当前播放状态
  TtsState get state => _state;

  /// 当前正在朗读的消息 ID
  String? get currentMessageId => _currentMessageId;

  /// 状态变化通知
  final _stateController = StreamController<TtsState>.broadcast();
  Stream<TtsState> get onStateChanged => _stateController.stream;

  /// 初始化 TTS 引擎
  Future<void> _ensureInitialized() async {
    if (_tts != null) return;

    final tts = FlutterTts();
    try {
      // 仅 iOS 需要;macOS/Windows 未实现会抛 MissingPluginException——
      // 不能因此放弃整个初始化(否则桌面端朗读永久静默,复审 P1)。
      await tts.setSharedInstance(true);
    } catch (e) {
      debugLog('TtsService: setSharedInstance unsupported (non-iOS): '
          '$e — continuing');
    }
    _tts = tts;

    _tts!.setStartHandler(() {
      _state = TtsState.playing;
      _stateController.add(_state);
    });

    _tts!.setCompletionHandler(() {
      _state = TtsState.stopped;
      _currentMessageId = null;
      _stateController.add(_state);
    });

    _tts!.setCancelHandler(() {
      _state = TtsState.stopped;
      _currentMessageId = null;
      _stateController.add(_state);
    });

    _tts!.setErrorHandler((msg) {
      debugLog('TtsService: Error - $msg');
      _state = TtsState.stopped;
      _currentMessageId = null;
      _stateController.add(_state);
    });

    _tts!.setPauseHandler(() {
      _state = TtsState.paused;
      _stateController.add(_state);
    });

    _tts!.setContinueHandler(() {
      _state = TtsState.playing;
      _stateController.add(_state);
    });

    // 默认设置
    await _tts!.setSpeechRate(0.5);
    await _tts!.setVolume(1.0);
    await _tts!.setPitch(1.0);
  }

  /// 朗读文本消息
  ///
  /// [text] 要朗读的文本
  /// [messageId] 消息 ID（用于跟踪当前朗读的消息）
  /// [language] 可选的语言代码（如 'en-US', 'zh-TW'）
  Future<void> speak(String text, {String? messageId, String? language}) async {
    if (text.trim().isEmpty) return;
    await _ensureInitialized();
    if (_tts == null) return;

    // 如果正在朗读同一条消息，停止
    if (_state == TtsState.playing && _currentMessageId == messageId) {
      await stop();
      return;
    }

    // 如果正在朗读其他消息，先停止
    if (_state != TtsState.stopped) {
      await stop();
    }

    _currentMessageId = messageId;

    // 设置语言
    if (language != null) {
      await _tts!.setLanguage(language);
    } else {
      // 自动检测语言
      final detectedLang = _detectLanguage(text);
      await _tts!.setLanguage(detectedLang);
    }

    await _tts!.speak(text);
  }

  /// 停止朗读
  Future<void> stop() async {
    if (_tts == null) return;
    await _tts!.stop();
    _state = TtsState.stopped;
    _currentMessageId = null;
    _stateController.add(_state);
  }

  /// 暂停朗读
  Future<void> pause() async {
    if (_tts == null || _state != TtsState.playing) return;
    await _tts!.pause();
  }

  /// 判断指定消息是否正在被朗读
  bool isSpeaking(String messageId) {
    return _state == TtsState.playing && _currentMessageId == messageId;
  }

  static final RegExp _chineseRegex = RegExp(r'[\u4e00-\u9fff]');
  static final RegExp _japaneseRegex = RegExp(r'[\u3040-\u309f\u30a0-\u30ff]');
  static final RegExp _koreanRegex = RegExp(r'[\uac00-\ud7af]');

  /// 简单的语言检测
  String _detectLanguage(String text) {
    final chineseCount = _chineseRegex.allMatches(text).length;
    final japaneseCount = _japaneseRegex.allMatches(text).length;
    final koreanCount = _koreanRegex.allMatches(text).length;

    final totalNonAscii = chineseCount + japaneseCount + koreanCount;
    final totalLength = text.length;

    if (totalLength == 0) return 'en-US';

    // 如果非 ASCII 字符占比超过 30%
    if (totalNonAscii / totalLength > 0.3) {
      if (japaneseCount > chineseCount && japaneseCount > koreanCount) {
        return 'ja-JP';
      }
      if (koreanCount > chineseCount) {
        return 'ko-KR';
      }
      return 'zh-TW';
    }

    return 'en-US';
  }

  /// 释放资源
  void dispose() {
    _tts?.stop();
    _stateController.close();
  }
}
