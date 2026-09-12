import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/services/media_lifecycle_service.dart';
import 'package:n42_chat/src/core/services/storage_cleanup_service.dart';
import 'package:n42_chat/src/core/services/storage_manager_service.dart';
import 'package:n42_chat/src/core/services/storage_monitor_service.dart';
import 'package:n42_chat/src/presentation/pages/settings/storage_management_page.dart';

class _Manager extends Mock implements StorageManagerService {}

class _Lifecycle extends Mock implements MediaLifecycleService {}

class _Cleanup extends Mock implements StorageCleanupService {}

class _Monitor extends Mock implements StorageMonitorService {}

void main() {
  tearDown(() => GetIt.instance.reset());
  testWidgets('view all rooms expands storage ranking beyond five entries', (
    tester,
  ) async {
    final manager = _Manager();
    final lifecycle = _Lifecycle();
    final cleanup = _Cleanup();
    final monitor = _Monitor();
    GetIt.instance.registerSingleton<StorageManagerService>(manager);
    GetIt.instance.registerSingleton<MediaLifecycleService>(lifecycle);
    GetIt.instance.registerSingleton<StorageCleanupService>(cleanup);
    GetIt.instance.registerSingleton<StorageMonitorService>(monitor);
    when(
      () => manager.getStorageUsage(),
    ).thenAnswer((_) async => const StorageInfo());
    when(
      () => monitor.checkStorageStatus(),
    ).thenAnswer((_) async => const StorageStatus());
    when(
      () => monitor.getStorageConfig(),
    ).thenAnswer((_) async => const StorageConfig());
    when(
      () => cleanup.getRecommendations(
        preserveThumbnails: any(named: 'preserveThumbnails'),
      ),
    ).thenAnswer((_) async => []);
    when(() => lifecycle.getAllRoomStats()).thenAnswer((_) async => []);
    when(() => manager.getRoomStorageRanking()).thenAnswer(
      (_) async => List.generate(
        7,
        (i) => RoomStorageInfo(
          roomId: '!room$i:server',
          roomName: 'Room $i',
          totalSize: 1024,
          mediaCount: 1,
        ),
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: StorageManagementPage(),
      ),
    );
    await tester.pumpAndSettle();
    final all = find.text('View all 7 rooms');
    await tester.scrollUntilVisible(
      all,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(all);
    await tester.pumpAndSettle();
    expect(find.text('Room 6'), findsNothing);
    await tester.tap(all);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Room 6'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Room 6'), findsOneWidget);
    expect(all, findsNothing);
    expect(tester.takeException(), isNull);
  });
}
