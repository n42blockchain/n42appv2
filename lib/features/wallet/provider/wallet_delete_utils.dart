import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

Map<String, dynamic>? walletDeletionMiningChainConfig(WalletInfo wallet) {
  if (wallet.watchOnly) return null;

  final coinInfo = wallet.coinInfo;
  if (coinInfo == null) return null;

  final rawChainConfig = coinInfo[CoinType.N.name];
  if (rawChainConfig is! Map) return null;

  final chainConfig = Map<String, dynamic>.from(rawChainConfig);
  final baseInfo = chainConfig['baseInfo'];
  final addrType = chainConfig['addrType'];
  if (baseInfo is! Map || addrType is! String || addrType.isEmpty) {
    return null;
  }

  final baseInfoMap = Map<String, dynamic>.from(baseInfo);
  final pathMap = baseInfoMap['path'];
  if (pathMap is! Map || pathMap[addrType] == null) {
    return null;
  }

  return chainConfig;
}

bool walletRequiresMiningDeletionCheck(WalletInfo wallet) {
  return walletDeletionMiningChainConfig(wallet) != null;
}
