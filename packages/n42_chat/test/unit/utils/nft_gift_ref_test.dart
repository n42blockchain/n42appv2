import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/nft_gift_ref.dart';

void main() {
  group('format', () {
    test('formats with chain id', () {
      const ref = NftGiftRef(
        contractAddress: '0xabc',
        tokenId: '42',
        chainId: 137,
      );
      expect(ref.format(), 'nft://0xabc/42@137');
      expect(ref.shortLabel, '#42');
    });
  });

  group('tryParse', () {
    test('parses full ref', () {
      final ref = NftGiftRef.tryParse(' nft://0xabc/42@137 ');
      expect(ref?.contractAddress, '0xabc');
      expect(ref?.tokenId, '42');
      expect(ref?.chainId, 137);
    });

    test('defaults chain to 1 when omitted', () {
      final ref = NftGiftRef.tryParse('nft://0xabc/7');
      expect(ref?.chainId, 1);
      expect(ref?.tokenId, '7');
    });

    test('round-trips through format', () {
      const ref = NftGiftRef(
        contractAddress: '0xDEAD',
        tokenId: '1001',
        chainId: 56,
      );
      expect(NftGiftRef.tryParse(ref.format()), ref);
    });

    test('returns null for non-nft scheme', () {
      expect(NftGiftRef.tryParse('https://x/y'), isNull);
      expect(NftGiftRef.tryParse('nft:/missing'), isNull);
    });

    test('returns null when missing parts', () {
      expect(NftGiftRef.tryParse('nft://'), isNull);
      expect(NftGiftRef.tryParse('nft://0xabc/'), isNull);
      expect(NftGiftRef.tryParse('nft:///42'), isNull);
    });

    test('returns null for non-numeric chain', () {
      expect(NftGiftRef.tryParse('nft://0xabc/42@abc'), isNull);
    });

    test('returns null for non-positive chain', () {
      expect(NftGiftRef.tryParse('nft://0xabc/42@0'), isNull);
      expect(NftGiftRef.tryParse('nft://0xabc/42@-1'), isNull);
    });

    test('returns null when token id contains path separators', () {
      expect(NftGiftRef.tryParse('nft://0xabc/42/extra@1'), isNull);
    });
  });
}
