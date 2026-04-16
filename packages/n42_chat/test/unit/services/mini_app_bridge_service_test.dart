import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/mini_app_bridge_service.dart';
import 'package:n42_chat/src/domain/entities/mini_app_entity.dart';

import '../../mocks/mock_wallet_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MiniAppEntity buildApp(List<MiniAppPermission> permissions) {
    return MiniAppEntity(
      id: 'app',
      name: 'Test App',
      description: 'desc',
      url: 'https://example.com',
      iconUrl: 'icon',
      category: MiniAppCategory.tools,
      permissions: permissions,
    );
  }

  test(
    'initScript disables chat bridge methods when app lacks chat permissions',
    () {
      final service = MiniAppBridgeService(
        walletBridge: MockWalletBridge(),
        roomId: '!room:server',
        app: buildApp(const [MiniAppPermission.walletAddress]),
      );

      expect(service.initScript, contains('var _canChatRead = false;'));
      expect(service.initScript, contains('var _canChatSend = false;'));
      expect(service.initScript, contains('if (!_canChatRead) return null;'));
      expect(
        service.initScript,
        contains(
          "if (!_canChatSend || typeof text !== 'string' || !text.trim()) return false;",
        ),
      );
    },
  );

  test(
    'initScript enables chat bridge methods when app declares chat permissions',
    () {
      final service = MiniAppBridgeService(
        walletBridge: MockWalletBridge(),
        roomId: '!room:server',
        app: buildApp(const [
          MiniAppPermission.chatRead,
          MiniAppPermission.chatSend,
        ]),
      );

      expect(service.initScript, contains('var _canChatRead = true;'));
      expect(service.initScript, contains('var _canChatSend = true;'));
    },
  );

  test(
    'initScript disables chat bridge methods when room context is empty',
    () {
      final service = MiniAppBridgeService(
        walletBridge: MockWalletBridge(),
        roomId: '',
        app: buildApp(const [
          MiniAppPermission.chatRead,
          MiniAppPermission.chatSend,
        ]),
      );

      expect(service.initScript, contains('var _canChatRead = false;'));
      expect(service.initScript, contains('var _canChatSend = false;'));
    },
  );

  test(
    'initScript defaults chat permissions to disabled when app metadata is missing',
    () {
      final service = MiniAppBridgeService(
        walletBridge: MockWalletBridge(),
        roomId: '!room:server',
      );

      expect(service.initScript, contains('var _canChatRead = false;'));
      expect(service.initScript, contains('var _canChatSend = false;'));
    },
  );

  test('normalizeTrustedMiniAppUri accepts https URLs with host', () {
    final uri = normalizeTrustedMiniAppUri('https://mini.n42.world/path?q=1');

    expect(uri, isNotNull);
    expect(uri!.scheme, 'https');
    expect(uri.host, 'mini.n42.world');
  });

  test('normalizeTrustedMiniAppUri rejects invalid or non-https URLs', () {
    expect(normalizeTrustedMiniAppUri('http://mini.n42.world'), isNull);
    expect(normalizeTrustedMiniAppUri('notaurl'), isNull);
    expect(normalizeTrustedMiniAppUri(''), isNull);
    expect(normalizeTrustedMiniAppUri(null), isNull);
  });

  test('isTrustedMiniAppNavigationUrl allows same-origin navigation only', () {
    expect(
      isTrustedMiniAppNavigationUrl(
        appUrl: 'https://mini.n42.world/app',
        candidateUrl: 'https://mini.n42.world/other?tab=1',
      ),
      isTrue,
    );

    expect(
      isTrustedMiniAppNavigationUrl(
        appUrl: 'https://mini.n42.world/app',
        candidateUrl: 'https://cdn.n42.world/other',
      ),
      isFalse,
    );

    expect(
      isTrustedMiniAppNavigationUrl(
        appUrl: 'https://mini.n42.world:8443/app',
        candidateUrl: 'https://mini.n42.world/app',
      ),
      isFalse,
    );
  });

  test('parseMiniAppChatAction keeps sendMessage separate from close', () {
    final action = parseMiniAppChatAction(
      '{"method":"sendMessage","params":{"text":"  hello  "}}',
      canSendMessage: true,
    );

    expect(action.type, MiniAppChatActionType.sendMessage);
    expect(action.text, 'hello');
  });

  test('parseMiniAppChatAction ignores sendMessage without permission', () {
    final action = parseMiniAppChatAction(
      '{"method":"sendMessage","params":{"text":"hello"}}',
      canSendMessage: false,
    );

    expect(action.type, MiniAppChatActionType.ignore);
  });

  test('parseMiniAppChatAction maps close to close action', () {
    final action = parseMiniAppChatAction(
      '{"method":"close"}',
      canSendMessage: true,
    );

    expect(action.type, MiniAppChatActionType.close);
  });
}
