# Chrome extension dependency upgrade

Verified with Node 20.20.0 and npm 10.8.2 on 2026-09-25.

The extension uses the current stable production package releases, React 19.3.0, Noble secp256k1 3.2.0, Noble hashes 2.4.0, Scure bip32/bip39 2.4.0, viem 2.56.9, and Zustand 5.0.15. Development tools include Vite 8.3.1, TypeScript 6.0.3, Vitest 4.1.11, ESLint 10.11.0, and `typescript-eslint` 8.70.1. See `41-final-direct-versions.log.gz` for the full direct package tree.

TypeScript 7.0.2 exceeds `typescript-eslint` 8.70.1's declared TypeScript peer range (`>=4.8.4 <6.1.0`). Vitest 5.0.2 requires Node 22.12 or newer; Node 20.20.0 is the CI pin. TypeScript 6.0.3 and Vitest 4.1.11 are the newest stable compatible releases. TypeScript 6 required relative `paths` values, removal of deprecated `baseUrl`, and explicit `types` entries for Chrome and Node. The migration follows the [official TypeScript 6 release notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html).

The five keyring tests check two known HD addresses and fixed 65-byte personal, raw-hash, and EIP-712 signatures. The signature references were generated independently with viem's `mnemonicToAccount` signer for the public `test test test test test test test test test test test junk` mnemonic; reference output is saved in `34-viem-reference-signatures.log.gz`. Each signature is also recovered with viem to the expected account address.

Final verification (all exit 0):

| Command | Result | Log |
| --- | --- | --- |
| `npm ci` | Clean lockfile install | `35-typescript-6-final-npm-ci.log.gz` |
| `npm test` | 5 passed | `36-final-test.log.gz` |
| `npm run lint` | Passed | `37-final-lint.log.gz` |
| `npm run type-check` | Passed | `38-final-type-check.log.gz` |
| `npm run build` | Passed | `39-final-build.log.gz` |
| `npm audit --omit=dev --audit-level=moderate` | 0 production vulnerabilities | `40-final-production-audit.log.gz` |

Earlier numbered logs preserve the initial TypeScript 6 config errors and preceding upgrade attempts. npm's full install summary reports 11 development-side vulnerabilities; the production audit has none.

Full migration details: [Task 9 report](task-9-report.md).

Task 10 final acceptance subsequently applied compatible transitive security updates and reduced the development audit to 9 vulnerable package nodes; production remains zero. See [final audit and upstream constraints](../acceptance/chrome-development-audit.md) and the numbered acceptance logs.

Final independent review then identified `vite-plugin-web-extension` as unused. Task 10 removed it through npm, removing its entire vulnerable runner graph. Acceptance checks `325`–`331` all pass, with both full and production audits at **zero**. Earlier 11/9-node results remain historical evidence.
