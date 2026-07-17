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
| `services/id_hub_bind_signer.dart` | `n42id://bind` scan-to-sign: hub-allowlist guard + getSession -> prepare -> sign -> complete |

## n42id:// scan-to-sign (P3-B)

`IdHubBindSigner` powers the wallet side of 11X's BindWallet QR. Given a scanned
`n42id://bind?sid=...&hub=...`:

1. **Anti-phishing guard**: `isHubAllowed(hubUrl)` checks the hub host against
   `AppConfig.idHubAllowedHosts` (exact or registrable suffix, https only). A
   malicious QR pointing `hub` at an attacker server is refused before any call.
2. The message to sign is always **pulled from the hub** (`prepareBindSession`),
   never taken from QR-embedded text.
3. Wallet signs via a `MessageSigner` (wire to `N42WalletBridge.signMessage`);
   `completeBindSession` submits it. Hub error codes (e.g. `binding-conflict`)
   surface in the outcome.

### Deep-link wiring (native, not device-verified)

The `n42id://bind|auth` scheme is now wired end to end in code (device verification
pending):

- **Scheme registration**: `android/.../AndroidManifest.xml`, `ios/Runner/Info.plist`,
  `macos/Runner/Info.plist` accept `n42id`.
- **Parse**: `DeepLinkService` allowlists `n42id`, adds `DeepLinkType.idHubBind` /
  `idHubAuth`, parses `sid`+`hub` (`_parseN42IdUri`), and redacts `sid` in logs.
- **Validate**: `DeepLinkHandler` drops any link whose `sid` is empty or whose
  `hub` fails `IdHubBindSigner.isHubAllowed` (anti-phishing gate).
- **Dispatch**: `main.dart._handleDeepLinkNavigation` pushes `IdHubSignPage`.
- **Sign page**: `pages/id_hub_sign_page.dart` re-checks the hub allowlist, pulls
  the message from the hub (`prepare`), shows the decoded request (action, wallet,
  hub domain, message), and on confirm signs via `N42WalletBridge` +
  `completeBindSession`.
- **In-app scan**: `services/id_hub_scan.dart` `tryHandleIdHubScan` routes a scanned
  `n42id://` string into the deep-link pipeline; wired into `send_utils.dart` scans.

Covered by unit tests (n42id parse + sid redaction in `deep_link_service_test.dart`;
allowlist + flow in `id_hub_bind_signer_test.dart`). The `IdHubSignPage` UI and
real device deep-link delivery still need on-device QA. A pending-when-locked queue
(mirroring `chat_initialization`) is an optional refinement - today the page reads
the wallet address on open and prompts to unlock if absent.

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
