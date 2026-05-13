import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Crescent (CRE) — Cosmos DeFi 链，denom: ucre
class CreApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/crescent';

  CreApi() : super(_main, 'ucre');
}
