# Wallet weekly implementation — 2026-10-23

Baseline: host 9015f9d7e; preserve the three existing untracked plans and Chat pin.

## Scope and independent decisions

1. RPC/network identity: central HTTPS URL validation, reject ambiguous authorities and credentials, explicit internationalized-host warning, guard stale discovery callbacks, record genesis fingerprint when adding a custom chain and verify it before wallet-page signing. A first-observed fingerprint detects endpoint changes; it is not an independently trusted chain identity. Never download an unsigned network registry or silently trust a DApp-supplied RPC.
2. Links: audit actual custom-scheme, WalletConnect wrapper and OAuth routes. Add exact-authority and malformed-link regressions. Reuse existing signed Mini App launches; unsupported signed OEM payment/delegation links must remain unsupported, not silently become trusted.
3. Gas: audit native, contract, batch and AA submission paths. Remove fixed-limit fallbacks from executable estimates, reject malformed/zero estimates and propagate failure into confirmation. Keep protocol-specific non-EVM costs separate. Test state-dependent estimates and malformed results, including 500 deterministic matrix cases. This is not 500 live-chain executions or a claim of a 1.00–1.20 real gas ratio.
4. Explainable risks and asset display: inspect existing calldata warnings and asset removal/re-add behavior. Add source/time/enforcement semantics and safe, reversible asset controls where missing. Do not imply hiding revokes approval. Signed external assessments require pinned issuers and transaction binding; no fictitious Sentinel service.
5. Capability evidence: derive a versioned manifest from current source/release inputs; distinguish implemented, enabled/configured and externally verified. Mark 7702, sponsored/batch execution and native Swift/Kotlin acceptance according to evidence rather than keywords. Produce artifact hashes when an artifact is actually built.
6. Validation/delivery: behavior tests for each change, focused wallet/AA/WalletConnect/link suites, full host suite and analyzer; small English commits and remote parity checks. Record failures and final evidence in ACCEPTANCE.md.

## External acceptance (not inferred from local tests)

- Trusted genesis anchors/registry issuer and signed OEM issuer configuration.
- RPC fork activation, 500 actual executions, independent receipts and three-way Swift/Kotlin/Flutter encoding comparisons. This repo cannot activate EIP-2780/8038 on a network.
- Real risk-provider signatures, mobile timing and 50 scam/30 poisoning/20 normal user study; no claims of a 50% risk reduction or <1% false positives from synthetic tests.
- A fresh release build/upload is separate from the already delivered Chat 2.5.3 (73037).

## References

- https://github.com/MetaMask/metamask-extension/releases/tag/v13.53.0
- https://eips.ethereum.org/EIPS/eip-2780
- https://eips.ethereum.org/EIPS/eip-8038
- https://www.safe.global/blog/safenet-launches

The EIP pages were checked on 2026-10-24 and still identify the proposals as Last Call. Their parameters are not enabled as wallet constants.
