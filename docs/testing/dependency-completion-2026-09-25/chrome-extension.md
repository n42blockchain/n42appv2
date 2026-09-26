# Chrome extension dependency completion — 2026-09-26

## Scope and versions

Validated with isolated Node.js 24.21.0 and npm 11.19.0 in `chrome-extension/`. The only direct dependency changes are development tools:

| Package | Previous | Selected | Reason |
| --- | --- | --- | --- |
| `vitest` | 4.1.11 | 5.0.2 | Latest stable; its Node 24 and Vite 8 requirements are met. |
| `@types/node` | 20.19.43 | 24.19.0 | Latest 24.x types for the Node 24 toolchain and compatible with Vitest 5. |

All eight direct production packages were already at their latest stable registry versions: `@noble/hashes` 2.4.0, `@noble/secp256k1` 3.2.0, `@scure/bip32` 2.4.0, `@scure/bip39` 2.4.0, `react` and `react-dom` 19.3.0, `viem` 2.56.9, and `zustand` 5.0.15. The 32 lock entries without `dev: true` remain identical as parsed JSON; 28 are strictly production-only and four are `devOptional` (`@types/react`, `csstype`, `typescript`, `zod`). No production source, build target, or extension manifest permission changed.

`npm outdated --json` exits 1 for two intentional caps: `@types/node` 24.19.0 versus the global latest 26.6.3 (the installed runtime is Node 24), and TypeScript 6.0.3 versus 7.0.2. The latest `typescript-eslint` 8.70.1 requires TypeScript `>=4.8.4 <6.1.0`; TypeScript 7 cannot satisfy that peer range. The other direct development packages resolved at their current stable versions. No peer override or lint relaxation was used. Registry evidence: [Vitest](https://registry.npmjs.org/vitest/latest), [Node types](https://registry.npmjs.org/@types%2Fnode/24.19.0), [TypeScript](https://registry.npmjs.org/typescript/latest), [typescript-eslint](https://registry.npmjs.org/typescript-eslint/latest).

## Verification

Every command below ran from `chrome-extension/` with the Node 24 toolchain. Exact stdout, stderr, and exit codes are in [chrome-extension-logs.tar.gz](chrome-extension-logs.tar.gz).

| Command | Exit | Result |
| --- | ---: | --- |
| `npm install --save-dev 'vitest@^5.0.2' '@types/node@^24.19.0'` | 0 | Lock and manifest updated; a repeat install was up to date. |
| `npm ci` | 0 | Clean install of 215 packages; 0 reported vulnerabilities. |
| `npm test -- src/background/keyring.test.ts` | 0 | Five deterministic HD keyring tests passed. |
| `npm test` | 0 | One file, five tests passed. |
| `npm run lint` | 0 | ESLint passed. |
| `npm run type-check` | 0 | TypeScript `--noEmit` passed. |
| `npm run build` | 0 | TypeScript compile and Vite production build passed. |
| `npm audit --json` | 0 | Zero vulnerabilities at all severities. |
| `npm audit --omit=dev --json` | 0 | Zero production vulnerabilities at all severities. |
| `npm ls --all` | 0 | Dependency tree valid; unused optional test/browser peers appear as optional. |
| `npm outdated --json` | 1 | Only the two deliberate caps above remain. |
| `inspect_dist.py` | 0 | Static distribution inspection passed. |

The existing crypto vectors verify standard mnemonic accounts 0 and 1, exact personal/raw/EIP-712 signatures and recovery, lock clearing, password rejection, and unlock. Their mocked `chrome.storage.local` is reset before each test. Vitest 5 required no source or test API changes for these cases.

The built distribution contains the background service worker, content bridge, in-page script, popup HTML and referenced bundle, and four icons. The copied manifest equals the source manifest; icon bytes match. Static inspection found no Vite browser-external placeholder, Node import/require, or referenced WASM/native asset across five JavaScript bundles. A guarded `process.emit` reference in React's popup bundle is not a Node import. Browser runtime, service-worker lifecycle, message-origin isolation, and actual Chrome storage behavior were not exercised by these Node-based tests or by the build.
