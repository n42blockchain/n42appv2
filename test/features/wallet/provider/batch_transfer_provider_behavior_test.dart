import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex, keccak256, hexToBytes;

import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

class _BlockedHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Network disabled in provider test');
}

class _BlockedHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _BlockedHttpClient();
}

class _DeferredBroadcastApi extends BatchTransferApi {
  final result = Completer<MessageModel>();
  final entered = Completer<void>();
  @override
  Future<MessageModel> broadcastTransaction(String rpcUrl, String signedTx) {
    entered.complete();
    return result.future;
  }
}

class _UnknownSubmissionApi extends BatchTransferApi {
  _UnknownSubmissionApi({this.fail = false});
  final bool fail;
  int sends = 0;
  @override
  Future<MessageModel> broadcastTransaction(
    String rpcUrl,
    String signedTx,
  ) async {
    sends++;
    if (fail) throw TimeoutException('unknown broadcast outcome');
    return MessageModel()
      ..data = bytesToHex(keccak256(hexToBytes(signedTx)), include0x: true);
  }

  @override
  Future<Map<String, dynamic>?> pollReceipt(
    String rpcUrl,
    String txHash,
  ) async => null;
}

class _ConfirmedSubmissionApi extends _UnknownSubmissionApi {
  _ConfirmedSubmissionApi(this.status);
  final String status;
  @override
  Future<Map<String, dynamic>?> pollReceipt(
    String rpcUrl,
    String txHash,
  ) async => {
    'transactionHash': txHash,
    'blockHash': '0x${'ab' * 32}',
    'blockNumber': '0x1',
    'status': status,
  };
  @override
  Future<bool> isReceiptFinal(
    String rpcUrl,
    int chainId,
    Map<String, dynamic> receipt, {
    Future<dynamic> Function(String method, List<dynamic> params)? rpc,
  }) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    HttpOverrides.global = _BlockedHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
  });

  BatchTransferProvider createProvider() {
    final provider = BatchTransferProvider();
    provider.initialize(
      chainSymbol: 'ETH',
      rpcUrl: 'https://rpc.invalid',
      chainId: 1,
      fromAddress: '0x${'a1' * 20}',
      tokenSymbol: 'ETH',
      decimals: 18,
    );
    return provider;
  }

  test(
    'callers cannot change recipients without invalidating provider state',
    () {
      final provider = createProvider();
      addTearDown(provider.dispose);
      provider.addItem('0x${'b2' * 20}', BigInt.from(250));
      expect(() => provider.items.clear(), throwsUnsupportedError);
      expect(provider.recipientCount, 1);
      expect(provider.totalAmount, BigInt.from(250));
    },
  );

  test(
    'a previous account broadcast failure cannot overwrite a new account',
    () async {
      final api = _DeferredBroadcastApi();
      final provider = BatchTransferProvider(api: api);
      addTearDown(provider.dispose);
      void initialize(String address) => provider.initialize(
        chainSymbol: 'ETH',
        rpcUrl: 'https://rpc.invalid',
        chainId: 1,
        fromAddress: address,
        tokenSymbol: 'ETH',
        decimals: 18,
      );
      initialize('0x${'a1' * 20}');
      final sending = provider.broadcastTransaction('0x01');
      await api.entered.future;
      initialize('0x${'b2' * 20}');
      api.result.completeError(StateError('old account request failed'));
      expect(await sending, isFalse);
      expect(provider.state, BatchTransferState.initial);
      expect(provider.errorMessage, isNull);
      expect(provider.txHash, isNull);
    },
  );

  test(
    'a stale successful broadcast cannot attach its hash to a new account',
    () async {
      final api = _DeferredBroadcastApi();
      final provider = BatchTransferProvider(api: api);
      addTearDown(provider.dispose);
      void initialize(String address) => provider.initialize(
        chainSymbol: 'ETH',
        rpcUrl: 'https://rpc.invalid',
        chainId: 1,
        fromAddress: address,
        tokenSymbol: 'ETH',
        decimals: 18,
      );
      initialize('0x${'a1' * 20}');
      final sending = provider.broadcastTransaction('0x01');
      await api.entered.future;
      initialize('0x${'b2' * 20}');
      api.result.complete(MessageModel()..data = '0x${'ab' * 32}');
      expect(await sending, isFalse);
      expect(provider.state, BatchTransferState.initial);
      expect(provider.txHash, isNull);
      expect(provider.errorMessage, isNull);
    },
  );

  test('owner change during durable preparation cancels without blocking a new batch', () async {
    final api = _ConfirmedSubmissionApi('0x1');
    BatchTransferProvider create() {
      final provider = BatchTransferProvider(api: api);
      provider.initialize(
        chainSymbol: 'ETH',
        rpcUrl: 'https://rpc.invalid',
        chainId: 1,
        fromAddress: '0x${'a1' * 20}',
        tokenSymbol: 'ETH',
        decimals: 18,
      );
      addTearDown(provider.dispose);
      return provider;
    }

    var owner = true;
    final first = create();
    final attempt = first.broadcastTransaction(
      '0x01',
      isOwnerCurrent: () => owner,
    );
    owner = false;
    expect(await attempt, isFalse);
    expect(api.sends, 0);
    expect(await create().broadcastTransaction('0x02'), isTrue);
    expect(api.sends, 1);
  });

  for (final status in ['0x1', '0x0']) {
    test(
      'finalized $status releases the journal for a subsequent transfer',
      () async {
        final api = _ConfirmedSubmissionApi(status);
        BatchTransferProvider create() {
          final provider = BatchTransferProvider(api: api);
          provider.initialize(
            chainSymbol: 'ETH',
            rpcUrl: 'https://rpc.invalid',
            chainId: 1,
            fromAddress: '0x${'a1' * 20}',
            tokenSymbol: 'ETH',
            decimals: 18,
          );
          addTearDown(provider.dispose);
          return provider;
        }

        final first = create();
        expect(await first.broadcastTransaction('0x01'), status == '0x1');
        expect(
          first.state,
          status == '0x1'
              ? BatchTransferState.success
              : BatchTransferState.error,
        );
        final next = create();
        expect(await next.broadcastTransaction('0x02'), status == '0x1');
        expect(api.sends, 2);
      },
    );
  }
  for (final fail in [false, true]) {
    test(
      'unknown ${fail ? 'broadcast' : 'receipt'} is pending and cannot be submitted twice',
      () async {
        final api = _UnknownSubmissionApi(fail: fail);
        final provider = BatchTransferProvider(api: api);
        addTearDown(provider.dispose);
        provider.initialize(
          chainSymbol: 'ETH',
          rpcUrl: 'https://rpc.invalid',
          chainId: 1,
          fromAddress: '0x${'a1' * 20}',
          tokenSymbol: 'ETH',
          decimals: 18,
        );
        provider.addItem('0x${'b2' * 20}', BigInt.one);
        expect(await provider.broadcastTransaction('0x01'), isFalse);
        expect(provider.state, BatchTransferState.awaitingConfirmation);
        expect(provider.items.single.status.name, 'pending');
        expect(await provider.broadcastTransaction('0x01'), isFalse);
        expect(api.sends, 1);
      },
    );
  }

  test(
    'initialize resets prior items, cached totals, errors, and gas quote',
    () async {
      final provider = createProvider();
      addTearDown(provider.dispose);
      provider.addItem('0x${'b2' * 20}', BigInt.from(250));
      await provider.estimateGas();
      expect(provider.gasEstimate, isNull);
      provider.setError('previous transfer failed');
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.initialize(
        chainSymbol: 'POLYGON',
        rpcUrl: 'https://polygon.invalid',
        chainId: 137,
        fromAddress: '0x${'c3' * 20}',
        tokenAddress: '0x${'d4' * 20}',
        tokenSymbol: 'USDC',
        decimals: 6,
      );

      expect(provider.chainSymbol, 'POLYGON');
      expect(provider.fromAddress, '0x${'c3' * 20}');
      expect(provider.tokenSymbol, 'USDC');
      expect(provider.isNativeToken, isFalse);
      expect(provider.state, BatchTransferState.initial);
      expect(provider.items, isEmpty);
      expect(provider.recipientCount, 0);
      expect(provider.totalAmount, BigInt.zero);
      expect(provider.gasEstimate, isNull);
      expect(provider.errorMessage, isNull);
      expect(notifications, 1);
    },
  );

  test(
    'reset clears transfer data and gas quote while retaining the chain',
    () async {
      final provider = createProvider();
      addTearDown(provider.dispose);
      provider.addItem('0x${'b2' * 20}', BigInt.from(250));
      await provider.estimateGas();
      expect(provider.gasEstimate, isNull);
      provider.setError('previous transfer failed');

      provider.reset();

      expect(provider.chainSymbol, 'ETH');
      expect(provider.state, BatchTransferState.initial);
      expect(provider.items, isEmpty);
      expect(provider.recipientCount, 0);
      expect(provider.totalAmount, BigInt.zero);
      expect(provider.gasEstimate, isNull);
      expect(provider.errorMessage, isNull);
    },
  );

  test('addItem updates recipients, state, and cached total amount', () {
    final provider = createProvider();
    addTearDown(provider.dispose);

    provider.addItem('0x${'b2' * 20}', BigInt.from(125), memo: 'invoice');
    provider.addItem('0x${'c3' * 20}', BigInt.from(75));

    expect(provider.state, BatchTransferState.ready);
    expect(provider.recipientCount, 2);
    expect(provider.totalAmount, BigInt.from(200));
    expect(provider.items[0].id, 'item_0');
    expect(provider.items[0].toAddress, '0x${'b2' * 20}');
    expect(provider.items[0].memo, 'invoice');
    expect(provider.items[1].id, 'item_1');
  });

  test(
    'updateItemAmount preserves recipient details and adjusts cached total',
    () {
      final provider = createProvider();
      addTearDown(provider.dispose);
      provider.addItem('0x${'b2' * 20}', BigInt.from(125), memo: 'invoice');
      provider.addItem('0x${'c3' * 20}', BigInt.from(75));
      final updatedItemId = provider.items.first.id;

      provider.updateItemAmount(0, BigInt.from(300));

      expect(provider.recipientCount, 2);
      expect(provider.totalAmount, BigInt.from(375));
      expect(provider.items.first.id, updatedItemId);
      expect(provider.items.first.toAddress, '0x${'b2' * 20}');
      expect(provider.items.first.amount, BigInt.from(300));
      expect(provider.items.first.memo, 'invoice');
    },
  );

  test(
    'removeItem updates count and total and returns to initial when empty',
    () {
      final provider = createProvider();
      addTearDown(provider.dispose);
      provider.addItem('0x${'b2' * 20}', BigInt.from(125));
      provider.addItem('0x${'c3' * 20}', BigInt.from(75));

      provider.removeItem(0);

      expect(provider.state, BatchTransferState.ready);
      expect(provider.recipientCount, 1);
      expect(provider.totalAmount, BigInt.from(75));
      expect(provider.items.single.toAddress, '0x${'c3' * 20}');

      provider.removeItem(0);

      expect(provider.state, BatchTransferState.initial);
      expect(provider.recipientCount, 0);
      expect(provider.totalAmount, BigInt.zero);
    },
  );

  test('invalid item indexes leave items, totals, state, and notifications unchanged', () {
    final provider = createProvider();
    addTearDown(provider.dispose);
    provider.addItem('0x${'b2' * 20}', BigInt.from(125));
    final originalItem = provider.items.single;
    var notifications = 0;
    provider.addListener(() => notifications++);

    provider.removeItem(-1);
    provider.removeItem(1);
    provider.updateItemAmount(-1, BigInt.from(999));
    provider.updateItemAmount(1, BigInt.from(999));

    expect(identical(provider.items.single, originalItem), isTrue);
    expect(provider.state, BatchTransferState.ready);
    expect(provider.recipientCount, 1);
    expect(provider.totalAmount, BigInt.from(125));
    expect(notifications, 0);
  });

  test('clearItems empties recipients, cached total, and error state', () {
    final provider = createProvider();
    addTearDown(provider.dispose);
    provider.addItem('0x${'b2' * 20}', BigInt.from(125));
    provider.setError('previous transfer failed');

    provider.clearItems();

    expect(provider.state, BatchTransferState.initial);
    expect(provider.items, isEmpty);
    expect(provider.recipientCount, 0);
    expect(provider.totalAmount, BigInt.zero);
    expect(provider.errorMessage, isNull);
  });

  test('offline failures never become executable gas estimates', () async {
    final provider = createProvider();
    addTearDown(provider.dispose);
    provider.addItem('0x${'b2' * 20}', BigInt.from(125));

    Future<void> estimateOffline() async {
      await provider.estimateGas();
      expect(provider.state, BatchTransferState.error);
      expect(provider.gasEstimate, isNull);
    }

    await estimateOffline();
    provider.updateItemAmount(0, BigInt.from(200));
    expect(provider.gasEstimate, isNull);

    await estimateOffline();
    provider.addItem('0x${'c3' * 20}', BigInt.from(75));
    expect(provider.gasEstimate, isNull);

    await estimateOffline();
    provider.removeItem(0);
    expect(provider.gasEstimate, isNull);

    await estimateOffline();
    provider.clearItems();
    expect(provider.gasEstimate, isNull);
  });
}
