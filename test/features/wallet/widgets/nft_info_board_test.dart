import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/widgets/nft_info_board.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

NftModel _erc1155Fixture() => const NftModel(
  nftId: 'ethereum.0xabc.17',
  name: 'Fixture Edition',
  contractAddress: '0x1234567890abcdef1234567890abcdef12345678',
  tokenId: '17',
  nftType: 'ERC1155',
  balance: 3,
  chain: 'ethereum',
  collectionName: 'Fixture Collection',
  description: 'A local description for the NFT info board test.',
  floorPrice: 0.05,
  floorPriceSymbol: 'ETH',
);

void main() {
  testWidgets('ERC1155 board presents metadata and forwards enabled actions', (
    tester,
  ) async {
    var sends = 0;
    var receives = 0;
    var browsers = 0;
    var burns = 0;
    final nft = _erc1155Fixture();

    await tester.pumpWidget(
      wrapForTest(
        SingleChildScrollView(
          child: NftInfoBoard(
            address: 'bc1qfixtureaddress',
            coinType: 'BTC',
            tokenName: nft.name,
            tokenId: nft.tokenId,
            contractAddress: nft.contractAddress,
            nftType: nft.nftType,
            balance: nft.balance.toString(),
            description: nft.description,
            floorPriceDisplay: nft.floorPriceDisplay,
            collectionName: nft.collectionName,
            sendTap: () => sends++,
            receiveTap: () => receives++,
            browserTap: () => browsers++,
            burnTap: () => burns++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final localizations = S.of(tester.element(find.byType(NftInfoBoard)));
    expect(find.text(nft.name), findsOneWidget);
    expect(find.text(nft.collectionName!), findsOneWidget);
    expect(find.text('#${nft.tokenId}'), findsOneWidget);
    expect(find.text(nft.nftType), findsOneWidget);
    expect(find.text(nft.balance.toString()), findsOneWidget);
    expect(find.text(nft.description!), findsOneWidget);
    expect(
      find.text('${localizations.g_key_nft_floor_price}: 0.0500 ETH'),
      findsOneWidget,
    );

    for (final icon in [
      Icons.send,
      Icons.qr_code,
      Icons.open_in_browser,
      Icons.local_fire_department,
    ]) {
      final finder = find.byIcon(icon);
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
    }

    expect(sends, 1);
    expect(receives, 1);
    expect(browsers, 1);
    expect(burns, 1);
  });

  testWidgets('custom media is shown and absent optional fields stay hidden', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        SingleChildScrollView(
          child: NftInfoBoard(
            address: '',
            tokenName: 'Media Fixture',
            mediaWidget: const ColoredBox(
              color: Colors.black,
              child: Center(child: Text('Offline media fixture')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline media fixture'), findsOneWidget);
    expect(find.text('Media Fixture'), findsOneWidget);
    expect(find.byIcon(Icons.image), findsNothing);
    expect(find.byIcon(Icons.local_fire_department), findsNothing);
    expect(find.text(S.current.g_key_nft_collection), findsNothing);
    expect(find.text(S.current.g_key_nft_token_id), findsNothing);
  });
}
