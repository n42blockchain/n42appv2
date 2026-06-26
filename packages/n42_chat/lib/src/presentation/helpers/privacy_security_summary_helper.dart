import '../../core/encryption/e2ee_manager.dart';
import '../../core/encryption/key_backup_service.dart';
import '../../core/services/privacy_http_client.dart';
import '../../core/services/self_destruct_service.dart';
import '../../domain/entities/user_profile_entity.dart';

class PrivacySecuritySummaryHelper {
  const PrivacySecuritySummaryHelper._();

  static String identitySummary({
    required PrivacySettings settings,
    String? username,
  }) {
    final trimmedUsername = username?.trim();
    if (trimmedUsername != null && trimmedUsername.isNotEmpty) {
      if (settings.hidePhoneNumber) {
        return '@$trimmedUsername for public contact · phone masked locally';
      }
      return '@$trimmedUsername available for direct contact';
    }

    if (settings.hidePhoneNumber) {
      return 'Phone masked on this device';
    }
    return 'Phone or Matrix ID may still be shared directly';
  }

  static String conversationSummary({
    required PrivacySettings settings,
    required bool screenshotProtectionEnabled,
  }) {
    final parts = <String>[
      settings.defaultEncryptNewChats
          ? 'New chats encrypted by default'
          : 'Encryption enabled manually per chat',
      _screenshotSummary(
        privateChatMode: settings.privateChatMode,
        screenshotProtectionEnabled: screenshotProtectionEnabled,
      ),
    ];

    final selfDestructSeconds = settings.defaultSelfDestructSeconds;
    if (selfDestructSeconds != null && selfDestructSeconds > 0) {
      parts.add(
        'Self-destruct ${SelfDestructService.formatDuration(selfDestructSeconds)}',
      );
    } else {
      parts.add('Self-destruct off');
    }

    return parts.join(' · ');
  }

  static String networkSummary(PrivacySettings settings) {
    final parts = <String>[];

    if (settings.useTor) {
      parts.add(
        'Tor / Privoxy via ${Uri.parse(kDefaultTorHttpProxy).host}:${Uri.parse(kDefaultTorHttpProxy).port}',
      );
    } else if (settings.proxyEnabled) {
      final proxyUri = resolvePrivacyProxyUri(settings);
      if (proxyUri != null) {
        final hostLabel = proxyUri.hasPort
            ? '${proxyUri.host}:${proxyUri.port}'
            : proxyUri.host;
        if (settings.protectIpAddress) {
          parts.add('IP protection through $hostLabel');
        } else {
          parts.add('Custom proxy through $hostLabel');
        }
      } else {
        parts.add('Custom proxy enabled, but endpoint is invalid');
      }
    } else if (settings.protectIpAddress) {
      parts.add('IP protection requested, but no proxy endpoint configured');
    } else {
      parts.add('Direct network path');
    }

    if (!settings.showLinkPreviews) {
      parts.add('Link previews off');
    }

    return parts.join(' · ');
  }

  static String encryptionSummary({
    required E2EEStatus status,
    KeyBackupInfo? backupInfo,
  }) {
    switch (status) {
      case E2EEStatus.notSupported:
        return 'End-to-end encryption unavailable on this session';
      case E2EEStatus.notInitialized:
        return 'Encryption supported, but not initialized yet';
      case E2EEStatus.ready:
        if (backupInfo == null) {
          return 'E2EE ready · backup not configured';
        }
        return 'E2EE ready · ${backupInfo.count} keys backed up';
    }
  }

  static String deviceVerificationSummary({
    required int deviceCount,
    required int verifiedDeviceCount,
  }) {
    if (deviceCount <= 0) {
      return 'No active session';
    }
    if (verifiedDeviceCount <= 0) {
      return '$deviceCount devices · verification pending';
    }
    if (verifiedDeviceCount >= deviceCount) {
      return '$deviceCount devices · all verified';
    }
    final pending = deviceCount - verifiedDeviceCount;
    return '$deviceCount devices · $pending need verification';
  }

  static String? validateCustomProxyUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'Enter an HTTP or HTTPS proxy endpoint';
    }

    final settings = PrivacySettings(proxyEnabled: true, proxyUrl: trimmed);
    return resolvePrivacyProxyUri(settings) == null
        ? 'Proxy must be a valid HTTP/HTTPS URL with host and port'
        : null;
  }

  static bool hasValidCustomProxy(PrivacySettings settings) {
    if (!settings.proxyEnabled) {
      return false;
    }
    return resolvePrivacyProxyUri(settings) != null;
  }

  static String _screenshotSummary({
    required bool privateChatMode,
    required bool screenshotProtectionEnabled,
  }) {
    if (screenshotProtectionEnabled) {
      return 'Global screenshot blocking on';
    }
    if (privateChatMode) {
      return 'Private-chat screenshot blocking on';
    }
    return 'Screenshot blocking off';
  }
}
