import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// BandChain (BAND) — 去中心化预言机，denom: uband
class BandApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/bandchain';
  static const _test = 'https://laozi-testnet6.bandchain.org/api';

  BandApi({bool isTest = false}) : super(isTest ? _test : _main, 'uband');
}
