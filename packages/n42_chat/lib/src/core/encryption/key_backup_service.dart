import 'package:matrix/matrix.dart' as matrix;
import '../utils/debug_log.dart';

/// 密钥备份服务
///
/// 管理加密密钥的备份和恢复
class KeyBackupService {
  final matrix.Client _client;

  KeyBackupService(this._client);

  /// 是否存在密钥备份
  Future<bool> hasKeyBackup() async {
    try {
      final encryption = _client.encryption;
      if (encryption == null) return false;

      return encryption.keyManager.enabled;
    } catch (e) {
      return false;
    }
  }

  /// 获取密钥备份信息
  ///
  /// 从服务端获取真实的备份版本信息
  Future<KeyBackupInfo?> getBackupInfo() async {
    try {
      final encryption = _client.encryption;
      if (encryption == null) return null;

      if (!encryption.keyManager.enabled) return null;

      final info = await encryption.keyManager.getRoomKeysBackupInfo();
      return KeyBackupInfo(
        version: info.version,
        algorithm: info.algorithm.name,
        count: info.count,
        etag: info.etag,
      );
    } catch (e) {
      debugLog('KeyBackupService: Failed to get backup info: $e');
      return null;
    }
  }

  /// 创建新的密钥备份
  ///
  /// 启用服务端密钥备份并开始自动上传 inbound group sessions
  Future<String?> createKeyBackup(String password) async {
    try {
      final encryption = _client.encryption;
      if (encryption == null) return null;

      // 启用自动密钥上传（每次同步后自动上传未备份的密钥）
      encryption.keyManager.startAutoUploadKeys();

      // 立即触发一次全量上传
      await encryption.keyManager.uploadInboundGroupSessions();

      debugLog('KeyBackupService: Key backup created and auto-upload enabled');
      return 'backup_created';
    } catch (e) {
      throw KeyBackupException('Failed to create backup: $e');
    }
  }

  /// 从密码恢复密钥备份
  ///
  /// 使用密码解锁 SSSS，然后通过 SSSS 中存储的 megolm backup 密钥恢复
  Future<int> restoreFromPassword(String password) async {
    try {
      final encryption = _client.encryption;
      if (encryption == null) {
        throw KeyBackupException('Encryption not initialized');
      }

      // 1. 使用密码解锁 SSSS
      final openSsss = encryption.ssss.open();
      await openSsss.unlock(passphrase: password);

      // 2. 缓存所有秘密（包含 megolm backup 密钥）
      await openSsss.maybeCacheAll();

      // 3. 从服务端备份主动下载所有房间密钥
      try {
        await encryption.keyManager.loadAllKeys();
        debugLog('KeyBackupService: All room keys loaded from backup');
      } catch (e) {
        debugLog('KeyBackupService: loadAllKeys skipped: $e');
      }

      // 4. 启用自动密钥上传
      encryption.keyManager.startAutoUploadKeys();

      debugLog('KeyBackupService: Restored from password successfully');
      return 1;
    } catch (e) {
      if (e is KeyBackupException) rethrow;
      throw KeyBackupException('Failed to restore from password: $e');
    }
  }

  /// 从恢复密钥恢复
  ///
  /// 使用恢复密钥解锁 SSSS 并恢复所有密钥备份
  Future<int> restoreFromRecoveryKey(String recoveryKey) async {
    try {
      final encryption = _client.encryption;
      if (encryption == null) {
        throw KeyBackupException('Encryption not initialized');
      }

      // 1. 使用恢复密钥解锁 SSSS
      final openSsss = encryption.ssss.open();
      await openSsss.unlock(recoveryKey: recoveryKey);

      // 2. 缓存所有秘密
      await openSsss.maybeCacheAll();

      // 3. 恢复 cross-signing
      try {
        await encryption.crossSigning.selfSign(recoveryKey: recoveryKey);
      } catch (e) {
        debugLog('KeyBackupService: Cross-signing restore skipped: $e');
      }

      // 4. 从服务端备份主动下载所有房间密钥
      try {
        await encryption.keyManager.loadAllKeys();
        debugLog('KeyBackupService: All room keys loaded from backup');
      } catch (e) {
        debugLog('KeyBackupService: loadAllKeys skipped: $e');
      }

      // 5. 启用自动密钥上传
      encryption.keyManager.startAutoUploadKeys();

      debugLog('KeyBackupService: Restored from recovery key successfully');
      return 1;
    } catch (e) {
      if (e is KeyBackupException) rethrow;
      throw KeyBackupException('Failed to restore from recovery key: $e');
    }
  }

  /// 删除密钥备份
  Future<void> deleteKeyBackup() async {
    try {
      final encryption = _client.encryption;
      if (encryption == null) return;

      if (!encryption.keyManager.enabled) return;

      final info = await encryption.keyManager.getRoomKeysBackupInfo();
      await _client.deleteRoomKeysVersion(info.version);
      debugLog('KeyBackupService: Backup version ${info.version} deleted');
    } catch (e) {
      throw KeyBackupException('Failed to delete backup: $e');
    }
  }

  /// 备份所有密钥
  ///
  /// 立即上传所有未备份的 inbound group sessions 到服务端
  Future<void> backupAllKeys() async {
    try {
      final encryption = _client.encryption;
      if (encryption == null) return;

      await encryption.keyManager.uploadInboundGroupSessions();
      debugLog('KeyBackupService: All keys uploaded successfully');
    } catch (e) {
      throw KeyBackupException('Failed to backup keys: $e');
    }
  }

  /// 获取备份状态
  KeyBackupStatus get status {
    final encryption = _client.encryption;
    if (encryption == null) {
      return KeyBackupStatus.notAvailable;
    }

    if (encryption.keyManager.enabled) {
      return KeyBackupStatus.enabled;
    }

    return KeyBackupStatus.disabled;
  }
}

/// 密钥备份信息
class KeyBackupInfo {
  final String version;
  final String algorithm;
  final int count;
  final String etag;

  KeyBackupInfo({
    required this.version,
    required this.algorithm,
    required this.count,
    required this.etag,
  });
}

/// 密钥备份状态
enum KeyBackupStatus {
  /// 不可用
  notAvailable,

  /// 已禁用
  disabled,

  /// 已启用
  enabled,
}

/// 密钥备份异常
class KeyBackupException implements Exception {
  final String message;

  KeyBackupException(this.message);

  @override
  String toString() => 'KeyBackupException: $message';
}
