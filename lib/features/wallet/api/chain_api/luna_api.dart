import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Terra v2 (LUNA) — 稳定币链，denom: uluna
class LunaApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/terra2';
  static const _test = 'https://testnet.rest.cosmos.directory/pisco-1';

  LunaApi({bool isTest = false}) : super(isTest ? _test : _main, 'uluna');
}
