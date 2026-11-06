import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/egld_api.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';

void main() {
  TransationRecordModel record({int network = 0}) => TransationRecordModel()
    ..coin = {'blockchainType': 'MultiversX', 'coinType': 'EGLD'}
    ..from1 = 'erd1sender'
    ..to1 = 'erd1receiver'
    ..price = BigInt.from(123)
    ..txHash = 'ab' * 32
    ..isTest = network;
  Map<String, dynamic> body() => {
    'txHash': 'ab' * 32,
    'sender': 'erd1sender',
    'receiver': 'erd1receiver',
    'value': '123',
    'status': 'success',
    'miniBlockHash': 'cd' * 32,
    'timestamp': 123,
  };
  for (final network in [0, 1]) {
    for (final status in ['success', 'pending', 'fail', 'invalid']) {
      test('$status receipt on network $network', () async {
        final api = EgldApi(
          get: (url) async {
            expect(
              url,
              '${network == 0 ? 'https://api.multiversx.com' : 'https://testnet-api.multiversx.com'}/transactions/${'ab' * 32}',
            );
            return body()..['status'] = status;
          },
        );
        expect(
          await TransactionStateResolver(egldApi: api)
              .resolveState(record(network: network)),
          status == 'success'
              ? 1
              : status == 'pending'
              ? 0
              : 2,
        );
      });
    }
  }
  final invalid = [
    null,
    [],
    {},
    'error',
    body()..['txHash'] = 'ef' * 32,
    body()..['sender'] = 'other',
    body()..['receiver'] = 'other',
    body()..['value'] = '124',
    body()..['value'] = 123,
    body()..['status'] = 'unknown',
    body()..remove('status'),
    body()..['miniBlockHash'] = 'bad',
    body()..remove('miniBlockHash'),
    body()..['timestamp'] = 0,
    body()..['timestamp'] = '123',
    body()
      ..['status'] = 'invalid'
      ..remove('miniBlockHash'),
  ];
  for (var i = 0; i < invalid.length; i++) {
    test('unverified response $i remains unresolved', () async {
      final item = record();
      expect(
        await TransactionStateResolver(
          egldApi: EgldApi(get: (_) async => invalid[i]),
        ).resolveState(item),
        -1,
      );
      expect(item.state, 0);
    });
  }
  test('timeout stays unresolved', () async {
    expect(
      await TransactionStateResolver(
        egldApi: EgldApi(get: (_) async => throw TimeoutException('offline')),
      ).resolveState(record()),
      -1,
    );
  });
  for (final field in [
    'hash',
    'network',
    'owner',
    'wallet',
    'coin',
    'sender',
    'receiver',
    'amount',
    'contract',
  ]) {
    test('late receipt rejects changed $field', () async {
      final gate = Completer<dynamic>();
      final item = record();
      final pending = TransactionStateResolver(
        egldApi: EgldApi(get: (_) => gate.future),
      ).resolveState(item);
      switch (field) {
        case 'hash':
          item.txHash = 'ef' * 32;
        case 'network':
          item.isTest = 1;
        case 'owner':
          item.userUuid = 'other';
        case 'wallet':
          item.walletIndex++;
        case 'coin':
          item.coinId++;
        case 'sender':
          item.from1 = 'other';
        case 'receiver':
          item.to1 = 'other';
        case 'amount':
          item.price += BigInt.one;
        case 'contract':
          item.contract = 'other';
      }
      gate.complete(body());
      expect(await pending, -1);
    });
  }
  test('invalid local identity never queries', () async {
    final api = EgldApi(get: (_) async => fail('must not query'));
    for (final item in [
      record()..txHash = '../bad',
      record()..isTest = 2,
      record()..from1 = '',
      record()..to1 = '',
      record()..price = BigInt.zero,
      record()..contract = 'token',
    ]) {
      expect(
        await TransactionStateResolver(egldApi: api).resolveState(item),
        -1,
      );
    }
    expect(
      () => api.getTransaction('../bad', isTest: false),
      throwsFormatException,
    );
  });
}
