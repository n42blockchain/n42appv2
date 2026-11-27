import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

const walletBackupPhraseUnavailableMessage =
    'No recovery phrase is stored for this wallet.';

final _whitespaceRun = RegExp(r'\s+');

List<String> parseBackupMnemonicWords(String? mnemonic) {
  if (mnemonic == null) return const <String>[];
  return mnemonic
      .trim()
      .split(_whitespaceRun)
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
}

bool walletHasBackupableMnemonic(WalletInfo walletInfo) {
  return parseBackupMnemonicWords(walletInfo.mnemonic).isNotEmpty;
}
