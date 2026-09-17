import 'package:matrix/matrix.dart' as matrix;
import 'encrypted_send_guard.dart';

class DirectFriendshipNotReady extends StateError {
  static const code = 'n42.friendship_not_ready';
  DirectFriendshipNotReady() : super(code);
  @override
  String toString() => code;
}

/// An outgoing direct-room invitation is not yet an accepted friendship.
/// Group rooms and the user's own saved-messages room keep their SDK policy.
matrix.Room? roomForSending(matrix.Client? client, String roomId) {
  final room = client?.getRoomById(roomId);
  final partner = room?.directChatMatrixID;
  if (room != null && partner != null && partner != client?.userID) {
    final member = room.unsafeGetUserFromMemoryOrFallback(partner);
    if (room.membership != matrix.Membership.join ||
        member.content['membership'] != 'join') {
      throw DirectFriendshipNotReady();
    }
  }
  return room;
}

/// Fetch authoritative membership before treating a lazy-loaded room as rejected.
Future<matrix.User> resolveDirectPeer(matrix.Room room, String peerId) async {
  // requestUser can return an old invitation indefinitely with lazy sync.
  // Recheck non-joined members against current server state before classifying.
  var member = await room
      .requestUser(peerId, requestProfile: false)
      .timeout(const Duration(seconds: 15));
  if (member == null || member.content['membership'] != 'join') {
    final content = await room.client
        .getRoomStateWithKey(room.id, matrix.EventTypes.RoomMember, peerId)
        .timeout(const Duration(seconds: 15));
    if (content['membership'] is! String) {
      throw StateError('Contact membership is not available yet');
    }
    member = matrix.User.fromState(
      stateKey: peerId,
      senderId: peerId,
      typeKey: matrix.EventTypes.RoomMember,
      content: content,
      room: room,
    );
  }

  room.setState(member);
  return member;
}

Future<matrix.Room?> resolveRoomForSending(
  matrix.Client? client,
  String roomId,
) async {
  final room = client?.getRoomById(roomId);
  final peer = room?.directChatMatrixID;
  if (room != null &&
      peer != null &&
      peer != client?.userID &&
      room.membership == matrix.Membership.join) {
    await resolveDirectPeer(room, peer);
  }
  return roomForSending(client, roomId);
}

Future<matrix.Room?> prepareRoomForSending(
  matrix.Client? client,
  String roomId,
) async {
  final room = await resolveRoomForSending(client, roomId);
  if (room != null) await EncryptedSendGuard.prepare(room);
  return roomForSending(client, roomId);
}
