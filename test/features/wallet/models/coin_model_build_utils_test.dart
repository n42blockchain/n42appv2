import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model_build_utils.dart';

void main() {
  test(
    'resolveCoinModelDerivation keeps addrType separate from derivation path',
    () {
      final derivation = resolveCoinModelDerivation(
        coin: {
          'path': {'legacy': "m/44'/60'/0'/0/0"},
        },
        addrType: 'legacy',
        pathIndex: 3,
      );

      expect(derivation.addressType, 'legacy');
      expect(derivation.path, "m/44'/60'/0'/0/3");
    },
  );

  test('resolveCoinModelDerivation throws when addrType path is missing', () {
    expect(
      () => resolveCoinModelDerivation(
        coin: {
          'path': {'segwit': "m/84'/0'/0'/0/0"},
        },
        addrType: 'legacy',
        pathIndex: 0,
      ),
      throwsFormatException,
    );
  });
}
