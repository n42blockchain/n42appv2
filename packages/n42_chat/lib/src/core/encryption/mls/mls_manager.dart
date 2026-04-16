import 'dart:typed_data';

import '../../../core/utils/debug_log.dart';
import 'mls_protocol.dart';

/// 加密后端类型。
enum EncryptionBackend {
  /// 传统 Matrix Olm/Megolm (vodozemac)。
  olmMegolm,
  /// MLS (RFC 9420)。
  mls,
}

/// MLS 管理器 —— 管理 MLS 后端生命周期并提供群组级别的加密后端选择。
///
/// 设计原则：
/// - 新建群组可选择 MLS（管理员在群设置里切换）；
/// - 旧群组继续使用 Megolm，不强制迁移；
/// - 所有 MLS 操作通过 Matrix room events 分发（Commit/Welcome/Application）。
class MlsManager {
  MlsManager({this.backend});

  /// 注入的 MLS 底层实现。null 表示 MLS 不可用（回退到 Megolm）。
  MlsBackend? backend;

  /// 已启用 MLS 的群组集合。
  final Map<String, MlsGroupInfo> _mlsGroups = {};

  bool get isMlsAvailable => backend != null;

  /// 查询指定群组使用的加密后端。
  EncryptionBackend getBackendFor(String roomId) {
    if (_mlsGroups.containsKey(roomId)) return EncryptionBackend.mls;
    return EncryptionBackend.olmMegolm;
  }

  /// 为一个群组启用 MLS（创建 MLS Group）。
  Future<MlsGroupInfo?> enableMls(String roomId) async {
    if (backend == null) return null;
    try {
      final info = await backend!.createGroup(roomId);
      _mlsGroups[roomId] = info;
      debugLog('MlsManager: Enabled MLS for $roomId (epoch=${info.epoch})');
      return info;
    } catch (e) {
      debugLog('MlsManager: Failed to enable MLS for $roomId: $e');
      return null;
    }
  }

  /// 加入一个 MLS 群组（处理 Welcome 消息）。
  Future<bool> joinGroup(Uint8List welcomeMessage) async {
    if (backend == null) return false;
    try {
      final info = await backend!.processWelcome(welcomeMessage);
      _mlsGroups[info.groupId] = info;
      debugLog('MlsManager: Joined MLS group ${info.groupId}');
      return true;
    } catch (e) {
      debugLog('MlsManager: Failed to join MLS group: $e');
      return false;
    }
  }

  /// 处理 Commit 消息（群状态更新：成员变动、密钥轮换等）。
  Future<void> processCommit(String roomId, Uint8List commitMessage) async {
    if (backend == null) return;
    try {
      await backend!.processCommit(groupId: roomId, commitMessage: commitMessage);
      final epoch = await backend!.getEpoch(roomId);
      final existing = _mlsGroups[roomId];
      if (existing != null) {
        _mlsGroups[roomId] = MlsGroupInfo(
          groupId: roomId,
          epoch: epoch,
          memberCount: existing.memberCount,
          cipherSuite: existing.cipherSuite,
        );
      }
    } catch (e) {
      debugLog('MlsManager: processCommit failed for $roomId: $e');
    }
  }

  /// 加密消息（根据群组后端选择路径）。
  ///
  /// MLS 群组走 [MlsBackend.encrypt]；Megolm 群组由调用方走现有 vodozemac 路径。
  Future<Uint8List?> encrypt(String roomId, Uint8List plaintext) async {
    if (getBackendFor(roomId) != EncryptionBackend.mls) return null;
    return backend?.encrypt(groupId: roomId, plaintext: plaintext);
  }

  /// 解密消息。
  Future<Uint8List?> decrypt(String roomId, Uint8List ciphertext) async {
    if (getBackendFor(roomId) != EncryptionBackend.mls) return null;
    return backend?.decrypt(groupId: roomId, ciphertext: ciphertext);
  }

  /// 添加成员到 MLS 群组。
  Future<MlsAddResult?> addMember(
    String roomId,
    MlsKeyPackage keyPackage,
  ) async {
    if (backend == null || !_mlsGroups.containsKey(roomId)) return null;
    return backend!.addMember(groupId: roomId, keyPackage: keyPackage);
  }

  /// 移除成员。
  Future<Uint8List?> removeMember(String roomId, String userId) async {
    if (backend == null) return null;
    return backend!.removeMember(groupId: roomId, userId: userId);
  }

  /// 群组信息。
  MlsGroupInfo? getGroupInfo(String roomId) => _mlsGroups[roomId];

  /// 所有 MLS 群组 ID。
  Set<String> get mlsGroupIds => _mlsGroups.keys.toSet();

  Future<void> dispose() async {
    await backend?.dispose();
    _mlsGroups.clear();
  }
}
