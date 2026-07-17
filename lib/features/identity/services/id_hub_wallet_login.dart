import '../api/id_hub_api.dart';
import '../models/id_hub_models.dart';
import 'id_token_store.dart';

/// Signs an EIP-191 personal message, returning a 0x hex signature (or null if
/// the wallet is unavailable / the user declined). Satisfied by
/// `N42WalletBridge.signMessage`.
typedef MessageSigner = Future<String?> Function(String message);

/// Orchestrates wallet DID-auth against the N42 ID Hub: challenge -> sign the
/// hub-issued message -> verify -> cache the token. Decoupled from the wallet
/// SDK via [MessageSigner] so it is trivially testable and the caller wires the
/// bridge.
class IdHubWalletLogin {
  final IdHubApi _api;
  final IdTokenStore _store;

  IdHubWalletLogin({IdHubApi? api, IdTokenStore? store})
      : _api = api ?? IdHubApi(),
        _store = store ?? IdTokenStore();

  bool get isEnabled => _api.isEnabled;

  /// Run the full login. Returns the result (token + didCreated) and persists
  /// the token bundle under its DID. Throws [IdHubException] on hub errors and
  /// [StateError] if the wallet declines to sign - callers catch and fall back.
  Future<IdHubWalletLoginResult> login({
    required String address,
    required MessageSigner sign,
    String chain = IdHubApi.defaultChainCaip2,
    String signerType = 'eoa',
    String aud = 'wallet-api',
  }) async {
    final challenge = await _api.createWalletChallenge(
      address: address,
      chain: chain,
      aud: aud,
    );

    // The wallet signs the exact message the hub issued - never a locally
    // fabricated one - so the server can rebuild and verify it against the nonce.
    final signature = await sign(challenge.message);
    if (signature == null || signature.isEmpty) {
      throw StateError('wallet declined to sign the login challenge');
    }

    final result = await _api.verifyWalletLogin(
      challengeId: challenge.challengeId,
      signature: signature,
      signerType: signerType,
    );

    final did = result.token.sub;
    if (did != null && did.isNotEmpty) {
      await _store.save(did, result.token);
    }
    return result;
  }
}
