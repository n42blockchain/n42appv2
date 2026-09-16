import '../../domain/repositories/contact_repository.dart';
import '../../services/voip/call_manager.dart';

/// Resolves an accepted contact's direct room before starting a call.
class ContactCallService {
  ContactCallService(this._contacts, this._manager);
  final IContactRepository _contacts;
  final Future<CallManager?> Function() _manager;

  Future<bool> start({
    required String userId,
    required String name,
    String? avatarUrl,
    required bool video,
  }) async {
    if (!userId.startsWith('@'))
      throw ArgumentError('Invalid contact identity');
    final manager = await _manager();
    if (manager == null || !manager.isInitialized) {
      throw StateError('Call service unavailable');
    }
    final roomId = await _contacts.startDirectChat(userId);
    if (video) {
      return manager.startVideoCall(
        roomId: roomId,
        peerId: userId,
        peerName: name,
        peerAvatarUrl: avatarUrl,
      );
    }
    return manager.startVoiceCall(
      roomId: roomId,
      peerId: userId,
      peerName: name,
      peerAvatarUrl: avatarUrl,
    );
  }
}
