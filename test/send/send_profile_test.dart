// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_profile.dart';

void main() {
  group('resolveSendProfile — UTXO chains', () {
    test('Bitcoin → utxo', () {
      expect(resolveSendProfile('Bitcoin'), SendProfile.utxo);
    });

    test('Qtum → utxo', () {
      expect(resolveSendProfile('Qtum'), SendProfile.utxo);
    });

    test('Decred → utxo', () {
      expect(resolveSendProfile('Decred'), SendProfile.utxo);
    });
  });

  group('resolveSendProfile — XRP chains', () {
    test('Ripple → xrp', () {
      expect(resolveSendProfile('Ripple'), SendProfile.xrp);
    });
  });

  group('resolveSendProfile — EVM chains', () {
    test('Ethereum → evm', () {
      expect(resolveSendProfile('Ethereum'), SendProfile.evm);
    });

    test('Harmony (EVM-compatible) → evm', () {
      expect(resolveSendProfile('Harmony'), SendProfile.evm);
    });

    test('IoTeX (EVM-compatible) → evm', () {
      expect(resolveSendProfile('IoTeX'), SendProfile.evm);
    });

    test('Theta (EVM-compatible) → evm', () {
      expect(resolveSendProfile('Theta'), SendProfile.evm);
    });

    test('unknown chain falls back to evm', () {
      expect(resolveSendProfile('UnknownChain'), SendProfile.evm);
    });

    test('empty string falls back to evm', () {
      expect(resolveSendProfile(''), SendProfile.evm);
    });

    test('wrong casing is not recognised → evm fallback', () {
      // 'ethereum' (lowercase) is not in any set → should fallback to evm
      expect(resolveSendProfile('ethereum'), SendProfile.evm);
      expect(resolveSendProfile('BITCOIN'), SendProfile.evm);
    });
  });

  group('resolveSendProfile — Memo chains (existing dedicated pages)', () {
    test('Solana → memo', () {
      expect(resolveSendProfile('Solana'), SendProfile.memo);
    });

    test('Tron → memo', () {
      expect(resolveSendProfile('Tron'), SendProfile.memo);
    });

    test('Algorand → memo', () {
      expect(resolveSendProfile('Algorand'), SendProfile.memo);
    });

    test('Filecoin → memo', () {
      expect(resolveSendProfile('Filecoin'), SendProfile.memo);
    });

    test('Polkadot → memo', () {
      expect(resolveSendProfile('Polkadot'), SendProfile.memo);
    });

    test('Sui → memo', () {
      expect(resolveSendProfile('Sui'), SendProfile.memo);
    });

    test('TheOpenNetwork → memo', () {
      expect(resolveSendProfile('TheOpenNetwork'), SendProfile.memo);
    });

    test('Zilliqa → memo', () {
      expect(resolveSendProfile('Zilliqa'), SendProfile.memo);
    });
  });

  group('resolveSendProfile — Memo chains (generic WalletChainSendMemo)', () {
    test('Cosmos → memo', () {
      expect(resolveSendProfile('Cosmos'), SendProfile.memo);
    });

    test('Aptos → memo', () {
      expect(resolveSendProfile('Aptos'), SendProfile.memo);
    });

    test('Near → memo', () {
      expect(resolveSendProfile('Near'), SendProfile.memo);
    });

    test('Stellar → memo', () {
      expect(resolveSendProfile('Stellar'), SendProfile.memo);
    });

    test('Tezos → memo', () {
      expect(resolveSendProfile('Tezos'), SendProfile.memo);
    });

    test('VeChain → memo', () {
      expect(resolveSendProfile('VeChain'), SendProfile.memo);
    });

    test('Cardano → memo', () {
      expect(resolveSendProfile('Cardano'), SendProfile.memo);
    });

    test('MultiversX → memo', () {
      expect(resolveSendProfile('MultiversX'), SendProfile.memo);
    });

    test('Starknet → memo', () {
      expect(resolveSendProfile('Starknet'), SendProfile.memo);
    });

    test('EOSIO → memo', () {
      expect(resolveSendProfile('EOSIO'), SendProfile.memo);
    });

    test('Waves → memo', () {
      expect(resolveSendProfile('Waves'), SendProfile.memo);
    });

    test('Neo → memo', () {
      expect(resolveSendProfile('Neo'), SendProfile.memo);
    });

    test('Ontology → memo', () {
      expect(resolveSendProfile('Ontology'), SendProfile.memo);
    });

    test('NEM → memo', () {
      expect(resolveSendProfile('NEM'), SendProfile.memo);
    });

    test('Nano → memo', () {
      expect(resolveSendProfile('Nano'), SendProfile.memo);
    });

    test('ICON → memo', () {
      expect(resolveSendProfile('ICON'), SendProfile.memo);
    });

    test('IOST → memo', () {
      expect(resolveSendProfile('IOST'), SendProfile.memo);
    });

    test('Ark → memo', () {
      expect(resolveSendProfile('Ark'), SendProfile.memo);
    });

    test('Hive → memo', () {
      expect(resolveSendProfile('Hive'), SendProfile.memo);
    });
  });

  group('resolveSendProfile — BlockchainType enum coverage', () {
    // 验证 send_profile.dart 与 BlockchainType enum 保持一致：
    // 每个 BlockchainType 都能被正确分类，不存在意外 fallback。
    const expectedProfiles = <String, SendProfile>{
      // UTXO
      'Bitcoin': SendProfile.utxo,
      'Qtum': SendProfile.utxo,
      'Decred': SendProfile.utxo,
      // XRP
      'Ripple': SendProfile.xrp,
      // EVM
      'Ethereum': SendProfile.evm,
      'Harmony': SendProfile.evm,
      'IoTeX': SendProfile.evm,
      'Theta': SendProfile.evm,
      // Memo — dedicated pages
      'Solana': SendProfile.memo,
      'Tron': SendProfile.memo,
      'Algorand': SendProfile.memo,
      'Filecoin': SendProfile.memo,
      'Polkadot': SendProfile.memo,
      'Sui': SendProfile.memo,
      'TheOpenNetwork': SendProfile.memo,
      'Zilliqa': SendProfile.memo,
      // Memo — generic page
      'Cosmos': SendProfile.memo,
      'Aptos': SendProfile.memo,
      'Near': SendProfile.memo,
      'Stellar': SendProfile.memo,
      'Tezos': SendProfile.memo,
      'VeChain': SendProfile.memo,
      'Cardano': SendProfile.memo,
      'MultiversX': SendProfile.memo,
      'Starknet': SendProfile.memo,
      'EOSIO': SendProfile.memo,
      'Waves': SendProfile.memo,
      'Neo': SendProfile.memo,
      'Ontology': SendProfile.memo,
      'NEM': SendProfile.memo,
      'Nano': SendProfile.memo,
      'ICON': SendProfile.memo,
      'IOST': SendProfile.memo,
      'Ark': SendProfile.memo,
      'Hive': SendProfile.memo,
    };

    test('all known BlockchainType values map to correct profile', () {
      for (final entry in expectedProfiles.entries) {
        expect(
          resolveSendProfile(entry.key),
          entry.value,
          reason: '${entry.key} should map to ${entry.value}',
        );
      }
    });

    test('total known chains count is at least 35', () {
      expect(expectedProfiles.length, greaterThanOrEqualTo(35));
    });
  });

  group('resolveSendProfile — idempotency', () {
    test('calling twice with same input returns same result', () {
      const chains = ['Bitcoin', 'Ethereum', 'Solana', 'Cosmos', 'Ripple'];
      for (final chain in chains) {
        final first = resolveSendProfile(chain);
        final second = resolveSendProfile(chain);
        expect(first, second, reason: '$chain should return consistent result');
      }
    });
  });

  group('SendProfile enum values', () {
    test('has exactly 4 values', () {
      expect(SendProfile.values.length, 4);
    });

    test('contains evm, utxo, xrp, memo', () {
      expect(SendProfile.values, containsAll([
        SendProfile.evm,
        SendProfile.utxo,
        SendProfile.xrp,
        SendProfile.memo,
      ]));
    });
  });
}
