import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/n42_wallet_bridge.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';

class _WalletSnapshot extends Fake
    implements LegacyWalletActionProviderAdapter {
  @override
  final List<WalletInfo> walletInfoLsit = [];

  @override
  final List<CoinModel> coinModels = [];

  @override
  int get walletIndex => 0;

  final addresses = <String, String>{};

  @override
  dynamic getAddress(String coinKey, {String addrType = 'legacy'}) =>
      addresses[coinKey];
}

class _SyntheticWalletService extends Fake implements IWalletService {
  @override
  Future<String?> getPrivateKeyForWallet(int walletIndex) async => null;

  @override
  Future<String?> getMnemonicForWallet(int walletIndex) async =>
      'test-only synthetic mnemonic';
}

CoinModel _ethCoin() => CoinModel()
  ..coin = {
    'coinType': 'ETH',
    'mKey': 'ETH',
    'blockchainType': 'Ethereum',
    'path': {'legacy': "m/44'/60'/0'/0/0"},
  }
  ..address = '0x1111111111111111111111111111111111111111';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const trustdart = MethodChannel('trustdart');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final snapshot = _WalletSnapshot();
  late N42WalletBridge bridge;
  late ProviderContainer container;

  setUpAll(() => globalWapAdapter = snapshot);

  setUp(() {
    snapshot.walletInfoLsit.clear();
    snapshot.coinModels.clear();
    snapshot.addresses.clear();
    container = ProviderContainer();
    globalProviderContainer = container;
    registerWalletService(_SyntheticWalletService());
    bridge = N42WalletBridge();
    messenger.setMockMethodCallHandler(trustdart, (call) async {
      if (call.method == 'getPrivateKey') {
        expect(call.arguments, {
          'coin': 'ETH',
          'path': "m/44'/60'/0'/0/0",
          'mnemonic': 'test-only synthetic mnemonic',
          'passphrase': '',
        });
        // Test-only deterministic scalar; never read from wallet storage.
        return base64Encode(List<int>.generate(32, (index) => index + 1));
      }
      throw MissingPluginException(
        'Unexpected test channel call: ${call.method}',
      );
    });
  });

  test('opts into exact-asset wallet transfers', () {
    expect(bridge, isA<IExactWalletTransfer>());
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(trustdart, null);
    resetCrossFeatureServices();
    container.dispose();
  });

  test('selects ETH then N before falling back to a coin model address', () {
    snapshot.addresses.addAll({'ETH': 'eth-address', 'N': 'n-address'});
    expect(bridge.walletAddress, 'eth-address');

    snapshot.addresses.remove('ETH');
    expect(bridge.walletAddress, 'n-address');

    snapshot.addresses.clear();
    snapshot.coinModels.add(_ethCoin());
    expect(bridge.walletAddress, _ethCoin().address);
  });

  test(
    'returns zero for malformed ERC query inputs without RPC access',
    () async {
      const owner = '0x1111111111111111111111111111111111111111';

      expect(
        await bridge.getErc20Balance(
          contractAddress: 'invalid',
          chainId: 1,
          ownerAddress: owner,
        ),
        BigInt.zero,
      );
      expect(
        await bridge.getErc721Balance(
          contractAddress: 'invalid',
          chainId: 1,
          ownerAddress: owner,
        ),
        0,
      );
      expect(
        await bridge.getErc1155Balance(
          contractAddress: 'invalid',
          tokenId: BigInt.one,
          chainId: 1,
          ownerAddress: owner,
        ),
        BigInt.zero,
      );
    },
  );

  test('rejects invalid NFT transfer requests before sender setup', () async {
    snapshot.walletInfoLsit.add(WalletInfo());

    final invalidAddress = await bridge.requestNftTransfer(
      contractAddress: 'invalid',
      tokenId: '1',
      toAddress: '0x2222222222222222222222222222222222222222',
      chainId: 1,
    );
    final invalidTokenId = await bridge.requestNftTransfer(
      contractAddress: '0x1111111111111111111111111111111111111111',
      tokenId: 'not-an-id',
      toAddress: '0x2222222222222222222222222222222222222222',
      chainId: 1,
    );
    final invalidAmount = await bridge.requestNftTransfer(
      contractAddress: '0x1111111111111111111111111111111111111111',
      tokenId: '1',
      toAddress: '0x2222222222222222222222222222222222222222',
      chainId: 1,
      standard: NftStandard.erc1155,
      amount: 0,
    );

    expect(invalidAddress.errorMessage, 'Invalid NFT transfer address');
    expect(invalidTokenId.errorMessage, 'Invalid NFT token ID');
    expect(invalidAmount.errorMessage, 'Invalid NFT transfer amount');
  });

  testWidgets('does not navigate when there are no receive assets', (
    tester,
  ) async {
    final previousNavigatorKey = AppGlobals.navigatorKey;
    final navigatorKey = GlobalKey<NavigatorState>();
    AppGlobals.navigatorKey = navigatorKey;
    addTearDown(() => AppGlobals.navigatorKey = previousNavigatorKey);
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigatorKey, home: const SizedBox()),
    );

    await bridge.showReceiveQRCode();

    expect(navigatorKey.currentState!.canPop(), isFalse);
  });

  test('signs message using deterministic trustdart test fixture', () async {
    snapshot.coinModels.add(_ethCoin());

    final firstSignature = await bridge.signMessage('wallet bridge behavior');
    final secondSignature = await bridge.signMessage('wallet bridge behavior');

    expect(firstSignature, isNotNull);
    expect(firstSignature, startsWith('0x'));
    expect(firstSignature, hasLength(132));
    expect(secondSignature, firstSignature);
  });

  test('signs valid EIP-712 data with the deterministic key fixture', () async {
    snapshot.coinModels.add(_ethCoin());
    const typedData = '''
      {
        "types": {
          "EIP712Domain": [{"name": "name", "type": "string"}],
          "Mail": [{"name": "contents", "type": "string"}]
        },
        "primaryType": "Mail",
        "domain": {"name": "Bridge test"},
        "message": {"contents": "deterministic"}
      }
    ''';

    final signature = await bridge.signTypedData(typedData);

    expect(signature, isNotNull);
    expect(signature, startsWith('0x'));
    expect(signature, hasLength(132));
  });
}
