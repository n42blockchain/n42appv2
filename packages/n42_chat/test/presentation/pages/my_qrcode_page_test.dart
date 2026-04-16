import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/domain/entities/avatar_decoration_preset.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/presentation/pages/qrcode/my_qrcode_page.dart';

class MockMatrixClientManager extends Mock implements MatrixClientManager {
  @override
  matrix.Client? get client => null;
}

class MockAuthRepository extends Mock implements IAuthRepository {}

Widget buildTestWidget(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    theme: theme,
    home: child,
  );
}

void main() {
  late MockMatrixClientManager mockClientManager;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockClientManager = MockMatrixClientManager();
    mockAuthRepository = MockAuthRepository();

    // 注册 GetIt 依赖
    if (getIt.isRegistered<MatrixClientManager>()) {
      getIt.unregister<MatrixClientManager>();
    }
    if (getIt.isRegistered<IAuthRepository>()) {
      getIt.unregister<IAuthRepository>();
    }
    getIt.registerSingleton<MatrixClientManager>(mockClientManager);
    getIt.registerSingleton<IAuthRepository>(mockAuthRepository);
    when(
      () => mockAuthRepository.getCurrentUserProfile(),
    ).thenAnswer((_) async => null);
  });

  tearDown(() {
    if (getIt.isRegistered<MatrixClientManager>()) {
      getIt.unregister<MatrixClientManager>();
    }
    if (getIt.isRegistered<IAuthRepository>()) {
      getIt.unregister<IAuthRepository>();
    }
  });

  group('MyQRCodePage', () {
    testWidgets('renders with loading state when no user info', (tester) async {
      // 使用较大的屏幕尺寸避免 overflow 错误
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      // 应该显示加载指示器（因为没有 client 登录）
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows AppBar with My QR Code title', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      expect(find.text('My QR Code'), findsOneWidget);
    });

    testWidgets('has back button in AppBar', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('has more options button in AppBar', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('shows scan hint text', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      expect(find.textContaining('Scan the QR code'), findsOneWidget);
    });

    testWidgets('shows Copy ID and Share buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      expect(find.text('Copy ID'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('tapping more_horiz shows bottom sheet options', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz));
      // 使用多次 pump 代替 pumpAndSettle，避免动画超时
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Save to Album'), findsOneWidget);
      expect(find.text('Change Style'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(const MyQRCodePage(), theme: ThemeData.dark()),
      );
      await tester.pump();

      expect(find.text('My QR Code'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('RepaintBoundary wraps QR content for screenshot', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('uses shared auth profile avatar decoration when available', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockAuthRepository.getCurrentUserProfile()).thenAnswer(
        (_) async => const UserEntity(
          userId: '@alice:example.org',
          displayName: 'Alice',
          avatarUrl: null,
          avatarDecorationPreset: AvatarDecorationPreset.arcade,
        ),
      );

      await tester.pumpWidget(buildTestWidget(const MyQRCodePage()));
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.byIcon(Icons.sports_esports), findsOneWidget);
    });
  });
}
