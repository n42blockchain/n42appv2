import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';

void main() {
  late SolApi api;
  late List<(String, Map<String, dynamic>, bool)> calls;
  dynamic result;
  dynamic error;
  bool throwsRequest = false;
  setUp(() {
    calls = [];
    result = {'value': 12345};
    error = null;
    throwsRequest = false;
    api = SolApi(
      request: (url, body, {required enableRetry}) async {
        calls.add((url, body, enableRetry));
        if (throwsRequest) throw StateError('offline');
        return error != null ? {'error': error} : {'result': result};
      },
    );
  });
  for (final isTest in [true, false]) {
    test(
      'native balance uses selected RPC and returns exact integer $isTest',
      () async {
        result = {'value': '9007199254740993'};
        final mm = await api.getBalance('owner', '', isTest: isTest);
        expect(mm.error, isFalse);
        expect(mm.data, BigInt.parse('9007199254740993'));
        expect(calls.single.$1, contains(isTest ? 'testnet' : 'mainnet'));
        expect(calls.single.$2['method'], 'getBalance');
        expect(calls.single.$2['params'], ['owner']);
        expect(calls.single.$3, isTrue);
      },
    );
    test('fee and broadcast preserve the selected network $isTest', () async {
      final fee = await api.getFeeForMessage('base64-message', isTest: isTest);
      expect(fee.data, BigInt.from(12345));
      expect(calls.single.$2['params'], ['base64-message']);
      result = 'signature';
      expect(
        (await api.sendTransaction('base58-tx', isTest: isTest)).data,
        'signature',
      );
      expect(calls.last.$2['params'], [
        'base58-tx',
        {'encoding': 'base58'},
      ]);
      expect(calls.last.$3, isFalse);
      expect(
        calls.map((c) => c.$1),
        everyElement(contains(isTest ? 'testnet' : 'mainnet')),
      );
    });
  }
  for (final value in [null, -1, 'invalid', 1.5]) {
    test('invalid native value $value returns error', () async {
      result = {'value': value};
      expect((await api.getBalance('owner', '')).error, isTrue);
    });
    test('unavailable or invalid fee $value returns error', () async {
      result = {'value': value};
      expect((await api.getFeeForMessage('message')).error, isTrue);
    });
  }
  test(
    'spendable SPL balance queries the specific associated account',
    () async {
      result = {
        'value': {'amount': '1234567890123456789'},
      };
      final mm = await api.getTokenAccountBalance('ata', isTest: true);
      expect(mm.data, BigInt.parse('1234567890123456789'));
      expect(calls.single.$2['method'], 'getTokenAccountBalance');
      expect(calls.single.$2['params'], ['ata']);
      expect(calls.single.$1, contains('testnet'));
    },
  );
  test(
    'rent quote requests the legacy token account size on testnet',
    () async {
      result = 2039280;
      expect(
        (await api.getTokenAccountRent(isTest: true)).data,
        BigInt.from(2039280),
      );
      expect(calls.single.$2['method'], 'getMinimumBalanceForRentExemption');
      expect(calls.single.$2['params'], [165]);
      expect(calls.single.$1, contains('testnet'));
    },
  );
  test('malformed token balance and rent fail closed', () async {
    result = {
      'value': {'amount': 'invalid'},
    };
    expect((await api.getTokenAccountBalance('ata')).error, isTrue);
    result = null;
    expect((await api.getTokenAccountRent()).error, isTrue);
  });
  test('token balance and rent RPC failures reach caller', () async {
    error = {'message': 'unavailable'};
    expect((await api.getTokenAccountBalance('ata')).error, isTrue);
    expect((await api.getTokenAccountRent()).error, isTrue);
  });
  test('missing associated account returns null without throwing', () async {
    result = {'value': null};
    final mm = await api.getAccountInfo('ata', isTest: true);
    expect(mm.error, isFalse);
    expect(mm.data, isNull);
    expect(calls.single.$2['params'], [
      'ata',
      {'encoding': 'base64'},
    ]);
  });
  test('existing associated account returns data', () async {
    result = {
      'value': {
        'data': ['serialized', 'base64'],
      },
    };
    expect((await api.getAccountInfo('ata')).data, ['serialized', 'base64']);
  });
  test('blockhash extracts nested value and keeps testnet', () async {
    result = {
      'value': {'blockhash': 'recent'},
    };
    expect((await api.getLatestBlockhash(isTest: true)).data, 'recent');
    expect(calls.single.$1, contains('testnet'));
  });
  test('token balance preserves exact decimal amount', () async {
    result = {
      'value': [
        {
          'account': {
            'data': {
              'parsed': {
                'info': {
                  'tokenAmount': {'amount': '9007199254740993'},
                },
              },
            },
          },
        },
      ],
    };
    final mm = await api.getBalance('owner', 'mint', isTest: true);
    expect(mm.data, BigInt.parse('9007199254740993'));
    expect(calls.single.$2['params'], [
      'owner',
      {'mint': 'mint'},
      {'encoding': 'jsonParsed'},
    ]);
  });
  test('no token account returns zero', () async {
    result = {'value': []};
    expect((await api.getBalance('owner', 'mint')).data, BigInt.zero);
  });
  test('simulation requests signature verification', () async {
    result = {
      'value': {'err': null},
    };
    expect((await api.simulateTransaction('signed', isTest: true)).data, {
      'err': null,
    });
    expect(calls.single.$2['params'], [
      'signed',
      {'sigVerify': true},
    ]);
  });
  test('nested RPC error message reaches caller', () async {
    error = {'code': -32002, 'message': 'insufficient funds'};
    final mm = await api.sendTransaction('signed', isTest: true);
    expect(mm.error, isTrue);
    expect(mm.data.toString(), contains('insufficient funds'));
    expect(calls, hasLength(1));
  });
  test('transport exception becomes a failed result without retry', () async {
    throwsRequest = true;
    final mm = await api.sendTransaction('signed', isTest: true);
    expect(mm.error, isTrue);
    expect(calls.single.$3, isFalse);
    expect(calls, hasLength(1));
  });
  test('RPC failure bypasses all successful response decoders', () async {
    error = {'message': 'unavailable'};
    for (final mm in [
      await api.getAccountInfo('ata'),
      await api.getBalance('owner', ''),
      await api.getBalance('owner', 'mint'),
      await api.getLatestBlockhash(),
      await api.getFeeForMessage('message'),
      await api.simulateTransaction('signed'),
    ]) {
      expect(mm.error, isTrue);
      expect(mm.data.toString(), contains('unavailable'));
    }
  });
}
