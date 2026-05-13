import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Injective (INJ) — Cosmos DeFi 链，denom: inj (18位精度)
class InjApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/injective';
  static const _test = 'https://testnet.rest.cosmos.directory/injective-888';

  InjApi({bool isTest = false}) : super(isTest ? _test : _main, 'inj');
}
