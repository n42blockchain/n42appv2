import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

Map<String, dynamic>? faceBindingChainConfig(WalletInfo walletInfo) {
  if (walletInfo.watchOnly) return null;

  final coinInfo = walletInfo.coinInfo;
  if (coinInfo == null) return null;

  final rawChainConfig = coinInfo[CoinType.N.name];
  if (rawChainConfig is! Map) return null;

  final chainConfig = Map<String, dynamic>.from(rawChainConfig);
  final baseInfo = chainConfig['baseInfo'];
  if (baseInfo is! Map) return null;

  final baseInfoMap = Map<String, dynamic>.from(baseInfo);
  final pathMap = baseInfoMap['path'];
  final coinType = baseInfoMap['coinType']?.toString();
  if (pathMap is! Map || pathMap['legacy'] is! String || coinType == null) {
    return null;
  }

  return chainConfig;
}

bool walletSupportsFaceBinding(WalletInfo walletInfo) {
  return faceBindingChainConfig(walletInfo) != null;
}
