import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/services/auto_download_policy_service.dart';
import 'package:n42_chat/src/presentation/widgets/chat/image_message_widget.dart';

class MockPolicy extends Mock implements AutoDownloadPolicyService {}

void main() {
  late MockPolicy policy;
  setUp(() {
    policy = MockPolicy();
    when(
      () => policy.shouldAutoDownload(AutoDownloadMediaType.image),
    ).thenAnswer((_) async => false);
  });
  Future<void> show(
    WidgetTester tester, {
    String url = '',
    int? width,
    int? height,
    bool once = false,
    bool viewed = false,
    bool expired = false,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: Center(
            child: ImageMessageWidget(
              key: const ValueKey('message'),
              imageUrl: url,
              width: width,
              height: height,
              isViewOnce: once,
              isViewed: viewed,
              isExpired: expired,
              onTap: onTap,
              autoDownloadPolicyService: policy,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'disabled auto-download keeps network image absent until explicit download',
    (tester) async {
      var opens = 0;
      await show(tester, onTap: () => opens++);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.download_for_offline_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.download_for_offline_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
      expect(opens, 0);
    },
  );
  testWidgets(
    'unresolved policy shows a placeholder without starting a download',
    (tester) async {
      final decision = Completer<bool>();
      when(
        () => policy.shouldAutoDownload(AutoDownloadMediaType.image),
      ).thenAnswer((_) => decision.future);
      await show(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
      decision.complete(false);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
  testWidgets(
    'view-once preview opens only through explicit callback and never renders media',
    (tester) async {
      var opens = 0;
      await show(tester, once: true, onTap: () => opens++);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(
        tester.getSize(find.byType(ImageMessageWidget)).height,
        lessThan(240),
      );
      await tester.tap(find.byIcon(Icons.lock));
      expect(opens, 1);
      expect(tester.takeException(), isNull);
    },
  );
  for (final expired in [false, true]) {
    testWidgets('consumed view-once media cannot reopen: expired=$expired', (
      tester,
    ) async {
      var opens = 0;
      await show(
        tester,
        once: true,
        viewed: !expired,
        expired: expired,
        onTap: () => opens++,
      );
      await tester.tap(
        find.byIcon(expired ? Icons.timer_off : Icons.visibility),
      );
      expect(opens, 0);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  for (final dimensions in [(4000, 100), (100, 4000), (300, 300), (0, 0)]) {
    testWidgets(
      'image dimensions $dimensions remain inside chat thumbnail limits',
      (tester) async {
        await show(tester, width: dimensions.$1, height: dimensions.$2);
        final size = tester.getSize(find.byType(ImageMessageWidget));
        expect(size.width, inInclusiveRange(100, 200));
        expect(size.height, inInclusiveRange(100, 300));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('disposed image ignores a late policy completion', (
    tester,
  ) async {
    final decision = Completer<bool>();
    when(
      () => policy.shouldAutoDownload(AutoDownloadMediaType.image),
    ).thenAnswer((_) => decision.future);
    await show(tester);
    await tester.pumpWidget(const SizedBox());
    decision.complete(true);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'older policy completion cannot override a new image download decision',
    (tester) async {
      final first = Completer<bool>();
      final second = Completer<bool>();
      var calls = 0;
      when(
        () => policy.shouldAutoDownload(AutoDownloadMediaType.image),
      ).thenAnswer((_) => calls++ == 0 ? first.future : second.future);
      await show(tester, url: 'old');
      await show(tester, url: '');
      second.complete(false);
      await tester.pump();
      first.complete(true);
      await tester.pump();
      expect(find.byIcon(Icons.download_for_offline_outlined), findsOneWidget);
      expect(find.byIcon(Icons.broken_image), findsNothing);
    },
  );
  testWidgets(
    'policy failure requires manual download instead of bypassing user preferences',
    (tester) async {
      when(
        () => policy.shouldAutoDownload(AutoDownloadMediaType.image),
      ).thenThrow(StateError('preferences unavailable'));
      await show(tester);
      expect(find.byIcon(Icons.download_for_offline_outlined), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    },
  );
}
