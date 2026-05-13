import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Coreum (CORE) — 企业级 Cosmos 链，denom: ucore
class CoreumApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/coreum';
  static const _test = 'https://full-node.testnet-1.coreum.dev:1317';

  CoreumApi({bool isTest = false}) : super(isTest ? _test : _main, 'ucore');
}
