import 'package:flutter_mining/mobileverify.dart';

import 'package:n42_wallet/core/storage/secure_preferences.dart';

/// Where the v3 device key lives. Kept apart from the v2 validator key:
/// the two engines are separate identities.
const mobileVerifyKeyStorageKey = 'mining_v3_bls_priv';

/// The device's v3 secret key hex, created and stored on first use.
/// Returns the key and whether it was just created.
Future<(String, bool)> loadOrCreateDeviceKey(
  MobileVerifyApi api,
  SecureStore store,
) async {
  final stored = await store.read(key: mobileVerifyKeyStorageKey);
  if (stored != null && stored.isNotEmpty) return (stored, false);
  final created = await api.generateKey();
  await store.write(key: mobileVerifyKeyStorageKey, value: created);
  return (created, true);
}
