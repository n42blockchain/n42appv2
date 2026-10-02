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
import 'package:shared_preferences/shared_preferences.dart';

class _Host extends ConsumerStatefulWidget {
  const _Host({super.key});

  @override
  ConsumerState<_Host> createState() => _HostState();
}

class _HostState extends ConsumerState<_Host>
    with ChatInitializationMixin<_Host> {
  final chatRoutes = <DeepLinkData>[];
  final ssoRoutes = <DeepLinkData>[];
  final ssoLogins = <String>[];
  final chatActions = <String>[];
  bool chatInitializedForTest = false;
  bool chatLoggedInForTest = false;
  bool delegateNavigationToMixin = false;
  bool renderChatEntryForTest = false;
  bool failN42ChatOperation = false;
  int authNotifications = 0;
  int permissionChecks = 0;
  int deliveryChecks = 0;

  @override
  bool get chatIsInitialized => chatInitializedForTest;

  @override
  bool get chatIsLoggedIn => chatLoggedInForTest;

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
  Future<void> loginN42ChatWithLoginToken({
    required String homeserver,
    required String loginToken,
  }) async {
    ssoLogins.add('$homeserver|$loginToken');
  }

  @override
  void notifyN42ChatUserChanged() {
    authNotifications++;
    super.notifyN42ChatUserChanged();
  }

  @override
  Future<void> checkChatPushPermission() async {
    permissionChecks++;
  }

  @override
  Future<void> checkChatBackgroundDelivery() async {
    deliveryChecks++;
  }

  @override
  Future<void> openChatEntry(BuildContext navContext) async {
    if (renderChatEntryForTest) {
      await super.openChatEntry(navContext);
      return;
    }
    chatActions.add('entry');
  }

  @override
  Future<void> openChatConversation(
    BuildContext navContext,
    String roomId,
  ) async {
    if (delegateNavigationToMixin) {
      await super.openChatConversation(navContext, roomId);
      return;
    }
    chatActions.add('conversation:$roomId');
  }

  @override
  Future<void> openDirectMessage(BuildContext navContext, String userId) async {
    if (delegateNavigationToMixin) {
      await super.openDirectMessage(navContext, userId);
      return;
    }
    chatActions.add('direct:$userId');
  }

  @override
  Future<void> openChatUserProfile(
    BuildContext navContext,
    String userId,
  ) async {
    if (delegateNavigationToMixin) {
      await super.openChatUserProfile(navContext, userId);
      return;
    }
    chatActions.add('profile:$userId');
  }

  @override
  Future<void> openN42ChatConversation(
    String roomId, {
    required BuildContext context,
  }) async {
    chatActions.add('open:$roomId');
    if (failN42ChatOperation) throw StateError('conversation failed');
  }

  @override
  Future<String> createN42ChatDirectMessage(String userId) async {
    chatActions.add('create:$userId');
    if (failN42ChatOperation) throw StateError('creation failed');
    return '!direct:$userId';
  }

  @override
  Future<void> openN42ChatUserProfile(
    String userId, {
    required BuildContext context,
  }) async {
    chatActions.add('profile-open:$userId');
    if (failN42ChatOperation) throw StateError('profile failed');
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
    SharedPreferences.setMockInitialValues({});
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
    'authenticated transition notifies chat and checks permissions once',
    (tester) async {
      final host = await mount(tester);
      final userEvents = <UserEntity?>[];
      final subscription = N42Chat.userStream.listen(userEvents.add);
      addTearDown(subscription.cancel);

      host.syncHostWithChatAuthStatus(
        AuthStatus.authenticated,
        previousStatus: AuthStatus.unauthenticated,
      );
      await tester.pump();

      expect(host.authNotifications, 1);
      expect(host.permissionChecks, 1);
      expect(host.deliveryChecks, 1);
      expect(userEvents, [null]);
      expect(app.globalProviderContainer.read(unreadCountProvider), 7);
      expect(badgeCalls, isEmpty);

      host.syncHostWithChatAuthStatus(
        AuthStatus.authenticated,
        previousStatus: AuthStatus.authenticated,
      );
      await tester.pump();

      expect(host.authNotifications, 1);
      expect(host.permissionChecks, 1);
      expect(host.deliveryChecks, 1);
      expect(userEvents, [null]);
    },
  );

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
    host.delegateNavigationToMixin = true;
    host.renderChatEntryForTest = true;

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

  testWidgets(
    'initialized logged-in chat links dispatch to their destinations',
    (tester) async {
      final host = await mount(tester);
      host.chatInitializedForTest = true;
      host.chatLoggedInForTest = true;

      DeepLinkData withParams(DeepLinkType type, Map<String, String> params) =>
          DeepLinkData(
            type: type,
            uri: Uri.parse('n42wallet://chat/route'),
            params: params,
          );

      for (final link in [
        withParams(DeepLinkType.chat, {'roomId': '!room'}),
        withParams(DeepLinkType.user, {'userId': '@alice'}),
        withParams(DeepLinkType.group, {'groupId': '!group'}),
        withParams(DeepLinkType.friendCard, {'userId': '@bob'}),
      ]) {
        await host.routeChatDeepLink(link, navContext: host.context);
      }

      expect(host.chatActions, [
        'conversation:!room',
        'direct:@alice',
        'conversation:!group',
        'profile:@bob',
      ]);
    },
  );

  testWidgets('session readiness requires both initialization and login', (
    tester,
  ) async {
    final host = await mount(tester);
    expect(host.isChatSessionReady, isFalse);

    host.chatInitializedForTest = true;
    expect(host.isChatSessionReady, isFalse);

    host.chatLoggedInForTest = true;
    expect(host.isChatSessionReady, isTrue);

    host.chatInitializedForTest = false;
    expect(host.isChatSessionReady, isFalse);
  });

  testWidgets('unauthenticated deep links resume after login becomes ready', (
    tester,
  ) async {
    final host = await mount(tester);
    host.chatInitializedForTest = true;
    final pending = link(DeepLinkType.chat, '!pending-login');

    await host.routeChatDeepLink(pending, navContext: host.context);
    expect(host.chatActions, ['entry']);

    host.chatLoggedInForTest = true;
    await host.flushPendingChatDeepLink();

    expect(host.chatActions, ['entry', 'conversation:!pending-login']);
    expect(host.chatRoutes, [pending, pending]);
  });

  testWidgets('deep links with missing identifiers take safe fallback paths', (
    tester,
  ) async {
    final host = await mount(tester);
    host.chatInitializedForTest = true;
    host.chatLoggedInForTest = true;

    DeepLinkData withParams(DeepLinkType type, Map<String, String> params) =>
        DeepLinkData(
          type: type,
          uri: Uri.parse('n42wallet://chat/route'),
          params: params,
        );

    for (final missingIdentifier in [
      withParams(DeepLinkType.chat, const {}),
      withParams(DeepLinkType.user, const {}),
      withParams(DeepLinkType.group, const {}),
      withParams(DeepLinkType.friendCard, const {}),
    ]) {
      await host.routeChatDeepLink(missingIdentifier, navContext: host.context);
    }

    expect(host.chatActions, ['entry']);
  });

  testWidgets('initialized routing ignores non-chat deep link types', (
    tester,
  ) async {
    final host = await mount(tester);
    host.chatInitializedForTest = true;
    host.chatLoggedInForTest = true;

    for (final type in DeepLinkType.values.where(
      (type) => !host.isChatDeepLink(type),
    )) {
      await host.routeChatDeepLink(
        link(type, 'ignored'),
        navContext: host.context,
      );
    }

    expect(host.chatActions, isEmpty);
  });

  testWidgets('ready chat actions use their corresponding N42Chat operations', (
    tester,
  ) async {
    final host = await mount(tester);
    host.chatInitializedForTest = true;
    host.chatLoggedInForTest = true;
    host.delegateNavigationToMixin = true;

    await host.openChatConversation(host.context, '!room');
    await host.openDirectMessage(host.context, '@alice');
    await host.openChatUserProfile(host.context, '@bob');

    expect(host.chatActions, [
      'open:!room',
      'create:@alice',
      'open:!direct:@alice',
      'profile-open:@bob',
    ]);
  });

  testWidgets('failed N42Chat operations fall back to the chat entry', (
    tester,
  ) async {
    final host = await mount(tester);
    host.chatInitializedForTest = true;
    host.chatLoggedInForTest = true;
    host.delegateNavigationToMixin = true;
    host.failN42ChatOperation = true;

    await host.openChatConversation(host.context, '!room');
    await host.openDirectMessage(host.context, '@alice');
    await host.openChatUserProfile(host.context, '@bob');

    expect(host.chatActions, [
      'open:!room',
      'entry',
      'create:@alice',
      'entry',
      'profile-open:@bob',
      'entry',
    ]);
  });

  testWidgets(
    'unready chat actions open the chat entry without N42Chat calls',
    (tester) async {
      final host = await mount(tester);
      host.delegateNavigationToMixin = true;

      await host.openChatConversation(host.context, '!room');
      await host.openDirectMessage(host.context, '@alice');
      await host.openChatUserProfile(host.context, '@bob');

      expect(host.chatActions, ['entry', 'entry', 'entry']);
    },
  );

  testWidgets('SSO callbacks accept token aliases and normalize homeservers', (
    tester,
  ) async {
    final host = await mount(tester);
    host.chatInitializedForTest = true;

    DeepLinkData callback(Map<String, String> params) => DeepLinkData(
      type: DeepLinkType.chatSso,
      uri: Uri.parse('n42wallet://auth/sso'),
      params: params,
    );

    await host.routeChatSsoDeepLink(
      callback({
        'loginToken': 'camel',
        'homeserver': ' https://matrix.example.org/// ',
      }),
    );
    await host.routeChatSsoDeepLink(
      callback({
        'login_token': 'snake',
        'homeserver': 'https://matrix.example.org',
      }),
    );
    await host.routeChatSsoDeepLink(
      callback({'token': 'short', 'homeserver': 'https://matrix.example.org'}),
    );

    expect(host.ssoLogins, [
      'https://matrix.example.org|camel',
      'https://matrix.example.org|snake',
      'https://matrix.example.org|short',
    ]);
  });

  testWidgets(
    'SSO callbacks with missing tokens or invalid homeservers are ignored',
    (tester) async {
      final host = await mount(tester);
      host.chatInitializedForTest = true;

      for (final params in [
        {'homeserver': 'https://matrix.example.org'},
        {'loginToken': '', 'homeserver': 'https://matrix.example.org'},
        {'token': 'secret', 'homeserver': 'javascript:alert(1)'},
        {'token': 'secret'},
      ]) {
        await host.routeChatSsoDeepLink(
          DeepLinkData(
            type: DeepLinkType.chatSso,
            uri: Uri.parse('n42wallet://auth/sso'),
            params: params,
          ),
        );
      }

      expect(host.ssoLogins, isEmpty);
    },
  );

  testWidgets('pending SSO callback flushes after Chat initialization', (
    tester,
  ) async {
    final host = await mount(tester);
    final callback = DeepLinkData(
      type: DeepLinkType.chatSso,
      uri: Uri.parse('n42wallet://auth/sso'),
      params: {
        'login_token': 'queued-token',
        'homeserver': 'https://matrix.example.org',
      },
    );

    await host.routeChatSsoDeepLink(callback);
    host.chatInitializedForTest = true;
    await host.flushPendingChatSsoDeepLink();

    expect(host.ssoRoutes, [callback, callback]);
    expect(host.ssoLogins, ['https://matrix.example.org|queued-token']);
  });
}
