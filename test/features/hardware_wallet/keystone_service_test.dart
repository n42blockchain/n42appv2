// KeystoneService 单元测试
//
// 覆盖 lib/features/hardware_wallet/service/keystone_service.dart：
// - buildEthSignRequest / buildEthTypedDataRequest / buildEthPersonalSignRequest
//   （构造出的 UR 用 UrCodec.decode 反解并验证 CBOR 字段）
// - parseEthSignature（坏输入返回 error 响应而非抛出）
// - validateScannedUr
// - parseSyncQr（crypto-hdkey / crypto-account / 明文 xpub 回退 / 未知格式）
// - KeystoneAccountInfo.toDevice

import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/crypto/ur_codec.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/service/keystone_service.dart';

/// 反解 UR -> CBOR -> {int 键: CborObject}
Map<int, CborObject> decodeUrToIntMap(String ur, String expectedType) {
  final decoded = UrCodec.decode(ur);
  expect(decoded.type, expectedType);
  final obj = CborObject.fromCbor(decoded.data.toList());
  final map = obj as CborMapValue;
  return <int, CborObject>{
    for (final e in map.value.entries) (e.key as CborIntValue).value: e.value,
  };
}

void main() {
  late KeystoneService service;
  const path = "m/44'/60'/0'/0/0";
  final expectedPathInts = [0x8000002C, 0x8000003C, 0x80000000, 0, 0];

  setUp(() {
    service = KeystoneService();
  });

  group('buildEthSignRequest（交易）', () {
    final rlp = Uint8List.fromList(List.generate(30, (i) => 0xF0 - i));

    test('产出的 UR 可反解且 CBOR 字段正确', () {
      final ur = service.buildEthSignRequest(
        rawTxRlp: rlp,
        chainId: 1,
        derivationPath: path,
        fromAddress: '0x9858EfFD232B4033E47d90003D41EC34EcaEda94',
      );
      expect(ur, startsWith('UR:ETH-SIGN-REQUEST/'));

      final map = decodeUrToIntMap(ur, 'eth-sign-request');
      // requestId：UUID tag(37) 包裹（registry 规范）
      final reqIdTag = map[1] as CborTagValue;
      expect(reqIdTag.tags, [EthSignRequest.uuidTag]);
      expect((reqIdTag.value as CborBytesValue).value.length, 16);
      expect((map[2] as CborBytesValue).value, rlp); // signData
      expect((map[3] as CborIntValue).value, 1); // dataType=transaction
      expect((map[4] as CborIntValue).value, 1); // chainId
      // derivationPath：crypto-keypath tag(304) 结构
      final keypathTag = map[5] as CborTagValue;
      expect(keypathTag.tags, [EthSignRequest.cryptoKeypathTag]);
      final components =
          ((keypathTag.value as CborMapValue).value[const CborIntValue(1)]
                  as CborListValue)
              .value;
      final rebuilt = <int>[];
      for (var i = 0; i < components.length; i += 2) {
        final index = (components[i] as CborIntValue).value;
        final hardened = (components[i + 1] as CborBoleanValue).value;
        rebuilt.add(hardened ? (0x80000000 | index) : index);
      }
      expect(rebuilt, expectedPathInts);
      expect((map[6] as CborBytesValue).value.length, 20); // address
      expect((map[7] as CborStringValue).value, 'N42'); // origin
    });

    test('不传 fromAddress 时 CBOR 中无 address 键', () {
      final ur = service.buildEthSignRequest(
        rawTxRlp: rlp,
        chainId: 56,
        derivationPath: path,
      );
      final map = decodeUrToIntMap(ur, 'eth-sign-request');
      expect(map.containsKey(6), isFalse);
      expect((map[4] as CborIntValue).value, 56);
    });
  });

  group('buildEthTypedDataRequest（EIP-712）', () {
    test('dataType=2 且 signData 为 JSON 字节', () {
      const json = '{"domain":{"chainId":1},"message":{}}';
      final ur = service.buildEthTypedDataRequest(
        typedDataJson: json,
        chainId: 1,
        derivationPath: path,
      );
      final map = decodeUrToIntMap(ur, 'eth-sign-request');
      expect((map[3] as CborIntValue).value, 2);
      expect((map[2] as CborBytesValue).value, json.codeUnits);
      expect((map[4] as CborIntValue).value, 1);
    });
  });

  group('buildEthPersonalSignRequest（personal_sign）', () {
    test('dataType=3、无 chainId 键、signData 为消息字节', () {
      const message = 'Sign in to N42';
      final ur = service.buildEthPersonalSignRequest(
        message: message,
        derivationPath: path,
        fromAddress: '0x9858EfFD232B4033E47d90003D41EC34EcaEda94',
      );
      final map = decodeUrToIntMap(ur, 'eth-sign-request');
      expect((map[3] as CborIntValue).value, 3);
      expect(map.containsKey(4), isFalse); // personal_sign 无 chainId
      expect((map[2] as CborBytesValue).value, message.codeUnits);
    });

    test('非 ASCII 消息按 UTF-8 编码进 signData（2026-08-05 修复）', () {
      const message = '你好 N42';
      final ur = service.buildEthPersonalSignRequest(
        message: message,
        derivationPath: path,
      );
      final map = decodeUrToIntMap(ur, 'eth-sign-request');
      expect((map[2] as CborBytesValue).value, utf8.encode(message));
    });
  });

  group('parseEthSignature', () {
    final sig65 = Uint8List.fromList([
      ...List.filled(32, 0xAA),
      ...List.filled(32, 0xBB),
      0x00,
    ]);
    final reqId = Uint8List.fromList(List.generate(16, (i) => i));

    String buildSignatureUr() {
      final cbor = CborMapValue.definite(<CborObject, CborObject>{
        const CborIntValue(1): CborBytesValue(reqId),
        const CborIntValue(2): CborBytesValue(sig65),
      });
      return UrCodec.encode('eth-signature', Uint8List.fromList(cbor.encode()));
    }

    test('合法 eth-signature UR -> success 响应含 0x 签名', () {
      final resp = service.parseEthSignature(buildSignatureUr());
      expect(resp.success, isTrue);
      expect(resp.signature, '0x${'aa' * 32}${'bb' * 32}00');
      expect(resp.error, isNull);
    });

    test('首尾空白被容忍', () {
      final resp = service.parseEthSignature('  ${buildSignatureUr()}  ');
      expect(resp.success, isTrue);
    });

    test('非 UR 字符串返回 error 响应而非抛出', () {
      final resp = service.parseEthSignature('hello world');
      expect(resp.success, isFalse);
      expect(resp.error, contains('Invalid Keystone response'));
    });

    test('UR 类型不符返回 error 响应', () {
      final ur = UrCodec.encode(
        'eth-sign-request',
        Uint8List.fromList([1, 2, 3]),
      );
      final resp = service.parseEthSignature(ur);
      expect(resp.success, isFalse);
      expect(resp.error, contains('Expected eth-signature'));
    });

    test('CRC 损坏的 UR 返回 error 响应', () {
      final ur = buildSignatureUr();
      final slash = ur.indexOf('/');
      final body = ur.substring(slash + 1).toLowerCase();
      final firstPair = body.substring(0, 2);
      final newPair = firstPair == 'ae' ? 'ad' : 'ae';
      final tampered = '${ur.substring(0, slash)}/$newPair${body.substring(2)}';
      final resp = service.parseEthSignature(tampered);
      expect(resp.success, isFalse);
      expect(resp.error, contains('CRC-32 mismatch'));
    });

    test('CBOR 不是 map（解析抛非 UrCodecException 也被兜住）返回 error', () {
      // payload 是合法 CBOR int，fromCbor 抛 UrCodecException('must be a map')
      final notMap = Uint8List.fromList(const CborIntValue(7).encode());
      final ur = UrCodec.encode('eth-signature', notMap);
      final resp = service.parseEthSignature(ur);
      expect(resp.success, isFalse);
      expect(resp.error, isNotNull);
    });
  });

  group('validateScannedUr', () {
    test('空字符串 -> "Empty QR code"', () {
      expect(service.validateScannedUr(''), 'Empty QR code');
    });

    test('非 UR 内容 -> "Not a valid UR QR code"', () {
      expect(service.validateScannedUr('https://n42.ai'), contains('Not a valid UR'));
    });

    test('类型不符 -> 报出实际类型', () {
      final err = service.validateScannedUr('ur:eth-sign-request/able acid');
      expect(err, contains('eth-sign-request'));
      expect(err, contains('expected eth-signature'));
    });

    test('仅 "ur:" 无类型 -> 报空类型', () {
      final err = service.validateScannedUr('ur:');
      expect(err, contains('Unexpected UR type'));
    });

    test('合法 eth-signature（小写）-> null', () {
      expect(service.validateScannedUr('ur:eth-signature/able acid'), isNull);
    });

    test('合法 eth-signature（大写）-> null', () {
      expect(service.validateScannedUr('UR:ETH-SIGNATURE/ABLE ACID'), isNull);
    });
  });

  group('parseSyncQr', () {
    test('ur:crypto-hdkey -> xpub 为 payload 十六进制', () {
      final keyData = Uint8List.fromList(List.generate(16, (i) => i * 3));
      final ur = UrCodec.encode('crypto-hdkey', keyData);
      final info = service.parseSyncQr(ur);
      expect(info.deviceName, 'Keystone');
      expect(info.masterFingerprint, isNull);
      // xpub 存的是 CBOR payload 的 hex
      expect(info.xpub.toLowerCase(), _toHex(keyData));
    });

    test('ur:crypto-account -> 同样以 hex 存储', () {
      final data = Uint8List.fromList([0xCA, 0xFE, 0xBA, 0xBE, 0x01]);
      final ur = UrCodec.encode('crypto-account', data);
      final info = service.parseSyncQr(ur);
      expect(info.xpub.toLowerCase(), 'cafebabe01');
    });

    test('CRC 损坏的 crypto-hdkey 抛 UrCodecException', () {
      final ur = UrCodec.encode(
        'crypto-hdkey',
        Uint8List.fromList([1, 2, 3, 4, 5]),
      );
      final slash = ur.indexOf('/');
      final body = ur.substring(slash + 1).toLowerCase();
      final firstPair = body.substring(0, 2);
      final newPair = firstPair == 'ae' ? 'ad' : 'ae';
      final tampered = '${ur.substring(0, slash)}/$newPair${body.substring(2)}';
      expect(
        () => service.parseSyncQr(tampered),
        throwsA(isA<UrCodecException>()),
      );
    });

    test('明文 xpub 回退路径', () {
      const xpub = 'xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz';
      final info = service.parseSyncQr('  $xpub  ');
      expect(info.xpub, xpub);
      expect(info.masterFingerprint, isNull);
      expect(info.deviceName, 'Keystone');
    });

    test('zpub / ypub / Xpub 前缀同样进入回退路径', () {
      for (final prefix in ['zpub', 'ypub', 'Xpub']) {
        final info = service.parseSyncQr('${prefix}AAAABBBB');
        expect(info.xpub, '${prefix}AAAABBBB');
      }
    });

    test('无法识别的内容抛 UrCodecException', () {
      expect(
        () => service.parseSyncQr('random garbage'),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('Unrecognized Keystone sync QR'),
          ),
        ),
      );
    });
  });

  group('KeystoneAccountInfo.toDevice', () {
    test('有 masterFingerprint 时 id = keystone_<fp>', () {
      const info = KeystoneAccountInfo(
        xpub: 'xpub6CUGRUonZSQ4TWtTMmz',
        masterFingerprint: '1a2b3c4d',
        deviceName: 'Keystone 3 Pro',
      );
      final device = info.toDevice();
      expect(device.id, 'keystone_1a2b3c4d');
      expect(device.name, 'Keystone 3 Pro');
      expect(device.type, HardwareWalletType.keystoneModel);
      expect(device.isConnected, isTrue);
      expect(device.lastConnectedAt, isNotNull);
      expect(device.isKeystone, isTrue);
    });

    test('无 masterFingerprint 时 id 取 xpub 前 8 位', () {
      const info = KeystoneAccountInfo(
        xpub: 'xpub6CUGRUonZSQ4TWtTMmz',
        masterFingerprint: null,
        deviceName: 'Keystone',
      );
      expect(info.toDevice().id, 'keystone_xpub6CUG');
    });
  });
}

String _toHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
