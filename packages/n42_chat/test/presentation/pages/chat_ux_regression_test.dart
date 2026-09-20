import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_chat/src/presentation/pages/conversation/conversation_list_page.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_event.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_state.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_event.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_state.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/theme/n42_chat_theme.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/domain/entities/stored_account_entity.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/domain/repositories/contact_repository.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_event.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';
import 'package:n42_chat/src/presentation/pages/conversation/conversation_filter.dart';
import 'package:n42_chat/src/presentation/pages/settings/account_switch_page.dart';
import 'package:n42_chat/src/presentation/widgets/common/chat_account_title.dart';
import 'package:n42_chat/src/presentation/widgets/common/friend_request_card.dart';
import 'package:n42_chat/src/presentation/widgets/call/return_to_call_banner.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_more_panel.dart';

class MockConversations extends MockBloc<ConversationEvent, ConversationState>
    implements ConversationBloc {}

class MockStories extends MockBloc<StoryEvent, StoryState>
    implements StoryBloc {}

class MockAuth extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockRepository extends Mock implements IAuthRepository {}

const active = AuthState(
  status: AuthStatus.authenticated,
  user: UserEntity(userId: '@alice:example.org', displayName: 'Alice'),
);
const accounts = [
  StoredAccountEntity(
    userId: '@alice:example.org',
    homeserver: 'https://example.org',
    displayName: 'Alice',
    isCurrent: true,
  ),
  StoredAccountEntity(
    userId: '@bob:example.org',
    homeserver: 'https://example.org',
    displayName: 'Bob',
  ),
  StoredAccountEntity(
    userId: '@carol:example.org',
    homeserver: 'https://example.org',
    displayName: 'Carol',
  ),
];

ThemeData reviewTheme(Brightness brightness) {
  final theme =
      (brightness == Brightness.dark
              ? N42ChatTheme.wechatDark()
              : N42ChatTheme.wechatLight())
          .toThemeData();
  if (Platform.environment['N42_UX_SCREENSHOTS'] == null) return theme;
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'UXReview'),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'UXReview'),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: theme.elevatedButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          theme.textTheme.labelLarge?.copyWith(fontFamily: 'UXReview'),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: theme.outlinedButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          theme.textTheme.labelLarge?.copyWith(fontFamily: 'UXReview'),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: theme.textButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          theme.textTheme.labelLarge?.copyWith(fontFamily: 'UXReview'),
        ),
      ),
    ),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: 'UXReview',
      ),
    ),
    chipTheme: theme.chipTheme.copyWith(
      labelStyle: theme.chipTheme.labelStyle?.copyWith(fontFamily: 'UXReview'),
      secondaryLabelStyle: theme.chipTheme.secondaryLabelStyle?.copyWith(
        fontFamily: 'UXReview',
      ),
    ),
  );
}

Widget app(
  Widget child, {
  Brightness brightness = Brightness.light,
  double scale = 1.3,
}) => MaterialApp(
  theme: reviewTheme(brightness),
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: const Locale('en'),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: child,
);

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  final folder = Platform.environment['N42_UX_SCREENSHOTS'];
  if (folder == null) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$folder/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    registerFallbackValue(const AuthRestoreSessionRequested());
    if (Platform.environment['N42_UX_SCREENSHOTS'] != null) {
      final loader = FontLoader('UXReview');
      loader.addFont(
        File(
          '/System/Library/Fonts/Supplemental/Arial.ttf',
        ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
      await loader.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        File(
          '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
      await icons.load();
    }
  });
  tearDown(() async => getIt.reset());

  test('unread filter includes muted chats and excludes read chats', () {
    const muted = ConversationEntity(
      id: 'a',
      name: 'A',
      type: ConversationType.direct,
      isMuted: true,
      unreadCount: 1,
    );
    const group = ConversationEntity(
      id: 'b',
      name: 'B',
      type: ConversationType.group,
    );
    expect(ConversationFilter.unread.matches(muted), isTrue);
    expect(ConversationFilter.unread.matches(group), isFalse);
    expect(ConversationFilter.groups.matches(group), isTrue);
    expect(ConversationFilter.groups.matches(muted), isFalse);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'conversation filters preserve muted unread and recover empty results ${brightness.name}',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final conversations = MockConversations();
        final stories = MockStories();
        when(() => stories.state).thenReturn(const StoryState());
        getIt.registerFactory<StoryBloc>(() => stories);
        const entries = [
          ConversationEntity(
            id: 'a',
            name: 'Alice',
            type: ConversationType.direct,
            unreadCount: 2,
            isMuted: true,
            lastMessage: 'See you tomorrow',
          ),
          ConversationEntity(
            id: 'b',
            name: 'Design team',
            type: ConversationType.group,
            isPinned: true,
            lastMessage: 'The new design is ready',
          ),
        ];
        when(
          () => conversations.state,
        ).thenReturn(const ConversationState(conversations: entries));
        final key = GlobalKey();
        await tester.pumpWidget(
          app(
            BlocProvider<ConversationBloc>.value(
              value: conversations,
              child: RepaintBoundary(
                key: key,
                child: const ConversationListPage(),
              ),
            ),
            brightness: brightness,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Design team'), findsOneWidget);
        await capture(tester, key, 'messages-${brightness.name}');
        await tester.tap(
          find.byKey(const ValueKey('conversation_filter_unread')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Design team'), findsNothing);
        await tester.tap(
          find.byKey(const ValueKey('conversation_filter_groups')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Alice'), findsNothing);
        expect(find.text('Design team'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await conversations.close();
      },
    );
  }

  testWidgets(
    'account switch serializes actions and keeps recoverable failure visible',
    (tester) async {
      final repository = MockRepository();
      when(repository.getStoredAccounts).thenAnswer((_) async => accounts);
      getIt.registerSingleton<IAuthRepository>(repository);
      final auth = MockAuth();
      final states = StreamController<AuthState>();
      whenListen(auth, states.stream, initialState: active);
      await tester.pumpWidget(
        app(
          BlocProvider<AuthBloc>.value(
            value: auth,
            child: const AccountSwitchPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bob'));
      await tester.pump();
      await tester.tap(find.text('Carol'));
      await tester.pump();
      verify(
        () => auth.add(
          const AuthSwitchStoredAccountRequested(userId: '@bob:example.org'),
        ),
      ).called(1);
      verifyNever(
        () => auth.add(
          const AuthSwitchStoredAccountRequested(userId: '@carol:example.org'),
        ),
      );
      expect(find.textContaining('Switching account'), findsOneWidget);
      states.add(
        const AuthState(
          status: AuthStatus.error,
          user: UserEntity(userId: '@alice:example.org', displayName: 'Alice'),
          errorMessage: 'expired',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not switch accounts'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.text('Carol'));
      verify(
        () => auth.add(
          const AuthSwitchStoredAccountRequested(userId: '@carol:example.org'),
        ),
      ).called(1);
      await tester.pumpWidget(const SizedBox());
      await states.close();
      await auth.close();
    },
  );

  testWidgets(
    'title identifies current account and opens switcher without logout',
    (tester) async {
      final repository = MockRepository();
      when(repository.getStoredAccounts).thenAnswer((_) async => accounts);
      getIt.registerSingleton<IAuthRepository>(repository);
      final auth = MockAuth();
      when(() => auth.state).thenReturn(active);
      await tester.pumpWidget(
        app(
          BlocProvider<AuthBloc>.value(
            value: auth,
            child: Scaffold(
              appBar: AppBar(title: const ChatAccountTitle(title: 'Messages')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('@alice:example.org'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('chat_account_selector')));
      await tester.pumpAndSettle();
      expect(find.byType(AccountSwitchPage), findsOneWidget);
      verifyNever(() => auth.add(const AuthLogoutRequested()));
      await auth.close();
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'requests and return-to-call fit narrow large-text ${brightness.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 750);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var accepted = 0;
        var returned = 0;
        final key = GlobalKey();
        await tester.pumpWidget(
          app(
            RepaintBoundary(
              key: key,
              child: Scaffold(
                body: SafeArea(
                  child: ListView(
                    children: [
                      ReturnToCallBanner(onReturn: () => returned++),
                      FriendRequestCard(
                        request: const FriendRequest(
                          id: 'a',
                          userId: '@alexandra:example.org',
                          userName: 'Alexandra Johnson',
                        ),
                        busy: false,
                        onAccept: () => accepted++,
                        onReject: () {},
                        onProfile: () {},
                      ),
                      FriendRequestCard(
                        request: const FriendRequest(
                          id: 'b',
                          userId: '@bob:example.org',
                          userName: 'Bob',
                          isOutgoing: true,
                        ),
                        busy: false,
                        onAccept: () => accepted++,
                        onReject: () {},
                        onProfile: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            brightness: brightness,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Accept'), findsOneWidget);
        expect(find.text('Awaiting acceptance'), findsOneWidget);
        await tester.tap(find.text('Accept'));
        await tester.tap(find.text('Return to call'));
        expect(accepted, 1);
        expect(returned, 1);
        await capture(tester, key, 'requests-${brightness.name}');
      },
    );

    testWidgets('account chooser fits large text ${brightness.name}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MockRepository();
      when(repository.getStoredAccounts).thenAnswer((_) async => accounts);
      getIt.registerSingleton<IAuthRepository>(repository);
      final auth = MockAuth();
      when(() => auth.state).thenReturn(active);
      final key = GlobalKey();
      await tester.pumpWidget(
        app(
          BlocProvider<AuthBloc>.value(
            value: auth,
            child: RepaintBoundary(key: key, child: const AccountSwitchPage()),
          ),
          brightness: brightness,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Current account'), findsOneWidget);
      await capture(tester, key, 'accounts-${brightness.name}');
      await auth.close();
    });
  }

  testWidgets('attachment panel fits narrow screen and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 750);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selected = 0;
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatMorePanel(
              onPhotoPressed: () => selected++,
              onFilePressed: () {},
            ),
          ),
        ),
        scale: 1.6,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Photos'));
    expect(selected, 1);
  });
}
