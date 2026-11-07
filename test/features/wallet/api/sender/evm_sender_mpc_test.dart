import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet/wallet.dart' show EthereumAddress, EtherAmount;
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_provider.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_evm_transaction_signer.dart';
import 'package:n42_wallet/generated/l10n.dart';

class _Provider extends Mock implements MpcProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousOverrides = HttpOverrides.current;
  final key = EthPrivateKey.fromHex(
    '1'.padLeft(64, '0'),
  ); // Public test vector.
  final to = '0x${'35' * 20}';
  final contract = '0x${'12' * 20}';
  final exact = BigInt.parse('1000000000000000001');
  late HttpServer rpc;
  late _Provider provider;
  late EvmSender sender;
  var current = true;
  var wrongHash = false;
  final methods = <String>[];
  String? submitted;
  String? persisted;
  Future<void> Function()? duringSign;
  setUpAll(() async {
    registerFallbackValue(Uint8List(0));
    HttpOverrides.global = null;
    await S.load(const Locale('en'));
  });
  tearDownAll(() => HttpOverrides.global = previousOverrides);
  setUp(() async {
    current = true;
    wrongHash = false;
    duringSign = null;
    methods.clear();
    submitted = persisted = null;
    provider = _Provider();
    when(() => provider.currentAddress).thenReturn(key.address.with0x);
    when(() => provider.isLoggedIn).thenReturn(true);
    when(() => provider.signTransaction(any())).thenAnswer((call) async {
      final signature = key.signToUint8List(
        call.positionalArguments.first as Uint8List,
      );
      await duringSign?.call();
      return MpcSignResult(signature: signature, signatureHex: 'unused');
    });
    rpc = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => rpc.close(force: true));
    rpc.listen((request) async {
      final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
      final method = body['method'] as String;
      methods.add(method);
      Object result;
      switch (method) {
        case 'eth_chainId':
          result = '0x1';
        case 'eth_getBalance':
          result = '0x${(BigInt.one << 200).toRadixString(16)}';
        case 'eth_call':
          result =
              '0x${(BigInt.one << 200).toRadixString(16).padLeft(64, '0')}';
        case 'eth_gasPrice':
          result = '0x1';
        case 'eth_estimateGas':
          result = '0x5208';
        case 'eth_getTransactionCount':
          result = '0x7';
        case 'eth_sendRawTransaction':
          expect(
            persisted,
            isNotNull,
            reason: 'durable callback must finish first',
          );
          submitted = (body['params'] as List).first as String;
          result = wrongHash
              ? '0x${'00' * 32}'
              : '0x${bytesToHex(keccak256(hexToBytes(submitted!)))}';
        default:
          throw StateError('Unexpected RPC method $method');
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'jsonrpc': '2.0', 'id': body['id'], 'result': result}),
      );
      await request.response.close();
    });
    sender = EvmSender(
      mpcSigner: MpcEvmTransactionSigner(provider, isCurrent: () => current),
      ownerIdentity: () => 'fixture-owner',
      readMnemonic: () =>
          throw StateError('MPC must not read a local mnemonic'),
    );
  });
  SendParams params({
    bool token = false,
    bool persist = true,
    String? privateKey,
    String? calldata,
    Future<void> Function(String)? persistence,
  }) => SendParams(
    coinType: 'ETH',
    fromAddress: key.address.with0x,
    toAddress: to,
    amount: 0,
    decimals: 18,
    path: '',
    contractAddress: token ? contract : '',
    tokenDecimals: 18,
    chainConfig: {'chainId': 1, 'service': 'http://127.0.0.1:${rpc.port}'},
    valueWeiOverride: token ? null : exact,
    tokenValueWeiOverride: token ? exact : null,
    nonceOverride: BigInt.from(7),
    privateKey: privateKey,
    calldata: calldata,
    beforeBroadcast: persist
        ? persistence ??
              (hash) async {
                persisted = hash;
              }
        : null,
  );
  for (final token in [false, true]) {
    test(
      'real MPC signed ${token ? 'ERC20' : 'native'} bytes reach RPC after persistence',
      () async {
        final result = await sender.send(params(token: token));
        expect(result.success, isTrue, reason: result.error);
        final data = token
            ? hexToBytes(
                'a9059cbb${to.substring(2).padLeft(64, '0')}${exact.toRadixString(16).padLeft(64, '0')}',
              )
            : Uint8List(0);
        final expected = Transaction(
          from: key.address,
          to: EthereumAddress.fromHex(token ? contract : to),
          nonce: 7,
          maxGas: 25200,
          value: EtherAmount.inWei(token ? BigInt.zero : exact),
          data: data,
          maxFeePerGas: EtherAmount.inWei(BigInt.two),
          maxPriorityFeePerGas: EtherAmount.inWei(BigInt.one),
        );
        expect(
          submitted,
          '0x${bytesToHex(signTransactionRaw(expected, key, chainId: 1))}',
        );
        expect(result.txHash, persisted);
        expect(
          methods.where((m) => m == 'eth_sendRawTransaction'),
          hasLength(1),
        );
      },
    );
  }
  test('empty hex calldata preserves ordinary token transfers', () async {
    expect(
      (await sender.send(params(token: true, calldata: '0x'))).success,
      isTrue,
    );
  });
  test('ambiguous token calldata never reaches signing or broadcast', () async {
    expect(
      (await sender.send(params(token: true, calldata: '0x1234'))).success,
      isFalse,
    );
    expect(submitted, isNull);
    verifyNever(() => provider.signTransaction(any()));
  });
  test('account switch during persistence prevents broadcast', () async {
    final result = await sender.send(
      params(
        persistence: (hash) async {
          persisted = hash;
          current = false;
        },
      ),
    );
    expect(result.success, isFalse);
    expect(persisted, isNotNull);
    expect(submitted, isNull);
  });
  test('missing durable persistence stops before RPC or signing', () async {
    expect((await sender.send(params(persist: false))).success, isFalse);
    expect(methods, isEmpty);
    verifyNever(() => provider.signTransaction(any()));
  });
  test('does not accept a local key as an MPC fallback', () async {
    expect((await sender.send(params(privateKey: 'fixture'))).success, isFalse);
    expect(methods, isEmpty);
    verifyNever(() => provider.signTransaction(any()));
  });
  test(
    'account switch during MPC await prevents persistence and dispatch',
    () async {
      duringSign = () async {
        current = false;
      };
      expect((await sender.send(params())).success, isFalse);
      expect(persisted, isNull);
      expect(submitted, isNull);
    },
  );
  test('failed durable write prevents dispatch', () async {
    final result = await sender.send(
      params(
        persistence: (_) async {
          throw StateError('disk unavailable');
        },
      ),
    );
    expect(result.success, isFalse);
    expect(submitted, isNull);
  });
  test(
    'unexpected remote hash remains uncertain with original durable hash',
    () async {
      wrongHash = true;
      final result = await sender.send(params());
      expect(result.success, isFalse);
      expect(result.definitelyNotSubmitted, isFalse);
      expect(result.txHash, persisted);
      expect(result.error, contains('Unexpected broadcast hash'));
    },
  );
}
