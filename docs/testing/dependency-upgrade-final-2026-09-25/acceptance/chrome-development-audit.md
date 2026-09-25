# Chrome development dependency audit — investigation and resolution

**Resolved after final independent review:** `vite-plugin-web-extension` had no import or invocation. `vite.config.mts` already uses `react()` and the app-owned `copyExtensionAssets()` plugin. Removing this unused direct dev dependency with `npm uninstall --save-dev vite-plugin-web-extension` removed 186 packages and all remaining advisory nodes. Fresh Node 20 `npm ci`, 5 tests, lint, type check, build, production audit and full audit all pass; both audits report **zero vulnerabilities** (`323`–`331`). No npm overrides were required. The build still transforms 488 modules and produces the same entry assets.

The investigation below is retained as historical evidence, superseded by the removal and clean audits above. The initial final-check audit reported 11 vulnerable package nodes (2 moderate, 6 high, 3 critical). Ordinary `npm audit fix` updated `fast-uri` 3.1.0 → 3.1.8, `brace-expansion` 1.1.14 → 1.1.21 and `adm-zip` 0.5.17 → 0.5.18 without changing direct constraints. The first two vulnerable nodes were removed; adm-zip remains affected. The generated lockfile was retained and all extension checks were rerun with Node 20.20.0.

**Intermediate full audit: FAILED, 9 vulnerable development package nodes (2 moderate, 4 high, 3 critical). Intermediate production audit: PASS, zero.** These are package-node counts; inherited advisory effects are counted alongside the vulnerable leaves.

## Previously remaining nodes

| Package | Installed | Severity | Dependency/advisory | npm fixAvailable |
| --- | --- | --- | --- | --- |
| adm-zip | 0.5.18 | high | [adm-zip: Crafted ZIP file triggers 4GB memory allocation](https://github.com/advisories/GHSA-xcpc-8h2w-3j85); [adm-zip extraction follows destination symlinks, allowing arbitrary file overwrite](https://github.com/advisories/GHSA-vwc7-r8mq-g2x9); [adm-zip: Uncontrolled memory allocation via the declared uncompressed size (DoS)](https://github.com/advisories/GHSA-7q85-xj36-vmfc) | `true` |
| firefox-profile | 4.7.0 | high | adm-zip | `true` |
| fx-runner | 1.4.0 | critical | shell-quote | `true` |
| node-notifier | 10.0.1 | moderate | uuid | `true` |
| shell-quote | 1.7.3 | critical | [shell-quote quote() does not escape newlines in object .op values](https://github.com/advisories/GHSA-w7jw-789q-3m8p); [shell-quote: Quadratic-complexity Denial of Service in `parse()` (CWE-407)](https://github.com/advisories/GHSA-395f-4hp3-45gv) | `true` |
| tmp | 0.2.5 | high | [tmp has Path Traversal via unsanitized prefix/postfix that enables directory escape](https://github.com/advisories/GHSA-ph9p-34f9-6g65) | `{"name": "vite-plugin-web-extension", "version": "3.2.0", "isSemVerMajor": true}` |
| uuid | 8.3.2 | moderate | [uuid: Missing buffer bounds check in v3/v5/v6 when buf is provided](https://github.com/advisories/GHSA-w5hq-g745-h8pq) | `true` |
| vite-plugin-web-extension | 4.5.1 | high | web-ext-run | `{"name": "vite-plugin-web-extension", "version": "3.2.0", "isSemVerMajor": true}` |
| web-ext-run | 0.2.4 | critical | firefox-profile; fx-runner; node-notifier; tmp | `{"name": "vite-plugin-web-extension", "version": "3.2.0", "isSemVerMajor": true}` |

## Why ordinary audit fix did not resolve the previously installed graph

- `vite-plugin-web-extension` 4.5.1 is the registry latest and requires `web-ext-run ^0.2.1`; latest `web-ext-run` 0.2.4 pins `firefox-profile 4.7.0`, `fx-runner 1.4.0`, `tmp 0.2.5`, and `node-notifier 10.0.1` exactly.
- `firefox-profile 4.7.0` requires `adm-zip ~0.5.x`, whose compatible 0.5.18 is still vulnerable. Published `firefox-profile 4.7.1` moves to `~0.6.x`, but the exact 4.7.0 parent pin prevents that patch update.
- `fx-runner 1.4.0` requires `shell-quote 1.7.3` exactly. Published `fx-runner 1.6.0` uses `shell-quote 1.10.0`, but the exact parent pin prevents that update.
- `tmp 0.2.5` is pinned by web-ext-run, while the advisory requires at least 0.2.6.
- Latest `node-notifier 10.0.1` still requires `uuid ^8.3.2`; the advisory-safe range starts at 11.1.1, outside that major version.
- npm suggests replacing the direct extension plugin with **3.2.0** through `--force`. That is a breaking downgrade of the upgraded Vite integration, not a compatible transitive update. No force, parent-constraint override, package-source edit or unverified downgrade was applied. These findings require an upstream parent release or a separately validated runner/plugin migration; they are not claimed to be Node 22-only problems.

## Evidence

All paths refer to [acceptance evidence](.). `307` preserves the original audit; `308` the dry run; `309` installed dependency chains; `310` the normal fix (exit 1 because vulnerabilities remain); `311`–`317` fresh install and complete post-fix verification; `318`–`322` official npm registry latest versions, dependencies and engine requirements.

## Historical npm override assessment (superseded by removing the unused parent)

Overrides were considered, not installed. An exact upstream pin alone does not prove an override is incompatible. The available package updates may be viable, but the repository's five tests cover wallet cryptography and the production Vite build does not exercise Firefox launch, profile ZIP handling, temporary-directory cleanup or desktop notification delivery.

| Candidate override | Actual consumer API inspected | Compatibility work still needed |
| --- | --- | --- |
| `firefox-profile 4.7.1` | `web-ext-run/lib/firefox/index.js` constructs/manages profiles; profile encoding uses `AdmZip.addLocalFolder/toBuffer`, XPI install uses `extractAllTo` | Validate the profile lifecycle and ZIP extraction with the upgraded adm-zip 0.6 family; ordinary extension build is insufficient |
| `fx-runner 1.6.0` | `web-ext-run` imports its default runner; installed runner parses launch arguments through shell-quote and spawns the browser | Validate quoted arguments, binary discovery, returned process shape and child-process cleanup on supported OSes; this is a plausible compatible minor upgrade, not a demonstrated breaking API |
| `tmp 0.2.6` | `web-ext-run/lib/util/temp-dir.js` promisifies `tmp.dir`, consumes its `[path, cleanupCallback]` pair, supplies `prefix` and `unsafeCleanup`, and calls async cleanup | Validate callback shape and success/failure cleanup under the fixed path-validation behavior; patch override appears narrow but has not been exercised |
| `uuid 11.1.1` | Windows `node-notifier/notifiers/toaster.js` uses CommonJS `require('uuid').v4()` without arguments to create a pipe name | Confirm the newer major's CommonJS export on Node 20 and Windows toast/pipe behavior. The vulnerable buffer-based v3/v5/v6 APIs are not called by this inspected consumer, but the package-level advisory remains real |

No inability to install these versions is asserted. The reason for leaving the nine findings visible is missing runner/platform compatibility evidence for a changed upstream graph, not a claim that all overrides require Node 22 or are intrinsically unsafe. A scoped follow-up can evaluate these overrides with runner-focused checks. No `--force`, blanket override or advisory suppression was used.
