// LedgerApduUtils（生产类）单元测试
//
// 注意：test/features/hardware_wallet/ledger_utils_test.dart 测试的是
// 该文件内部的副本，不覆盖生产代码；本文件直接 import
// lib/features/hardware_wallet/service/ledger_apdu_utils.dart 测真实实现。
//
// 覆盖：
// - buildGetAppNameApdu / buildEthGetAddressApdu / buildEthSignTxApdu
// - serializeDerivationPath
// - handleApduStatusCode（成功/短包/各错误码/未知码）
// - handlePlatformExceptionCode
// - splitIntoChunks 边界
// - encodeSignature（含 v=0 补零）

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/service/ledger_apdu_utils.dart';

/// 匹配指定错误码的 HardwareWalletError
Matcher throwsHwError(String code) => throwsA(
      isA<HardwareWalletError>().having((e) => e.code, 'code', code),
    );

void main() {
  const path = "m/44'/60'/0'/0/0";
  // 5 个分量：1 字节计数 + 5 * 4 字节 = 21 字节
  final expectedPathBytes = [
    5,
    0x80, 0x00, 0x00, 0x2C, // 44'
    0x80, 0x00, 0x00, 0x3C, // 60'
    0x80, 0x00, 0x00, 0x00, // 0'
    0x00, 0x00, 0x00, 0x00, // 0
    0x00, 0x00, 0x00, 0x00, // 0
  ];

  group('serializeDerivationPath', () {
    test("标准路径 m/44'/60'/0'/0/0 -> 计数 + 大端 4 字节分量", () {
      expect(LedgerApduUtils.serializeDerivationPath(path), expectedPathBytes);
    });

    test('无 m 前缀的路径同样可序列化', () {
      expect(
        LedgerApduUtils.serializeDerivationPath("44'/60'"),
        [2, 0x80, 0x00, 0x00, 0x2C, 0x80, 0x00, 0x00, 0x3C],
      );
    });

    test('仅 "m" 的路径 -> 只有 0 计数字节', () {
      expect(LedgerApduUtils.serializeDerivationPath('m'), [0]);
    });

    test('非硬化大索引的大端编码', () {
      // 0x01020304 = 16909060
      expect(
        LedgerApduUtils.serializeDerivationPath('m/16909060'),
        [1, 0x01, 0x02, 0x03, 0x04],
      );
    });
  });

  group('buildGetAppNameApdu', () {
    test('固定 APDU B0 01 00 00 00', () {
      expect(
        LedgerApduUtils.buildGetAppNameApdu(),
        [0xB0, 0x01, 0x00, 0x00, 0x00],
      );
    });
  });

  group('buildEthGetAddressApdu', () {
    test('display=false -> P1=0x00，头部与路径长度正确', () {
      final apdu = LedgerApduUtils.buildEthGetAddressApdu(path, false);
      expect(apdu[0], 0xE0); // CLA
      expect(apdu[1], 0x02); // INS: GET_PUBLIC_KEY
      expect(apdu[2], 0x00); // P1: no display
      expect(apdu[3], 0x00); // P2
      expect(apdu[4], 21); // Lc = 路径字节长度
      expect(apdu.sublist(5), expectedPathBytes);
      expect(apdu.length, 5 + 21);
    });

    test('display=true -> P1=0x01', () {
      final apdu = LedgerApduUtils.buildEthGetAddressApdu(path, true);
      expect(apdu[2], 0x01);
    });
  });

  group('buildEthSignTxApdu', () {
    final txData = Uint8List.fromList(List.generate(10, (i) => 0xD0 + i));

    test('isFirst=true -> P1=0x00，payload = 路径 + 数据', () {
      final apdu = LedgerApduUtils.buildEthSignTxApdu(
        path,
        txData,
        isFirst: true,
      );
      expect(apdu[0], 0xE0);
      expect(apdu[1], 0x04); // INS: SIGN
      expect(apdu[2], 0x00); // P1: first chunk
      expect(apdu[3], 0x00);
      expect(apdu[4], 21 + txData.length); // Lc
      expect(apdu.sublist(5, 5 + 21), expectedPathBytes);
      expect(apdu.sublist(5 + 21), txData);
    });

    test('isFirst=false -> P1=0x80，payload 仅含数据（无路径）', () {
      final apdu = LedgerApduUtils.buildEthSignTxApdu(
        path,
        txData,
        isFirst: false,
      );
      expect(apdu[2], 0x80); // P1: subsequent chunk
      expect(apdu[4], txData.length);
      expect(apdu.sublist(5), txData);
      expect(apdu.length, 5 + txData.length);
    });

    test('payload 恰为 255 字节（Lc 上限）不抛，Lc=0xFF', () {
      // isFirst=false 时 payload 即 data
      final data = Uint8List(255);
      final apdu = LedgerApduUtils.buildEthSignTxApdu(
        path,
        data,
        isFirst: false,
      );
      expect(apdu[4], 0xFF);
      expect(apdu.length, 5 + 255);
    });

    test('payload 超过 255 字节抛 ArgumentError（曾静默截断 Lc）', () {
      final data = Uint8List(256);
      expect(
        () => LedgerApduUtils.buildEthSignTxApdu(path, data, isFirst: false),
        throwsArgumentError,
      );
    });

    test('isFirst=true 时路径字节计入 payload：21+235=256 超限抛出，21+234=255 通过', () {
      // path 序列化后 21 字节
      expect(
        () => LedgerApduUtils.buildEthSignTxApdu(
          path,
          Uint8List(235),
          isFirst: true,
        ),
        throwsArgumentError,
      );
      final apdu = LedgerApduUtils.buildEthSignTxApdu(
        path,
        Uint8List(234),
        isFirst: true,
      );
      expect(apdu[4], 0xFF);
    });
  });

  group('handleApduStatusCode', () {
    test('0x9000 长包 -> 剥离末尾 2 字节状态码', () {
      final result = Uint8List.fromList([0xAA, 0xBB, 0xCC, 0x90, 0x00]);
      expect(
        LedgerApduUtils.handleApduStatusCode(0x9000, result),
        [0xAA, 0xBB, 0xCC],
      );
    });

    test('0x9000 短包（仅 2 字节状态码）-> 返回空', () {
      final result = Uint8List.fromList([0x90, 0x00]);
      expect(LedgerApduUtils.handleApduStatusCode(0x9000, result), isEmpty);
    });

    test('0x9000 空包 -> 返回空', () {
      expect(
        LedgerApduUtils.handleApduStatusCode(0x9000, Uint8List(0)),
        isEmpty,
      );
    });

    test('0x6985 -> userRejected', () {
      expect(
        () => LedgerApduUtils.handleApduStatusCode(0x6985, Uint8List(0)),
        throwsHwError(HardwareWalletError.userRejected),
      );
    });

    test('0x5501 -> userRejected', () {
      expect(
        () => LedgerApduUtils.handleApduStatusCode(0x5501, Uint8List(0)),
        throwsHwError(HardwareWalletError.userRejected),
      );
    });

    test('0x6A82 -> appNotOpen', () {
      expect(
        () => LedgerApduUtils.handleApduStatusCode(0x6A82, Uint8List(0)),
        throwsHwError(HardwareWalletError.appNotOpen),
      );
    });

    test('0x6D00（INS 不支持）-> appNotOpen', () {
      expect(
        () => LedgerApduUtils.handleApduStatusCode(0x6D00, Uint8List(0)),
        throwsHwError(HardwareWalletError.appNotOpen),
      );
    });

    test('0x6E00（CLA 不支持）-> appNotOpen', () {
      expect(
        () => LedgerApduUtils.handleApduStatusCode(0x6E00, Uint8List(0)),
        throwsHwError(HardwareWalletError.appNotOpen),
      );
    });

    test('0x6982 -> deviceLocked', () {
      expect(
        () => LedgerApduUtils.handleApduStatusCode(0x6982, Uint8List(0)),
        throwsHwError(HardwareWalletError.deviceLocked),
      );
    });

    test('0x5515 -> deviceLocked', () {
      expect(
        () => LedgerApduUtils.handleApduStatusCode(0x5515, Uint8List(0)),
        throwsHwError(HardwareWalletError.deviceLocked),
      );
    });

    test('0x6700 -> invalidTransaction', () {
      expect(
        () => LedgerApduUtils.handleApduStatusCode(0x6700, Uint8List(0)),
        throwsHwError(HardwareWalletError.invalidTransaction),
      );
    });

    test('未知状态码 -> 原样返回 result（不抛出）', () {
      final result = Uint8List.fromList([0x01, 0x02, 0x6F, 0x42]);
      expect(LedgerApduUtils.handleApduStatusCode(0x6F42, result), result);
    });
  });

  group('handlePlatformExceptionCode', () {
    test('"6985" -> userRejected', () {
      expect(
        () => LedgerApduUtils.handlePlatformExceptionCode('6985'),
        throwsHwError(HardwareWalletError.userRejected),
      );
    });

    test('大写 "6A82" 大小写不敏感 -> appNotOpen', () {
      expect(
        () => LedgerApduUtils.handlePlatformExceptionCode('6A82'),
        throwsHwError(HardwareWalletError.appNotOpen),
      );
    });

    test('"5515" -> deviceLocked', () {
      expect(
        () => LedgerApduUtils.handlePlatformExceptionCode('5515'),
        throwsHwError(HardwareWalletError.deviceLocked),
      );
    });

    test('未知错误码不抛出', () {
      expect(
        () => LedgerApduUtils.handlePlatformExceptionCode('9000'),
        returnsNormally,
      );
      expect(
        () => LedgerApduUtils.handlePlatformExceptionCode('whatever'),
        returnsNormally,
      );
    });
  });

  group('splitIntoChunks', () {
    test('有余数：10 字节按 4 分块 -> [4,4,2]', () {
      final data = Uint8List.fromList(List.generate(10, (i) => i));
      final chunks = LedgerApduUtils.splitIntoChunks(data, 4);
      expect(chunks.map((c) => c.length), [4, 4, 2]);
      expect(chunks[0], [0, 1, 2, 3]);
      expect(chunks[2], [8, 9]);
      // 拼回原数据
      expect(chunks.expand((c) => c), data);
    });

    test('整除：8 字节按 4 分块 -> [4,4]', () {
      final data = Uint8List.fromList(List.generate(8, (i) => i));
      expect(
        LedgerApduUtils.splitIntoChunks(data, 4).map((c) => c.length),
        [4, 4],
      );
    });

    test('块大小大于数据 -> 单块', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final chunks = LedgerApduUtils.splitIntoChunks(data, 100);
      expect(chunks.length, 1);
      expect(chunks[0], [1, 2, 3]);
    });

    test('块大小恰等于数据长度 -> 单块', () {
      final data = Uint8List.fromList([1, 2, 3]);
      expect(LedgerApduUtils.splitIntoChunks(data, 3).length, 1);
    });

    test('空数据 -> 空列表', () {
      expect(LedgerApduUtils.splitIntoChunks(Uint8List(0), 4), isEmpty);
    });
  });

  group('encodeSignature', () {
    final r = Uint8List.fromList(List.filled(32, 0x11));
    final s = Uint8List.fromList(List.filled(32, 0x22));

    test('顺序为 0x + r + s + v', () {
      expect(
        LedgerApduUtils.encodeSignature(0x1B, r, s),
        '0x${'11' * 32}${'22' * 32}1b',
      );
    });

    test('v=0 补零为 "00"', () {
      final sig = LedgerApduUtils.encodeSignature(0, r, s);
      expect(sig.endsWith('00'), isTrue);
      expect(sig.length, 2 + 64 + 64 + 2); // 0x + r + s + v
    });

    test('r/s 中的前导零字节保留', () {
      final rz = Uint8List.fromList([0x00, ...List.filled(31, 0xAB)]);
      final sig = LedgerApduUtils.encodeSignature(1, rz, s);
      expect(sig.substring(2, 4), '00');
      expect(sig.substring(4, 6), 'ab');
    });
  });
}
