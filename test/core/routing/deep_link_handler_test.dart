import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/platform/deep_link_service.dart';
import 'package:n42appv2/core/routing/deep_link_handler.dart';

/// A minimal mock of DeepLinkService for testing DeepLinkHandler.
///
/// We avoid full mocking frameworks here because DeepLinkService creates
/// internal StreamControllers. Instead we create a thin test double.
class FakeDeepLinkService extends DeepLinkService {
  final StreamController<DeepLinkData> _testController =
      StreamController<DeepLinkData>.broadcast();
  DeepLinkData? _fakeLastDeepLink;

  @override
  Stream<DeepLinkData> get deepLinkStream => _testController.stream;

  @override
  DeepLinkData? get lastDeepLink => _fakeLastDeepLink;

  set fakeLastDeepLink(DeepLinkData? data) => _fakeLastDeepLink = data;

  @override
  void clearLastDeepLink() {
    _fakeLastDeepLink = null;
  }

  void emitDeepLink(DeepLinkData data) {
    _testController.add(data);
  }

  Future<void> closeController() async {
    await _testController.close();
  }
}

void main() {
  group('DeepLinkHandler', () {
    late FakeDeepLinkService fakeService;
    late DeepLinkHandler handler;
    final List<DeepLinkData> navigatedData = [];

    setUp(() {
      fakeService = FakeDeepLinkService();
      handler = DeepLinkHandler(deepLinkService: fakeService);
      navigatedData.clear();
      handler.onNavigate = navigatedData.add;
    });

    tearDown(() async {
      handler.dispose();
      await fakeService.closeController();
    });

    test('should handle stream events after startListening', () async {
      handler.startListening();

      final data = DeepLinkData(
        type: DeepLinkType.chat,
        uri: Uri.parse('n42://chat/room1'),
        params: {'roomId': 'room1'},
      );
      fakeService.emitDeepLink(data);
      await Future.delayed(Duration.zero);

      expect(navigatedData.length, 1);
      expect(navigatedData.first.type, DeepLinkType.chat);
    });

    test('should process initial deep link on startListening', () async {
      fakeService.fakeLastDeepLink = DeepLinkData(
        type: DeepLinkType.user,
        uri: Uri.parse('n42://user/alice'),
        params: {'userId': 'alice'},
      );

      handler.startListening();
      // Initial deep link is processed synchronously
      expect(navigatedData.length, 1);
      expect(navigatedData.first.type, DeepLinkType.user);
      // Should clear the last deep link after processing
      expect(fakeService.lastDeepLink, isNull);
    });

    test('should not navigate for chat with empty roomId', () async {
      handler.startListening();

      fakeService.emitDeepLink(DeepLinkData(
        type: DeepLinkType.chat,
        uri: Uri.parse('n42://chat/'),
        params: {'roomId': ''},
      ));
      await Future.delayed(Duration.zero);

      expect(navigatedData, isEmpty);
    });

    test('should not navigate for user with empty userId', () async {
      handler.startListening();

      fakeService.emitDeepLink(DeepLinkData(
        type: DeepLinkType.user,
        uri: Uri.parse('n42://user/'),
        params: {'userId': ''},
      ));
      await Future.delayed(Duration.zero);

      expect(navigatedData, isEmpty);
    });

    test('should not navigate for group with empty groupId', () async {
      handler.startListening();

      fakeService.emitDeepLink(DeepLinkData(
        type: DeepLinkType.group,
        uri: Uri.parse('n42://group/'),
        params: {'groupId': ''},
      ));
      await Future.delayed(Duration.zero);

      expect(navigatedData, isEmpty);
    });

    test('should navigate for friendCard without params check', () async {
      handler.startListening();

      final data = DeepLinkData(
        type: DeepLinkType.friendCard,
        uri: Uri.parse('astraapp://astrawallet.com?type=friendCard'),
        params: {},
      );
      fakeService.emitDeepLink(data);
      await Future.delayed(Duration.zero);

      expect(navigatedData.length, 1);
      expect(navigatedData.first.type, DeepLinkType.friendCard);
    });

    test('should navigate for walletConnect without params check', () async {
      handler.startListening();

      final data = DeepLinkData(
        type: DeepLinkType.walletConnect,
        uri: Uri.parse('wc:abc@2?relay-protocol=irn&symKey=key'),
        params: {'wcUri': 'wc:abc@2?relay-protocol=irn&symKey=key'},
      );
      fakeService.emitDeepLink(data);
      await Future.delayed(Duration.zero);

      expect(navigatedData.length, 1);
      expect(navigatedData.first.type, DeepLinkType.walletConnect);
    });

    test('should navigate for groupMining without params check', () async {
      handler.startListening();

      final data = DeepLinkData(
        type: DeepLinkType.groupMining,
        uri: Uri.parse('astraapp://astrawallet.com?type=group_mining&id=1'),
        params: {'groupId': '1'},
      );
      fakeService.emitDeepLink(data);
      await Future.delayed(Duration.zero);

      expect(navigatedData.length, 1);
      expect(navigatedData.first.type, DeepLinkType.groupMining);
    });

    test('should navigate for fullNode without params check', () async {
      handler.startListening();

      final data = DeepLinkData(
        type: DeepLinkType.fullNode,
        uri: Uri.parse('astraapp://astrawallet.com?type=full_node'),
        params: {},
      );
      fakeService.emitDeepLink(data);
      await Future.delayed(Duration.zero);

      expect(navigatedData.length, 1);
      expect(navigatedData.first.type, DeepLinkType.fullNode);
    });

    test('should not navigate for unknown type', () async {
      handler.startListening();

      fakeService.emitDeepLink(DeepLinkData(
        type: DeepLinkType.unknown,
        uri: Uri.parse('https://example.com'),
        params: {},
      ));
      await Future.delayed(Duration.zero);

      // Unknown type enters default branch, no onNavigate call
      expect(navigatedData, isEmpty);
    });

    test('should not call onNavigate if callback is null', () async {
      handler.onNavigate = null;
      handler.startListening();

      fakeService.emitDeepLink(DeepLinkData(
        type: DeepLinkType.chat,
        uri: Uri.parse('n42://chat/room1'),
        params: {'roomId': 'room1'},
      ));
      await Future.delayed(Duration.zero);

      // No crash, no callback called
      expect(navigatedData, isEmpty);
    });

    test('should cancel previous subscription on re-startListening', () async {
      handler.startListening();

      fakeService.emitDeepLink(DeepLinkData(
        type: DeepLinkType.chat,
        uri: Uri.parse('n42://chat/room1'),
        params: {'roomId': 'room1'},
      ));
      await Future.delayed(Duration.zero);
      expect(navigatedData.length, 1);

      // Re-start should cancel old subscription and start new
      handler.startListening();

      fakeService.emitDeepLink(DeepLinkData(
        type: DeepLinkType.group,
        uri: Uri.parse('n42://group/group1'),
        params: {'groupId': 'group1'},
      ));
      await Future.delayed(Duration.zero);

      // Should receive only one more, not duplicated
      expect(navigatedData.length, 2);
      expect(navigatedData[1].type, DeepLinkType.group);
    });

    // ========== Static link generators ==========

    test('generateChatLink should return correct format', () {
      expect(DeepLinkHandler.generateChatLink('room1'), 'n42://chat/room1');
    });

    test('generateUserLink should return correct format', () {
      expect(DeepLinkHandler.generateUserLink('user1'), 'n42://user/user1');
    });

    test('generateGroupLink should return correct format', () {
      expect(DeepLinkHandler.generateGroupLink('group1'), 'n42://group/group1');
    });

    test('should handle dispose gracefully', () {
      handler.startListening();
      // Should not throw
      handler.dispose();
      handler.dispose(); // Double dispose should be safe
    });
  });
}
