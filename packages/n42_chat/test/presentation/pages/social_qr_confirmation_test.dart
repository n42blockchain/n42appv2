import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/domain/repositories/contact_repository.dart';
import 'package:n42_chat/src/domain/repositories/group_repository.dart';
import 'package:n42_chat/src/presentation/pages/qrcode/scan_qr_page.dart';

class _GroupRepository extends Mock implements IGroupRepository {}

class _ContactRepository extends Mock implements IContactRepository {}

void main() {
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  late int launchCalls;
  late _GroupRepository groups;
  late _ContactRepository contacts;

  setUp(() {
    launchCalls = 0;
    groups = _GroupRepository();
    contacts = _ContactRepository();
    if (getIt.isRegistered<IGroupRepository>()) {
      getIt.unregister<IGroupRepository>();
    }
    getIt.registerSingleton<IGroupRepository>(groups);
    if (getIt.isRegistered<IContactRepository>()) {
      getIt.unregister<IContactRepository>();
    }
    getIt.registerSingleton<IContactRepository>(contacts);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          switch (call.method) {
            case 'checkPermissionStatus':
              return 0;
            case 'requestPermissions':
              return <int, int>{1: 0};
            case 'openAppSettings':
              return true;
          }
          throw StateError('Unexpected permission call ${call.method}');
        });
  });

  tearDown(() {
    if (getIt.isRegistered<IGroupRepository>()) {
      getIt.unregister<IGroupRepository>();
    }
    if (getIt.isRegistered<IContactRepository>()) {
      getIt.unregister<IContactRepository>();
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  Future<void> openScanner(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: ScanQRPage(
          launchExternalUrl: (uri) async {
            launchCalls++;
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manual Input User ID'));
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField), value);
    await tester.tap(find.text('Add'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('canceling WhatsApp confirmation does not launch externally', (
    tester,
  ) async {
    await openScanner(tester);
    await submit(tester, 'https://wa.me/14155552671');
    expect(
      find.text('Continue to WhatsApp with +14155552671?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(launchCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accepting WhatsApp confirmation launches the allowlisted URL', (
    tester,
  ) async {
    await openScanner(tester);
    await submit(tester, 'https://wa.me/14155552671');

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(launchCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling Matrix room preview does not join the room', (
    tester,
  ) async {
    await openScanner(tester);
    await submit(tester, 'https://matrix.to/#/%21room%3Aexample.org');
    expect(find.text('Join Matrix room?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    verifyNever(() => groups.joinGroupByAlias(any()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('accepting Matrix room preview joins the selected room', (
    tester,
  ) async {
    when(
      () => groups.joinGroupByAlias(any()),
    ).thenAnswer((_) async => '!room:example.org');
    await openScanner(tester);
    await submit(tester, 'https://matrix.to/#/%21room%3Aexample.org');

    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();

    verify(() => groups.joinGroupByAlias('!room:example.org')).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling Matrix user preview does not start a direct chat', (
    tester,
  ) async {
    await openScanner(tester);
    await submit(tester, 'https://matrix.to/#/%40alice%3Aexample.org');
    expect(find.text('Start a Matrix chat?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    verifyNever(() => contacts.startDirectChat(any()));
    expect(tester.takeException(), isNull);
  });
}
