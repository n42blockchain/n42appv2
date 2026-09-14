import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_contact_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_moment_datasource.dart';
import 'package:n42_chat/src/data/repositories/contact_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';

class _Contacts extends Mock implements MatrixContactDataSource {}

class _Preferences extends Mock implements PreferencesDataSource {}

class _Moments extends Mock implements MatrixMomentDataSource {}

class _User extends Mock implements matrix.User {}

class _Room extends Mock implements matrix.Room {}

class _Profile extends Mock implements matrix.Profile {}

class _Presence extends Mock implements matrix.CachedPresence {}

void main() {
  late _Contacts contacts;
  late _Preferences preferences;
  late _Moments moments;
  late ContactRepositoryImpl repository;
  late Map<String, String> remarks;
  const alice = '@alice:test';
  const bob = '@bob:test';
  _User user(String id, String name, {Uri? avatar}) {
    final user = _User();
    when(() => user.id).thenAnswer((_) => id);
    when(() => user.calcDisplayname()).thenAnswer((_) => name);
    when(() => user.avatarUrl).thenAnswer((_) => avatar);
    when(() => contacts.getUserDisplayName(user)).thenAnswer((_) => name);
    return user;
  }

  _Profile profile(String id, {String? name}) {
    final profile = _Profile();
    when(() => profile.userId).thenAnswer((_) => id);
    when(() => profile.displayName).thenAnswer((_) => name);
    return profile;
  }

  _Room invite(String id, {String? inviter, _User? sender}) {
    final room = _Room();
    when(() => room.id).thenAnswer((_) => id);
    when(() => room.directChatMatrixID).thenAnswer((_) => inviter);
    if (inviter != null) {
      when(
        () => room.unsafeGetUserFromMemoryOrFallback(inviter),
      ).thenAnswer((_) => sender!);
    }
    return room;
  }

  setUp(() {
    contacts = _Contacts();
    preferences = _Preferences();
    moments = _Moments();
    repository = ContactRepositoryImpl(contacts, preferences, moments);
    remarks = {alice: 'Project Lead'};
    when(
      () => preferences.getContactRemarks(),
    ).thenAnswer((_) async => Map.of(remarks));
    when(
      () => preferences.getContactRemark(any()),
    ).thenAnswer((i) async => remarks[i.positionalArguments.first]);
    when(() => preferences.setContactRemark(any(), any())).thenAnswer((
      i,
    ) async {
      final id = i.positionalArguments[0] as String;
      final value = i.positionalArguments[1] as String?;
      if (value == null || value.isEmpty) {
        remarks.remove(id);
      } else {
        remarks[id] = value;
      }
    });
    when(() => contacts.isUserIgnored(any())).thenAnswer((_) => false);
    when(
      () => contacts.getDirectChatRoomIdMap(),
    ).thenAnswer((_) => {alice: '!alice:test'});
    when(
      () => contacts.getDirectChatContacts(),
    ).thenAnswer((_) => [user(alice, 'Alice'), user(bob, 'Bob')]);
    when(() => contacts.getUserProfile(any())).thenAnswer((_) async => null);
    when(() => contacts.getPendingInvites()).thenAnswer((_) => []);
  });

  group('contact search and identity', () {
    test('search matches the remark displayed in the contact list', () async {
      expect((await repository.searchContacts('project')).single.userId, alice);
    });
    test('search trims surrounding whitespace', () async {
      expect(
        (await repository.searchContacts('  ALICE  ')).single.userId,
        alice,
      );
    });
    test(
      'original display name remains searchable after setting a remark',
      () async {
        expect((await repository.searchContacts('ALICE')).single.userId, alice);
      },
    );
    test('Matrix identifier remains searchable', () async {
      expect((await repository.searchContacts('@bob:')).single.userId, bob);
    });
    test(
      'blank search returns contacts ordered by their visible names',
      () async {
        final result = await repository.searchContacts('  ');
        expect(result.map((c) => c.userId), [bob, alice]);
        expect(result.last.effectiveDisplayName, 'Project Lead');
        expect(result.last.isFriend, isTrue);
        expect(result.first.isFriend, isFalse);
        expect(result.last.directRoomId, '!alice:test');
      },
    );
    test('unmatched query returns no contacts', () async {
      expect(await repository.searchContacts('absent'), isEmpty);
    });
    test('unknown profile returns null', () async {
      expect(await repository.getContactById('missing'), isNull);
    });
    test(
      'profile with no display name keeps its identifier and block state',
      () async {
        when(
          () => contacts.getUserProfile(alice),
        ).thenAnswer((_) async => profile(alice));
        when(() => contacts.isUserIgnored(alice)).thenAnswer((_) => true);
        final result = (await repository.getContactById(alice))!;
        expect(result.displayName, alice);
        expect(result.isBlocked, isTrue);
        expect(result.remark, 'Project Lead');
        expect(result.isFriend, isFalse);
      },
    );
    test('directory search maps remote profiles and preserves limit', () async {
      final remote = profile(alice, name: 'Alice');
      when(
        () => contacts.searchUsers('alice', limit: 3),
      ).thenAnswer((_) async => [remote, profile(bob)]);
      when(
        () => contacts.getProfileAvatarUrl(remote),
      ).thenAnswer((_) => 'https://fixture.test/avatar');
      final result = await repository.searchUsers('alice', limit: 3);
      expect(result.first.avatarUrl, 'https://fixture.test/avatar');
      expect(result.last.displayName, bob);
      expect(result.first.presence, PresenceStatus.offline);
      verify(() => contacts.searchUsers('alice', limit: 3)).called(1);
    });
    test('blank directory query avoids remote search', () async {
      expect(await repository.searchUsers('  '), isEmpty);
      verifyNever(
        () => contacts.searchUsers(any(), limit: any(named: 'limit')),
      );
    });
  });
  group('remark persistence', () {
    test('returned remark maps cannot mutate the cache', () async {
      final values = await repository.getContactRemarks();
      values[alice] = 'Changed';
      expect(await repository.getContactRemark(alice), 'Project Lead');
    });
    test(
      'saved remark is available immediately without another read',
      () async {
        await repository.setContactRemark(bob, 'Friend');
        expect(await repository.getContactRemark(bob), 'Friend');
        verifyNever(() => preferences.getContactRemark(bob));
      },
    );
    for (final value in <String?>[null, '']) {
      test(
        'clearing with ${value == null ? 'null' : 'empty text'} removes the cached remark',
        () async {
          await repository.getContactRemarks();
          await repository.setContactRemark(alice, value);
          expect(await repository.getContactRemark(alice), isNull);
        },
      );
    }
    test('failed remark write retains the previous cached value', () async {
      await repository.getContactRemarks();
      when(
        () => preferences.setContactRemark(alice, 'New'),
      ).thenThrow(StateError('storage unavailable'));
      await expectLater(
        repository.setContactRemark(alice, 'New'),
        throwsStateError,
      );
      expect(await repository.getContactRemark(alice), 'Project Lead');
    });
    test('successful deletion clears both durable and cached remark', () async {
      await repository.getContactRemarks();
      when(() => contacts.deleteContact(alice)).thenAnswer((_) async {});
      await repository.deleteContact(alice);
      expect(await repository.getContactRemark(alice), isNull);
      expect(remarks, isNot(contains(alice)));
    });
    test('remote deletion failure preserves the remark', () async {
      await repository.getContactRemarks();
      when(
        () => contacts.deleteContact(alice),
      ).thenThrow(StateError('offline'));
      await expectLater(repository.deleteContact(alice), throwsStateError);
      expect(await repository.getContactRemark(alice), 'Project Lead');
      verifyNever(() => preferences.setContactRemark(alice, null));
    });
    test('ignored contacts load current remarks even on first read', () async {
      when(() => contacts.ignoredUsers).thenAnswer((_) => [alice, 'missing']);
      when(
        () => contacts.getUserProfile(alice),
      ).thenAnswer((_) async => profile(alice, name: 'Alice'));
      when(() => contacts.isUserIgnored(alice)).thenAnswer((_) => true);
      final result = (await repository.getIgnoredUsers()).single;
      expect(result.remark, 'Project Lead');
      expect(result.isBlocked, isTrue);
    });
  });
  group('friend invitations', () {
    test(
      'cached sender name and avatar avoid a remote profile request',
      () async {
        final sender = user(alice, 'Alice', avatar: Uri.parse('mxc://test/a'));
        when(
          () => contacts.getUserAvatarUrl(sender),
        ).thenAnswer((_) => 'https://fixture.test/a');
        when(() => contacts.getPendingInvites()).thenAnswer(
          (_) => [invite('!invite:test', inviter: alice, sender: sender)],
        );
        final result = (await repository.getPendingFriendRequests()).single;
        expect(result.userName, 'Alice');
        expect(result.userAvatarUrl, 'https://fixture.test/a');
        expect(result.id, '!invite:test');
        verifyNever(() => contacts.getUserProfile(alice));
      },
    );
    test('missing cached name resolves profile name and avatar', () async {
      when(() => contacts.getPendingInvites()).thenAnswer(
        (_) => [
          invite('!invite:test', inviter: alice, sender: user(alice, '')),
        ],
      );
      final remote = profile(alice, name: 'Remote Alice');
      when(
        () => contacts.getUserProfile(alice),
      ).thenAnswer((_) async => remote);
      when(
        () => contacts.getProfileAvatarUrl(remote),
      ).thenAnswer((_) => 'https://fixture.test/a');
      final result = (await repository.getPendingFriendRequests()).single;
      expect(result.userName, 'Remote Alice');
      expect(result.userAvatarUrl, 'https://fixture.test/a');
    });
    test('profile request failure uses the Matrix localpart', () async {
      when(() => contacts.getPendingInvites()).thenAnswer(
        (_) => [
          invite('!invite:test', inviter: alice, sender: user(alice, '')),
        ],
      );
      when(
        () => contacts.getUserProfile(alice),
      ).thenThrow(StateError('offline'));
      expect(
        (await repository.getPendingFriendRequests()).single.userName,
        'alice',
      );
    });
    test('invitation without an inviter remains representable', () async {
      when(
        () => contacts.getPendingInvites(),
      ).thenAnswer((_) => [invite('!invite:test')]);
      final result = (await repository.getPendingFriendRequests()).single;
      expect(result.userId, '');
      expect(result.userName, isNotEmpty);
    });
    test(
      'accepting a direct invite triggers optional Moments invitation',
      () async {
        when(
          () => contacts.acceptInvite('!invite:test'),
        ).thenAnswer((_) async {});
        when(() => contacts.getRoomById('!invite:test')).thenAnswer(
          (_) => invite(
            '!invite:test',
            inviter: alice,
            sender: user(alice, 'Alice'),
          ),
        );
        when(
          () => moments.inviteFriendToMomentRoom(alice),
        ).thenAnswer((_) async {});
        await repository.acceptFriendRequest('!invite:test');
        verify(() => moments.inviteFriendToMomentRoom(alice)).called(1);
      },
    );
    test(
      'optional Moments failure does not undo accepted friendship',
      () async {
        when(
          () => contacts.acceptInvite('!invite:test'),
        ).thenAnswer((_) async {});
        when(() => contacts.getRoomById('!invite:test')).thenAnswer(
          (_) => invite(
            '!invite:test',
            inviter: alice,
            sender: user(alice, 'Alice'),
          ),
        );
        when(
          () => moments.inviteFriendToMomentRoom(alice),
        ).thenThrow(StateError('offline'));
        await repository.acceptFriendRequest('!invite:test');
        verify(() => contacts.acceptInvite('!invite:test')).called(1);
      },
    );
    test('failed acceptance does not invite a user to Moments', () async {
      when(
        () => contacts.acceptInvite('!invite:test'),
      ).thenThrow(StateError('forbidden'));
      await expectLater(
        repository.acceptFriendRequest('!invite:test'),
        throwsStateError,
      );
      verifyNever(() => moments.inviteFriendToMomentRoom(any()));
    });
  });
  group('contact and presence streams', () {
    test(
      'contact stream without an SDK stream emits one initial snapshot',
      () async {
        final values = await repository.watchContacts().toList();
        expect(values, hasLength(1));
        expect(values.single, hasLength(2));
      },
    );
    test(
      'contact changes reload remarks without mutating the previous snapshot',
      () async {
        final updates = StreamController<void>();
        when(
          () => contacts.onContactsChanged,
        ).thenAnswer((_) => updates.stream);
        final snapshots = <List<ContactEntity>>[];
        final initial = Completer<void>();
        final next = Completer<void>();
        final subscription = repository.watchContacts().listen((value) {
          snapshots.add(value);
          if (snapshots.length == 1) {
            initial.complete();
          } else {
            next.complete();
          }
        });
        await initial.future;
        await pumpEventQueue();
        remarks[alice] = 'A Team';
        updates.add(null);
        await next.future;
        expect(snapshots.first.last.remark, 'Project Lead');
        expect(snapshots.last.first.remark, 'A Team');
        await subscription.cancel();
        expect(updates.hasListener, isFalse);
        await updates.close();
      },
    );
    test(
      'missing presence stream completes without fabricating statuses',
      () async {
        expect(await repository.watchOnlineStatus().toList(), isEmpty);
      },
    );
    test(
      'presence snapshots retain other users and do not share mutable maps',
      () async {
        final updates = StreamController<matrix.CachedPresence>();
        when(
          () => contacts.onPresenceChanged,
        ).thenAnswer((_) => updates.stream);
        _Presence presence(String id, matrix.PresenceType value) {
          final p = _Presence();
          when(() => p.userid).thenAnswer((_) => id);
          when(() => p.presence).thenAnswer((_) => value);
          return p;
        }

        final future = repository.watchOnlineStatus().toList();
        updates.add(presence(alice, matrix.PresenceType.online));
        updates.add(presence(bob, matrix.PresenceType.unavailable));
        updates.add(presence(alice, matrix.PresenceType.offline));
        await updates.close();
        final values = await future;
        expect(values, [
          {alice: true},
          {alice: true, bob: false},
          {alice: false, bob: false},
        ]);
      },
    );
    test('asynchronous presence and activity preserve SDK values', () async {
      final date = DateTime.utc(2026, 9, 14);
      when(() => contacts.isUserOnline(alice)).thenAnswer((_) async => true);
      when(
        () => contacts.getLastActiveTime(alice),
      ).thenAnswer((_) async => date);
      expect(await repository.isUserOnlineAsync(alice), isTrue);
      expect(await repository.getLastActiveTimeAsync(alice), date);
    });
    test('logged-out own status avoids an authenticated SDK read', () async {
      expect(await repository.getMyStatus(), isNull);
      verifyNever(() => contacts.getCurrentUserStatusMessage());
    });
    test('clearing status removes expiry as well as text', () async {
      when(
        () => contacts.setCurrentUserStatus(null, expiresAt: null),
      ).thenAnswer((_) async {});
      await repository.setMyStatus(null);
      verify(
        () => contacts.setCurrentUserStatus(null, expiresAt: null),
      ).called(1);
    });
  });
}
