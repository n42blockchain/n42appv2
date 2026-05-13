import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Fetch.AI (FET) — AI + Cosmos 链，denom: afet (18位精度)
class FetApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/fetchhub';
  static const _test = 'https://rest-fetchai-testnet.keplr.app';

  FetApi({bool isTest = false}) : super(isTest ? _test : _main, 'afet');
}
