// Tests for bridge_state.dart — pure Dart bridge state value objects.
// Covers: BridgeConnectionStatus enum, BridgeState (getters: isConnected,
// isLoading, hasError, canLogin, canLogout; copyWith with sentinel pattern),
// BridgeBotCommand (toMessage, static factory methods),
// BridgeBotResponse (field storage, defaults).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/integration/bridge/bridge_state.dart';
import 'package:n42_chat/src/integration/bridge/bridge_platform.dart';

// Helper: BridgeState for a given status
BridgeState _state(
  BridgeConnectionStatus status, {
  bool isAvailable = true,
  String? remoteUsername,
  String? errorMessage,
}) =>
    BridgeState(
      platform: BridgePlatform.discord,
      status: status,
      isAvailable: isAvailable,
      remoteUsername: remoteUsername,
      errorMessage: errorMessage,
    );

void main() {
  // ─────────────────────────────────────────────────
  // BridgeConnectionStatus enum
  // ─────────────────────────────────────────────────

  group('BridgeConnectionStatus enum', () {
    test('contains all six expected values', () {
      expect(BridgeConnectionStatus.values, containsAll([
        BridgeConnectionStatus.notAvailable,
        BridgeConnectionStatus.disconnected,
        BridgeConnectionStatus.connecting,
        BridgeConnectionStatus.connected,
        BridgeConnectionStatus.error,
        BridgeConnectionStatus.reconnecting,
      ]));
    });

    test('six values total', () {
      expect(BridgeConnectionStatus.values.length, 6);
    });
  });

  // ─────────────────────────────────────────────────
  // BridgeState — constructor defaults
  // ─────────────────────────────────────────────────

  group('BridgeState constructor defaults', () {
    const s = BridgeState(platform: BridgePlatform.telegram);

    test('status defaults to notAvailable', () {
      expect(s.status, BridgeConnectionStatus.notAvailable);
    });

    test('remoteUsername defaults to null', () {
      expect(s.remoteUsername, isNull);
    });

    test('statusMessage defaults to null', () {
      expect(s.statusMessage, isNull);
    });

    test('errorMessage defaults to null', () {
      expect(s.errorMessage, isNull);
    });

    test('lastConnected defaults to null', () {
      expect(s.lastConnected, isNull);
    });

    test('managementRoomId defaults to null', () {
      expect(s.managementRoomId, isNull);
    });

    test('bridgedConversationCount defaults to 0', () {
      expect(s.bridgedConversationCount, 0);
    });

    test('isAvailable defaults to false', () {
      expect(s.isAvailable, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // BridgeState — computed getters
  // ─────────────────────────────────────────────────

  group('BridgeState.isConnected', () {
    test('true when status is connected', () {
      expect(_state(BridgeConnectionStatus.connected).isConnected, isTrue);
    });

    test('false when status is disconnected', () {
      expect(_state(BridgeConnectionStatus.disconnected).isConnected, isFalse);
    });

    test('false when status is connecting', () {
      expect(_state(BridgeConnectionStatus.connecting).isConnected, isFalse);
    });

    test('false when status is error', () {
      expect(_state(BridgeConnectionStatus.error).isConnected, isFalse);
    });

    test('false when status is reconnecting', () {
      expect(_state(BridgeConnectionStatus.reconnecting).isConnected, isFalse);
    });

    test('false when status is notAvailable', () {
      expect(_state(BridgeConnectionStatus.notAvailable).isConnected, isFalse);
    });
  });

  group('BridgeState.isLoading', () {
    test('true when status is connecting', () {
      expect(_state(BridgeConnectionStatus.connecting).isLoading, isTrue);
    });

    test('true when status is reconnecting', () {
      expect(_state(BridgeConnectionStatus.reconnecting).isLoading, isTrue);
    });

    test('false when status is connected', () {
      expect(_state(BridgeConnectionStatus.connected).isLoading, isFalse);
    });

    test('false when status is error', () {
      expect(_state(BridgeConnectionStatus.error).isLoading, isFalse);
    });

    test('false when status is disconnected', () {
      expect(_state(BridgeConnectionStatus.disconnected).isLoading, isFalse);
    });
  });

  group('BridgeState.hasError', () {
    test('true when status is error', () {
      expect(_state(BridgeConnectionStatus.error).hasError, isTrue);
    });

    test('false when status is connected', () {
      expect(_state(BridgeConnectionStatus.connected).hasError, isFalse);
    });

    test('false when status is disconnected', () {
      expect(_state(BridgeConnectionStatus.disconnected).hasError, isFalse);
    });
  });

  group('BridgeState.canLogin', () {
    test('true when available AND disconnected', () {
      expect(
        _state(BridgeConnectionStatus.disconnected, isAvailable: true).canLogin,
        isTrue,
      );
    });

    test('false when not available even if disconnected', () {
      expect(
        _state(BridgeConnectionStatus.disconnected, isAvailable: false).canLogin,
        isFalse,
      );
    });

    test('false when connected (already logged in)', () {
      expect(
        _state(BridgeConnectionStatus.connected, isAvailable: true).canLogin,
        isFalse,
      );
    });

    test('false when connecting', () {
      expect(
        _state(BridgeConnectionStatus.connecting, isAvailable: true).canLogin,
        isFalse,
      );
    });

    test('false when error (cannot start new login during error state)', () {
      expect(
        _state(BridgeConnectionStatus.error, isAvailable: true).canLogin,
        isFalse,
      );
    });

    test('false when notAvailable', () {
      expect(
        _state(BridgeConnectionStatus.notAvailable, isAvailable: false).canLogin,
        isFalse,
      );
    });
  });

  group('BridgeState.canLogout', () {
    test('true when connected', () {
      expect(_state(BridgeConnectionStatus.connected).canLogout, isTrue);
    });

    test('false when disconnected', () {
      expect(_state(BridgeConnectionStatus.disconnected).canLogout, isFalse);
    });

    test('false when connecting', () {
      expect(_state(BridgeConnectionStatus.connecting).canLogout, isFalse);
    });

    test('false when error', () {
      expect(_state(BridgeConnectionStatus.error).canLogout, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // BridgeState.copyWith — sentinel pattern
  // ─────────────────────────────────────────────────

  group('BridgeState.copyWith', () {
    final base = BridgeState(
      platform: BridgePlatform.whatsapp,
      status: BridgeConnectionStatus.connected,
      remoteUsername: 'alice',
      statusMessage: 'Connected',
      errorMessage: null,
      bridgedConversationCount: 5,
      isAvailable: true,
    );

    test('copies without change when no args given', () {
      final copy = base.copyWith();
      expect(copy.status, BridgeConnectionStatus.connected);
      expect(copy.remoteUsername, 'alice');
      expect(copy.bridgedConversationCount, 5);
    });

    test('replaces status', () {
      expect(
        base.copyWith(status: BridgeConnectionStatus.error).status,
        BridgeConnectionStatus.error,
      );
    });

    test('replaces bridgedConversationCount', () {
      expect(base.copyWith(bridgedConversationCount: 10).bridgedConversationCount, 10);
    });

    test('replaces isAvailable', () {
      expect(base.copyWith(isAvailable: false).isAvailable, isFalse);
    });

    test('platform is preserved (not replaceable)', () {
      final copy = base.copyWith(status: BridgeConnectionStatus.disconnected);
      expect(copy.platform, BridgePlatform.whatsapp);
    });

    // Sentinel pattern: passing null explicitly clears the field
    test('sentinel: remoteUsername preserved when not passed', () {
      final copy = base.copyWith(status: BridgeConnectionStatus.error);
      expect(copy.remoteUsername, 'alice');
    });

    test('sentinel: remoteUsername cleared when explicitly set to null', () {
      final copy = base.copyWith(remoteUsername: null);
      expect(copy.remoteUsername, isNull);
    });

    test('sentinel: statusMessage cleared when explicitly set to null', () {
      final withMsg = BridgeState(
        platform: BridgePlatform.signal,
        statusMessage: 'Connected',
      );
      final copy = withMsg.copyWith(statusMessage: null);
      expect(copy.statusMessage, isNull);
    });

    test('sentinel: errorMessage cleared when explicitly set to null', () {
      final withErr = BridgeState(
        platform: BridgePlatform.telegram,
        status: BridgeConnectionStatus.error,
        errorMessage: 'Timeout',
      );
      final copy = withErr.copyWith(errorMessage: null);
      expect(copy.errorMessage, isNull);
    });

    test('sentinel: lastConnected cleared when explicitly set to null', () {
      final t = DateTime.utc(2024, 1, 1);
      final withTime = BridgeState(platform: BridgePlatform.slack, lastConnected: t);
      final copy = withTime.copyWith(lastConnected: null);
      expect(copy.lastConnected, isNull);
    });

    test('sentinel: managementRoomId cleared when explicitly set to null', () {
      final withRoom = BridgeState(
        platform: BridgePlatform.discord, managementRoomId: '!room:server',
      );
      final copy = withRoom.copyWith(managementRoomId: null);
      expect(copy.managementRoomId, isNull);
    });

    test('original unchanged after copyWith', () {
      base.copyWith(status: BridgeConnectionStatus.disconnected);
      expect(base.status, BridgeConnectionStatus.connected);
      expect(base.remoteUsername, 'alice');
    });
  });

  // ─────────────────────────────────────────────────
  // BridgeBotCommand
  // ─────────────────────────────────────────────────

  group('BridgeBotCommand.toMessage', () {
    test('command with no arguments returns command string alone', () {
      expect(const BridgeBotCommand('login').toMessage(), 'login');
    });

    test('command with arguments joins them with spaces', () {
      expect(const BridgeBotCommand('login', ['qr']).toMessage(), 'login qr');
    });

    test('command with multiple arguments', () {
      expect(const BridgeBotCommand('list', ['contacts', 'all']).toMessage(), 'list contacts all');
    });
  });

  group('BridgeBotCommand static constants', () {
    test('login.toMessage() is "login"', () {
      expect(BridgeBotCommand.login.toMessage(), 'login');
    });

    test('logout.toMessage() is "logout"', () {
      expect(BridgeBotCommand.logout.toMessage(), 'logout');
    });

    test('status.toMessage() is "status"', () {
      expect(BridgeBotCommand.status.toMessage(), 'status');
    });

    test('help.toMessage() is "help"', () {
      expect(BridgeBotCommand.help.toMessage(), 'help');
    });

    test('ping.toMessage() is "ping"', () {
      expect(BridgeBotCommand.ping.toMessage(), 'ping');
    });
  });

  group('BridgeBotCommand static factory methods', () {
    test('loginQR produces "login qr"', () {
      expect(BridgeBotCommand.loginQR().toMessage(), 'login qr');
    });

    test('loginToken produces "login-token <token>"', () {
      expect(BridgeBotCommand.loginToken('abc123').toMessage(), 'login-token abc123');
    });

    test('loginToken with spaces in token embeds them verbatim (injection risk)', () {
      // toMessage() joins arguments with a plain space. A token containing
      // spaces produces a message that bridge bots may parse as multiple
      // commands. This test documents the current behavior; callers must
      // validate that tokens contain no whitespace before passing them here.
      final msg = BridgeBotCommand.loginToken('abc logout').toMessage();
      expect(msg, 'login-token abc logout');
    });

    test('loginToken with empty string produces trailing space', () {
      expect(BridgeBotCommand.loginToken('').toMessage(), 'login-token ');
    });

    test('bridgeRoom produces "bridge <remoteId>"', () {
      expect(BridgeBotCommand.bridgeRoom('chat123').toMessage(), 'bridge chat123');
    });

    test('bridgeRoom with spaces in remoteId embeds them verbatim', () {
      // Same verbatim-embedding behavior as loginToken; document it here.
      expect(BridgeBotCommand.bridgeRoom('chat 123').toMessage(), 'bridge chat 123');
    });

    test('unbridgeRoom produces "unbridge"', () {
      expect(BridgeBotCommand.unbridgeRoom().toMessage(), 'unbridge');
    });

    test('listContacts produces "list contacts"', () {
      expect(BridgeBotCommand.listContacts().toMessage(), 'list contacts');
    });

    test('listGroups produces "list groups"', () {
      expect(BridgeBotCommand.listGroups().toMessage(), 'list groups');
    });

    test('sync produces "sync"', () {
      expect(BridgeBotCommand.sync().toMessage(), 'sync');
    });
  });

  // ─────────────────────────────────────────────────
  // BridgeBotResponse
  // ─────────────────────────────────────────────────

  group('BridgeBotResponse', () {
    test('stores text', () {
      const r = BridgeBotResponse(text: 'Connected successfully');
      expect(r.text, 'Connected successfully');
    });

    test('isSuccess defaults to true', () {
      expect(const BridgeBotResponse(text: 'ok').isSuccess, isTrue);
    });

    test('detectedStatus defaults to null', () {
      expect(const BridgeBotResponse(text: 'ok').detectedStatus, isNull);
    });

    test('qrCodeUrl defaults to null', () {
      expect(const BridgeBotResponse(text: 'ok').qrCodeUrl, isNull);
    });

    test('remoteUsername defaults to null', () {
      expect(const BridgeBotResponse(text: 'ok').remoteUsername, isNull);
    });

    test('stores detectedStatus when provided', () {
      const r = BridgeBotResponse(
        text: 'Connected',
        detectedStatus: BridgeConnectionStatus.connected,
      );
      expect(r.detectedStatus, BridgeConnectionStatus.connected);
    });

    test('isSuccess=false for error responses', () {
      const r = BridgeBotResponse(text: 'Error: not found', isSuccess: false);
      expect(r.isSuccess, isFalse);
    });

    test('stores remoteUsername', () {
      const r = BridgeBotResponse(text: 'Logged in as @alice', remoteUsername: '@alice');
      expect(r.remoteUsername, '@alice');
    });

    test('stores qrCodeUrl', () {
      const r = BridgeBotResponse(
        text: 'Scan QR', qrCodeUrl: 'data:image/png;base64,abc',
      );
      expect(r.qrCodeUrl, 'data:image/png;base64,abc');
    });
  });
}
