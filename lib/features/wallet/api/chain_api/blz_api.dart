import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Bluzelle (BLZ) — 去中心化数据库链，denom: ubnt
class BlzApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/bluzelle';

  BlzApi() : super(_main, 'ubnt');
}
