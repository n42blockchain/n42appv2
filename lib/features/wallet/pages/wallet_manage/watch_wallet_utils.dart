import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

final RegExp _evmWatchWalletAddressPattern = RegExp(r'^0x[a-fA-F0-9]{40}$');

bool isValidWatchWalletAddress(String address) {
  return _evmWatchWalletAddressPattern.hasMatch(address.trim());
}

WalletInfo? findExistingWatchWallet(
  Iterable<WalletInfo> walletList,
  String address,
) {
  final normalizedAddress = address.trim().toLowerCase();
  if (normalizedAddress.isEmpty) return null;

  for (final wallet in walletList) {
    if (!wallet.watchOnly) continue;
    if (wallet.watchAddress.trim().toLowerCase() == normalizedAddress) {
      return wallet;
    }
  }
  return null;
}
