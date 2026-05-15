import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Stargaze (STARS) — Cosmos NFT 链，denom: ustars
class StarsApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/stargaze';
  static const _test = 'https://testnet.rest.cosmos.directory/elgafar-1';

  StarsApi({bool isTest = false}) : super(isTest ? _test : _main, 'ustars');
}
