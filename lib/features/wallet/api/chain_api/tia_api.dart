import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Celestia (TIA) — 模块化区块链，denom: utia
class TiaApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/celestia';
  static const _test = 'https://testnet.rest.cosmos.directory/mocha-4';

  TiaApi({bool isTest = false}) : super(isTest ? _test : _main, 'utia');
}
