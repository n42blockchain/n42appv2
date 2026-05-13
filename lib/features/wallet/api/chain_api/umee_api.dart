import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Umee (UMEE) — 跨链借贷协议，denom: uumee
class UmeeApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/umee';

  UmeeApi() : super(_main, 'uumee');
}
