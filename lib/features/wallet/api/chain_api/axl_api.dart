import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Axelar (AXL) — 跨链通信协议，denom: uaxl
class AxlApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/axelar';
  static const _test =
      'https://testnet.rest.cosmos.directory/axelar-testnet-lisbon-3';

  AxlApi({bool isTest = false}) : super(isTest ? _test : _main, 'uaxl');
}
