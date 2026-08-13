import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:n42_chat/src/core/services/chat_media_bytes_resolver.dart';
import 'package:n42_chat/src/core/services/image_text_recognition_service.dart';
import 'package:n42_chat/src/core/services/image_text_session_service.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/ocr_document.dart';

void main() {
  final message = MessageEntity(
    id: 'event-1',
    roomId: 'room-1',
    senderId: 'alice',
    senderName: 'Alice',
    content: 'image.png',
    type: MessageType.image,
    timestamp: DateTime(2026),
  );

  test('shares one download and OCR task between image text entries', () async {
    final resolver = _FakeResolver();
    final recognizer = _FakeRecognizer();
    final service = ImageTextSessionService(
      mediaResolver: resolver,
      recognizer: recognizer,
    );
    addTearDown(resolver.dispose);

    final first = await service.load(message, scripts: const {OcrScript.latin});
    final second = await service.load(
      message,
      scripts: const {OcrScript.latin},
    );

    expect(identical(first, second), isTrue);
    expect(resolver.calls, 1);
    expect(recognizer.calls, 1);
  });

  test('never caches or processes protected media', () async {
    final resolver = _FakeResolver();
    final recognizer = _FakeRecognizer();
    final service = ImageTextSessionService(
      mediaResolver: resolver,
      recognizer: recognizer,
    );
    addTearDown(resolver.dispose);

    final protected = MessageEntity(
      id: 'event-protected',
      roomId: 'room-1',
      senderId: 'alice',
      senderName: 'Alice',
      content: 'image.png',
      type: MessageType.image,
      timestamp: DateTime(2026),
      selfDestructAfter: 30,
    );

    expect(
      () => service.load(protected, scripts: const {OcrScript.latin}),
      throwsA(isA<ChatMediaResolveException>()),
    );
    expect(resolver.calls, 0);
    expect(recognizer.calls, 0);
  });
}

class _FakeResolver extends ChatMediaBytesResolver {
  _FakeResolver()
    : super(httpClient: MockClient((_) async => throw StateError('unused')));

  int calls = 0;

  @override
  Future<ChatMediaData> resolveMessage(
    MessageEntity message, {
    bool allowSelfDestructing = false,
  }) async {
    calls++;
    return ChatMediaData(
      bytes: Uint8List.fromList([1, 2, 3]),
      mimeType: 'image/png',
    );
  }
}

class _FakeRecognizer implements ImageTextRecognitionService {
  int calls = 0;

  @override
  bool get isSupported => true;

  @override
  Future<OcrDocument> recognize(
    ChatMediaData media, {
    Set<OcrScript> scripts = const {OcrScript.latin, OcrScript.chinese},
  }) async {
    calls++;
    return const OcrDocument(
      fullText: 'hello',
      pixelSize: Size(10, 10),
      blocks: [],
    );
  }

  @override
  void dispose() {}
}
