import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/local_llm/local_llm_service.dart';
import '../../../core/services/local_llm/local_llm_types.dart';

/// 本地 AI 模型管理页面。
///
/// - 显示设备能力评估
/// - 模型列表：下载进度 / 已下载 / 活跃
/// - 加载/卸载/删除操作
/// - 磁盘占用统计
class LocalLlmSettingsPage extends StatefulWidget {
  const LocalLlmSettingsPage({super.key});

  @override
  State<LocalLlmSettingsPage> createState() => _LocalLlmSettingsPageState();
}

class _LocalLlmSettingsPageState extends State<LocalLlmSettingsPage> {
  late final LocalLlmService _service;
  DeviceCapability? _capability;
  Map<String, bool> _downloadedMap = {};
  int _usedDiskBytes = 0;

  @override
  void initState() {
    super.initState();
    _service = getIt.isRegistered<LocalLlmService>()
        ? getIt<LocalLlmService>()
        : LocalLlmService();
    _loadState();
  }

  Future<void> _loadState() async {
    final cap = await _service.getCapability();
    final downloaded = <String, bool>{};
    for (final m in LocalModelInfo.presets) {
      downloaded[m.id] = await _service.isModelDownloaded(m.id);
    }
    final used = await _service.getUsedDiskBytes();
    if (mounted) {
      setState(() {
        _capability = cap;
        _downloadedMap = downloaded;
        _usedDiskBytes = used;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('本地 AI 模型')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCapabilityCard(theme),
          const SizedBox(height: 16),
          Text('可用模型', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...LocalModelInfo.presets.map(_buildModelCard),
          const SizedBox(height: 16),
          _buildDiskUsage(theme),
          const SizedBox(height: 24),
          _buildPrivacyNote(theme),
        ],
      ),
    );
  }

  Widget _buildCapabilityCard(ThemeData theme) {
    final cap = _capability;
    if (cap == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  cap.supported ? Icons.check_circle : Icons.error_outline,
                  color: cap.supported ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  cap.supported ? '设备支持本地推理' : '设备不支持本地推理',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('可用内存: ${cap.availableMemoryMb} MB'),
            Text('GPU: ${cap.hasGpu ? "可用" : "不可用"}'
                '  NPU: ${cap.hasNpu ? "可用" : "不可用"}'),
            Text('推荐量化: ${cap.recommendedQuantization.toUpperCase()}'),
            if (cap.canRunGemma4b)
              const Text('可运行 4B 参数模型',
                  style: TextStyle(color: Colors.green))
            else if (cap.canRunGemma2b)
              const Text('可运行 2B 参数模型',
                  style: TextStyle(color: Colors.orange))
            else
              const Text('内存不足，无法运行本地模型',
                  style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(LocalModelInfo model) {
    final isDownloaded = _downloadedMap[model.id] ?? false;
    final isActive = _service.activeModelId.value == model.id;
    final canRun = _capability != null &&
        ((model.parameterCount == '4B' && _capability!.canRunGemma4b) ||
            (model.parameterCount == '2B' && _capability!.canRunGemma2b));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(
                        '${model.parameterCount} · ${model.quantization.label} · ${model.fileSizeMb}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Chip(
                    label: const Text('运行中', style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.green[100],
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (model.description != null) ...[
              const SizedBox(height: 4),
              Text(model.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
            const SizedBox(height: 8),
            // 下载进度条
            StreamBuilder<ModelDownloadProgress?>(
              stream: _service.downloadProgress
                  .where((p) => p != null && p.modelId == model.id),
              builder: (context, snap) {
                final prog = snap.data;
                if (prog != null &&
                    prog.status == ModelDownloadStatus.downloading) {
                  return Column(
                    children: [
                      LinearProgressIndicator(value: prog.progress),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(prog.progressText,
                              style: const TextStyle(fontSize: 11)),
                          TextButton(
                            onPressed: _service.cancelDownload,
                            child: const Text('取消',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDownloaded)
                  FilledButton.tonal(
                    onPressed: canRun ? () => _download(model) : null,
                    child: const Text('下载'),
                  )
                else if (!isActive)
                  ...[
                    TextButton(
                      onPressed: () => _delete(model.id),
                      child: const Text('删除',
                          style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _load(model.id),
                      child: const Text('启用'),
                    ),
                  ]
                else
                  ...[
                    TextButton(
                      onPressed: _unload,
                      child: const Text('卸载'),
                    ),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiskUsage(ThemeData theme) {
    final usedMb = (_usedDiskBytes / (1024 * 1024)).toStringAsFixed(1);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.storage),
        title: const Text('本地模型占用'),
        subtitle: Text('$usedMb MB'),
        trailing: TextButton(
          onPressed: _clearAll,
          child: const Text('清除全部'),
        ),
      ),
    );
  }

  Widget _buildPrivacyNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '本地 AI 完全在设备端运行，数据不会上传到任何服务器。'
              '翻译、摘要、智能回复等功能均可离线使用。',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _download(LocalModelInfo model) async {
    await _service.downloadModel(model);
    await _loadState();
  }

  Future<void> _load(String modelId) async {
    final ok = await _service.loadModel(modelId);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模型已启用')),
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _unload() async {
    await _service.unloadModel();
    if (mounted) setState(() {});
  }

  Future<void> _delete(String modelId) async {
    await _service.deleteModel(modelId);
    await _loadState();
  }

  Future<void> _clearAll() async {
    for (final m in LocalModelInfo.presets) {
      await _service.deleteModel(m.id);
    }
    await _loadState();
  }
}
