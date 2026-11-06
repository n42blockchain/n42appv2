import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Api extends AdaApi {
  _Api({super.projectId = 'fixture'});
  dynamic body;
  bool error = false;
  bool throws = false;
  int calls = 0;
  String? hash;
  bool? testnet;
  Completer<void>? gate;
  @override
  Future<MessageModel> getTransaction(
    String txHash, {
    bool isTest = false,
  }) async {
    calls++;
    hash = txHash;
    testnet = isTest;
    await gate?.future;
    if (throws) throw TimeoutException('fixture');
    return (error ? MessageModel.error() : MessageModel())..data = body;
  }
}

void main() {
  TransationRecordModel record({int network = 0}) => TransationRecordModel()
    ..coin = {'blockchainType': 'Cardano', 'coinType': 'ADA'}
    ..from1 = 'addr_fixture'
    ..txHash = 'ab' * 32
    ..isTest = network;
  Map<String, dynamic> body() => {
    'hash': 'ab' * 32,
    'block': 'cd' * 32,
    'block_height': 123,
    'valid_contract': true,
  };
  for (final network in [0, 1]) {
    for (final successful in [true, false]) {
      test('included receipt network=$network success=$successful', () async {
        final api = _Api()..body = (body()..['valid_contract'] = successful);
        expect(
          await TransactionStateResolver(adaApi: api)
              .resolveState(record(network: network)),
          successful ? 1 : 2,
        );
        expect(api.hash, 'ab' * 32);
        expect(api.testnet, network == 1);
      });
    }
  }
  for (final value in [
    null,
    {},
    [],
    'missing',
    body()..['hash'] = 'cd' * 32,
    body()..['block'] = 'addr_other',
    body()..remove('valid_contract'),
    body()..['valid_contract'] = 'true',
    body()..['block_height'] = -1,
    body()..['block_height'] = 1.5,
    body()..['block_height'] = '123',
    body()..remove('block'),
  ]) {
    test('unverified response $value stays unknown', () async {
      final api = _Api()..body = value;
      final item = record();
      expect(
        await TransactionStateResolver(adaApi: api).resolveState(item),
        -1,
      );
      expect(item.state, 0);
    });
  }
  for (final throws in [true, false]) {
    test('RPC failure throws=$throws stays unknown', () async {
      final api = _Api()
        ..throws = throws
        ..error = !throws
        ..body = body();
      expect(
        await TransactionStateResolver(adaApi: api).resolveState(record()),
        -1,
      );
      expect(api.calls, 1);
    });
  }
  test('invalid local identity does not query', () async {
    final api = _Api();
    final resolver = TransactionStateResolver(adaApi: api);
    expect(await resolver.resolveState(record()..txHash = 'bad'), -1);
    expect(await resolver.resolveState(record()..from1 = ''), -1);
    expect(await resolver.resolveState(record(network: 2)), -1);
    expect(api.calls, 0);
  });
  test('missing project configuration does not query', () async {
    final api = _Api(projectId: '');
    expect(
      await TransactionStateResolver(adaApi: api).resolveState(record()),
      -1,
    );
    expect(api.calls, 0);
  });
  for (final field in [
    'hash',
    'sender',
    'network',
    'owner',
    'wallet',
    'chain',
  ]) {
    test('record $field changed during lookup is not resolved', () async {
      final api = _Api()
        ..body = body()
        ..gate = Completer<void>();
      final item = record();
      final pending = TransactionStateResolver(adaApi: api).resolveState(item);
      if (field == 'hash') item.txHash = 'cd' * 32;
      if (field == 'sender') item.from1 = 'addr_other';
      if (field == 'network') item.isTest = 1;
      if (field == 'owner') item.userUuid = 'changed';
      if (field == 'wallet') item.walletIndex = 4;
      if (field == 'chain') item.coinId = 99;
      api.gate!.complete();
      expect(await pending, -1);
    });
  }
}
