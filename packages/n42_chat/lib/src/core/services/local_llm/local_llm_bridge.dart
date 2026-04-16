import 'dart:async';

import 'package:flutter/services.dart';

import '../../utils/debug_log.dart';
import 'local_llm_types.dart';

/// 本地 LLM 推理桥接（MethodChannel → Android MediaPipe / iOS Core ML）。
///
/// Flutter 侧只做参数序列化和流式结果反序列化；
/// 实际推理由各平台原生代码完成。
///
/// Android 推荐实现：MediaPipe LLM Inference API（原生支持 Gemma）
/// iOS 推荐实现：Core ML + MLX 或 llama.cpp C FFI
class LocalLlmBridge {
  static const _channel = MethodChannel('com.n42.chat/local_llm');
  static const _eventChannel = EventChannel('com.n42.chat/local_llm_stream');

  /// 检查设备是否支持本地推理（GPU/NPU 可用性 + 可用内存）。
  Future<DeviceCapability> checkCapability() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'checkCapability',
      );
      if (result == null) return const DeviceCapability.unsupported();
      return DeviceCapability(
        supported: result['supported'] as bool? ?? false,
        availableMemoryMb: result['available_memory_mb'] as int? ?? 0,
        hasGpu: result['has_gpu'] as bool? ?? false,
        hasNpu: result['has_npu'] as bool? ?? false,
        recommendedQuantization: result['recommended_quant'] as String? ?? 'int4',
      );
    } catch (e) {
      debugLog('LocalLlmBridge: checkCapability failed - $e');
      return const DeviceCapability.unsupported();
    }
  }

  /// 加载模型到内存。
  ///
  /// [modelPath] 本地模型文件路径（GGUF / TFLite / MediaPipe task 格式）。
  /// [maxTokens] 上下文窗口长度。
  Future<bool> loadModel({
    required String modelPath,
    int maxTokens = 2048,
    int topK = 40,
    double temperature = 0.7,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('loadModel', {
        'model_path': modelPath,
        'max_tokens': maxTokens,
        'top_k': topK,
        'temperature': temperature,
      });
      return result ?? false;
    } catch (e) {
      debugLog('LocalLlmBridge: loadModel failed - $e');
      return false;
    }
  }

  /// 卸载当前模型，释放内存。
  Future<void> unloadModel() async {
    try {
      await _channel.invokeMethod('unloadModel');
    } catch (e) {
      debugLog('LocalLlmBridge: unloadModel failed - $e');
    }
  }

  /// 是否已加载模型。
  Future<bool> isModelLoaded() async {
    try {
      return await _channel.invokeMethod<bool>('isModelLoaded') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 非流式推理。
  Future<String?> generate({
    required String prompt,
    int maxOutputTokens = 512,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('generate', {
        'prompt': prompt,
        'max_output_tokens': maxOutputTokens,
      });
      return result;
    } catch (e) {
      debugLog('LocalLlmBridge: generate failed - $e');
      return null;
    }
  }

  /// 流式推理（逐 token 返回）。
  Stream<String> generateStream({
    required String prompt,
    int maxOutputTokens = 512,
  }) {
    final controller = StreamController<String>();

    _channel.invokeMethod('startStreamGenerate', {
      'prompt': prompt,
      'max_output_tokens': maxOutputTokens,
    }).catchError((Object e) {
      controller.addError(e);
      controller.close();
    });

    final sub = _eventChannel
        .receiveBroadcastStream()
        .listen(
          (data) {
            if (data is String) {
              if (data == '<|end|>') {
                controller.close();
              } else {
                controller.add(data);
              }
            }
          },
          onError: (Object e) {
            controller.addError(e);
            controller.close();
          },
          onDone: () {
            if (!controller.isClosed) controller.close();
          },
        );

    controller.onCancel = () {
      sub.cancel();
      _channel.invokeMethod('cancelGenerate');
    };

    return controller.stream;
  }

  /// 获取当前模型信息。
  Future<Map<String, dynamic>?> getModelInfo() async {
    try {
      return await _channel.invokeMapMethod<String, dynamic>('getModelInfo');
    } catch (e) {
      return null;
    }
  }
}
