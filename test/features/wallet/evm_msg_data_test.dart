import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex;

void main() {
  group('EvmSender.buildMsgData', () {
    // 原生签名层按 hex 解码 msgData。calldata 必须剥掉 0x 后原样透传，
    // 否则 hex 文本会被当字符串编码，合约调用上链 revert（假成功、烧 gas）。
    const approveCalldata =
        '0x095ea7b3'
        '00000000000000000000000068b3465833fb72a70ecdf485e0e4c7bd8665fc45'
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

    test('calldata 剥离 0x 前缀后原样透传', () {
      final out = EvmSender.buildMsgData(
        calldata: approveCalldata,
        isAndroid: true,
      );
      expect(out, approveCalldata.substring(2));
      expect(out.startsWith('0x'), isFalse);
    });

    test('calldata 在两端产出一致（不再按平台分叉）', () {
      expect(
        EvmSender.buildMsgData(calldata: approveCalldata, isAndroid: true),
        EvmSender.buildMsgData(calldata: approveCalldata, isAndroid: false),
      );
    });

    test('已不带 0x 的 calldata 保持不变', () {
      final raw = approveCalldata.substring(2);
      expect(EvmSender.buildMsgData(calldata: raw, isAndroid: true), raw);
    });

    test('calldata 结果是合法 hex（可被原生解码）', () {
      final out = EvmSender.buildMsgData(
        calldata: approveCalldata,
        isAndroid: false,
      );
      expect(RegExp(r'^[0-9a-fA-F]*$').hasMatch(out), isTrue);
      expect(out.length.isEven, isTrue);
    });

    // 真机报告要求的边界断言：0x095ea7b3 必须解码为 09 5e a7 b3，
    // 而不是 ASCII 的 30 78 30 39...（Android 此前按 UTF-8 编码的产物）。
    test('approve selector 解码后是 09 5e a7 b3 而非 ASCII 字节', () {
      final out = EvmSender.buildMsgData(
        calldata: '0x095ea7b3',
        isAndroid: true,
      );
      expect(out, '095ea7b3');
      final decoded = <int>[
        for (var i = 0; i < out.length; i += 2)
          int.parse(out.substring(i, i + 2), radix: 16),
      ];
      expect(decoded, [0x09, 0x5e, 0xa7, 0xb3]);
      // 旧行为（把 hex 文本当字符串编码）会得到 ASCII "0x095ea7b3"。
      expect(decoded, isNot(utf8.encode('0x095ea7b3')));
    });

    test('memo 按 UTF-8 转 hex，两端一致', () {
      const memo = 'hello';
      final android = EvmSender.buildMsgData(message: memo, isAndroid: true);
      final ios = EvmSender.buildMsgData(message: memo, isAndroid: false);
      expect(android, bytesToHex(utf8.encode(memo)));
      expect(android, ios);
    });

    test('中文 memo 先 UTF-8 再 hex，解码可还原原文', () {
      const memo = '转账备注';
      final out = EvmSender.buildMsgData(message: memo, isAndroid: true);
      expect(out, bytesToHex(utf8.encode(memo)));
      // 必须是合法的偶数长度 hex —— codeUnits(UTF-16) 会让码点溢出单字节。
      expect(RegExp(r'^[0-9a-f]*$').hasMatch(out), isTrue);
      expect(out.length.isEven, isTrue);
      final decoded = <int>[
        for (var i = 0; i < out.length; i += 2)
          int.parse(out.substring(i, i + 2), radix: 16),
      ];
      expect(utf8.decode(decoded), memo);
    });

    test('calldata 优先于 memo', () {
      final out = EvmSender.buildMsgData(
        calldata: approveCalldata,
        message: 'ignored',
        isAndroid: true,
      );
      expect(out, approveCalldata.substring(2));
    });

    test('两者皆空时返回空串', () {
      expect(EvmSender.buildMsgData(isAndroid: true), '');
      expect(EvmSender.buildMsgData(isAndroid: false), '');
    });
  });
}
