import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

Future<String?> verifyBatchTransferSigner({
  required Trustdart signer,
  required String coinType,
  required String path,
  required String addressType,
  required String fromAddress,
  required String mnemonic,
  required String privateKey,
  required bool isTest,
}) async {
  if (mnemonic.trim().isEmpty && privateKey.trim().isEmpty) {
    return 'Signing key is unavailable';
  }

  final Map derived;
  try {
    derived = await signer.generateAddress(
      coinType,
      path,
      addressType,
      mnemonic: privateKey.trim().isEmpty ? mnemonic : '',
      pk: privateKey,
      isTest: isTest,
    );
  } catch (_) {
    return 'Unable to verify signing address';
  }

  final signerAddress = derived[addressType]?.toString().trim() ?? '';
  if (signerAddress.isEmpty) return 'Unable to verify signing address';
  if (signerAddress.toLowerCase() != fromAddress.trim().toLowerCase()) {
    return 'Signing key does not match sender address';
  }
  return null;
}
