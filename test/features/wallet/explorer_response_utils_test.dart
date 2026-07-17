import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/transaction/explorer_response_utils.dart';

void main() {
  group('normalizeExplorerPayload', () {
    test('decodes a JSON response delivered as text', () {
      expect(normalizeExplorerPayload('{"result":[]}'), {'result': []});
    });

    test('returns null for a non-JSON explorer error page', () {
      expect(normalizeExplorerPayload('rate limit exceeded'), isNull);
    });
  });

  group('extractExplorerItems', () {
    test('flattens TokenView txlist payloads with nested txs', () {
      final items = extractExplorerItems({
        'code': 1,
        'data': [
          {
            'address': '0xabc',
            'txs': [
              {'txid': '0x1'},
              {'txid': '0x2'},
            ],
          },
        ],
      });

      expect(items.length, 2);
      expect(items.first['txid'], '0x1');
      expect(items.last['txid'], '0x2');
    });

    test('returns TokenView token transfer payloads directly', () {
      final items = extractExplorerItems({
        'code': 1,
        'data': [
          {'txid': '0x1', 'tokenAddr': '0xtoken'},
        ],
      });

      expect(items, hasLength(1));
      expect(items.first['tokenAddr'], '0xtoken');
    });

    test('keeps etherscan-style result lists unchanged', () {
      final items = extractExplorerItems({
        'status': '1',
        'result': [
          {'hash': '0x1'},
        ],
      });

      expect(items, hasLength(1));
      expect(items.first['hash'], '0x1');
    });

    test('returns an empty list for valid but empty explorer payloads', () {
      final items = extractExplorerItems({
        'status': '0',
        'message': 'No transactions found',
        'result': <Map<String, dynamic>>[],
      });

      expect(items, isEmpty);
    });
  });

  group('explorer helpers', () {
    test('detects explorer payload containers even when the list is empty', () {
      expect(
        hasExplorerItemContainer({
          'status': '0',
          'result': <Map<String, dynamic>>[],
        }),
        isTrue,
      );
      expect(
        hasExplorerItemContainer({'code': 1, 'data': <Map<String, dynamic>>[]}),
        isTrue,
      );
    });

    test('returns the first matching non-null key as a string', () {
      final value = explorerString(
        {'block_no': 123, 'blockNumber': '456'},
        const ['blockNumber', 'block_no'],
      );

      expect(value, '456');
    });

    test('converts numeric values to strings', () {
      final value = explorerString(
        {'tokenDecimals': 18},
        const ['tokenDecimals'],
      );

      expect(value, '18');
    });

    test(
      'parseExplorerAmount keeps integer smallest-unit values unchanged',
      () {
        expect(parseExplorerAmount('1234500', 6), BigInt.from(1234500));
      },
    );

    test(
      'parseExplorerAmount converts decimal display values to smallest units',
      () {
        expect(
          parseExplorerAmount('0.2', 18),
          BigInt.parse('200000000000000000'),
        );
      },
    );
  });
}
