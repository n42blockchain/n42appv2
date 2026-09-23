import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

void main() {
  group('WalletActionProvider wallet lookup', () {
    test('private-key lookup does not fall back to a matching mnemonic', () {
      final provider = WalletActionProvider();
      final wallet = WalletInfo(
        walletName: 'Primary',
        mnemonic: 'fixture mnemonic',
        privateKey: '0x1234',
      );
      provider.walletInfoLsit.add(wallet);

      expect(
        provider.findWallet(pk: '0x9999', mnemonic: 'fixture mnemonic'),
        isNull,
      );
      expect(provider.findWallet(pk: '0x1234'), same(wallet));
    });

    test(
      'mnemonic lookup finds the wallet when no private key is supplied',
      () {
        final provider = WalletActionProvider();
        final wallet = WalletInfo(
          walletName: 'Recovery',
          mnemonic: 'one two three four',
          privateKey: '0x1234',
        );
        provider.walletInfoLsit.add(wallet);

        expect(
          provider.findWallet(mnemonic: 'one two three four'),
          same(wallet),
        );
        expect(provider.findWallet(mnemonic: 'different words'), isNull);
      },
    );
  });

  group('WalletActionProvider wallet removal', () {
    test(
      'default removal selects the previous last wallet after clamping',
      () async {
        final provider = WalletActionProvider();
        final first = WalletInfo(walletName: 'First');
        final second = WalletInfo(walletName: 'Second');
        final selected = WalletInfo(walletName: 'Selected');
        provider.walletInfoLsit.addAll([first, second, selected]);
        provider.walletIndex = 2;

        await provider.deleteWalletInfo();

        expect(provider.walletInfoLsit, [second, selected]);
        expect(provider.walletIndex, 1);
        expect(provider.walletName, 'Selected');
      },
    );

    test('default removal from an empty list is harmless', () async {
      final provider = WalletActionProvider();

      await expectLater(provider.deleteWalletInfo(), completes);

      expect(provider.walletInfoLsit, isEmpty);
      expect(provider.walletIndex, -1);
    });
  });

  test(
    'public key-pair lookup skips wallets without derivation metadata',
    () async {
      final provider = WalletActionProvider();
      provider.walletInfoLsit.addAll([
        WalletInfo(walletName: 'Watch')..mainWallet = false,
        WalletInfo(walletName: 'Missing coin metadata')..mainWallet = true,
        WalletInfo(walletName: 'Missing N chain')
          ..mainWallet = true
          ..coinInfo = {},
        WalletInfo(walletName: 'Missing path')
          ..mainWallet = true
          ..coinInfo = {
            'N': {'baseInfo': <String, dynamic>{}},
          },
        WalletInfo(walletName: 'Unknown address type')
          ..mainWallet = true
          ..coinInfo = {
            'N': {
              'baseInfo': {
                'path': {'legacy': "m/44'/1'/0'/0/0"},
              },
              'addrType': 'segwit',
              'pathIndex': 0,
            },
          },
      ]);

      await provider.publicKeyAndPrivateKeyPair();

      expect(provider.getPrivateKeyWithPublicKey('unavailable'), isNull);
    },
  );
}
