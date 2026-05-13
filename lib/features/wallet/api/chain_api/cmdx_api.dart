import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Comdex (CMDX) — DeFi 基础设施链，denom: ucmdx
class CmdxApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/comdex';
  static const _test = 'https://testnet.rest.cosmos.directory/comdex-test2';

  CmdxApi({bool isTest = false}) : super(isTest ? _test : _main, 'ucmdx');
}
