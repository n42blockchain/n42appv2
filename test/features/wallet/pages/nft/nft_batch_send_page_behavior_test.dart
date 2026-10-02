import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_batch_send_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

NftModel _nft({
  String id = 'nft-1',
  String name = 'Collectible',
  String chain = 'ethereum',
  String contract = '0x1234567890abcdef1234567890abcdef12345678',
  String tokenId = '42',
  String type = 'ERC721',
}) => NftModel(
  nftId: id,
  name: name,
  contractAddress: contract,
  tokenId: tokenId,
  nftType: type,
  balance: 1,
  chain: chain,
);

CoinModel _coin() => CoinModel()
  ..address = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  ..coin = {'coinType': 'ETH'};

void main() {
  Future<S> openPage(WidgetTester tester, List<NftModel> nfts) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(wrapForTest(NftBatchSendPage(nfts, _coin())));
    await tester.pumpAndSettle();
    return S.of(tester.element(find.byType(NftBatchSendPage)));
  }

  testWidgets('empty batch shows empty state and disables sending', (
    tester,
  ) async {
    final l10n = await openPage(tester, []);

    expect(find.text(l10n.g_key_nft_no_items), findsOneWidget);
    expect(find.text('0 selected'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('only transferable EVM NFT standards appear in the batch', (
    tester,
  ) async {
    final l10n = await openPage(tester, [
      _nft(name: 'Ethereum artwork'),
      _nft(id: 'erc1155', name: 'ERC-1155 item', type: 'ERC1155', tokenId: '7'),
      _nft(id: 'solana', name: 'Solana collectible', chain: 'solana'),
      _nft(id: 'ordinal', name: 'Bitcoin inscription', chain: 'bitcoin'),
      _nft(id: 'missing-contract', name: 'Missing contract', contract: '  '),
      _nft(id: 'missing-token', name: 'Missing token id', tokenId: ''),
      _nft(id: 'unknown-standard', name: 'Unsupported standard', type: 'NFT'),
    ]);

    expect(find.text('Ethereum artwork'), findsOneWidget);
    expect(find.text('ERC-1155 item'), findsOneWidget);
    expect(find.text('Solana collectible'), findsNothing);
    expect(find.text('Bitcoin inscription'), findsNothing);
    expect(find.text('Missing contract'), findsNothing);
    expect(find.text('Missing token id'), findsNothing);
    expect(find.text('Unsupported standard'), findsNothing);
    expect(find.text('0/2 submitted'), findsOneWidget);
    expect(find.text(l10n.g_key_41), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty recipient validation blocks send before address checks', (
    tester,
  ) async {
    final l10n = await openPage(tester, [_nft()]);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // The same copy is also the field's placeholder, so validation produces
    // the second visible instance as the inline error.
    expect(find.text(l10n.g_key_41), findsNWidgets(2));
    expect(find.text('0/1 submitted'), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
