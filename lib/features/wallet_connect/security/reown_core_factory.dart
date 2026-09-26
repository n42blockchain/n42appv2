import 'package:n42_wallet/features/wallet_connect/security/reown_keychain.dart';
import 'package:n42_wallet/features/wallet_connect/security/reown_secure_store.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

/// Compose the official core with host secure storage before any SDK init.
ReownCore createN42ReownCore({required String projectId}) {
  return configureN42ReownCore(ReownCore(projectId: projectId));
}

ReownCore configureN42ReownCore(ReownCore core) {
  final secureStore = N42ReownSecureStore();
  core.secureStorage = secureStore;
  core.crypto.keyChain = N42ReownKeychain(storage: secureStore);
  return core;
}
