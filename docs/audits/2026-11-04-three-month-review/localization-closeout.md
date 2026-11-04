# Localization and formatting follow-up — 2026-11-04

This follows the audit closeout. It completes the missing resource catalogs and fixes the recorded Dart formatting failures. It does not change wallet, chat, signing or network behavior.

## Changes

- Wallet: add 1,488 missing localized values; update 84 existing values, including regenerated pseudo translations and corrections to the Ledger hardware-wallet label. All 26 catalogs retain the 1,642 English message keys.
- Chat: add 1,359 missing localized values; update 710 existing values. All 26 catalogs retain the 1,871 English message keys. This includes account deletion, report failures, catch-up/history scope and device-action consent text.
- Translations were authored by parallel language tasks and cross-reviewed for security meaning. Native-speaker and physical-device approval remain separate.
- Preserve brands, SI units, technical identifiers and native homographs. The audit allows only exact reviewed scope/locale/key/value exceptions where required. The existing audit baseline was not refreshed.
- Regenerate Flutter localization classes with their respective generators. Add wallet locale-loading/parameter coverage; expand chat coverage to every 1,690 plain and 181 formatted message accessor, with a duplicate-accessor check.
- Format 199 previously inconsistent Dart files in a separate formatting commit (`43e37a472`). No public feature entry points were removed.
- Pin the application to the independent chat translation commit `7e7106f1` on `fix/l10n-completion-20261104`. Do not use the untracked local chat mirror.

## Verification

- Joint audit of wallet and the actual resolved chat dependency: zero missing, extra, empty or invalid-placeholder entries; audit passes.
- Formatting: 1,618 Dart files checked, zero changes required.
- Audit script regressions: 8 passed.
- Chat localization, accessibility and catch-up UI regressions: 16 passed.
- Wallet static analysis: zero errors, zero warnings, 59 existing informational findings.
- Chat static analysis: zero errors, zero warnings, 305 informational findings.
- Final wallet full regression: 5,803 passed, zero failed, zero skipped, exit code 0. Native Falcon library explicitly enabled.
- Line coverage: 99,844 / 138,092 = 72.30%; the existing 70% threshold passes.
- Machine-readable results and log hashes: [localization-evidence.json](localization-evidence.json).
- Wallet `master` and the chat translation branch were pushed; remote parity was checked.

## Remaining boundaries

Resource parity does not prove that every screen uses localized resources. Chat has an existing direct-UI-literal backlog (QA-006 in its `OPEN_ISSUES.md`); brands, sample values and real untranslated controls must be reviewed separately. Linguistic review by native speakers, RTL/device screen acceptance and a new release upload were not performed in this follow-up.
