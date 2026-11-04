import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;
import 'package:web3dart/web3dart.dart' as web3;

// Deterministic test-only key; it is never loaded from wallet storage.
final _testKey = web3.EthPrivateKey.fromInt(BigInt.one);

class _WalletKit extends Fake implements wc.ReownWalletKit {
  final responses = <(String, wc.JsonRpcResponse)>[];
  Object? responseFailure;
  Future<void> Function()? beforeRespond;

  @override
  Future<void> respondSessionRequest({
    required String topic,
    required wc.JsonRpcResponse response,
  }) async {
    if (beforeRespond != null) await beforeRespond!();
    if (responseFailure case final failure?) throw failure;
    responses.add((topic, response));
  }
}

class _SigningProvider extends WalletConnectProvider {
  // This fixture isolates signing/preview; permission enforcement has its own suite.
  @override
  bool isSessionRequestAuthorized(wc.SessionRequestEvent request) => true;

  int privateKeyReads = 0;
  int chainInitializations = 0;

  @override
  web3.EthPrivateKey get privateKey {
    privateKeyReads++;
    return _testKey;
  }

  @override
  Future<bool> web3clientInitFromChainId(String chainId) async {
    chainInitializations++;
    return true;
  }
}

wc.SessionRequestEvent _request(String method, dynamic params) =>
    wc.SessionRequestEvent(
      451,
      'request-session',
      method,
      'eip155:1',
      params,
      wc.TransportType.relay,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _SigningProvider provider;
  late _WalletKit walletKit;

  setUp(() {
    provider = _SigningProvider();
    walletKit = _WalletKit();
    provider.signClient = walletKit;
  });

  tearDown(() {
    provider.signClient = null;
    provider.dispose();
  });

  test(
    'personal_sign accepts the active account with case differences',
    () async {
      provider.actionData = _request('personal_sign', [
        'fixture',
        '0x${_testKey.address.with0x.substring(2).toUpperCase()}',
      ]);
      await provider.messageSignTap();
      expect(walletKit.responses.single.$2.error, isNull);
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );
  test('personal_sign rejects a different requested account', () async {
    provider.actionData = _request('personal_sign', [
      'fixture',
      '0x1111111111111111111111111111111111111111',
    ]);
    await provider.messageSignTap();
    expect(walletKit.responses, isEmpty);
    expect(provider.walletConnectState, WalletConnectState.error);
    expect(provider.errorMessage, contains('Requested signer'));
  });
  test('typed-data rejects a different requested account before parsing or signing', () async {
    provider.actionData = _request('eth_signTypedData_v4', [
      '0x1111111111111111111111111111111111111111',
      '{}',
    ]);
    await provider.messageSignTap();
    expect(walletKit.responses, isEmpty);
    expect(provider.walletConnectState, WalletConnectState.error);
    expect(provider.errorMessage, contains('Requested signer'));
  });
  for (final fail in [false, true]) {
    test(
      'old message response ${fail ? 'failure' : 'success'} preserves a new request state',
      () async {
        provider.actionData = _request('personal_sign', [
          'old',
          _testKey.address.with0x,
        ]);
        walletKit.beforeRespond = () async {
          provider.actionData = _request('personal_sign', [
            'new',
            _testKey.address.with0x,
          ]);
          provider.walletConnectState = WalletConnectState.messageSignOK;
          if (fail) throw StateError('old response failed');
        };
        await provider.messageSignTap();
        expect(provider.walletConnectState, WalletConnectState.messageSignOK);
        expect(provider.errorMessage, isEmpty);
      },
    );
  }
  for (final message in ['deadbeef', 'cafe', '1234']) {
    test('personal_sign preserves unprefixed text $message', () async {
      provider.actionData = _request('personal_sign', [
        message,
        _testKey.address.with0x,
      ]);
      await provider.messageSignTap();
      expect(
        walletKit.responses.single.$2.result,
        web3.bytesToHex(
          _testKey.signPersonalMessageToUint8List(
            Uint8List.fromList(utf8.encode(message)),
          ),
          include0x: true,
        ),
      );
    });
  }
  test(
    'personal_sign returns a signature recoverable to its test signer',
    () async {
      const message = 'WalletConnect signing fixture';
      provider.actionData = _request('personal_sign', [
        message,
        _testKey.address.with0x,
      ]);

      await provider.messageSignTap();

      final response = walletKit.responses.single;
      expect(response.$1, 'request-session');
      expect(response.$2.id, 451);
      expect(response.$2.error, isNull);
      final digest = web3.keccak256(
        Uint8List.fromList([
          ...utf8.encode('\u0019Ethereum Signed Message:\n${message.length}'),
          ...utf8.encode(message),
        ]),
      );
      final signatureBytes = web3.hexToBytes(response.$2.result as String);
      expect(signatureBytes, hasLength(65));
      BigInt word(List<int> bytes) =>
          BigInt.parse(web3.bytesToHex(bytes), radix: 16);
      final signature = web3.MsgSignature(
        word(signatureBytes.sublist(0, 32)),
        word(signatureBytes.sublist(32, 64)),
        signatureBytes[64],
      );
      final recovered = web3.publicKeyToAddress(
        web3.ecRecover(digest, signature),
      );
      expect(web3.bytesToHex(recovered), _testKey.address.without0x);
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );

  test('eth_sign is rejected before reading the signing key', () async {
    provider.actionData = _request('eth_sign', [
      _testKey.address.with0x,
      '0xdeadbeef',
    ]);

    await provider.messageSignTap();

    final response = walletKit.responses.single.$2;
    expect(response.id, 451);
    expect(response.error?.code, 4200);
    expect(provider.privateKeyReads, 0);
    expect(provider.walletConnectState, WalletConnectState.connect);
  });

  for (final (method, params, expectedMessage) in <(String, dynamic, String)>[
    ('tron_signTransaction', {'message': 'fixture'}, 'TRON'),
    ('solana_signAndSendTransaction', {'transaction': 'fixture'}, 'Solana'),
    ('aptos_signAndSubmitTransaction', {'transaction': 'fixture'}, 'Aptos'),
    ('sui_signAndExecuteTransaction', {'transaction': 'fixture'}, 'Sui'),
    ('near_signTransaction', {'transaction': 'fixture'}, 'NEAR'),
  ]) {
    test('$method rejects when its chain is not configured', () async {
      provider.actionData = _request(method, params);

      await provider.transactionSignTap();

      expect(provider.chainInitializations, 1);
      expect(provider.privateKeyReads, 0);
      expect(walletKit.responses, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.error);
      expect(provider.errorMessage, contains(expectedMessage));
    });
  }

  test(
    'NEAR request without a transaction is rejected before key access',
    () async {
      provider.actionData = _request('near_signTransaction', {});

      await provider.transactionSignTap();

      expect(provider.privateKeyReads, 0);
      expect(walletKit.responses, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.error);
      expect(provider.errorMessage, contains('no transaction provided'));
    },
  );

  test('WalletKit response failure is surfaced as a signing error', () async {
    walletKit.responseFailure = StateError('session response failed');
    provider.actionData = _request('personal_sign', [
      'fixture',
      _testKey.address.with0x,
    ]);

    await provider.messageSignTap();

    expect(provider.walletConnectState, WalletConnectState.error);
    expect(provider.errorMessage, contains('session response failed'));
  });
}
