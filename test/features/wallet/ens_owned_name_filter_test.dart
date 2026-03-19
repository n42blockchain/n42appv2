import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_chain_config.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_owned_name_filter.dart';
import 'package:n42_wallet/features/wallet/services/ens_models.dart';

OwnedEns _ownedEns(String name) {
  return OwnedEns(name: name, ownerAddress: '0x123', expiresAt: DateTime(2030));
}

void main() {
  group('filterOwnedEnsByChain', () {
    final ownedNames = [
      _ownedEns('alice.eth'),
      _ownedEns('bob.base.eth'),
      _ownedEns('carol.n42'),
      _ownedEns('dave.arb'),
    ];

    test('matches Ethereum names without swallowing longer suffix chains', () {
      final filtered = filterOwnedEnsByChain(
        ownedNames,
        EnsChainConfig.supportedChains[1],
      );

      expect(filtered.map((item) => item.name), ['alice.eth']);
    });

    test('matches Base names by their specific suffix', () {
      final filtered = filterOwnedEnsByChain(
        ownedNames,
        EnsChainConfig.supportedChains[3],
      );

      expect(filtered.map((item) => item.name), ['bob.base.eth']);
    });

    test('matches N42 names by n42 suffix', () {
      final filtered = filterOwnedEnsByChain(
        ownedNames,
        EnsChainConfig.supportedChains[0],
      );

      expect(filtered.map((item) => item.name), ['carol.n42']);
    });
  });
}
