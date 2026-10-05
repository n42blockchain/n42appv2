import 'dart:io';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  setUp(() {
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
    'initialize resets prior items, cached totals, errors, and gas quote',
    () async {
      final provider = createProvider();
      addTearDown(provider.dispose);
      provider.addItem('0x${'b2' * 20}', BigInt.from(250));
      await provider.estimateGas();
      expect(provider.gasEstimate, isNotNull);
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
      expect(provider.gasEstimate, isNotNull);
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

  test(
    'invalid item indexes leave items, totals, state, and notifications unchanged',
    () {
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
    },
  );

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

  test('item changes invalidate an offline gas estimate', () async {
    final provider = createProvider();
    addTearDown(provider.dispose);
    provider.addItem('0x${'b2' * 20}', BigInt.from(125));

    Future<void> estimateOffline() async {
      await provider.estimateGas();
      expect(provider.state, BatchTransferState.gasEstimated);
      expect(provider.gasEstimate, isNotNull);
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
