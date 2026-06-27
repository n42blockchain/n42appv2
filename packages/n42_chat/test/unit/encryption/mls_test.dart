import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/encryption/mls_manager.dart';
import 'package:n42_chat/src/core/encryption/mls_protocol.dart';

/// 已绑定的假 MLS 实现：模拟原生 OpenMLS 就绪后的行为（仅供测试 manager 调度）。
class _FakeBoundMls implements MlsProtocol {
  @override
  bool get isBound => true;

  @override
  Future<MlsKeyPackage> generateKeyPackage() async =>
      MlsKeyPackage(Uint8List.fromList([1, 2, 3]));

  @override
  Future<MlsGroupState> createGroup(String groupId) async =>
      MlsGroupState(groupId, Uint8List.fromList([0]));

  @override
  Future<(MlsCommit, MlsWelcome)> addMembers(
          String groupId, List<MlsKeyPackage> keyPackages) async =>
      (MlsCommit(Uint8List(0)), MlsWelcome(Uint8List(0)));

  @override
  Future<MlsCommit> removeMembers(
          String groupId, List<String> memberIds) async =>
      MlsCommit(Uint8List(0));

  @override
  Future<void> processCommit(String groupId, MlsCommit commit) async {}

  @override
  Future<MlsGroupState> processWelcome(MlsWelcome welcome) async =>
      MlsGroupState('g', Uint8List(0));

  @override
  Future<Uint8List> encrypt(String groupId, Uint8List plaintext) async =>
      plaintext;

  @override
  Future<Uint8List> decrypt(String groupId, Uint8List ciphertext) async =>
      ciphertext;

  @override
  Future<MlsCommit> selfUpdate(String groupId) async => MlsCommit(Uint8List(0));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MlsManager 双栈调度', () {
    test('未绑定时默认 Olm，且拒绝切 MLS', () {
      final mgr = MlsManager(const UnboundMlsProtocol());
      expect(mgr.mlsAvailable, isFalse);
      expect(mgr.backendForGroup('!g'), GroupEncryptionBackend.olm);
      expect(mgr.enableMlsForGroup('!g'), isFalse); // 被拒
      expect(mgr.isMlsGroup('!g'), isFalse);
    });

    test('已绑定时可为群启用 MLS 并切回 Olm', () {
      final mgr = MlsManager(_FakeBoundMls());
      expect(mgr.mlsAvailable, isTrue);
      expect(mgr.enableMlsForGroup('!g'), isTrue);
      expect(mgr.isMlsGroup('!g'), isTrue);
      mgr.useOlmForGroup('!g');
      expect(mgr.isMlsGroup('!g'), isFalse);
      expect(mgr.backendForGroup('!g'), GroupEncryptionBackend.olm);
    });

    test('未指定的群默认 Olm', () {
      final mgr = MlsManager(_FakeBoundMls());
      expect(mgr.backendForGroup('!other'), GroupEncryptionBackend.olm);
    });
  });

  group('UnboundMlsProtocol', () {
    test('isBound=false 且各操作抛 MlsUnboundException', () async {
      const p = UnboundMlsProtocol();
      expect(p.isBound, isFalse);
      expect(p.generateKeyPackage(), throwsA(isA<MlsUnboundException>()));
      expect(p.createGroup('g'), throwsA(isA<MlsUnboundException>()));
      expect(
        p.encrypt('g', Uint8List(0)),
        throwsA(isA<MlsUnboundException>()),
      );
    });
  });

  group('FfiMlsProtocol 绑定层', () {
    const channel = MethodChannel('n42.chat/mls');
    final calls = <MethodCall>[];
    Object? Function(MethodCall)? handler;

    setUp(() {
      calls.clear();
      handler = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return handler?.call(call);
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('probe：原生未绑定 → isBound=false', () async {
      handler = (_) => false;
      final p = FfiMlsProtocol(channel: channel);
      expect(await p.probe(), isFalse);
      expect(p.isBound, isFalse);
    });

    test('未绑定时操作抛 MlsUnboundException（不触达原生具体方法）', () async {
      handler = (_) => false;
      final p = FfiMlsProtocol(channel: channel);
      await p.probe();
      expect(p.generateKeyPackage(), throwsA(isA<MlsUnboundException>()));
    });

    test('probe 成功后转发到原生并包装返回字节', () async {
      handler = (call) {
        switch (call.method) {
          case 'isBound':
            return true;
          case 'generateKeyPackage':
            return Uint8List.fromList([9, 8, 7]);
          case 'encrypt':
            return Uint8List.fromList([1, 1]);
          default:
            return null;
        }
      };
      final p = FfiMlsProtocol(channel: channel);
      expect(await p.probe(), isTrue);
      final kp = await p.generateKeyPackage();
      expect(kp.bytes, [9, 8, 7]);
      final ct = await p.encrypt('!g', Uint8List.fromList([5]));
      expect(ct, [1, 1]);
      // 验证转发的方法与参数
      expect(calls.any((c) => c.method == 'generateKeyPackage'), isTrue);
      final enc = calls.firstWhere((c) => c.method == 'encrypt');
      expect((enc.arguments as Map)['groupId'], '!g');
    });

    test('createGroup 转发 groupId 并回包 MlsGroupState', () async {
      handler = (call) {
        if (call.method == 'isBound') return true;
        if (call.method == 'createGroup') return Uint8List.fromList([0, 1]);
        return null;
      };
      final p = FfiMlsProtocol(channel: channel);
      await p.probe();
      final state = await p.createGroup('!room');
      expect(state.groupId, '!room');
      expect(state.bytes, [0, 1]);
    });
  });
}
