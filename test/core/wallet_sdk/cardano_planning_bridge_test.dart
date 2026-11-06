import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('trustdart');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  Map<String, dynamic> input() => {
    'utxos': [
      {
        'txHash': 'ab' * 32,
        'outputIndex': 0,
        'amount': '10000000',
        'address': 'addr_owner',
      },
    ],
    'ttl': '123456',
    'toAddress': 'addr_recipient',
    'changeAddress': 'addr_owner',
    'amount': '2000000',
    'useMaxAmount': false,
  };
  test('planning sends only snapshotted public transaction data', () async {
    final gate = Completer<void>();
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      await gate.future;
      return {
        'amount': '2000000',
        'fee': '200000',
        'change': '7800000',
        'available': '10000000',
      };
    });
    final request = input();
    final result = Trustdart().planCardanoTransaction(request);
    (request['utxos'] as List).first['amount'] = '1';
    request['amount'] = '1';
    gate.complete();
    expect((await result)['fee'], '200000');
    expect(calls, hasLength(1));
    expect(calls.single.method, 'planCardanoTransaction');
    expect(calls.single.arguments, {'txData': input()});
  });
  test(
    'credentials and unsupported fields never cross the planning bridge',
    () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (_) async {
        calls++;
        return {};
      });
      for (final key in ['mnemonic', 'pk', 'privateKey', 'returnMetadata']) {
        await expectLater(
          Trustdart().planCardanoTransaction({...input(), key: 'forbidden'}),
          throwsArgumentError,
        );
      }
      expect(calls, 0);
    },
  );
  test('missing planner and null output are explicit failures', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    await expectLater(
      Trustdart().planCardanoTransaction(input()),
      throwsStateError,
    );
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'invalid_cardano_plan'),
    );
    await expectLater(
      Trustdart().planCardanoTransaction(input()),
      throwsA(isA<PlatformException>()),
    );
  });
}
