// BC-UR fountain 编解码——Blockchain Commons 参考实现官方测试向量移植
//
// 向量来源：bc-ur/test/test.cpp（用脚本机械提取，非手抄）。
// 这些向量守护与真机硬件钱包（Keystone 等）的逐比特互操作性：
// Xoshiro256** 序列、alias 采样、洗牌、分片、fragment 选择、
// 帧 CBOR、完整 UR 字符串、单帧黄金串、32767 字节多帧 round-trip。

import 'dart:typed_data';

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/crypto/ur_codec.dart';
import 'package:n42_wallet/features/hardware_wallet/crypto/ur_fountain.dart';

String _hex(List<int> data) =>
    data.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

/// 参考实现 test-utils 的 make_message：Xoshiro256(seed).next_data(len)
Uint8List makeMessage(int len, [String seed = 'Wolf']) =>
    Xoshiro256.fromString(seed).nextData(len);

/// 参考实现 test-utils 的 make_message_ur：CBOR bytes 包裹后作为 UR payload
Uint8List makeMessageUrCbor(int len, [String seed = 'Wolf']) {
  final message = makeMessage(len, seed);
  return Uint8List.fromList(CborBytesValue(message).encode());
}

void main() {
  group('Xoshiro256**（官方 RNG 向量）', () {
    test('rng_1: "Wolf" 种子 next()%100 × 100', () {
      final rng = Xoshiro256.fromString('Wolf');
      final numbers = [
        for (var i = 0; i < 100; i++) (rng.next() % BigInt.from(100)).toInt(),
      ];
      expect(numbers, kExpectedRng1);
    });

    test('rng_2: 以 crc32("Wolf") 整数做种', () {
      final checksum = UrCodec.crc32Int(Uint8List.fromList('Wolf'.codeUnits));
      expect(checksum, 0x598c84dc);
      final rng = Xoshiro256.fromCrc32(checksum);
      final numbers = [
        for (var i = 0; i < 100; i++) (rng.next() % BigInt.from(100)).toInt(),
      ];
      expect(numbers, kExpectedRng2);
    });

    test('rng_3: next_int(1,10) × 100', () {
      final rng = Xoshiro256.fromString('Wolf');
      final numbers = [for (var i = 0; i < 100; i++) rng.nextInt(1, 10)];
      expect(numbers, kExpectedRng3);
    });

    test('next_data 前 20 字节（test_xor 向量）', () {
      final rng = Xoshiro256.fromString('Wolf');
      expect(_hex(rng.nextData(10)), '916ec65cf77cadf55cd7');
      expect(_hex(rng.nextData(10)), 'f9cda1a1030026ddd42e');
    });
  });

  group('RandomSampler（alias method 官方向量）', () {
    test('权重 {1,2,4,8} 采样 500 次', () {
      final sampler = RandomSampler([1, 2, 4, 8]);
      final rng = Xoshiro256.fromString('Wolf');
      final samples = [
        for (var i = 0; i < 500; i++) sampler.next(rng.nextDouble),
      ];
      expect(samples, kExpectedSamples);
    });
  });

  group('shuffled（官方向量）', () {
    test('1..10 连续洗牌 10 轮', () {
      final rng = Xoshiro256.fromString('Wolf');
      final values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final result = [for (var i = 0; i < 10; i++) shuffled(values, rng)];
      expect(result, kExpectedShuffles);
    });
  });

  group('FountainEncoder 分片', () {
    test('find_nominal_fragment_length 官方向量', () {
      expect(
        FountainEncoder.findNominalFragmentLength(12345, 1005, 1955),
        1764,
      );
      expect(
        FountainEncoder.findNominalFragmentLength(12345, 1005, 30000),
        12345,
      );
    });

    test('partition_message：1024 字节 → 11 片官方 hex + join 还原', () {
      final message = makeMessage(1024);
      final fragmentLen = FountainEncoder.findNominalFragmentLength(
        message.length,
        10,
        100,
      );
      final fragments = FountainEncoder.partitionMessage(message, fragmentLen);
      expect([for (final f in fragments) _hex(f)], kExpectedFragmentsHex);
      final rejoined = FountainDecoder.joinFragments(fragments, message.length);
      expect(rejoined, message);
    });
  });

  group('chooseDegree / chooseFragments（官方向量）', () {
    test('choose_degree：200 个 "Wolf-n" 种子', () {
      final message = makeMessage(1024);
      final fragmentLen = FountainEncoder.findNominalFragmentLength(
        message.length,
        10,
        100,
      );
      final fragments = FountainEncoder.partitionMessage(message, fragmentLen);
      final degrees = [
        for (var nonce = 1; nonce <= 200; nonce++)
          chooseDegree(fragments.length, Xoshiro256.fromString('Wolf-$nonce')),
      ];
      expect(degrees, kExpectedDegrees);
    });

    test('choose_fragments：seqNum 1..30 的片段集', () {
      final message = makeMessage(1024);
      final checksum = UrCodec.crc32Int(message);
      final fragmentLen = FountainEncoder.findNominalFragmentLength(
        message.length,
        10,
        100,
      );
      final fragments = FountainEncoder.partitionMessage(message, fragmentLen);
      final indexes = [
        for (var seqNum = 1; seqNum <= 30; seqNum++)
          (chooseFragments(seqNum, fragments.length, checksum).toList()
            ..sort()),
      ];
      expect(indexes, kExpectedFragmentIndexes);
    });
  });

  group('FountainEncoder（官方向量）', () {
    test('256 字节消息 20 帧 description', () {
      final encoder = FountainEncoder(makeMessage(256), maxFragmentLen: 30);
      final parts = [
        for (var i = 0; i < 20; i++) encoder.nextPart().description,
      ];
      expect(parts, kExpectedEncoderParts);
    });

    test('256 字节消息 20 帧 CBOR hex', () {
      final encoder = FountainEncoder(makeMessage(256), maxFragmentLen: 30);
      final parts = [
        for (var i = 0; i < 20; i++) _hex(encoder.nextPart().toCbor()),
      ];
      expect(parts, kExpectedEncoderCborHex);
    });

    test('is_complete：生成帧数 == seqLen 时纯片段已全部产出', () {
      final encoder = FountainEncoder(makeMessage(256), maxFragmentLen: 30);
      var generated = 0;
      while (!encoder.isComplete) {
        encoder.nextPart();
        generated++;
      }
      expect(generated, encoder.seqLen);
    });

    test('FountainPart CBOR round-trip', () {
      final part = FountainPart(
        seqNum: 12,
        seqLen: 8,
        messageLen: 100,
        checksum: 0x12345678,
        data: Uint8List.fromList([1, 5, 3, 3, 5]),
      );
      final cbor = part.toCbor();
      final part2 = FountainPart.fromCbor(cbor);
      expect(part2.toCbor(), cbor);
    });
  });

  group('FountainDecoder', () {
    test('32767 字节消息、firstSeqNum=100（全混合帧）round-trip', () {
      final message = makeMessage(32767);
      final encoder = FountainEncoder(
        message,
        maxFragmentLen: 1000,
        firstSeqNum: 100,
      );
      final decoder = FountainDecoder();
      do {
        decoder.receivePart(encoder.nextPart());
      } while (!decoder.isComplete);
      expect(decoder.isSuccess, isTrue, reason: decoder.resultError ?? '');
      expect(decoder.resultMessage, message);
    });

    test('顺序接收前 seqLen 个纯片段即完成', () {
      final message = makeMessage(256);
      final encoder = FountainEncoder(message, maxFragmentLen: 30);
      final decoder = FountainDecoder();
      for (var i = 0; i < encoder.seqLen; i++) {
        decoder.receivePart(encoder.nextPart());
      }
      expect(decoder.isSuccess, isTrue);
      expect(decoder.resultMessage, message);
    });

    test('参数不一致的帧被拒收', () {
      final encoder = FountainEncoder(makeMessage(256), maxFragmentLen: 30);
      final alien = FountainEncoder(makeMessage(300), maxFragmentLen: 30);
      final decoder = FountainDecoder();
      expect(decoder.receivePart(encoder.nextPart()), isTrue);
      expect(decoder.receivePart(alien.nextPart()), isFalse);
    });
  });

  group('FountainPart 边界校验（防恶意 QR DoS）', () {
    // 手工拼一个 [seqNum, seqLen, messageLen, checksum, data] 的 fountain 帧 CBOR。
    Uint8List craft({
      required int seqNum,
      required int seqLen,
      required int messageLen,
      int checksum = 0x12345678,
      int dataLen = 5,
    }) {
      return Uint8List.fromList(
        CborListValue.definite(<CborObject>[
          CborIntValue(seqNum),
          CborIntValue(seqLen),
          CborIntValue(messageLen),
          CborIntValue(checksum),
          CborBytesValue(Uint8List(dataLen)),
        ]).encode(),
      );
    }

    test('巨大 seqLen 被拒（不会分配数十亿元素）', () {
      final cbor = craft(seqNum: 1, seqLen: 2000000000, messageLen: 100);
      expect(
        () => FountainPart.fromCbor(cbor),
        throwsA(isA<UrCodecException>()),
      );
    });

    test('巨大 messageLen 被拒', () {
      final cbor = craft(seqNum: 1, seqLen: 4, messageLen: 999999999);
      expect(
        () => FountainPart.fromCbor(cbor),
        throwsA(isA<UrCodecException>()),
      );
    });

    test('seqLen < 1 被拒', () {
      final cbor = craft(seqNum: 1, seqLen: 0, messageLen: 100);
      expect(
        () => FountainPart.fromCbor(cbor),
        throwsA(isA<UrCodecException>()),
      );
    });

    test('空 data 分片被拒', () {
      final cbor = craft(seqNum: 1, seqLen: 4, messageLen: 100, dataLen: 0);
      expect(
        () => FountainPart.fromCbor(cbor),
        throwsA(isA<UrCodecException>()),
      );
    });

    test('合法边界帧仍可解析', () {
      final cbor = craft(seqNum: 1, seqLen: 4, messageLen: 20, dataLen: 5);
      final part = FountainPart.fromCbor(cbor);
      expect(part.seqLen, 4);
      expect(part.messageLen, 20);
    });
  });

  group('UrEncoder / UrDecoder（官方向量）', () {
    test('单帧 UR 黄金串（50 字节消息）', () {
      final cbor = makeMessageUrCbor(50);
      final encoder = UrEncoder('bytes', cbor, maxFragmentLen: 1000);
      expect(encoder.isSinglePart, isTrue);
      expect(encoder.nextPart(), kExpectedSinglePartUr);
      // 与既有 UrCodec.decode 单帧路径互通
      final decoded = UrCodec.decode(kExpectedSinglePartUr);
      expect(decoded.type, 'bytes');
      expect(decoded.data, cbor);
    });

    test('256 字节消息 20 帧 UR 字符串', () {
      final cbor = makeMessageUrCbor(256);
      final encoder = UrEncoder('bytes', cbor, maxFragmentLen: 30);
      final parts = [for (var i = 0; i < 20; i++) encoder.nextPart()];
      expect(parts, kExpectedUrParts);
    });

    test('多帧 round-trip：32767 字节、firstSeqNum=100', () {
      final cbor = makeMessageUrCbor(32767);
      final encoder = UrEncoder(
        'bytes',
        cbor,
        maxFragmentLen: 1000,
        firstSeqNum: 100,
      );
      final decoder = UrDecoder();
      do {
        decoder.receivePart(encoder.nextPart());
      } while (!decoder.isComplete);
      expect(decoder.isSuccess, isTrue, reason: decoder.error ?? '');
      expect(decoder.result!.type, 'bytes');
      expect(decoder.result!.data, cbor);
    });

    test('UrDecoder 接受大写/混写帧', () {
      final cbor = makeMessageUrCbor(256);
      final encoder = UrEncoder('bytes', cbor, maxFragmentLen: 30);
      final decoder = UrDecoder();
      while (!decoder.isComplete) {
        decoder.receivePart(encoder.nextPart().toUpperCase());
      }
      expect(decoder.isSuccess, isTrue);
      expect(decoder.result!.data, cbor);
    });

    test('UrDecoder 拒绝类型不一致/畸形帧但不打断会话', () {
      final cbor = makeMessageUrCbor(256);
      final encoder = UrEncoder('bytes', cbor, maxFragmentLen: 30);
      final decoder = UrDecoder();
      expect(decoder.receivePart(encoder.nextPart()), isTrue);
      expect(decoder.receivePart('ur:other-type/1-9/aeae'), isFalse);
      expect(decoder.receivePart('not-a-ur'), isFalse);
      expect(decoder.receivePart('ur:bytes'), isFalse);
      while (!decoder.isComplete) {
        decoder.receivePart(encoder.nextPart());
      }
      expect(decoder.isSuccess, isTrue);
    });

    test('进度指标：期望帧数与接收/完成度单调', () {
      final cbor = makeMessageUrCbor(256);
      final encoder = UrEncoder('bytes', cbor, maxFragmentLen: 30);
      final decoder = UrDecoder();
      expect(decoder.expectedPartCount, isNull);
      decoder.receivePart(encoder.nextPart());
      expect(decoder.expectedPartCount, encoder.seqLen);
      expect(decoder.receivedPartCount, 1);
      var last = decoder.estimatedPercentComplete;
      while (!decoder.isComplete) {
        decoder.receivePart(encoder.nextPart());
        final now = decoder.estimatedPercentComplete;
        expect(now, greaterThanOrEqualTo(last));
        last = now;
      }
      expect(decoder.estimatedPercentComplete, 1);
    });
  });
}

// ============ 官方测试向量（机械提取自 bc-ur/test/test.cpp） ============

const kExpectedRng1 = [
  42,
  81,
  85,
  8,
  82,
  84,
  76,
  73,
  70,
  88,
  2,
  74,
  40,
  48,
  77,
  54,
  88,
  7,
  5,
  88,
  37,
  25,
  82,
  13,
  69,
  59,
  30,
  39,
  11,
  82,
  19,
  99,
  45,
  87,
  30,
  15,
  32,
  22,
  89,
  44,
  92,
  77,
  29,
  78,
  4,
  92,
  44,
  68,
  92,
  69,
  1,
  42,
  89,
  50,
  37,
  84,
  63,
  34,
  32,
  3,
  17,
  62,
  40,
  98,
  82,
  89,
  24,
  43,
  85,
  39,
  15,
  3,
  99,
  29,
  20,
  42,
  27,
  10,
  85,
  66,
  50,
  35,
  69,
  70,
  70,
  74,
  30,
  13,
  72,
  54,
  11,
  5,
  70,
  55,
  91,
  52,
  10,
  43,
  43,
  52,
];

const kExpectedRng2 = [
  88,
  44,
  94,
  74,
  0,
  99,
  7,
  77,
  68,
  35,
  47,
  78,
  19,
  21,
  50,
  15,
  42,
  36,
  91,
  11,
  85,
  39,
  64,
  22,
  57,
  11,
  25,
  12,
  1,
  91,
  17,
  75,
  29,
  47,
  88,
  11,
  68,
  58,
  27,
  65,
  21,
  54,
  47,
  54,
  73,
  83,
  23,
  58,
  75,
  27,
  26,
  15,
  60,
  36,
  30,
  21,
  55,
  57,
  77,
  76,
  75,
  47,
  53,
  76,
  9,
  91,
  14,
  69,
  3,
  95,
  11,
  73,
  20,
  99,
  68,
  61,
  3,
  98,
  36,
  98,
  56,
  65,
  14,
  80,
  74,
  57,
  63,
  68,
  51,
  56,
  24,
  39,
  53,
  80,
  57,
  51,
  81,
  3,
  1,
  30,
];

const kExpectedRng3 = [
  6,
  5,
  8,
  4,
  10,
  5,
  7,
  10,
  4,
  9,
  10,
  9,
  7,
  7,
  1,
  1,
  2,
  9,
  9,
  2,
  6,
  4,
  5,
  7,
  8,
  5,
  4,
  2,
  3,
  8,
  7,
  4,
  5,
  1,
  10,
  9,
  3,
  10,
  2,
  6,
  8,
  5,
  7,
  9,
  3,
  1,
  5,
  2,
  7,
  1,
  4,
  4,
  4,
  4,
  9,
  4,
  5,
  5,
  6,
  9,
  5,
  1,
  2,
  8,
  3,
  3,
  2,
  8,
  4,
  3,
  2,
  1,
  10,
  8,
  9,
  3,
  10,
  8,
  5,
  5,
  6,
  7,
  10,
  5,
  8,
  9,
  4,
  6,
  4,
  2,
  10,
  2,
  1,
  7,
  9,
  6,
  7,
  4,
  2,
  5,
];

const kExpectedSamples = [
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  0,
  2,
  3,
  3,
  3,
  3,
  1,
  2,
  2,
  1,
  3,
  3,
  2,
  3,
  3,
  1,
  1,
  2,
  1,
  1,
  3,
  1,
  3,
  1,
  2,
  0,
  2,
  1,
  0,
  3,
  3,
  3,
  1,
  3,
  3,
  3,
  3,
  1,
  3,
  2,
  3,
  2,
  2,
  3,
  3,
  3,
  3,
  2,
  3,
  3,
  0,
  3,
  3,
  3,
  3,
  1,
  2,
  3,
  3,
  2,
  2,
  2,
  1,
  2,
  2,
  1,
  2,
  3,
  1,
  3,
  0,
  3,
  2,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  2,
  3,
  1,
  3,
  3,
  2,
  0,
  2,
  2,
  3,
  1,
  1,
  2,
  3,
  2,
  3,
  3,
  3,
  3,
  2,
  3,
  3,
  3,
  3,
  3,
  2,
  3,
  1,
  2,
  1,
  1,
  3,
  1,
  3,
  2,
  2,
  3,
  3,
  3,
  1,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  2,
  3,
  2,
  3,
  3,
  1,
  2,
  3,
  3,
  1,
  3,
  2,
  3,
  3,
  3,
  2,
  3,
  1,
  3,
  0,
  3,
  2,
  1,
  1,
  3,
  1,
  3,
  2,
  3,
  3,
  3,
  3,
  2,
  0,
  3,
  3,
  1,
  3,
  0,
  2,
  1,
  3,
  3,
  1,
  1,
  3,
  1,
  2,
  3,
  3,
  3,
  0,
  2,
  3,
  2,
  0,
  1,
  3,
  3,
  3,
  2,
  2,
  2,
  3,
  3,
  3,
  3,
  3,
  2,
  3,
  3,
  3,
  3,
  2,
  3,
  3,
  2,
  0,
  2,
  3,
  3,
  3,
  3,
  2,
  1,
  1,
  1,
  2,
  1,
  3,
  3,
  3,
  2,
  2,
  3,
  3,
  1,
  2,
  3,
  0,
  3,
  2,
  3,
  3,
  3,
  3,
  0,
  2,
  2,
  3,
  2,
  2,
  3,
  3,
  3,
  3,
  1,
  3,
  2,
  3,
  3,
  3,
  3,
  3,
  2,
  2,
  3,
  1,
  3,
  0,
  2,
  1,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  1,
  3,
  3,
  3,
  3,
  2,
  2,
  2,
  3,
  1,
  1,
  3,
  2,
  2,
  0,
  3,
  2,
  1,
  2,
  1,
  0,
  3,
  3,
  3,
  2,
  2,
  3,
  2,
  1,
  2,
  0,
  0,
  3,
  3,
  2,
  3,
  3,
  2,
  3,
  3,
  3,
  3,
  3,
  2,
  2,
  2,
  3,
  3,
  3,
  3,
  3,
  1,
  1,
  3,
  2,
  2,
  3,
  1,
  1,
  0,
  1,
  3,
  2,
  3,
  3,
  2,
  3,
  3,
  2,
  3,
  3,
  2,
  2,
  2,
  2,
  3,
  2,
  2,
  2,
  2,
  2,
  1,
  2,
  3,
  3,
  2,
  2,
  2,
  2,
  3,
  3,
  2,
  0,
  2,
  1,
  3,
  3,
  3,
  3,
  0,
  3,
  3,
  3,
  3,
  2,
  2,
  3,
  1,
  3,
  3,
  3,
  2,
  3,
  3,
  3,
  2,
  3,
  3,
  3,
  3,
  2,
  3,
  2,
  1,
  3,
  3,
  3,
  3,
  2,
  2,
  0,
  1,
  2,
  3,
  2,
  0,
  3,
  3,
  3,
  3,
  3,
  3,
  1,
  3,
  3,
  2,
  3,
  2,
  2,
  3,
  3,
  3,
  3,
  3,
  2,
  2,
  3,
  3,
  2,
  2,
  2,
  1,
  3,
  3,
  3,
  3,
  1,
  2,
  3,
  2,
  3,
  3,
  2,
  3,
  2,
  3,
  3,
  3,
  2,
  3,
  1,
  2,
  3,
  2,
  1,
  1,
  3,
  3,
  2,
  3,
  3,
  2,
  3,
  3,
  0,
  0,
  1,
  3,
  3,
  2,
  3,
  3,
  3,
  3,
  1,
  3,
  3,
  0,
  3,
  2,
  3,
  3,
  1,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  0,
  3,
  3,
  2,
];

const kExpectedShuffles = [
  [6, 4, 9, 3, 10, 5, 7, 8, 1, 2],
  [10, 8, 6, 5, 1, 2, 3, 9, 7, 4],
  [6, 4, 5, 8, 9, 3, 2, 1, 7, 10],
  [7, 3, 5, 1, 10, 9, 4, 8, 2, 6],
  [8, 5, 7, 10, 2, 1, 4, 3, 9, 6],
  [4, 3, 5, 6, 10, 2, 7, 8, 9, 1],
  [5, 1, 3, 9, 4, 6, 2, 10, 7, 8],
  [2, 1, 10, 8, 9, 4, 7, 6, 3, 5],
  [6, 7, 10, 4, 8, 9, 2, 3, 1, 5],
  [10, 2, 1, 7, 9, 5, 6, 3, 4, 8],
];

const kExpectedFragmentsHex = [
  '916ec65cf77cadf55cd7f9cda1a1030026ddd42e905b77adc36e4f2d3ccba44f7f04f2de44f42d84c374a0e149136f25b01852545961d55f7f7a8cde6d0e2ec43f3b2dcb644a2209e8c9e34af5c4747984a5e873c9cf5f965e25ee29039f',
  'df8ca74f1c769fc07eb7ebaec46e0695aea6cbd60b3ec4bbff1b9ffe8a9e7240129377b9d3711ed38d412fbb4442256f1e6f595e0fc57fed451fb0a0101fb76b1fb1e1b88cfdfdaa946294a47de8fff173f021c0e6f65b05c0a494e50791',
  '270a0050a73ae69b6725505a2ec8a5791457c9876dd34aadd192a53aa0dc66b556c0c215c7ceb8248b717c22951e65305b56a3706e3e86eb01c803bbf915d80edcd64d4d41977fa6f78dc07eecd072aae5bc8a852397e06034dba6a0b570',
  '797c3a89b16673c94838d884923b8186ee2db5c98407cab15e13678d072b43e406ad49477c2e45e85e52ca82a94f6df7bbbe7afbed3a3a830029f29090f25217e48d1f42993a640a67916aa7480177354cc7440215ae41e4d02eae9a1912',
  '33a6d4922a792c1b7244aa879fefdb4628dc8b0923568869a983b8c661ffab9b2ed2c149e38d41fba090b94155adbed32f8b18142ff0d7de4eeef2b04adf26f2456b46775c6c20b37602df7da179e2332feba8329bbb8d727a138b4ba7a5',
  '03215eda2ef1e953d89383a382c11d3f2cad37a4ee59a91236a3e56dcf89f6ac81dd4159989c317bd649d9cbc617f73fe10033bd288c60977481a09b343d3f676070e67da757b86de27bfca74392bac2996f7822a7d8f71a489ec6180390',
  '089ea80a8fcd6526413ec6c9a339115f111d78ef21d456660aa85f790910ffa2dc58d6a5b93705caef1091474938bd312427021ad1eeafbd19e0d916ddb111fabd8dcab5ad6a6ec3a9c6973809580cb2c164e26686b5b98cfb017a337968',
  'c7daaa14ae5152a067277b1b3902677d979f8e39cc2aafb3bc06fcf69160a853e6869dcc09a11b5009f91e6b89e5b927ab1527a735660faa6012b420dd926d940d742be6a64fb01cdc0cff9faa323f02ba41436871a0eab851e7f5782d10',
  'fbefde2a7e9ae9dc1e5c2c48f74f6c824ce9ef3c89f68800d44587bedc4ab417cfb3e7447d90e1e417e6e05d30e87239d3a5d1d45993d4461e60a0192831640aa32dedde185a371ded2ae15f8a93dba8809482ce49225daadfbb0fec629e',
  '23880789bdf9ed73be57fa84d555134630e8d0f7df48349f29869a477c13ccca9cd555ac42ad7f568416c3d61959d0ed568b2b81c7771e9088ad7fd55fd4386bafbf5a528c30f107139249357368ffa980de2c76ddd9ce4191376be0e6b5',
  '170010067e2e75ebe2d2904aeb1f89d5dc98cd4a6f2faaa8be6d03354c990fd895a97feb54668473e9d942bb99e196d897e8f1b01625cf48a7b78d249bb4985c065aa8cd1402ed2ba1b6f908f63dcd84b66425df00000000000000000000',
];

const kExpectedDegrees = [
  11,
  3,
  6,
  5,
  2,
  1,
  2,
  11,
  1,
  3,
  9,
  10,
  10,
  4,
  2,
  1,
  1,
  2,
  1,
  1,
  5,
  2,
  4,
  10,
  3,
  2,
  1,
  1,
  3,
  11,
  2,
  6,
  2,
  9,
  9,
  2,
  6,
  7,
  2,
  5,
  2,
  4,
  3,
  1,
  6,
  11,
  2,
  11,
  3,
  1,
  6,
  3,
  1,
  4,
  5,
  3,
  6,
  1,
  1,
  3,
  1,
  2,
  2,
  1,
  4,
  5,
  1,
  1,
  9,
  1,
  1,
  6,
  4,
  1,
  5,
  1,
  2,
  2,
  3,
  1,
  1,
  5,
  2,
  6,
  1,
  7,
  11,
  1,
  8,
  1,
  5,
  1,
  1,
  2,
  2,
  6,
  4,
  10,
  1,
  2,
  5,
  5,
  5,
  1,
  1,
  4,
  1,
  1,
  1,
  3,
  5,
  5,
  5,
  1,
  4,
  3,
  3,
  5,
  1,
  11,
  3,
  2,
  8,
  1,
  2,
  1,
  1,
  4,
  5,
  2,
  1,
  1,
  1,
  5,
  6,
  11,
  10,
  7,
  4,
  7,
  1,
  5,
  3,
  1,
  1,
  9,
  1,
  2,
  5,
  5,
  2,
  2,
  3,
  10,
  1,
  3,
  2,
  3,
  3,
  1,
  1,
  2,
  1,
  3,
  2,
  2,
  1,
  3,
  8,
  4,
  1,
  11,
  6,
  3,
  1,
  1,
  1,
  1,
  1,
  3,
  1,
  2,
  1,
  10,
  1,
  1,
  8,
  2,
  7,
  1,
  2,
  1,
  9,
  2,
  10,
  2,
  1,
  3,
  4,
  10,
];

const kExpectedFragmentIndexes = [
  [0],
  [1],
  [2],
  [3],
  [4],
  [5],
  [6],
  [7],
  [8],
  [9],
  [10],
  [9],
  [2, 5, 6, 8, 9, 10],
  [8],
  [1, 5],
  [1],
  [0, 2, 4, 5, 8, 10],
  [5],
  [2],
  [2],
  [0, 1, 3, 4, 5, 7, 9, 10],
  [0, 1, 2, 3, 5, 6, 8, 9, 10],
  [0, 2, 4, 5, 7, 8, 9, 10],
  [3, 5],
  [4],
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  [0, 1, 3, 4, 5, 6, 7, 9, 10],
  [6],
  [5, 6],
  [7],
];

const kExpectedEncoderParts = [
  'seqNum:1, seqLen:9, messageLen:256, checksum:23570951, data:916ec65cf77cadf55cd7f9cda1a1030026ddd42e905b77adc36e4f2d3c',
  'seqNum:2, seqLen:9, messageLen:256, checksum:23570951, data:cba44f7f04f2de44f42d84c374a0e149136f25b01852545961d55f7f7a',
  'seqNum:3, seqLen:9, messageLen:256, checksum:23570951, data:8cde6d0e2ec43f3b2dcb644a2209e8c9e34af5c4747984a5e873c9cf5f',
  'seqNum:4, seqLen:9, messageLen:256, checksum:23570951, data:965e25ee29039fdf8ca74f1c769fc07eb7ebaec46e0695aea6cbd60b3e',
  'seqNum:5, seqLen:9, messageLen:256, checksum:23570951, data:c4bbff1b9ffe8a9e7240129377b9d3711ed38d412fbb4442256f1e6f59',
  'seqNum:6, seqLen:9, messageLen:256, checksum:23570951, data:5e0fc57fed451fb0a0101fb76b1fb1e1b88cfdfdaa946294a47de8fff1',
  'seqNum:7, seqLen:9, messageLen:256, checksum:23570951, data:73f021c0e6f65b05c0a494e50791270a0050a73ae69b6725505a2ec8a5',
  'seqNum:8, seqLen:9, messageLen:256, checksum:23570951, data:791457c9876dd34aadd192a53aa0dc66b556c0c215c7ceb8248b717c22',
  'seqNum:9, seqLen:9, messageLen:256, checksum:23570951, data:951e65305b56a3706e3e86eb01c803bbf915d80edcd64d4d0000000000',
  'seqNum:10, seqLen:9, messageLen:256, checksum:23570951, data:330f0f33a05eead4f331df229871bee733b50de71afd2e5a79f196de09',
  'seqNum:11, seqLen:9, messageLen:256, checksum:23570951, data:3b205ce5e52d8c24a52cffa34c564fa1af3fdffcd349dc4258ee4ee828',
  'seqNum:12, seqLen:9, messageLen:256, checksum:23570951, data:dd7bf725ea6c16d531b5f03254783803048ca08b87148daacd1cd7a006',
  'seqNum:13, seqLen:9, messageLen:256, checksum:23570951, data:760be7ad1c6187902bbc04f539b9ee5eb8ea6833222edea36031306c01',
  'seqNum:14, seqLen:9, messageLen:256, checksum:23570951, data:5bf4031217d2c3254b088fa7553778b5003632f46e21db129416f65b55',
  'seqNum:15, seqLen:9, messageLen:256, checksum:23570951, data:73f021c0e6f65b05c0a494e50791270a0050a73ae69b6725505a2ec8a5',
  'seqNum:16, seqLen:9, messageLen:256, checksum:23570951, data:b8546ebfe2048541348910267331c643133f828afec9337c318f71b7df',
  'seqNum:17, seqLen:9, messageLen:256, checksum:23570951, data:23dedeea74e3a0fb052befabefa13e2f80e4315c9dceed4c8630612e64',
  'seqNum:18, seqLen:9, messageLen:256, checksum:23570951, data:d01a8daee769ce34b6b35d3ca0005302724abddae405bdb419c0a6b208',
  'seqNum:19, seqLen:9, messageLen:256, checksum:23570951, data:3171c5dc365766eff25ae47c6f10e7de48cfb8474e050e5fe997a6dc24',
  'seqNum:20, seqLen:9, messageLen:256, checksum:23570951, data:e055c2433562184fa71b4be94f262e200f01c6f74c284b0dc6fae6673f',
];

const kExpectedEncoderCborHex = [
  '8501091901001a0167aa07581d916ec65cf77cadf55cd7f9cda1a1030026ddd42e905b77adc36e4f2d3c',
  '8502091901001a0167aa07581dcba44f7f04f2de44f42d84c374a0e149136f25b01852545961d55f7f7a',
  '8503091901001a0167aa07581d8cde6d0e2ec43f3b2dcb644a2209e8c9e34af5c4747984a5e873c9cf5f',
  '8504091901001a0167aa07581d965e25ee29039fdf8ca74f1c769fc07eb7ebaec46e0695aea6cbd60b3e',
  '8505091901001a0167aa07581dc4bbff1b9ffe8a9e7240129377b9d3711ed38d412fbb4442256f1e6f59',
  '8506091901001a0167aa07581d5e0fc57fed451fb0a0101fb76b1fb1e1b88cfdfdaa946294a47de8fff1',
  '8507091901001a0167aa07581d73f021c0e6f65b05c0a494e50791270a0050a73ae69b6725505a2ec8a5',
  '8508091901001a0167aa07581d791457c9876dd34aadd192a53aa0dc66b556c0c215c7ceb8248b717c22',
  '8509091901001a0167aa07581d951e65305b56a3706e3e86eb01c803bbf915d80edcd64d4d0000000000',
  '850a091901001a0167aa07581d330f0f33a05eead4f331df229871bee733b50de71afd2e5a79f196de09',
  '850b091901001a0167aa07581d3b205ce5e52d8c24a52cffa34c564fa1af3fdffcd349dc4258ee4ee828',
  '850c091901001a0167aa07581ddd7bf725ea6c16d531b5f03254783803048ca08b87148daacd1cd7a006',
  '850d091901001a0167aa07581d760be7ad1c6187902bbc04f539b9ee5eb8ea6833222edea36031306c01',
  '850e091901001a0167aa07581d5bf4031217d2c3254b088fa7553778b5003632f46e21db129416f65b55',
  '850f091901001a0167aa07581d73f021c0e6f65b05c0a494e50791270a0050a73ae69b6725505a2ec8a5',
  '8510091901001a0167aa07581db8546ebfe2048541348910267331c643133f828afec9337c318f71b7df',
  '8511091901001a0167aa07581d23dedeea74e3a0fb052befabefa13e2f80e4315c9dceed4c8630612e64',
  '8512091901001a0167aa07581dd01a8daee769ce34b6b35d3ca0005302724abddae405bdb419c0a6b208',
  '8513091901001a0167aa07581d3171c5dc365766eff25ae47c6f10e7de48cfb8474e050e5fe997a6dc24',
  '8514091901001a0167aa07581de055c2433562184fa71b4be94f262e200f01c6f74c284b0dc6fae6673f',
];

const kExpectedSinglePartUr =
    'ur:bytes/hdeymejtswhhylkepmykhhtsytsnoyoyaxaedsuttydmmhhpktpmsrjtgwdpfnsboxgwlbaawzuefywkdplrsrjynbvygabwjldapfcsdwkbrkch';

const kExpectedUrParts = [
  'ur:bytes/1-9/lpadascfadaxcywenbpljkhdcahkadaemejtswhhylkepmykhhtsytsnoyoyaxaedsuttydmmhhpktpmsrjtdkgslpgh',
  'ur:bytes/2-9/lpaoascfadaxcywenbpljkhdcagwdpfnsboxgwlbaawzuefywkdplrsrjynbvygabwjldapfcsgmghhkhstlrdcxaefz',
  'ur:bytes/3-9/lpaxascfadaxcywenbpljkhdcahelbknlkuejnbadmssfhfrdpsbiegecpasvssovlgeykssjykklronvsjksopdzmol',
  'ur:bytes/4-9/lpaaascfadaxcywenbpljkhdcasotkhemthydawydtaxneurlkosgwcekonertkbrlwmplssjtammdplolsbrdzcrtas',
  'ur:bytes/5-9/lpahascfadaxcywenbpljkhdcatbbdfmssrkzmcwnezelennjpfzbgmuktrhtejscktelgfpdlrkfyfwdajldejokbwf',
  'ur:bytes/6-9/lpamascfadaxcywenbpljkhdcackjlhkhybssklbwefectpfnbbectrljectpavyrolkzczcpkmwidmwoxkilghdsowp',
  'ur:bytes/7-9/lpatascfadaxcywenbpljkhdcavszmwnjkwtclrtvaynhpahrtoxmwvwatmedibkaegdosftvandiodagdhthtrlnnhy',
  'ur:bytes/8-9/lpayascfadaxcywenbpljkhdcadmsponkkbbhgsoltjntegepmttmoonftnbuoiyrehfrtsabzsttorodklubbuyaetk',
  'ur:bytes/9-9/lpasascfadaxcywenbpljkhdcajskecpmdckihdyhphfotjojtfmlnwmadspaxrkytbztpbauotbgtgtaeaevtgavtny',
  'ur:bytes/10-9/lpbkascfadaxcywenbpljkhdcahkadaemejtswhhylkepmykhhtsytsnoyoyaxaedsuttydmmhhpktpmsrjtwdkiplzs',
  'ur:bytes/11-9/lpbdascfadaxcywenbpljkhdcahelbknlkuejnbadmssfhfrdpsbiegecpasvssovlgeykssjykklronvsjkvetiiapk',
  'ur:bytes/12-9/lpbnascfadaxcywenbpljkhdcarllaluzmdmgstospeyiefmwejlwtpedamktksrvlcygmzemovovllarodtmtbnptrs',
  'ur:bytes/13-9/lpbtascfadaxcywenbpljkhdcamtkgtpknghchchyketwsvwgwfdhpgmgtylctotzopdrpayoschcmhplffziachrfgd',
  'ur:bytes/14-9/lpbaascfadaxcywenbpljkhdcapazewnvonnvdnsbyleynwtnsjkjndeoldydkbkdslgjkbbkortbelomueekgvstegt',
  'ur:bytes/15-9/lpbsascfadaxcywenbpljkhdcaynmhpddpzmversbdqdfyrehnqzlugmjzmnmtwmrouohtstgsbsahpawkditkckynwt',
  'ur:bytes/16-9/lpbeascfadaxcywenbpljkhdcawygekobamwtlihsnpalnsghenskkiynthdzotsimtojetprsttmukirlrsbtamjtpd',
  'ur:bytes/17-9/lpbyascfadaxcywenbpljkhdcamklgftaxykpewyrtqzhydntpnytyisincxmhtbceaykolduortotiaiaiafhiaoyce',
  'ur:bytes/18-9/lpbgascfadaxcywenbpljkhdcahkadaemejtswhhylkepmykhhtsytsnoyoyaxaedsuttydmmhhpktpmsrjtntwkbkwy',
  'ur:bytes/19-9/lpbwascfadaxcywenbpljkhdcadekicpaajootjzpsdrbalpeywllbdsnbinaerkurspbncxgslgftvtsrjtksplcpeo',
  'ur:bytes/20-9/lpbbascfadaxcywenbpljkhdcayapmrleeleaxpasfrtrdkncffwjyjzgyetdmlewtkpktgllepfrltataztksmhkbot',
];
