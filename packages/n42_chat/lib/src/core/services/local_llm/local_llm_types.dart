/// 设备本地推理能力。
class DeviceCapability {
  const DeviceCapability({
    required this.supported,
    this.availableMemoryMb = 0,
    this.hasGpu = false,
    this.hasNpu = false,
    this.recommendedQuantization = 'int4',
  });

  const DeviceCapability.unsupported()
      : supported = false,
        availableMemoryMb = 0,
        hasGpu = false,
        hasNpu = false,
        recommendedQuantization = 'int4';

  final bool supported;
  final int availableMemoryMb;
  final bool hasGpu;
  final bool hasNpu;
  final String recommendedQuantization;

  /// 是否有足够内存加载 4B 参数 INT4 量化模型（约 2.5 GB）。
  bool get canRunGemma4b => supported && availableMemoryMb >= 3000;

  /// 是否有足够内存加载 2B 参数 INT4 量化模型（约 1.2 GB）。
  bool get canRunGemma2b => supported && availableMemoryMb >= 1500;
}

/// 模型量化格式。
enum ModelQuantization {
  /// 4-bit 整数量化（最小体积，适合移动端）
  int4('INT4', 'int4'),
  /// 8-bit 整数量化（平衡精度与大小）
  int8('INT8', 'int8'),
  /// 16-bit 浮点（高精度，需要大内存）
  float16('FP16', 'float16');

  const ModelQuantization(this.label, this.id);
  final String label;
  final String id;
}

/// 本地模型描述。
class LocalModelInfo {
  const LocalModelInfo({
    required this.id,
    required this.name,
    required this.family,
    required this.parameterCount,
    required this.quantization,
    required this.downloadUrl,
    required this.fileSizeBytes,
    this.sha256,
    this.description,
  });

  final String id;
  final String name;
  final String family;
  final String parameterCount;
  final ModelQuantization quantization;
  final String downloadUrl;
  final int fileSizeBytes;
  final String? sha256;
  final String? description;

  String get fileSizeMb => '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';

  /// 预置模型列表。
  static const List<LocalModelInfo> presets = [
    LocalModelInfo(
      id: 'gemma-3-4b-it-int4',
      name: 'Gemma 3 4B IT',
      family: 'gemma',
      parameterCount: '4B',
      quantization: ModelQuantization.int4,
      downloadUrl: 'https://huggingface.co/google/gemma-3-4b-it/resolve/main/gemma-3-4b-it-int4.task',
      fileSizeBytes: 2500 * 1024 * 1024,
      description: '最新 Gemma 3 指令调优模型，4B 参数 INT4 量化，适合移动端',
    ),
    LocalModelInfo(
      id: 'gemma-3-2b-it-int4',
      name: 'Gemma 3 2B IT',
      family: 'gemma',
      parameterCount: '2B',
      quantization: ModelQuantization.int4,
      downloadUrl: 'https://huggingface.co/google/gemma-3-2b-it/resolve/main/gemma-3-2b-it-int4.task',
      fileSizeBytes: 1300 * 1024 * 1024,
      description: '轻量级 Gemma 3，2B 参数，低端设备也能运行',
    ),
  ];
}

/// 模型下载状态。
enum ModelDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
  failed,
  verifying,
}

/// 模型下载进度。
class ModelDownloadProgress {
  const ModelDownloadProgress({
    required this.modelId,
    required this.status,
    this.bytesReceived = 0,
    this.totalBytes = 0,
    this.error,
  });

  final String modelId;
  final ModelDownloadStatus status;
  final int bytesReceived;
  final int totalBytes;
  final String? error;

  double get progress =>
      totalBytes > 0 ? bytesReceived / totalBytes : 0.0;

  String get progressText {
    if (totalBytes <= 0) return '';
    final receivedMb = (bytesReceived / (1024 * 1024)).toStringAsFixed(1);
    final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(0);
    return '$receivedMb / $totalMb MB';
  }
}
