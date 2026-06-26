import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'media_lifecycle_service.dart';
import '../utils/debug_log.dart';

/// 下载任务状态
enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}

/// 下载任务
class DownloadTask {
  final String id;
  final String url;
  final String savePath;
  final String? fileName;
  final Map<String, String>? headers;
  double progress;
  DownloadStatus status;
  int totalBytes;
  int receivedBytes;
  String? error;

  /// 媒体元数据（用于生命周期管理注册）
  /// 支持的 key: roomId, eventId, mxcUrl, fileCategory, isThumbnail
  final Map<String, String>? metadata;

  DownloadTask({
    required this.id,
    required this.url,
    required this.savePath,
    this.fileName,
    this.headers,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.totalBytes = 0,
    this.receivedBytes = 0,
    this.error,
    this.metadata,
  });
}

/// 统一下载服务
///
/// 使用 http 包 + StreamedResponse 实现进度跟踪
/// 最大并发数: 3
class DownloadService {
  static const int _maxConcurrent = 3;

  final Map<String, DownloadTask> _tasks = {};
  final Map<String, StreamController<DownloadTask>> _taskControllers = {};
  final Map<String, http.Client> _activeClients = {};
  int _activeCount = 0;
  int _taskIdCounter = 0;

  /// 所有活跃的下载任务
  List<DownloadTask> get activeTasks =>
      _tasks.values.where((t) => t.status == DownloadStatus.downloading || t.status == DownloadStatus.pending).toList();

  /// 下载文件
  ///
  /// 返回下载任务 ID
  /// 媒体生命周期服务（可选注入）
  MediaLifecycleService? _mediaLifecycle;

  /// 设置媒体生命周期服务
  void setMediaLifecycleService(MediaLifecycleService service) {
    _mediaLifecycle = service;
  }

  /// 下载文件
  ///
  /// 返回下载任务 ID
  /// [metadata] 用于媒体生命周期管理，支持 key: roomId, eventId, mxcUrl, fileCategory, isThumbnail
  Future<String> download({
    required String url,
    required String savePath,
    String? fileName,
    Map<String, String>? headers,
    Map<String, String>? metadata,
  }) async {
    final taskId = 'download_${_taskIdCounter++}';
    final task = DownloadTask(
      id: taskId,
      url: url,
      savePath: savePath,
      fileName: fileName,
      headers: headers == null ? null : Map<String, String>.from(headers),
      metadata: metadata,
    );

    _tasks[taskId] = task;
    _taskControllers[taskId] = StreamController<DownloadTask>.broadcast();

    _startDownload(task);
    return taskId;
  }

  /// 监听下载任务进度
  Stream<DownloadTask> watchTask(String taskId) {
    return _taskControllers[taskId]?.stream ?? const Stream.empty();
  }

  /// 等待下载任务进入最终状态
  Future<DownloadTask> waitForTaskCompletion(String taskId) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw StateError('Unknown download task: $taskId');
    }

    if (_isTerminalStatus(task.status)) {
      return task;
    }

    return watchTask(taskId).firstWhere(
      (updatedTask) => _isTerminalStatus(updatedTask.status),
    );
  }

  /// 取消下载任务
  void cancelTask(String taskId) {
    final task = _tasks[taskId];
    if (task != null && task.status == DownloadStatus.downloading) {
      task.status = DownloadStatus.cancelled;
      // 关闭 HTTP client 以中断正在进行的网络流。
      // _activeCount 由 _executeDownload 的 finally 块统一管理，
      // 此处不再重复递减。
      _activeClients[taskId]?.close();
      _activeClients.remove(taskId);
      _notifyTask(task);
    }
  }

  /// 暂停下载任务（标记为取消，后续可通过 resumeTask 重新下载）
  void pauseTask(String taskId) {
    cancelTask(taskId);
  }

  /// 恢复下载任务
  void resumeTask(String taskId) {
    final task = _tasks[taskId];
    if (task != null && task.status == DownloadStatus.cancelled) {
      task.status = DownloadStatus.pending;
      task.progress = 0.0;
      task.receivedBytes = 0;
      _startDownload(task);
    }
  }

  void _startDownload(DownloadTask task) {
    if (_activeCount >= _maxConcurrent) {
      task.status = DownloadStatus.pending;
      _notifyTask(task);
      return;
    }

    _activeCount++;
    _executeDownload(task);
  }

  Future<void> _executeDownload(DownloadTask task) async {
    task.status = DownloadStatus.downloading;
    _notifyTask(task);

    final client = http.Client();
    _activeClients[task.id] = client;

    try {
      final request = http.Request('GET', Uri.parse(task.url));
      if (task.headers != null && task.headers!.isNotEmpty) {
        request.headers.addAll(task.headers!);
      }
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}');
      }

      task.totalBytes = response.contentLength ?? 0;
      final file = File(task.savePath);
      await file.parent.create(recursive: true);
      final sink = file.openWrite();

      try {
        await for (final chunk in response.stream) {
          if (task.status == DownloadStatus.cancelled) {
            return;
          }

          sink.add(chunk);
          task.receivedBytes += chunk.length;
          if (task.totalBytes > 0) {
            task.progress = task.receivedBytes / task.totalBytes;
          } else {
            // totalBytes 未知时标记为不确定进度
            task.progress = -1.0;
          }
          _notifyTask(task);
        }
      } finally {
        await sink.close();
      }

      task.status = DownloadStatus.completed;
      task.progress = 1.0;
      // 更新 totalBytes 为实际接收字节数（如果服务器未提供 Content-Length）
      if (task.totalBytes == 0) {
        task.totalBytes = task.receivedBytes;
      }
      _notifyTask(task);

      // 注册到媒体生命周期管理
      try {
        if (_mediaLifecycle != null && task.metadata != null) {
          final meta = task.metadata!;
          final roomId = meta['roomId'];
          if (roomId != null && roomId.isNotEmpty) {
            await _mediaLifecycle!.registerMediaFile(
              filePath: task.savePath,
              roomId: roomId,
              mxcUrl: meta['mxcUrl'] ?? task.url,
              eventId: meta['eventId'],
              fileCategory: meta['fileCategory'],
              fileSize: task.totalBytes,
              isThumbnail: meta['isThumbnail'] == 'true',
            );
          }
        }
      } catch (e) {
        debugLog('DownloadService: Failed to register media: $e');
      }
    } catch (e) {
      if (task.status != DownloadStatus.cancelled) {
        task.status = DownloadStatus.failed;
        task.error = e.toString();
        _notifyTask(task);
      }
    } finally {
      client.close();
      _activeClients.remove(task.id);
      _activeCount--;
      _processQueue();
    }
  }

  void _processQueue() {
    // 找到等待中的任务并启动
    for (final task in _tasks.values) {
      if (task.status == DownloadStatus.pending && _activeCount < _maxConcurrent) {
        _activeCount++;
        _executeDownload(task);
      }
    }
  }

  void _notifyTask(DownloadTask task) {
    _taskControllers[task.id]?.add(task);
  }

  bool _isTerminalStatus(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
      case DownloadStatus.failed:
      case DownloadStatus.cancelled:
        return true;
      case DownloadStatus.pending:
      case DownloadStatus.downloading:
        return false;
    }
  }

  /// 获取默认下载目录
  static Future<String> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      return '${dir?.path ?? '/storage/emulated/0/Download'}/N42';
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/Downloads';
    }
  }

  /// 清理已完成的任务
  void clearCompleted() {
    final terminalIds = _tasks.entries
        .where((e) => _isTerminalStatus(e.value.status))
        .map((e) => e.key)
        .toList();

    for (final id in terminalIds) {
      _taskControllers[id]?.close();
      _taskControllers.remove(id);
      _tasks.remove(id);
    }
  }

  /// 释放资源
  void dispose() {
    for (final controller in _taskControllers.values) {
      controller.close();
    }
    _taskControllers.clear();
    _tasks.clear();
  }
}
