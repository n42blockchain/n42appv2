import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Noble (USDC) — Cosmos 原生 USDC 发行链，denom: uusdc
class NobleApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/noble';

  NobleApi() : super(_main, 'uusdc');
}
