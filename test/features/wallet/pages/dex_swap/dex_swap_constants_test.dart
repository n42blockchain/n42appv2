// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_constants.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';

void main() {
  test('every selectable DEX chain maps to a configured EVM network', () {
    for (final chain in kDexSupportedChains) {
      final coinType = chain['coinType']!;
      final config = allChainUrlMap[coinType] as Map<String, dynamic>?;
      expect(config, isNotNull, reason: '$coinType must be registered');
      expect(
        config!['baseInfo']['blockchainType'],
        'Ethereum',
        reason: '$coinType needs an EVM calldata execution path',
      );
    }
  });

  test('backend aliases map to wallet coin types', () {
    expect(dexCoinTypeForChain('BSC'), 'BNB');
    expect(dexCoinTypeForChain('POLYGON'), 'MATIC');
    expect(dexCoinTypeForChain('BASE'), 'BASE');
  });
}
