import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/simplehash_nft_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_list_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _FixtureNftApi extends SimpleHashNftApi {
  _FixtureNftApi(this.items);

  final List<NftModel> items;

  @override
  Future<List<NftModel>> fetchNfts(String address, String coinType) async =>
      items;
}

CoinModel _supportedCoin() => CoinModel.fromJson({
  'coin': {'coinType': 'ETH'},
  'address': '0x1234567890abcdef',
});

const _moonNft = NftModel(
  nftId: 'ethereum.0xabc.1',
  name: 'Moon Cat',
  contractAddress: '0xabc',
  tokenId: '1',
  nftType: 'ERC721',
  balance: 1,
  chain: 'ethereum',
  collectionName: 'Moon Collection',
);

const _videoNft = NftModel(
  nftId: 'ethereum.0xdef.2',
  name: 'Moving Star',
  contractAddress: '0xdef',
  tokenId: '2',
  nftType: 'ERC1155',
  balance: 2,
  chain: 'ethereum',
  animationUrl: 'https://media.example/star.mp4',
  collectionName: 'Star Collection',
);

const _spamNft = NftModel(
  nftId: 'ethereum.0xeee.3',
  name: 'Free reward claim',
  contractAddress: '0xeee',
  tokenId: '3',
  nftType: 'ERC721',
  balance: 1,
  chain: 'ethereum',
  collectionName: 'Unknown Collection',
);

void _useGalleryViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(750, 1334);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('empty NFT gallery keeps search clear interaction available', (
    tester,
  ) async {
    final coin = CoinModel.fromJson({
      'coin': {'coinType': 'UNSUPPORTED'},
      'address': 'fixture-address',
    });

    await tester.pumpWidget(wrapForTest(NftListPage(coin)));
    await tester.pumpAndSettle();

    final pageContext = tester.element(find.byType(NftListPage));
    expect(find.text(S.of(pageContext).g_key_nft_no_items), findsOneWidget);
    expect(find.byIcon(Icons.collections_outlined), findsOneWidget);

    final search = find.byType(TextField);
    await tester.enterText(search, 'art');
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsNothing);
    expect(find.text(S.of(pageContext).g_key_nft_no_items), findsOneWidget);
  });

  testWidgets('NFT gallery filters spam, then reveals it on explicit request', (
    tester,
  ) async {
    _useGalleryViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        NftListPage(
          _supportedCoin(),
          api: _FixtureNftApi([_moonNft, _videoNft, _spamNft]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Moon Cat'), findsOneWidget);
    expect(find.text('Moving Star'), findsOneWidget);
    expect(find.text('Free reward claim'), findsNothing);

    await tester.tap(find.byIcon(Icons.shield));
    await tester.pumpAndSettle();
    expect(find.text('Free reward claim'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shield_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Free reward claim'), findsNothing);
  });

  testWidgets('NFT gallery search and type filters narrow visible cards', (
    tester,
  ) async {
    _useGalleryViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        NftListPage(
          _supportedCoin(),
          api: _FixtureNftApi([_moonNft, _videoNft, _spamNft]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final filterList = find.byType(ListView).first;
    await tester.drag(filterList, const Offset(-500, 0));
    await tester.pumpAndSettle();
    final erc1155Filter = find.text('ERC1155');
    await tester.tap(erc1155Filter);
    await tester.pumpAndSettle();
    expect(find.text('Moving Star'), findsOneWidget);
    expect(find.text('Moon Cat'), findsNothing);

    await tester.drag(filterList, const Offset(500, 0));
    await tester.pumpAndSettle();
    final allFilter = find.text(
      S.of(tester.element(find.byType(NftListPage))).g_key_nft_filter_all,
    );
    await tester.tap(allFilter);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'moon');
    await tester.pumpAndSettle();
    expect(find.text('Moon Cat'), findsOneWidget);
    expect(find.text('Moving Star'), findsNothing);
  });

  testWidgets('NFT collection toggle groups cards under their collection', (
    tester,
  ) async {
    _useGalleryViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        NftListPage(
          _supportedCoin(),
          api: _FixtureNftApi([_moonNft, _videoNft]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Moon Collection'), findsOneWidget);
    final starCollection = find.text('Star Collection');
    await tester.ensureVisible(starCollection);
    expect(starCollection, findsOneWidget);
    expect(find.text('Moon Cat'), findsOneWidget);
    expect(find.text('Moving Star'), findsOneWidget);
  });
}
