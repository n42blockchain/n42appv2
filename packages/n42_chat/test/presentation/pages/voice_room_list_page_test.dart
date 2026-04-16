import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/domain/entities/voice_room_entity.dart';
import 'package:n42_chat/src/domain/repositories/voice_room_repository.dart';
import 'package:n42_chat/src/presentation/pages/voice_room/voice_room_list_page.dart';
import 'package:n42_chat/src/services/voip/voice_room_service.dart';

class MockVoiceRoomRepository extends Mock implements IVoiceRoomRepository {}

class MockVoiceRoomService extends Mock implements VoiceRoomService {}

VoiceRoomEntity _makeRoom({String roomId = '!voice:server', String name = 'Room'}) {
  return VoiceRoomEntity(
    roomId: roomId,
    name: name,
    creatorId: '@host:server',
    status: VoiceRoomStatus.live,
    createdAt: DateTime(2026, 3, 15),
  );
}

void main() {
  late MockVoiceRoomRepository mockRepo;
  late MockVoiceRoomService mockService;

  setUp(() {
    mockRepo = MockVoiceRoomRepository();
    mockService = MockVoiceRoomService();

    getIt.reset();
    getIt
      ..registerSingleton<IVoiceRoomRepository>(mockRepo)
      ..registerSingleton<VoiceRoomService>(mockService);

    when(() => mockRepo.getActiveVoiceRooms()).thenAnswer((_) async => const []);
    when(() => mockRepo.watchActiveVoiceRooms())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockService.stateStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockService.isMuted).thenReturn(true);
    when(() => mockService.myRole).thenReturn(VoiceRoomRole.listener);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildApp() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const VoiceRoomListPage(),
        ),
        GoRoute(
          path: '/voice-rooms/:roomId',
          builder: (context, state) => Text(
            'Joined ${state.pathParameters['roomId']}',
          ),
        ),
      ],
    );

    return MaterialApp.router(
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      locale: const Locale('en'),
      routerConfig: router,
    );
  }

  testWidgets('create dialog keeps input open on failure', (tester) async {
    when(
      () => mockRepo.createVoiceRoom(name: any(named: 'name'), topic: any(named: 'topic')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Weekly sync');
    await tester.enterText(find.byType(TextField).at(1), 'Planning');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Voice Room'), findsWidgets);
    expect(find.text('Failed to create voice room'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
      'Weekly sync',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller?.text,
      'Planning',
    );
  });

  testWidgets('create dialog closes and navigates on success', (tester) async {
    const roomId = '!voice-created:server';
    final room = _makeRoom(roomId: roomId, name: 'Weekly sync');

    when(
      () => mockRepo.createVoiceRoom(name: any(named: 'name'), topic: any(named: 'topic')),
    ).thenAnswer((_) async => room);
    when(() => mockService.joinRoom(roomId)).thenAnswer((_) async => true);
    when(() => mockRepo.getVoiceRoom(roomId)).thenAnswer((_) async => room);
    when(() => mockRepo.watchVoiceRoom(roomId))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockService.myRole).thenReturn(VoiceRoomRole.host);
    when(() => mockService.isMuted).thenReturn(false);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Weekly sync');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Voice Room'), findsNothing);
    expect(find.text('Joined $roomId'), findsOneWidget);
  });
}
