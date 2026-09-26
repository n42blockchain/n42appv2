import 'package:n42_wallet/features/wallet_connect/security/reown_secure_store.dart';

/// Remove only the pairing metadata created by an interrupted key write.
///
/// A fresh secure-storage read distinguishes a failed write from a write that
/// reached durable storage but reported an error. Existing pairings and
/// uncertain reads are always preserved.
Future<void> reconcileFailedNewPairing({
  required String topic,
  required bool existedBefore,
  required Future<void> Function(String topic) deletePairing,
  N42ReownSecureStore? durableStore,
}) async {
  if (existedBefore) return;
  final store = durableStore ?? N42ReownSecureStore();
  await store.init();
  final durableKeys = store.get('0.3//keychain');
  if (durableKeys?.containsKey(topic) ?? false) return;
  await deletePairing(topic);
}
