import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/core/services/moment_location_resolver.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/domain/repositories/moment_repository.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_detail_page.dart';
import 'package:n42_chat/src/presentation/pages/moment/video_feed_page.dart';
import 'package:n42_chat/src/presentation/widgets/chat/message_bubble.dart';
import 'package:n42_chat/src/presentation/widgets/chat/message_status_indicator.dart';

class _Repository extends Mock implements IMomentRepository {}

class _Places extends GeocodingPlatform {
  bool fail = false;
  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    if (fail) throw StateError('Offline');
    return [
      const Placemark(
        street: '123 King St',
        locality: 'Toronto',
        administrativeArea: 'Ontario',
        country: 'Canada',
      ),
    ];
  }
}

void main() {
  test(
    'location resolves a readable address and retains coordinates offline',
    () async {
      final original = GeocodingPlatform.instance;
      final places = _Places();
      GeocodingPlatform.instance = places;
      addTearDown(() => GeocodingPlatform.instance = original ?? _Places());
      final location = await resolveMomentLocation(43.6, -79.4);
      expect(location.displayText, contains('King St'));
      expect(location.displayText, contains('Toronto'));
      expect(location.latitude, 43.6);
      places.fail = true;
      final offline = await resolveMomentLocation(43.6, -79.4);
      expect(offline.latitude, 43.6);
      expect(offline.longitude, -79.4);
    },
  );

  testWidgets('sending spinner is before the outgoing message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            isSelf: true,
            showAvatar: false,
            status: MessageStatus.sending,
            child: Text('Pending message'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      tester.getRect(find.byType(CircularProgressIndicator)).right,
      lessThan(tester.getRect(find.text('Pending message')).left),
    );
  });

  for (final own in [false, true]) {
    testWidgets('sent message remains visible (self: $own)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              isSelf: own,
              showAvatar: false,
              status: MessageStatus.sent,
              child: const Text('Delivered message'),
            ),
          ),
        ),
      );
      expect(find.text('Delivered message'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('friend video channel opens that friends videos', (tester) async {
    await getIt.reset();
    addTearDown(getIt.reset);
    final repository = _Repository();
    when(
      () => repository.getUserMoments('@friend:hs', limit: 50),
    ).thenAnswer((_) async => <MomentEntity>[]);
    when(
      () => repository.watchMoments(),
    ).thenAnswer((_) => const Stream<List<MomentEntity>>.empty());
    getIt.registerSingleton<IMomentRepository>(repository);
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: ContactDetailPage(userId: '@friend:hs', displayName: 'Friend'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Video Channel'));
    await tester.tap(find.text('Video Channel'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<VideoFeedPage>(find.byType(VideoFeedPage)).userId,
      '@friend:hs',
    );
    verify(() => repository.getUserMoments('@friend:hs', limit: 50)).called(1);
    verifyNever(() => repository.getMoments(limit: any(named: 'limit')));
    expect(tester.takeException(), isNull);
  });
}
