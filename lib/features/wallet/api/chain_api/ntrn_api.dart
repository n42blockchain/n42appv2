import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Neutron (NTRN) — Cosmos DeFi Hub，denom: untrn
class NtrnApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/neutron';
  static const _test = 'https://testnet.rest.cosmos.directory/pion-1';

  NtrnApi({bool isTest = false}) : super(isTest ? _test : _main, 'untrn');
}
