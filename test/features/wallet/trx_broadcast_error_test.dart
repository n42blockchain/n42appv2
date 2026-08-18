import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';

void main() {
  group('TrxApi.trxBroadcastError', () {
    test('success response ({result:true, txid}) → null', () {
      expect(
        TrxApi.trxBroadcastError({'result': true, 'txid': 'abc123'}),
        isNull,
      );
    });

    test('rejection with error code but echoed txid → error (no false success)',
        () {
      // The historical false-success case: SIGERROR / TAPOS with a txid and
      // no `result` key.
      final err = TrxApi.trxBroadcastError({
        'code': 'SIGERROR',
        'txid': 'abc123',
        'message': 'validate signature error',
      });
      expect(err, isNotNull);
    });

    test('result:false → error', () {
      expect(
        TrxApi.trxBroadcastError({'result': false, 'code': 'TAPOS_ERROR'}),
        isNotNull,
      );
    });

    test('hex-encoded message is decoded to human text', () {
      // "bad" = 0x626164
      final err = TrxApi.trxBroadcastError({
        'code': 'CONTRACT_VALIDATE_ERROR',
        'message': '626164',
      });
      expect(err, 'bad');
    });

    test('non-map response → error', () {
      expect(TrxApi.trxBroadcastError('oops'), isNotNull);
      expect(TrxApi.trxBroadcastError(null), isNotNull);
    });

    test('code SUCCESS is not treated as error', () {
      expect(
        TrxApi.trxBroadcastError({'code': 'SUCCESS', 'txid': 'abc'}),
        isNull,
      );
    });
  });
}
