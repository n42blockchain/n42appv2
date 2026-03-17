import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/keystore_flow_utils.dart';

void main() {
  group('resolveSelectedImportCoinType', () {
    test('prefers baseInfo.coinType when present', () {
      final coinType = resolveSelectedImportCoinType({
        'baseInfo': {'coinType': 'ETH', 'mKey': 'N'},
      });

      expect(coinType, 'ETH');
    });

    test('falls back to mKey then default N', () {
      expect(
        resolveSelectedImportCoinType({
          'baseInfo': {'mKey': 'SOL'},
        }),
        'SOL',
      );

      expect(resolveSelectedImportCoinType(const {}), CoinType.N.name);
    });
  });

  group('extractImportedWalletAddress', () {
    test('supports string addresses returned by native keystore import', () {
      final address = extractImportedWalletAddress({'address': ' 0xabc123 '});

      expect(address, '0xabc123');
    });

    test('falls back to first non-empty address variant', () {
      final address = extractImportedWalletAddress({
        'addressType': 'legacy',
        'address': {'legacy': '', 'segwit': ' bc1qexample '},
      });

      expect(address, 'bc1qexample');
    });
  });

  group('normalizeImportedPrivateKey', () {
    test('strips newlines and outer whitespace', () {
      expect(normalizeImportedPrivateKey('  abc\\n123\\n '), 'abc\\n123\\n');
    });
  });
}
