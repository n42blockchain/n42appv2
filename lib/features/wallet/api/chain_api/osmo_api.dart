import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Osmosis (OSMO) — Cosmos DEX，denom: uosmo
class OsmoApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/osmosis';
  static const _test = 'https://testnet.rest.cosmos.directory/osmotest5';

  OsmoApi({bool isTest = false}) : super(isTest ? _test : _main, 'uosmo');
}
