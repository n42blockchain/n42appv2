import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_subdomain_sheet_utils.dart';

void main() {
  test('canDismissEnsSubdomainSheet blocks dismiss while creating', () {
    expect(canDismissEnsSubdomainSheet(true), isFalse);
    expect(canDismissEnsSubdomainSheet(false), isTrue);
  });
}
