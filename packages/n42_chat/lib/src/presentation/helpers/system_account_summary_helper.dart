import '../../domain/entities/stored_account_entity.dart';
import '../../domain/entities/user_profile_entity.dart';

class SystemAccountSummaryHelper {
  const SystemAccountSummaryHelper._();

  static String accountSummary(List<StoredAccountEntity> accounts) {
    if (accounts.isEmpty) {
      return 'No saved accounts on this device';
    }

    final activeCount = accounts.where((account) => account.isCurrent).length;
    final savedLabel = '${accounts.length} saved on this device';
    if (activeCount <= 0) {
      return savedLabel;
    }
    return '$savedLabel · $activeCount active now';
  }

  static String deviceSummary({
    required int deviceCount,
    String? currentDeviceId,
  }) {
    if (deviceCount <= 0) {
      return 'Current session only';
    }

    final countLabel = deviceCount == 1
        ? '1 signed-in device'
        : '$deviceCount signed-in devices';
    final compactDeviceId = _compactDeviceId(currentDeviceId);
    if (compactDeviceId == null) {
      return countLabel;
    }
    return '$countLabel · current $compactDeviceId';
  }

  static String notificationSummary(NotificationSettings settings) {
    if (!settings.enabled) {
      return 'Notifications off';
    }
    if (settings.doNotDisturb) {
      final start = settings.doNotDisturbStart ?? '22:00';
      final end = settings.doNotDisturbEnd ?? '07:00';
      return 'Focus hours $start-$end';
    }

    switch (settings.privacyMode) {
      case NotificationPrivacyMode.full:
        return 'Preview, sound, and vibration controls';
      case NotificationPrivacyMode.senderOnly:
        return 'Show sender only on lock screen';
      case NotificationPrivacyMode.hidden:
        return 'Private notifications only';
    }
  }

  static String usernameSummary(String? username) {
    final trimmed = username?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Share your account without exposing phone number';
    }
    return '@$trimmed · public handle for direct contact';
  }

  static String currentAccountLabel({
    required String? userId,
    required String? homeserver,
  }) {
    final normalizedUserId = userId?.trim();
    if (normalizedUserId == null || normalizedUserId.isEmpty) {
      return 'Not signed in';
    }

    final normalizedHomeserver = homeserver?.trim();
    if (normalizedHomeserver == null || normalizedHomeserver.isEmpty) {
      return normalizedUserId;
    }
    return '$normalizedUserId · $normalizedHomeserver';
  }

  static String? _compactDeviceId(String? deviceId) {
    final normalized = deviceId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    if (normalized.length <= 8) {
      return normalized;
    }
    return '${normalized.substring(0, 4)}...${normalized.substring(normalized.length - 4)}';
  }
}
