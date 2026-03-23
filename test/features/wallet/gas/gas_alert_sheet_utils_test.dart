import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_alert_sheet_utils.dart';

void main() {
  test('canDismissGasAlertSheet blocks dismiss while saving', () {
    expect(canDismissGasAlertSheet(true), isFalse);
    expect(canDismissGasAlertSheet(false), isTrue);
  });
}
