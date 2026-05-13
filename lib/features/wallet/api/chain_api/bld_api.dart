import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Agoric (BLD) — JavaScript 智能合约链，denom: ubld
class BldApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/agoric';

  BldApi() : super(_main, 'ubld');
}
