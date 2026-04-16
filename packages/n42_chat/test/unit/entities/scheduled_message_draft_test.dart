import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/scheduled_message_draft.dart';

void main() {
  group('ScheduledMessageDraft', () {
    test('parses poll payload and builds preview text', () {
      final draft = ScheduledMessageDraft.fromJson({
        'messageId': 'scheduled_poll',
        'text': 'Lunch?',
        'type': 'poll',
        'scheduledAt': DateTime.utc(2026, 3, 22, 12).toIso8601String(),
        'createdAt': DateTime.utc(2026, 3, 22, 11).toIso8601String(),
        'payload': {
          'options': ['Sushi', 'Pizza'],
          'maxSelections': 1,
        },
      });

      expect(draft.type, MessageType.poll);
      expect(draft.pollOptions, ['Sushi', 'Pizza']);
      expect(draft.timelinePreviewText, '[Poll] Lunch?');
    });

    test('creates pending preview messages as plain text summaries', () {
      final draft = ScheduledMessageDraft(
        messageId: 'scheduled_poll',
        text: 'Lunch?',
        type: MessageType.poll,
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        createdAt: DateTime.now(),
        payload: {
          'options': ['Sushi', 'Pizza'],
        },
      );

      final preview = draft.toPreviewMessage(
        roomId: '!room:test',
        senderId: '@me:test',
      );

      expect(preview.type, MessageType.text);
      expect(preview.content, '[Poll] Lunch?');
      expect(preview.isScheduled, isTrue);
    });

    test('treats image payload with gifUrl as a scheduled GIF', () {
      final draft = ScheduledMessageDraft.fromJson({
        'messageId': 'scheduled_gif',
        'text': 'Celebration',
        'type': 'image',
        'scheduledAt': DateTime.utc(2026, 3, 22, 12).toIso8601String(),
        'createdAt': DateTime.utc(2026, 3, 22, 11).toIso8601String(),
        'payload': {
          'gifUrl': 'https://media.giphy.com/media/abc/giphy.gif',
          'previewUrl': 'https://media.giphy.com/media/abc/preview.gif',
          'width': 320,
          'height': 240,
        },
      });

      expect(draft.isGif, isTrue);
      expect(draft.typeLabel, 'GIF');
      expect(draft.timelinePreviewText, '[GIF] Celebration');
    });

    test('parses local attachment payload and builds media preview text', () {
      final draft = ScheduledMessageDraft.fromJson({
        'messageId': 'scheduled_photo',
        'text': 'IMG_0001.jpg',
        'type': 'image',
        'scheduledAt': DateTime.utc(2026, 3, 22, 12).toIso8601String(),
        'createdAt': DateTime.utc(2026, 3, 22, 11).toIso8601String(),
        'payload': {
          'localPath': '/tmp/scheduled/IMG_0001.jpg',
          'filename': 'IMG_0001.jpg',
          'mimeType': 'image/jpeg',
          'fileSize': 2048,
        },
      });

      expect(draft.hasLocalAttachment, isTrue);
      expect(draft.localAttachmentPath, '/tmp/scheduled/IMG_0001.jpg');
      expect(draft.attachmentMimeType, 'image/jpeg');
      expect(draft.attachmentFileSize, 2048);
      expect(draft.typeLabel, 'Photo');
      expect(draft.timelinePreviewText, '[Photo] IMG_0001.jpg');
    });
  });
}
