import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Quasar (QSR) — Cosmos 流动性聚合，denom: uqsr
class QsrApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/quasar';

  QsrApi() : super(_main, 'uqsr');
}
