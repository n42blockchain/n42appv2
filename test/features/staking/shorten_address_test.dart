// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// shortenStakingAddress 工具函数测试。
//
// 覆盖 lib/features/staking/models/staking_models.dart 296-304 行：
// 截断规则为 length > prefixLen + suffixLen + 3 时才截断，
// 输出 "前缀...后缀"（省略号固定 3 个点）。

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';

void main() {
  group('shortenStakingAddress 默认参数（prefixLen=8, suffixLen=6）', () {
    test('长地址按 8...6 格式截断', () {
      const addr = '0x1234567890abcdef1234567890abcdef12345678';
      final out = shortenStakingAddress(addr);
      expect(out, '0x123456...345678');
      // 截断后总长 = 8 + 3 + 6 = 17
      expect(out.length, 17);
    });

    test('长度恰好等于阈值（17）时不截断', () {
      // minLen = 8 + 6 + 3 = 17：length <= 17 原样返回
      final addr = 'a' * 17;
      expect(shortenStakingAddress(addr), addr);
    });

    test('长度为阈值 +1（18）时开始截断', () {
      final addr = 'abcdefghijklmnopqr'; // 18 字符
      final out = shortenStakingAddress(addr);
      expect(out, 'abcdefgh...mnopqr');
      expect(out.length, 17);
    });

    test('cosmosvaloper 长地址截断保留前后缀', () {
      const addr = 'cosmosvaloper1sjllsnramtg3ewxqwwrwjxfgc4n4ef9u2lcnj0';
      final out = shortenStakingAddress(addr);
      expect(out, 'cosmosva...2lcnj0');
      expect(out.startsWith('cosmosva'), isTrue);
      expect(out.endsWith('2lcnj0'), isTrue);
    });

    test('空串原样返回，不抛 RangeError', () {
      expect(shortenStakingAddress(''), '');
    });

    test('短串原样返回，不抛 RangeError', () {
      expect(shortenStakingAddress('abc'), 'abc');
      expect(shortenStakingAddress('a'), 'a');
    });
  });

  group('shortenStakingAddress 自定义 prefixLen/suffixLen', () {
    test('prefixLen=6, suffixLen=4（SOL 验证者列表用法）', () {
      const addr = 'Vote111111111111111111111111111111111111111';
      final out = shortenStakingAddress(addr, prefixLen: 6, suffixLen: 4);
      expect(out, 'Vote11...1111');
      expect(out.length, 6 + 3 + 4);
    });

    test('自定义参数下阈值边界同样成立', () {
      // minLen = 2 + 2 + 3 = 7
      expect(
        shortenStakingAddress('1234567', prefixLen: 2, suffixLen: 2),
        '1234567', // 恰好 7 位不截断
      );
      expect(
        shortenStakingAddress('12345678', prefixLen: 2, suffixLen: 2),
        '12...78', // 8 位开始截断
      );
    });

    test('prefixLen+suffixLen 大于地址长度时不截断不抛错', () {
      expect(
        shortenStakingAddress('short', prefixLen: 10, suffixLen: 10),
        'short',
      );
    });
  });
}
