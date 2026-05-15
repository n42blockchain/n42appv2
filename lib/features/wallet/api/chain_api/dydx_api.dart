import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// dYdX (DYDX) — 去中心化永续合约，denom: adydx (18位精度)
class DydxApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/dydxprotocol';
  static const _test = 'https://testnet.rest.cosmos.directory/dydx-testnet-4';

  DydxApi({bool isTest = false}) : super(isTest ? _test : _main, 'adydx');
}
