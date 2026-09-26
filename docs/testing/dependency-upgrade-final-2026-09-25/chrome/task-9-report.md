# Task 9 — Chrome extension dependency upgrade

Completed on 2026-09-25 from base commit `32ef665ab0e957ab1381bfedd291e3fe67fbffc6` with Node `v20.20.0` and npm `10.8.2`. Commit: `e6dc9ca3f219633b142590ea5a4f7a4e215a4a93` (`chore: upgrade Chrome extension dependencies and crypto tests`). The configured pre-commit hook bumped the root `pubspec.yaml` version from `2.4.8+2026072836` to `2.4.8+2026072837` and included it in the commit.

Follow-up correction commit: `26840b378` (`fix: upgrade extension to TypeScript 6 with signature vectors`). The hook bumped `pubspec.yaml` again to `2.4.8+2026072838`.

## Dependency result

All eight direct production packages were upgraded to their npm `latest` dist-tags: `@noble/hashes` 2.4.0, `@noble/secp256k1` 3.2.0, `@scure/bip32` 2.4.0, `@scure/bip39` 2.4.0, React and ReactDOM 19.3.0, viem 2.56.9, and Zustand 5.0.15.

Development packages resolved to `@types/chrome` 0.3.0, `@types/node` 20.19.43 (matching the pinned Node 20 runtime), `@types/react` and `@types/react-dom` 19.3.0, `@vitejs/plugin-react` 6.1.1, terser 5.51.2, Vite 8.3.1, and `vite-plugin-web-extension` 4.5.1. Added ESLint 10.11.0, `typescript-eslint` 8.70.1, `eslint-plugin-react-hooks` 7.1.1, and Vitest 4.1.11. TypeScript is 6.0.3. The exact installed direct tree is in `docs/testing/dependency-upgrade-final-2026-09-25/chrome/41-final-direct-versions.log.gz`.

Two current dist-tags cannot fit the pinned Node 20 toolchain and peer graph without changing CI or ignoring compatibility declarations:

- Vitest 5.0.2 declares Node `^22.12.0 || ^24.0.0 || >=26.0.0`; Vitest 4.1.11 declares Node `^20.0.0 || ^22.0.0 || >=24.0.0` and supports Vite 8.
- TypeScript 7.0.2 is outside `typescript-eslint` 8.70.1's peer range `>=4.8.4 <6.1.0`; TypeScript 6.0.3 is the newest stable compatible release. An earlier report incorrectly stopped at 5.9.3; this was corrected in the follow-up commit. TypeScript 6 required removing deprecated `baseUrl`, making path aliases relative, and explicitly listing `chrome` and `node` in `types` because TypeScript 6 defaults to an empty global type list. These changes follow the [official TypeScript 6 migration notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html).

No `--force` or `--legacy-peer-deps` was used. Registry dist-tags, engines, and peer ranges were queried on 2026-09-25 before installation.

## Source and test migration

- Updated Noble and Scure package exports to `.js` entry points, set Noble's synchronous SHA-256/HMAC hooks, and disabled its new prehash default when signing an existing Keccak or EIP-712 digest. Converted Noble's recovered `[v, r, s]` bytes to Ethereum's `[r, s, v + 27]` format. Migrated point decoding to Noble's `Point` API.
- Added five deterministic tests with the standard test mnemonic. They check account indexes 0 and 1 against known addresses; compare EIP-191, raw-hash, and EIP-712 signatures to fixed 65-byte references generated independently by viem's `mnemonicToAccount` signer; recover all three signatures independently with viem; and check vault lock, wrong-password rejection, and successful unlock. The reference address, digest, and three signatures are saved in `34-viem-reference-signatures.log.gz`.
- Added Vitest with a WebCrypto and `chrome.storage.local` test setup. Added an ESLint flat config with the recommended TypeScript rules and React Hooks rules. Removed unused legacy bindings and narrow `any`/`Function` casts so these rules can apply without exceptions.
- Adapted Chrome storage value typing to the updated `@types/chrome` package. Changed Vite and Vitest configs to explicit ES modules for Vite 8's native config loader.

## Verification

Final commands, all exit 0:

| Command | Result | Log |
| --- | --- | --- |
| `npm ci` | 412 packages installed from lock | `35-typescript-6-final-npm-ci.log.gz` |
| `npm test` | 5 tests passed | `36-final-test.log.gz` |
| `npm run lint` | Passed | `37-final-lint.log.gz` |
| `npm run type-check` | Passed | `38-final-type-check.log.gz` |
| `npm run build` | Passed; 488 modules transformed | `39-final-build.log.gz` |
| `npm audit --omit=dev --audit-level=moderate` | 0 production vulnerabilities | `40-final-production-audit.log.gz` |

All logs, including intermediate failures and their follow-up runs, are stored as numbered gzip files in `docs/testing/dependency-upgrade-final-2026-09-25/chrome/`. The production audit has no unresolved advisory. npm's whole-tree install summary reports 11 development-side vulnerabilities, outside the required production audit gate; no workaround or forced audit fix was applied.
