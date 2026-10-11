import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';

class _FakeSigner extends Trustdart {
  final payloads = <Map<String, dynamic>>[];

  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    payloads.add(Map<String, dynamic>.from(txData));
    // SignatureValidator only performs structural validation here. Broadcast
    // remains on the local fixture RPC, so no real transaction is created.
    return 'f8${List.filled(100, '0').join()}';
  }
}

class _RpcFixture {
  late final HttpServer server;
  final methods = <String>[];
  final estimates = <Map<String, dynamic>>[];
  BigInt nativeBalance = BigInt.one << 200;
  BigInt tokenBalance = BigInt.one << 200;
  BigInt gasEstimate = BigInt.from(21);
  int chainId = 1;
  String broadcastHash = '0xfixturehash';
  bool dropBroadcastResponse = false;

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = jsonDecode(
        await utf8.decoder.bind(request).join(),
      ) as Map<String, dynamic>;
      final method = body['method'] as String;
      methods.add(method);
      if (method == 'eth_estimateGas') {
        estimates.add(
          Map<String, dynamic>.from((body['params'] as List).first as Map),
        );
      }

      if (method == 'eth_sendRawTransaction' && dropBroadcastResponse) {
        final socket = await request.response.detachSocket(writeHeaders: false);
        socket.destroy();
        return;
      }
      final result = switch (method) {
        'eth_chainId' => _hex(BigInt.from(chainId)),
        'eth_getBalance' => _hex(nativeBalance),
        'eth_call' => '0x${tokenBalance.toRadixString(16).padLeft(64, '0')}',
        'eth_gasPrice' => '0x1',
        'eth_estimateGas' => _hex(gasEstimate),
        'eth_sendRawTransaction' => broadcastHash,
        _ => '0x0',
      };
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'jsonrpc': '2.0', 'id': body['id'], 'result': result}),
      );
      await request.response.close();
    });
  }

  String get url => 'http://127.0.0.1:${server.port}';

  static String _hex(BigInt value) => '0x${value.toRadixString(16)}';
}

SendParams _params({
  double amount = 1,
  int decimals = 18,
  String contract = '',
  int tokenDecimals = 18,
  String? calldata,
  BigInt? exact,
  BigInt? exactToken,
  bool sendMax = false,
  required String rpc,
  Future<void> Function(String)? beforeBroadcast,
}) => SendParams(
  coinType: 'ETH',
  fromAddress: '0x0000000000000000000000000000000000000001',
  toAddress: '0x0000000000000000000000000000000000000002',
  amount: amount,
  decimals: decimals,
  path: '',
  contractAddress: contract,
  tokenDecimals: tokenDecimals,
  calldata: calldata,
  privateKey: 'fixture-key',
  chainConfig: {'chainId': 1, 'service': rpc},
  nonceOverride: BigInt.zero,
  valueWeiOverride: exact,
  tokenValueWeiOverride: exactToken,
  sendMax: sendMax,
  beforeBroadcast: beforeBroadcast,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;
  setUpAll(() async {
    HttpOverrides.global = null;
    await S.load(const Locale('en'));
  });
  tearDownAll(() => HttpOverrides.global = previousHttpOverrides);

  late _RpcFixture rpc;
  late _FakeSigner signer;
  late EvmSender sender;
  setUp(() async {
    rpc = _RpcFixture();
    await rpc.start();
    addTearDown(() => rpc.server.close(force: true));
    signer = _FakeSigner();
    sender = EvmSender(trustdart: signer);
  });

  test(
    'native exact override owns transaction and displayed amounts',
    () async {
      final exact = BigInt.parse('9007199254740993');

      for (final staleDisplay in [double.nan, -1.0]) {
        final result = await sender.send(
          _params(amount: staleDisplay, exact: exact, rpc: rpc.url),
        );

        expect(result.success, isTrue);
        expect(result.actualAmount, closeTo(0.009007199254740993, 1e-18));
        expect(rpc.estimates.last['value'], '0x${exact.toRadixString(16)}');
        expect(signer.payloads.last['amount'], exact.toRadixString(16));
      }
    },
  );

  test('ERC20 exact override reaches estimate calldata and signer', () async {
    final exact = BigInt.parse('9007199254740995');

    final result = await sender.send(
      _params(
        amount: double.infinity,
        contract: '0x0000000000000000000000000000000000000003',
        exactToken: exact,
        rpc: rpc.url,
      ),
    );

    expect(result.success, isTrue);
    expect(result.actualAmount, closeTo(0.009007199254740995, 3e-18));
    expect(
      rpc.estimates.single['data'],
      endsWith(exact.toRadixString(16).padLeft(64, '0')),
    );
    expect(signer.payloads.single['amount'], exact.toRadixString(16));
  });

  test(
    'legacy amount uses the same converted wei for estimate and sign',
    () async {
      final expected = BigInt.parse('125000000000000000');

      final result = await sender.send(_params(amount: 0.125, rpc: rpc.url));

      expect(result.success, isTrue);
      expect(rpc.estimates.single['value'], '0x${expected.toRadixString(16)}');
      expect(signer.payloads.single['amount'], expected.toRadixString(16));
    },
  );

  test(
    'raw calldata keeps a zero native value through estimate and sign',
    () async {
      final result = await sender.send(
        _params(amount: 0, calldata: '0xdeadbeef', rpc: rpc.url),
      );

      expect(result.success, isTrue);
      expect(rpc.estimates.single['value'], '0x0');
      expect(rpc.estimates.single['data'], '0xdeadbeef');
      expect(signer.payloads.single['amount'], '0');
      expect(signer.payloads.single['msgData'], 'deadbeef');
    },
  );

  test(
    'send-max estimate uses requested value before signed fee deduction',
    () async {
      rpc.nativeBalance = BigInt.from(1000);
      final requested = BigInt.from(970);

      final result = await sender.send(
        _params(
          amount: 0.000000000000000970,
          exact: requested,
          sendMax: true,
          rpc: rpc.url,
        ),
      );

      // ETH doubles the fixture gas price to 2; ceil(21 * 1.2) = 26 gas.
      final signed = BigInt.from(948);
      expect(result.success, isTrue);
      expect(rpc.estimates.single['value'], '0x${requested.toRadixString(16)}');
      expect(signer.payloads.single['amount'], signed.toRadixString(16));
    },
  );

  test('wrong RPC network is rejected before estimation or signing', () async {
    rpc.chainId = 94;
    final result = await sender.send(_params(rpc: rpc.url));
    expect(result.success, isFalse);
    expect(rpc.methods, ['eth_chainId']);
    expect(signer.payloads, isEmpty);
  });

  test(
    'explicit amount near balance cannot silently become send-max',
    () async {
      rpc.nativeBalance = BigInt.from(1000);
      final result = await sender.send(
        _params(exact: BigInt.from(970), rpc: rpc.url),
      );
      expect(result.success, isFalse);
      expect(signer.payloads, isEmpty);
      expect(rpc.methods, isNot(contains('eth_sendRawTransaction')));
    },
  );

  test('durable hash save completes before broadcast', () async {
    final gate = Completer<void>();
    String? savedHash;
    final operation = sender.send(
      _params(
        rpc: rpc.url,
        beforeBroadcast: (hash) async {
          savedHash = hash;
          rpc.broadcastHash = hash;
          await gate.future;
        },
      ),
    );
    while (savedHash == null) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(rpc.methods, isNot(contains('eth_sendRawTransaction')));
    expect(savedHash, matches(RegExp(r'^0x[a-f0-9]{64}$')));
    gate.complete();
    final result = await operation;
    expect(result.success, isTrue);
    expect(result.txHash, savedHash);
  });

  test('storage failure blocks broadcasting', () async {
    final result = await sender.send(
      _params(
        rpc: rpc.url,
        beforeBroadcast: (_) async {
          throw StateError('fixture storage failed');
        },
      ),
    );
    expect(result.success, isFalse);
    expect(result.txHash, isNull);
    expect(rpc.methods, isNot(contains('eth_sendRawTransaction')));
  });

  test(
    'lost broadcast response retains the original saved hash without retry',
    () async {
      rpc.dropBroadcastResponse = true;
      String? savedHash;
      final result = await sender.send(
        _params(
          rpc: rpc.url,
          beforeBroadcast: (hash) async {
            savedHash = hash;
          },
        ),
      );
      expect(result.success, isFalse);
      expect(result.txHash, savedHash);
      expect(
        rpc.methods.where((m) => m == 'eth_sendRawTransaction'),
        hasLength(1),
      );
    },
  );

  test(
    'foreign broadcast hash cannot replace the durable local hash',
    () async {
      String? savedHash;
      final result = await sender.send(
        _params(
          rpc: rpc.url,
          beforeBroadcast: (hash) async {
            savedHash = hash;
          },
        ),
      );
      expect(result.success, isFalse);
      expect(result.txHash, savedHash);
      expect(result.error, 'Unexpected broadcast hash');
    },
  );

  test('invalid amounts fail before every RPC and signing operation', () async {
    final tooLarge = BigInt.one << 256;
    final invalid = [
      _params(amount: -1, rpc: rpc.url),
      _params(amount: double.nan, rpc: rpc.url),
      _params(amount: double.infinity, rpc: rpc.url),
      _params(exact: -BigInt.one, rpc: rpc.url),
      _params(exact: tooLarge, rpc: rpc.url),
      _params(
        contract: '0x0000000000000000000000000000000000000003',
        exactToken: -BigInt.one,
        rpc: rpc.url,
      ),
      _params(
        contract: '0x0000000000000000000000000000000000000003',
        exactToken: tooLarge,
        rpc: rpc.url,
      ),
    ];

    for (final params in invalid) {
      final result = await sender.send(params);
      expect(result.success, isFalse);
      expect(result.error, 'Invalid transfer amount');
    }
    expect(rpc.methods, isEmpty);
    expect(signer.payloads, isEmpty);
  });
}
