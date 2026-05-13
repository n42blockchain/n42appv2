import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Mars Protocol (MARS) — Cosmos 借贷协议，denom: umars
class MarsApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/mars';

  MarsApi() : super(_main, 'umars');
}
