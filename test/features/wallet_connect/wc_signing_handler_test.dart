import 'dart:convert';
import 'dart:typed_data';

import 'package:eip712/eip712.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;
import 'package:web3dart/web3dart.dart' as web3;

// Public test-only scalar; never used with a funded account or a network client.
final _fixtureKey = web3.EthPrivateKey.fromInt(BigInt.one);

class _Client extends Fake implements wc.ReownWalletKit {
  final responses = <(String, wc.JsonRpcResponse)>[];

  @override
  Future<void> respondSessionRequest({
    required String topic,
    required wc.JsonRpcResponse response,
  }) async {
    responses.add((topic, response));
  }
}

class _Provider extends WalletConnectProvider {
  var keyReads = 0;
  var chainInitializations = 0;

  @override
  web3.EthPrivateKey get privateKey {
    keyReads++;
    return _fixtureKey;
  }

  @override
  Future<bool> web3clientInitFromChainId(String chainStr) async {
    chainInitializations++;
    return false;
  }
}

wc.SessionRequestEvent _request(String method, dynamic params) =>
    wc.SessionRequestEvent(
      73,
      'request-topic',
      method,
      'eip155:1',
      params,
      wc.TransportType.relay,
    );

void _expectSigner(String encodedSignature, Uint8List digest) {
  final bytes = web3.hexToBytes(encodedSignature);
  expect(bytes, hasLength(65));
  BigInt integer(List<int> bytes) =>
      BigInt.parse(web3.bytesToHex(bytes), radix: 16);
  final signature = web3.MsgSignature(
    integer(bytes.sublist(0, 32)),
    integer(bytes.sublist(32, 64)),
    bytes[64],
  );
  final address = web3.publicKeyToAddress(web3.ecRecover(digest, signature));
  expect(web3.bytesToHex(address), _fixtureKey.address.without0x);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Client client;
  late _Provider provider;
  setUp(() {
    client = _Client();
    provider = _Provider()..signClient = client;
  });
  tearDown(() {
    provider.signClient = null;
    provider.dispose();
  });

  for (final input in <(String, List<int>)>[
    ('0x48656c6c6f', utf8.encode('Hello')),
    ('Hello wallet', utf8.encode('Hello wallet')),
    ('签名验收 🔐', utf8.encode('签名验收 🔐')),
    ('line one\nline two', utf8.encode('line one\nline two')),
  ]) {
    test(
      'real personal_sign handler signs the supplied bytes: ${input.$1}',
      () async {
        provider.actionData = _request('personal_sign', [
          input.$1,
          _fixtureKey.address.with0x,
        ]);
        await provider.messageSignTap();
        expect(client.responses.single.$1, 'request-topic');
        final response = client.responses.single.$2;
        expect(response.id, 73);
        expect(response.error, isNull);
        final digest = web3.keccak256(
          Uint8List.fromList([
            ...utf8.encode(
              '\u0019Ethereum Signed Message:\n${input.$2.length}',
            ),
            ...input.$2,
          ]),
        );
        _expectSigner(response.result as String, digest);
        expect(provider.walletConnectState, WalletConnectState.connect);
      },
    );
  }

  for (final method in [
    'eth_signTypedData',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
  ]) {
    test(
      'real $method handler returns a recoverable EIP-712 signature',
      () async {
        final data = {
          'types': {
            'EIP712Domain': [
              {'name': 'name', 'type': 'string'},
            ],
            'Mail': [
              {'name': 'contents', 'type': 'string'},
            ],
          },
          'primaryType': 'Mail',
          'domain': {'name': 'N42 Test Fixture'},
          'message': {'contents': 'Verify the production signing handler'},
        };
        provider.actionData = _request(method, [
          _fixtureKey.address.with0x,
          jsonEncode(data),
        ]);
        await provider.messageSignTap();
        final digest = hashTypedData(
          typedData: TypedMessage.fromJson(data),
          version: method.endsWith('_v3')
              ? TypedDataVersion.v3
              : TypedDataVersion.v4,
        );
        _expectSigner(client.responses.single.$2.result as String, digest);
        expect(provider.walletConnectState, WalletConnectState.connect);
      },
    );
  }

  test(
    'eth_sign is rejected with 4200 without accessing a signing key',
    () async {
      provider.actionData = _request('eth_sign', [
        _fixtureKey.address.with0x,
        '0x1234',
      ]);
      await provider.messageSignTap();
      expect(client.responses.single.$1, 'request-topic');
      expect(client.responses.single.$2.id, 73);
      expect(client.responses.single.$2.error?.code, 4200);
      expect(provider.keyReads, 0);
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );

  test('duplicate signing tap leaves an in-flight request untouched', () async {
    provider.walletConnectState = WalletConnectState.messageSign;
    provider.actionData = _request('personal_sign', [
      'Hello',
      _fixtureKey.address.with0x,
    ]);
    await provider.messageSignTap();
    expect(client.responses, isEmpty);
    expect(provider.keyReads, 0);
    expect(provider.walletConnectState, WalletConnectState.messageSign);
  });

  for (final params in [
    null,
    <dynamic>[],
    <String, dynamic>{},
    [42],
    [42, _fixtureKey.address.with0x],
  ]) {
    test(
      'malformed personal_sign data cannot produce a signature: $params',
      () async {
        provider.actionData = _request('personal_sign', params);
        await provider.messageSignTap();
        expect(client.responses, isEmpty);
        expect(provider.keyReads, 0);
        expect(provider.walletConnectState, WalletConnectState.error);
        expect(provider.errorMessage, isNotEmpty);
      },
    );
  }

  for (final method in [
    'tron_signMessage',
    'aptos_signMessage',
    'sui_signMessage',
    'solana_signMessage',
  ]) {
    test('$method with no configured chain cannot invoke a signer', () async {
      provider.actionData = _request(method, {
        'message': base64Encode(utf8.encode('fixture')),
      });
      await provider.messageSignTap();
      expect(client.responses, isEmpty);
      expect(provider.keyReads, 0);
      expect(provider.walletConnectState, WalletConnectState.error);
      expect(provider.errorMessage, contains('chain'));
    });
  }

  test('missing event is a recoverable local error', () async {
    await provider.messageSignTap();
    expect(client.responses, isEmpty);
    expect(provider.walletConnectState, WalletConnectState.error);
    provider.actionData = _request('eth_sign', []);
    await provider.messageSignTap();
    expect(client.responses.single.$2.error?.code, 4200);
    expect(provider.walletConnectState, WalletConnectState.connect);
  });

  test('failed transaction chain initialization prevents signing', () async {
    provider.actionData = _request('eth_sendTransaction', [{}]);
    await provider.transactionSignTap();
    expect(provider.chainInitializations, 1);
    expect(provider.keyReads, 0);
    expect(client.responses, isEmpty);
  });

  test(
    'duplicate transaction tap does not initialize another signer',
    () async {
      provider.walletConnectState = WalletConnectState.transaction;
      provider.actionData = _request('eth_sendTransaction', [{}]);
      await provider.transactionSignTap();
      expect(provider.chainInitializations, 0);
      expect(client.responses, isEmpty);
    },
  );

  test(
    'cancel responds to the request topic and ID with user rejection',
    () async {
      provider.dAppTopic = 'different-selected-session';
      provider.actionData = _request('personal_sign', ['fixture']);
      await provider.cancelTap(WalletConnectState.messageSign);
      expect(client.responses.single.$1, 'request-topic');
      expect(client.responses.single.$2.id, 73);
      expect(client.responses.single.$2.error?.code, 4001);
      expect(provider.keyReads, 0);
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );
}
