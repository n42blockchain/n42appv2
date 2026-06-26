import 'package:matrix/encryption/utils/key_verification.dart' as kv;
import 'package:matrix/matrix.dart' as matrix;
import '../utils/debug_log.dart';

/// 端到端加密管理器
///
/// 封装Matrix SDK的加密功能，提供统一的加密接口
class E2EEManager {
  final matrix.Client _client;

  /// 缓存的恢复密钥（仅在当前会话中有效）
  String? _cachedRecoveryKey;

  E2EEManager(this._client);

  /// 是否支持加密
  bool get isEncryptionSupported => _client.encryptionEnabled;

  /// 是否已初始化加密
  bool get isEncryptionInitialized => _client.encryption != null;

  /// 获取加密状态
  E2EEStatus get status {
    if (!isEncryptionSupported) {
      return E2EEStatus.notSupported;
    }
    if (!isEncryptionInitialized) {
      return E2EEStatus.notInitialized;
    }
    return E2EEStatus.ready;
  }

  // ============================================
  // 密钥管理
  // ============================================

  /// 导出房间密钥（上传到服务端备份）
  ///
  /// 将所有 inbound group sessions 上传到服务端密钥备份。
  /// [password] 参数保留以备将来扩展本地加密导出。
  Future<String> exportRoomKeys(String password) async {
    if (!isEncryptionInitialized) {
      throw E2EEException('Encryption not initialized');
    }

    final encryption = _client.encryption;
    if (encryption == null) {
      throw E2EEException('Encryption not available');
    }

    try {
      // 上传所有 inbound group sessions 到服务端备份
      await encryption.keyManager.uploadInboundGroupSessions();
      debugLog('E2EEManager: Room keys exported to server backup');
      return 'exported_to_server_backup';
    } catch (e) {
      throw E2EEException('Failed to export room keys: $e');
    }
  }

  /// 导入房间密钥（从服务端备份恢复）
  ///
  /// 从服务端密钥备份下载并恢复所有 megolm 会话密钥。
  /// [password] 用于解锁 SSSS 以获取备份密钥。
  Future<int> importRoomKeys(String exportedKeys, String password) async {
    if (!isEncryptionInitialized) {
      throw E2EEException('Encryption not initialized');
    }

    final encryption = _client.encryption;
    if (encryption == null) {
      throw E2EEException('Encryption not available');
    }

    try {
      // 使用密码解锁 SSSS 并加载所有备份密钥
      final openSsss = encryption.ssss.open();
      await openSsss.unlock(passphrase: password);
      await openSsss.maybeCacheAll();

      // 从服务端备份恢复所有密钥
      await encryption.keyManager.loadAllKeys();
      debugLog('E2EEManager: Room keys imported from server backup');
      return 1;
    } catch (e) {
      throw E2EEException('Failed to import room keys: $e');
    }
  }

  /// 获取恢复密钥（用于跨设备恢复）
  ///
  /// 返回当前会话中缓存的恢复密钥。如果没有缓存则返回 null。
  /// 恢复密钥仅在 [createRecoveryKey] 创建后或 [unlockWithRecoveryKey] 解锁后可用。
  Future<String?> getRecoveryKey() async {
    return _cachedRecoveryKey;
  }

  /// 清除内存中缓存的恢复密钥
  ///
  /// 应在用户查看/保存恢复密钥后调用，以减少密钥在内存中的暴露时间。
  void clearCachedRecoveryKey() {
    _cachedRecoveryKey = null;
  }

  /// 创建新的恢复密钥
  ///
  /// 通过 SSSS（安全秘密存储）创建新的恢复密钥。
  /// 流程：创建 SSSS 密钥 → 初始化 cross-signing → 启用密钥自动上传
  /// 返回恢复密钥字符串，用户应安全保存此密钥。
  Future<String?> createRecoveryKey({String? passphrase}) async {
    final encryption = _client.encryption;
    if (encryption == null) return null;

    try {
      // 1. 通过 SSSS 创建新的默认密钥
      final openSsss = await encryption.ssss.createKey(passphrase);
      final recoveryKey = openSsss.recoveryKey;
      if (recoveryKey == null) {
        throw E2EEException('Failed to generate recovery key');
      }

      // 2. 设置为默认密钥
      await encryption.ssss.setDefaultKeyId(openSsss.keyId);

      // 3. 缓存恢复密钥和解锁的 SSSS
      _cachedRecoveryKey = recoveryKey;

      // 4. 存储 cross-signing 和 megolm backup 密钥到 SSSS
      try {
        await encryption.crossSigning.selfSign(
          recoveryKey: recoveryKey,
        );
      } catch (e) {
        debugLog('E2EEManager: Cross-signing self-sign skipped: $e');
      }

      // 5. 启用密钥自动上传到服务端备份
      encryption.keyManager.startAutoUploadKeys();

      debugLog('E2EEManager: Recovery key created successfully');
      return recoveryKey;
    } catch (e) {
      if (e is E2EEException) rethrow;
      throw E2EEException('Failed to create recovery key: $e');
    }
  }

  /// 使用恢复密钥解锁 SSSS 并恢复密钥
  ///
  /// 解锁后会缓存恢复密钥，并尝试恢复 cross-signing 和密钥备份
  Future<void> unlockWithRecoveryKey(String recoveryKey) async {
    final encryption = _client.encryption;
    if (encryption == null) {
      throw E2EEException('Encryption not initialized');
    }

    try {
      // 1. 打开 SSSS 并使用恢复密钥解锁
      final openSsss = encryption.ssss.open();
      await openSsss.unlock(recoveryKey: recoveryKey);

      // 2. 缓存所有秘密（cross-signing keys, megolm backup key 等）
      await openSsss.maybeCacheAll();

      // 3. 恢复 cross-signing
      try {
        await encryption.crossSigning.selfSign(recoveryKey: recoveryKey);
      } catch (e) {
        debugLog('E2EEManager: Cross-signing recovery skipped: $e');
      }

      // 4. 缓存恢复密钥
      _cachedRecoveryKey = recoveryKey;

      // 5. 启用自动密钥上传
      encryption.keyManager.startAutoUploadKeys();

      debugLog('E2EEManager: Unlocked with recovery key successfully');
    } catch (e) {
      if (e is E2EEException) rethrow;
      throw E2EEException('Failed to unlock with recovery key: $e');
    }
  }

  /// 使用密码解锁 SSSS
  Future<void> unlockWithPassphrase(String passphrase) async {
    final encryption = _client.encryption;
    if (encryption == null) {
      throw E2EEException('Encryption not initialized');
    }

    try {
      final openSsss = encryption.ssss.open();
      await openSsss.unlock(passphrase: passphrase);
      await openSsss.maybeCacheAll();

      // 缓存恢复密钥
      _cachedRecoveryKey = openSsss.recoveryKey;

      try {
        await encryption.crossSigning.selfSign(passphrase: passphrase);
      } catch (e) {
        debugLog('E2EEManager: Cross-signing with passphrase skipped: $e');
      }

      encryption.keyManager.startAutoUploadKeys();

      debugLog('E2EEManager: Unlocked with passphrase successfully');
    } catch (e) {
      if (e is E2EEException) rethrow;
      throw E2EEException('Failed to unlock with passphrase: $e');
    }
  }

  /// 检查是否有 SSSS 默认密钥
  bool get hasSsssDefaultKey {
    final encryption = _client.encryption;
    if (encryption == null) return false;
    return encryption.ssss.defaultKeyId != null;
  }

  // ============================================
  // 设备验证
  // ============================================

  /// 获取当前设备ID
  String? get currentDeviceId => _client.deviceID;

  /// 获取所有已知设备
  List<matrix.DeviceKeys> getDevicesForUser(String userId) {
    final encryption = _client.encryption;
    if (encryption == null) return [];

    final userKeys = _client.userDeviceKeys[userId];
    return userKeys?.deviceKeys.values.toList() ?? [];
  }

  /// 验证设备
  Future<void> verifyDevice(
    String userId,
    String deviceId, {
    bool verified = true,
  }) async {
    final userKeys = _client.userDeviceKeys[userId];
    if (userKeys == null) {
      throw E2EEException('User not found');
    }

    final device = userKeys.deviceKeys[deviceId];
    if (device == null) {
      throw E2EEException('Device not found');
    }

    await device.setVerified(verified);
  }

  /// 检查设备是否已验证
  bool isDeviceVerified(String userId, String deviceId) {
    final userKeys = _client.userDeviceKeys[userId];
    if (userKeys == null) return false;

    final device = userKeys.deviceKeys[deviceId];
    return device?.verified ?? false;
  }

  /// 获取所有未验证的设备
  List<DeviceInfo> getUnverifiedDevices(String userId) {
    final devices = getDevicesForUser(userId);
    return devices
        .where((d) => !d.verified)
        .map((d) => DeviceInfo(
              deviceId: d.deviceId ?? '',
              deviceName: d.unsigned?['device_display_name'] as String? ?? 'Unknown',
              isVerified: d.verified,
              lastSeenTs: d.unsigned?['last_seen_ts'] as int?,
            ))
        .toList();
  }

  // ============================================
  // 房间加密
  // ============================================

  /// 检查房间是否加密
  bool isRoomEncrypted(String roomId) {
    final room = _client.getRoomById(roomId);
    return room?.encrypted ?? false;
  }

  /// 在房间启用加密
  Future<void> enableEncryptionInRoom(String roomId) async {
    final room = _client.getRoomById(roomId);
    if (room == null) {
      throw E2EEException('Room not found');
    }

    if (room.encrypted) {
      return; // 已启用
    }

    await room.enableEncryption();
  }

  /// 获取房间加密状态
  RoomEncryptionStatus getRoomEncryptionStatus(String roomId) {
    final room = _client.getRoomById(roomId);
    if (room == null) return RoomEncryptionStatus.unknown;

    if (!room.encrypted) {
      return RoomEncryptionStatus.unencrypted;
    }

    // 检查是否有未验证的设备
    final members = room.getParticipants();
    for (final member in members) {
      final unverified = getUnverifiedDevices(member.id);
      if (unverified.isNotEmpty) {
        return RoomEncryptionStatus.encryptedWithUnverifiedDevices;
      }
    }

    return RoomEncryptionStatus.encrypted;
  }

  // ============================================
  // 跨设备签名验证 (Cross-Signing)
  // ============================================

  bool _autoSetupInProgress = false;

  /// 登录后自动设置 cross-signing
  ///
  /// 检查是否已初始化 cross-signing，若未初始化则尝试自动设置。
  /// 失败时静默处理，不阻塞登录流程。
  Future<void> autoSetupAfterLogin() async {
    if (!isEncryptionInitialized || _autoSetupInProgress) {
      debugLog('E2EEManager: Encryption not initialized or setup already in progress, skipping');
      return;
    }

    _autoSetupInProgress = true;
    try {
      if (isCrossSigningEnabled) {
        debugLog('E2EEManager: Cross-signing already enabled');
        return;
      }

      // 尝试自签名（如果有 SSSS 密钥可用）
      if (hasSsssDefaultKey) {
        final cachedKey = _cachedRecoveryKey;
        if (cachedKey != null) {
          await recoverCrossSigning(cachedKey);
          debugLog('E2EEManager: Cross-signing recovered with cached key');
          return;
        }
      }

      // 尝试直接 self-sign（新设备、首次登录场景）
      await initializeCrossSigning();
      debugLog('E2EEManager: Cross-signing auto-initialized');
    } catch (e) {
      // 非致命：部分场景下 self-sign 需要用户交互（如输入恢复密钥）
      debugLog('E2EEManager: Auto cross-signing setup failed (non-fatal): $e');
    } finally {
      _autoSetupInProgress = false;
    }
  }

  /// 是否已设置跨设备签名
  bool get isCrossSigningEnabled {
    return _client.encryption?.crossSigning.enabled ?? false;
  }

  /// 初始化跨设备签名
  Future<void> initializeCrossSigning() async {
    final encryption = _client.encryption;
    if (encryption == null) {
      throw E2EEException('Encryption not initialized');
    }

    try {
      await encryption.crossSigning.selfSign();
    } catch (e) {
      throw E2EEException('Failed to initialize cross-signing: $e');
    }
  }

  /// 使用恢复密钥恢复跨设备签名
  Future<void> recoverCrossSigning(String recoveryKey) async {
    final encryption = _client.encryption;
    if (encryption == null) {
      throw E2EEException('Encryption not initialized');
    }

    try {
      final openSsss = encryption.ssss.open();
      await openSsss.unlock(recoveryKey: recoveryKey);
      await openSsss.maybeCacheAll();
      await encryption.crossSigning.selfSign(recoveryKey: recoveryKey);
    } catch (e) {
      throw E2EEException('Failed to recover cross-signing: $e');
    }
  }

  // ============================================
  // SAS 验证 (Short Authentication String)
  // ============================================

  /// 启动 SAS 验证流程
  ///
  /// 向指定用户的设备发起 SAS 验证请求
  /// 返回 [KeyVerification] 对象用于跟踪验证状态
  Future<kv.KeyVerification?> startSasVerification(
    String userId,
    String deviceId,
  ) async {
    final encryption = _client.encryption;
    if (encryption == null) {
      throw E2EEException('Encryption not initialized');
    }

    try {
      final userKeys = _client.userDeviceKeys[userId];
      if (userKeys == null) {
        throw E2EEException('User device keys not found');
      }

      final deviceKeys = userKeys.deviceKeys[deviceId];
      if (deviceKeys == null) {
        throw E2EEException('Device keys not found');
      }

      final verification = await deviceKeys.startVerification();
      return verification;
    } catch (e) {
      if (e is E2EEException) rethrow;
      throw E2EEException('Failed to start SAS verification: $e');
    }
  }

  /// 接受传入的 SAS 验证请求
  Future<void> acceptSasVerification(kv.KeyVerification verification) async {
    try {
      await verification.acceptVerification();
    } catch (e) {
      throw E2EEException('Failed to accept verification: $e');
    }
  }

  /// 确认 SAS emoji/数字匹配
  Future<void> confirmSas(kv.KeyVerification verification) async {
    try {
      await verification.acceptSas();
    } catch (e) {
      throw E2EEException('Failed to confirm SAS: $e');
    }
  }

  /// 拒绝 SAS 验证（emoji/数字不匹配）
  Future<void> rejectSas(kv.KeyVerification verification) async {
    try {
      await verification.rejectSas();
    } catch (e) {
      throw E2EEException('Failed to reject SAS: $e');
    }
  }

  /// 取消验证流程
  Future<void> cancelVerification(kv.KeyVerification verification) async {
    try {
      await verification.cancel();
    } catch (e) {
      throw E2EEException('Failed to cancel verification: $e');
    }
  }

  /// 获取 Matrix Client 用于监听验证事件
  matrix.Client get client => _client;

  /// 监听传入的验证请求
  ///
  /// 返回一个 Stream，当有新的验证请求时发出事件
  Stream<kv.KeyVerification> get onVerificationRequest {
    return _client.onKeyVerificationRequest.stream;
  }
}

/// E2EE状态
enum E2EEStatus {
  /// 不支持加密
  notSupported,

  /// 未初始化
  notInitialized,

  /// 已就绪
  ready,
}

/// 房间加密状态
enum RoomEncryptionStatus {
  /// 未知
  unknown,

  /// 未加密
  unencrypted,

  /// 已加密
  encrypted,

  /// 已加密但有未验证设备
  encryptedWithUnverifiedDevices,
}

/// 设备信息
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final bool isVerified;
  final int? lastSeenTs;
  final String? lastSeenIp;
  final bool isCurrentDevice;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.isVerified,
    this.lastSeenTs,
    this.lastSeenIp,
    this.isCurrentDevice = false,
  });

  DateTime? get lastSeen =>
      lastSeenTs != null ? DateTime.fromMillisecondsSinceEpoch(lastSeenTs!) : null;
}

/// E2EE异常
class E2EEException implements Exception {
  final String message;

  E2EEException(this.message);

  @override
  String toString() => 'E2EEException: $message';
}
