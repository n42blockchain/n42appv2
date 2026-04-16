import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/voice_room_entity.dart';
import 'package:n42_chat/src/presentation/blocs/voice_room/voice_room_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/voice_room/voice_room_event.dart';
import 'package:n42_chat/src/presentation/blocs/voice_room/voice_room_state.dart';
import 'package:n42_chat/src/presentation/pages/voice_room/voice_room_page.dart';

class MockVoiceRoomBloc extends Mock implements VoiceRoomBloc {}

class FakeVoiceRoomEvent extends Fake implements VoiceRoomEvent {}

void main() {
  late MockVoiceRoomBloc mockVoiceRoomBloc;
  late StreamController<VoiceRoomState> stateController;

  const room = VoiceRoomEntity(
    roomId: '!voice:server',
    name: 'Voice Room',
    creatorId: '@host:server',
  );

  setUpAll(() {
    registerFallbackValue(FakeVoiceRoomEvent());
  });

  setUp(() {
    mockVoiceRoomBloc = MockVoiceRoomBloc();
    stateController = StreamController<VoiceRoomState>.broadcast();

    when(
      () => mockVoiceRoomBloc.state,
    ).thenReturn(
      const VoiceRoomState(
        room: room,
        isConnected: true,
        myRole: VoiceRoomRole.host,
      ),
    );
    when(() => mockVoiceRoomBloc.stream).thenAnswer((_) => stateController.stream);
    when(() => mockVoiceRoomBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateController.close();
  });

  Widget buildPage() {
    return MaterialApp(
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: BlocProvider<VoiceRoomBloc>.value(
        value: mockVoiceRoomBloc,
        child: const VoiceRoomPage(roomId: '!voice:server'),
      ),
    );
  }

  testWidgets('confirm end closes dialog but keeps page mounted until disconnect',
      (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Voice Room'), findsOneWidget);

    await tester.tap(find.text('End Room'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to end this voice room?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'End Room'));
    await tester.pumpAndSettle();

    verify(() => mockVoiceRoomBloc.add(const EndVoiceRoom())).called(1);
    expect(find.text('Voice Room'), findsOneWidget);
    expect(find.text('Are you sure you want to end this voice room?'), findsNothing);
  });
}
