import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_contact_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_message_sender.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_uploader.dart';

class _Client extends Mock implements Client {}

class _Manager extends Mock implements MatrixClientManager {}

class _Room extends Mock implements Room {}

class _User extends Mock implements User {}

class _Uploader extends Mock implements MatrixMediaUploader {}

void main() {
  late _Client client;
  late _Room room;
  late _User partner;
  late MatrixContactDataSource contacts;
  late MatrixMessageSender sender;
  setUp(() {
    client = _Client();
    final manager = _Manager();
    room = _Room();
    partner = _User();
    when(() => manager.client).thenReturn(client);
    when(() => client.isLogged()).thenReturn(true);
    when(() => client.userID).thenReturn('@alice:test');
    when(() => client.rooms).thenReturn([room]);
    when(() => client.getRoomById('!dm:test')).thenReturn(room);
    when(() => room.id).thenReturn('!dm:test');
    when(() => room.encrypted).thenReturn(false);
    when(() => room.isDirectChat).thenReturn(true);
    when(() => room.membership).thenReturn(Membership.join);
    when(() => room.directChatMatrixID).thenReturn('@bob:test');
    when(
      () => room.unsafeGetUserFromMemoryOrFallback('@bob:test'),
    ).thenReturn(partner);
    when(() => partner.content).thenReturn({'membership': 'invite'});
    when(() => room.sendTextEvent(any())).thenAnswer((_) async => 'event');
    when(
      () => room.requestUser('@bob:test', requestProfile: false),
    ).thenAnswer((_) async => partner);
    contacts = MatrixContactDataSource(manager);
    sender = MatrixMessageSender(manager, _Uploader());
  });
  for (final membership in [
    Membership.invite,
    Membership.leave,
    Membership.ban,
    Membership.knock,
  ]) {
    test(
      'partner $membership is not a friend and cannot receive messages',
      () async {
        when(() => partner.content).thenReturn({'membership': membership.name});
        expect(contacts.getDirectChatContacts(), isEmpty);
        expect(contacts.getDirectChatRoomIdMap(), isEmpty);
        await expectLater(
          sender.sendTextMessage('!dm:test', 'hello'),
          throwsStateError,
        );
        await expectLater(
          sender.sendImageMessage(
            '!dm:test',
            imageBytes: Uint8List(1),
            filename: 'test.png',
          ),
          throwsStateError,
        );
        verifyNever(() => room.sendTextEvent(any()));
      },
    );
  }
  test(
    'missing member state cannot be mistaken for SDK fallback join',
    () async {
      when(() => partner.content).thenReturn({});
      when(() => partner.membership).thenReturn(Membership.join);
      expect(contacts.getDirectChatContacts(), isEmpty);
      expect(contacts.getDirectChatRoomIdMap(), isEmpty);
      await expectLater(
        sender.sendTextMessage('!dm:test', 'hello'),
        throwsStateError,
      );
    },
  );
  test(
    'lazy-loaded accepted member is fetched before listing and sending',
    () async {
      when(() => partner.content).thenReturn({});
      when(
        () => room.requestUser('@bob:test', requestProfile: false),
      ).thenAnswer((_) async {
        when(() => partner.content).thenReturn({'membership': 'join'});
        return partner;
      });
      await contacts.refreshDirectChatMembers();
      expect(contacts.getDirectChatContacts(), [partner]);
      expect(await sender.sendTextMessage('!dm:test', 'hello'), 'event');
    },
  );
  test(
    'sending also resolves membership without first opening Contacts',
    () async {
      when(() => partner.content).thenReturn({});
      when(
        () => room.requestUser('@bob:test', requestProfile: false),
      ).thenAnswer((_) async {
        when(() => partner.content).thenReturn({'membership': 'join'});
        return partner;
      });
      expect(await sender.sendTextMessage('!dm:test', 'hello'), 'event');
      verify(
        () => room.requestUser('@bob:test', requestProfile: false),
      ).called(1);
    },
  );
  test('fetched pending membership remains blocked', () async {
    when(() => partner.content).thenReturn({});
    when(() => room.requestUser('@bob:test', requestProfile: false)).thenAnswer(
      (_) async {
        when(() => partner.content).thenReturn({'membership': 'invite'});
        return partner;
      },
    );
    await expectLater(
      sender.sendTextMessage('!dm:test', 'hello'),
      throwsStateError,
    );
    expect(contacts.getOutgoingInvites(), [room]);
    expect(contacts.getDirectChatContacts(), isEmpty);
    verifyNever(() => room.sendTextEvent(any()));
  });
  test('scan creates a fresh invitation when the old peer has left', () async {
    when(() => partner.content).thenReturn({'membership': 'leave'});
    when(
      () => client.startDirectChat(
        '@bob:test',
        enableEncryption: true,
        skipExistingChat: true,
      ),
    ).thenAnswer((_) async => '!new:test');
    expect(await contacts.startDirectChat('@bob:test'), '!new:test');
    verify(
      () => client.startDirectChat(
        '@bob:test',
        enableEncryption: true,
        skipExistingChat: true,
      ),
    ).called(1);
  });
  test(
    'scanning a pending request reuses it without making duplicates',
    () async {
      expect(await contacts.startDirectChat('@bob:test'), '!dm:test');
    },
  );
  test('blocked room is not bypassed by creating another invitation', () async {
    when(() => partner.content).thenReturn({'membership': 'ban'});
    await expectLater(contacts.startDirectChat('@bob:test'), throwsStateError);
  });

  test('accepted friendship appears and permits sending', () async {
    when(() => partner.content).thenReturn({'membership': 'join'});
    expect(contacts.getDirectChatContacts(), [partner]);
    expect(contacts.getDirectChatRoomIdMap(), {'@bob:test': '!dm:test'});
    expect(await sender.sendTextMessage('!dm:test', 'hello'), 'event');
  });
  test('recipient must also accept before friendship appears', () {
    when(() => room.membership).thenReturn(Membership.invite);
    when(() => partner.content).thenReturn({'membership': 'join'});
    expect(contacts.getDirectChatContacts(), isEmpty);
    expect(contacts.getDirectChatRoomIdMap(), isEmpty);
  });
  test('group sending is unaffected by direct friendship approval', () async {
    when(() => room.directChatMatrixID).thenReturn(null);
    expect(await sender.sendTextMessage('!dm:test', 'hello'), 'event');
  });
}
