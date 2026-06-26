import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Canto Native Cosmos (CANTO) — EVM + Cosmos 双协议，denom: acanto (18位精度)
class CantoCosmosApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/canto';
  static const _test = 'https://testnet.rest.cosmos.directory/canto_7700-1';

  CantoCosmosApi({bool isTest = false})
    : super(isTest ? _test : _main, 'acanto');
}
