import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// THORChain (RUNE) — 跨链 DEX，denom: rune (1 RUNE = 1e8 rune)
class RuneApi extends CosmosChainApi {
  static const _main = 'https://thornode.ninerealms.com';
  static const _test = 'https://testnet.thornode.thorchain.info';

  RuneApi({bool isTest = false}) : super(isTest ? _test : _main, 'rune');
}
