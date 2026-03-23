import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/address_book_input_utils.dart';

void main() {
  group('normalizeAddressBookInput', () {
    test('strips scheme, transfer prefix, and query params', () {
      expect(
        normalizeAddressBookInput('ton:transfer/UQabc123?amount=1&memo=test'),
        'UQabc123',
      );
      expect(
        normalizeAddressBookInput('ethereum:0xabc123?value=1'),
        '0xabc123',
      );
    });

    test('returns raw trimmed address when no scheme is present', () {
      expect(normalizeAddressBookInput('  0xabc123  '), '0xabc123');
    });
  });

  group('addressBookSelectionFromCoinMap', () {
    test('uses coinType for validation and miniName/name for display', () {
      final selection = addressBookSelectionFromCoinMap({
        'coinType': CoinType.ETH.name,
        'miniName': 'ETH',
        'name': 'Ethereum',
        'icon': 'icon.png',
        'blockchainType': 'Ethereum',
      });

      expect(selection.coinType, CoinType.ETH.name);
      expect(selection.coinName, 'ETH');
      expect(selection.coinFullName, 'Ethereum');
      expect(selection.coinIcon, 'icon.png');
      expect(selection.blockchainType, 'Ethereum');
    });
  });
}
