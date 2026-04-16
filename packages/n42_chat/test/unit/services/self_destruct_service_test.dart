import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/self_destruct_service.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  late SelfDestructService service;

  setUp(() {
    service = SelfDestructService.forTest();
  });

  tearDown(() {
    service.dispose();
  });

  MessageEntity createTestMessage({
    String id = '\$event1',
    String roomId = '!room:example.com',
    int? selfDestructAfter,
    DateTime? destroyedAt,
  }) {
    return MessageEntity(
      id: id,
      roomId: roomId,
      senderId: '@user:example.com',
      senderName: 'Test User',
      content: 'Test message',
      type: MessageType.text,
      timestamp: DateTime.now(),
      selfDestructAfter: selfDestructAfter,
      destroyedAt: destroyedAt,
    );
  }

  group('SelfDestructService', () {
    group('startTracking', () {
      test('should return same message if not self-destructing', () {
        final message = createTestMessage();
        final result = service.startTracking(message);

        expect(result.id, message.id);
        expect(service.isTracking(message.id), false);
      });

      test('should start tracking self-destructing message', () {
        final message = createTestMessage(selfDestructAfter: 30);
        final result = service.startTracking(message);

        expect(result.isDestructionStarted, true);
        expect(result.destroyedAt, isNotNull);
        expect(service.isTracking(message.id), true);
      });

      test('should not restart tracking for already tracked message', () {
        final message = createTestMessage(selfDestructAfter: 30);
        final result1 = service.startTracking(message);
        final result2 = service.startTracking(message);

        expect(result1.destroyedAt, result2.destroyedAt);
      });

      test('should preserve existing destroyedAt', () {
        final destroyedAt = DateTime.now().add(const Duration(seconds: 15));
        final message = createTestMessage(
          selfDestructAfter: 30,
          destroyedAt: destroyedAt,
        );
        final result = service.startTracking(message);

        expect(result.destroyedAt, destroyedAt);
      });
    });

    group('stopTracking', () {
      test('should stop tracking message', () {
        final message = createTestMessage(selfDestructAfter: 30);
        service.startTracking(message);

        expect(service.isTracking(message.id), true);

        service.stopTracking(message.id);

        expect(service.isTracking(message.id), false);
      });

      test('should handle stopping non-tracked message', () {
        expect(() => service.stopTracking('non-existent'), returnsNormally);
      });
    });

    group('stopTrackingRoom', () {
      test('should stop tracking all messages in room', () {
        final msg1 = createTestMessage(
          id: '\$event1',
          roomId: '!room1:example.com',
          selfDestructAfter: 30,
        );
        final msg2 = createTestMessage(
          id: '\$event2',
          roomId: '!room1:example.com',
          selfDestructAfter: 60,
        );
        final msg3 = createTestMessage(
          id: '\$event3',
          roomId: '!room2:example.com',
          selfDestructAfter: 30,
        );

        service.startTracking(msg1);
        service.startTracking(msg2);
        service.startTracking(msg3);

        expect(service.trackedMessages.length, 3);

        service.stopTrackingRoom('!room1:example.com');

        expect(service.trackedMessages.length, 1);
        expect(service.isTracking(msg1.id), false);
        expect(service.isTracking(msg2.id), false);
        expect(service.isTracking(msg3.id), true);
      });
    });

    group('getRemainingSeconds', () {
      test('should return null for non-tracked message', () {
        expect(service.getRemainingSeconds('non-existent'), null);
      });

      test('should return remaining seconds for tracked message', () {
        final message = createTestMessage(selfDestructAfter: 30);
        service.startTracking(message);

        final remaining = service.getRemainingSeconds(message.id);
        expect(remaining, isNotNull);
        expect(remaining, greaterThanOrEqualTo(29));
        expect(remaining, lessThanOrEqualTo(30));
      });
    });

    group('getTrackedMessagesForRoom', () {
      test('should return empty list for room with no tracked messages', () {
        final messages = service.getTrackedMessagesForRoom('!unknown:room');
        expect(messages, isEmpty);
      });

      test('should return tracked messages for specific room', () {
        final msg1 = createTestMessage(
          id: '\$event1',
          roomId: '!room1:example.com',
          selfDestructAfter: 30,
        );
        final msg2 = createTestMessage(
          id: '\$event2',
          roomId: '!room2:example.com',
          selfDestructAfter: 30,
        );

        service.startTracking(msg1);
        service.startTracking(msg2);

        final room1Messages = service.getTrackedMessagesForRoom('!room1:example.com');
        expect(room1Messages.length, 1);
        expect(room1Messages.first.id, '\$event1');
      });
    });

    group('callbacks', () {
      test('should call destruction callback when message expires', () async {
        String? destroyedMessageId;
        String? destroyedRoomId;

        service.onMessageDestroyed((messageId, roomId) {
          destroyedMessageId = messageId;
          destroyedRoomId = roomId;
        });

        // Create a message that's already expired
        final pastTime = DateTime.now().subtract(const Duration(seconds: 1));
        final message = createTestMessage(
          selfDestructAfter: 1,
          destroyedAt: pastTime,
        );

        service.startTracking(message);

        // Wait a bit for async processing
        await Future.delayed(const Duration(milliseconds: 100));

        expect(destroyedMessageId, message.id);
        expect(destroyedRoomId, message.roomId);
      });

      test('should allow removing callbacks', () {
        var callCount = 0;
        void callback(String messageId, String roomId) {
          callCount++;
        }

        service.onMessageDestroyed(callback);
        service.removeDestructionCallback(callback);

        // Trigger destruction
        final pastTime = DateTime.now().subtract(const Duration(seconds: 1));
        final message = createTestMessage(
          selfDestructAfter: 1,
          destroyedAt: pastTime,
        );

        service.startTracking(message);

        expect(callCount, 0);
      });
    });

    group('clear', () {
      test('should clear all tracked messages', () {
        final msg1 = createTestMessage(id: '\$event1', selfDestructAfter: 30);
        final msg2 = createTestMessage(id: '\$event2', selfDestructAfter: 60);

        service.startTracking(msg1);
        service.startTracking(msg2);

        expect(service.trackedMessages.length, 2);

        service.clear();

        expect(service.trackedMessages.length, 0);
      });
    });

    group('formatDuration', () {
      test('should format seconds', () {
        expect(SelfDestructService.formatDuration(5), '5s');
        expect(SelfDestructService.formatDuration(30), '30s');
        expect(SelfDestructService.formatDuration(59), '59s');
      });

      test('should format minutes', () {
        expect(SelfDestructService.formatDuration(60), '1m');
        expect(SelfDestructService.formatDuration(90), '1m 30s');
        expect(SelfDestructService.formatDuration(300), '5m');
        expect(SelfDestructService.formatDuration(3599), '59m 59s');
      });

      test('should format hours', () {
        expect(SelfDestructService.formatDuration(3600), '1h');
        expect(SelfDestructService.formatDuration(5400), '1h 30m');
        expect(SelfDestructService.formatDuration(7200), '2h');
        expect(SelfDestructService.formatDuration(86399), '23h 59m');
      });

      test('should format days', () {
        expect(SelfDestructService.formatDuration(86400), '1d');
        expect(SelfDestructService.formatDuration(129600), '1d 12h');
        expect(SelfDestructService.formatDuration(604800), '7d');
      });
    });

    group('getFormattedRemainingTime', () {
      test('should return null for non-tracked message', () {
        expect(service.getFormattedRemainingTime('non-existent'), null);
      });

      test('should return formatted time for tracked message', () {
        final message = createTestMessage(selfDestructAfter: 65);
        service.startTracking(message);

        final formatted = service.getFormattedRemainingTime(message.id);
        expect(formatted, isNotNull);
        expect(formatted, contains('m'));
      });
    });
  });

  group('SelfDestructTimer', () {
    group('presets', () {
      test('should have 8 presets', () {
        expect(SelfDestructTimer.presets.length, 8);
      });

      test('should have correct preset values', () {
        const presets = SelfDestructTimer.presets;

        expect(presets[0].seconds, 5);
        expect(presets[0].name, '5 秒');

        expect(presets[1].seconds, 10);
        expect(presets[1].name, '10 秒');

        expect(presets[2].seconds, 30);
        expect(presets[2].name, '30 秒');

        expect(presets[3].seconds, 60);
        expect(presets[3].name, '1 分钟');

        expect(presets[4].seconds, 300);
        expect(presets[4].name, '5 分钟');

        expect(presets[5].seconds, 3600);
        expect(presets[5].name, '1 小时');

        expect(presets[6].seconds, 86400);
        expect(presets[6].name, '24 小时');

        expect(presets[7].seconds, 604800);
        expect(presets[7].name, '1 周');
      });
    });

    group('fromSeconds', () {
      test('should find preset by seconds', () {
        final preset = SelfDestructTimer.fromSeconds(60);
        expect(preset, isNotNull);
        expect(preset!.name, '1 分钟');
      });

      test('should return null for non-preset value', () {
        final preset = SelfDestructTimer.fromSeconds(45);
        expect(preset, null);
      });
    });

    group('getDisplayName', () {
      test('should return preset name for preset value', () {
        expect(SelfDestructTimer.getDisplayName(60), '1 分钟');
        expect(SelfDestructTimer.getDisplayName(3600), '1 小时');
      });

      test('should return formatted duration for non-preset value', () {
        expect(SelfDestructTimer.getDisplayName(45), '45s');
        expect(SelfDestructTimer.getDisplayName(90), '1m 30s');
      });
    });
  });
}
