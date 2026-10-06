import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/sender/aa_transfer_handler.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

class _Signer extends Trustdart {
  int addressDerivations = 0;
  int signatures = 0;

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
    return {addressType: '0x${'b' * 40}'};
  }

  @override
  Future<String> signMessage(
    String coin,
    String path,
    String txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    signatures++;
    return '0xsignature';
  }
}

SmartAccount _account({
  String address = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  String ownerAddress = '0xcccccccccccccccccccccccccccccccccccccccc',
}) => SmartAccount(
  address: address,
  type: SmartAccountType.simpleAccount,
  ownerAddress: ownerAddress,
  state: SmartAccountState.deployed,
  chainId: 1,
  salt: BigInt.zero,
  factoryAddress: '0xdddddddddddddddddddddddddddddddddddddddd',
  createdAt: DateTime.utc(2026),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'rejects a signer that does not own the smart account before signing',
    () async {
      final signer = _Signer();
      final coin = CoinModel()
        ..coin = {
          'coinType': 'ETH',
          'path': {'legacy': "m/44'/60'/0'/0/0"},
        };
      final handler = AATransferHandler(
        'ETH',
        signer: signer,
        coinModelReader: (_) => coin,
      );

      final result = await handler.transfer(
        AATransferParams(
          chainSymbol: 'ETH',
          fromAddress: _account().address,
          toAddress: '0x${'e' * 40}',
          value: 0.01,
          smartAccount: _account(),
          privateKey: 'fixture-private-key',
          chainMap: {'path': "m/44'/60'/0'/0/0"},
        ),
      );

      expect(result.error, isTrue);
      expect(result.data, 'Signing key does not match smart account owner');
      expect(signer.addressDerivations, 1);
      expect(signer.signatures, 0);
    },
  );

  test('rejects a mismatched from address before deriving a signer', () async {
    final signer = _Signer();
    final coin = CoinModel()
      ..coin = {
        'coinType': 'ETH',
        'path': {'legacy': "m/44'/60'/0'/0/0"},
      };
    final handler = AATransferHandler(
      'ETH',
      signer: signer,
      coinModelReader: (_) => coin,
    );

    final result = await handler.transfer(
      AATransferParams(
        chainSymbol: 'ETH',
        fromAddress: '0x${'f' * 40}',
        toAddress: '0x${'e' * 40}',
        value: 0.01,
        smartAccount: _account(),
        privateKey: 'fixture-private-key',
        chainMap: {'path': "m/44'/60'/0'/0/0"},
      ),
    );

    expect(result.error, isTrue);
    expect(signer.addressDerivations, 0);
    expect(signer.signatures, 0);
  });
}
