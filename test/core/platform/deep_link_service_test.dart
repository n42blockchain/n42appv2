import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/platform/deep_link_service.dart';

void main() {
  group('DeepLinkService - URI Parsing', () {
    late DeepLinkService service;
    late StreamSubscription<DeepLinkData> subscription;
    final List<DeepLinkData> receivedData = [];

    setUp(() {
      service = DeepLinkService();
      receivedData.clear();
      subscription = service.deepLinkStream.listen(receivedData.add);
    });

    tearDown(() async {
      await subscription.cancel();
      await service.dispose();
    });

    // ========== WalletConnect URI ==========

    test(
      'should detect WalletConnect URI with relay-protocol and symKey',
      () async {
        final uri = Uri.parse('wc:abc123@2?relay-protocol=irn&symKey=def456');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        expect(receivedData.first.type, DeepLinkType.walletConnect);
        expect(receivedData.first.params['wcUri'], uri.toString());
      },
    );

    test('should detect WalletConnect URI embedded in n42 scheme', () async {
      final wcUri = Uri.parse(
        'n42app://connect?wcUri=wc%3Aabc123%402%3Frelay-protocol%3Dirn%26symKey%3Dabc123',
      );

      service.handleUri(wcUri);
      await Future.delayed(Duration.zero);

      expect(receivedData.length, 1);
      expect(receivedData.first.type, DeepLinkType.walletConnect);
      expect(
        receivedData.first.params['wcUri'],
        'wc:abc123@2?relay-protocol=irn&symKey=abc123',
      );
    });

    test('should detect WalletConnect universal links', () async {
      final wcUri = Uri.parse(
        'https://walletconnect.com/wc?uri=wc%3Aabc123%402%3Frelay-protocol%3Dirn%26symKey%3Dabc123',
      );

      service.handleUri(wcUri);
      await Future.delayed(Duration.zero);

      expect(receivedData.length, 1);
      expect(receivedData.first.type, DeepLinkType.walletConnect);
      expect(
        receivedData.first.params['wcUri'],
        'wc:abc123@2?relay-protocol=irn&symKey=abc123',
      );
    });

    test('should ignore malformed WalletConnect universal links', () async {
      final wcUri = Uri.parse(
        'https://walletconnect.com/wc?uri=wc%3Aabc123%402',
      );

      service.handleUri(wcUri);
      await Future.delayed(Duration.zero);

      expect(receivedData.length, 1);
      expect(receivedData.first.type, DeepLinkType.unknown);
    });

    // ========== n42:// scheme ==========

    group('n42:// scheme parsing', () {
      test('should parse n42://chat/{roomId} with host-based format', () async {
        final uri = Uri.parse('n42://chat/!room123:server.com');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        final data = receivedData.first;
        expect(data.type, DeepLinkType.chat);
        expect(data.params['roomId'], isNotEmpty);
      });

      test('should parse n42://user/@userId:server', () async {
        final uri = Uri.parse('n42://user/@alice:server.com');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        final data = receivedData.first;
        expect(data.type, DeepLinkType.user);
        expect(data.params['userId'], isNotEmpty);
      });

      test('should parse n42://group/!groupId:server', () async {
        final uri = Uri.parse('n42://group/!group456:server.com');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        final data = receivedData.first;
        expect(data.type, DeepLinkType.group);
        expect(data.params['groupId'], isNotEmpty);
      });

      test('should return unknown for unrecognized n42 path', () async {
        final uri = Uri.parse('n42://settings/profile');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        expect(receivedData.first.type, DeepLinkType.unknown);
      });

      test('should handle n42:// with empty path', () async {
        final uri = Uri.parse('n42://');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        expect(receivedData.first.type, DeepLinkType.unknown);
      });

      test('should preserve query parameters', () async {
        final uri = Uri.parse('n42://chat/room1?ref=share&from=invite');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        final data = receivedData.first;
        expect(data.type, DeepLinkType.chat);
        expect(data.params['ref'], 'share');
        expect(data.params['from'], 'invite');
      });
    });

    group('n42app:// scheme parsing', () {
      test('should parse n42app://chat/{roomId}', () async {
        final uri = Uri.parse('n42app://chat/room123');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        expect(receivedData.first.type, DeepLinkType.chat);
      });

      test('should parse n42app://user/{userId}', () async {
        final uri = Uri.parse('n42app://user/user123');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        expect(receivedData.first.type, DeepLinkType.user);
      });
    });

    // ========== astraapp:// scheme ==========

    group('astraapp:// scheme parsing', () {
      test('should parse group_mining type', () async {
        final uri = Uri.parse(
          'astraapp://astrawallet.com?type=group_mining&id=20',
        );

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        final data = receivedData.first;
        expect(data.type, DeepLinkType.groupMining);
        expect(data.params['groupId'], '20');
      });

      test('should parse full_node type', () async {
        final uri = Uri.parse('astraapp://astrawallet.com?type=full_node');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        expect(receivedData.first.type, DeepLinkType.fullNode);
      });

      test('should parse friendCard type', () async {
        final uri = Uri.parse(
          'astraapp://astrawallet.com?type=friendCard&userid=user1&email=a@b.com',
        );

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        final data = receivedData.first;
        expect(data.type, DeepLinkType.friendCard);
        expect(data.params['userId'], 'user1');
        expect(data.params['email'], 'a@b.com');
      });

      test('should return unknown for unrecognized astraapp type', () async {
        final uri = Uri.parse('astraapp://astrawallet.com?type=unknown_type');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        expect(receivedData.first.type, DeepLinkType.unknown);
      });

      test('should return unknown for astraapp without type', () async {
        final uri = Uri.parse('astraapp://astrawallet.com');

        service.handleUri(uri);
        await Future.delayed(Duration.zero);

        expect(receivedData.length, 1);
        expect(receivedData.first.type, DeepLinkType.unknown);
      });
    });

    // ========== Unknown scheme ==========

    test('should return unknown for unrecognized scheme', () async {
      final uri = Uri.parse('https://example.com/page');

      service.handleUri(uri);
      await Future.delayed(Duration.zero);

      expect(receivedData.length, 1);
      expect(receivedData.first.type, DeepLinkType.unknown);
      expect(receivedData.first.uri, uri);
    });

    // ========== lastDeepLink ==========

    test('should store last deep link', () {
      final uri = Uri.parse('n42://chat/room1');

      expect(service.lastDeepLink, isNull);

      service.handleUri(uri);
      expect(service.lastDeepLink, isNotNull);
      expect(service.lastDeepLink!.type, DeepLinkType.chat);
    });

    test('should clear last deep link', () {
      final uri = Uri.parse('n42://chat/room1');
      service.handleUri(uri);
      expect(service.lastDeepLink, isNotNull);

      service.clearLastDeepLink();
      expect(service.lastDeepLink, isNull);
    });

    // ========== Stream behavior ==========

    test('should emit multiple events for multiple URIs', () async {
      service.handleUri(Uri.parse('n42://chat/room1'));
      service.handleUri(Uri.parse('n42://user/user1'));
      service.handleUri(Uri.parse('n42://group/group1'));
      await Future.delayed(Duration.zero);

      expect(receivedData.length, 3);
      expect(receivedData[0].type, DeepLinkType.chat);
      expect(receivedData[1].type, DeepLinkType.user);
      expect(receivedData[2].type, DeepLinkType.group);
    });

    test('should support broadcast stream (multiple listeners)', () async {
      final secondReceived = <DeepLinkData>[];
      final sub2 = service.deepLinkStream.listen(secondReceived.add);

      service.handleUri(Uri.parse('n42://chat/room1'));
      await Future.delayed(Duration.zero);

      expect(receivedData.length, 1);
      expect(secondReceived.length, 1);

      await sub2.cancel();
    });
  });

  group('DeepLinkData', () {
    test('toString should include type, uri, and params', () {
      final data = DeepLinkData(
        type: DeepLinkType.chat,
        uri: Uri.parse('n42://chat/room1'),
        params: {'roomId': 'room1'},
      );

      final str = data.toString();
      expect(str, contains('chat'));
      expect(str, contains('room1'));
    });

    test('toString should redact sensitive sso parameters', () {
      final data = DeepLinkData(
        type: DeepLinkType.chatSso,
        uri: Uri.parse(
          'n42://auth/sso?loginToken=secret-token&homeserver=https://m.si46.world',
        ),
        params: {
          'loginToken': 'secret-token',
          'homeserver': 'https://m.si46.world',
        },
      );

      final str = data.toString();
      expect(str, isNot(contains('secret-token')));
      expect(str, contains('[redacted]'));
      expect(str, contains('m.si46.world'));
    });

    test('toString should redact walletconnect symKey in nested wcUri', () {
      final data = DeepLinkData(
        type: DeepLinkType.walletConnect,
        uri: Uri.parse(
          'wc:abc123@2?relay-protocol=irn&symKey=super-secret-key',
        ),
        params: {
          'wcUri': 'wc:abc123@2?relay-protocol=irn&symKey=super-secret-key',
        },
      );

      final str = data.toString();
      expect(str, isNot(contains('super-secret-key')));
      expect(str, contains('redacted'));
    });

    test('sanitizedUri should redact walletconnect symKey in nested uri', () {
      final data = DeepLinkData(
        type: DeepLinkType.walletConnect,
        uri: Uri.parse(
          'https://walletconnect.com/wc?uri=wc%3Aabc123%402%3Frelay-protocol%3Dirn%26symKey%3Dsuper-secret-key',
        ),
        params: const {},
      );

      final sanitized = data.sanitizedUri.toString();
      expect(sanitized, isNot(contains('super-secret-key')));
      expect(sanitized, contains('redacted'));
    });
  });

  group('DeepLinkType enum', () {
    test('should have all expected values', () {
      expect(
        DeepLinkType.values,
        containsAll([
          DeepLinkType.walletConnect,
          DeepLinkType.groupMining,
          DeepLinkType.fullNode,
          DeepLinkType.friendCard,
          DeepLinkType.chat,
          DeepLinkType.user,
          DeepLinkType.group,
          DeepLinkType.unknown,
        ]),
      );
    });
  });
}
