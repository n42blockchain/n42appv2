import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:web3dart/web3dart.dart' as web3;

import '../../../helpers/wallet_connect_client_fake.dart';

class _Provider extends WalletConnectProvider {
  final pending = <Completer<String?>>[];
  int selected = 0;
  String owner = 'owner-a';
  @override
  int get signingWalletIndex => selected;
  @override
  String get signingWalletOwner => owner;
  @override
  Future<String?> loadSigningKey(int index, CoinModel cm) {
    final request = Completer<String?>();
    pending.add(request);
    return request.future;
  }
}

String _key(int n) => base64Encode(Uint8List(32)..[31] = n);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _Provider create() {
    final coin = sessionCoin(
      address: web3.EthPrivateKey.fromInt(BigInt.one).address.with0x,
    );
    coin.coin['service'] = 'https://rpc.invalid';
    return _Provider()
      ..coinModels = [coin]
      ..coinModelsIndex = 0;
  }

  for (final fail in [false, true]) {
    test(
      'older initialization ${fail ? 'failure' : 'success'} cannot replace the current client or key',
      () async {
        final provider = create();
        addTearDown(provider.dispose);
        final old = provider.web3clientInit();
        provider.coinModels.single.address = web3.EthPrivateKey.fromInt(
          BigInt.two,
        ).address.with0x;
        final latest = provider.web3clientInit();
        provider.pending[1].complete(_key(2));
        expect(await latest, isTrue);
        final client = provider.web3client;
        if (fail) {
          provider.pending[0].completeError(StateError('old failure'));
        } else {
          provider.pending[0].complete(_key(1));
        }
        expect(await old, isFalse);
        expect(provider.web3client, same(client));
        expect(
          provider.privateKey.address,
          web3.EthPrivateKey.fromInt(BigInt.two).address,
        );
        expect(provider.errorMessage, isEmpty);
      },
    );
  }
  test(
    'a cached key expires on account change and the new account can initialize',
    () async {
      final provider = create();
      addTearDown(provider.dispose);
      final first = provider.web3clientInit();
      provider.pending[0].complete(_key(1));
      expect(await first, isTrue);
      provider.selected = 1;
      expect(() => provider.privateKey, throwsStateError);
      provider.coinModels.single.address = web3.EthPrivateKey.fromInt(
        BigInt.two,
      ).address.with0x;
      final next = provider.web3clientInitFromChainId('eip155:1');
      provider.pending[1].complete(_key(2));
      expect(await next, isTrue);
      expect(
        provider.privateKey.address,
        web3.EthPrivateKey.fromInt(BigInt.two).address,
      );
    },
  );
  for (final change in ['wallet', 'owner', 'disconnect', 'dispose']) {
    test('$change invalidates outstanding key loading', () async {
      final provider = create();
      if (change != 'dispose') addTearDown(provider.dispose);
      final loading = provider.web3clientInit();
      if (change == 'wallet') provider.selected = 1;
      if (change == 'owner') provider.owner = 'owner-b';
      if (change == 'disconnect') {
        await provider.viewStateDeal(WalletConnectState.disconnect);
      }
      if (change == 'dispose') provider.dispose();
      provider.pending.single.complete(_key(1));
      expect(await loading, isFalse);
      expect(() => provider.privateKey, throwsStateError);
    });
  }
  test(
    'mismatched private key never becomes the selected wallet key',
    () async {
      final provider = create();
      addTearDown(provider.dispose);
      final loading = provider.web3clientInit();
      provider.pending.single.complete(_key(2));
      expect(await loading, isFalse);
      expect(() => provider.privateKey, throwsStateError);
      expect(provider.web3client, isNull);
    },
  );
  for (final change in ['address type', 'derivation path']) {
    test('$change invalidates pending and cached signing keys', () async {
      final provider = create();
      addTearDown(provider.dispose);
      final coin = provider.coinModels.single;
      coin.coin['path'] = {'legacy': "m/44'/60'/0'/0/0"};
      final first = provider.web3clientInit();
      provider.pending[0].complete(_key(1));
      expect(await first, isTrue);
      if (change == 'address type') coin.addrType = 'segwit';
      if (change == 'derivation path') {
        coin.coin['path'] = {'legacy': "m/44'/60'/1'/0/0"};
      }
      expect(() => provider.privateKey, throwsStateError);
      final pending = provider.web3clientInit();
      if (change == 'address type') coin.addrType = 'legacy';
      if (change == 'derivation path') {
        coin.coin['path'] = {'legacy': "m/44'/60'/2'/0/0"};
      }
      provider.pending[1].complete(_key(1));
      expect(await pending, isFalse);
    });
  }
}
