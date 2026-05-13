import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Kujira (KUJI) — DeFi 链，denom: ukuji
class KujiApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/kujira';
  static const _test = 'https://testnet.rest.cosmos.directory/harpoon-4';

  KujiApi({bool isTest = false}) : super(isTest ? _test : _main, 'ukuji');
}
