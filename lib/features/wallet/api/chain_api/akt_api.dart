import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Akash (AKT) — 去中心化云计算，denom: uakt
class AktApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/akash';
  static const _test = 'https://testnet.rest.cosmos.directory/sandbox-01';

  AktApi({bool isTest = false}) : super(isTest ? _test : _main, 'uakt');
}
