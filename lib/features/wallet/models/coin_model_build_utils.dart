import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

typedef CoinModelDerivation = ({String path, String addressType});

CoinModelDerivation resolveCoinModelDerivation({
  required Map<String, dynamic> coin,
  required String addrType,
  required int pathIndex,
}) {
  final rawPathMap = coin['path'];
  if (rawPathMap is! Map || rawPathMap[addrType] is! String) {
    throw FormatException('Missing derivation path for addrType=$addrType');
  }

  return (
    path: getPathWithIndex(rawPathMap[addrType] as String, pathIndex),
    addressType: addrType,
  );
}
