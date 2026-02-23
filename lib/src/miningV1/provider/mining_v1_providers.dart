import 'package:flutter_riverpod/legacy.dart';
import 'package:n42_wallet/src/miningV1/provider/mining_provider.dart';

/// Global V1 mining provider instance (legacy ChangeNotifier)
late MiningProvider globalMiningV1;

/// Riverpod provider wrapping the global V1 MiningProvider instance
final miningV1BridgeProvider = ChangeNotifierProvider<MiningProvider>((ref) {
  globalMiningV1 = MiningProvider();
  return globalMiningV1;
});
