import 'dart:typed_data';

/// MLS (Message Layer Security, RFC 9420) 协议抽象。
///
/// 与现有 Olm/Megolm (vodozemac) 双栈共存。当 MLS 可用时，
/// 新建的群组默认使用 MLS；旧群组仍走 Megolm 直到手动迁移。
///
/// 底层实现选项：
/// - **OpenMLS** (Rust via FFI) — 生产推荐
/// - **纯 Dart 实现** — 实验性
/// - **Matrix MSC4245** — 等待 Matrix 标准化后原生支持
///
/// 此文件仅定义接口；具体实现由 [MlsBackend] 子类提供。
abstract class MlsBackend {
  /// 初始化 MLS 客户端，生成密钥包。
  Future<void> initialize({
    required String userId,
    required Uint8List identityKey,
  });

  /// 生成并上传密钥包 (KeyPackage) 到服务端。
  ///
  /// Matrix 的 MLS MSC 定义了 `/_matrix/client/v3/keys/mls/upload`。
  Future<MlsKeyPackage> generateKeyPackage();

  /// 创建一个 MLS 群组。
  ///
  /// [groupId] 通常对应 Matrix room ID。
  /// 返回初始的 GroupInfo（含 group secret tree）。
  Future<MlsGroupInfo> createGroup(String groupId);

  /// 将成员添加到 MLS 群组。
  ///
  /// [keyPackage] 被邀请方的密钥包（从服务端获取）。
  /// 返回 Welcome + Commit 消息，需通过 Matrix 房间事件分发。
  Future<MlsAddResult> addMember({
    required String groupId,
    required MlsKeyPackage keyPackage,
  });

  /// 处理收到的 Welcome 消息，加入群组。
  Future<MlsGroupInfo> processWelcome(Uint8List welcomeMessage);

  /// 处理收到的 Commit 消息，更新群组状态。
  Future<void> processCommit({
    required String groupId,
    required Uint8List commitMessage,
  });

  /// 加密一条消息。
  Future<Uint8List> encrypt({
    required String groupId,
    required Uint8List plaintext,
  });

  /// 解密一条消息。
  Future<Uint8List> decrypt({
    required String groupId,
    required Uint8List ciphertext,
  });

  /// 将成员从群组移除（生成 Remove Proposal + Commit）。
  Future<Uint8List> removeMember({
    required String groupId,
    required String userId,
  });

  /// 更新自身在群组中的密钥（Post-Compromise Security）。
  Future<Uint8List> selfUpdate(String groupId);

  /// 导出群组的当前 epoch secret（用于密钥备份）。
  Future<Uint8List> exportGroupSecret(String groupId);

  /// 获取群组当前 epoch 号。
  Future<int> getEpoch(String groupId);

  /// 释放资源。
  Future<void> dispose();
}

/// MLS 密钥包。
class MlsKeyPackage {
  const MlsKeyPackage({
    required this.data,
    required this.userId,
    required this.deviceId,
    required this.expiresAt,
  });

  final Uint8List data;
  final String userId;
  final String deviceId;
  final DateTime expiresAt;
}

/// MLS 群组信息快照。
class MlsGroupInfo {
  const MlsGroupInfo({
    required this.groupId,
    required this.epoch,
    required this.memberCount,
    required this.cipherSuite,
  });

  final String groupId;
  final int epoch;
  final int memberCount;
  final MlsCipherSuite cipherSuite;
}

/// MLS 添加成员结果。
class MlsAddResult {
  const MlsAddResult({
    required this.welcome,
    required this.commit,
  });

  final Uint8List welcome;
  final Uint8List commit;
}

/// MLS 密码套件。
enum MlsCipherSuite {
  /// MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519
  x25519Aes128gcm,

  /// MLS_128_DHKEMP256_AES128GCM_SHA256_P256
  p256Aes128gcm,

  /// MLS_256_DHKEMX448_AES256GCM_SHA512_Ed448
  x448Aes256gcm,
}
