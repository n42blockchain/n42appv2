import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';

/// Sei Cosmos 侧 (SEI2) — 原生 Cosmos SDK 层，denom: usei
/// 区别于 CoinType.SEI（EVM，chainId 1329，0x 地址），
/// 此类对应 CoinType.SEI2（Cosmos，pacific-1，sei1… 地址，path m/44'/118'/0'/0/0）
class SeiCosmosApi extends CosmosChainApi {
  static const _main = 'https://rest.cosmos.directory/sei';
  static const _test = 'https://rest.cosmos.directory/seiTestnet2';

  SeiCosmosApi({bool isTest = false}) : super(isTest ? _test : _main, 'usei');
}
