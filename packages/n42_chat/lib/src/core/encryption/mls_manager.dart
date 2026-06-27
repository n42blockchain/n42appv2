import 'mls_protocol.dart';

/// 群组加密后端
enum GroupEncryptionBackend {
  /// 现役：Matrix Olm/Megolm（via vodozemac）
  olm,

  /// MLS（RFC 9420，需 OpenMLS FFI 绑定）
  mls,
}

/// Olm ↔ MLS 双栈调度
///
/// 按群选择加密后端。**默认 Olm/Megolm（现役、真实可用）**；仅当底层 MLS
/// 已绑定（[MlsProtocol.isBound]）时才允许把某群切到 MLS。MLS 未接入时
/// [mlsAvailable]=false、切换被拒，行为等价纯 Olm——不误导为可用。
class MlsManager {
  final MlsProtocol _mls;

  MlsManager(this._mls);

  final Map<String, GroupEncryptionBackend> _backends =
      <String, GroupEncryptionBackend>{};

  /// MLS 底层是否可用
  bool get mlsAvailable => _mls.isBound;

  /// 底层协议（供已切 MLS 的群使用）
  MlsProtocol get protocol => _mls;

  /// 群当前后端（默认 Olm）
  GroupEncryptionBackend backendForGroup(String groupId) =>
      _backends[groupId] ?? GroupEncryptionBackend.olm;

  bool isMlsGroup(String groupId) =>
      backendForGroup(groupId) == GroupEncryptionBackend.mls;

  /// 为群启用 MLS（仅当底层已绑定，返回是否成功）
  bool enableMlsForGroup(String groupId) {
    if (!_mls.isBound) return false;
    _backends[groupId] = GroupEncryptionBackend.mls;
    return true;
  }

  /// 把群切回 Olm
  void useOlmForGroup(String groupId) {
    _backends[groupId] = GroupEncryptionBackend.olm;
  }
}
