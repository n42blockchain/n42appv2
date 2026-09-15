// KeystoneScanSession 多帧扫码会话测试
//
// 覆盖：多帧动画 QR 累积 → completedUr 重建 → 既有 parseEthSignature
// 解析路径全链路；单帧直通；同帧去重；无效帧不打断会话。

import 'dart:typed_data';

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/crypto/ur_codec.dart';
import 'package:n42_wallet/features/hardware_wallet/crypto/ur_fountain.dart';
import 'package:n42_wallet/features/hardware_wallet/service/keystone_service.dart';

/// 构造一个合法的 eth-signature CBOR（65 字节签名）
Uint8List buildSignatureCbor() {
  final sig65 = Uint8List.fromList([
    ...List.filled(32, 0x11),
    ...List.filled(32, 0x22),
    0x1B,
  ]);
  final map = <CborObject, CborObject>{
    const CborIntValue(1): CborBytesValue(
      Uint8List.fromList(List.generate(16, (i) => i)),
    ),
    const CborIntValue(2): CborBytesValue(sig65),
    const CborIntValue(3): CborStringValue('Keystone'),
  };
  return Uint8List.fromList(CborMapValue.definite(map).encode());
}

void main() {
  final service = KeystoneService();

  group('KeystoneScanSession', () {
    test('多帧 eth-signature：逐帧累积 → 完成 → parseEthSignature 成功', () {
      final cbor = buildSignatureCbor();
      // maxFragmentLen 压小强制多帧
      final encoder = UrEncoder('eth-signature', cbor, maxFragmentLen: 20);
      expect(encoder.isSinglePart, isFalse);

      final session = KeystoneScanSession();
      expect(session.expectedPartCount, isNull);

      while (!session.isComplete) {
        session.receive(encoder.nextPart().toUpperCase());
      }
      expect(session.expectedPartCount, encoder.seqLen);
      expect(session.progress, 1);

      final ur = session.completedUr;
      expect(ur, isNotNull);
      expect(service.validateScannedUr(ur!), isNull);

      final response = service.parseEthSignature(ur);
      expect(response.success, isTrue);
      expect(response.signature, '0x${'11' * 32}${'22' * 32}1b');
    });

    test('单帧 UR 一帧完成', () {
      final cbor = buildSignatureCbor();
      final single = UrCodec.encode('eth-signature', cbor);
      final session = KeystoneScanSession();
      expect(session.receive(single), isTrue);
      expect(session.isComplete, isTrue);
      expect(service.parseEthSignature(session.completedUr!).success, isTrue);
    });

    test('动画 QR 同帧连续识别被去重', () {
      final cbor = buildSignatureCbor();
      final encoder = UrEncoder('eth-signature', cbor, maxFragmentLen: 20);
      final session = KeystoneScanSession();
      final frame = encoder.nextPart();
      expect(session.receive(frame), isTrue);
      expect(session.receive(frame), isFalse);
      expect(session.receivedPartCount, 1);
    });

    test('无效帧不打断会话，后续有效帧仍可完成', () {
      final cbor = buildSignatureCbor();
      final encoder = UrEncoder('eth-signature', cbor, maxFragmentLen: 20);
      final session = KeystoneScanSession();
      expect(session.receive(encoder.nextPart()), isTrue);
      expect(session.receive('https://not-a-ur.example'), isFalse);
      expect(session.receive('ur:other-type/1-2/aeae'), isFalse);
      while (!session.isComplete) {
        session.receive(encoder.nextPart());
      }
      expect(session.completedUr, isNotNull);
    });
  });
}
