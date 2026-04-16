// Tests for ThreadEvent subclasses in thread_event.dart.
// List<int> (imageBytes/fileBytes) is const-capable; MessageEntity is
// skipped for complex equality (null target is testable).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/thread/thread_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('LoadThreadMessages', () {
    test('is a ThreadEvent', () {
      expect(const LoadThreadMessages(), isA<ThreadEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadThreadMessages(), equals(const LoadThreadMessages()));
    });
  });

  group('LoadMoreThreadMessages', () {
    test('is a ThreadEvent', () {
      expect(const LoadMoreThreadMessages(), isA<ThreadEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadMoreThreadMessages(), equals(const LoadMoreThreadMessages()));
    });
  });

  group('DisposeThread', () {
    test('is a ThreadEvent', () {
      expect(const DisposeThread(), isA<ThreadEvent>());
    });

    test('two instances are equal', () {
      expect(const DisposeThread(), equals(const DisposeThread()));
    });
  });

  // ─────────────────────────────────────────────────
  // InitializeThread
  // ─────────────────────────────────────────────────

  group('InitializeThread', () {
    test('stores roomId and threadRootEventId', () {
      const e = InitializeThread(
        roomId: '!room:server',
        threadRootEventId: '\$root:event',
      );
      expect(e.roomId, '!room:server');
      expect(e.threadRootEventId, '\$root:event');
    });

    test('same fields → equal', () {
      expect(
        const InitializeThread(roomId: '!r:s', threadRootEventId: '\$e:s'),
        equals(const InitializeThread(roomId: '!r:s', threadRootEventId: '\$e:s')),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const InitializeThread(roomId: '!a:s', threadRootEventId: '\$e:s'),
        isNot(equals(const InitializeThread(roomId: '!b:s', threadRootEventId: '\$e:s'))),
      );
    });

    test('different threadRootEventId → not equal', () {
      expect(
        const InitializeThread(roomId: '!r:s', threadRootEventId: '\$a:s'),
        isNot(equals(const InitializeThread(roomId: '!r:s', threadRootEventId: '\$b:s'))),
      );
    });

    test('is a ThreadEvent', () {
      expect(
        const InitializeThread(roomId: '!r:s', threadRootEventId: '\$e:s'),
        isA<ThreadEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SendThreadTextMessage
  // ─────────────────────────────────────────────────

  group('SendThreadTextMessage', () {
    test('stores text', () {
      const e = SendThreadTextMessage('Hello thread');
      expect(e.text, 'Hello thread');
    });

    test('same text → equal', () {
      expect(
        const SendThreadTextMessage('hi'),
        equals(const SendThreadTextMessage('hi')),
      );
    });

    test('different text → not equal', () {
      expect(
        const SendThreadTextMessage('a'),
        isNot(equals(const SendThreadTextMessage('b'))),
      );
    });

    test('is a ThreadEvent', () {
      expect(const SendThreadTextMessage('msg'), isA<ThreadEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SendThreadImageMessage
  // ─────────────────────────────────────────────────

  group('SendThreadImageMessage', () {
    test('stores imageBytes and filename', () {
      const e = SendThreadImageMessage(
        imageBytes: [0xFF, 0xD8, 0xFF],
        filename: 'photo.jpg',
      );
      expect(e.imageBytes, [0xFF, 0xD8, 0xFF]);
      expect(e.filename, 'photo.jpg');
    });

    test('mimeType defaults to null', () {
      const e = SendThreadImageMessage(imageBytes: [], filename: 'f.jpg');
      expect(e.mimeType, isNull);
    });

    test('stores mimeType when provided', () {
      const e = SendThreadImageMessage(
        imageBytes: [1],
        filename: 'f.jpg',
        mimeType: 'image/jpeg',
      );
      expect(e.mimeType, 'image/jpeg');
    });

    test('same fields → equal', () {
      expect(
        const SendThreadImageMessage(
            imageBytes: [1, 2], filename: 'a.jpg', mimeType: 'image/jpeg'),
        equals(const SendThreadImageMessage(
            imageBytes: [1, 2], filename: 'a.jpg', mimeType: 'image/jpeg')),
      );
    });

    test('different filename → not equal', () {
      expect(
        const SendThreadImageMessage(imageBytes: [1], filename: 'a.jpg'),
        isNot(equals(const SendThreadImageMessage(imageBytes: [1], filename: 'b.jpg'))),
      );
    });

    test('is a ThreadEvent', () {
      expect(
        const SendThreadImageMessage(imageBytes: [], filename: 'f.png'),
        isA<ThreadEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SendThreadFileMessage
  // ─────────────────────────────────────────────────

  group('SendThreadFileMessage', () {
    test('stores fileBytes and filename', () {
      const e = SendThreadFileMessage(
        fileBytes: [0x50, 0x4B],
        filename: 'doc.pdf',
      );
      expect(e.fileBytes, [0x50, 0x4B]);
      expect(e.filename, 'doc.pdf');
    });

    test('mimeType defaults to null', () {
      expect(
        const SendThreadFileMessage(fileBytes: [], filename: 'f.pdf').mimeType,
        isNull,
      );
    });

    test('stores mimeType', () {
      const e = SendThreadFileMessage(
        fileBytes: [1],
        filename: 'f.pdf',
        mimeType: 'application/pdf',
      );
      expect(e.mimeType, 'application/pdf');
    });

    test('same fields → equal', () {
      expect(
        const SendThreadFileMessage(fileBytes: [1], filename: 'f.pdf'),
        equals(const SendThreadFileMessage(fileBytes: [1], filename: 'f.pdf')),
      );
    });

    test('different fileBytes → not equal', () {
      expect(
        const SendThreadFileMessage(fileBytes: [1], filename: 'f.pdf'),
        isNot(equals(const SendThreadFileMessage(fileBytes: [2], filename: 'f.pdf'))),
      );
    });

    test('is a ThreadEvent', () {
      expect(
        const SendThreadFileMessage(fileBytes: [], filename: 'f.pdf'),
        isA<ThreadEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SetThreadReplyTarget
  // ─────────────────────────────────────────────────

  group('SetThreadReplyTarget', () {
    test('null target is stored', () {
      const e = SetThreadReplyTarget(null);
      expect(e.target, isNull);
    });

    test('null target → equal', () {
      expect(
        const SetThreadReplyTarget(null),
        equals(const SetThreadReplyTarget(null)),
      );
    });

    test('is a ThreadEvent', () {
      expect(const SetThreadReplyTarget(null), isA<ThreadEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ThreadMessagesUpdated
  // ─────────────────────────────────────────────────

  group('ThreadMessagesUpdated', () {
    test('stores empty messages list', () {
      const e = ThreadMessagesUpdated([]);
      expect(e.messages, isEmpty);
    });

    test('empty list → equal', () {
      expect(
        const ThreadMessagesUpdated([]),
        equals(const ThreadMessagesUpdated([])),
      );
    });

    test('is a ThreadEvent', () {
      expect(const ThreadMessagesUpdated([]), isA<ThreadEvent>());
    });
  });
}
