import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/gas_tracker_api.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';

class _RpcAdapter implements HttpClientAdapter {
  final Queue<Map<String, dynamic>> _responses = Queue();
  final List<Map<String, dynamic>> requests = [];

  void enqueue(Map<String, dynamic> response) => _responses.add(response);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(Map<String, dynamic>.from(options.data as Map));
    if (_responses.isEmpty) throw StateError('No RPC response queued');
    return ResponseBody.fromString(
      jsonEncode(_responses.removeFirst()),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _RpcAdapter adapter;
  late GasTrackerApi api;

  setUp(() {
    adapter = _RpcAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    api = GasTrackerApi.testing(dio);
  });

  test('rejects unsupported chain before issuing an RPC request', () async {
    final result = await api.getGasEstimate(coinType: 'NOT_A_CHAIN');

    expect(result.error, isTrue);
    expect(result.data, 'Unsupported chain: NOT_A_CHAIN');
    expect(adapter.requests, isEmpty);
  });

  test('parses EIP-1559 history and preserves a custom gas limit', () async {
    adapter.enqueue({
      'jsonrpc': '2.0',
      'result': {
        'baseFeePerGas': ['0x3b9aca00', '0x3b9aca00'],
        'reward': [
          ['0x3b9aca0'],
          ['0x77359400'],
          ['0xee6b2800'],
        ],
      },
    });

    final result = await api.getGasEstimate(
      coinType: 'ETH',
      customGasLimit: BigInt.from(55_000),
    );

    expect(result.error, isFalse);
    final estimate = result.data as GasEstimateModel;
    expect(estimate.supportsEIP1559, isTrue);
    expect(estimate.baseFee, BigInt.from(1_000_000_000));
    expect(estimate.gasLimit, BigInt.from(55_000));
    expect(estimate.chainSymbol, 'ETH');
    expect(adapter.requests.single['method'], 'eth_feeHistory');
    expect(adapter.requests.single['params'], [
      '0xa',
      'latest',
      [10, 50, 90],
    ]);
  });

  test(
    'falls back to legacy gas price when fee history returns RPC error',
    () async {
      adapter.enqueue({
        'error': {'code': -32601, 'message': 'method not found'},
      });
      adapter.enqueue({'result': '0x3b9aca00'});

      final result = await api.getGasEstimate(coinType: 'ETH');

      expect(result.error, isFalse);
      final estimate = result.data as GasEstimateModel;
      expect(estimate.supportsEIP1559, isFalse);
      expect(estimate.gasLimit, BigInt.from(50_000));
      expect(estimate.slow.effectiveGasPrice, BigInt.from(900_000_000));
      expect(estimate.standard.effectiveGasPrice, BigInt.from(1_000_000_000));
      expect(estimate.fast.effectiveGasPrice, BigInt.from(1_300_000_000));
      expect(adapter.requests.map((request) => request['method']), [
        'eth_feeHistory',
        'eth_gasPrice',
      ]);
    },
  );

  test(
    'getBaseFee parses a block fee and reports unavailable fee safely',
    () async {
      adapter.enqueue({
        'result': {'baseFeePerGas': '0x3b9aca00'},
      });
      final result = await api.getBaseFee(coinType: 'ETH');
      expect(result.error, isFalse);
      expect(result.data, BigInt.from(1_000_000_000));
      expect(adapter.requests.single['method'], 'eth_getBlockByNumber');

      adapter.enqueue({
        'result': {'number': '0x10'},
      });
      final unavailable = await api.getBaseFee(coinType: 'ETH');
      expect(unavailable.error, isTrue);
      expect(unavailable.data, 'baseFeePerGas not available');
    },
  );

  test('formats estimated time at seconds, minutes, and hours boundaries', () {
    expect(GasTrackerApi.formatEstimatedTime(59), '~59s');
    expect(GasTrackerApi.formatEstimatedTime(60), '~1min');
    expect(GasTrackerApi.formatEstimatedTime(3599), '~59min');
    expect(GasTrackerApi.formatEstimatedTime(3600), '~1hr');
  });
}
