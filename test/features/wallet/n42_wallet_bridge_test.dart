// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/n42_wallet_bridge.dart';

void main() {
  group('resolveWalletBridgeTokenDecimals', () {
    test('reads the canonical decimals field', () {
      expect(resolveWalletBridgeTokenDecimals({'decimals': 6}), 6);
    });

    test('accepts integer-valued numeric values', () {
      expect(resolveWalletBridgeTokenDecimals({'decimals': 9.0}), 9);
    });

    test('supports legacy singular records', () {
      expect(resolveWalletBridgeTokenDecimals({'decimal': 8}), 8);
    });

    test('prefers the canonical field over the legacy field', () {
      expect(
        resolveWalletBridgeTokenDecimals({'decimals': 6, 'decimal': 18}),
        6,
      );
    });

    test('parses string decimals like CoinConfigView does', () {
      // 拒绝字符串会让存成 "8" 的代币按 18 位精度换算，金额差 10^10 倍。
      expect(resolveWalletBridgeTokenDecimals({'decimals': '6'}), 6);
      expect(resolveWalletBridgeTokenDecimals({'decimal': '8'}), 8);
    });

    test('uses the requested fallback for invalid values', () {
      expect(resolveWalletBridgeTokenDecimals({'decimals': -1}), 18);
      expect(
        resolveWalletBridgeTokenDecimals({'decimals': 'abc'}, fallback: 12),
        12,
      );
      expect(resolveWalletBridgeTokenDecimals({'decimals': 6.5}), 18);
      expect(resolveWalletBridgeTokenDecimals({'decimals': '300'}), 18);
    });
  });

  group('token gate ABI helpers', () {
    test('encodes ERC-1155 balanceOf(address,uint256)', () {
      final data = buildErc1155BalanceCalldata(
        '0x1111111111111111111111111111111111111111',
        BigInt.from(42),
      );
      expect(data, startsWith('0x00fdd58e'));
      expect(data.length, 2 + 8 + 64 + 64);
      expect(data.substring(data.length - 2), '2a');
    });

    test('encodes ERC-721 tokenURI(uint256)', () {
      final data = buildErc721TokenUriCalldata(BigInt.from(9));
      expect(data, startsWith('0xc87b56dd'));
      expect(data.length, 2 + 8 + 64);
      expect(data.substring(data.length - 1), '9');
    });

    test('decodes a dynamic ABI string', () {
      final encoded =
          '0x'
          '${'20'.padLeft(64, '0')}'
          '${'4'.padLeft(64, '0')}'
          '${'74657374'.padRight(64, '0')}';
      expect(decodeAbiString(encoded), 'test');
      expect(decodeAbiString('0x01'), isNull);
    });
  });
}
