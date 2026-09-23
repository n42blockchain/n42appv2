import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/bundled_sticker_packs.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_metadata_extractor.dart';

class _Event extends Mock implements matrix.Event {}

void main() {
  test('resolves a bundled animation by stable pack and sticker IDs', () {
    expect(
      BundledStickerPacks.resolveAssetUrl('n42_animated', 'n42_animated_1F600'),
      'asset:assets/stickers/lottie/1F600.json',
    );
  });

  test('incoming bundled sticker metadata resolves locally before mxc URL', () {
    final event = _Event();
    when(() => event.type).thenReturn(matrix.EventTypes.Sticker);
    when(() => event.content).thenReturn({
      'url': 'mxc://example.org/remote-copy',
      'info': {'mimetype': 'application/lottie+json', 'w': 256, 'h': 256},
      'org.n42.sticker': {
        'pack_id': 'n42_animated',
        'sticker_id': 'n42_animated_1F600',
      },
    });
    final extractor = MatrixMetadataExtractor(
      () => null,
      (url, {width, height}) => url,
    );

    final metadata = extractor.extractMetadataWithHttpUrl(event);

    expect(metadata?.httpUrl, 'asset:assets/stickers/lottie/1F600.json');
    expect(metadata?.mediaUrl, 'asset:assets/stickers/lottie/1F600.json');
  });

  test('unknown sticker IDs preserve the original media fallback', () {
    final event = _Event();
    when(() => event.type).thenReturn(matrix.EventTypes.Sticker);
    when(() => event.content).thenReturn({
      'url': 'mxc://example.org/remote-copy',
      'org.n42.sticker': {
        'pack_id': 'future_pack',
        'sticker_id': 'future_sticker',
      },
    });
    final extractor = MatrixMetadataExtractor(
      () => null,
      (url, {width, height}) => 'https://media.example.org/sticker.json',
    );

    final metadata = extractor.extractMetadataWithHttpUrl(event);

    expect(metadata?.mediaUrl, 'mxc://example.org/remote-copy');
    expect(metadata?.httpUrl, 'https://media.example.org/sticker.json');
  });
}
