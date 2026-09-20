# TestFlight 2696 feedback — September 20, 2026

This pass follows the completed chat/contact/account UI plan. The user's screenshots and recordings under Downloads/1 were reviewed locally; private recordings and account data are not copied into this repository.

## Changes and acceptance boundaries

| Feedback | Implementation | Remaining acceptance |
| --- | --- | --- |
| Account switching / received encrypted messages | Remove explicitly logged-out accounts from saved sessions; reauthenticate expired or missing encryption identities with account/server prefilled; keep transient failures retryable. | Feedback-phone secure storage and switching. The live SDK test passes with real AuthRepositoryImpl, independent account sessions, incoming history after logout/password login, restart and new messages. This does not prove the reported phone scenario is resolved. |
| Sending while recipient is logged out | Keep encryption readiness checks; retained-account switching preserves the receiving device session. | A revoked device without usable keys cannot receive new encrypted messages until it signs in. No plaintext fallback is introduced. |
| Group admission | Existing unblocked friends' invitations autojoin through the room admission service. Stranger/blocked/failed invites stay pending. Internal social rooms retain their existing filters. | Native arrival/badge and admission checks. |
| Existing friend contact card | Resolve authoritative relationship when the contacts Bloc has not hydrated; prevent a pending lookup from undoing deletion. | Feedback-phone profile/card acceptance. |
| Group add/remove/manage | Exclude current/invited members, deduplicate backend invitations, open actual member management and provide the required GroupBloc. | Feedback group permissions and native navigation. |
| Announcement / own nickname | Load announcement and own nickname; persist nickname in the user's room member state, preserving avatar/membership. | Save/reopen and remote member display on phones. |
| 9 Calendar | Open native iOS EventKit / Android calendar editor with title, dates, location and notes. | Save/cancel/permissions with installed calendar app. Android return means editor opened, not event saved. |
| 10 Red packet | Demo records no longer require a nonexistent real CNY balance. Real service balance errors stop sending. | This remains an explicitly labelled local demo, not an on-chain red-packet implementation. |
| 11 Tip | Offer validated manual recipient address when the contact has no linked wallet. Existing wallet confirmation remains. | Verified automatic peer-wallet discovery is absent; real asset transfer not executed during QA. |
| 12 / 24 Transfer | Scanner returns raw payload to transfer form; accept raw addresses and both host n42://pay and n42pay://pay; select supported requested token. Errors belong to scanner/form. Bounded token list; fix balance localization function call. | Current form cannot safely honor requested networks/EIP-681 contract calls and rejects them; chain-aware routing remains open. |
| 13 Stickers | Upload bundled SVG/Lottie and send mxc with correct MIME. Render old allowlisted asset messages. | Native remote media rendering. |
| 14 GIF | Provider timeouts and bounded picker request with retry; no infinite loading. | Provider availability on the reported network. |
| 15 / 16 Image / OCR | Contrasting dark toolbar, white icons, remove duplicate save/share menu entries, dark OCR panel and zoomable image comparison. | Native visual and OCR accuracy acceptance. |
| 17–19 AI | Resize/compress image before upload; proxy/nginx accept bounded inline images; batch consented OCR text translation into one request; user-readable errors. | Live synthetic vision reached upstream but received HTTP 429. Free service availability remains a limitation; no paid fallback or quota reset. |
| 20 Video | Use gallery thumbnail bytes when available, with native thumbnail extraction fallback. | Native codecs/camera thumbnail acceptance. |
| 21 Code | Reproduced HighlightView exception for null language; plain/unknown language renders directly, known language remains highlighted. | Narrow-width rendering tests pass. |
| 22 Face blur | Rename setting to explicitly describe sent photos. | It processes outgoing photos; it does not blur video calls. |
| 23 Android call ringing | Hide the current incoming CallKit sound/notification before marking connected; no hangup. | Method-channel ordering passes; the reported HarmonyOS phone is not attached. |

## Validation

- iOS device Debug build without signing: passed. This verifies native calendar integration, not a distribution upload.
- Android `:app:compileDebugKotlin` with JDK 17: passed. Default JDK 25 is incompatible with this build toolchain.
- AI gateway: seven backend tests passed. Deployment backed up code/nginx and preserved credentials and usage database; nginx configuration validated and services active.
- Synthetic live vision: invalid token rejected (401); valid request returned upstream 429; temporary Matrix account deactivated.
- Live encryption repository regression: passed, both temporary Matrix accounts deactivated.
- Chat regression: **473 passed**; host Chat regression: **1,019 passed**. Analyzers: zero errors/warnings (280 Chat / 264 host informational diagnostics).
- Follow-up delegated review fixes cover stale contact state and optional gallery thumbnail failure; focused evidence and acceptance decisions are recorded below.

The Chat repository's `OPEN_ISSUES.md` remains the unresolved-issue ledger. No original keys can be recreated by this UI work. No release upload or phone overwrite is part of this validation.

## Delegated execution and final review

- [Workflow](WORKFLOW.md)
- [Validation evidence](validation.md)
- [Account/group review](account-group-review.md)
- [Media/native review](media-native-review.md)
- [Primary-agent decisions](decisions.md)

Final Chat pin: `ef5fbb38c42da0a09db8f4e5ba3a3b3004d52069`.
