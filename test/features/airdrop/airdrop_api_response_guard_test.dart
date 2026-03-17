import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/airdrop/api/airdrop_api.dart';

void main() {
  group('hasSuccessfulApiPayload', () {
    test('accepts payloads with data and no explicit code', () {
      expect(
        hasSuccessfulApiPayload({
          'data': {'ok': true},
        }),
        isTrue,
      );
    });

    test('accepts payloads with HTTP-style success code', () {
      expect(
        hasSuccessfulApiPayload({
          'code': 200,
          'data': {'ok': true},
        }),
        isTrue,
      );
    });

    test('rejects empty payloads that previously looked successful', () {
      expect(hasSuccessfulApiPayload({'code': 200, 'data': null}), isFalse);
      expect(
        hasSuccessfulApiPayload({
          'code': 500,
          'data': {'ok': true},
        }),
        isFalse,
      );
    });
  });
}
