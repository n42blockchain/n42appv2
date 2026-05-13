import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Persistence (XPRT) — 流动性质押 Hub，denom: uxprt
class XprtApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/persistence';
  static const _test = 'https://testnet.rest.cosmos.directory/test-core-2';

  XprtApi({bool isTest = false}) : super(isTest ? _test : _main, 'uxprt');
}
