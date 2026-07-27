// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

const _chains = <({String coin, String prefix, String path})>[
  (coin: 'ATOM', prefix: 'cosmos', path: "m/44'/118'/0'/0/0"),
  (coin: 'INJ', prefix: 'inj', path: "m/44'/60'/0'/0/0"),
  (coin: 'TIA', prefix: 'celestia', path: "m/44'/118'/0'/0/0"),
  (coin: 'DYDX', prefix: 'dydx', path: "m/44'/118'/0'/0/0"),
  (coin: 'OSMO', prefix: 'osmo', path: "m/44'/118'/0'/0/0"),
  (coin: 'AKT', prefix: 'akash', path: "m/44'/118'/0'/0/0"),
  (coin: 'NTRN', prefix: 'neutron', path: "m/44'/118'/0'/0/0"),
  (coin: 'SCRT', prefix: 'secret', path: "m/44'/529'/0'/0/0"),
  (coin: 'STRD', prefix: 'stride', path: "m/44'/118'/0'/0/0"),
  (coin: 'JUNO', prefix: 'juno', path: "m/44'/118'/0'/0/0"),
  (coin: 'KUJI', prefix: 'kujira', path: "m/44'/118'/0'/0/0"),
  (coin: 'XPRT', prefix: 'persistence', path: "m/44'/118'/0'/0/0"),
  (coin: 'RUNE', prefix: 'thor', path: "m/44'/931'/0'/0/0"),
  (coin: 'KAVA2', prefix: 'kava', path: "m/44'/459'/0'/0/0"),
  (coin: 'SEI2', prefix: 'sei', path: "m/44'/118'/0'/0/0"),
  (coin: 'CRE', prefix: 'cre', path: "m/44'/118'/0'/0/0"),
  (coin: 'SOMM', prefix: 'somm', path: "m/44'/118'/0'/0/0"),
  (coin: 'MARS', prefix: 'mars', path: "m/44'/118'/0'/0/0"),
  (coin: 'CMDX', prefix: 'comdex', path: "m/44'/118'/0'/0/0"),
];

const _expectedAddresses = <String, String>{
  'ATOM': 'cosmos19rl4cm2hmr8afy4kldpxz3fka4jguq0auqdal4',
  'INJ': 'inj1npvwllfr9dqr8erajqqr6s0vxnk2ak55re90dz',
  'TIA': 'celestia19rl4cm2hmr8afy4kldpxz3fka4jguq0ad2ud9c',
  'DYDX': 'dydx19rl4cm2hmr8afy4kldpxz3fka4jguq0a4erelz',
  'OSMO': 'osmo19rl4cm2hmr8afy4kldpxz3fka4jguq0a5m7df8',
  'AKT': 'akash19rl4cm2hmr8afy4kldpxz3fka4jguq0a3mq6x0',
  'NTRN': 'neutron19rl4cm2hmr8afy4kldpxz3fka4jguq0aclyl9j',
  'SCRT': 'secret1gkle2qetd47g4qlruxu8kx4m97875t66qsgr0p',
  'STRD': 'stride19rl4cm2hmr8afy4kldpxz3fka4jguq0altdpte',
  'JUNO': 'juno19rl4cm2hmr8afy4kldpxz3fka4jguq0a2jwxcf',
  'KUJI': 'kujira19rl4cm2hmr8afy4kldpxz3fka4jguq0adg09jl',
  'XPRT': 'persistence19rl4cm2hmr8afy4kldpxz3fka4jguq0ajvtw33',
  'RUNE': 'thor1gm00vwsfcp48enm4uv9e5dhm37jtd0ye27wrx0',
  'KAVA2': 'kava1fzgm3840v4xwme059mfnx9rc5qgzl0enq7qgac',
  'SEI2': 'sei19rl4cm2hmr8afy4kldpxz3fka4jguq0a3vute5',
  'CRE': 'cre19rl4cm2hmr8afy4kldpxz3fka4jguq0acg7c2c',
  'SOMM': 'somm19rl4cm2hmr8afy4kldpxz3fka4jguq0asuz3wl',
  'MARS': 'mars19rl4cm2hmr8afy4kldpxz3fka4jguq0apa5y2w',
  'CMDX': 'comdex19rl4cm2hmr8afy4kldpxz3fka4jguq0am00lxz',
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('T27 derives all Cosmos-family addresses', (tester) async {
    final trustdart = Trustdart();
    final addresses = <String, String>{};

    for (final chain in _chains) {
      final result = await trustdart.generateAddress(
        chain.coin,
        chain.path,
        'legacy',
        mnemonic: _mnemonic,
      );
      final address = result['legacy'] as String? ?? '';

      expect(address, startsWith('${chain.prefix}1'), reason: chain.coin);
      expect(address, isNot(startsWith('0x')), reason: chain.coin);
      expect(address, _expectedAddresses[chain.coin], reason: chain.coin);
      addresses[chain.coin] = address;
    }

    expect(addresses, hasLength(19));

    for (final entry in addresses.entries) {
      // Printed output is retained as cross-platform comparison evidence.
      // The mnemonic is the public BIP-39 test vector above, never user data.
      // ignore: avoid_print
      print('T27_ADDRESS ${entry.key}=${entry.value}');
    }
  });
}
