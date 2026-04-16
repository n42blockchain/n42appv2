import 'dart:async';

import '../../domain/protocols/messaging_protocol.dart';
import '../../domain/protocols/protocol_capabilities.dart';
import '../../domain/protocols/protocol_event.dart';
import '../datasources/matrix/matrix_client_manager.dart';
import '../datasources/matrix/matrix_contact_datasource.dart';
import '../datasources/matrix/matrix_message_datasource.dart';
import '../datasources/matrix/matrix_room_datasource.dart';

/// Matrix protocol implementation of [IMessagingProtocol].
///
/// Wraps existing Matrix datasources to provide a unified protocol interface.
/// This allows future protocols (XMTP, Waku) to be swapped in without
/// changing the repository or presentation layers.
///
/// The implementation delegates to the existing datasource classes that
/// already handle Matrix SDK interactions, ensuring consistency with
/// the rest of the codebase.
class MatrixProtocol implements IMessagingProtocol {
  final MatrixClientManager _clientManager;
  final MatrixRoomDataSource _roomDataSource;
  final MatrixMessageDataSource _messageDataSource;
  final MatrixContactDataSource _contactDataSource;

  final _connectionController =
      StreamController<ProtocolConnectionState>.broadcast();
  final _eventController = StreamController<ProtocolEvent>.broadcast();

  MatrixProtocol({
    required MatrixClientManager clientManager,
    required MatrixRoomDataSource roomDataSource,
    required MatrixMessageDataSource messageDataSource,
    required MatrixContactDataSource contactDataSource,
  }) : _clientManager = clientManager,
       _roomDataSource = roomDataSource,
       _messageDataSource = messageDataSource,
       _contactDataSource = contactDataSource;

  @override
  String get protocolId => 'matrix';

  @override
  ProtocolCapabilities get capabilities =>
      const ProtocolCapabilities.fullFeatured();

  @override
  bool get isConnected => _clientManager.client?.isLogged() ?? false;

  @override
  Stream<ProtocolConnectionState> get connectionState =>
      _connectionController.stream;

  @override
  Stream<ProtocolEvent> get eventStream => _eventController.stream;

  // ─── Connection Management ───────────────────────────────────────

  @override
  Future<void> connect(ProtocolCredentials credentials) async {
    _connectionController.add(ProtocolConnectionState.connecting);
    try {
      // Matrix connection is managed by MatrixClientManager + AuthDataSource.
      // This protocol wrapper observes and broadcasts the state.
      // Actual login/token-restore is handled by the auth layer before
      // this method is called; we just transition the state here.
      _connectionController.add(ProtocolConnectionState.connected);
    } catch (e) {
      _connectionController.add(ProtocolConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    _connectionController.add(ProtocolConnectionState.disconnected);
  }

  // ─── Messaging ───────────────────────────────────────────────────

  @override
  Future<String> sendMessage(String roomId, MessageContent content) async {
    try {
      String? eventId;

      switch (content.type) {
        case MessageContentType.text:
          eventId = await _messageDataSource.sendTextMessage(
            roomId,
            content.text ?? '',
          );
        case MessageContentType.image:
        case MessageContentType.video:
        case MessageContentType.audio:
        case MessageContentType.file:
        case MessageContentType.location:
        case MessageContentType.sticker:
        case MessageContentType.custom:
          // For non-text types, fall back to sending as text.
          // Full media support requires Uint8List data which is handled
          // by the datasource layer directly for richer media flows.
          eventId = await _messageDataSource.sendTextMessage(
            roomId,
            content.text ?? '[Unsupported content type: ${content.type.name}]',
          );
      }

      if (eventId == null) {
        throw StateError('Failed to send message: no event ID returned');
      }
      return eventId;
    } catch (e) {
      throw StateError('Failed to send message to room $roomId: $e');
    }
  }

  // ─── Room Management ─────────────────────────────────────────────

  @override
  Future<String> createRoom(RoomCreationParams params) async {
    try {
      if (params.isDirect && params.inviteUserIds.isNotEmpty) {
        return await _roomDataSource.createDirectChat(
          params.inviteUserIds.first,
          encrypted: params.enableEncryption,
        );
      }
      return await _roomDataSource.createGroupChat(
        name: params.name ?? '',
        topic: params.topic,
        inviteUserIds: params.inviteUserIds,
        encrypted: params.enableEncryption,
      );
    } catch (e) {
      throw StateError('Failed to create room: $e');
    }
  }

  @override
  Future<List<RoomSummary>> getRooms() async {
    try {
      final rooms = _clientManager.client?.rooms ?? [];
      return rooms.map((room) {
        return RoomSummary(
          id: room.id,
          name: room.getLocalizedDisplayname(),
          avatarUrl: room.avatar?.toString(),
          memberCount: room.summary.mJoinedMemberCount ?? 0,
          lastMessage: room.lastEvent?.body,
          lastActivity: room.lastEvent?.originServerTs,
          isDirect: room.isDirectChat,
          isEncrypted: room.encrypted,
        );
      }).toList();
    } catch (e) {
      throw StateError('Failed to get rooms: $e');
    }
  }

  @override
  Future<void> joinRoom(String roomId) async {
    try {
      await _roomDataSource.joinRoom(roomId);
    } catch (e) {
      throw StateError('Failed to join room $roomId: $e');
    }
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    try {
      await _roomDataSource.leaveRoom(roomId);
    } catch (e) {
      throw StateError('Failed to leave room $roomId: $e');
    }
  }

  // ─── User Management ─────────────────────────────────────────────

  @override
  Future<ProtocolUserProfile> getUserProfile(String userId) async {
    try {
      final profile = await _contactDataSource.getUserProfile(userId);
      return ProtocolUserProfile(
        userId: userId,
        displayName: profile?.displayName,
        avatarUrl: profile?.avatarUrl?.toString(),
      );
    } catch (e) {
      throw StateError('Failed to get user profile for $userId: $e');
    }
  }

  @override
  Future<List<ProtocolUserProfile>> searchUsers(String query) async {
    try {
      final results = await _contactDataSource.searchUsers(query);
      return results.map((profile) {
        return ProtocolUserProfile(
          userId: profile.userId,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl?.toString(),
        );
      }).toList();
    } catch (e) {
      throw StateError('Failed to search users with query "$query": $e');
    }
  }

  /// Dispose stream controllers and release resources.
  ///
  /// Must be called when the protocol instance is no longer needed
  /// to prevent memory leaks. Safe to call multiple times.
  void dispose() {
    if (!_connectionController.isClosed) {
      _connectionController.close();
    }
    if (!_eventController.isClosed) {
      _eventController.close();
    }
  }
}
