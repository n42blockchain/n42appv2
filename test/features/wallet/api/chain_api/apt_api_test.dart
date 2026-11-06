import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../../native/aptos_reference_vectors.dart' as native;
import '../../../../native/aptos_coin_reference_vectors.dart' as coin;
import '../../../../native/aptos_fa_reference_vectors.dart' as fa;

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';

void main() {
  for (final vector in [
    ...native.aptosReferenceVectors,
    ...coin.aptosReferenceVectors,
    ...fa.aptosReferenceVectors,
  ]) {
    test(
      'signed transaction hash matches independent vector ${vector['transactionHash']}',
      () {
        expect(
          AptApi.transactionHash(vector['signed'] as String),
          vector['transactionHash'],
        );
      },
    );
  }
  test('unrelated but well-formed RPC hash is rejected', () async {
    final api = AptApi(
      submit: (_, _, {required header, required enableRetry}) async => {
        'hash': '0x${'ab' * 32}',
      },
    );
    expect((await api.sendTxHash('00ff')).error, isTrue);
  });
  group('expired unexecuted transaction', () {
    for (final scenario in [
      'expired',
      'equal time',
      'before expiry',
      'consumed',
      'behind sequence',
      'wrong chain',
      'missing version',
      'offline',
    ]) {
      test(scenario, () async {
        final reads = <String>[];
        final api = AptApi(
          read: (url) async {
            reads.add(url);
            if (scenario == 'offline') throw const SocketException('offline');
            if (url.endsWith('/v1/')) {
              return {
                'chain_id': scenario == 'wrong chain' ? 2 : 1,
                if (scenario != 'missing version')
                  'ledger_version': '9007199254740993',
                'ledger_timestamp': scenario == 'equal time'
                    ? '10000000'
                    : scenario == 'before expiry'
                    ? '9000000'
                    : '11000000',
              };
            }
            expect(
              Uri.parse(url).queryParameters['ledger_version'],
              '9007199254740993',
            );
            return {
              'sequence_number': scenario == 'consumed'
                  ? '8'
                  : scenario == 'behind sequence'
                  ? '6'
                  : '7',
            };
          },
        );
        expect(
          await api.isExpiredWithoutExecution(
            sender: '0x1',
            sequence: BigInt.from(7),
            expirationSeconds: BigInt.from(10),
            chainId: 1,
          ),
          scenario == 'expired',
        );
        if ([
          'equal time',
          'before expiry',
          'wrong chain',
          'missing version',
          'offline',
        ].contains(scenario)) {
          expect(reads, hasLength(1));
        }
      });
    }
  });
  group('receipt recovery identity', () {
    final hash = '0x${'ab' * 32}';
    final sequence = BigInt.parse('9007199254740993');
    Map<String, dynamic> receipt() => {
      'type': 'user_transaction',
      'hash': hash,
      'sender': '0x${'0' * 63}1',
      'sequence_number': sequence.toString(),
      'version': '18446744073709551615',
      'success': true,
    };
    Future<dynamic> query(Map<String, dynamic> data, {int chain = 2}) =>
        AptApi(
          isTest: true,
          read: (url) async => url.endsWith('/v1/')
              ? {'chain_id': chain, 'ledger_timestamp': '1000000'}
              : data,
        ).getTransactionReceipt(
          hash: hash,
          sender: '0x1',
          sequence: sequence,
          chainId: 2,
        );

    for (final success in [true, false]) {
      test(
        'terminal execution success=$success preserves exact version',
        () async {
          final result = await query(receipt()..['success'] = success);
          expect(result.error, false);
          final value = result.data as AptTransactionReceipt;
          expect(value.hash, hash);
          expect(
            value.status,
            success
                ? AptTransactionStatus.succeeded
                : AptTransactionStatus.failed,
          );
          expect(value.version, BigInt.parse('18446744073709551615'));
        },
      );
    }
    test('pending stays pending', () async {
      final data = receipt()
        ..['type'] = 'pending_transaction'
        ..remove('success')
        ..remove('version');
      final result = await query(data);
      expect(result.error, false);
      expect(
        (result.data as AptTransactionReceipt).status,
        AptTransactionStatus.pending,
      );
      expect((result.data as AptTransactionReceipt).version, isNull);
    });
    for (final field in <String, dynamic>{
      'hash': '0x${'cd' * 32}',
      'sender': '0x2',
      'sequence_number': '9007199254740992',
      'type': 'block_metadata_transaction',
      'success': 'true',
      'version': 1.5,
    }.entries) {
      test('reject mismatched or malformed ${field.key}', () async {
        expect((await query(receipt()..[field.key] = field.value)).error, true);
      });
    }
    test('wrong chain rejects before transaction lookup', () async {
      var calls = 0;
      final api = AptApi(
        read: (_) async {
          calls++;
          return {'chain_id': 1, 'ledger_timestamp': '1000000'};
        },
      );
      expect(
        (await api.getTransactionReceipt(
          hash: hash,
          sender: '0x1',
          sequence: sequence,
          chainId: 2,
        )).error,
        true,
      );
      expect(calls, 1);
    });
    test('pending cannot carry committed fields', () async {
      expect(
        (await query(receipt()..['type'] = 'pending_transaction')).error,
        true,
      );
    });
    test('not found and transport failures remain unknown', () async {
      for (final response in [
        null,
        <String, dynamic>{'error_code': 'transaction_not_found'},
      ]) {
        final api = AptApi(
          read: (url) async => url.endsWith('/v1/')
              ? {'chain_id': 2, 'ledger_timestamp': '1000000'}
              : response,
        );
        expect(
          (await api.getTransactionReceipt(
            hash: hash,
            sender: '0x1',
            sequence: sequence,
            chainId: 2,
          )).error,
          true,
        );
      }
      final api = AptApi(read: (_) async => throw TimeoutException('offline'));
      expect(
        (await api.getTransactionReceipt(
          hash: hash,
          sender: '0x1',
          sequence: sequence,
          chainId: 2,
        )).error,
        true,
      );
    });
  });
  for (final asset in [
    ('', '', '0x1::aptos_coin::AptosCoin'),
    ('0x42::usd_coin::USDC', '', '0x42::usd_coin::USDC'),
    ('0xabc', '', '0xabc'),
    ('0x42', 'USDC', '0x42::celer_coin_manager::USDC'),
    (
      '0x42::pool::Share<0x1::aptos_coin::AptosCoin>',
      '',
      '0x42::pool::Share<0x1::aptos_coin::AptosCoin>',
    ),
  ]) {
    for (final isTest in [false, true]) {
      test('balance uses asset tag ${asset.$3} testnet=$isTest', () async {
        var calls = 0;
        final api = AptApi(
          isTest: isTest,
          read: (endpoint) async {
            calls++;
            final uri = Uri.parse(endpoint);
            expect(uri.host, contains(isTest ? 'testnet' : 'mainnet'));
            expect(uri.pathSegments, [
              'v1',
              'accounts',
              '0x1',
              'balance',
              asset.$3,
            ]);
            expect(uri.query, isEmpty);
            expect(uri.fragment, isEmpty);
            return '123456789';
          },
        );
        final result = await api.getBalance(
          '0x1',
          contract: asset.$1,
          tokenName: asset.$2,
        );
        expect(result.error, false);
        expect(result.data, BigInt.from(123456789));
        expect(calls, 1);
      });
    }
  }
  for (final value in ['18446744073709551615', '9007199254740993', '0', 42]) {
    test('REST uint64 stays exact: $value', () async {
      final api = AptApi(
        read: (url) async {
          if (url.endsWith('estimate_gas_price')) {
            return {'gas_estimate': value};
          }
          if (url.endsWith('accounts/0x1')) return {'sequence_number': value};
          if (url.contains('/balance/')) return value;
          expect(url, endsWith('/v1/'));
          return {'ledger_timestamp': value};
        },
      );
      for (final response in [
        await api.getBalance('0x1'),
        await api.getGasPrice(),
        await api.getAccountInfo('0x1'),
        await api.getServiceInfo(),
      ]) {
        expect(response.error, false);
        expect(response.data, BigInt.parse(value.toString()));
      }
    });
  }
  for (final value in [
    null,
    true,
    1.5,
    -1,
    '',
    '01',
    '+1',
    '1e3',
    '18446744073709551616',
  ]) {
    test('invalid REST uint64 fails: $value', () async {
      final api = AptApi(
        read: (_) async => {
          'sequence_number': value,
          'ledger_timestamp': value,
          'gas_estimate': value,
        },
      );
      expect((await api.getAccountInfo('0x1')).error, true);
      expect((await api.getServiceInfo()).error, true);
      expect((await api.getGasPrice()).error, true);
    });
  }
  final hash = AptApi.transactionHash('00ff');
  for (final encoded in ['00aBff', '0x00aBff', '0X00aBff']) {
    for (final isTest in [false, true]) {
      test('native hex $encoded sends bytes on testnet=$isTest', () async {
        var calls = 0;
        final api = AptApi(
          isTest: isTest,
          submit: (url, bytes, {required header, required enableRetry}) async {
            calls++;
            expect(url, contains(isTest ? 'testnet' : 'mainnet'));
            expect(url, endsWith('/transactions'));
            expect(bytes, [0, 171, 255]);
            expect(
              header['content-type'],
              'application/x.aptos.signed_transaction+bcs',
            );
            expect(enableRetry, isFalse);
            return {
              'type': 'pending_transaction',
              'hash': AptApi.transactionHash(encoded)
                  .toUpperCase()
                  .replaceFirst('0X', '0x'),
            };
          },
        );
        final result = await api.sendTxHash(encoded);
        expect(result.error, isFalse);
        expect(result.data, AptApi.transactionHash(encoded));
        expect(calls, 1);
      });
    }
  }
  for (final invalid in ['', '0x', '0x0', 'zz', ' aa', 'aa\n', '0x0x12']) {
    test('invalid hex $invalid never dispatches', () async {
      var calls = 0;
      final api = AptApi(
        submit: (_, _, {required header, required enableRetry}) async {
          calls++;
          return {'hash': hash};
        },
      );
      expect((await api.sendTxHash(invalid)).error, isTrue);
      expect(calls, 0);
    });
  }
  for (final response in [
    null,
    <String, dynamic>{},
    {'hash': ''},
    {'hash': 42},
    {'hash': '0x12'},
    {'hash': '$hash\n'},
    {'hash': hash, 'success': false},
    {'hash': hash, 'success': 'true'},
  ]) {
    test('invalid response $response cannot report success', () async {
      final api = AptApi(
        submit: (_, _, {required header, required enableRetry}) async =>
            response,
      );
      expect((await api.sendTxHash('00ff')).error, isTrue);
    });
  }
  test(
    'committed successful response preserves its transaction hash',
    () async {
      final api = AptApi(
        submit: (_, _, {required header, required enableRetry}) async => {
          'hash': hash,
          'success': true,
        },
      );
      final response = await api.sendTxHash('00ff');
      expect(response.error, isFalse);
      expect(response.data, hash);
    },
  );
  test('transport timeout is not retried or reported as success', () async {
    var calls = 0;
    final api = AptApi(
      submit: (_, _, {required header, required enableRetry}) async {
        calls++;
        expect(enableRetry, isFalse);
        throw TimeoutException('fixture');
      },
    );
    expect((await api.sendTxHash('00ff')).error, isTrue);
    expect(calls, 1);
  });
  test('real HTTP transport preserves the BCS bytes', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final received = Completer<List<int>>();
    server.listen((request) async {
      final bytes = await request.fold<List<int>>(
        [],
        (all, chunk) => all..addAll(chunk),
      );
      expect(
        request.headers.contentType?.mimeType,
        'application/x.aptos.signed_transaction+bcs',
      );
      received.complete(bytes);
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'hash': AptApi.transactionHash('00017f80ff')}),
      );
      await request.response.close();
    });
    final api = AptApi(
      submit: (_, bytes, {required header, required enableRetry}) =>
          BaseApi.requestEmptyH.post(
            'http://127.0.0.1:${server.port}/transactions',
            params: {},
            data: bytes,
            header: header,
            enableRetry: enableRetry,
          ),
    );
    final result = await api.sendTxHash('0x00017f80ff');
    expect(result.error, isFalse);
    expect(await received.future.timeout(const Duration(seconds: 5)), [
      0,
      1,
      127,
      128,
      255,
    ]);
  });
}
