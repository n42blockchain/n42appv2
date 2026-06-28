// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/wallet/models/nft_model.dart';

class NftBatchTransferUtils {
  const NftBatchTransferUtils._();

  static bool isBatchTransferable(NftModel nft) {
    if (nft.isSolana || nft.isOrdinal) return false;
    if (nft.contractAddress.trim().isEmpty) return false;
    if (nft.tokenId.trim().isEmpty) return false;
    return nft.nftType == 'ERC721' || nft.nftType == 'ERC1155';
  }

  static int quantityForBatch(NftModel nft) => nft.isErc1155 ? 1 : 1;

  static String selectionKey(NftModel nft) {
    if (nft.nftId.isNotEmpty) return nft.nftId;
    return [
      nft.chain,
      nft.contractAddress.toLowerCase(),
      nft.tokenId,
      nft.nftType,
    ].join(':');
  }
}
