import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Sommelier (SOMM) — 链上策略 DeFi，denom: usomm
class SommApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/sommelier';

  SommApi() : super(_main, 'usomm');
}
