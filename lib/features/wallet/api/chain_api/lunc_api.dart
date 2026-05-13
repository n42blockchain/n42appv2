import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Terra Classic (LUNC) — 原始 Terra 链，denom: uluna
class LuncApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/terra';

  LuncApi() : super(_main, 'uluna');
}
