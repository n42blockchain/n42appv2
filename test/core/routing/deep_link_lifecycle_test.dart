import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/platform/deep_link_service.dart';
import 'package:n42_wallet/core/routing/deep_link_handler.dart';

const _session = '00000000-0000-4000-8000-000000000000';

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('link input boundaries', () {
    late DeepLinkService service;
    setUp(() => service = DeepLinkService());
    tearDown(() => service.dispose());

    for (final action in ['chat', 'user', 'group']) {
      test('$action path target cannot be overwritten by query', () {
        final key = action == 'chat' ? 'roomId' : '${action}Id';
        service.handleUri(Uri.parse('n42://$action/expected?$key=attacker'));
        expect(service.lastDeepLink!.params[key], 'expected');
      });
    }

    for (final value in ['a%2Fb', 'a%5Cb', 'a%00b', 'a%20b', '%2E%2E']) {
      test('invalid ID $value never becomes a different valid target', () {
        service.handleUri(Uri.parse('n42://chat/$value?roomId=fallback'));
        final link = service.lastDeepLink!;
        expect(
          link.type == DeepLinkType.unknown || link.params['roomId'] == '',
          isTrue,
        );
      });
    }

    for (final raw in [
      'n42://other/chat/room',
      'n42://chat/room/extra',
      'n42://user@chat/room',
      'n42://chat:12/room',
      'n42://auth/sso/extra?token=t',
      'n42id://bind/extra?sid=$_session&hub=https://id.n42.ai',
      'n42id://bind?sid=$_session&sid=other&hub=https://id.n42.ai',
      'n42://chat/room?ref=%00',
      'javascript://chat/room',
    ]) {
      test('rejects ambiguous or malformed link ${Uri.parse(raw).host}', () {
        service.handleUri(Uri.parse(raw));
        expect(service.lastDeepLink!.type, DeepLinkType.unknown);
      });
    }

    test('legacy path form and Matrix IDs remain intact', () {
      service.handleUri(Uri.parse('n42:/chat/!room:server.example'));
      expect(service.lastDeepLink!.params['roomId'], '!room:server.example');
      final generated = DeepLinkHandler.generateUserLink('@alice:example.org');
      service.handleUri(Uri.parse(generated));
      expect(service.lastDeepLink!.params['userId'], '@alice:example.org');
    });

    test('capability is not repaired into a valid session ID', () {
      service.handleUri(
        Uri.parse('n42id://bind?sid=${_session}x%2Fy&hub=https://id.n42.ai'),
      );
      expect(service.lastDeepLink!.params['sid'], '${_session}x/y');
    });

    test('oversized URI is discarded before parsing its parameters', () {
      service.handleUri(Uri.parse('n42://chat/room?ref=${'x' * 17000}'));
      expect(service.lastDeepLink!.type, DeepLinkType.unknown);
      expect(service.lastDeepLink!.params, isEmpty);
    });

    test('share link generation rejects injectable targets', () {
      for (final target in ['', '..', 'room?token=x', 'room/other', 'a\nb']) {
        expect(
          () => DeepLinkHandler.generateChatLink(target),
          throwsArgumentError,
        );
        expect(
          () => DeepLinkHandler.generateUserLink(target),
          throwsArgumentError,
        );
        expect(
          () => DeepLinkHandler.generateGroupLink(target),
          throwsArgumentError,
        );
      }
    });

    test(
      'redacts case variants, repeated parameters, nested links and fragments',
      () {
        final data = DeepLinkData(
          type: DeepLinkType.walletConnect,
          uri: Uri.parse(
            'https://login:secret-user@example.org/?SYM_KEY=secret-one&SYM_KEY=secret-two&uri=wc%3Atopic%402%3FsymKey%3Dsecret-three#uri=secret-four',
          ),
          params: const {
            'LOGIN_TOKEN': 'secret-five',
            'Private-Key': 'secret-six',
            'sid': 'secret-seven',
          },
        );
        expect(data.toString(), isNot(contains('secret-')));
        expect(data.toString(), contains('redacted'));
        expect(data.sanitizedUri.queryParametersAll['SYM_KEY']!.length, 2);
      },
    );

    test('receipt logs never print pairing or authentication payloads', () {
      final logs = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) logs.add(message);
      };
      try {
        service.handleUri(
          Uri.parse('wc:topic@2?relay-protocol=irn&symKey=private-fixture'),
        );
        service.handleUri(
          Uri.parse('n42://auth/sso?loginToken=private-fixture'),
        );
        expect(logs.join('\n'), isNot(contains('private-fixture')));
      } finally {
        debugPrint = original;
      }
    });
  });

  group('platform lifecycle', () {
    late StreamController<Uri> source;
    late Completer<Uri?> initial;
    late DeepLinkService service;
    late List<DeepLinkData> received;
    late StreamSubscription<DeepLinkData> subscription;
    var calls = 0;
    setUp(() {
      calls = 0;
      source = StreamController<Uri>.broadcast();
      initial = Completer<Uri?>();
      service = DeepLinkService(
        getInitialLink: () {
          calls++;
          return initial.future;
        },
        uriLinkStream: source.stream,
      );
      received = [];
      subscription = service.deepLinkStream.listen(received.add);
    });
    tearDown(() async {
      await subscription.cancel();
      await service.dispose();
      await source.close();
    });

    test(
      'initialization is coalesced and initial link delivered once',
      () async {
        final first = service.init();
        expect(identical(first, service.init()), isTrue);
        initial.complete(Uri.parse('n42://chat/initial'));
        await first;
        await _flush();
        await service.init();
        expect(calls, 1);
        expect(received.single.params['roomId'], 'initial');
      },
    );

    test(
      'consumed manual intent still wins over older platform startup',
      () async {
        service.handleUri(Uri.parse('n42://chat/manual'));
        final navigated = <DeepLinkData>[];
        var ready = false;
        final handler = DeepLinkHandler(deepLinkService: service)
          ..canNavigate = (() => ready)
          ..onNavigate = navigated.add
          ..startListening();
        addTearDown(handler.dispose);
        expect(service.lastDeepLink, isNull);
        final pending = service.init();
        initial.complete(Uri.parse('n42://chat/old-platform-link'));
        await pending;
        await _flush();
        ready = true;
        handler.resumePending();
        expect(navigated.single.params['roomId'], 'manual');
      },
    );

    test(
      'startup handler retains valid intent when an unknown link follows',
      () async {
        final navigated = <DeepLinkData>[];
        var ready = false;
        final handler = DeepLinkHandler(deepLinkService: service)
          ..canNavigate = (() => ready)
          ..onNavigate = navigated.add
          ..startListening();
        addTearDown(handler.dispose);
        final pending = service.init();
        source.add(Uri.parse('n42://chat/valid'));
        source.add(Uri.parse('https://untrusted.invalid/unknown'));
        await _flush();
        initial.complete(null);
        await pending;
        ready = true;
        handler.resumePending();
        expect(navigated.single.params['roomId'], 'valid');
      },
    );

    test('live link wins over older initial result during startup', () async {
      final pending = service.init();
      source.add(Uri.parse('n42://chat/new'));
      await _flush();
      initial.complete(Uri.parse('n42://chat/old'));
      await pending;
      await _flush();
      expect(received.single.params['roomId'], 'new');
    });

    for (final beforeInit in [true, false]) {
      test(
        'manual intent wins over initial result: beforeInit=$beforeInit',
        () async {
          final uri = Uri.parse('n42://chat/manual');
          if (beforeInit) service.handleUri(uri);
          final pending = service.init();
          if (!beforeInit) service.handleUri(uri);
          initial.complete(Uri.parse('n42://chat/old-platform-link'));
          await pending;
          await _flush();
          expect(received.single.params['roomId'], 'manual');
        },
      );
    }

    test(
      'initial failure leaves live stream usable without leaking error data',
      () async {
        final pending = service.init();
        initial.completeError(StateError('sensitive startup URI'));
        await pending;
        source.add(Uri.parse('n42://chat/recovered'));
        await _flush();
        expect(received.single.params['roomId'], 'recovered');
      },
    );

    test('stream error does not cancel later delivery', () async {
      final pending = service.init();
      initial.complete(null);
      await pending;
      source.addError(StateError('sensitive stream URI'));
      source.add(Uri.parse('n42://chat/recovered'));
      await _flush();
      expect(received.single.params['roomId'], 'recovered');
    });

    test(
      'dispose during startup discards late result and forbids restart',
      () async {
        final pending = service.init();
        await service.dispose();
        initial.complete(Uri.parse('n42://chat/late'));
        await pending;
        service.handleUri(Uri.parse('n42://chat/after-dispose'));
        await service.init();
        expect(received, isEmpty);
        expect(service.lastDeepLink, isNull);
        expect(calls, 1);
        expect(source.hasListener, isFalse);
      },
    );

    testWidgets('initial timeout still accepts a subsequent live link', (
      tester,
    ) async {
      final pending = service.init();
      await tester.pump(const Duration(seconds: 5));
      await pending;
      source.add(Uri.parse('n42://chat/after-timeout'));
      await tester.pump();
      expect(received.single.params['roomId'], 'after-timeout');
      initial.complete(Uri.parse('n42://chat/expired-initial'));
      await tester.pump();
      expect(received.length, 1);
    });
  });

  group('dispatch lifecycle and validation', () {
    late DeepLinkService service;
    late DeepLinkHandler handler;
    late List<DeepLinkData> delivered;
    setUp(() {
      service = DeepLinkService();
      handler = DeepLinkHandler(deepLinkService: service);
      delivered = [];
      handler.onNavigate = delivered.add;
    });
    tearDown(() async {
      handler.dispose();
      await service.dispose();
    });
    Future<void> emit(String link) async {
      service.handleUri(Uri.parse(link));
      await _flush();
    }

    test(
      'startup intent waits for readiness and resumes exactly once',
      () async {
        var ready = false;
        handler.canNavigate = () => ready;
        service.handleUri(Uri.parse('n42://chat/initial'));
        handler.startListening();
        handler.resumePending();
        expect(delivered, isEmpty);
        ready = true;
        handler.resumePending();
        handler.resumePending();
        await _flush();
        expect(delivered.single.params['roomId'], 'initial');
        expect(service.lastDeepLink, isNull);
      },
    );

    test(
      'only the latest valid intent is kept while navigation is unavailable',
      () async {
        var ready = false;
        handler.canNavigate = () => ready;
        handler.startListening();
        await emit('n42://chat/old');
        await emit('n42://chat/new');
        await emit('n42://chat/malformed%2Ftarget');
        ready = true;
        handler.resumePending();
        expect(delivered.single.params['roomId'], 'new');
      },
    );

    test('a new ready intent supersedes an older pending intent', () async {
      var ready = false;
      handler.canNavigate = () => ready;
      handler.startListening();
      await emit('n42://chat/old');
      ready = true;
      await emit('n42://chat/new');
      handler.resumePending();
      expect(delivered.single.params['roomId'], 'new');
    });

    test('null callback retains intent until callback is installed', () async {
      handler.onNavigate = null;
      handler.startListening();
      await emit('n42://chat/later');
      handler.onNavigate = delivered.add;
      handler.resumePending();
      expect(delivered.single.params['roomId'], 'later');
    });

    test('readiness exception retains intent for explicit retry', () async {
      handler.canNavigate = () => throw StateError('not ready');
      handler.startListening();
      await emit('n42://chat/later');
      handler.canNavigate = () => true;
      handler.resumePending();
      expect(delivered.single.params['roomId'], 'later');
    });

    test(
      'restarting listener does not replay an already delivered live link',
      () async {
        handler.startListening();
        await emit('n42://chat/once');
        handler.startListening();
        await _flush();
        expect(delivered.length, 1);
      },
    );

    test(
      'same active route is coalesced but can be reopened after return',
      () async {
        final completion = Completer<void>();
        handler.onNavigate = (data) {
          delivered.add(data);
          return completion.future;
        };
        handler.startListening();
        await emit('n42://chat/once');
        await emit('n42://chat/once');
        expect(delivered.length, 1);
        completion.complete();
        await _flush();
        await emit('n42://chat/once');
        expect(delivered.length, 2);
      },
    );

    test('async callback failure is caught and permits later retry', () async {
      handler.onNavigate = (_) async {
        await _flush();
        throw StateError('private URI');
      };
      handler.startListening();
      await emit('n42://chat/retry');
      await _flush();
      handler.onNavigate = delivered.add;
      await emit('n42://chat/retry');
      expect(delivered.length, 1);
    });

    test('sync callback failure is caught and permits later retry', () async {
      handler.onNavigate = (_) => throw StateError('private URI');
      handler.startListening();
      await emit('n42://chat/retry');
      handler.onNavigate = delivered.add;
      await emit('n42://chat/retry');
      expect(delivered.length, 1);
    });

    test('disposed handler drops pending intents and cannot restart', () async {
      handler.canNavigate = () => false;
      handler.startListening();
      await emit('n42://chat/queued');
      handler.dispose();
      handler.canNavigate = () => true;
      handler.resumePending();
      handler.startListening();
      await emit('n42://chat/late');
      expect(delivered, isEmpty);
    });

    for (final action in ['bind', 'auth']) {
      test('$action accepts only exact session and trusted origin', () async {
        handler.startListening();
        for (final hub in [
          'http://id.n42.ai',
          'https://id.n42.ai.evil.org',
          'https://id.n42.ai/path',
          'https://id.n42.ai?redirect=evil',
        ]) {
          await emit(
            Uri(
              scheme: 'n42id',
              host: action,
              queryParameters: {'sid': _session, 'hub': hub},
            ).toString(),
          );
        }
        await emit(
          'n42id://$action?sid=${_session.substring(0, 10)}%2F${_session.substring(10)}&hub=https://id.n42.ai',
        );
        expect(delivered, isEmpty);
        await emit('n42id://$action?sid=$_session&hub=https://id.n42.ai');
        expect(delivered.length, 1);
        expect(
          delivered.single.type,
          action == 'bind' ? DeepLinkType.idHubBind : DeepLinkType.idHubAuth,
        );
      });
    }

    test(
      'SSO rejects absent and conflicting tokens, accepts each supported alias',
      () async {
        handler.startListening();
        await emit('n42wallet://auth/sso');
        await emit('n42wallet://auth/sso?token=%20%20');
        await emit('n42wallet://auth/sso?token=a&loginToken=b');
        expect(delivered, isEmpty);
        for (final alias in ['loginToken', 'login_token', 'token']) {
          await emit('n42wallet://auth/sso?$alias=fixture');
        }
        expect(delivered.length, 3);
      },
    );

    test('empty group mining target never reaches the host', () async {
      handler.startListening();
      await emit('astraapp://astrawallet.com?type=group_mining');
      await emit('astraapp://astrawallet.com?type=group_mining&id=bad%2Fid');
      expect(delivered, isEmpty);
    });
  });

  testWidgets(
    'pending intent opens a real Navigator route only after readiness',
    (tester) async {
      final service = DeepLinkService();
      final handler = DeepLinkHandler(deepLinkService: service);
      addTearDown(() async {
        handler.dispose();
        await service.dispose();
      });
      final navKey = GlobalKey<NavigatorState>();
      var ready = false;
      handler.canNavigate = () => ready && navKey.currentState != null;
      handler.onNavigate = (data) => navKey.currentState!.push<void>(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(),
            body: Text('target: ${data.params['roomId']}'),
          ),
        ),
      );
      service.handleUri(Uri.parse('n42://chat/room'));
      handler.startListening();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: const Scaffold(body: Text('home')),
        ),
      );
      expect(find.text('target: room'), findsNothing);
      ready = true;
      handler.resumePending();
      await tester.pumpAndSettle();
      expect(find.text('target: room'), findsOneWidget);
      service.handleUri(Uri.parse('n42://chat/room'));
      await tester.pumpAndSettle();
      navKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      expect(find.text('target: room'), findsNothing);
    },
  );
}
