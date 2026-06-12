// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// 金额的十进制 → 链上最小单位（BigInt）精确转换。
//
// 资金路径禁止 `BigInt.from((value * 1e18).round())` 这类写法：
// double 只有 53 位尾数，value * 1e18 在 value > ~9 时就开始丢精度，
// 高 decimals 代币的尾数会被悄悄改写。本工具走十进制字符串移位，
// 完整保留 double.toString() 所表达的全部数位。

/// 把十进制字符串（支持 `-1.23`、`1e-7`、`2.5E+3` 形式）按 [decimals]
/// 移位转换为链上最小单位整数。超出 decimals 的多余小数位**向零截断**
/// （宁可少转一个最小单位，绝不多转）。
///
/// 非法输入抛 [FormatException]。
BigInt decimalStringToBigInt(String input, int decimals) {
  if (decimals < 0) {
    throw FormatException('negative decimals: $decimals');
  }
  var s = input.trim();
  if (s.isEmpty) throw FormatException('empty amount');

  var negative = false;
  if (s.startsWith('-')) {
    negative = true;
    s = s.substring(1);
  } else if (s.startsWith('+')) {
    s = s.substring(1);
  }

  var exponent = 0;
  final eIdx = s.indexOf(RegExp('[eE]'));
  if (eIdx >= 0) {
    exponent = int.parse(s.substring(eIdx + 1));
    s = s.substring(0, eIdx);
  }

  final dot = s.indexOf('.');
  final String digits;
  final int fracLen;
  if (dot >= 0) {
    digits = s.substring(0, dot) + s.substring(dot + 1);
    fracLen = s.length - dot - 1;
  } else {
    digits = s;
    fracLen = 0;
  }
  if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) {
    throw FormatException('invalid decimal amount: $input');
  }

  // 结果 = digits * 10^(decimals + exponent - fracLen)
  final shift = decimals + exponent - fracLen;
  var value = BigInt.parse(digits);
  if (shift >= 0) {
    value *= BigInt.from(10).pow(shift);
  } else {
    value ~/= BigInt.from(10).pow(-shift);
  }
  return negative ? -value : value;
}

/// [decimalStringToBigInt] 的 double 便捷入口。
/// `value.toString()` 是 double 的最短可逆十进制表示，转换中不再引入
/// 任何新的浮点误差（输入 double 本身的精度上限除外）。
BigInt doubleAmountToBigInt(double value, int decimals) {
  if (value.isNaN || value.isInfinite) {
    throw FormatException('non-finite amount: $value');
  }
  return decimalStringToBigInt(value.toString(), decimals);
}
