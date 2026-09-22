import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_metadata_extractor.dart';

class _MockEvent extends Mock implements matrix.Event {}

void main() {
  test('extracts encrypted file material for image messages', () {
    final event = _MockEvent();
    when(() => event.type).thenReturn(matrix.EventTypes.Message);
    when(() => event.messageType).thenReturn(matrix.MessageTypes.Image);
    when(() => event.content).thenReturn({
      'msgtype': 'm.image',
      'body': 'secret.png',
      'file': {
        'url': 'mxc://server/image',
        'key': {'k': 'base64url-key'},
        'iv': 'base64-iv',
        'hashes': {'sha256': 'base64-hash'},
      },
      'info': {'mimetype': 'image/png', 'w': 320, 'h': 240},
    });
    final extractor = MatrixMetadataExtractor(
      () => null,
      (mxc, {width, height}) => mxc == null ? null : 'https://media/$mxc',
    );

    final metadata = extractor.extractMetadataWithHttpUrl(event);

    expect(metadata, isNotNull);
    expect(metadata!.mediaUrl, 'mxc://server/image');
    expect(metadata.encryptKey, 'base64url-key');
    expect(metadata.encryptIv, 'base64-iv');
    expect(metadata.encryptSha256, 'base64-hash');
  });

  test('extracts encrypted video thumbnail using the download URL', () {
    final event = _MockEvent();
    when(() => event.type).thenReturn(matrix.EventTypes.Message);
    when(() => event.messageType).thenReturn(matrix.MessageTypes.Video);
    when(() => event.content).thenReturn({
      'msgtype': 'm.video',
      'body': 'secret.mp4',
      'url': 'mxc://server/video',
      'info': {
        'mimetype': 'video/mp4',
        'thumbnail_file': {
          'url': 'mxc://server/encrypted-thumbnail',
          'key': {'k': 'thumbnail-key'},
          'iv': 'thumbnail-iv',
          'hashes': {'sha256': 'thumbnail-hash'},
        },
      },
    });
    final conversions = <({String? mxc, int? width, int? height})>[];
    final extractor = MatrixMetadataExtractor(() => null, (
      mxc, {
      width,
      height,
    }) {
      conversions.add((mxc: mxc, width: width, height: height));
      return mxc == null ? null : 'https://media/$mxc';
    });

    final metadata = extractor.extractMetadataWithHttpUrl(event)!;

    expect(metadata.thumbnailUrl, contains('encrypted-thumbnail'));
    expect(metadata.thumbnailEncryptKey, 'thumbnail-key');
    expect(metadata.thumbnailEncryptIv, 'thumbnail-iv');
    expect(metadata.thumbnailEncryptSha256, 'thumbnail-hash');
    expect(conversions.last, (
      mxc: 'mxc://server/encrypted-thumbnail',
      width: null,
      height: null,
    ));
  });
}
