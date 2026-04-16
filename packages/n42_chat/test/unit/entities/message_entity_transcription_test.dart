import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  group('TranscriptionStatus', () {
    test('should have all expected values', () {
      expect(TranscriptionStatus.values.length, 4);
      expect(TranscriptionStatus.values.contains(TranscriptionStatus.none), isTrue);
      expect(TranscriptionStatus.values.contains(TranscriptionStatus.transcribing), isTrue);
      expect(TranscriptionStatus.values.contains(TranscriptionStatus.success), isTrue);
      expect(TranscriptionStatus.values.contains(TranscriptionStatus.failed), isTrue);
    });
  });

  group('MessageMetadata Transcription', () {
    test('should create metadata with transcription fields', () {
      const metadata = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        duration: 5000,
        transcription: '这是语音转文字的结果',
        transcriptionStatus: TranscriptionStatus.success,
      );

      expect(metadata.transcription, '这是语音转文字的结果');
      expect(metadata.transcriptionStatus, TranscriptionStatus.success);
    });

    test('should return true for hasTranscription when transcription exists', () {
      const metadata = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcription: '语音内容',
        transcriptionStatus: TranscriptionStatus.success,
      );

      expect(metadata.hasTranscription, isTrue);
    });

    test('should return false for hasTranscription when transcription is null', () {
      const metadata = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcriptionStatus: TranscriptionStatus.none,
      );

      expect(metadata.hasTranscription, isFalse);
    });

    test('should return false for hasTranscription when transcription is empty', () {
      const metadata = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcription: '',
        transcriptionStatus: TranscriptionStatus.failed,
      );

      expect(metadata.hasTranscription, isFalse);
    });

    test('should return true for isTranscribing when status is transcribing', () {
      const metadata = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcriptionStatus: TranscriptionStatus.transcribing,
      );

      expect(metadata.isTranscribing, isTrue);
    });

    test('should return false for isTranscribing when status is not transcribing', () {
      const metadataNone = MessageMetadata(
        transcriptionStatus: TranscriptionStatus.none,
      );
      const metadataSuccess = MessageMetadata(
        transcription: 'text',
        transcriptionStatus: TranscriptionStatus.success,
      );
      const metadataFailed = MessageMetadata(
        transcriptionStatus: TranscriptionStatus.failed,
      );

      expect(metadataNone.isTranscribing, isFalse);
      expect(metadataSuccess.isTranscribing, isFalse);
      expect(metadataFailed.isTranscribing, isFalse);
    });

    test('should copy with updated transcription using copyWithTranscription', () {
      const original = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        duration: 5000,
        transcriptionStatus: TranscriptionStatus.none,
      );

      final updated = original.copyWithTranscription(
        transcription: '转录结果',
        transcriptionStatus: TranscriptionStatus.success,
      );

      expect(updated.transcription, '转录结果');
      expect(updated.transcriptionStatus, TranscriptionStatus.success);
      // Original fields should be preserved
      expect(updated.mediaUrl, 'mxc://server.com/audio123');
      expect(updated.duration, 5000);
    });

    test('should preserve existing transcription when copyWithTranscription has null values', () {
      const original = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcription: '原始转录',
        transcriptionStatus: TranscriptionStatus.success,
      );

      final updated = original.copyWithTranscription();

      expect(updated.transcription, '原始转录');
      expect(updated.transcriptionStatus, TranscriptionStatus.success);
    });

    test('should update transcription status only', () {
      const original = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcriptionStatus: TranscriptionStatus.none,
      );

      final transcribing = original.copyWithTranscription(
        transcriptionStatus: TranscriptionStatus.transcribing,
      );

      expect(transcribing.transcriptionStatus, TranscriptionStatus.transcribing);
      expect(transcribing.transcription, isNull);
    });

    test('should include transcription fields in equality', () {
      const metadata1 = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcription: '相同内容',
        transcriptionStatus: TranscriptionStatus.success,
      );

      const metadata2 = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcription: '相同内容',
        transcriptionStatus: TranscriptionStatus.success,
      );

      const metadata3 = MessageMetadata(
        mediaUrl: 'mxc://server.com/audio123',
        transcription: '不同内容',
        transcriptionStatus: TranscriptionStatus.success,
      );

      expect(metadata1, equals(metadata2));
      expect(metadata1, isNot(equals(metadata3)));
    });
  });

  group('MessageEntity with Transcription Metadata', () {
    final testTimestamp = DateTime(2024, 1, 1, 12, 0);

    test('should create voice message with transcription metadata', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: '',
        timestamp: testTimestamp,
        type: MessageType.voice,
        status: MessageStatus.sent,
        metadata: const MessageMetadata(
          mediaUrl: 'mxc://server.com/audio123',
          duration: 5000,
          transcription: '语音消息内容',
          transcriptionStatus: TranscriptionStatus.success,
        ),
      );

      expect(message.type, MessageType.voice);
      expect(message.metadata?.transcription, '语音消息内容');
      expect(message.metadata?.transcriptionStatus, TranscriptionStatus.success);
      expect(message.metadata?.hasTranscription, isTrue);
    });

    test('should handle voice message without transcription', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: '',
        timestamp: testTimestamp,
        type: MessageType.voice,
        status: MessageStatus.sent,
        metadata: const MessageMetadata(
          mediaUrl: 'mxc://server.com/audio123',
          duration: 5000,
        ),
      );

      expect(message.metadata?.transcription, isNull);
      expect(message.metadata?.transcriptionStatus, isNull);
      expect(message.metadata?.hasTranscription, isFalse);
    });

    test('should handle transcription in progress', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: '',
        timestamp: testTimestamp,
        type: MessageType.voice,
        status: MessageStatus.sent,
        metadata: const MessageMetadata(
          mediaUrl: 'mxc://server.com/audio123',
          duration: 5000,
          transcriptionStatus: TranscriptionStatus.transcribing,
        ),
      );

      expect(message.metadata?.isTranscribing, isTrue);
      expect(message.metadata?.hasTranscription, isFalse);
    });

    test('should handle failed transcription', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: '',
        timestamp: testTimestamp,
        type: MessageType.voice,
        status: MessageStatus.sent,
        metadata: const MessageMetadata(
          mediaUrl: 'mxc://server.com/audio123',
          duration: 5000,
          transcriptionStatus: TranscriptionStatus.failed,
        ),
      );

      expect(message.metadata?.transcriptionStatus, TranscriptionStatus.failed);
      expect(message.metadata?.isTranscribing, isFalse);
      expect(message.metadata?.hasTranscription, isFalse);
    });

    test('should update message with transcription result using copyWith', () {
      final original = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: '',
        timestamp: testTimestamp,
        type: MessageType.voice,
        status: MessageStatus.sent,
        metadata: const MessageMetadata(
          mediaUrl: 'mxc://server.com/audio123',
          duration: 5000,
          transcriptionStatus: TranscriptionStatus.transcribing,
        ),
      );

      final updatedMetadata = original.metadata!.copyWithTranscription(
        transcription: '转录完成的文字',
        transcriptionStatus: TranscriptionStatus.success,
      );

      final updated = original.copyWith(metadata: updatedMetadata);

      expect(original.metadata?.isTranscribing, isTrue);
      expect(updated.metadata?.transcription, '转录完成的文字');
      expect(updated.metadata?.transcriptionStatus, TranscriptionStatus.success);
      expect(updated.metadata?.hasTranscription, isTrue);
      // Original message data should be preserved
      expect(updated.id, original.id);
      expect(updated.roomId, original.roomId);
      expect(updated.metadata?.mediaUrl, 'mxc://server.com/audio123');
      expect(updated.metadata?.duration, 5000);
    });

    test('should work with audio message type as well', () {
      final message = MessageEntity(
        id: '\$event1',
        roomId: '!room:server.com',
        senderId: '@user:server.com',
        senderName: 'Test User',
        content: '',
        timestamp: testTimestamp,
        type: MessageType.audio,
        status: MessageStatus.sent,
        metadata: const MessageMetadata(
          mediaUrl: 'mxc://server.com/audio123',
          duration: 10000,
          transcription: '音频内容转文字',
          transcriptionStatus: TranscriptionStatus.success,
        ),
      );

      expect(message.type, MessageType.audio);
      expect(message.metadata?.hasTranscription, isTrue);
      expect(message.metadata?.transcription, '音频内容转文字');
    });
  });
}
