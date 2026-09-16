import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/domain/repositories/moment_repository.dart';
import 'package:n42_chat/src/presentation/pages/moment/video_feed_page.dart';

class _Repository extends Mock implements IMomentRepository {}

void main() {
  for (final error in [false, true]) {
    testWidgets(
      'late feed request cannot restore revoked content (stream error: $error)',
      (tester) async {
        await getIt.reset();
        final repo = _Repository();
        final changes = StreamController<List<MomentEntity>>.broadcast();
        final old = Completer<List<MomentEntity>>();
        var reads = 0;
        when(
          () => repo.getMoments(limit: 50),
        ).thenAnswer((_) => reads++ == 0 ? old.future : Future.value([]));
        when(() => repo.watchMoments()).thenAnswer((_) => changes.stream);
        getIt.registerSingleton<IMomentRepository>(repo);
        addTearDown(() async {
          await changes.close();
          await getIt.reset();
        });
        await tester.pumpWidget(
          const MaterialApp(
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: VideoFeedPage(creatorActions: true),
          ),
        );
        await tester.pump();
        if (error) {
          changes.addError(StateError('Permissions changed'));
        } else {
          changes.add([]);
        }
        await tester.pumpAndSettle();
        expect(find.text('No videos yet'), findsOneWidget);
        old.complete([
          MomentEntity(
            id: 'revoked',
            userId: '@alice:hs',
            userName: 'Alice',
            content: 'Revoked content',
            timestamp: DateTime(2026),
            media: const [
              MomentMedia(url: '', httpUrl: '', type: MomentMediaType.video),
            ],
          ),
        ]);
        await tester.pumpAndSettle();
        expect(find.text('No videos yet'), findsOneWidget);
        expect(find.text('Revoked content'), findsNothing);
      },
    );
  }
}
