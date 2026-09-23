import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_uploader.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_message_sender.dart';

class _Manager extends Mock implements MatrixClientManager {}

class _Client extends Mock implements matrix.Client {}

class _Room extends Mock implements matrix.Room {}

class _Uploader extends Mock implements MatrixMediaUploader {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => registerFallbackValue(Uint8List(0)));
  for (final kind in ['openmoji', 'lottie']) {
    test(
      'sends $kind artwork as a bundled asset without media upload',
      () async {
        final manager = _Manager();
        final client = _Client();
        final room = _Room();
        when(() => manager.client).thenReturn(client);
        when(() => client.isLogged()).thenReturn(true);
        when(() => client.getRoomById('!room:test')).thenReturn(room);
        when(() => room.client).thenReturn(client);
        when(() => room.encrypted).thenReturn(false);
        when(
          () => client.uploadContent(
            any(),
            filename: any(named: 'filename'),
            contentType: any(named: 'contentType'),
          ),
        ).thenAnswer((_) async => Uri.parse('mxc://test/sticker'));
        when(
          () => room.sendEvent(any(), type: any(named: 'type')),
        ).thenAnswer((_) async => 'event');
        final ext = kind == 'openmoji' ? 'svg' : 'json';
        final result = await MatrixMessageSender(manager, _Uploader())
            .sendStickerMessage(
              '!room:test',
              stickerId: '1F60D',
              packId: kind,
              url: 'asset:assets/stickers/$kind/1F60D.$ext',
              name: 'Heart eyes',
            );
        expect(result, 'event');
        final content =
            verify(
                  () => room.sendEvent(
                    captureAny(),
                    type: matrix.EventTypes.Sticker,
                  ),
                ).captured.single
                as Map;
        expect(content['url'], 'asset:assets/stickers/$kind/1F60D.$ext');
        expect(content['org.n42.sticker'], {
          'pack_id': kind,
          'sticker_id': '1F60D',
          'emoji': null,
        });
        expect(
          (content['info'] as Map)['mimetype'],
          kind == 'openmoji' ? 'image/svg+xml' : 'application/lottie+json',
        );
        verifyNever(
          () => client.uploadContent(
            any(),
            filename: '1F60D.$ext',
            contentType: any(named: 'contentType'),
          ),
        );
      },
    );
  }
}
