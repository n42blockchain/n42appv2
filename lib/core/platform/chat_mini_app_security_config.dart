import 'dart:convert';

import 'package:n42_chat/n42_chat.dart';

/// Public trust anchors only. A configured but invalid endpoint/key stays in
/// managed mode so the plugin fails closed instead of silently disabling policy.
MiniAppSecurityConfig resolveChatMiniAppSecurity({
  String policyUrl = const String.fromEnvironment(
    'N42_CHAT_MINI_APP_POLICY_URL',
  ),
  String policyKeys = const String.fromEnvironment(
    'N42_CHAT_MINI_APP_POLICY_KEYS',
  ),
  String launchKeys = const String.fromEnvironment(
    'N42_CHAT_MINI_APP_LAUNCH_KEYS',
  ),
  String upgradeUrl = const String.fromEnvironment('N42_CHAT_UPGRADE_URL'),
  String audience = const String.fromEnvironment(
    'N42_CHAT_MINI_APP_AUDIENCE',
    defaultValue: 'n42chat-miniapp',
  ),
}) => MiniAppSecurityConfig(
  policyUrl: policyUrl.isEmpty ? null : policyUrl,
  upgradeUrl: upgradeUrl.isEmpty ? null : upgradeUrl,
  policyPublicKeys: _publicKeys(policyKeys),
  launchPublicKeys: _publicKeys(launchKeys),
  audience: audience,
);

Map<String, String> _publicKeys(String value) {
  if (value.isEmpty) return const {};
  try {
    final decoded = jsonDecode(value) as Map<String, dynamic>;
    if (decoded.length > 16) return const {};
    final keys = <String, String>{};
    for (final entry in decoded.entries) {
      if (entry.key.isEmpty ||
          entry.value is! String ||
          base64Url.decode(base64Url.normalize(entry.value as String)).length !=
              32) {
        return const {};
      }
      keys[entry.key] = entry.value as String;
    }
    return Map.unmodifiable(keys);
  } catch (_) {
    return const {};
  }
}
