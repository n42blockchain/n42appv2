import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_batch_transfer_utils.dart';

void main() {
  NftModel nft({
    String nftId = 'nft-1',
    String chain = 'ethereum',
    String contract = '0xContract',
    String tokenId = '1',
    String type = 'ERC721',
  }) {
    return NftModel(
      nftId: nftId,
      name: 'Test NFT',
      contractAddress: contract,
      tokenId: tokenId,
      nftType: type,
      balance: 1,
      chain: chain,
    );
  }

  test('isBatchTransferable only allows EVM ERC721/ERC1155 with ids', () {
    expect(NftBatchTransferUtils.isBatchTransferable(nft()), isTrue);
    expect(
      NftBatchTransferUtils.isBatchTransferable(nft(type: 'ERC1155')),
      isTrue,
    );
    expect(
      NftBatchTransferUtils.isBatchTransferable(nft(chain: 'solana')),
      isFalse,
    );
    expect(
      NftBatchTransferUtils.isBatchTransferable(nft(chain: 'bitcoin')),
      isFalse,
    );
    expect(
      NftBatchTransferUtils.isBatchTransferable(nft(contract: '')),
      isFalse,
    );
    expect(
      NftBatchTransferUtils.isBatchTransferable(nft(tokenId: '')),
      isFalse,
    );
    expect(
      NftBatchTransferUtils.isBatchTransferable(nft(type: 'INSCRIPTION')),
      isFalse,
    );
  });

  test('quantityForBatch is always 1 (never transfers full ERC-1155 balance)', () {
    // 资金安全关键不变量：批量路径每个 token 只转 1，避免误转整个多余额 ERC-1155。
    expect(NftBatchTransferUtils.quantityForBatch(nft(type: 'ERC721')), 1);
    expect(NftBatchTransferUtils.quantityForBatch(nft(type: 'ERC1155')), 1);
    final multiBalance = NftModel(
      nftId: 'nft-multi',
      name: 'Multi',
      contractAddress: '0xContract',
      tokenId: '1',
      nftType: 'ERC1155',
      balance: 999,
      chain: 'ethereum',
    );
    expect(NftBatchTransferUtils.quantityForBatch(multiBalance), 1);
  });

  test('selectionKey uses nftId when present', () {
    expect(
      NftBatchTransferUtils.selectionKey(nft(nftId: 'unique-xyz')),
      'unique-xyz',
    );
  });

  test('selectionKey falls back to chain contract token and type', () {
    final model = nft(
      nftId: '',
      chain: 'ethereum',
      contract: '0xABCDEF',
      tokenId: '42',
      type: 'ERC1155',
    );

    expect(
      NftBatchTransferUtils.selectionKey(model),
      'ethereum:0xabcdef:42:ERC1155',
    );
  });
}
