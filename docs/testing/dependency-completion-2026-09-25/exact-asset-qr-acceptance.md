# Exact-asset QR acceptance checkpoint (Task 15B)

This records the reviewed source and mock-test checkpoint for exact-asset Chat payments. It is not a live transaction, device QR, native release, deployed gateway, or store acceptance result.

## Source and behavior

The host pins the published official Chat commit [`1d2e1ab4`](https://github.com/n42blockchain/n42_chat/commit/1d2e1ab4213e3ab2d7c59983e9353b02f9c766ae) by immutable Git SHA in `pubspec.yaml` and `pubspec.lock`. Its QR implementation was tested at [`42de7970`](https://github.com/n42blockchain/n42_chat/commit/42de79702f43c341c434cd6c4c9a3aeb8a3f45f4); the following Chat commit only corrected the open-issues ledger. Host capability integration is [`7706df89`](https://github.com/n42blockchain/n42appv2/commit/7706df892006ef94a16d191a8a06b3b0e8a90f09), and the bounded analyzer scope fix is [`e3286138`](https://github.com/n42blockchain/n42appv2/commit/e3286138e073d3c240ab241017b2d722e47dc577).

- `n42pay://v1/pay` accepts only `chain`, `network`, `type`, `to`, `contract`, and optional `amount`. The exact parser rejects malformed, repeated, unknown and partial fields. Native assets have no contract; tokens require one. Chain mKeys stay opaque, networks are `mainnet`/`testnet`, EVM 40-hex IDs compare without case sensitivity, and non-EVM IDs remain case sensitive. The legacy parser does not consume exact v1 requests.
- `IExactWalletTransfer` is an optional typed capability. Chat rejects unsupported or incomplete exact requests instead of falling back to a symbol-only transfer. The host `N42WalletBridge` explicitly opts in through its existing `requestTransferExact` method. Its `TokenInfo` base fields expose the selected chain, network, native/token identity, ID and receive address to Chat. Host token metadata uses the actual wallet mKeys and testnet flag; the sender receives the selected asset and decimal text.
- Scanner, transfer form, merchant/receive QR and incoming payment-message click carry exact identity through selection, confirmation and event/repository dispatch. Duplicate or same-symbol assets stay distinct; a changed or missing selected asset, wrong network, absent exact receiver, partial identity or excess decimal precision fails before wallet dispatch. Legacy requests retain an explicit asset choice when ambiguous, and unambiguous existing paths continue.
- NFT, red-packet, IAP, subscription and Rewards flows were preserved. No subscription or paid business entry was hidden as part of this QR work. The two new unavailable-message keys were added to all 26 Chat source ARBs and generated normally; English null-localization fallbacks and other existing page text remain, so this does not establish full localization acceptance.

## Reviewed commit sequence

| Scope | Reviewed Chat commits |
| --- | --- |
| Optional API and strict URI/asset matching | [`5a6b4e18`](https://github.com/n42blockchain/n42_chat/commit/5a6b4e184be9ed751c1c28610b5325f1aea7e503), [`e60a24a6`](https://github.com/n42blockchain/n42_chat/commit/e60a24a6ae11cf0b356ab79e8b81096e3357e4f5) |
| Repository, request/message and bloc propagation | [`2d92ba44`](https://github.com/n42blockchain/n42_chat/commit/2d92ba441036a675705bbd04f525eec8b6952714), [`5a3b745d`](https://github.com/n42blockchain/n42_chat/commit/5a3b745dc1cceeca8ea57309ec0f7cf53f98fe1e), [`94f82362`](https://github.com/n42blockchain/n42_chat/commit/94f823628b473d85b778d0b3df2a2e29795f9de7), [`ea9dc58f`](https://github.com/n42blockchain/n42_chat/commit/ea9dc58f38abb2a2d02b552549577a41bdbcc313) |
| Scanner and transfer form, with review fixes | [`c18578a7`](https://github.com/n42blockchain/n42_chat/commit/c18578a7321706f5f8887cd1249170b70bd0c051), [`02eb738c`](https://github.com/n42blockchain/n42_chat/commit/02eb738cdd6b668cf34a92643d87d246bedbdca1), [`f70841bc`](https://github.com/n42blockchain/n42_chat/commit/f70841bc3d51cf2b8d23bc73c5c5be1cfecd1a24), [`19ebfe29`](https://github.com/n42blockchain/n42_chat/commit/19ebfe29ac9df300bc3bcec3c51ee21cd810ab6d) |
| Merchant/receive QR, message click and review fixes | [`dee577cb`](https://github.com/n42blockchain/n42_chat/commit/dee577cb9ead5f559f662b64cb712dde83e2e01a), [`f8a901c6`](https://github.com/n42blockchain/n42_chat/commit/f8a901c693a44cbd977a42bc162d02a3fbaede5e), [`eee9ddce`](https://github.com/n42blockchain/n42_chat/commit/eee9ddcea9346282e4832c07088cac8a43749eb2), [`42de7970`](https://github.com/n42blockchain/n42_chat/commit/42de79702f43c341c434cd6c4c9a3aeb8a3f45f4) |

Each bounded source/review fix was independently reviewed before publication. The host change and analyzer fix were likewise independently reviewed and published. Chat's QR-001 ledger text predates the host handoff; this host note records the completed source integration and its remaining acceptance limits.

## Reproducible verification and retained logs

All commands below used `/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/flutter`. The six gzip files in [exact-asset-qr-evidence](exact-asset-qr-evidence/) retain representative raw command output; `gzip -t` passed. Chat commands ran in the official Chat worktree; host commands ran in the app continuation worktree.

| Command and source | Observed result | Raw output |
| --- | --- | --- |
| Chat `flutter test --no-pub` at `42de7970` | 6,895 passed, 3 skipped, exit 0 | [Chat full tests](exact-asset-qr-evidence/chat-full-test.log.gz) |
| Chat `flutter analyze --no-pub --no-fatal-infos` at `42de7970` | Exit 0; 0 errors, 0 warnings, 295 infos | [Chat analysis](exact-asset-qr-evidence/chat-full-analyze.log.gz) |
| Host `flutter pub get` at the new SHA | Resolved `n42_chat` at `1d2e1ab4`; one dependency changed | `pubspec.lock` at `7706df89` |
| Host `flutter test --no-pub test/features/wallet/n42_wallet_bridge_rejection_test.dart test/features/wallet/n42_wallet_bridge_test.dart test/features/wallet/chain_payment_uri_test.dart test/features/wallet/wallet_payment_asset_test.dart test/features/wallet/pages/wallet_receive_qr_test.dart test/features/payments/data/wallet_payment_asset_resolver_test.dart` at `7706df89` | 81 passed, exit 0; mock sender only | [Host targeted tests](exact-asset-qr-evidence/host-targeted-tests.log.gz) |
| Host `flutter analyze --no-pub --no-fatal-infos lib test` at `7706df89` | Exit 0; 36 infos, no errors or warnings | [Host app source and tests analysis](exact-asset-qr-evidence/host-libtest-analyze.log.gz) |
| Host full `flutter analyze --no-pub --no-fatal-infos` before `e3286138` | Exit 1; **35 errors, 4 warnings, 75 infos** | [Before scope fix](exact-asset-qr-evidence/host-full-analyze-before.log.gz) |
| Same full command after `e3286138` | Exit 0; **0 errors, 0 warnings, 69 infos** | [After scope fix](exact-asset-qr-evidence/host-full-analyze-after.log.gz) |

The original full host analyzer errors came from historical evidence packages: 32 in the Vodo source snapshot and three in the datastore fixture overlay. Three warnings were archive path/asset references; one was a redundant `raw!` in the active native smoke test. `e3286138` excludes only the three exact archived source/overlay subtrees from host analysis and removes that redundant assertion. The archived bytes and manifest evidence were not edited, while active app, packages and tools remain analyzed. The before/after counts correct an earlier summary that mentioned only the four warnings.

## Limits and follow-up

The verified tests used fixtures and mock senders. They did not execute a real transfer, scan or share a QR on a device, verify a deployed gateway, or perform an integrated native/release build. Account deletion, UGC moderation/deletion, other native acceptance and store compliance remain separate unfinished work. This checkpoint does not claim deployed or store acceptance.
