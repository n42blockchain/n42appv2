# P15 — local red packet funding prototype

Date: 2026-09-20. **Unaudited, undeployed, non-production. No claim/refund/withdrawal
path exists; real tokens must never be deposited.**

## Delivered scope

`contracts/red-packets/` contains a standalone Foundry project using Solidity
0.8.30 and no Solidity dependencies. `EqualRedPacketFundingPrototype` locks one
token, records caller-owned packet IDs, exact total/share/count, future expiry and
a nonzero opaque eligibility commitment. It implements only funding. No owner
withdrawal, deployment script, provider integration or application flag was added.

Funding checks strict `transferFrom` success and exact recipient/sender balance
changes. Reverts preserve packet/reservation state and roll back token balances
and allowances. Fees, malformed/absent/false responses and reentrant funding are
rejected; caught nested rejection cannot create another packet. Token donations
do not inflate reserved packet amounts. Existing detectable shortfalls block
additional funding.

## Validation

- `forge test --root contracts/red-packets -vv`: **14 passed**, including **256
  fuzz runs** for integer equal-share conservation.
- Cases include exact stored terms and event receipt, duplicate ID after expiry,
  different-sender ID isolation, zero/indivisible amounts and count, invalid
  expiry/eligibility/token address, insufficient allowance/balance, strict return
  validation, transfer fees, over-credit/no-movement, existing deficit, propagated
  and caught reentry, native funding and absent withdrawal selectors.
- `forge coverage --root contracts/red-packets --report summary` passes the same
  suite. Prototype source coverage: **37/37 lines, 60/60 statements, 13/13 branches,
  5/5 functions**. These metrics do not constitute an audit or prove real-token
  compatibility.
- `forge fmt --root contracts/red-packets --check` and scoped whitespace checks
  pass.
- Logs: `/tmp/n42-payment-contract-funding-tests-20260920.log` and
  `/tmp/n42-payment-contract-funding-coverage-20260920.log`.

## Remaining boundaries

This is the USDC-first design's local funding experiment, not verified live USDC
support. Strict boolean-return handling can reject some USDT implementations.
Arbitrary dishonest balance reporting cannot be detected generically; future
reviewed token/network allowlists and real-token tests remain necessary. Recipient
eligibility interpretation, claims, refunds, chain indexing and audit are separate
future work. Full constraints are in `contracts/red-packets/README.md`.

All runs used local mock tokens. No RPC, accounts, credentials, installations,
deployments or funds were used.
