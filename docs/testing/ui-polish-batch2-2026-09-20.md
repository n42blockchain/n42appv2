# UI polish batch 2 — Add Members contact picker

Date: 2026-09-20. Chat baseline: `21748699`, in
`/Users/jieliu/Documents/n42/.tmp-worktrees/n42-chat-registration-20260917`.

Reviewed the completed chat UX/UI plan and Chat `AGENTS.md` / `OPEN_ISSUES.md`.
This pass addresses one remaining dialog surface, without changing the completed
chat/contact/account root layouts.

## Reproduced gaps

The chat Add Members action uses `ContactSelectDialog`. Its old text field offered
no clear control, and filtering to no matches rendered a blank list. An empty
input contact list was also blank. At 320×568, 200% text and a simulated 220-point
keyboard inset, the dialog overflowed vertically by **52 pixels**, in both themes.

Four new widget tests were run before implementation; all four failed against
the baseline. Log: `/tmp/n42-ui-polish-batch2-baseline-20260920.log`.

## Changes

- Reuse the existing shared `N42SearchBar`, including its localized clear action.
- Show existing localized “No Results” / “No contacts” text in a live accessibility
  region. Filtering and clearing retain selected contacts.
- Enable `AlertDialog.scrollable` so title/content can scroll under reduced
  available height while Cancel and Confirm remain in the actions area.

Chat files:

- `lib/src/presentation/widgets/chat/contact_select_dialog.dart`
- `test/presentation/pages/contact_select_dialog_polish_test.dart` (new)

## Validation

- Focused widget test file: **4 passed**. Checks no-results → clear → restored
  selected contacts → correct confirmation result; explicit empty list with
  disabled confirmation; narrow/large-text/keyboard-inset Cancel reachability in
  light and dark themes, with no layout exception.
- Focused analyzer on those two files: **no issues**.
- Logs: `/tmp/n42-ui-polish-batch2-tests-20260920.log` and
  `/tmp/n42-ui-polish-batch2-analyze-20260920.log`.

These are synthetic Flutter widget checks, not screenshots or native device
acceptance. Native keyboard, safe-area and VoiceOver/TalkBack checks remain covered
by the existing QA-005 verification gap; no new ledger issue is introduced. No
account, encryption, payment, dependency or generated-file changes were made.

Integration: Chat `d2e3167c86c06a56ad471d67404eeb0691a0a864` pushed; host pin/mirror synchronized, host wrapper 4 tests passed.
