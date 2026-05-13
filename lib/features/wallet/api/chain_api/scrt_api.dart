import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Secret Network (SCRT) — 隐私合约链，denom: uscrt
class ScrtApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/secretnetwork';
  static const _test = 'https://testnet.rest.cosmos.directory/pulsar-3';

  ScrtApi({bool isTest = false}) : super(isTest ? _test : _main, 'uscrt');
}
