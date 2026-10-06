import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_signer_guard.dart';

class _Signer extends Trustdart {
  _Signer(this.address);

  final String address;
  int addressDerivations = 0;

  @override
  Future<Map> generateAddress(
    String coin,
    String path,
    String addressType, {
    String mnemonic = '',
    String passphrase = '',
    String pk = '',
    bool isImport = false,
    bool isTest = false,
  }) async {
    addressDerivations++;
    return {addressType: address};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('accepts the signing key that derives the transfer sender', () async {
    final signer = _Signer('0x${'a' * 40}');

    final error = await verifyBatchTransferSigner(
      signer: signer,
      coinType: 'ETH',
      path: "m/44'/60'/0'/0/0",
      addressType: 'legacy',
      fromAddress: '0x${'A' * 40}',
      mnemonic: 'fixture words',
      privateKey: '',
      isTest: false,
    );

    expect(error, isNull);
    expect(signer.addressDerivations, 1);
  });

  test('rejects a different signer before batch transaction signing', () async {
    final signer = _Signer('0x${'b' * 40}');

    final error = await verifyBatchTransferSigner(
      signer: signer,
      coinType: 'ETH',
      path: "m/44'/60'/0'/0/0",
      addressType: 'legacy',
      fromAddress: '0x${'a' * 40}',
      mnemonic: 'fixture words',
      privateKey: '',
      isTest: false,
    );

    expect(error, 'Signing key does not match sender address');
    expect(signer.addressDerivations, 1);
  });

  test(
    'does not attempt address derivation without signing material',
    () async {
      final signer = _Signer('0x${'a' * 40}');

      final error = await verifyBatchTransferSigner(
        signer: signer,
        coinType: 'ETH',
        path: "m/44'/60'/0'/0/0",
        addressType: 'legacy',
        fromAddress: '0x${'a' * 40}',
        mnemonic: '',
        privateKey: '',
        isTest: false,
      );

      expect(error, 'Signing key is unavailable');
      expect(signer.addressDerivations, 0);
    },
  );
}
