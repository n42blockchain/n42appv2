import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Juno (JUNO) — CosmWasm 智能合约链，denom: ujuno
class JunoApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/juno';
  static const _test = 'https://testnet.rest.cosmos.directory/uni-6';

  JunoApi({bool isTest = false}) : super(isTest ? _test : _main, 'ujuno');
}
