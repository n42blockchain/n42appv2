// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Smoke tests for SenderFactory dispatch. The factory looks up each coin
// in the global `allChainUrlMap` registry and returns the ChainSender
// subclass keyed by `baseInfo.blockchainType`. This test pins:
//   - Each major blockchainType maps to the right Sender subclass.
//   - The factory caches per-coinType (same instance on repeated reads).
//   - Unknown coinTypes return an _UnsupportedSender that fails-soft.
//   - Coin lookup is case-insensitive on the requested coinType.

import 'package:flutter_test/flutter_test.dart';

import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';

import 'package:n42_wallet/features/wallet/api/sender/ada_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/algo_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/apt_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/btc_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/signing_context_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/cosmos_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/dot_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/egld_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/fil_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/near_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sol_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sui_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/ton_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/trx_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/vet_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/xlm_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/xrp_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/xtz_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/zil_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/strk_sender.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

void main() {
  final factory = SenderFactory.instance;

  ChainSender implementation(String coinType) {
    final sender = factory.getSender(coinType);
    return sender is WalletSigningContextSender ? sender.delegate : sender;
  }

  group('SenderFactory dispatch by blockchainType', () {
    test('EVM family → EvmSender', () {
      // ETH, BNB, MATIC, ARB, OP, BASE, AVAX etc. all share blockchainType "Ethereum".
      expect(implementation('ETH'), isA<EvmSender>());
      expect(implementation('BNB'), isA<EvmSender>());
      expect(implementation('MATIC'), isA<EvmSender>());
      expect(implementation('N'), isA<EvmSender>());
    });

    test('Bitcoin family → BtcSender', () {
      expect(implementation('BTC'), isA<BtcSender>());
    });

    test('Cosmos family → CosmosSender', () {
      // ATOM is the canonical Cosmos chain. AKT/OSMO/etc. share blockchainType.
      expect(implementation('ATOM'), isA<CosmosSender>());
    });

    test('Solana → SolSender', () {
      expect(implementation('SOL'), isA<SolSender>());
    });

    test('TRON → TrxSender', () {
      expect(implementation('TRX'), isA<TrxSender>());
    });

    test('Polkadot → DotSender', () {
      expect(implementation('DOT'), isA<DotSender>());
    });

    test('Aptos → AptSender', () {
      expect(implementation('APT'), isA<AptSender>());
    });

    test('TON → TonSender', () {
      expect(implementation('TON'), isA<TonSender>());
    });

    test('NEAR → NearSender', () {
      expect(implementation('NEAR'), isA<NearSender>());
    });

    test('Sui → SuiSender', () {
      expect(implementation('SUI'), isA<SuiSender>());
    });

    test('Ripple → XrpSender', () {
      expect(implementation('XRP'), isA<XrpSender>());
    });

    test('Algorand → AlgoSender', () {
      expect(implementation('ALGO'), isA<AlgoSender>());
    });

    test('Tezos → XtzSender', () {
      expect(implementation('XTZ'), isA<XtzSender>());
    });

    test('Zilliqa → ZilSender', () {
      expect(implementation('ZIL'), isA<ZilSender>());
    });

    test('Filecoin → FilSender', () {
      expect(implementation('FIL'), isA<FilSender>());
    });

    test('Stellar → XlmSender', () {
      expect(implementation('XLM'), isA<XlmSender>());
    });

    test('Cardano → AdaSender', () {
      expect(implementation('ADA'), isA<AdaSender>());
    });

    test('VeChain → VetSender', () {
      expect(implementation('VET'), isA<VetSender>());
    });

    test('MultiversX → EgldSender', () {
      expect(implementation('EGLD'), isA<EgldSender>());
    });

    test('HBAR → EvmSender (registry-defined behaviour)', () {
      // HBAR is registered with blockchainType "Ethereum" in
      // chain_url_configs_part2 (HBAR is EVM-compatible), so it
      // dispatches to EvmSender, NOT HbarSender. The sender_factory's
      // 'Hedera' => HbarSender() branch is currently dead code; this
      // test pins the actual production behaviour.
      expect(implementation('HBAR'), isA<EvmSender>());
    });

    test('Starknet → StrkSender', () {
      expect(implementation('STRK'), isA<StrkSender>());
    });
  });

  group('SenderFactory contract', () {
    test('every default wallet network has a concrete sender', () {
      final unsupported = chainUrlMap.keys
          .where((coinType) => !factory.supportsTransfers(coinType))
          .toList();

      expect(unsupported, isEmpty);
    });

    test('runtime custom EVM config dispatches to EvmSender', () {
      final sender = factory.getSender(
        'MYCHAIN',
        chainConfig: {
          'blockchainType': 'Ethereum',
          'coinType': 'MYCHAIN',
          'chainId': 987654,
          'service': 'https://rpc.example.com',
        },
      );

      expect(
        sender is WalletSigningContextSender ? sender.delegate : sender,
        isA<EvmSender>(),
      );
    });

    test('coinType lookup is case-insensitive', () {
      final upper = factory.getSender('ETH');
      final lower = factory.getSender('eth');
      final mixed = factory.getSender('Eth');
      expect(identical(upper, lower), isTrue);
      expect(identical(upper, mixed), isTrue);
    });

    test('caches sender instance per coinType', () {
      final first = factory.getSender('BTC');
      final second = factory.getSender('BTC');
      expect(identical(first, second), isTrue);
    });

    test('unknown coinType returns a ChainSender that fails-soft', () async {
      // The factory must never throw on lookup — every coinType should
      // resolve to *some* ChainSender (even if it just refuses to send).
      final sender = factory.getSender('__DEFINITELY_NOT_A_REAL_COIN__');
      expect(sender, isA<ChainSender>());

      final result = await sender.send(
        const SendParams(
          coinType: '__DEFINITELY_NOT_A_REAL_COIN__',
          fromAddress: '',
          toAddress: '',
          amount: 0,
          decimals: 0,
          path: '',
        ),
      );
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });

    test('SenderFactory.instance is a singleton', () {
      expect(identical(SenderFactory.instance, SenderFactory.instance), isTrue);
    });
  });
}
