import 'package:n42_wallet/features/wallet/utils/browser/browser_address.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// Resolve the account's own chain, independently of the selected EOA network.
String aaAccountExplorer(int chainId, String address) {
  for (final entry in chainUrlMap.entries) {
    final base = (entry.value as Map)['baseInfo'] as Map?;
    if (base == null || base['blockchainType'] != 'Ethereum') continue;
    for (final isTest in [false, true]) {
      final id = base[isTest ? 'chainId_test' : 'chainId'];
      if (id?.toString() == chainId.toString()) {
        return getBrowserAddress(entry.key, address, isTest: isTest);
      }
    }
  }
  return '';
}
