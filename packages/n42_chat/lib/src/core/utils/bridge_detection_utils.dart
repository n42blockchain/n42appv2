import '../../../n42_chat.dart';

/// Utility for detecting bridge platform from Matrix user IDs.
///
/// Uses the ghost user MXID prefix convention to identify which
/// bridge platform a user originates from.
class BridgeDetectionUtils {
  BridgeDetectionUtils._();

  /// Detect bridge platform from a Matrix user ID (MXID).
  ///
  /// Extracts the localpart from the MXID and checks if it starts
  /// with a known ghost prefix (e.g., `@whatsapp_123:server` → WhatsApp).
  static BridgePlatform? detectFromUserId(String userId) {
    final localpart = userId.split(':').first.replaceFirst('@', '');
    for (final info in BridgePlatformRegistry.allPlatforms) {
      if (info.ghostPrefix.isNotEmpty &&
          localpart.startsWith(info.ghostPrefix)) {
        return info.platform;
      }
    }
    return null;
  }

  /// Detect bridge platform from a [ConversationEntity].
  ///
  /// For direct chats, checks the `directUserId`.
  /// For group chats, scans `memberIds` for any bridged ghost user.
  static BridgePlatform? detectFromConversation(ConversationEntity conv) {
    if (conv.directUserId != null) {
      return detectFromUserId(conv.directUserId!);
    }
    final memberIds = conv.memberIds;
    if (memberIds != null) {
      for (final id in memberIds) {
        final p = detectFromUserId(id);
        if (p != null) return p;
      }
    }
    return null;
  }
}
