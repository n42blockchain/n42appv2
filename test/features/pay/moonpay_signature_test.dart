import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/pay/moonpay/moonpay.dart';

void main() {
  group('Moonpay signature request helpers', () {
    test('parses valid signature request payload', () {
      final request = parseMoonpaySignatureRequest(
        '[{"type":"get_moonpay_signature","url":"https://n42.world/pay","mode":"prod"}]',
      );

      expect(request, isNotNull);
      expect(request?.url, 'https://n42.world/pay');
      expect(request?.mode, 'prod');
    });

    test('ignores invalid payloads', () {
      expect(
        parseMoonpaySignatureRequest('{"type":"get_moonpay_signature"}'),
        isNull,
      );
      expect(
        parseMoonpaySignatureRequest(
          '[{"type":"other","url":"https://n42.world/pay","mode":"prod"}]',
        ),
        isNull,
      );
      expect(
        parseMoonpaySignatureRequest(
          '[{"type":"get_moonpay_signature","url":"","mode":"prod"}]',
        ),
        isNull,
      );
    });

    test('resolves signature without requiring a selected coin model', () async {
      var callCount = 0;

      final signature = await resolveMoonpaySignatureRequest(
        '[{"type":"get_moonpay_signature","url":"https://n42.world/pay","mode":"test"}]',
        signUrl: (url, mode) async {
          callCount++;
          return '$mode:$url';
        },
      );

      expect(callCount, 1);
      expect(signature, 'test:https://n42.world/pay');
    });
  });
}
