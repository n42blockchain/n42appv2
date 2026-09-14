import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/room_join_service.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_group_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_room_datasource.dart';
import 'package:n42_chat/src/data/repositories/group_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/token_gate_entity.dart';

class _Manager extends Mock implements MatrixClientManager {}

class _Client extends Mock implements matrix.Client {}

class _Room extends Mock implements matrix.Room {}

class _Event extends Mock implements matrix.Event {}

void main() {
  const id = '!room:test';
  const alias = '#room:test';
  const passed = TokenGateVerificationResult(passed: true);
  const denied = TokenGateVerificationResult(
    passed: false,
    errorMessage: 'Balance too low',
  );
  late _Manager manager;
  late _Client client;
  late _Room room;
  late _Event event;
  late RoomJoinService service;
  late Map<String, dynamic>? gate;
  late Future<TokenGateVerificationResult> Function(String) verifier;
  late List<String> checks;

  setUp(() {
    manager = _Manager();
    client = _Client();
    room = _Room();
    event = _Event();
    gate = null;
    checks = [];
    verifier = (_) async => passed;
    when(() => manager.client).thenReturn(client);
    when(() => client.userID).thenReturn('@user:test');
    when(() => client.getRoomById(id)).thenReturn(room);
    when(() => room.membership).thenReturn(matrix.Membership.invite);
    when(
      () => room.getState('n42.token_gate'),
    ).thenAnswer((_) => gate == null ? null : event);
    when(() => event.content).thenAnswer((_) => gate!);
    when(() => room.join()).thenAnswer((_) async {});
    when(() => client.getRoomIdByAlias(alias)).thenAnswer(
      (_) async =>
          matrix.GetRoomIdByAliasResponse(roomId: id, servers: ['test']),
    );
    when(
      () => client.joinRoom(id, via: any(named: 'via')),
    ).thenAnswer((_) async => id);
    service = RoomJoinService(
      manager,
      verifyGate: (roomId) {
        checks.add(roomId);
        return verifier(roomId);
      },
    );
  });

  for (final invalid in [
    '',
    'room:test',
    '!room',
    '#room',
    '!room:bad host',
    '!room\n:test',
    '!room:',
    '!:test',
  ]) {
    test(
      'rejects invalid target ${invalid.replaceAll('\n', r'\n')} without SDK work',
      () async {
        await expectLater(service.join(invalid), throwsFormatException);
        verifyZeroInteractions(client);
      },
    );
  }
  test('missing client fails before admission', () async {
    when(() => manager.client).thenReturn(null);
    await expectLater(service.join(id), throwsStateError);
    verifyNever(() => room.join());
  });
  test('trims room ID and preserves an ordinary invite', () async {
    expect(await service.join(' $id '), id);
    expect(checks, isEmpty);
    verify(() => room.join()).called(1);
  });
  test('joined member does not repeat verification or join', () async {
    gate = {'enabled': true};
    when(() => room.membership).thenReturn(matrix.Membership.join);
    expect(await service.join(id), id);
    expect(checks, isEmpty);
    verifyNever(() => room.join());
  });
  test('disabled gate needs no verifier', () async {
    gate = {'enabled': false};
    expect(await RoomJoinService(manager).join(id), id);
    verify(() => room.join()).called(1);
  });
  for (final enabled in [true, null, 'invalid']) {
    test('non-disabled gate $enabled fails without a verifier', () async {
      gate = {'enabled': enabled};
      await expectLater(
        RoomJoinService(manager).join(id),
        throwsA(isA<RoomAdmissionException>()),
      );
      verifyNever(() => room.join());
    });
  }
  test('failed verification carries the exact result and skips join', () async {
    gate = {'enabled': true};
    verifier = (_) async => denied;
    await expectLater(
      service.join(id),
      throwsA(
        isA<RoomAdmissionException>()
            .having((e) => e.result, 'result', same(denied))
            .having((e) => e.toString(), 'message', denied.errorMessage),
      ),
    );
    expect(checks, [id]);
    verifyNever(() => room.join());
  });
  test('verification error without message has a readable fallback', () {
    expect(
      const RoomAdmissionException(
        id,
        TokenGateVerificationResult(passed: false),
      ).toString(),
      isNotEmpty,
    );
  });
  test('verifier exception cannot allow SDK join', () async {
    gate = {'enabled': true};
    verifier = (_) async => throw StateError('RPC unavailable');
    await expectLater(service.join(id), throwsStateError);
    verifyNever(() => room.join());
  });
  test('state read error cannot become an ungated join', () async {
    when(
      () => room.getState('n42.token_gate'),
    ).thenThrow(StateError('state unavailable'));
    await expectLater(service.join(id), throwsStateError);
    verifyNever(() => room.join());
  });
  test('successful gate checks once before joining', () async {
    gate = {'enabled': true};
    expect(await service.join(id), id);
    expect(checks, [id]);
    verify(() => room.join()).called(1);
  });
  for (final next in <Map<String, dynamic>?>[
    {
      'enabled': true,
      'rules': ['changed'],
    },
    {'enabled': false},
    null,
  ]) {
    test(
      'changed or removed gate during verification requires retry: $next',
      () async {
        gate = {'enabled': true};
        verifier = (_) async {
          gate = next;
          return passed;
        };
        await expectLater(
          service.join(id),
          throwsA(isA<RoomAdmissionException>()),
        );
        verifyNever(() => room.join());
      },
    );
  }
  test('replacement room state during verification is checked again', () async {
    gate = {'enabled': true};
    verifier = (_) async {
      when(() => client.getRoomById(id)).thenReturn(null);
      return passed;
    };
    await expectLater(service.join(id), throwsA(isA<RoomAdmissionException>()));
    verifyNever(() => room.join());
  });
  test('in-place gate mutation is detected', () async {
    gate = {
      'enabled': true,
      'rules': <String>['original'],
    };
    verifier = (_) async {
      (gate!['rules'] as List<String>).add('changed');
      return passed;
    };
    await expectLater(service.join(id), throwsA(isA<RoomAdmissionException>()));
    verifyNever(() => room.join());
  });
  for (final switchClient in [true, false]) {
    test(
      'session change during verification is rejected ($switchClient)',
      () async {
        gate = {'enabled': true};
        verifier = (_) async {
          if (switchClient) {
            when(() => manager.client).thenReturn(_Client());
          } else {
            when(() => client.userID).thenReturn('@other:test');
          }
          return passed;
        };
        await expectLater(service.join(id), throwsStateError);
        verifyNever(() => room.join());
      },
    );
  }
  test('alias resolves once and checks the immutable room ID', () async {
    gate = {'enabled': true};
    expect(await service.join(' $alias '), id);
    expect(checks, [id]);
    verify(() => client.getRoomIdByAlias(alias)).called(1);
    verifyNever(() => client.joinRoom(alias));
  });
  for (final resolvedId in <String?>[
    null,
    '#other:test',
    '!bad',
    '!bad:bad host',
  ]) {
    test('invalid alias result $resolvedId cannot join', () async {
      when(() => client.getRoomIdByAlias(alias)).thenAnswer(
        (_) async => matrix.GetRoomIdByAliasResponse(roomId: resolvedId),
      );
      await expectLater(service.join(alias), throwsFormatException);
      verifyNever(() => room.join());
    });
  }
  test('alias resolution failure is surfaced', () async {
    when(
      () => client.getRoomIdByAlias(alias),
    ).thenThrow(StateError('alias unavailable'));
    await expectLater(service.join(alias), throwsStateError);
    verifyNever(() => room.join());
  });
  test('session change while resolving alias blocks admission', () async {
    when(() => client.getRoomIdByAlias(alias)).thenAnswer((_) async {
      when(() => manager.client).thenReturn(null);
      return matrix.GetRoomIdByAliasResponse(roomId: id);
    });
    await expectLater(service.join(alias), throwsStateError);
    verifyNever(() => room.join());
  });
  test(
    'unknown room preserves homeserver join policy and alias routing',
    () async {
      when(() => client.getRoomById(id)).thenReturn(null);
      expect(await service.join(alias), id);
      expect(checks, isEmpty);
      verify(() => client.joinRoom(id, via: ['test'])).called(1);
    },
  );
  test('unexpected returned room ID is rejected', () async {
    when(() => client.getRoomById(id)).thenReturn(null);
    when(
      () => client.joinRoom(id, via: null),
    ).thenAnswer((_) async => '!different:test');
    await expectLater(service.join(id), throwsStateError);
  });
  for (final knownRoom in [true, false]) {
    test(
      'account change during SDK join prevents stale success ($knownRoom)',
      () async {
        if (knownRoom) {
          when(() => room.join()).thenAnswer((_) async {
            when(() => manager.client).thenReturn(null);
          });
        } else {
          when(() => client.getRoomById(id)).thenReturn(null);
          when(() => client.joinRoom(id, via: null)).thenAnswer((_) async {
            when(() => manager.client).thenReturn(null);
            return id;
          });
        }
        await expectLater(service.join(id), throwsStateError);
      },
    );
  }
  test('simultaneous alias and ID taps share verification and join', () async {
    gate = {'enabled': true};
    final balance = Completer<TokenGateVerificationResult>();
    verifier = (_) => balance.future;
    final direct = service.join(id);
    final byAlias = service.join(alias);
    await Future<void>.delayed(Duration.zero);
    expect(checks, [id]);
    balance.complete(passed);
    expect(await Future.wait([direct, byAlias]), [id, id]);
    verify(() => room.join()).called(1);
  });
  test('failed admission is removed from pending work and can retry', () async {
    gate = {'enabled': true};
    verifier = (_) async => denied;
    await expectLater(service.join(id), throwsA(isA<RoomAdmissionException>()));
    verifier = (_) async => passed;
    expect(await service.join(id), id);
    expect(checks, [id, id]);
    verify(() => room.join()).called(1);
  });
  test('SDK failure releases pending join so retry can succeed', () async {
    when(() => room.join()).thenThrow(StateError('offline'));
    await expectLater(service.join(id), throwsStateError);
    when(() => room.join()).thenAnswer((_) async {});
    expect(await service.join(id), id);
    verify(() => room.join()).called(2);
  });

  for (final path in [
    'repository ID',
    'repository alias',
    'repository invite',
    'group ID',
    'group alias',
    'group invite',
    'room ID',
  ]) {
    test('$path cannot bypass known token gate', () async {
      gate = {'enabled': true};
      verifier = (_) async => denied;
      final groups = MatrixGroupDataSource(manager, roomJoinService: service);
      final rooms = MatrixRoomDataSource(manager, roomJoinService: service);
      final repository = GroupRepositoryImpl(
        groups,
        manager,
        roomJoinService: service,
      );
      final operation = switch (path) {
        'repository ID' => repository.joinGroup(id),
        'repository alias' => repository.joinGroupByAlias(alias),
        'repository invite' => repository.acceptGroupInvite(id),
        'group ID' => groups.joinGroup(id),
        'group alias' => groups.joinGroupByAlias(alias),
        'group invite' => groups.acceptGroupInvite(id),
        _ => rooms.joinRoom(id),
      };
      await expectLater(operation, throwsA(isA<RoomAdmissionException>()));
      expect(checks, [id]);
      verifyNever(() => room.join());
      verifyNever(() => client.joinRoom(any(), via: any(named: 'via')));
    });
  }
}
