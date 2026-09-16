import 'package:flutter/material.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_permissions_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/contact_privacy_service.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_moment_datasource.dart';

class _Client extends Mock implements matrix.Client {}

class _Manager extends Mock implements MatrixClientManager {}

class _Room extends Mock implements matrix.Room {}

class _Event extends Mock implements matrix.Event {}

class _Timeline extends Mock implements matrix.Timeline {}

class _User extends Mock implements matrix.User {}

void main() {
  const me = '@me:hs';
  const friend = '@friend:hs';
  late _Client client;
  late _Manager manager;
  late ContactPrivacyService privacy;
  late Map<String, matrix.BasicEvent> account;
  late List<matrix.Room> rooms;
  late Map<String, Map<String, matrix.Event>> states;
  late Map<String, _Timeline> timelines;
  late Map<String, dynamic> serverSettings;

  matrix.Event event(
    String type,
    String sender,
    Map<String, dynamic> content, {
    String id = 'event',
  }) {
    final e = _Event();
    when(() => e.type).thenReturn(type);
    when(() => e.senderId).thenReturn(sender);
    when(() => e.content).thenReturn(content);
    when(() => e.eventId).thenReturn(id);
    when(() => e.redacted).thenReturn(false);
    when(() => e.originServerTs).thenReturn(DateTime.now());
    return e;
  }

  matrix.Room room(String id, String owner, {bool story = false}) {
    final r = _Room();
    final timeline = _Timeline();
    states[id] = {
      'm.room.create/': event('m.room.create', owner, {}),
      'm.room.join_rules/': event('m.room.join_rules', owner, {
        'join_rule': 'invite',
      }),
      'm.room.history_visibility/': event('m.room.history_visibility', owner, {
        'history_visibility': 'joined',
      }),
      'm.room.member/$friend': event('m.room.member', friend, {
        'membership': 'join',
      }),
    };
    timelines[id] = timeline;
    when(() => r.id).thenReturn(id);
    when(() => r.membership).thenReturn(matrix.Membership.join);
    when(() => r.tags).thenReturn({
      story ? ContactPrivacyService.storyTag : ContactPrivacyService.momentTag:
          matrix.Tag(),
    });
    when(() => r.getState(any(), any())).thenAnswer(
      (i) =>
          states[id]!['${i.positionalArguments[0]}/${i.positionalArguments[1]}'],
    );
    when(() => r.getTimeline()).thenAnswer((_) async => timeline);
    when(() => timeline.events).thenReturn([]);
    when(() => timeline.canRequestHistory).thenReturn(false);
    when(() => r.requestParticipants()).thenAnswer((_) async => []);
    when(
      () => r.sendEvent(any(), type: any(named: 'type')),
    ).thenAnswer((_) async => 'new-event');
    when(() => r.redactEvent(any())).thenAnswer((_) async => 'redaction');
    final user = _User();
    when(() => user.displayName).thenReturn('Friend');
    when(() => user.avatarUrl).thenReturn(null);
    when(() => r.unsafeGetUserFromMemoryOrFallback(any())).thenReturn(user);
    rooms.add(r);
    return r;
  }

  setUpAll(() => registerFallbackValue(matrix.PresenceType.online));
  setUp(() {
    client = _Client();
    manager = _Manager();
    account = {};
    rooms = [];
    states = {};
    timelines = {};
    serverSettings = {};
    when(() => manager.client).thenReturn(client);
    when(() => client.userID).thenReturn(me);
    when(() => client.accountData).thenReturn(account);
    when(() => client.rooms).thenReturn(rooms);
    when(() => client.getRoomById(any())).thenAnswer(
      (i) =>
          rooms.where((r) => r.id == i.positionalArguments.first).firstOrNull,
    );
    when(
      () => client.getAccountData(me, ContactPrivacyService.accountType),
    ).thenAnswer((_) async => serverSettings);
    when(
      () => client.setAccountData(me, ContactPrivacyService.accountType, any()),
    ).thenAnswer((i) async {
      serverSettings = Map<String, dynamic>.from(
        i.positionalArguments[2] as Map,
      );
    });
    when(
      () => client.setRoomStateWithKey(any(), any(), any(), any()),
    ).thenAnswer((i) async {
      final id = i.positionalArguments[0] as String;
      final type = i.positionalArguments[1] as String;
      states[id]!['$type/${i.positionalArguments[2]}'] = event(
        type,
        me,
        Map<String, dynamic>.from(i.positionalArguments[3] as Map),
      );
      return 'state-event';
    });
    when(
      () => client.ban(any(), any(), reason: any(named: 'reason')),
    ).thenAnswer((i) async {
      final id = i.positionalArguments[0] as String;
      final user = i.positionalArguments[1] as String;
      states[id]!['m.room.member/$user'] = event('m.room.member', me, {
        'membership': 'ban',
      });
    });
    when(() => client.unban(any(), any())).thenAnswer((i) async {
      states[i.positionalArguments[0]]!['m.room.member/${i.positionalArguments[1]}'] =
          event('m.room.member', me, {'membership': 'leave'});
    });
    when(
      () => client.inviteUser(any(), any(), reason: any(named: 'reason')),
    ).thenAnswer((_) async {});
    when(() => client.getPresence(me)).thenAnswer(
      (_) async => matrix.GetPresenceResponse(
        presence: matrix.PresenceType.unavailable,
        statusMsg: 'Working',
      ),
    );
    when(
      () => client.getAccountData(me, 'n42.user.status'),
    ).thenAnswer((_) async => {'message': 'Working'});
    when(
      () => client.setPresence(me, any(), statusMsg: any(named: 'statusMsg')),
    ).thenAnswer((_) async {});
    privacy = ContactPrivacyService(manager);
    getIt.registerSingleton<MatrixClientManager>(manager);
  });
  tearDown(() async => getIt.reset());

  Future<void> openPermissions(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: ContactPermissionsPage(userId: friend, displayName: 'Friend'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'permission switches save to account data and reload after reopening',
    (tester) async {
      await openPermissions(tester);
      await tester.tap(find.byType(Switch).at(2));
      await tester.pumpAndSettle();
      expect(privacy.hides(friend, incoming: true), isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await openPermissions(tester);
      expect(tester.widget<Switch>(find.byType(Switch).at(2)).value, isTrue);
    },
  );
  testWidgets('failed server enforcement remains visibly retryable', (
    tester,
  ) async {
    room('moments', me);
    room('stories', me, story: true);
    when(
      () => client.ban('moments', friend, reason: any(named: 'reason')),
    ).thenThrow(StateError('Offline'));
    await openPermissions(tester);
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  test(
    'hide their moments affects feeds and profiles, not their status',
    () async {
      final theirs = room('theirs', friend);
      await privacy.save(friend, {'hideTheirMoments': true});
      expect(privacy.canView(theirs, friend), isFalse);
      expect(privacy.canView(theirs, friend, story: true), isTrue);
      verifyNever(() => client.ban(any(), any(), reason: any(named: 'reason')));
      await privacy.save(friend, {'hideTheirMoments': false});
      expect(privacy.canView(theirs, friend), isTrue);
    },
  );

  for (final flag in ['hideMyMoments', 'hideMyStatus', 'chatOnly']) {
    test(
      '$flag applies server membership only to the intended owned rooms',
      () async {
        room(
          'foreign',
          friend,
        ); // Must never treat the first tagged room as ours.
        final moments = room('moments', me);
        final stories = room('stories', me, story: true);
        expect(await privacy.ownRoom(), moments);
        expect(await privacy.ownRoom(story: true), stories);
        await privacy.save(friend, {flag: true});
        expect(
          states['moments']!['m.room.member/$friend']!.content['membership'],
          flag == 'hideMyStatus' ? 'join' : 'ban',
        );
        expect(
          states['stories']!['m.room.member/$friend']!.content['membership'],
          flag == 'hideMyMoments' ? 'join' : 'ban',
        );
        verifyNever(
          () => client.ban('foreign', any(), reason: any(named: 'reason')),
        );
        expect(serverSettings[friend], {flag: true});
        await privacy.save(friend, {flag: false});
        verify(
          () => client.inviteUser(
            flag == 'hideMyStatus' ? 'stories' : 'moments',
            friend,
            reason: any(named: 'reason'),
          ),
        ).called(1);
      },
    );
  }

  test(
    'hidden text status is moved out of global presence without changing availability',
    () async {
      room('moments', me);
      room('stories', me, story: true);
      await privacy.save(friend, {'hideMyStatus': true});
      verify(
        () => client.setRoomStateWithKey('stories', 'n42.user.status', '', {
          'message': 'Working',
        }),
      ).called(1);
      verify(
        () => client.setPresence(
          me,
          matrix.PresenceType.unavailable,
          statusMsg: '',
        ),
      ).called(1);
    },
  );

  test(
    'active legacy statuses are copied before shared-room redaction',
    () async {
      final old = room('moments', me);
      final status = room('stories', me, story: true);
      final content = {
        'story_id': 'status-1',
        'content': 'Private status',
        'expires_at': DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      };
      final statusEvent = event('n42.story', me, content);
      when(() => timelines['moments']!.events).thenReturn([statusEvent]);
      await privacy.save(friend, {'hideMyStatus': true});
      verifyInOrder([
        () => client.ban('stories', friend, reason: 'Contact privacy'),
        () => status.sendEvent(content, type: 'n42.story'),
        () => old.redactEvent('event'),
      ]);
    },
  );

  test(
    'failed room enforcement is surfaced and retained for retry before publishing',
    () async {
      room('moments', me);
      room('stories', me, story: true);
      when(
        () => client.ban('moments', friend, reason: any(named: 'reason')),
      ).thenThrow(StateError('Offline'));
      await expectLater(
        privacy.save(friend, {'hideMyMoments': true}),
        throwsStateError,
      );
      expect(privacy.hides(friend), isTrue);
      await expectLater(
        MatrixMomentDataSource(manager).postMoment(content: 'Must not publish'),
        throwsStateError,
      );
      verifyNever(() => rooms.first.sendEvent(any(), type: any(named: 'type')));
    },
  );

  test(
    'hidden readers cannot be re-invited by automatic friendship synchronization',
    () async {
      room('moments', me);
      room('stories', me, story: true);
      await privacy.save(friend, {'chatOnly': true});
      await MatrixMomentDataSource(manager).inviteFriendToMomentRoom(friend);
      verifyNever(
        () => client.inviteUser(any(), friend, reason: any(named: 'reason')),
      );
    },
  );

  test(
    'cached detail and profile reads re-check local and remote permissions',
    () async {
      final theirs = room('theirs', friend);
      final momentEvent = event('n42.moment', friend, {
        'moment_id': 'm1',
        'content': 'Shared',
      }, id: 'm1');
      when(() => timelines['theirs']!.events).thenReturn([momentEvent]);
      final source = MatrixMomentDataSource(manager);
      expect(await source.getMoments(), hasLength(1));
      await privacy.save(friend, {'hideTheirMoments': true});
      expect(await source.getMomentById('m1'), isNull);
      expect(await source.getUserMoments(friend), isEmpty);
      await privacy.save(friend, {});
      states['theirs']!['${ContactPrivacyService.policyType}/'] = event(
        ContactPrivacyService.policyType,
        friend,
        {
          'moments': [me],
        },
      );
      expect(privacy.canView(theirs, friend), isFalse);
      expect(await source.getMoments(), isEmpty);
    },
  );

  test('permissions do not carry over to another signed-in account', () async {
    room('stories', me, story: true);
    await privacy.save(friend, {'chatOnly': true});
    final other = _Client();
    when(() => other.userID).thenReturn('@other:hs');
    when(() => other.accountData).thenReturn({});
    when(() => manager.client).thenReturn(other);
    expect(privacy.forUser(friend), isEmpty);
  });
}
