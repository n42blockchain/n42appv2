// Tests for ContactRepositoryImpl — contacts retrieval and friend requests.

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_contact_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_moment_datasource.dart';
import 'package:n42_chat/src/data/repositories/contact_repository_impl.dart';

class MockMatrixContactDataSource extends Mock
    implements MatrixContactDataSource {}

class MockPreferencesDataSource extends Mock implements PreferencesDataSource {}

class MockMatrixMomentDataSource extends Mock
    implements MatrixMomentDataSource {}

class MockUser extends Mock implements matrix.User {}

class MockRoom extends Mock implements matrix.Room {}

class MockProfile extends Mock implements matrix.Profile {}

void main() {
  late ContactRepositoryImpl repository;
  late MockMatrixContactDataSource mockContactDS;
  late MockPreferencesDataSource mockStorageDS;
  late MockMatrixMomentDataSource mockMomentDS;

  setUp(() {
    mockContactDS = MockMatrixContactDataSource();
    mockStorageDS = MockPreferencesDataSource();
    mockMomentDS = MockMatrixMomentDataSource();
    repository = ContactRepositoryImpl(
      mockContactDS,
      mockStorageDS,
      mockMomentDS,
    );
  });

  group('getContacts', () {
    test('returns empty list when no contacts', () async {
      when(() => mockContactDS.getDirectChatContacts()).thenReturn([]);
      when(() => mockContactDS.getDirectChatRoomIdMap()).thenReturn({});
      when(() => mockStorageDS.getContactRemarks()).thenAnswer((_) async => {});

      final contacts = await repository.getContacts();

      expect(contacts, isEmpty);
    });

    test('returns mapped contacts sorted by name', () async {
      final user1 = MockUser();
      final user2 = MockUser();

      when(() => user1.id).thenReturn('@bob:matrix.org');
      when(() => user1.displayName).thenReturn('Bob');
      when(() => user1.avatarUrl).thenReturn(null);
      when(() => mockContactDS.getUserDisplayName(user1)).thenReturn('Bob');
      when(() => mockContactDS.getUserAvatarUrl(user1)).thenReturn(null);
      when(
        () => mockContactDS.isUserIgnored('@bob:matrix.org'),
      ).thenReturn(false);

      when(() => user2.id).thenReturn('@alice:matrix.org');
      when(() => user2.displayName).thenReturn('Alice');
      when(() => user2.avatarUrl).thenReturn(null);
      when(() => mockContactDS.getUserDisplayName(user2)).thenReturn('Alice');
      when(() => mockContactDS.getUserAvatarUrl(user2)).thenReturn(null);
      when(
        () => mockContactDS.isUserIgnored('@alice:matrix.org'),
      ).thenReturn(true);

      when(
        () => mockContactDS.getDirectChatContacts(),
      ).thenReturn([user1, user2]);
      when(() => mockContactDS.getDirectChatRoomIdMap()).thenReturn({
        '@bob:matrix.org': '!r1:matrix.org',
        '@alice:matrix.org': '!r2:matrix.org',
      });
      when(() => mockStorageDS.getContactRemarks()).thenAnswer((_) async => {});

      final contacts = await repository.getContacts();

      expect(contacts, hasLength(2));
      // Sorted alphabetically: Alice before Bob
      expect(contacts[0].displayName, 'Alice');
      expect(contacts[1].displayName, 'Bob');
      expect(contacts[0].isBlocked, isTrue);
      expect(contacts[1].isBlocked, isFalse);
    });
  });

  group('startDirectChat', () {
    test('creates chat and invites to moment room', () async {
      const userId = '@alice:matrix.org';
      const roomId = '!dm1:matrix.org';

      when(
        () => mockStorageDS.shouldDefaultEncryptNewChats(),
      ).thenAnswer((_) async => true);
      when(
        () => mockContactDS.startDirectChat(userId, encrypted: true),
      ).thenAnswer((_) async => roomId);
      when(
        () => mockMomentDS.inviteFriendToMomentRoom(userId),
      ).thenAnswer((_) async {});

      final result = await repository.startDirectChat(userId);

      expect(result, roomId);
      verify(() => mockStorageDS.shouldDefaultEncryptNewChats()).called(1);
      verify(
        () => mockContactDS.startDirectChat(userId, encrypted: true),
      ).called(1);
      verify(() => mockMomentDS.inviteFriendToMomentRoom(userId)).called(1);
    });

    test('still returns roomId even if moment invite fails', () async {
      const userId = '@alice:matrix.org';
      const roomId = '!dm1:matrix.org';

      when(
        () => mockStorageDS.shouldDefaultEncryptNewChats(),
      ).thenAnswer((_) async => false);
      when(
        () => mockContactDS.startDirectChat(userId, encrypted: false),
      ).thenAnswer((_) async => roomId);
      when(
        () => mockMomentDS.inviteFriendToMomentRoom(userId),
      ).thenThrow(Exception('Moment room error'));

      final result = await repository.startDirectChat(userId);

      expect(result, roomId);
      verify(
        () => mockContactDS.startDirectChat(userId, encrypted: false),
      ).called(1);
    });
  });

  group('getContactById', () {
    test('loads remark cache before mapping remote profile', () async {
      final profile = MockProfile();
      const userId = '@alice:matrix.org';

      when(
        () => mockStorageDS.getContactRemarks(),
      ).thenAnswer((_) async => {userId: 'Alice Remark'});
      when(
        () => mockContactDS.getUserProfile(userId),
      ).thenAnswer((_) async => profile);
      when(() => profile.displayName).thenReturn('Alice');
      when(
        () => mockContactDS.getProfileAvatarUrl(profile),
      ).thenReturn('https://cdn.example/avatar.png');
      when(
        () => mockContactDS.getDirectChatRoomId(userId),
      ).thenReturn('!dm-alice:matrix.org');
      when(() => mockContactDS.isUserIgnored(userId)).thenReturn(true);

      final contact = await repository.getContactById(userId);

      expect(contact, isNotNull);
      expect(contact!.remark, 'Alice Remark');
      expect(contact.avatarUrl, 'https://cdn.example/avatar.png');
      expect(contact.directRoomId, '!dm-alice:matrix.org');
      expect(contact.isFriend, isTrue);
      expect(contact.isBlocked, isTrue);
    });
  });

  group('getPendingFriendRequests', () {
    test('returns empty list when no invites', () async {
      when(() => mockContactDS.getPendingInvites()).thenReturn([]);

      final requests = await repository.getPendingFriendRequests();

      expect(requests, isEmpty);
    });
  });

  group('acceptFriendRequest', () {
    test('delegates to datasource', () async {
      const roomId = '!invite1:matrix.org';
      when(() => mockContactDS.acceptInvite(roomId)).thenAnswer((_) async {});

      await repository.acceptFriendRequest(roomId);

      verify(() => mockContactDS.acceptInvite(roomId)).called(1);
    });
  });

  group('status', () {
    test('setMyStatus forwards a 24h-style expiry when requested', () async {
      DateTime? capturedExpiry;
      when(
        () => mockContactDS.setCurrentUserStatus(
          any(),
          expiresAt: any(named: 'expiresAt'),
        ),
      ).thenAnswer((invocation) async {
        capturedExpiry = invocation.namedArguments[#expiresAt] as DateTime?;
      });

      final before = DateTime.now().toUtc();
      await repository.setMyStatus(
        'Gaming',
        expiresIn: const Duration(hours: 24),
      );

      final after = DateTime.now().toUtc();
      expect(capturedExpiry, isNotNull);
      expect(
        capturedExpiry!.isAfter(before.add(const Duration(hours: 23))),
        isTrue,
      );
      expect(
        capturedExpiry!.isBefore(after.add(const Duration(hours: 25))),
        isTrue,
      );
    });

    test('getMyStatus uses current-user timed status path', () async {
      when(() => mockContactDS.currentUserId).thenReturn('@me:matrix.org');
      when(
        () => mockContactDS.getCurrentUserStatusMessage(),
      ).thenAnswer((_) async => 'Busy');

      final result = await repository.getMyStatus();

      expect(result, 'Busy');
      verify(() => mockContactDS.getCurrentUserStatusMessage()).called(1);
    });
  });
}
