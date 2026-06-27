import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import '../utils/debug_log.dart';

/// 端侧推理模型配置
///
/// [modelUrl] 为 MediaPipe `.task` 模型的网络地址（Gemma 系列多为 HuggingFace
/// 受限模型，需配套 [huggingFaceToken]）。**未配置 [modelUrl] 时端侧推理不可用**，
/// [LocalLlmService] 恒 `unavailable` → 回退云端，不误导为可用。
class LocalLlmConfig {
  final String? modelUrl;
  final ModelType modelType;
  final int maxTokens;
  final String? huggingFaceToken;

  const LocalLlmConfig({
    this.modelUrl,
    this.modelType = ModelType.gemmaIt,
    this.maxTokens = 1024,
    this.huggingFaceToken,
  });

  bool get hasModelSource => modelUrl != null && modelUrl!.trim().isNotEmpty;

  /// 由 URL 末段推导模型文件名（flutter_gemma 以文件名为已安装判定 id）
  String get modelFilename {
    final url = modelUrl;
    if (url == null || url.isEmpty) return '';
    final clean = url.split('?').first;
    final slash = clean.lastIndexOf('/');
    return slash >= 0 ? clean.substring(slash + 1) : clean;
  }

  LocalLlmConfig copyWith({
    String? modelUrl,
    ModelType? modelType,
    int? maxTokens,
    String? huggingFaceToken,
  }) =>
      LocalLlmConfig(
        modelUrl: modelUrl ?? this.modelUrl,
        modelType: modelType ?? this.modelType,
        maxTokens: maxTokens ?? this.maxTokens,
        huggingFaceToken: huggingFaceToken ?? this.huggingFaceToken,
      );
}

/// 端侧推理后端接口（便于注入与单测）
abstract class LocalLlmBackend {
  LocalLlmConfig get config;
  void configure(LocalLlmConfig config);
  Future<bool> isDeviceCapable();
  Future<bool> isModelDownloaded();
  Future<bool> downloadModel({void Function(double progress)? onProgress});
  Future<bool> loadModel();
  Future<void> unloadModel();
  Future<String?> generate(String prompt, {int maxTokens});
}

/// 本地大模型推理桥（flutter_gemma / MediaPipe LLM Inference 真实后端）
///
/// 替代了早期的纯 MethodChannel 占位：现经 `flutter_gemma` 在 Android/iOS 设备端
/// **真实运行 Gemma 推理**。模型为**运行时下载**（不打进包体），未配置模型源或在
/// Web/桌面（flutter_gemma 移动端为主）时各调用优雅降级（能力查询 false、生成
/// 返回 null），由 [AiProviderRouter] 回退云端。
class LocalLlmBridge implements LocalLlmBackend {
  LocalLlmBridge([LocalLlmConfig config = const LocalLlmConfig()])
      : _config = config;

  LocalLlmConfig _config;
  bool _sdkInitialized = false;
  InferenceModel? _model;

  @override
  LocalLlmConfig get config => _config;

  /// 运行时配置模型源（host 可经远端配置注入 URL/token 后启用端侧推理）
  @override
  void configure(LocalLlmConfig config) {
    _config = config;
    _sdkInitialized = false; // token 可能变化，重新初始化 SDK
    // 释放旧模型，避免 configure 后仍用旧模型（loadModel 用 `_model ??=`）。
    final old = _model;
    _model = null;
    if (old != null) {
      old.close(); // fire-and-forget 释放原生模型内存
    }
  }

  bool get _platformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  void _ensureSdk() {
    if (_sdkInitialized) return;
    FlutterGemma.initialize(huggingFaceToken: _config.huggingFaceToken);
    _sdkInitialized = true;
  }

  /// 设备是否具备端侧推理能力（平台支持 + 已配置模型源）
  @override
  Future<bool> isDeviceCapable() async {
    return _platformSupported && _config.hasModelSource;
  }

  /// 模型是否已下载
  @override
  Future<bool> isModelDownloaded() async {
    if (!_platformSupported || !_config.hasModelSource) return false;
    try {
      _ensureSdk();
      return await FlutterGemma.isModelInstalled(_config.modelFilename);
    } catch (e) {
      debugLog('LocalLlmBridge.isModelDownloaded failed: $e');
      return false;
    }
  }

  /// 下载模型（运行时网络下载；幂等。返回是否成功）。
  ///
  /// [onProgress] 0.0–1.0 进度回调（可选）。
  @override
  Future<bool> downloadModel({void Function(double progress)? onProgress}) async {
    if (!_platformSupported || !_config.hasModelSource) return false;
    try {
      _ensureSdk();
      await FlutterGemma.installModel(modelType: _config.modelType)
          .fromNetwork(_config.modelUrl!, token: _config.huggingFaceToken)
          .withProgress((p) => onProgress?.call(p / 100.0))
          .install();
      return await FlutterGemma.isModelInstalled(_config.modelFilename);
    } catch (e) {
      debugLog('LocalLlmBridge.downloadModel failed: $e');
      return false;
    }
  }

  /// 加载模型到内存（推理会话按调用即用即建，见 [generate]）。
  @override
  Future<bool> loadModel() async {
    if (!_platformSupported || !_config.hasModelSource) return false;
    try {
      _ensureSdk();
      _model ??= await FlutterGemmaPlugin.instance.createModel(
        modelType: _config.modelType,
        maxTokens: _config.maxTokens,
      );
      return true;
    } catch (e) {
      debugLog('LocalLlmBridge.loadModel failed: $e');
      return false;
    }
  }

  /// 卸载模型，释放内存
  @override
  Future<void> unloadModel() async {
    try {
      await _model?.close();
    } catch (e) {
      debugLog('LocalLlmBridge.unloadModel failed: $e');
    }
    _model = null;
  }

  /// 生成（非流式）。模型未就绪时自动加载；失败/不支持返回 null。
  ///
  /// **每次生成用独立会话**（用完即关），避免多次调用共享同一会话导致上下文
  /// 跨请求串台、无限增长——`AiProviderRouter` 消费的是一次性 generate。
  @override
  Future<String?> generate(String prompt, {int maxTokens = 512}) async {
    if (!_platformSupported || !_config.hasModelSource) return null;
    try {
      if (_model == null) {
        final ok = await loadModel();
        if (!ok) return null;
      }
      final session = await _model!.createSession();
      try {
        await session.addQueryChunk(Message.text(text: prompt));
        return await session.getResponse();
      } finally {
        await session.close();
      }
    } catch (e) {
      debugLog('LocalLlmBridge.generate failed: $e');
      return null;
    }
  }
}

/// 本地大模型状态
enum LocalLlmState { unavailable, notDownloaded, downloading, ready }

/// 本地设备推理服务（模型生命周期 + 生成）
///
/// 经 [LocalLlmBridge]（flutter_gemma）调用设备端推理。**未配置模型源/原生不可用时
/// [state] 恒为 `unavailable`**，AI 请求由 [AiProviderRouter] 回退云端——不误导。
class LocalLlmService {
  final LocalLlmBackend _bridge;

  LocalLlmService(this._bridge);

  final ValueNotifier<LocalLlmState> stateNotifier =
      ValueNotifier<LocalLlmState>(LocalLlmState.unavailable);

  /// 下载进度（0.0–1.0），仅 downloading 态有意义
  final ValueNotifier<double> downloadProgress = ValueNotifier<double>(0);

  /// 用户是否启用端侧推理（开关；默认关）
  bool enabled = false;

  LocalLlmState get state => stateNotifier.value;

  bool get isReady => enabled && state == LocalLlmState.ready;

  /// 运行时配置模型源后重新探测
  Future<void> configure(LocalLlmConfig config) async {
    _bridge.configure(config);
    await init();
  }

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
    downloadProgress.value = 0;
    final ok = await _bridge.downloadModel(
      onProgress: (p) => downloadProgress.value = p.clamp(0.0, 1.0),
    );
    stateNotifier.value =
        ok ? LocalLlmState.ready : LocalLlmState.notDownloaded;
  }

  Future<String?> generate(String prompt, {int maxTokens = 512}) {
    if (!isReady) return Future<String?>.value(null);
    return _bridge.generate(prompt, maxTokens: maxTokens);
  }

  void dispose() {
    stateNotifier.dispose();
    downloadProgress.dispose();
  }
}
