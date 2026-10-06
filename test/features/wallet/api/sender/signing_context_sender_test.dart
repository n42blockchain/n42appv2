import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/signing_context_sender.dart';

const _sender = '0x0000000000000000000000000000000000000001';

class _FakeSigner extends Trustdart {
  final generatedArgs = <Map<String, String>>[];
  String derivedAddress = _sender;
  Completer<void>? generationGate;
  Completer<void>? generationStarted;

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
    generatedArgs.add({
      'coin': coin,
      'path': path,
      'addressType': addressType,
      'mnemonic': mnemonic,
      'pk': pk,
      'isTest': '$isTest',
    });
    generationStarted?.complete();
    await generationGate?.future;
    return {addressType: derivedAddress};
  }
}

class _FakeSender implements ChainSender {
  SendParams? receivedParams;
  int calls = 0;

  @override
  Future<SendResult> send(SendParams params) async {
    calls++;
    receivedParams = params;
    return const SendResult.ok('fixture-hash');
  }
}

SendParams _params({String? privateKey}) => SendParams(
  coinType: 'ETH',
  fromAddress: _sender,
  toAddress: '0x0000000000000000000000000000000000000002',
  amount: 1,
  decimals: 18,
  path: "m/44'/60'/0'/0/0",
  privateKey: privateKey,
  chainConfig: const {'blockchainType': 'Ethereum'},
);

void main() {
  test(
    'rejects a signer that does not own from before entering the sender',
    () async {
      final signer = _FakeSigner()
        ..derivedAddress = '0x0000000000000000000000000000000000000003';
      final delegate = _FakeSender();
      final guard = WalletSigningContextSender(
        delegate: delegate,
        readSigningContext: (_) =>
            const WalletSigningContext(mnemonic: 'fixture phrase'),
        trustdart: signer,
      );

      final result = await guard.send(_params());

      expect(result.success, isFalse);
      expect(result.error, 'Signing key does not match sender address');
      expect(delegate.calls, 0);
      expect(signer.generatedArgs.single['mnemonic'], 'fixture phrase');
    },
  );

  test(
    'keeps the captured signer while address validation is awaiting',
    () async {
      final signer = _FakeSigner()
        ..generationGate = Completer<void>()
        ..generationStarted = Completer<void>();
      final delegate = _FakeSender();
      var activeContext = const WalletSigningContext(mnemonic: 'wallet A');
      final guard = WalletSigningContextSender(
        delegate: delegate,
        readSigningContext: (_) => activeContext,
        trustdart: signer,
      );

      final sending = guard.send(_params());
      await signer.generationStarted!.future;
      activeContext = const WalletSigningContext(mnemonic: 'wallet B');
      signer.generationGate!.complete();
      final result = await sending;

      expect(result.success, isTrue);
      expect(signer.generatedArgs.single['mnemonic'], 'wallet A');
      expect(delegate.receivedParams?.signingContext?.mnemonic, 'wallet A');
      expect(delegate.receivedParams?.signingContext?.addressVerified, isTrue);
    },
  );

  test('uses the explicit key when validating an imported account', () async {
    final signer = _FakeSigner();
    final delegate = _FakeSender();
    final guard = WalletSigningContextSender(
      delegate: delegate,
      readSigningContext: (_) => const WalletSigningContext(),
      trustdart: signer,
    );

    final result = await guard.send(_params(privateKey: 'fixture private key'));

    expect(result.success, isTrue);
    expect(signer.generatedArgs.single['pk'], 'fixture private key');
    expect(signer.generatedArgs.single['mnemonic'], isEmpty);
    expect(delegate.receivedParams?.privateKey, 'fixture private key');
  });
}
