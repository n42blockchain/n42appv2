import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart';

void main() {
  group('BridgeState', () {
    test('default state should be notAvailable', () {
      const state = BridgeState(platform: BridgePlatform.discord);

      expect(state.status, BridgeConnectionStatus.notAvailable);
      expect(state.isAvailable, isFalse);
      expect(state.isConnected, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
      expect(state.canLogin, isFalse);
      expect(state.canLogout, isFalse);
      expect(state.remoteUsername, isNull);
      expect(state.managementRoomId, isNull);
      expect(state.bridgedConversationCount, 0);
    });

    test('connected state should report correctly', () {
      const state = BridgeState(
        platform: BridgePlatform.whatsapp,
        status: BridgeConnectionStatus.connected,
        isAvailable: true,
        remoteUsername: '+1234567890',
      );

      expect(state.isConnected, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
      expect(state.canLogin, isFalse);
      expect(state.canLogout, isTrue);
    });

    test('connecting state should report loading', () {
      const state = BridgeState(
        platform: BridgePlatform.signal,
        status: BridgeConnectionStatus.connecting,
        isAvailable: true,
      );

      expect(state.isConnected, isFalse);
      expect(state.isLoading, isTrue);
    });

    test('reconnecting state should report loading', () {
      const state = BridgeState(
        platform: BridgePlatform.telegram,
        status: BridgeConnectionStatus.reconnecting,
        isAvailable: true,
      );

      expect(state.isLoading, isTrue);
    });

    test('error state should report correctly', () {
      const state = BridgeState(
        platform: BridgePlatform.discord,
        status: BridgeConnectionStatus.error,
        isAvailable: true,
        errorMessage: 'Token expired',
      );

      expect(state.hasError, isTrue);
      expect(state.isConnected, isFalse);
      expect(state.canLogin, isFalse);
      expect(state.canLogout, isFalse);
    });

    test('disconnected and available state should allow login', () {
      const state = BridgeState(
        platform: BridgePlatform.slack,
        status: BridgeConnectionStatus.disconnected,
        isAvailable: true,
      );

      expect(state.canLogin, isTrue);
      expect(state.canLogout, isFalse);
    });

    test('copyWith should preserve unchanged fields', () {
      const original = BridgeState(
        platform: BridgePlatform.discord,
        status: BridgeConnectionStatus.connected,
        isAvailable: true,
        remoteUsername: 'user#1234',
        managementRoomId: '!room:server',
      );

      final updated = original.copyWith(
        status: BridgeConnectionStatus.error,
        errorMessage: 'Connection lost',
      );

      expect(updated.platform, BridgePlatform.discord);
      expect(updated.status, BridgeConnectionStatus.error);
      expect(updated.isAvailable, isTrue);
      expect(updated.remoteUsername, 'user#1234');
      expect(updated.managementRoomId, '!room:server');
      expect(updated.errorMessage, 'Connection lost');
    });

    test('toString should include platform and status', () {
      const state = BridgeState(
        platform: BridgePlatform.whatsapp,
        status: BridgeConnectionStatus.connected,
        remoteUsername: 'test',
      );

      final str = state.toString();
      expect(str, contains('whatsapp'));
      expect(str, contains('connected'));
      expect(str, contains('test'));
    });
  });

  group('BridgeConnectionStatus', () {
    test('should have all expected values', () {
      expect(BridgeConnectionStatus.values, containsAll([
        BridgeConnectionStatus.notAvailable,
        BridgeConnectionStatus.disconnected,
        BridgeConnectionStatus.connecting,
        BridgeConnectionStatus.connected,
        BridgeConnectionStatus.error,
        BridgeConnectionStatus.reconnecting,
      ]));
    });
  });

  group('BridgeBotCommand', () {
    test('login command should format correctly', () {
      expect(BridgeBotCommand.login.toMessage(), 'login');
    });

    test('logout command should format correctly', () {
      expect(BridgeBotCommand.logout.toMessage(), 'logout');
    });

    test('status command should format correctly', () {
      expect(BridgeBotCommand.status.toMessage(), 'status');
    });

    test('help command should format correctly', () {
      expect(BridgeBotCommand.help.toMessage(), 'help');
    });

    test('loginQR should format with qr argument', () {
      expect(BridgeBotCommand.loginQR().toMessage(), 'login qr');
    });

    test('loginToken should include token', () {
      expect(
        BridgeBotCommand.loginToken('abc123').toMessage(),
        'login-token abc123',
      );
    });

    test('bridgeRoom should include room id', () {
      expect(
        BridgeBotCommand.bridgeRoom('!room:server').toMessage(),
        'bridge !room:server',
      );
    });

    test('unbridgeRoom should format correctly', () {
      expect(BridgeBotCommand.unbridgeRoom().toMessage(), 'unbridge');
    });

    test('listContacts should format correctly', () {
      expect(BridgeBotCommand.listContacts().toMessage(), 'list contacts');
    });

    test('listGroups should format correctly', () {
      expect(BridgeBotCommand.listGroups().toMessage(), 'list groups');
    });

    test('sync should format correctly', () {
      expect(BridgeBotCommand.sync().toMessage(), 'sync');
    });

    test('custom command with arguments', () {
      const cmd = BridgeBotCommand('set-relay', ['--room', '!abc:s']);
      expect(cmd.toMessage(), 'set-relay --room !abc:s');
    });

    test('command without arguments', () {
      const cmd = BridgeBotCommand('ping');
      expect(cmd.toMessage(), 'ping');
    });
  });

  group('BridgeBotResponse', () {
    test('should create with required fields', () {
      const response = BridgeBotResponse(text: 'Logged in as user');

      expect(response.text, 'Logged in as user');
      expect(response.isSuccess, isTrue);
      expect(response.qrCodeUrl, isNull);
      expect(response.detectedStatus, isNull);
      expect(response.remoteUsername, isNull);
    });

    test('should create error response', () {
      const response = BridgeBotResponse(
        text: 'Login failed: invalid token',
        isSuccess: false,
        detectedStatus: BridgeConnectionStatus.error,
      );

      expect(response.isSuccess, isFalse);
      expect(response.detectedStatus, BridgeConnectionStatus.error);
    });

    test('should include QR code URL', () {
      const response = BridgeBotResponse(
        text: 'Scan QR code to login',
        qrCodeUrl: 'mxc://server/qrcode123',
        detectedStatus: BridgeConnectionStatus.connecting,
      );

      expect(response.qrCodeUrl, 'mxc://server/qrcode123');
    });
  });
}
