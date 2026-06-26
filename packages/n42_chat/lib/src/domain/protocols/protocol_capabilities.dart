import 'package:flutter/foundation.dart';

/// Declares the capabilities of a messaging protocol implementation.
///
/// Used by the application to adapt its UI and features based on
/// what the underlying protocol supports. For example, the UI can
/// hide the "edit message" button if [supportsEditing] is false.
@immutable
class ProtocolCapabilities {
  /// Whether the protocol supports end-to-end encryption
  final bool supportsE2EE;

  /// Whether the protocol supports group chats
  final bool supportsGroups;

  /// Whether the protocol supports threaded conversations
  final bool supportsThreads;

  /// Whether the protocol supports voice/video calls
  final bool supportsVoice;

  /// Whether the protocol supports token-gated access
  final bool supportsTokenGating;

  /// Whether the protocol supports message reactions
  final bool supportsReactions;

  /// Whether the protocol supports message editing
  final bool supportsEditing;

  /// Whether the protocol supports message deletion
  final bool supportsDeletion;

  /// Whether the protocol supports read receipts
  final bool supportsReadReceipts;

  /// Whether the protocol supports typing indicators
  final bool supportsTypingIndicators;

  /// Whether the protocol supports file uploads
  final bool supportsFileUpload;

  /// Maximum message size in bytes (0 = unlimited)
  final int maxMessageSize;

  /// Maximum file upload size in bytes (0 = unlimited)
  final int maxFileSize;

  /// Supported media MIME types
  final List<String> supportedMediaTypes;

  const ProtocolCapabilities({
    this.supportsE2EE = false,
    this.supportsGroups = false,
    this.supportsThreads = false,
    this.supportsVoice = false,
    this.supportsTokenGating = false,
    this.supportsReactions = false,
    this.supportsEditing = false,
    this.supportsDeletion = false,
    this.supportsReadReceipts = false,
    this.supportsTypingIndicators = false,
    this.supportsFileUpload = false,
    this.maxMessageSize = 0,
    this.maxFileSize = 0,
    this.supportedMediaTypes = const [],
  });

  /// Full-featured capabilities (e.g., Matrix).
  ///
  /// Declares support for all major features with a 50 MB file size limit
  /// and common media MIME types.
  const ProtocolCapabilities.fullFeatured()
      : supportsE2EE = true,
        supportsGroups = true,
        supportsThreads = true,
        supportsVoice = true,
        supportsTokenGating = true,
        supportsReactions = true,
        supportsEditing = true,
        supportsDeletion = true,
        supportsReadReceipts = true,
        supportsTypingIndicators = true,
        supportsFileUpload = true,
        maxMessageSize = 0,
        maxFileSize = 50 * 1024 * 1024,
        supportedMediaTypes = const [
          'image/jpeg',
          'image/png',
          'image/gif',
          'image/webp',
          'video/mp4',
          'audio/ogg',
          'audio/mp4',
          'application/pdf',
        ];

  /// Check if a specific feature is supported by name.
  ///
  /// Supported feature names:
  /// `e2ee`, `groups`, `threads`, `voice`, `tokenGating`,
  /// `reactions`, `editing`, `deletion`, `readReceipts`,
  /// `typing`, `fileUpload`.
  bool supports(String feature) {
    switch (feature) {
      case 'e2ee':
        return supportsE2EE;
      case 'groups':
        return supportsGroups;
      case 'threads':
        return supportsThreads;
      case 'voice':
        return supportsVoice;
      case 'tokenGating':
        return supportsTokenGating;
      case 'reactions':
        return supportsReactions;
      case 'editing':
        return supportsEditing;
      case 'deletion':
        return supportsDeletion;
      case 'readReceipts':
        return supportsReadReceipts;
      case 'typing':
        return supportsTypingIndicators;
      case 'fileUpload':
        return supportsFileUpload;
      default:
        return false;
    }
  }
}
