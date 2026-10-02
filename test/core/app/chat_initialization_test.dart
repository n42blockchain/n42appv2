import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/app/chat_initialization.dart';
import 'package:n42_wallet/core/platform/deep_link_service.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/main.dart' as app;

class _Host extends ConsumerStatefulWidget {
  const _Host({super.key});

  @override
  ConsumerState<_Host> createState() => _HostState();
}

class _HostState extends ConsumerState<_Host>
    with ChatInitializationMixin<_Host> {
  final chatRoutes = <DeepLinkData>[];
  final ssoRoutes = <DeepLinkData>[];

  // Observe the existing virtual routing seam while executing its real body.
  // Neither chat initialization nor Matrix/network authentication is replaced.
  @override
  Future<void> routeChatDeepLink(
    DeepLinkData data, {
    required BuildContext navContext,
  }) {
    chatRoutes.add(data);
    return super.routeChatDeepLink(data, navContext: navContext);
  }

  @override
  Future<void> routeChatSsoDeepLink(DeepLinkData data) {
    ssoRoutes.add(data);
    return super.routeChatSsoDeepLink(data);
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Host'));

  @override
  void dispose() {
    disposeChatSubscriptions();
    super.dispose();
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const badgeChannel = MethodChannel('flutter_new_badger');
  const notificationsChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  final badgeCalls = <MethodCall>[];
  final notificationCalls = <MethodCall>[];
  late GlobalKey<NavigatorState> previousNavigatorKey;

  setUp(() {
    previousNavigatorKey = AppGlobals.navigatorKey;
    AppGlobals.navigatorKey = GlobalKey<NavigatorState>();
    app.globalProviderContainer = ProviderContainer();
    app.globalProviderContainer.read(unreadCountProvider.notifier).setCount(7);
    badgeCalls.clear();
    notificationCalls.clear();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(badgeChannel, (
      call,
    ) async {
      badgeCalls.add(call);
      return null;
    });
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      notificationsChannel,
      (call) async {
        notificationCalls.add(call);
        return null;
      },
    );
  });

  tearDown(() {
    AppGlobals.navigatorKey = previousNavigatorKey;
    app.globalProviderContainer.dispose();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(badgeChannel, null);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      notificationsChannel,
      null,
    );
  });

  Future<_HostState> mount(WidgetTester tester) async {
    final key = GlobalKey<_HostState>();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorKey: AppGlobals.navigatorKey,
          home: _Host(key: key),
        ),
      ),
    );
    expect(N42Chat.isInitialized, isFalse);
    return key.currentState!;
  }

  DeepLinkData link(DeepLinkType type, String value) => DeepLinkData(
    type: type,
    uri: Uri.parse('n42wallet://chat/$value'),
    params: {'roomId': value, 'loginToken': value},
  );

  for (final status in [AuthStatus.unauthenticated, AuthStatus.initial]) {
    testWidgets('${status.name} transition clears unread and badge once', (
      tester,
    ) async {
      final host = await mount(tester);
      final userEvents = <UserEntity?>[];
      final subscription = N42Chat.userStream.listen(userEvents.add);
      addTearDown(subscription.cancel);

      host.syncHostWithChatAuthStatus(
        status,
        previousStatus: AuthStatus.authenticated,
      );
      await tester.pump();

      expect(app.globalProviderContainer.read(unreadCountProvider), 0);
      expect(userEvents, [null]);
      expect(badgeCalls.map((call) => call.method), ['removeBadge']);
      expect(notificationCalls, isEmpty);

      app.globalProviderContainer
          .read(unreadCountProvider.notifier)
          .setCount(3);
      host.syncHostWithChatAuthStatus(status, previousStatus: status);
      await tester.pump();
      expect(app.globalProviderContainer.read(unreadCountProvider), 3);
      expect(userEvents, [null]);
      expect(badgeCalls, hasLength(1));
    });
  }

  for (final status in AuthStatus.values) {
    testWidgets('unchanged ${status.name} preserves host state', (
      tester,
    ) async {
      final host = await mount(tester);
      final userEvents = <UserEntity?>[];
      final subscription = N42Chat.userStream.listen(userEvents.add);
      addTearDown(subscription.cancel);

      host.syncHostWithChatAuthStatus(status, previousStatus: status);
      await tester.pump();

      expect(app.globalProviderContainer.read(unreadCountProvider), 7);
      expect(userEvents, isEmpty);
      expect(badgeCalls, isEmpty);
      expect(notificationCalls, isEmpty);
    });
  }

  testWidgets('null auth status preserves host unread and badge', (
    tester,
  ) async {
    final host = await mount(tester);
    host.syncHostWithChatAuthStatus(
      null,
      previousStatus: AuthStatus.authenticated,
    );
    await tester.pump();
    expect(app.globalProviderContainer.read(unreadCountProvider), 7);
    expect(badgeCalls, isEmpty);
  });

  testWidgets('transient auth changes preserve host unread and badge', (
    tester,
  ) async {
    final host = await mount(tester);
    final userEvents = <UserEntity?>[];
    final subscription = N42Chat.userStream.listen(userEvents.add);
    addTearDown(subscription.cancel);
    for (final status in [
      AuthStatus.checking,
      AuthStatus.loading,
      AuthStatus.error,
    ]) {
      host.syncHostWithChatAuthStatus(
        status,
        previousStatus: AuthStatus.authenticated,
      );
    }
    await tester.pump();
    expect(app.globalProviderContainer.read(unreadCountProvider), 7);
    expect(userEvents, isEmpty);
    expect(badgeCalls, isEmpty);
  });

  testWidgets(
    'pending chat keeps the latest link while initialization is unavailable',
    (tester) async {
      final host = await mount(tester);
      final first = link(DeepLinkType.chat, '!first');
      final latest = link(DeepLinkType.group, '!latest');
      await host.routeChatDeepLink(first, navContext: host.context);
      await host.routeChatDeepLink(latest, navContext: host.context);
      await host.flushPendingChatDeepLink();
      await host.flushPendingChatDeepLink();
      expect(host.chatRoutes, [first, latest, latest, latest]);
      expect(find.text('Host'), findsOneWidget);
      expect(app.globalProviderContainer.read(unreadCountProvider), 7);
    },
  );

  testWidgets(
    'pending chat is retained until a navigator context is available',
    (tester) async {
      final host = await mount(tester);
      final pending = link(DeepLinkType.chat, '!pending');
      await host.routeChatDeepLink(pending, navContext: host.context);
      final attachedKey = AppGlobals.navigatorKey;
      AppGlobals.navigatorKey = GlobalKey<NavigatorState>();
      await host.flushPendingChatDeepLink();
      expect(host.chatRoutes, [pending]);
      AppGlobals.navigatorKey = attachedKey;
      await host.flushPendingChatDeepLink();
      expect(host.chatRoutes, [pending, pending]);
    },
  );

  testWidgets('pending chat cannot route after the host is disposed', (
    tester,
  ) async {
    final host = await mount(tester);
    final pending = link(DeepLinkType.chat, '!disposed');
    await host.routeChatDeepLink(pending, navContext: host.context);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(host.mounted, isFalse);
    await host.flushPendingChatDeepLink();
    expect(host.chatRoutes, [pending]);
    expect(badgeCalls, isEmpty);
  });

  testWidgets('pending SSO callback survives flushes before initialization', (
    tester,
  ) async {
    final host = await mount(tester);
    final callback = link(DeepLinkType.chatSso, 'login-token');
    await host.routeChatSsoDeepLink(callback);
    await host.flushPendingChatSsoDeepLink();
    await host.flushPendingChatSsoDeepLink();
    expect(host.ssoRoutes, [callback, callback, callback]);
    expect(host.chatRoutes, isEmpty);
    expect(app.globalProviderContainer.read(unreadCountProvider), 7);
  });

  testWidgets('chat deep link classifier accepts only chat destinations', (
    tester,
  ) async {
    final host = await mount(tester);
    for (final type in [
      DeepLinkType.chat,
      DeepLinkType.user,
      DeepLinkType.group,
      DeepLinkType.friendCard,
    ]) {
      expect(host.isChatDeepLink(type), isTrue, reason: type.name);
    }
    for (final type in DeepLinkType.values.where(
      (type) => ![
        DeepLinkType.chat,
        DeepLinkType.user,
        DeepLinkType.group,
        DeepLinkType.friendCard,
      ].contains(type),
    )) {
      expect(host.isChatDeepLink(type), isFalse, reason: type.name);
    }
  });

  testWidgets('unsupported pending deep link is ignored by every flush', (
    tester,
  ) async {
    final host = await mount(tester);
    final unsupported = link(DeepLinkType.walletConnect, 'pairing');
    await host.routeChatDeepLink(unsupported, navContext: host.context);
    await host.flushPendingChatDeepLink();
    await host.flushPendingChatDeepLink();
    expect(host.chatRoutes, [unsupported]);
  });

  testWidgets('chat navigation helpers open the chat entry before login', (
    tester,
  ) async {
    final host = await mount(tester);

    Future<void> expectChatEntry(Future<void> Function() open) async {
      final navigation = open();
      await tester.pumpAndSettle();
      expect(find.text('Chat initialization failed'), findsOneWidget);
      AppGlobals.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      await navigation;
    }

    await expectChatEntry(
      () => host.openChatConversation(host.context, '!room:example.org'),
    );
    await expectChatEntry(
      () => host.openDirectMessage(host.context, '@user:example.org'),
    );
    await expectChatEntry(
      () => host.openChatUserProfile(host.context, '@user:example.org'),
    );
  });

  testWidgets('chat entry does nothing after its host is disposed', (
    tester,
  ) async {
    final host = await mount(tester);
    final hostContext = host.context;
    await tester.pumpWidget(const SizedBox.shrink());
    expect(host.mounted, isFalse);
    await host.openChatEntry(hostContext);
    expect(find.text('N42 Chat'), findsNothing);
  });
}
