// UrCodec / EthSignRequest / EthSignature 单元测试
//
// 覆盖 lib/features/hardware_wallet/crypto/ur_codec.dart：
// - CRC-32 已知向量与空数据
// - Bytewords 编解码（大小写、多空白、未知词）
// - UR encode/decode round-trip、CRC 篡改检测、多帧前缀、payload 边界
// - EthSignRequest parsePath/toCbor/toUr（CBOR 字段反解验证）
// - EthSignature fromCbor/fromUr/signatureHex/vrs
//
// 已知缺陷（不修生产代码，规范不变量测试用 skip 固化）：
// - _wordList 含 286 词（BC-UR 规范应恰 256 词），其中 'brisk'(索引20)
//   与 'odd'(索引172) 非 4 字母词；索引 256-285 的词（'undo'..'zoom'）
//   encode 不可达，decode 时被 Uint8List 截断为 idx & 0xFF。

import 'dart:typed_data';

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/crypto/ur_codec.dart';

/// 把 CBOR 字节反解为 {int 键: CborObject} 便于断言
Map<int, CborObject> decodeCborIntMap(Uint8List data) {
  final obj = CborObject.fromCbor(data.toList());
  expect(obj, isA<CborMapValue>(), reason: '顶层 CBOR 应为 map');
  final map = obj as CborMapValue;
  return <int, CborObject>{
    for (final e in map.value.entries) (e.key as CborIntValue).value: e.value,
  };
}

void main() {
  group('UrCodec.crc32Bytes', () {
    test('标准校验向量 "123456789" -> 0xCBF43926（大端字节序）', () {
      final data = Uint8List.fromList('123456789'.codeUnits);
      expect(UrCodec.crc32Bytes(data), [0xCB, 0xF4, 0x39, 0x26]);
    });

    test('空数据 CRC-32 为 0x00000000', () {
      expect(UrCodec.crc32Bytes(Uint8List(0)), [0, 0, 0, 0]);
    });

    test('单字节数据的 CRC 与已知实现一致（0x00 -> 0xD202EF8D）', () {
      expect(
        UrCodec.crc32Bytes(Uint8List.fromList([0x00])),
        [0xD2, 0x02, 0xEF, 0x8D],
      );
    });
  });

  group('UrCodec bytewords 编解码', () {
    test('encode: 字节 [0,1,2] -> "able acid also"', () {
      expect(
        UrCodec.bytewordsEncode(Uint8List.fromList([0, 1, 2])),
        'able acid also',
      );
    });

    test('decode: "able acid also" -> [0,1,2]', () {
      expect(UrCodec.bytewordsDecode('able acid also'), [0, 1, 2]);
    });

    test('decode 对大写与大小写混写不敏感', () {
      expect(UrCodec.bytewordsDecode('ABLE Acid aLsO'), [0, 1, 2]);
    });

    test('decode 容忍多重空白与首尾空白', () {
      expect(UrCodec.bytewordsDecode('  able \t acid \n also  '), [0, 1, 2]);
    });

    test('decode 未知词抛 UrCodecException', () {
      expect(
        () => UrCodec.bytewordsDecode('able hello'),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('Unknown byteword'),
          ),
        ),
      );
    });

    test('全部 256 个字节值 encode/decode round-trip', () {
      final all = Uint8List.fromList(List.generate(256, (i) => i));
      final encoded = UrCodec.bytewordsEncode(all);
      expect(UrCodec.bytewordsDecode(encoded), all);
    });

    test('encode 产出的 256 个词彼此唯一', () {
      final all = Uint8List.fromList(List.generate(256, (i) => i));
      final words = UrCodec.bytewordsEncode(all).split(' ');
      expect(words.length, 256);
      expect(words.toSet().length, 256);
    });
  });

  group('UrCodec bytewords 规范不变量（已知缺陷，skip 固化）', () {
    test(
      '每个可编码词恰为 4 字母（BC-UR 规范 §2.1）',
      () {
        final all = Uint8List.fromList(List.generate(256, (i) => i));
        final words = UrCodec.bytewordsEncode(all).split(' ');
        // 实际：索引 20 = 'brisk'（5 字母）、索引 172 = 'odd'（3 字母）
        expect(words.where((w) => w.length != 4), isEmpty);
      },
      skip: '已知缺陷：wordList 含 286 词与非 4 字母词，待修复（见 MODULARITY_PLAN 批次6）',
    );

    test(
      'wordList 恰 256 词：任何可解码词应能 round-trip 回自身',
      () {
        // 规范列表只有 256 词，字节 255 应为 'zoom'。
        // 实际实现列表含 286 词：'zoom' 位于索引 285，decode 时被
        // Uint8List 截断为 29，重新 encode 得到 'clay' 而非 'zoom'。
        final decoded = UrCodec.bytewordsDecode('zoom');
        expect(UrCodec.bytewordsEncode(decoded), 'zoom');
      },
      skip: '已知缺陷：wordList 含 286 词与非 4 字母词，待修复（见 MODULARITY_PLAN 批次6）',
    );

    test(
      'BC-UR 官方测试向量 [0,1,2,128,255] -> "able acid also lava zoom"',
      () {
        final encoded = UrCodec.bytewordsEncode(
          Uint8List.fromList([0, 1, 2, 128, 255]),
        );
        // 实际实现字节 255 编码为 'ugly'（因多出 30 个词导致表偏移）
        expect(encoded, 'able acid also lava zoom');
      },
      skip: '已知缺陷：wordList 含 286 词与非 4 字母词，待修复（见 MODULARITY_PLAN 批次6）',
    );
  });

  group('UrCodec.encode / decode', () {
    final sampleData = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF, 0x42]);

    test('encode 产出 "UR:{TYPE大写}/{bytewords}" 格式', () {
      final ur = UrCodec.encode('eth-sign-request', sampleData);
      expect(ur, startsWith('UR:ETH-SIGN-REQUEST/'));
      // body 为空格分隔的 bytewords（数据 5 字节 + CRC 4 字节 = 9 词）
      final body = ur.substring(ur.indexOf('/') + 1);
      expect(body.split(' ').length, 9);
    });

    test('encode -> decode round-trip 还原 type 与 data', () {
      final ur = UrCodec.encode('eth-sign-request', sampleData);
      final decoded = UrCodec.decode(ur);
      expect(decoded.type, 'eth-sign-request');
      expect(decoded.data, sampleData);
    });

    test('空数据 round-trip（payload 仅含 4 字节 CRC 的边界）', () {
      final ur = UrCodec.encode('foo', Uint8List(0));
      final decoded = UrCodec.decode(ur);
      expect(decoded.type, 'foo');
      expect(decoded.data, isEmpty);
    });

    test('decode 对全大写 UR 字符串不敏感', () {
      final ur = UrCodec.encode('eth-signature', sampleData);
      final decoded = UrCodec.decode(ur.toUpperCase());
      expect(decoded.type, 'eth-signature');
      expect(decoded.data, sampleData);
    });

    test('decode 对大小写混写不敏感', () {
      final ur = UrCodec.encode('eth-signature', sampleData);
      // 逐字符交替大小写
      final mixed = String.fromCharCodes(
        ur.codeUnits.indexed.map(
          (e) => e.$1.isEven
              ? String.fromCharCode(e.$2).toLowerCase().codeUnitAt(0)
              : String.fromCharCode(e.$2).toUpperCase().codeUnitAt(0),
        ),
      );
      final decoded = UrCodec.decode(mixed);
      expect(decoded.type, 'eth-signature');
      expect(decoded.data, sampleData);
    });

    test('decode 容忍首尾空白', () {
      final ur = UrCodec.encode('foo', sampleData);
      expect(UrCodec.decode('  $ur \n').data, sampleData);
    });

    test('decode 支持多帧前缀 "1-of-3/"（当前实现直接剥离）', () {
      final ur = UrCodec.encode('eth-sign-request', sampleData);
      final slash = ur.indexOf('/');
      final multipart =
          '${ur.substring(0, slash)}/1-of-3/${ur.substring(slash + 1)}';
      final decoded = UrCodec.decode(multipart);
      expect(decoded.type, 'eth-sign-request');
      expect(decoded.data, sampleData);
    });

    test('decode 支持多位数多帧前缀 "12-of-34/"', () {
      final ur = UrCodec.encode('bar', sampleData);
      final slash = ur.indexOf('/');
      final multipart =
          '${ur.substring(0, slash)}/12-of-34/${ur.substring(slash + 1)}';
      expect(UrCodec.decode(multipart).data, sampleData);
    });

    test('CRC 篡改（替换一个数据词）抛 CRC-32 mismatch', () {
      final ur = UrCodec.encode('foo', sampleData);
      final slash = ur.indexOf('/');
      final words = ur.substring(slash + 1).split(' ');
      // 把第一个数据词替换为另一个合法词
      words[0] = words[0] == 'able' ? 'acid' : 'able';
      final tampered = '${ur.substring(0, slash)}/${words.join(' ')}';
      expect(
        () => UrCodec.decode(tampered),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('CRC-32 mismatch'),
          ),
        ),
      );
    });

    test('CRC 篡改（替换 CRC 尾词）同样被检出', () {
      final ur = UrCodec.encode('foo', sampleData);
      final slash = ur.indexOf('/');
      final words = ur.substring(slash + 1).split(' ');
      final last = words.length - 1;
      words[last] = words[last] == 'able' ? 'acid' : 'able';
      final tampered = '${ur.substring(0, slash)}/${words.join(' ')}';
      expect(
        () => UrCodec.decode(tampered),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('CRC-32 mismatch'),
          ),
        ),
      );
    });

    test('缺少 "UR:" 前缀抛异常', () {
      expect(
        () => UrCodec.decode('eth-signature/able acid'),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('missing "UR:" prefix'),
          ),
        ),
      );
    });

    test('缺少 "/" 分隔符抛异常', () {
      expect(
        () => UrCodec.decode('ur:eth-signature'),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('missing "/" separator'),
          ),
        ),
      );
    });

    test('payload 不足 4 字节（缺 CRC）抛异常', () {
      // 3 个词 = 3 字节 < 4
      expect(
        () => UrCodec.decode('ur:foo/able acid also'),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('too short'),
          ),
        ),
      );
    });

    test('单词 payload（1 字节）同样抛 too short', () {
      expect(
        () => UrCodec.decode('ur:foo/able'),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('too short'),
          ),
        ),
      );
    });

    test('body 中含未知 byteword 抛异常', () {
      expect(
        () => UrCodec.decode('ur:foo/able acid hello able able'),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('Unknown byteword'),
          ),
        ),
      );
    });

    test('UrCodecException.toString 含消息', () {
      expect(
        const UrCodecException('boom').toString(),
        'UrCodecException: boom',
      );
    });
  });

  group('EthSignRequest.parsePath', () {
    test("标准路径 m/44'/60'/0'/0/0", () {
      expect(EthSignRequest.parsePath("m/44'/60'/0'/0/0"), [
        0x8000002C,
        0x8000003C,
        0x80000000,
        0,
        0,
      ]);
    });

    test('无 m/ 前缀的路径同样可解析', () {
      expect(EthSignRequest.parsePath("44'/60'"), [0x8000002C, 0x8000003C]);
    });

    test('全非硬化路径', () {
      expect(EthSignRequest.parsePath('m/0/1/2'), [0, 1, 2]);
    });

    test('Ledger Live 风格路径 m/44\'/60\'/5\'/0/0', () {
      expect(EthSignRequest.parsePath("m/44'/60'/5'/0/0"), [
        0x8000002C,
        0x8000003C,
        0x80000005,
        0,
        0,
      ]);
    });
  });

  group('EthSignRequest.toCbor / toUr', () {
    final rlp = Uint8List.fromList(List.generate(20, (i) => i + 1));
    final path = [0x8000002C, 0x8000003C, 0x80000000, 0, 0];

    test('transaction 请求 CBOR 字段完整且值正确', () {
      final req = EthSignRequest.transaction(
        rawTxRlp: rlp,
        chainId: 1,
        derivationPath: path,
        fromAddress: '0x9858EfFD232B4033E47d90003D41EC34EcaEda94',
      );
      final map = decodeCborIntMap(req.toCbor());

      // key 1: requestId — UUID v4 的 16 字节
      expect((map[1] as CborBytesValue).value.length, 16);
      // key 2: signData
      expect((map[2] as CborBytesValue).value, rlp);
      // key 3: dataType = 1 (transaction)
      expect((map[3] as CborIntValue).value, 1);
      // key 4: chainId
      expect((map[4] as CborIntValue).value, 1);
      // key 5: derivationPath（含硬化位的整数列表）
      final pathList = (map[5] as CborListValue).value
          .map((e) => (e as CborIntValue).value)
          .toList();
      expect(pathList, path);
      // key 6: address（0x 前缀被剥离后的 20 字节）
      expect(
        (map[6] as CborBytesValue).value,
        BytesUtils.fromHexString('9858EfFD232B4033E47d90003D41EC34EcaEda94'),
      );
      // key 7: origin 默认 'N42'
      expect((map[7] as CborStringValue).value, 'N42');
    });

    test('无 0x 前缀的地址也能编码', () {
      final req = EthSignRequest(
        requestId: Uint8List(16),
        signData: rlp,
        dataType: EthSignDataType.transaction,
        chainId: 137,
        derivationPath: path,
        address: '9858EfFD232B4033E47d90003D41EC34EcaEda94',
      );
      final map = decodeCborIntMap(req.toCbor());
      expect((map[6] as CborBytesValue).value.length, 20);
    });

    test('address/origin 为 null 时对应键缺省', () {
      final req = EthSignRequest(
        requestId: Uint8List(16),
        signData: rlp,
        dataType: EthSignDataType.transaction,
        chainId: 1,
        derivationPath: path,
      );
      final map = decodeCborIntMap(req.toCbor());
      expect(map.containsKey(6), isFalse);
      expect(map.containsKey(7), isFalse);
    });

    test('typedData 工厂：dataType = 2', () {
      final req = EthSignRequest.typedData(
        typedDataJson: Uint8List.fromList('{"types":{}}'.codeUnits),
        chainId: 1,
        derivationPath: path,
      );
      final map = decodeCborIntMap(req.toCbor());
      expect((map[3] as CborIntValue).value, 2);
    });

    test('personalMessage 工厂：dataType = 3 且无 chainId 键', () {
      final req = EthSignRequest.personalMessage(
        messageBytes: Uint8List.fromList('hello'.codeUnits),
        derivationPath: path,
      );
      final map = decodeCborIntMap(req.toCbor());
      expect((map[3] as CborIntValue).value, 3);
      expect(map.containsKey(4), isFalse);
    });

    test('工厂生成的 requestId 每次不同（UUID v4）', () {
      final a = EthSignRequest.transaction(
        rawTxRlp: rlp,
        chainId: 1,
        derivationPath: path,
      );
      final b = EthSignRequest.transaction(
        rawTxRlp: rlp,
        chainId: 1,
        derivationPath: path,
      );
      expect(a.requestId, isNot(equals(b.requestId)));
    });

    test('toUr 产出可被 UrCodec.decode 反解的 eth-sign-request', () {
      final req = EthSignRequest.transaction(
        rawTxRlp: rlp,
        chainId: 1,
        derivationPath: path,
      );
      final ur = req.toUr();
      expect(ur, startsWith('UR:ETH-SIGN-REQUEST/'));
      final decoded = UrCodec.decode(ur);
      expect(decoded.type, 'eth-sign-request');
      expect(decoded.data, req.toCbor());
    });
  });

  group('EthSignature', () {
    // 65 字节签名：r(32) + s(32) + v(1)
    final rBytes = List<int>.filled(32, 0x11);
    final sBytes = List<int>.filled(32, 0x22);
    final sig65 = Uint8List.fromList([...rBytes, ...sBytes, 0x1B]);
    final reqId = Uint8List.fromList(List.generate(16, (i) => i));

    Uint8List buildSigCbor({
      Uint8List? requestId,
      Uint8List? signature,
      String? origin,
    }) {
      final map = <CborObject, CborObject>{
        if (requestId != null) CborIntValue(1): CborBytesValue(requestId),
        if (signature != null) CborIntValue(2): CborBytesValue(signature),
        if (origin != null) CborIntValue(3): CborStringValue(origin),
      };
      return Uint8List.fromList(CborMapValue.definite(map).encode());
    }

    test('fromCbor 解析 requestId/signature/origin', () {
      final sig = EthSignature.fromCbor(
        buildSigCbor(requestId: reqId, signature: sig65, origin: 'Keystone'),
      );
      expect(sig.requestId, reqId);
      expect(sig.signature, sig65);
      expect(sig.origin, 'Keystone');
    });

    test('fromCbor 允许缺省 origin', () {
      final sig = EthSignature.fromCbor(
        buildSigCbor(requestId: reqId, signature: sig65),
      );
      expect(sig.origin, isNull);
    });

    test('fromCbor 缺 requestId 抛异常', () {
      expect(
        () => EthSignature.fromCbor(buildSigCbor(signature: sig65)),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('missing required fields'),
          ),
        ),
      );
    });

    test('fromCbor 缺 signature 抛异常', () {
      expect(
        () => EthSignature.fromCbor(buildSigCbor(requestId: reqId)),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('missing required fields'),
          ),
        ),
      );
    });

    test('fromCbor 非 map CBOR 抛异常', () {
      final notMap = Uint8List.fromList(const CborIntValue(42).encode());
      expect(
        () => EthSignature.fromCbor(notMap),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('must be a map'),
          ),
        ),
      );
    });

    test('fromUr round-trip：UrCodec.encode 包裹后可解析', () {
      final cbor = buildSigCbor(
        requestId: reqId,
        signature: sig65,
        origin: 'Keystone',
      );
      final ur = UrCodec.encode('eth-signature', cbor);
      final sig = EthSignature.fromUr(ur);
      expect(sig.signature, sig65);
      expect(sig.requestId, reqId);
    });

    test('fromUr 类型不为 eth-signature 抛异常', () {
      final ur = UrCodec.encode(
        'eth-sign-request',
        buildSigCbor(requestId: reqId, signature: sig65),
      );
      expect(
        () => EthSignature.fromUr(ur),
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('Expected eth-signature'),
          ),
        ),
      );
    });

    test('signatureHex 为 0x 前缀的 130 位十六进制', () {
      final sig = EthSignature(requestId: reqId, signature: sig65);
      expect(sig.signatureHex, startsWith('0x'));
      expect(sig.signatureHex.length, 2 + 65 * 2);
      expect(sig.signatureHex, '0x${'11' * 32}${'22' * 32}1b');
    });

    test('vrs 拆分 65 字节签名', () {
      final sig = EthSignature(requestId: reqId, signature: sig65);
      final vrs = sig.vrs;
      expect(vrs.v, 0x1B);
      expect(vrs.r, '0x${'11' * 32}');
      expect(vrs.s, '0x${'22' * 32}');
    });

    test('vrs 对非 65 字节签名抛异常', () {
      final sig = EthSignature(
        requestId: reqId,
        signature: Uint8List(64), // 缺 v
      );
      expect(
        () => sig.vrs,
        throwsA(
          isA<UrCodecException>().having(
            (e) => e.message,
            'message',
            contains('must be 65 bytes'),
          ),
        ),
      );
    });
  });
}
