import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// MLS（RFC 9420）不透明结构封装
class MlsKeyPackage {
  final Uint8List bytes;
  const MlsKeyPackage(this.bytes);
}

class MlsGroupState {
  final String groupId;
  final Uint8List bytes;
  const MlsGroupState(this.groupId, this.bytes);
}

class MlsCommit {
  final Uint8List bytes;
  const MlsCommit(this.bytes);
}

class MlsWelcome {
  final Uint8List bytes;
  const MlsWelcome(this.bytes);
}

/// MLS 群组加密协议接口（RFC 9420）
///
/// 覆盖密钥包 / 建群 / Welcome / Commit / 加解密 / 成员管理 / PCS 自更新。
/// 由底层实现（OpenMLS Rust FFI）提供；未绑定时用 [UnboundMlsProtocol]。
abstract class MlsProtocol {
  /// 底层实现（OpenMLS FFI）是否已绑定可用
  bool get isBound;

  /// 生成本端密钥包（供他人加我入群）
  Future<MlsKeyPackage> generateKeyPackage();

  /// 新建 MLS 群
  Future<MlsGroupState> createGroup(String groupId);

  /// 加成员（产出 Commit + 对应 Welcome 给新成员）
  Future<(MlsCommit, MlsWelcome)> addMembers(
    String groupId,
    List<MlsKeyPackage> keyPackages,
  );

  /// 移除成员（产出 Commit）
  Future<MlsCommit> removeMembers(String groupId, List<String> memberIds);

  /// 应用收到的 Commit（推进群 epoch）
  Future<void> processCommit(String groupId, MlsCommit commit);

  /// 处理收到的 Welcome（加入群）
  Future<MlsGroupState> processWelcome(MlsWelcome welcome);

  /// 群内加密
  Future<Uint8List> encrypt(String groupId, Uint8List plaintext);

  /// 群内解密
  Future<Uint8List> decrypt(String groupId, Uint8List ciphertext);

  /// PCS（后向安全）：周期性自更新密钥
  Future<MlsCommit> selfUpdate(String groupId);
}

/// 底层未绑定时抛出
class MlsUnboundException implements Exception {
  @override
  String toString() =>
      'MlsUnboundException: OpenMLS FFI not bound; falling back to Olm/Megolm.';
}

/// 未绑定 OpenMLS FFI 的占位实现
///
/// `isBound=false`，任何操作抛 [MlsUnboundException]——由 [MlsManager] 据此
/// 回退到现役 Olm/Megolm，不误导为可用。接入 Rust FFI 后替换本实现即生效。
class UnboundMlsProtocol implements MlsProtocol {
  const UnboundMlsProtocol();

  @override
  bool get isBound => false;

  Never _unbound() => throw MlsUnboundException();

  @override
  Future<MlsKeyPackage> generateKeyPackage() async => _unbound();

  @override
  Future<MlsGroupState> createGroup(String groupId) async => _unbound();

  @override
  Future<(MlsCommit, MlsWelcome)> addMembers(
          String groupId, List<MlsKeyPackage> keyPackages) async =>
      _unbound();

  @override
  Future<MlsCommit> removeMembers(
          String groupId, List<String> memberIds) async =>
      _unbound();

  @override
  Future<void> processCommit(String groupId, MlsCommit commit) async =>
      _unbound();

  @override
  Future<MlsGroupState> processWelcome(MlsWelcome welcome) async => _unbound();

  @override
  Future<Uint8List> encrypt(String groupId, Uint8List plaintext) async =>
      _unbound();

  @override
  Future<Uint8List> decrypt(String groupId, Uint8List ciphertext) async =>
      _unbound();

  @override
  Future<MlsCommit> selfUpdate(String groupId) async => _unbound();
}

/// 经原生 OpenMLS（Rust）FFI 绑定的 MLS 实现。
///
/// 这是 RFC 9420 真实密码学接入的**绑定层**：所有操作转发到原生
/// `n42.chat/mls` 通道，由原生侧的 OpenMLS crate（经 flutter_rust_bridge /
/// uniffi）执行真正的 TreeKEM / HPKE / 棘轮密码学。
///
/// **不在 Dart 侧手搓 MLS 密码学**（安全敏感、易错，违背诚信原则）。原生 crate
/// 未构建接入时 [probe] 返回 false、[isBound]=false，各操作抛 [MlsUnboundException]，
/// 由 [MlsManager] 回退到现役 Olm/Megolm——不误导为可用。原生 crate 接好即生效。
class FfiMlsProtocol implements MlsProtocol {
  FfiMlsProtocol({@visibleForTesting MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('n42.chat/mls');

  final MethodChannel _channel;
  bool _bound = false;

  @override
  bool get isBound => _bound;

  /// 探测原生 OpenMLS FFI 是否就绪（应用启动时调用一次；可重复调用刷新）。
  Future<bool> probe() async {
    if (kIsWeb) {
      _bound = false;
      return false;
    }
    try {
      _bound = (await _channel.invokeMethod<bool>('isBound')) ?? false;
    } on MissingPluginException {
      _bound = false;
    } catch (_) {
      _bound = false;
    }
    return _bound;
  }

  Future<T> _invoke<T>(String method, [Object? args]) async {
    if (!_bound) throw MlsUnboundException();
    try {
      final r = await _channel.invokeMethod<T>(method, args);
      if (r == null) throw MlsUnboundException();
      return r;
    } on MissingPluginException {
      _bound = false;
      throw MlsUnboundException();
    }
  }

  @override
  Future<MlsKeyPackage> generateKeyPackage() async =>
      MlsKeyPackage(await _invoke<Uint8List>('generateKeyPackage'));

  @override
  Future<MlsGroupState> createGroup(String groupId) async => MlsGroupState(
        groupId,
        await _invoke<Uint8List>('createGroup', {'groupId': groupId}),
      );

  @override
  Future<(MlsCommit, MlsWelcome)> addMembers(
    String groupId,
    List<MlsKeyPackage> keyPackages,
  ) async {
    final res = await _invoke<Map<dynamic, dynamic>>('addMembers', {
      'groupId': groupId,
      'keyPackages': keyPackages.map((k) => k.bytes).toList(),
    });
    return (
      MlsCommit(res['commit'] as Uint8List),
      MlsWelcome(res['welcome'] as Uint8List),
    );
  }

  @override
  Future<MlsCommit> removeMembers(
    String groupId,
    List<String> memberIds,
  ) async =>
      MlsCommit(await _invoke<Uint8List>('removeMembers', {
        'groupId': groupId,
        'memberIds': memberIds,
      }));

  @override
  Future<void> processCommit(String groupId, MlsCommit commit) async {
    if (!_bound) throw MlsUnboundException();
    try {
      await _channel.invokeMethod<void>('processCommit', {
        'groupId': groupId,
        'commit': commit.bytes,
      });
    } on MissingPluginException {
      _bound = false;
      throw MlsUnboundException();
    }
  }

  @override
  Future<MlsGroupState> processWelcome(MlsWelcome welcome) async {
    final res = await _invoke<Map<dynamic, dynamic>>('processWelcome', {
      'welcome': welcome.bytes,
    });
    return MlsGroupState(
      res['groupId'] as String,
      res['state'] as Uint8List,
    );
  }

  @override
  Future<Uint8List> encrypt(String groupId, Uint8List plaintext) =>
      _invoke<Uint8List>('encrypt', {
        'groupId': groupId,
        'plaintext': plaintext,
      });

  @override
  Future<Uint8List> decrypt(String groupId, Uint8List ciphertext) =>
      _invoke<Uint8List>('decrypt', {
        'groupId': groupId,
        'ciphertext': ciphertext,
      });

  @override
  Future<MlsCommit> selfUpdate(String groupId) async =>
      MlsCommit(await _invoke<Uint8List>('selfUpdate', {'groupId': groupId}));
}
