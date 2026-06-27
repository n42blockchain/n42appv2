import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/debug_log.dart';

/// 本地大模型 MethodChannel 桥
///
/// 桥接平台原生设备端推理（Android MediaPipe LLM Inference / iOS Core ML）。
/// **Dart 侧完整**；原生 handler 另行实现，未实现时各调用经 [_safe] 捕获
/// `MissingPluginException` 优雅降级（能力查询返回 false、生成返回 null）。
class LocalLlmBridge {
  static const MethodChannel _channel = MethodChannel('n42.chat/local_llm');

  Future<T?> _safe<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } catch (e) {
      debugLog('LocalLlmBridge.$method failed: $e');
      return null;
    }
  }

  /// 设备是否具备端侧推理能力（GPU/NPU/内存）
  Future<bool> isDeviceCapable() async =>
      (await _safe<bool>('isDeviceCapable')) ?? false;

  /// 模型是否已下载
  Future<bool> isModelDownloaded() async =>
      (await _safe<bool>('isModelDownloaded')) ?? false;

  /// 下载模型（返回是否成功）
  Future<bool> downloadModel() async =>
      (await _safe<bool>('downloadModel')) ?? false;

  /// 加载模型到内存
  Future<bool> loadModel() async => (await _safe<bool>('loadModel')) ?? false;

  /// 卸载模型
  Future<void> unloadModel() => _safe<void>('unloadModel');

  /// 生成（非流式）。原生未实现/失败返回 null。
  Future<String?> generate(String prompt, {int maxTokens = 512}) =>
      _safe<String>('generate', {'prompt': prompt, 'maxTokens': maxTokens});
}

/// 本地大模型状态
enum LocalLlmState { unavailable, notDownloaded, downloading, ready }

/// 本地设备推理服务（模型生命周期 + 生成）
///
/// 经 [LocalLlmBridge] 调用原生设备端推理。**原生未接入时 [state] 恒为
/// `unavailable`**，AI 请求由 [AiProviderRouter] 回退云端——不误导为可用。
class LocalLlmService {
  final LocalLlmBridge _bridge;

  LocalLlmService(this._bridge);

  final ValueNotifier<LocalLlmState> stateNotifier =
      ValueNotifier<LocalLlmState>(LocalLlmState.unavailable);

  /// 用户是否启用端侧推理（开关；默认关）
  bool enabled = false;

  LocalLlmState get state => stateNotifier.value;

  bool get isReady => enabled && state == LocalLlmState.ready;

  /// 探测设备能力 + 模型状态
  Future<void> init() async {
    final capable = await _bridge.isDeviceCapable();
    if (!capable) {
      stateNotifier.value = LocalLlmState.unavailable;
      return;
    }
    final downloaded = await _bridge.isModelDownloaded();
    stateNotifier.value =
        downloaded ? LocalLlmState.ready : LocalLlmState.notDownloaded;
  }

  Future<void> download() async {
    if (state == LocalLlmState.unavailable) return;
    stateNotifier.value = LocalLlmState.downloading;
    final ok = await _bridge.downloadModel();
    stateNotifier.value =
        ok ? LocalLlmState.ready : LocalLlmState.notDownloaded;
  }

  Future<String?> generate(String prompt, {int maxTokens = 512}) {
    if (!isReady) return Future<String?>.value(null);
    return _bridge.generate(prompt, maxTokens: maxTokens);
  }

  void dispose() => stateNotifier.dispose();
}
