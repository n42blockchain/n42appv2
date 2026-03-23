import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/price_alert_sheet_utils.dart';

void main() {
  test('canDismissPriceAlertSheet blocks pop while saving', () {
    expect(canDismissPriceAlertSheet(true), isFalse);
    expect(canDismissPriceAlertSheet(false), isTrue);
  });
}
