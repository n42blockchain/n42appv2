import '../../../core/config/app_config.dart';
import '../api/id_hub_api.dart';
import '../models/id_hub_models.dart';

/// Signs an EIP-191 personal message, returning a 0x hex signature (or null if
/// the wallet is unavailable / the user declined).
typedef MessageSigner = Future<String?> Function(String message);

/// Outcome of scanning + completing an `n42id://bind` QR.
class BindSignOutcome {
  final bool success;
  final String? error;

  /// Problem code when the hub rejected completion (e.g. `binding-conflict`).
  final String? code;

  const BindSignOutcome._(this.success, {this.error, this.code});

  factory BindSignOutcome.ok() => const BindSignOutcome._(true);
  factory BindSignOutcome.fail(String error, {String? code}) =>
      BindSignOutcome._(false, error: error, code: code);
}

/// Handles a scanned `n42id://bind?sid=...&hub=...` QR: validates the hub against
/// the allowlist, pulls the exact message to sign from that hub (never trusting
/// text embedded in the QR), signs it with the wallet, and completes the session.
///
/// The hub allowlist ([AppConfig.idHubAllowedHosts]) is the core anti-phishing
/// guard - it prevents a malicious QR from redirecting the signature to an
/// attacker's server.
class IdHubBindSigner {
  /// Whether [hubUrl]'s host is on the allowlist (exact or registrable suffix).
  static bool isHubAllowed(String hubUrl) {
    final uri = Uri.tryParse(hubUrl);
    if (uri == null || uri.host.isEmpty) return false;
    if (uri.scheme != 'https') return false;
    final host = uri.host.toLowerCase();
    return AppConfig.idHubAllowedHosts.any(
      (allowed) => host == allowed || host.endsWith('.$allowed'),
    );
  }

  /// Run the full bind flow. [apiFactory] builds an [IdHubApi] for the validated
  /// hub URL (injectable for tests); defaults to a real client.
  Future<BindSignOutcome> completeBind({
    required String sessionId,
    required String hubUrl,
    required String address,
    required MessageSigner sign,
    String chain = IdHubApi.defaultChainCaip2,
    String signerType = 'eoa',
    IdHubApi Function(String hubUrl)? apiFactory,
  }) async {
    if (!isHubAllowed(hubUrl)) {
      return BindSignOutcome.fail('untrusted hub', code: 'untrusted-hub');
    }
    final api = (apiFactory ?? (u) => IdHubApi(baseUrl: u))(hubUrl);

    try {
      final session = await api.getBindSession(sessionId);
      if (session.status != 'pending') {
        return BindSignOutcome.fail('session ${session.status}',
            code: 'session-${session.status}');
      }

      // Always pull the message to sign from the hub - never sign QR-embedded text.
      final challenge = await api.prepareBindSession(
        sessionId: sessionId,
        address: address,
        chain: chain,
      );
      final signature = await sign(challenge.message);
      if (signature == null || signature.isEmpty) {
        return BindSignOutcome.fail('declined', code: 'declined');
      }

      await api.completeBindSession(
        sessionId: sessionId,
        challengeId: challenge.challengeId,
        signature: signature,
        signerType: signerType,
      );
      return BindSignOutcome.ok();
    } on IdHubException catch (e) {
      return BindSignOutcome.fail(e.message, code: e.code);
    }
  }
}
