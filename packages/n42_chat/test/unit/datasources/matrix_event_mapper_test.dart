import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_event_mapper.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

class _MockClient extends Mock implements matrix.Client {}

class _MockRoom extends Mock implements matrix.Room {}

class _MockUser extends Mock implements matrix.User {}

class _MockEvent extends Mock implements matrix.Event {}

void main() {
  late _MockClient client;
  late _MockRoom room;
  late _MockUser user;
  late _MockEvent event;
  late MatrixEventMapper mapper;

  setUp(() {
    client = _MockClient();
    room = _MockRoom();
    user = _MockUser();
    event = _MockEvent();
    mapper = MatrixEventMapper(() => client);

    when(() => client.userID).thenReturn('@me:server.test');
    when(
      () => client.homeserver,
    ).thenReturn(Uri.parse('https://matrix.server.test'));

    when(() => room.id).thenReturn('!room:server.test');
    when(() => room.unsafeGetUserFromMemoryOrFallback(any())).thenReturn(user);

    when(() => user.calcDisplayname()).thenReturn('Alice');
    when(() => user.avatarUrl).thenReturn(null);

    when(() => event.eventId).thenReturn(r'$event-1');
    when(() => event.senderId).thenReturn('@alice:server.test');
    when(() => event.originServerTs).thenReturn(DateTime(2026, 3, 20, 12));
    when(() => event.type).thenReturn(matrix.EventTypes.Message);
    when(() => event.messageType).thenReturn(matrix.MessageTypes.Text);
    when(() => event.status).thenReturn(matrix.EventStatus.sent);
    when(() => event.redactedBecause).thenReturn(null);
    when(() => event.relationshipEventId).thenReturn(null);
    when(
      () => event.inReplyToEventId(
        includingFallback: any(named: 'includingFallback'),
      ),
    ).thenReturn(null);
    when(() => event.body).thenReturn('Original body');
    when(() => event.formattedText).thenReturn('<p>Original body</p>');
    when(() => event.plaintextBody).thenReturn('Original body');
  });

  test('uses latest bundled edit content for display', () {
    when(
      () => event.content,
    ).thenReturn({'msgtype': 'm.text', 'body': 'Original body'});
    when(() => event.unsigned).thenReturn({
      'm.relations': {
        'm.replace': {
          'origin_server_ts': 1710000000000,
          'content': {
            'm.new_content': {
              'msgtype': 'm.text',
              'body': '编辑后的 UTF-8 内容 👨‍👩‍👧‍👦',
              'format': 'org.matrix.custom.html',
              'formatted_body': '<p>编辑后的 UTF-8 内容 👨‍👩‍👧‍👦</p>',
            },
          },
        },
      },
    });

    final message = mapper.mapEventToMessage(event, room);

    expect(message.content, '编辑后的 UTF-8 内容 👨‍👩‍👧‍👦');
    expect(message.formattedContent, '<p>编辑后的 UTF-8 内容 👨‍👩‍👧‍👦</p>');
    expect(message.isEdited, isTrue);
    expect(
      message.editedAt,
      DateTime.fromMillisecondsSinceEpoch(1710000000000),
    );
  });

  test('uses m.in_reply_to event id for reply target', () {
    when(() => event.content).thenReturn({
      'msgtype': 'm.text',
      'body': '> <@alice:server.test> Original body\n\n回复内容',
      'm.relates_to': {
        'm.in_reply_to': {'event_id': r'$reply-target'},
      },
    });
    when(
      () => event.body,
    ).thenReturn('> <@alice:server.test> Original body\n\n回复内容');
    when(
      () => event.inReplyToEventId(includingFallback: false),
    ).thenReturn(r'$reply-target');

    final message = mapper.mapEventToMessage(event, room);

    expect(message.replyToId, r'$reply-target');
    expect(message.replyToSender, 'Alice');
    expect(message.replyToContent, 'Original body');
    expect(message.content, '回复内容');
  });

  test('does not treat thread fallback as a reply target', () {
    when(() => event.content).thenReturn({
      'msgtype': 'm.text',
      'body': '线程内容',
      'm.relates_to': {
        'rel_type': 'm.thread',
        'event_id': r'$thread-root',
        'is_falling_back': true,
        'm.in_reply_to': {'event_id': r'$thread-root'},
      },
    });
    when(() => event.body).thenReturn('线程内容');
    when(() => event.relationshipEventId).thenReturn(r'$thread-root');
    when(
      () => event.inReplyToEventId(includingFallback: false),
    ).thenReturn(null);

    final message = mapper.mapEventToMessage(event, room);

    expect(message.replyToId, isNull);
    expect(message.hasReply, isFalse);
    expect(message.threadRootId, r'$thread-root');
  });

  test(
    'keeps reply preview when an edited reply has clean replacement body',
    () {
      when(() => event.content).thenReturn({
        'msgtype': 'm.text',
        'body': '> <@alice:server.test> 原消息\n\n旧回复',
        'm.relates_to': {
          'm.in_reply_to': {'event_id': r'$reply-target'},
        },
      });
      when(() => event.body).thenReturn('> <@alice:server.test> 原消息\n\n旧回复');
      when(
        () => event.inReplyToEventId(includingFallback: false),
      ).thenReturn(r'$reply-target');
      when(() => event.unsigned).thenReturn({
        'm.relations': {
          'm.replace': {
            'origin_server_ts': 1710000000001,
            'content': {
              'm.new_content': {
                'msgtype': 'm.text',
                'body': '新回复内容',
                'format': 'org.matrix.custom.html',
                'formatted_body': '<p>新回复内容</p>',
              },
            },
          },
        },
      });

      final message = mapper.mapEventToMessage(event, room);

      expect(message.replyToId, r'$reply-target');
      expect(message.replyToSender, 'Alice');
      expect(message.replyToContent, '原消息');
      expect(message.content, '新回复内容');
      expect(message.formattedContent, '<p>新回复内容</p>');
    },
  );

  test('builds authenticated media download URL for mxc content', () {
    final url = mapper.getMediaUrl('mxc://m.si46.world/media123');

    expect(
      url,
      Uri.parse(
        'https://matrix.server.test/_matrix/client/v1/media/download/m.si46.world/media123',
      ),
    );
  });

  test('maps payment request messages to dedicated type and metadata', () {
    final expiresAt = DateTime(2026, 3, 21, 18).millisecondsSinceEpoch;
    when(() => event.messageType).thenReturn('n42.payment_request');
    when(() => event.body).thenReturn('收款请求 8 USDT');
    when(() => event.formattedText).thenReturn('');
    when(() => event.content).thenReturn({
      'msgtype': 'n42.payment_request',
      'body': '收款请求 8 USDT',
      'request_id': 'req_123',
      'receiver_address': '0xreceiver',
      'amount': '8',
      'token': 'USDT',
      'memo': 'Coffee ☕️',
      'expires_at': expiresAt,
    });

    final message = mapper.mapEventToMessage(event, room);

    expect(message.type, MessageType.paymentRequest);
    expect(message.content, 'Coffee ☕️');
    expect(message.metadata?.amount, '8');
    expect(message.metadata?.token, 'USDT');
    expect(message.metadata?.paymentRequestId, 'req_123');
    expect(message.metadata?.paymentReceiverAddress, '0xreceiver');
    expect(
      message.metadata?.paymentRequestExpiresAt,
      DateTime.fromMillisecondsSinceEpoch(expiresAt),
    );
  });

  test('extracts tx hash and memo for transfer messages', () {
    when(() => event.messageType).thenReturn('n42.transfer');
    when(() => event.body).thenReturn('转账 1.25 ETH');
    when(() => event.formattedText).thenReturn('');
    when(() => event.content).thenReturn({
      'msgtype': 'n42.transfer',
      'body': '转账 1.25 ETH',
      'amount': '1.25',
      'token': 'ETH',
      'status': 'completed',
      'tx_hash': '0xtxhash123',
      'memo': 'Lunch',
    });

    final message = mapper.mapEventToMessage(event, room);

    expect(message.type, MessageType.transfer);
    expect(message.content, 'Lunch');
    expect(message.metadata?.transferStatus, 'completed');
    expect(message.metadata?.txHash, '0xtxhash123');
  });
}
