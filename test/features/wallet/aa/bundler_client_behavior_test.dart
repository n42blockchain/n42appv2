import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:n42_wallet/features/wallet/aa/bundler/bundler_client.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_errors.dart';
import 'package:n42_wallet/features/wallet/aa/models/user_operation.dart';

class _Reply {
  const _Reply(this.body, {this.statusCode = 200});

  final String body;
  final int statusCode;
}

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this.replies);

  final List<_Reply> replies;
  final requests = <({Uri url, Map<String, String> headers, Map body})>[];
  Completer<http.StreamedResponse>? pending;
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = jsonDecode(await request.finalize().bytesToString()) as Map;
    requests.add((url: request.url, headers: request.headers, body: body));
    if (pending case final completer?) return completer.future;
    final reply = replies.isEmpty
        ? const _Reply('{"jsonrpc":"2.0","result":null}')
        : replies.removeAt(0);
    return http.StreamedResponse(
      Stream.value(utf8.encode(reply.body)),
      reply.statusCode,
      request: request,
    );
  }

  @override
  void close() => closed = true;
}

BundlerClient _client(_RecordingClient httpClient, {Duration? timeout}) =>
    BundlerClient(
      bundlerUrl: 'https://bundler.example/rpc',
      entryPoint: '0x1111111111111111111111111111111111111111',
      httpClient: httpClient,
      timeout: timeout ?? const Duration(seconds: 1),
    );

UserOperation _operation() => UserOperation(
  sender: '0x2222222222222222222222222222222222222222',
  nonce: BigInt.from(7),
  callData: Uint8List.fromList([1, 2, 3]),
  accountGasLimits: Uint8List(32),
  preVerificationGas: BigInt.from(21000),
  gasFees: Uint8List(32),
  signature: Uint8List.fromList([4, 5]),
  eip7702Auth: Uint8List.fromList([6]),
);

String _response(dynamic result) =>
    jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': result});

void main() {
  test('sends a v0.8 UserOperation with request id and entry point', () async {
    final transport = _RecordingClient([_Reply(_response('0xuser-op-hash'))]);
    final client = _client(transport);
    addTearDown(client.dispose);

    final hash = await client.sendUserOperation(_operation());

    expect(hash, '0xuser-op-hash');
    final request = transport.requests.single;
    expect(request.url, Uri.parse('https://bundler.example/rpc'));
    expect(request.body['method'], 'eth_sendUserOperation');
    expect(request.body['id'], 1);
    expect((request.body['params'] as List).last, client.entryPoint);
    expect(
      ((request.body['params'] as List).first as Map)['eip7702Auth'],
      '0x06',
    );
  });

  test('rejects non-string UserOperation hashes', () async {
    final client = _client(_RecordingClient([_Reply(_response(42))]));
    addTearDown(client.dispose);

    await expectLater(
      client.sendUserOperation(_operation()),
      throwsA(isA<BundlerRpcError>()),
    );
  });

  test('parses gas estimates and reports aggregate gas', () async {
    final client = _client(
      _RecordingClient([
        _Reply(
          _response({
            'verificationGasLimit': '0x64',
            'callGasLimit': '0xC8',
            'preVerificationGas': '0x14',
            'paymasterVerificationGasLimit': '0xA',
            'paymasterPostOpGasLimit': '0x5',
          }),
        ),
      ]),
    );
    addTearDown(client.dispose);

    final estimate = await client.estimateUserOperationGas(_operation());

    expect(estimate.verificationGasLimit, BigInt.from(100));
    expect(estimate.callGasLimit, BigInt.from(200));
    expect(estimate.preVerificationGas, BigInt.from(20));
    expect(estimate.totalGas, BigInt.from(335));
  });

  test('invalid gas estimate response is rejected', () async {
    final client = _client(_RecordingClient([_Reply(_response('no gas'))]));
    addTearDown(client.dispose);
    await expectLater(
      client.estimateUserOperationGas(_operation()),
      throwsA(isA<GasEstimationError>()),
    );
  });

  test(
    'queries parse receipts and safely return null for RPC errors',
    () async {
      final client = _client(
        _RecordingClient([
          _Reply(
            _response({
              'userOpHash': '0xhash',
              'sender': '0x2222222222222222222222222222222222222222',
              'nonce': '0x2',
              'success': false,
              'actualGasUsed': '0x3',
              'actualGasCost': '0x4',
              'receipt': {'transactionHash': '0xtx', 'status': '0x0'},
              'logs': [],
            }),
          ),
          _Reply('{"jsonrpc":"2.0","error":{"code":-1,"message":"offline"}}'),
        ]),
      );
      addTearDown(client.dispose);

      final receipt = await client.getUserOperationReceipt('0xhash');
      final failedLookup = await client.getUserOperationReceipt('0xmissing');

      expect(receipt?.success, isFalse);
      expect(receipt?.actualGasUsed, BigInt.from(3));
      expect(receipt?.receipt.transactionHash, '0xtx');
      expect(failedLookup, isNull);
    },
  );

  test('supported-entry-point query uses the configured fallback', () async {
    final transport = _RecordingClient([
      _Reply(_response(['0xaaa', '0xbbb'])),
      _Reply(_response('unexpected')),
    ]);
    final client = _client(transport);
    addTearDown(client.dispose);

    expect(await client.getSupportedEntryPoints(), ['0xaaa', '0xbbb']);
    expect(await client.getSupportedEntryPoints(), [client.entryPoint]);
  });

  test('parses hexadecimal chain ID and rejects invalid responses', () async {
    final client = _client(
      _RecordingClient([_Reply(_response('0x89')), _Reply(_response(137))]),
    );
    addTearDown(client.dispose);

    expect(await client.getChainId(), BigInt.from(137));
    await expectLater(client.getChainId(), throwsA(isA<BundlerRpcError>()));
  });

  test('wraps HTTP and malformed JSON failures in a typed RPC error', () async {
    final client = _client(
      _RecordingClient([
        const _Reply('denied', statusCode: 401),
        const _Reply('not-json'),
      ]),
    );
    addTearDown(client.dispose);

    await expectLater(client.getChainId(), throwsA(isA<BundlerRpcError>()));
    await expectLater(client.getChainId(), throwsA(isA<BundlerRpcError>()));
  });

  test('waits for a receipt then reports a bounded timeout', () async {
    final client = _client(_RecordingClient([_Reply(_response(null))]));
    addTearDown(client.dispose);

    await expectLater(
      client.waitForReceipt(
        '0xmissing',
        timeout: Duration.zero,
        pollingInterval: Duration.zero,
      ),
      throwsA(isA<ReceiptTimeoutError>()),
    );
  });

  test('disposes its injected HTTP client', () {
    final transport = _RecordingClient([]);
    _client(transport).dispose();
    expect(transport.closed, isTrue);
  });

  test(
    'chain factories preserve configured versions and reject unknown chains',
    () {
      final v08 = BundlerClient.v08('ETH');
      final v07 = BundlerClient.v07('ETH');
      addTearDown(v08.dispose);
      addTearDown(v07.dispose);
      expect(v08.version, EntryPointVersion.v08);
      expect(v08.supportsEIP7702, isTrue);
      expect(v07.version, EntryPointVersion.v07);
      expect(v07.supportsEIP7702, isFalse);
      expect(
        () => BundlerClient.forChain('UNKNOWN'),
        throwsA(isA<AAUnsupportedChainError>()),
      );
    },
  );
}
