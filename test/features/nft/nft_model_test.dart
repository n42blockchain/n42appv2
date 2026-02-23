// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/models/nft_model.dart';

void main() {
  // ── Test fixture ──────────────────────────────────────────────────────────

  /// Minimal valid SimpleHash NFT JSON. Override fields as needed.
  Map<String, dynamic> base({
    String name = 'Test NFT',
    String nftId = 'ethereum.0xabc.1',
    String contractAddress = '0xabc',
    String contractType = 'ERC721',
    String tokenId = '1',
    String chain = 'ethereum',
    String quantityString = '1',
  }) =>
      {
        'nft_id': nftId,
        'name': name,
        'contract': {'address': contractAddress, 'type': contractType},
        'token_id': tokenId,
        'chain': chain,
        'quantity_string': quantityString,
      };

  // ── NftModel.fromSimpleHash ───────────────────────────────────────────────

  group('NftModel.fromSimpleHash', () {
    group('basic field parsing', () {
      test('parses name', () {
        final m = NftModel.fromSimpleHash(base(name: 'Cool NFT'));
        expect(m.name, 'Cool NFT');
      });

      test('parses contractAddress', () {
        final m = NftModel.fromSimpleHash(base());
        expect(m.contractAddress, '0xabc');
      });

      test('parses nftType from contract.type', () {
        final m = NftModel.fromSimpleHash(base(contractType: 'ERC1155'));
        expect(m.nftType, 'ERC1155');
      });

      test('defaults nftType to ERC721 when contract.type is empty', () {
        final json = base();
        (json['contract'] as Map).remove('type');
        final m = NftModel.fromSimpleHash(json);
        expect(m.nftType, 'ERC721');
      });

      test('parses tokenId', () {
        final m = NftModel.fromSimpleHash(base(tokenId: '9999'));
        expect(m.tokenId, '9999');
      });

      test('parses chain', () {
        final m = NftModel.fromSimpleHash(base(chain: 'solana'));
        expect(m.chain, 'solana');
      });

      test('parses balance from quantity_string', () {
        final m = NftModel.fromSimpleHash(base(quantityString: '5'));
        expect(m.balance, 5);
      });

      test('defaults balance to 1 on invalid quantity_string', () {
        final m = NftModel.fromSimpleHash(base(quantityString: 'invalid'));
        expect(m.balance, 1);
      });

      test('defaults balance to 1 on missing quantity_string', () {
        final json = base();
        json.remove('quantity_string');
        final m = NftModel.fromSimpleHash(json);
        expect(m.balance, 1);
      });
    });

    group('name fallback chain', () {
      test('uses name field when present', () {
        final json = {
          ...base(name: 'My NFT'),
          'collection': {'name': 'Cool Collection'},
        };
        final m = NftModel.fromSimpleHash(json);
        expect(m.name, 'My NFT');
      });

      test('falls back to collectionName when name is absent', () {
        final json = base();
        json.remove('name');
        json['collection'] = {'name': 'Cool Collection'};
        final m = NftModel.fromSimpleHash(json);
        expect(m.name, 'Cool Collection');
      });

      test('falls back to NFT #tokenId when both name and collection are absent', () {
        final json = base(tokenId: '42');
        json.remove('name');
        final m = NftModel.fromSimpleHash(json);
        expect(m.name, 'NFT #42');
      });
    });

    group('image URL resolution', () {
      test('prefers previews.image_small_url over medium and image_url', () {
        final json = {
          ...base(),
          'previews': {
            'image_small_url': 'https://small.jpg',
            'image_medium_url': 'https://medium.jpg',
          },
          'image_url': 'https://full.jpg',
        };
        expect(NftModel.fromSimpleHash(json).imageUrl, 'https://small.jpg');
      });

      test('falls back to previews.image_medium_url when small is absent', () {
        final json = {
          ...base(),
          'previews': {'image_medium_url': 'https://medium.jpg'},
          'image_url': 'https://full.jpg',
        };
        expect(NftModel.fromSimpleHash(json).imageUrl, 'https://medium.jpg');
      });

      test('falls back to image_url when previews absent', () {
        final json = {...base(), 'image_url': 'https://full.jpg'};
        expect(NftModel.fromSimpleHash(json).imageUrl, 'https://full.jpg');
      });

      test('imageUrl is null when all sources absent', () {
        expect(NftModel.fromSimpleHash(base()).imageUrl, isNull);
      });
    });

    group('floor price', () {
      test('parses floor price (numeric value) from collection.floor_prices', () {
        final json = {
          ...base(),
          'collection': {
            'floor_prices': [
              {'value': 0.05, 'payment_token': {'symbol': 'ETH'}},
            ],
          },
        };
        final m = NftModel.fromSimpleHash(json);
        expect(m.floorPrice, closeTo(0.05, 1e-9));
        expect(m.floorPriceSymbol, 'ETH');
      });

      test('parses floor price when value is a string', () {
        final json = {
          ...base(),
          'collection': {
            'floor_prices': [
              {'value': '0.1', 'payment_token': {'symbol': 'SOL'}},
            ],
          },
        };
        final m = NftModel.fromSimpleHash(json);
        expect(m.floorPrice, closeTo(0.1, 1e-9));
        expect(m.floorPriceSymbol, 'SOL');
      });

      test('floorPrice is null when floor_prices list is empty', () {
        final json = {...base(), 'collection': {'floor_prices': []}};
        expect(NftModel.fromSimpleHash(json).floorPrice, isNull);
      });

      test('floorPrice is null when collection absent', () {
        expect(NftModel.fromSimpleHash(base()).floorPrice, isNull);
      });

      test('floorPriceSymbol is null when payment_token absent', () {
        final json = {
          ...base(),
          'collection': {
            'floor_prices': [
              {'value': 0.5},
            ],
          },
        };
        final m = NftModel.fromSimpleHash(json);
        expect(m.floorPrice, closeTo(0.5, 1e-9));
        expect(m.floorPriceSymbol, isNull);
      });
    });

    group('animationUrl', () {
      test('parses animation_url', () {
        final json = {...base(), 'animation_url': 'https://cdn.example.com/video.mp4'};
        expect(NftModel.fromSimpleHash(json).animationUrl,
            'https://cdn.example.com/video.mp4');
      });

      test('falls back to extra_metadata.animation_original_url', () {
        final json = {
          ...base(),
          'extra_metadata': {
            'animation_original_url': 'https://cdn.example.com/orig.mp4',
          },
        };
        expect(NftModel.fromSimpleHash(json).animationUrl,
            'https://cdn.example.com/orig.mp4');
      });

      test('animation_url takes priority over extra_metadata fallback', () {
        final json = {
          ...base(),
          'animation_url': 'https://primary.com/video.mp4',
          'extra_metadata': {
            'animation_original_url': 'https://fallback.com/orig.mp4',
          },
        };
        expect(NftModel.fromSimpleHash(json).animationUrl,
            'https://primary.com/video.mp4');
      });

      test('animationUrl is null when absent', () {
        expect(NftModel.fromSimpleHash(base()).animationUrl, isNull);
      });
    });

    group('Ordinals inscription number', () {
      test('parses integer inscriptionNumber from extra_metadata', () {
        final json = {
          ...base(chain: 'bitcoin'),
          'extra_metadata': {'inscription_number': 12345},
        };
        expect(NftModel.fromSimpleHash(json).inscriptionNumber, 12345);
      });

      test('parses string inscriptionNumber from extra_metadata', () {
        final json = {
          ...base(chain: 'bitcoin'),
          'extra_metadata': {'inscription_number': '98765'},
        };
        expect(NftModel.fromSimpleHash(json).inscriptionNumber, 98765);
      });

      test('inscriptionNumber is null when extra_metadata absent', () {
        expect(NftModel.fromSimpleHash(base()).inscriptionNumber, isNull);
      });

      test('inscriptionNumber is null when key absent in extra_metadata', () {
        final json = {...base(), 'extra_metadata': <String, dynamic>{}};
        expect(NftModel.fromSimpleHash(json).inscriptionNumber, isNull);
      });
    });

    group('collectionName', () {
      test('parses collection name', () {
        final json = {...base(), 'collection': {'name': 'Bored Apes'}};
        expect(NftModel.fromSimpleHash(json).collectionName, 'Bored Apes');
      });

      test('collectionName is null when collection absent', () {
        expect(NftModel.fromSimpleHash(base()).collectionName, isNull);
      });
    });

    group('graceful degradation', () {
      test('handles missing contract key', () {
        final json = Map<String, dynamic>.from(base());
        json.remove('contract');
        final m = NftModel.fromSimpleHash(json);
        expect(m.contractAddress, '');
        expect(m.nftType, 'ERC721');
      });

      test('handles null contract', () {
        final json = {...base(), 'contract': null};
        final m = NftModel.fromSimpleHash(json);
        expect(m.contractAddress, '');
      });
    });
  });

  // ── Computed getters ──────────────────────────────────────────────────────

  group('NftModel.isSolana', () {
    test('returns true for solana chain', () {
      expect(NftModel.fromSimpleHash(base(chain: 'solana')).isSolana, isTrue);
    });

    test('returns false for ethereum chain', () {
      expect(NftModel.fromSimpleHash(base(chain: 'ethereum')).isSolana, isFalse);
    });
  });

  group('NftModel.isOrdinal', () {
    test('returns true for bitcoin chain', () {
      expect(NftModel.fromSimpleHash(base(chain: 'bitcoin')).isOrdinal, isTrue);
    });

    test('returns false for ethereum chain', () {
      expect(NftModel.fromSimpleHash(base()).isOrdinal, isFalse);
    });

    test('returns false for solana chain', () {
      expect(NftModel.fromSimpleHash(base(chain: 'solana')).isOrdinal, isFalse);
    });
  });

  group('NftModel.isErc1155', () {
    test('returns true for ERC1155', () {
      expect(NftModel.fromSimpleHash(base(contractType: 'ERC1155')).isErc1155, isTrue);
    });

    test('returns false for ERC721', () {
      expect(NftModel.fromSimpleHash(base(contractType: 'ERC721')).isErc1155, isFalse);
    });
  });

  group('NftModel.hasVideo', () {
    NftModel withAnimation(String? url) => NftModel(
          nftId: 'id',
          name: 'Test',
          contractAddress: '0x0',
          tokenId: '1',
          nftType: 'ERC721',
          balance: 1,
          chain: 'ethereum',
          animationUrl: url,
        );

    test('returns true for .mp4', () {
      expect(withAnimation('https://cdn.example.com/video.mp4').hasVideo, isTrue);
    });

    test('returns true for .webm', () {
      expect(withAnimation('https://cdn.example.com/clip.webm').hasVideo, isTrue);
    });

    test('returns true for .mov', () {
      expect(withAnimation('https://cdn.example.com/clip.mov').hasVideo, isTrue);
    });

    test('returns true for .ogg', () {
      expect(withAnimation('https://cdn.example.com/audio.ogg').hasVideo, isTrue);
    });

    test('returns true for uppercase extension (.MP4)', () {
      expect(withAnimation('https://cdn.example.com/VIDEO.MP4').hasVideo, isTrue);
    });

    test('returns true for URL with query params', () {
      expect(
        withAnimation('https://cdn.example.com/video.mp4?v=1&token=abc').hasVideo,
        isTrue,
      );
    });

    test('returns false for .jpg', () {
      expect(withAnimation('https://cdn.example.com/image.jpg').hasVideo, isFalse);
    });

    test('returns false for .gif', () {
      expect(withAnimation('https://cdn.example.com/anim.gif').hasVideo, isFalse);
    });

    test('returns false for null animationUrl', () {
      expect(withAnimation(null).hasVideo, isFalse);
    });

    test('returns false for empty animationUrl', () {
      expect(withAnimation('').hasVideo, isFalse);
    });

    test('returns false when .mp4 appears in path component (not as extension)', () {
      expect(
        withAnimation('https://cdn.example.com/mp4/image.jpg').hasVideo,
        isFalse,
      );
    });
  });

  group('NftModel.floorPriceDisplay', () {
    NftModel withFloor(double? price, [String? symbol]) => NftModel(
          nftId: 'id',
          name: 'Test',
          contractAddress: '0x0',
          tokenId: '1',
          nftType: 'ERC721',
          balance: 1,
          chain: 'ethereum',
          floorPrice: price,
          floorPriceSymbol: symbol,
        );

    test('returns null when floorPrice is null', () {
      expect(withFloor(null).floorPriceDisplay, isNull);
    });

    test('uses exponential notation for value < 0.0001', () {
      final display = withFloor(0.00001).floorPriceDisplay!;
      expect(display, contains('e'));
    });

    test('uses 4 decimal places for 0.0001 <= value < 1', () {
      expect(withFloor(0.05).floorPriceDisplay, '0.0500');
    });

    test('uses 3 decimal places for value >= 1', () {
      expect(withFloor(1234.5).floorPriceDisplay, '1234.500');
    });

    test('appends symbol when present', () {
      expect(withFloor(0.5, 'ETH').floorPriceDisplay, '0.5000 ETH');
    });

    test('omits symbol when null', () {
      expect(withFloor(0.5).floorPriceDisplay, '0.5000');
    });

    test('omits symbol when empty string', () {
      expect(withFloor(0.5, '').floorPriceDisplay, '0.5000');
    });

    test('boundary: exactly 0.0001 uses fixed notation', () {
      // 0.0001 is NOT < 0.0001, so uses toStringAsFixed(4)
      expect(withFloor(0.0001).floorPriceDisplay, '0.0001');
    });

    test('boundary: exactly 1.0 uses 3 decimal places', () {
      expect(withFloor(1.0).floorPriceDisplay, '1.000');
    });
  });
}
