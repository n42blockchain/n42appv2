import 'package:matrix/matrix.dart' as matrix;

/// An outgoing direct-room invitation is not yet an accepted friendship.
/// Group rooms and the user's own saved-messages room keep their SDK policy.
matrix.Room? roomForSending(matrix.Client? client, String roomId) {
  final room = client?.getRoomById(roomId);
  final partner = room?.directChatMatrixID;
  if (room != null && partner != null && partner != client?.userID) {
    final member = room.unsafeGetUserFromMemoryOrFallback(partner);
    if (room.membership != matrix.Membership.join ||
        member.content['membership'] != 'join') {
      throw StateError('Friend request has not been accepted');
    }
  }
  return room;
}
