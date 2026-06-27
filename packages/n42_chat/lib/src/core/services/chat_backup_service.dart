import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:uuid/uuid.dart';

import '../../data/datasources/local/archive_database.dart';
import '../../data/datasources/local/preferences_datasource.dart';
import '../../data/datasources/local/secure_storage_datasource.dart';
import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../constants/app_constants.dart';
import 'message_archive_service.dart';
import '../utils/debug_log.dart';

/// 备份结果
class BackupResult {
  final String backupId;
  final String filePath;
  final int fileSizeBytes;
  final int roomCount;
  final int messageCount;
  final DateTime createdAt;
  final List<String> warnings;

  const BackupResult({
    required this.backupId,
    required this.filePath,
    required this.fileSizeBytes,
    required this.roomCount,
    required this.messageCount,
    required this.createdAt,
    this.warnings = const [],
  });
}

/// 备份大小估算
class BackupSizeEstimate {
  final int estimatedBytes;
  final int roomCount;
  final bool includesMedia;

  const BackupSizeEstimate({
    required this.estimatedBytes,
    required this.roomCount,
    required this.includesMedia,
  });

  String get formattedSize {
    if (estimatedBytes < 1024) return '$estimatedBytes B';
    if (estimatedBytes < 1024 * 1024) {
      return '${(estimatedBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (estimatedBytes < 1024 * 1024 * 1024) {
      return '${(estimatedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(estimatedBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 备份信息
class BackupInfo {
  final String backupId;
  final String filePath;
  final int fileSizeBytes;
  final DateTime createdAt;
  final int roomCount;
  final bool includesMedia;
  final bool includesKeys;

  const BackupInfo({
    required this.backupId,
    required this.filePath,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.roomCount,
    required this.includesMedia,
    required this.includesKeys,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-'
        '${createdAt.day.toString().padLeft(2, '0')} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

/// 备份预览
class BackupPreview {
  final String backupId;
  final DateTime createdAt;
  final int roomCount;
  final List<String> roomNames;
  final bool hasMedia;
  final bool hasKeys;
  final bool hasSettings;

  const BackupPreview({
    required this.backupId,
    required this.createdAt,
    required this.roomCount,
    required this.roomNames,
    required this.hasMedia,
    required this.hasKeys,
    required this.hasSettings,
  });
}

/// 恢复结果
class RestoreResult {
  final int roomsRestored;
  final int settingsRestored;
  final bool keysRestored;
  final List<String> errors;
  final List<String> warnings;

  const RestoreResult({
    this.roomsRestored = 0,
    this.settingsRestored = 0,
    this.keysRestored = false,
    this.errors = const [],
    this.warnings = const [],
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}

/// 聊天备份与恢复服务
///
/// 备份格式: .n42backup = JSON 打包（纯文本，可选密码保护）
/// 内容: manifest.json + rooms/{roomId}/messages.json + settings/ + encryption/keys.json
class ChatBackupService {
  static const String _appVersion = '0.1.0'; // TODO: 从 package_info_plus 动态获取
  static const String _backupSettingPreferencesKey = 'n42_chat_settings';
  static const String _backupAppearancePreferencesKey =
      'n42_chat_appearance_settings';
  static const String _backupAutoDownloadPreferencesKey =
      'n42_chat_auto_download_settings';
  static const String _backupMessageFontPreferencesKey =
      'n42_chat_message_font_size';
  static const String _backupTranslationPreferencesKey =
      'n42_chat_translation_settings';
  static const String _legacyLanguageKey = 'language';
  static const String _legacyThemeModeKey = 'theme_mode';
  static const String _legacyFontSizeKey = 'chat_font_size';
  static const String _legacyAutoDownloadKey = 'auto_download';
  static const Set<String> _supportedPreferenceBackupKeys = {
    _backupSettingPreferencesKey,
    _backupAppearancePreferencesKey,
    _backupAutoDownloadPreferencesKey,
    _backupMessageFontPreferencesKey,
    _backupTranslationPreferencesKey,
  };
  static const String _unsupportedKeyBackupWarning =
      'Encryption keys are backed up separately via Recovery Key in Security settings and are not included in .n42backup files.';

  final MatrixClientManager _clientManager;
  final SecureStorageDataSource _secureStorage;
  final PreferencesDataSource _preferencesStorage;
  MessageArchiveService? _archiveService;
  final Future<Directory> Function()? _backupDirProvider;

  /// SharedPreferences key: 最后增量备份时间戳（毫秒）
  static const String _keyLastIncrementalBackupTs =
      'n42_chat_last_incremental_backup_ts';

  ChatBackupService({
    required MatrixClientManager clientManager,
    required SecureStorageDataSource secureStorage,
    required PreferencesDataSource preferencesStorage,
    MessageArchiveService? archiveService,
    Future<Directory> Function()? backupDirProvider,
  }) : _clientManager = clientManager,
       _secureStorage = secureStorage,
       _preferencesStorage = preferencesStorage,
       _archiveService = archiveService,
       _backupDirProvider = backupDirProvider;

  /// 延迟注入归档服务
  void setArchiveService(MessageArchiveService service) {
    _archiveService = service;
  }

  /// 获取备份目录
  Future<Directory> _getBackupDir() async {
    if (_backupDirProvider != null) {
      final provided = await _backupDirProvider();
      if (!provided.existsSync()) {
        provided.createSync(recursive: true);
      }
      return provided;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(
      p.join(appDir.path, StorageConstants.backupDirName),
    );
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }
    return backupDir;
  }

  /// 创建备份
  Future<BackupResult> createBackup({
    List<String>? roomIds,
    bool includeMedia = false,
    bool includeKeys = false,
    String? password,
    void Function(double progress)? onProgress,
  }) async {
    final backupId = const Uuid().v4();
    final now = DateTime.now();
    final backupDir = await _getBackupDir();
    final warnings = <String>[];
    final fileName =
        'backup_${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${StorageConstants.backupExtension}';
    final filePath = p.join(backupDir.path, fileName);

    final client = _clientManager.client;
    if (client == null) throw StateError('Matrix client not available');

    final rooms = roomIds != null
        ? client.rooms.where((r) => roomIds.contains(r.id)).toList()
        : client.rooms;

    onProgress?.call(0.1);

    final includesKeysInBackup = await _collectKeyBackupSupport(
      includeKeys,
      warnings,
    );

    // 构建备份数据
    final backupData = <String, dynamic>{
      'manifest': {
        'backupId': backupId,
        'createdAt': now.toIso8601String(),
        'appVersion': _appVersion,
        'roomCount': rooms.length,
        'includesMedia': includeMedia,
        'includesKeys': includesKeysInBackup,
        'checksum': '',
      },
      'rooms': <String, dynamic>{},
      'settings': <String, dynamic>{},
    };

    // 导出房间数据
    int messageCount = 0;
    for (var i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      try {
        final roomData = <String, dynamic>{
          'id': room.id,
          'name': room.getLocalizedDisplayname(),
          'topic': room.topic,
          'isDirect': room.isDirectChat,
          'memberCount': room.summary.mJoinedMemberCount ?? 0,
        };

        // 获取消息（通过 room 的 lastEvent 等方式）
        // Matrix SDK v6 不提供直接的 timeline getter
        // 使用 room.getTimeline() 获取完整 timeline
        try {
          final timeline = await room.getTimeline();
          final events = timeline.events
              .where((e) => e.type == 'm.room.message')
              .take(1000)
              .map(
                (e) => {
                  'eventId': e.eventId,
                  'sender': e.senderId,
                  'type': e.messageType,
                  'body': e.body,
                  'timestamp': e.originServerTs.toIso8601String(),
                },
              )
              .toList();
          roomData['messages'] = events;
          messageCount += events.length;
        } catch (_) {
          // Timeline not available, skip messages
        }

        (backupData['rooms'] as Map<String, dynamic>)[room.id] = roomData;
      } catch (e) {
        debugLog('ChatBackupService: Failed to export room ${room.id}: $e');
      }

      onProgress?.call(0.1 + 0.7 * (i + 1) / rooms.length);
    }

    // 导出设置
    try {
      final settingsKeys = [
        _backupSettingPreferencesKey,
        _backupAppearancePreferencesKey,
        _backupAutoDownloadPreferencesKey,
        _backupMessageFontPreferencesKey,
        _backupTranslationPreferencesKey,
      ];
      final settings = <String, String?>{};
      for (final key in settingsKeys) {
        settings[key] = await _preferencesStorage.read(key);
      }
      backupData['settings'] = settings;
    } catch (e) {
      debugLog('ChatBackupService: Failed to export settings: $e');
    }

    onProgress?.call(0.85);

    // 写入文件
    final finalJsonStr = _finalizeBackupJson(backupData);

    if (password != null && password.isNotEmpty) {
      final encryptedBytes = _encryptAesGcm(
        utf8.encode(finalJsonStr),
        password,
      );
      final file = File(filePath);
      await file.writeAsBytes(encryptedBytes);
    } else {
      final file = File(filePath);
      await file.writeAsString(finalJsonStr);
    }

    onProgress?.call(1.0);

    final fileSize = await File(filePath).length();

    return BackupResult(
      backupId: backupId,
      filePath: filePath,
      fileSizeBytes: fileSize,
      roomCount: rooms.length,
      messageCount: messageCount,
      createdAt: now,
      warnings: warnings,
    );
  }

  /// 估算备份大小
  Future<BackupSizeEstimate> estimateBackupSize({
    List<String>? roomIds,
    bool includeMedia = false,
  }) async {
    final client = _clientManager.client;
    if (client == null) {
      return const BackupSizeEstimate(
        estimatedBytes: 0,
        roomCount: 0,
        includesMedia: false,
      );
    }

    final rooms = roomIds != null
        ? client.rooms.where((r) => roomIds.contains(r.id)).toList()
        : client.rooms;

    // 基于房间活跃度估算：有 lastEvent 的房间按 500 条估计，
    // 无活动的按 50 条估计。每条约 200 字节 + 每房间元数据约 500 字节。
    int estimatedMessages = 0;
    for (final room in rooms) {
      final hasActivity = room.lastEvent != null;
      estimatedMessages += hasActivity ? 500 : 50;
    }
    int estimated = estimatedMessages * 200 + rooms.length * 500;
    // 设置约 10KB
    estimated += 10 * 1024;

    return BackupSizeEstimate(
      estimatedBytes: estimated,
      roomCount: rooms.length,
      includesMedia: includeMedia,
    );
  }

  /// 列出所有备份
  Future<List<BackupInfo>> listBackups() async {
    final backupDir = await _getBackupDir();
    final results = <BackupInfo>[];

    if (!backupDir.existsSync()) return results;

    await for (final entity in backupDir.list()) {
      if (entity is File &&
          entity.path.endsWith(StorageConstants.backupExtension)) {
        try {
          final stat = await entity.stat();
          // 尝试读取 manifest
          final preview = await _readManifest(entity.path);
          results.add(
            BackupInfo(
              backupId:
                  preview?.backupId ?? p.basenameWithoutExtension(entity.path),
              filePath: entity.path,
              fileSizeBytes: stat.size,
              createdAt: preview?.createdAt ?? stat.modified,
              roomCount: preview?.roomCount ?? 0,
              includesMedia: preview?.hasMedia ?? false,
              includesKeys: preview?.hasKeys ?? false,
            ),
          );
        } catch (e) {
          debugLog('ChatBackupService: Failed to read backup: $e');
        }
      }
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  /// 删除备份
  Future<void> deleteBackup(String backupId) async {
    final backups = await listBackups();
    final target = backups.where((b) => b.backupId == backupId).firstOrNull;
    if (target != null) {
      final file = File(target.filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  /// 创建增量备份
  ///
  /// 只导出上次备份以来的新消息（包括热数据 + 归档数据）。
  /// 突破原 1000 条/房间限制，可备份完整归档历史。
  Future<BackupResult> createIncrementalBackup({
    List<String>? roomIds,
    String? password,
    void Function(double progress)? onProgress,
  }) async {
    final backupId = const Uuid().v4();
    final now = DateTime.now();
    final backupDir = await _getBackupDir();
    final fileName =
        'incremental_${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${StorageConstants.backupExtension}';
    final filePath = p.join(backupDir.path, fileName);

    final client = _clientManager.client;
    if (client == null) throw StateError('Matrix client not available');

    // 获取上次增量备份时间
    final lastBackupTs = await _getLastIncrementalBackupTs();

    final rooms = roomIds != null
        ? client.rooms.where((r) => roomIds.contains(r.id)).toList()
        : client.rooms;

    onProgress?.call(0.1);

    final backupData = <String, dynamic>{
      'manifest': {
        'backupId': backupId,
        'createdAt': now.toIso8601String(),
        'appVersion': _appVersion,
        'roomCount': rooms.length,
        'isIncremental': true,
        'lastBackupTimestamp': lastBackupTs,
        'checksum': '', // 写入后填充
      },
      'rooms': <String, dynamic>{},
    };

    int messageCount = 0;
    for (var i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      try {
        final roomData = <String, dynamic>{
          'id': room.id,
          'name': room.getLocalizedDisplayname(),
        };

        final messages = <Map<String, dynamic>>[];
        final seenEventIds = <String>{};

        void addMessage(Map<String, dynamic> message) {
          final eventId = message['eventId']?.toString();
          if (eventId != null &&
              eventId.isNotEmpty &&
              !seenEventIds.add(eventId)) {
            return;
          }
          messages.add(message);
        }

        // 1. 从 Timeline 获取热数据（新消息）
        try {
          final timeline = await room.getTimeline();
          for (final e in timeline.events) {
            if (e.type != 'm.room.message') continue;
            final ts = e.originServerTs.millisecondsSinceEpoch;
            if (lastBackupTs > 0 && ts <= lastBackupTs) continue;
            addMessage({
              'eventId': e.eventId,
              'sender': e.senderId,
              'type': e.messageType,
              'body': e.body,
              'timestamp': e.originServerTs.toIso8601String(),
              'ts': ts,
            });
          }
        } catch (e) {
          debugLog('ChatBackupService: Timeline error for ${room.id}: $e');
        }

        // 2. 从归档获取历史消息（分页加载，避免 OOM）
        if (_archiveService != null) {
          try {
            const pageSize = 500;
            int? cursor; // beforeTimestamp cursor for pagination
            bool hasMore = true;

            while (hasMore) {
              final archived = await _archiveService!.getArchivedMessages(
                room.id,
                beforeTimestamp: cursor,
                limit: pageSize,
              );

              if (archived.isEmpty) break;
              hasMore = archived.length == pageSize;

              bool reachedCutoff = false;
              for (final a in archived) {
                // Archive is ordered descending; once we pass the cutoff,
                // all remaining pages are older — stop early.
                if (lastBackupTs > 0 && a.originServerTs <= lastBackupTs) {
                  reachedCutoff = true;
                  break;
                }
                addMessage({
                  'eventId': a.eventId,
                  'sender': a.senderId,
                  'type': a.type,
                  'body': a.body ?? '',
                  'timestamp': DateTime.fromMillisecondsSinceEpoch(
                    a.originServerTs,
                  ).toIso8601String(),
                  'ts': a.originServerTs,
                  'msgtype': a.msgtype,
                  'formattedBody': a.formattedBody,
                  'mediaInfo': a.mediaInfo,
                  'relatesTo': a.relatesTo,
                  'isArchived': true,
                });
              }

              if (reachedCutoff) break;

              // Move cursor to oldest message timestamp for next page
              cursor = archived.last.originServerTs;
            }
          } catch (e) {
            debugLog('ChatBackupService: Archive error for ${room.id}: $e');
          }
        }

        roomData['messages'] = messages;
        messageCount += messages.length;
        (backupData['rooms'] as Map<String, dynamic>)[room.id] = roomData;
      } catch (e) {
        debugLog('ChatBackupService: Failed to backup room ${room.id}: $e');
      }

      onProgress?.call(0.1 + 0.7 * (i + 1) / rooms.length);
    }

    onProgress?.call(0.85);

    // 写入文件
    final finalJsonStr = _finalizeBackupJson(backupData);

    if (password != null && password.isNotEmpty) {
      final encryptedBytes = _encryptAesGcm(
        utf8.encode(finalJsonStr),
        password,
      );
      await File(filePath).writeAsBytes(encryptedBytes);
    } else {
      await File(filePath).writeAsString(finalJsonStr);
    }

    // 记录本次备份时间
    await _setLastIncrementalBackupTs(now.millisecondsSinceEpoch);

    onProgress?.call(1.0);

    final fileSize = await File(filePath).length();

    return BackupResult(
      backupId: backupId,
      filePath: filePath,
      fileSizeBytes: fileSize,
      roomCount: rooms.length,
      messageCount: messageCount,
      createdAt: now,
    );
  }

  /// 从备份恢复消息到归档数据库
  ///
  /// 与普通 restoreFromBackup 不同，此方法将消息写入 archive.db，
  /// 不依赖 homeserver 同步。
  Future<RestoreResult> restoreToArchive({
    required String backupFilePath,
    String? password,
    void Function(double progress)? onProgress,
  }) async {
    if (_archiveService == null) {
      return const RestoreResult(errors: ['Archive service not available']);
    }

    try {
      final data = await _readBackupData(backupFilePath, password: password);
      final rooms = data['rooms'] as Map<String, dynamic>? ?? {};
      final errors = <String>[];

      onProgress?.call(0.1);

      final archiveDb = _archiveService!;
      final roomEntries = rooms.entries.toList();
      var roomsRestored = 0;

      for (var i = 0; i < roomEntries.length; i++) {
        final entry = roomEntries[i];
        final roomId = entry.key;
        final roomData = entry.value as Map<String, dynamic>;
        final messages = (roomData['messages'] as List<dynamic>?) ?? [];
        final companions = <ArchivedMessagesCompanion>[];

        for (final msg in messages) {
          try {
            final msgMap = msg as Map<String, dynamic>;
            final eventId = msgMap['eventId']?.toString();
            if (eventId == null || eventId.isEmpty) {
              continue;
            }

            if (await archiveDb.isEventArchived(eventId)) {
              continue;
            }

            final companion = _backupMessageToArchiveCompanion(roomId, msgMap);
            if (companion != null) {
              companions.add(companion);
            }
          } catch (e) {
            errors.add('Failed to restore message in $roomId: $e');
          }
        }

        if (companions.isNotEmpty) {
          final inserted = await archiveDb.importArchivedMessages(
            roomId,
            companions,
          );
          if (inserted > 0) {
            roomsRestored++;
          }
        }

        onProgress?.call(0.1 + 0.9 * (i + 1) / roomEntries.length);
      }

      return RestoreResult(
        roomsRestored: roomsRestored,
        settingsRestored: 0,
        errors: errors,
      );
    } catch (e) {
      return RestoreResult(errors: ['Restore to archive failed: $e']);
    }
  }

  /// 获取上次增量备份时间戳
  Future<int> _getLastIncrementalBackupTs() async {
    try {
      final value = await _secureStorage.read(_keyLastIncrementalBackupTs);
      return int.tryParse(value ?? '') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// 记录增量备份时间戳
  Future<void> _setLastIncrementalBackupTs(int ts) async {
    await _secureStorage.write(_keyLastIncrementalBackupTs, ts.toString());
  }

  /// 预览备份内容
  Future<BackupPreview> previewBackup(
    String backupFilePath, {
    String? password,
  }) async {
    final data = await _readBackupData(backupFilePath, password: password);
    final manifest = data['manifest'] as Map<String, dynamic>? ?? {};
    final rooms = data['rooms'] as Map<String, dynamic>? ?? {};

    final roomNames = rooms.values
        .map(
          (r) => (r as Map<String, dynamic>)['name']?.toString() ?? 'Unknown',
        )
        .toList();

    return BackupPreview(
      backupId: manifest['backupId']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(manifest['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      roomCount: rooms.length,
      roomNames: roomNames,
      hasMedia: manifest['includesMedia'] == true,
      hasKeys: manifest['includesKeys'] == true,
      hasSettings: data.containsKey('settings'),
    );
  }

  /// 验证备份完整性
  Future<bool> verifyBackup(String backupFilePath, {String? password}) async {
    try {
      await _readBackupData(backupFilePath, password: password);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 从备份恢复
  Future<RestoreResult> restoreFromBackup({
    required String backupFilePath,
    String? password,
    List<String>? roomIds,
    bool restoreSettings = true,
    bool restoreKeys = false,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final data = await _readBackupData(backupFilePath, password: password);
      final rawSettings = data['settings'] as Map<String, dynamic>? ?? {};

      int settingsRestored = 0;
      final errors = <String>[];
      final warnings = <String>[];

      onProgress?.call(0.1);

      // 恢复设置
      if (restoreSettings && rawSettings.isNotEmpty) {
        final settings = await _normalizeRestorableSettings(rawSettings);
        for (final entry in settings.entries) {
          try {
            if (entry.value != null) {
              await _preferencesStorage.write(
                entry.key,
                entry.value.toString(),
              );
              settingsRestored++;
            }
          } catch (e) {
            errors.add('Failed to restore setting ${entry.key}: $e');
          }
        }
      }

      onProgress?.call(0.5);

      if (restoreKeys) {
        warnings.add(_unsupportedKeyBackupWarning);
      }

      // 注意：消息恢复依赖 Matrix 同步机制
      // 本地备份主要用于保留设置和加密密钥
      // 消息会在重新登录后从服务器同步

      onProgress?.call(1.0);

      return RestoreResult(
        roomsRestored: 0,
        settingsRestored: settingsRestored,
        keysRestored: false,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return RestoreResult(errors: ['Restore failed: $e']);
    }
  }

  Future<bool> _collectKeyBackupSupport(
    bool includeKeys,
    List<String> warnings,
  ) async {
    if (!includeKeys) return false;
    warnings.add(_unsupportedKeyBackupWarning);
    return false;
  }

  Future<Map<String, String?>> _normalizeRestorableSettings(
    Map<String, dynamic> rawSettings,
  ) async {
    final nestedSettings = rawSettings['preferences'];
    if (nestedSettings is Map<String, dynamic>) {
      return nestedSettings.map(
        (key, value) => MapEntry(key, value?.toString()),
      );
    }

    final normalized = <String, String?>{};
    for (final key in _supportedPreferenceBackupKeys) {
      if (rawSettings.containsKey(key)) {
        normalized[key] = rawSettings[key]?.toString();
      }
    }

    final legacySettings = await _normalizeLegacyRestorableSettings(
      rawSettings.map((key, value) => MapEntry(key, value?.toString())),
    );
    normalized.addAll(legacySettings);
    return normalized;
  }

  Future<Map<String, String?>> _normalizeLegacyRestorableSettings(
    Map<String, String?> rawSettings,
  ) async {
    final migrated = <String, String?>{};

    final legacyLanguage = rawSettings[_legacyLanguageKey];
    if (legacyLanguage != null && legacyLanguage.isNotEmpty) {
      migrated[_backupSettingPreferencesKey] = await _mergeJsonPreferenceMap(
        _backupSettingPreferencesKey,
        <String, String>{'n42_chat_language': legacyLanguage},
      );
    }

    final legacyThemeMode = rawSettings[_legacyThemeModeKey];
    if (legacyThemeMode != null && legacyThemeMode.isNotEmpty) {
      migrated[_backupAppearancePreferencesKey] = await _mergeJsonPreferenceMap(
        _backupAppearancePreferencesKey,
        <String, String>{'themeMode': legacyThemeMode},
        defaults: const <String, String>{
          'fontSize': 'medium',
          'bubbleStyle': 'wechat',
        },
      );
    }

    final legacyFontSize = rawSettings[_legacyFontSizeKey];
    if (legacyFontSize != null && legacyFontSize.isNotEmpty) {
      migrated[_backupMessageFontPreferencesKey] = legacyFontSize;
    }

    final legacyAutoDownload = rawSettings[_legacyAutoDownloadKey];
    if (legacyAutoDownload != null && legacyAutoDownload.isNotEmpty) {
      migrated[_backupAutoDownloadPreferencesKey] = legacyAutoDownload;
    }

    return migrated;
  }

  ArchivedMessagesCompanion? _backupMessageToArchiveCompanion(
    String roomId,
    Map<String, dynamic> msgMap,
  ) {
    final eventId = msgMap['eventId']?.toString();
    final senderId = msgMap['sender']?.toString();
    final ts =
        msgMap['ts'] as int? ??
        DateTime.tryParse(
          msgMap['timestamp']?.toString() ?? '',
        )?.millisecondsSinceEpoch;
    if (eventId == null || eventId.isEmpty || senderId == null || ts == null) {
      return null;
    }

    final rawType = msgMap['type']?.toString();
    final eventType =
        rawType == null ||
            rawType.isEmpty ||
            (rawType.startsWith('m.') &&
                rawType != 'm.room.message' &&
                rawType != 'm.room.encrypted' &&
                rawType != 'm.sticker')
        ? 'm.room.message'
        : rawType;
    final msgtype =
        msgMap['msgtype']?.toString() ??
        (eventType == 'm.room.message' ? rawType : null);
    final body = msgMap['body']?.toString();
    final formattedBody = msgMap['formattedBody']?.toString();
    final relatesTo = msgMap['relatesTo'];
    final mediaInfo = msgMap['mediaInfo'];
    final isEncrypted = msgMap['isEncrypted'] == true;

    return ArchivedMessagesCompanion(
      eventId: Value(eventId),
      roomId: Value(roomId),
      senderId: Value(senderId),
      originServerTs: Value(ts),
      type: Value(eventType),
      body: Value(body),
      formattedBody: Value(formattedBody),
      msgtype: Value(msgtype),
      relatesTo: Value(relatesTo == null ? null : jsonEncode(relatesTo)),
      mediaInfo: Value(mediaInfo == null ? null : jsonEncode(mediaInfo)),
      isEncrypted: Value(isEncrypted),
      decryptedBody: Value(
        msgMap['decryptedBody']?.toString() ?? (isEncrypted ? body : null),
      ),
      quarter: Value(timestampToQuarter(ts)),
      archivedAt: Value(DateTime.now()),
    );
  }

  Future<String> _mergeJsonPreferenceMap(
    String key,
    Map<String, String> updates, {
    Map<String, String> defaults = const <String, String>{},
  }) async {
    final current = await _preferencesStorage.read(key);
    final merged = <String, dynamic>{...defaults};
    if (current != null && current.isNotEmpty) {
      try {
        final currentJson = jsonDecode(current);
        if (currentJson is Map<String, dynamic>) {
          merged.addAll(currentJson);
        }
      } catch (_) {
        // Ignore corrupt local values and overwrite with migrated backup data.
      }
    }
    merged.addAll(updates);
    return jsonEncode(merged);
  }

  /// 读取备份数据
  Future<Map<String, dynamic>> _readBackupData(
    String filePath, {
    String? password,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    final header = utf8.decode(bytes.take(8).toList(), allowMalformed: true);

    if (header == 'N42ENC3:') {
      if (password == null || password.isEmpty) {
        throw StateError('This backup is password-protected');
      }
      final decrypted = _decryptAesGcm(bytes, password);
      final jsonStr = utf8.decode(decrypted);
      return _decodeBackupJson(jsonStr);
    }

    if (header == 'N42ENC2:') {
      if (password == null || password.isEmpty) {
        throw StateError('This backup is password-protected');
      }
      final decrypted = _decryptAes256(bytes, password);
      final jsonStr = utf8.decode(decrypted);
      return _decodeBackupJson(jsonStr);
    }

    // 兼容旧版 v1 XOR 加密格式（只读）
    final headerV1 = utf8.decode(bytes.take(7).toList(), allowMalformed: true);
    if (headerV1 == 'N42ENC:') {
      if (password == null || password.isEmpty) {
        throw StateError('This backup is password-protected');
      }
      final keyBytes = sha256.convert(utf8.encode(password)).bytes;
      final encryptedData = bytes.sublist(7);
      final decrypted = Uint8List(encryptedData.length);
      for (var i = 0; i < encryptedData.length; i++) {
        decrypted[i] = encryptedData[i] ^ keyBytes[i % keyBytes.length];
      }
      final jsonStr = utf8.decode(decrypted);
      return _decodeBackupJson(jsonStr);
    }

    final jsonStr = utf8.decode(bytes);
    return _decodeBackupJson(jsonStr);
  }

  String _finalizeBackupJson(Map<String, dynamic> backupData) {
    final manifest = backupData['manifest'] as Map<String, dynamic>;
    manifest['checksum'] = _computeBackupChecksum(backupData);
    return jsonEncode(backupData);
  }

  Map<String, dynamic> _decodeBackupJson(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup payload must be a JSON object');
    }
    _validateBackupStructure(decoded);
    _validateBackupChecksum(decoded);
    return decoded;
  }

  void _validateBackupStructure(Map<String, dynamic> backupData) {
    if (backupData['manifest'] is! Map<String, dynamic>) {
      throw const FormatException('Backup manifest is missing or invalid');
    }
    if (backupData['rooms'] is! Map<String, dynamic>) {
      throw const FormatException('Backup rooms payload is missing or invalid');
    }
  }

  void _validateBackupChecksum(Map<String, dynamic> backupData) {
    final manifest = backupData['manifest'] as Map<String, dynamic>;
    final checksum = manifest['checksum']?.toString();
    if (checksum == null || checksum.isEmpty) {
      return;
    }

    final actualChecksum = _computeBackupChecksum(backupData);
    if (actualChecksum != checksum) {
      throw const FormatException('Backup checksum mismatch');
    }
  }

  String _computeBackupChecksum(Map<String, dynamic> backupData) {
    final canonicalPayload = _canonicalizeJsonValue(backupData);
    final payload = jsonEncode(canonicalPayload);
    return sha256.convert(utf8.encode(payload)).toString();
  }

  dynamic _canonicalizeJsonValue(dynamic value, {bool omitChecksum = false}) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      final keys = value.keys.toList()..sort();
      for (final key in keys) {
        if (omitChecksum && key == 'checksum') {
          continue;
        }
        result[key] = _canonicalizeJsonValue(
          value[key],
          omitChecksum: omitChecksum || key == 'manifest',
        );
      }
      return result;
    }
    if (value is List) {
      return value
          .map(
            (entry) =>
                _canonicalizeJsonValue(entry, omitChecksum: omitChecksum),
          )
          .toList(growable: false);
    }
    return value;
  }

  /// PBKDF2 密钥派生（使用 pointycastle 实现）
  static Uint8List _pbkdf2(
    String password,
    Uint8List salt, {
    int iterations = 100000,
    int keyLength = 32,
  }) {
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
      ..init(pc.Pbkdf2Parameters(salt, iterations, keyLength));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// AES-256-CBC 加密（v2，保留用于向后兼容解密）
  /// 格式: "N42ENC2:" (8字节) + salt (32字节) + iv (16字节) + 加密数据
  // ignore: unused_element
  static Uint8List _encryptAes256(List<int> plaintext, String password) {
    final random = Random.secure();
    final salt = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
    final iv = Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );

    final key = _pbkdf2(password, salt, iterations: 100000, keyLength: 32);

    // PKCS7 填充
    const blockSize = 16;
    final padLength = blockSize - (plaintext.length % blockSize);
    final padded = Uint8List(plaintext.length + padLength);
    padded.setRange(0, plaintext.length, plaintext);
    for (var i = plaintext.length; i < padded.length; i++) {
      padded[i] = padLength;
    }

    final cipher = pc.CBCBlockCipher(pc.AESEngine())
      ..init(true, pc.ParametersWithIV(pc.KeyParameter(key), iv));

    final encrypted = Uint8List(padded.length);
    for (var offset = 0; offset < padded.length; offset += blockSize) {
      cipher.processBlock(padded, offset, encrypted, offset);
    }

    return Uint8List.fromList([
      ...utf8.encode('N42ENC2:'),
      ...salt,
      ...iv,
      ...encrypted,
    ]);
  }

  /// AES-256-CBC 解密
  static Uint8List _decryptAes256(Uint8List data, String password) {
    if (data.length < 72) {
      throw const FormatException('Encrypted backup is truncated');
    }

    // 跳过头部 "N42ENC2:" (8 字节)
    final salt = Uint8List.fromList(data.sublist(8, 40));
    final iv = Uint8List.fromList(data.sublist(40, 56));
    final ciphertext = Uint8List.fromList(data.sublist(56));
    if (ciphertext.isEmpty || ciphertext.length % 16 != 0) {
      throw const FormatException('Encrypted backup payload is invalid');
    }

    final key = _pbkdf2(password, salt, iterations: 100000, keyLength: 32);

    final cipher = pc.CBCBlockCipher(pc.AESEngine())
      ..init(false, pc.ParametersWithIV(pc.KeyParameter(key), iv));

    final decrypted = Uint8List(ciphertext.length);
    const blockSize = 16;
    for (var offset = 0; offset < ciphertext.length; offset += blockSize) {
      cipher.processBlock(ciphertext, offset, decrypted, offset);
    }

    // 移除 PKCS7 填充
    final padLength = decrypted.last;
    final isValidPadding =
        padLength > 0 &&
        padLength <= blockSize &&
        decrypted.length >= padLength &&
        decrypted
            .sublist(decrypted.length - padLength)
            .every((byte) => byte == padLength);
    if (isValidPadding) {
      return Uint8List.fromList(
        decrypted.sublist(0, decrypted.length - padLength),
      );
    }
    throw const FormatException('Encrypted backup password is invalid');
  }

  /// AES-256-GCM 加密（v3，带认证标签，防 padding oracle）
  /// 格式: "N42ENC3:" (8字节) + salt (32字节) + nonce (12字节) + tag (16字节) + 密文
  static Uint8List _encryptAesGcm(List<int> plaintext, String password) {
    final random = Random.secure();
    final salt = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
    final nonce = Uint8List.fromList(
      List.generate(12, (_) => random.nextInt(256)),
    );

    final key = _pbkdf2(password, salt, iterations: 100000, keyLength: 32);

    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(
        true,
        pc.AEADParameters(
          pc.KeyParameter(key),
          128, // tag length in bits
          nonce,
          Uint8List(0), // no associated data
        ),
      );

    final input = Uint8List.fromList(plaintext);
    final output = Uint8List(cipher.getOutputSize(input.length));
    final len = cipher.processBytes(input, 0, input.length, output, 0);
    cipher.doFinal(output, len);

    // output contains ciphertext + tag (appended by GCM)
    // Extract tag (last 16 bytes) and ciphertext
    final tagStart = output.length - 16;
    final tag = Uint8List.fromList(output.sublist(tagStart));
    final ciphertext = Uint8List.fromList(output.sublist(0, tagStart));

    return Uint8List.fromList([
      ...utf8.encode('N42ENC3:'),
      ...salt,
      ...nonce,
      ...tag,
      ...ciphertext,
    ]);
  }

  /// AES-256-GCM 解密
  static Uint8List _decryptAesGcm(Uint8List data, String password) {
    // Header(8) + salt(32) + nonce(12) + tag(16) = 68 minimum
    if (data.length < 68) {
      throw const FormatException('Encrypted backup is truncated');
    }

    final salt = Uint8List.fromList(data.sublist(8, 40));
    final nonce = Uint8List.fromList(data.sublist(40, 52));
    final tag = Uint8List.fromList(data.sublist(52, 68));
    final ciphertext = Uint8List.fromList(data.sublist(68));

    final key = _pbkdf2(password, salt, iterations: 100000, keyLength: 32);

    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(
        false,
        pc.AEADParameters(pc.KeyParameter(key), 128, nonce, Uint8List(0)),
      );

    // GCM expects ciphertext + tag concatenated
    final input = Uint8List.fromList([...ciphertext, ...tag]);
    final output = Uint8List(cipher.getOutputSize(input.length));
    try {
      final len = cipher.processBytes(input, 0, input.length, output, 0);
      cipher.doFinal(output, len);
    } on ArgumentError {
      throw const FormatException('Encrypted backup password is invalid');
    }

    // GCM output is plaintext (tag is verified internally)
    return Uint8List.fromList(output.sublist(0, ciphertext.length));
  }

  /// 读取备份 manifest（快速预览，不需要密码）
  ///
  /// 仅读取文件头部来检测加密状态，非加密文件读取前 64KB 解析 manifest。
  Future<BackupPreview?> _readManifest(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      // 先读取头部 8 字节检测加密
      final raf = await file.open(mode: FileMode.read);
      try {
        final header = await raf.read(8);
        final headerStr = utf8.decode(header, allowMalformed: true);
        if (headerStr == 'N42ENC3:' ||
            headerStr == 'N42ENC2:' ||
            headerStr.startsWith('N42ENC:')) {
          return null; // 加密文件无法快速预览
        }
      } finally {
        await raf.close();
      }

      // 非加密文件：读取前 64KB 尝试提取 manifest
      final fileSize = await file.length();
      final readSize = fileSize < 65536 ? fileSize : 65536;
      final raf2 = await file.open(mode: FileMode.read);
      try {
        final bytes = await raf2.read(readSize);
        final partial = utf8.decode(bytes, allowMalformed: true);

        // 尝试找到完整的 manifest JSON 块
        final manifestStart = partial.indexOf('"manifest"');
        if (manifestStart == -1) return null;

        // 如果文件较小，直接完整解析
        if (fileSize < 65536) {
          final data = jsonDecode(partial) as Map<String, dynamic>;
          final manifest = data['manifest'] as Map<String, dynamic>? ?? {};
          final rooms = data['rooms'] as Map<String, dynamic>? ?? {};
          return BackupPreview(
            backupId: manifest['backupId']?.toString() ?? '',
            createdAt:
                DateTime.tryParse(manifest['createdAt']?.toString() ?? '') ??
                DateTime.now(),
            roomCount: rooms.length,
            roomNames: [],
            hasMedia: manifest['includesMedia'] == true,
            hasKeys: manifest['includesKeys'] == true,
            hasSettings: data.containsKey('settings'),
          );
        }

        // 大文件：仅提取 manifest 部分
        // 找到 manifest 值的开始 '{' 和匹配的 '}'
        final objStart = partial.indexOf('{', manifestStart);
        if (objStart == -1) return null;
        int depth = 0;
        int objEnd = -1;
        for (var i = objStart; i < partial.length; i++) {
          if (partial[i] == '{') depth++;
          if (partial[i] == '}') depth--;
          if (depth == 0) {
            objEnd = i + 1;
            break;
          }
        }
        if (objEnd == -1) return null;

        final manifestJson = partial.substring(objStart, objEnd);
        final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
        return BackupPreview(
          backupId: manifest['backupId']?.toString() ?? '',
          createdAt:
              DateTime.tryParse(manifest['createdAt']?.toString() ?? '') ??
              DateTime.now(),
          roomCount: manifest['roomCount'] as int? ?? 0,
          roomNames: [],
          hasMedia: manifest['includesMedia'] == true,
          hasKeys: manifest['includesKeys'] == true,
          hasSettings: true, // 假定有设置
        );
      } finally {
        await raf2.close();
      }
    } catch (_) {
      return null;
    }
  }
}
