import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/wallet.dart';

void main() {
  test('wallet barrel exports feature ChainType values', () {
    expect(ChainType.values.contains(ChainType.filecoin), isTrue);
    expect(ChainType.values.contains(ChainType.cosmos), isTrue);
    expect(ChainType.values.contains(ChainType.ton), isTrue);
  });
}
