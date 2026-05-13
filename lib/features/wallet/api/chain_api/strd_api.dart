import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Stride (STRD) — Cosmos 流动性质押，denom: ustrd
class StrdApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/stride';
  static const _test = 'https://testnet.rest.cosmos.directory/stride-internal-1';

  StrdApi({bool isTest = false}) : super(isTest ? _test : _main, 'ustrd');
}
