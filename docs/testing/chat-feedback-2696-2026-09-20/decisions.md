# Primary-agent decisions

## 2026-09-20 — review and integration plan

The main implementation passed 473 Chat checks and 1,019 host Chat checks. Native compilation passed. Review is limited to newly changed behavior; broad tests are not repeated without a relevant change or unresolved failure.

| Step | Owner | Decision and scope |
| --- | --- | --- |
| Account/group review | review_accounts_groups | Rework requested: delayed relationship fallback must not overwrite newer contact Bloc state. Agent owns the contact page and its focused test; primary will inspect the result before integration. |
| Media/native review | review_media_native | Rework requested: optional PhotoManager thumbnail errors must not abort video sending before fallback. Agent owns the media action, one import, helper and focused tests. |
| Live SDK invocation | validation_documentation | Retry from the Chat worktree. Previous failure was a harness working-directory error, with all temporary accounts cleaned; no product verdict inferred. |
| Evidence and process | validation_documentation | Workflow accepted in principle. Keep test scope, failures and device gaps explicit. Future assignments receive only necessary context and file references. |
| Integration | primary agent | Pending the two focused fixes and rerun. Update dependency/mirror together; run affected host wrappers and consistency checks, then commit using an English subject. |

Private recordings remain outside Git. Free AI HTTP 429, native feedback-phone encryption persistence, HarmonyOS ringing and demo-only red packets are not closed by compilation or unit tests.

## Follow-up decisions

- **Accepted — contact race:** reviewed completion-time Bloc preference and deletion guard; two completer tests plus existing contact suite passed (14 tests).
- **Accepted — optional video thumbnail:** reviewed a bounded helper and call site; platform exceptions/empty previews now permit existing file fallback. Four focused tests and necessary-file analysis passed.
- **Accepted — live SDK evidence:** corrected working directory rerun passed, both QA accounts deactivated. Preserve earlier harness error as an execution failure, not a product failure.
- Both fixes are committed in Chat `ef5fbb38c42da0a09db8f4e5ba3a3b3004d52069`. No other review finding requires a code change. Final host dependency checks follow; native/device and free-provider limits remain open.

- **Accepted — final integration:** 42 affected host checks passed; all 792 dependency library/asset files match the mirror. Proceed with the authorized main-repository commit and push. Distribution upload is outside this validation pass.
