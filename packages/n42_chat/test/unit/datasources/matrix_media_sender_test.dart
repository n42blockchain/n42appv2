import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_sender.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_uploader.dart';

class _MockMatrixClientManager extends Mock implements MatrixClientManager {}

class _MockClient extends Mock implements matrix.Client {}

class _MockRoom extends Mock implements matrix.Room {}

class _MockMediaUploader extends Mock implements MatrixMediaUploader {}

void main() {
  late _MockMatrixClientManager clientManager;
  late _MockClient client;
  late _MockRoom room;
  late _MockMediaUploader uploader;
  late MatrixMediaSender sender;

  setUp(() {
    clientManager = _MockMatrixClientManager();
    client = _MockClient();
    room = _MockRoom();
    uploader = _MockMediaUploader();
    sender = MatrixMediaSender(clientManager, uploader);

    when(() => clientManager.client).thenReturn(client);
    when(() => client.isLogged()).thenReturn(true);
    when(() => client.getRoomById('!room:test')).thenReturn(room);
  });

  test(
    'rejects streaming file uploads in encrypted rooms to preserve attachment encryption',
    () async {
      when(() => room.encrypted).thenReturn(true);
      when(() => client.fileEncryptionEnabled).thenReturn(true);

      await expectLater(
        () => sender.sendFileMessage(
          '!room:test',
          filename: 'secret.bin',
          filePath: '/tmp/secret.bin',
          fileSize: 16,
        ),
        throwsA(isA<UnsupportedError>()),
      );

      verifyNever(
        () => uploader.uploadFileAuthenticated(
          any(),
          contentLength: any(named: 'contentLength'),
          filename: any(named: 'filename'),
          contentType: any(named: 'contentType'),
        ),
      );
    },
  );
}
