import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/transaction_api.dart';

void main() {
  group('explorerStartFromPage', () {
    test('maps page-based pagination to upstream start offsets', () {
      expect(explorerStartFromPage(1, 20), 0);
      expect(explorerStartFromPage(2, 20), 20);
      expect(explorerStartFromPage(3, 50), 100);
    });

    test('normalizes invalid page and page size values', () {
      expect(explorerStartFromPage(null, null), 0);
      expect(explorerStartFromPage(0, 20), 0);
      expect(explorerStartFromPage(2, 0), 20);
    });
  });
}
