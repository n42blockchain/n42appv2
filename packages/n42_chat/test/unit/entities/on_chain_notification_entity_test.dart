import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/on_chain_notification_entity.dart';

void main() {
  test(
    'fromPushProtocol falls back to a stable synthetic id when payload_id is missing',
    () {
      final entity = OnChainNotificationEntity.fromPushProtocol({
        'sender': 'eip155:1:0xchannel',
        'epoch': '2025-06-01T12:00:00Z',
        'payload': {
          'notification': {
            'title': 'Channel - Transfer Alert',
            'body': 'Received 10 N42',
          },
          'data': {'asub': 'Transfer Alert', 'amsg': 'Received 10 N42'},
        },
      });

      expect(
        entity.id,
        'eip155:1:0xchannel|2025-06-01T12:00:00Z|Channel - Transfer Alert|Received 10 N42',
      );
      expect(entity.channelName, 'Channel');
      expect(entity.type, OnChainNotificationType.transfer);
    },
  );
}
