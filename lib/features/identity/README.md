# Identity (N42 ID Hub client)

Wallet-side client for the unified-identity **N42 ID Hub**: wallet DID-auth login
(challenge -> sign -> verify), per-DID N42 ID Token custody, and refresh.

Upstream design: the unified-DID identity design + `p3-wallet-chat-changes.md`.

## Graceful degradation (the fallback contract)

Everything is gated on `IdHubApi.isEnabled`, derived from the `idHubHost` entry
in `AppConfig.apiUrl`. Both `main`/`test` ship **empty**, so `isEnabled` is
`false`: callers skip the hub and use the pre-ID-Hub flow, and `IdHubApi` throws
locally rather than send a token to an unconfigured host. Fill in `idHubHost` per
environment to light it up. Unset = app behaves exactly as today.

## Modules

| File | Responsibility |
|------|----------------|
| `models/id_hub_models.dart` | Contract models (token, challenge, stored token, `IdHubException`) |
| `api/id_hub_api.dart` | Self-contained Dio client; RFC 9457 problem+json error codes; `isEnabled` guard |
| `services/id_token_store.dart` | Per-DID token custody (SecureStorage), pre-expiry refresh, single-flight |
| `services/id_hub_wallet_login.dart` | challenge -> sign -> verify orchestration, decoupled from the wallet SDK via a `MessageSigner` |

Token storage uses `SecureStorage.saveIdHubToken/getIdHubToken/deleteIdHubToken`,
keyed `n42id_token_<did>`, and is wiped by `clearUserData()` on logout.

### Refresh safety

Refresh tokens rotate (`<sid>.<secret>`): replaying a stale one revokes the whole
session family, so refreshes for one DID are **single-flighted**. A `401` on
refresh is terminal - the local token is cleared and the next call re-logs-in.

## Wiring the login

`IdHubWalletLogin.login` takes the wallet address and a `MessageSigner`. Wire it
to the bridge at the call site:

```dart
final bridge = ...; // N42WalletBridge (implements IWalletBridge)
final addr = bridge.walletAddress;
final result = await IdHubWalletLogin().login(
  address: addr!,
  sign: bridge.signMessage, // EIP-191 personal_sign of the hub-issued message
);
// result.token is cached; result.didCreated flags first-ever DID provisioning.
```

The wallet signs the exact message the hub issued (server nonce), never a locally
fabricated one.

## Not yet wired

The identity-center UI, the `n42id://` scan-to-sign flow, and PLC rotation-key
sovereignty upgrade (P3 B/C) build on this and land next.
