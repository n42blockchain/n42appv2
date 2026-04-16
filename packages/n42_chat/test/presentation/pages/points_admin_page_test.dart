import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/points/points_config.dart';
import 'package:n42_chat/src/domain/repositories/points_repository.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_bloc.dart';
import 'package:n42_chat/src/presentation/pages/points/points_admin_page.dart';

class MockPointsRepository extends Mock implements IPointsRepository {}

void main() {
  late MockPointsRepository mockRepository;
  late PointsBloc pointsBloc;

  const initialConfig = PointsConfig(
    roomId: '!room:server',
    pointsName: 'Points',
    pointsSymbol: 'PTS',
  );

  setUpAll(() {
    registerFallbackValue(initialConfig);
  });

  setUp(() {
    mockRepository = MockPointsRepository();
    pointsBloc = PointsBloc(repository: mockRepository);

    when(
      () => mockRepository.getConfig('!room:server'),
    ).thenAnswer((_) async => initialConfig);
    when(
      () => mockRepository.updateConfig(any()),
    ).thenThrow(Exception('save failed'));
  });

  tearDown(() async {
    await pointsBloc.close();
  });

  testWidgets('failed config save keeps dirty state and save action visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PointsBloc>.value(
          value: pointsBloc,
          child: const PointsAdminPage(roomId: '!room:server'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'Stars');
    await tester.pump();

    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsOneWidget);
  });
}
