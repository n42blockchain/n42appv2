import 'package:equatable/equatable.dart';

/// A locally stored Matrix account that can be resumed on this device.
class StoredAccountEntity extends Equatable {
  final String userId;
  final String homeserver;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? addedAt;
  final bool isCurrent;

  const StoredAccountEntity({
    required this.userId,
    required this.homeserver,
    this.displayName,
    this.avatarUrl,
    this.addedAt,
    this.isCurrent = false,
  });

  String get effectiveDisplayName {
    final normalized = displayName?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
    return userId.split(':').first.replaceFirst('@', '');
  }

  @override
  List<Object?> get props => [
    userId,
    homeserver,
    displayName,
    avatarUrl,
    addedAt,
    isCurrent,
  ];
}
