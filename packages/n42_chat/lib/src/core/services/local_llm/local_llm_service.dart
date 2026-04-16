import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/debug_log.dart';
import 'local_llm_bridge.dart';
import 'local_llm_types.dart';

/// 本地 LLM 推理服务。
///
/// 管理模型下载、加载/卸载生命周期、推理调用。
/// 底层通过 [LocalLlmBridge]（MethodChannel）调用原生推理引擎。
class LocalLlmService {
  LocalLlmService({
    LocalLlmBridge? bridge,
    Dio? dio,
  })  : _bridge = bridge ?? LocalLlmBridge(),
        _dio = dio ?? Dio();

  final LocalLlmBridge _bridge;
  final Dio _dio;

  static const _activeModelKey = 'n42_local_llm_active_model';

  // 状态
  final ValueNotifier<bool> isModelLoaded = ValueNotifier(false);
  final ValueNotifier<String?> activeModelId = ValueNotifier(null);
  final BehaviorSubject<ModelDownloadProgress?> downloadProgress =
      BehaviorSubject.seeded(null);

  DeviceCapability? _capability;
  CancelToken? _downloadCancelToken;

  /// 检查设备能力（缓存结果）。
  Future<DeviceCapability> getCapability() async {
    _capability ??= await _bridge.checkCapability();
    return _capability!;
  }

  /// 获取推荐的模型（根据设备能力）。
  Future<LocalModelInfo?> getRecommendedModel() async {
    final cap = await getCapability();
    if (cap.canRunGemma4b) {
      return LocalModelInfo.presets.firstWhere(
        (m) => m.parameterCount == '4B',
        orElse: () => LocalModelInfo.presets.first,
      );
    }
    if (cap.canRunGemma2b) {
      return LocalModelInfo.presets.firstWhere(
        (m) => m.parameterCount == '2B',
        orElse: () => LocalModelInfo.presets.first,
      );
    }
    return null;
  }

  /// 模型文件本地路径。
  Future<String> _modelPath(String modelId) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(p.join(dir.path, 'local_models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return p.join(modelsDir.path, '$modelId.task');
  }

  /// 检查模型是否已下载。
  Future<bool> isModelDownloaded(String modelId) async {
    final path = await _modelPath(modelId);
    return File(path).existsSync();
  }

  /// 获取所有已下载模型的 ID。
  Future<List<String>> getDownloadedModelIds() async {
    final results = <String>[];
    for (final preset in LocalModelInfo.presets) {
      if (await isModelDownloaded(preset.id)) {
        results.add(preset.id);
      }
    }
    return results;
  }

  bool _isDownloading = false;

  /// 下载模型文件。
  Future<bool> downloadModel(LocalModelInfo model) async {
    if (_isDownloading) {
      debugLog('LocalLlm: Download already in progress, ignoring');
      return false;
    }

    final path = await _modelPath(model.id);
    final file = File(path);
    if (await file.exists() && await file.length() > 0) {
      debugLog('LocalLlm: Model ${model.id} already downloaded');
      return true;
    }

    _isDownloading = true;
    _downloadCancelToken?.cancel();
    _downloadCancelToken = CancelToken();

    downloadProgress.add(ModelDownloadProgress(
      modelId: model.id,
      status: ModelDownloadStatus.downloading,
      totalBytes: model.fileSizeBytes,
    ));

    try {
      await _dio.download(
        model.downloadUrl,
        path,
        cancelToken: _downloadCancelToken,
        onReceiveProgress: (received, total) {
          downloadProgress.add(ModelDownloadProgress(
            modelId: model.id,
            status: ModelDownloadStatus.downloading,
            bytesReceived: received,
            totalBytes: total > 0 ? total : model.fileSizeBytes,
          ));
        },
      );

      downloadProgress.add(ModelDownloadProgress(
        modelId: model.id,
        status: ModelDownloadStatus.downloaded,
        bytesReceived: model.fileSizeBytes,
        totalBytes: model.fileSizeBytes,
      ));
      debugLog('LocalLlm: Model ${model.id} downloaded to $path');
      _isDownloading = false;
      return true;
    } catch (e) {
      _isDownloading = false;
      if (e is DioException && e.type == DioExceptionType.cancel) {
        downloadProgress.add(ModelDownloadProgress(
          modelId: model.id,
          status: ModelDownloadStatus.notDownloaded,
        ));
        return false;
      }
      downloadProgress.add(ModelDownloadProgress(
        modelId: model.id,
        status: ModelDownloadStatus.failed,
        error: e.toString(),
      ));
      debugLog('LocalLlm: Download failed - $e');
      try { await File(path).delete(); } catch (_) {}
      return false;
    }
  }

  /// 取消进行中的下载。
  void cancelDownload() {
    _downloadCancelToken?.cancel();
    _downloadCancelToken = null;
  }

  /// 删除已下载的模型。
  Future<void> deleteModel(String modelId) async {
    if (activeModelId.value == modelId) {
      await unloadModel();
    }
    final path = await _modelPath(modelId);
    try {
      await File(path).delete();
    } catch (_) {}
    downloadProgress.add(ModelDownloadProgress(
      modelId: modelId,
      status: ModelDownloadStatus.notDownloaded,
    ));
  }

  /// 加载模型到推理引擎。
  Future<bool> loadModel(String modelId, {int maxTokens = 2048}) async {
    final path = await _modelPath(modelId);
    if (!File(path).existsSync()) {
      debugLog('LocalLlm: Model file not found: $path');
      return false;
    }

    if (isModelLoaded.value) {
      await unloadModel();
    }

    final ok = await _bridge.loadModel(
      modelPath: path,
      maxTokens: maxTokens,
    );
    if (ok) {
      isModelLoaded.value = true;
      activeModelId.value = modelId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeModelKey, modelId);
      debugLog('LocalLlm: Model $modelId loaded');
    }
    return ok;
  }

  /// 卸载当前模型。
  Future<void> unloadModel() async {
    await _bridge.unloadModel();
    isModelLoaded.value = false;
    activeModelId.value = null;
  }

  /// 自动加载上次使用的模型（启动时调用）。
  Future<bool> autoLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final lastModelId = prefs.getString(_activeModelKey);
    if (lastModelId == null) return false;
    if (!await isModelDownloaded(lastModelId)) return false;
    return loadModel(lastModelId);
  }

  /// 非流式推理。
  Future<String?> generate(String prompt, {int maxOutputTokens = 512}) {
    if (!isModelLoaded.value) return Future.value(null);
    return _bridge.generate(prompt: prompt, maxOutputTokens: maxOutputTokens);
  }

  /// 流式推理。
  Stream<String> generateStream(String prompt, {int maxOutputTokens = 512}) {
    if (!isModelLoaded.value) return const Stream.empty();
    return _bridge.generateStream(
      prompt: prompt,
      maxOutputTokens: maxOutputTokens,
    );
  }

  /// 获取已用磁盘空间。
  Future<int> getUsedDiskBytes() async {
    int total = 0;
    for (final preset in LocalModelInfo.presets) {
      final path = await _modelPath(preset.id);
      final file = File(path);
      if (await file.exists()) {
        total += await file.length();
      }
    }
    return total;
  }

  Future<void> dispose() async {
    cancelDownload();
    await unloadModel();
    isModelLoaded.dispose();
    activeModelId.dispose();
    await downloadProgress.close();
  }
}
