import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';

/// Native denoms for every Cosmos chain exposed by [allChainUrlMap].
///
/// Keep this registry exhaustive. Returning no API is safer than silently
/// querying Cosmos Hub with `uatom` for an unknown Cosmos-family chain.
const Map<String, String> cosmosNativeDenomByCoinType = {
  'ATOM': 'uatom',
  'INJ': 'inj',
  'TIA': 'utia',
  'DYDX': 'adydx',
  'OSMO': 'uosmo',
  'AKT': 'uakt',
  'NTRN': 'untrn',
  'SCRT': 'uscrt',
  'STRD': 'ustrd',
  'JUNO': 'ujuno',
  'KUJI': 'ukuji',
  'XPRT': 'uxprt',
  'RUNE': 'rune',
  'KAVA2': 'ukava',
  'SEI2': 'usei',
  'CRE': 'ucre',
  'SOMM': 'usomm',
  'MARS': 'umars',
  'CMDX': 'ucmdx',
};

/// Builds the chain-specific REST client used for Cosmos balance reads.
///
/// The REST URL comes from the canonical all-chain registry, while the native
/// denom comes from [cosmosNativeDenomByCoinType]. Unsupported or incomplete
/// entries return null instead of falling back to ATOM.
CosmosChainApi? resolveCosmosBalanceApi(
  String coinType, {
  bool isTest = false,
}) {
  final normalizedCoinType = coinType.trim().toUpperCase();
  final denom = cosmosNativeDenomByCoinType[normalizedCoinType];
  final config = allChainUrlMap[normalizedCoinType];
  final baseInfo = config is Map<String, dynamic>
      ? resolveChainBaseInfo(config)
      : null;
  if (denom == null || baseInfo == null) return null;

  final view = CoinConfigView(baseInfo);
  if (view.blockchainType != 'Cosmos') return null;
  final service = isTest ? view.serviceTest : view.service;
  if (service.trim().isEmpty) return null;

  return CosmosChainApi(service, denom);
}
