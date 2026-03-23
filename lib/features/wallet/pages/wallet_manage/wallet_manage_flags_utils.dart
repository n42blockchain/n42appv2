import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

bool walletHasUserPassword(WalletInfo walletInfo) {
  return !walletInfo.watchOnly && (walletInfo.password?.isNotEmpty ?? false);
}

bool walletCanBackupFromManage(WalletInfo walletInfo) {
  return !walletInfo.watchOnly && !walletHasUserPassword(walletInfo);
}
