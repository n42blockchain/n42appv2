# Equal red packet funding prototype

**LOCAL TESTS ONLY — UNAUDITED, UNDEPLOYED, NOT FOR PRODUCTION.**

**There is no claim, refund, withdrawal, owner rescue or upgrade path. Tokens
deposited into this prototype cannot be recovered. Never deploy or fund it with
real assets.** No deployment scripts or application integrations are included.

## Scope

`EqualRedPacketFundingPrototype` demonstrates only exact funding for an equal-share
packet. It follows the project's USDC-first, single-chain design direction, but
all verification uses a synthetic local token; it does not establish compatibility
with any live USDC contract or network. It is not a generic ERC20 integration.
In particular, strict boolean return validation rejects no-return tokens and can
be incompatible with some USDT implementations.

- One immutable token contract per prototype; no native currency funding.
- The sender is always `msg.sender`. Packet IDs are unique **per sender**; another
  account cannot occupy the sender's packet ID. Receipts must include chain,
  prototype address, sender and packet ID when identifying a packet.
- Positive integer base-unit amount and recipient count; amount must divide
  exactly into the count. No decimal arithmetic, random allocation or dust.
- Expiry must be in the future at funding. It is stored metadata, not an automatic
  refund. An expired packet ID cannot be reused.
- Nonzero opaque `eligibilityCommitment` is stored without interpreting it. No
  recipient eligibility, proof format, membership validation or claiming logic
  is implemented or promised by this field.
- Funding requires approval and a strict 32-byte `true` from `transferFrom`.
  Both escrow increase and sender decrease must equal the requested amount.
  False/absent/malformed returns, transfer failures, recipient/sender fees,
  over-crediting and no movement revert the complete transaction.
- A reentrancy lock surrounds token calls. Nested funding is rejected even when
  the token catches that rejection; a valid outer transfer may still complete.
  Propagated callback failure reverts outer funding as well.
- Packet terms, `totalReserved` and the receipt event are recorded only after
  exact funding. Failure rolls back token balance/allowance changes. Direct token
  donations are not reserved for packets; a detected existing funding deficit
  blocks subsequent funding.

## Trust boundary and deferred work

Balance checks rely on the token's `balanceOf` reporting honestly. An arbitrary
malicious token can fabricate balances; these checks cannot prove its backing or
prevent future rebasing, administrative seizure, upgrades or freezing. The
constructor's code check is not token approval. A future implementation needs a
reviewed network/token allowlist, real-token compatibility tests and an audit.

Recipient authorization, replay-safe claims, refunds, expiry execution,
reconciliation, frontend/backend wiring and deployment are deliberately absent.
Neither passing these tests nor emitting a funding receipt makes a packet
claimable. All later fund-release paths require a separate design and review.

## Local verification

Uses the same Solidity 0.8.30 Foundry setup as `contracts/loyalty`, with no external
Solidity dependencies, RPC endpoint, credentials or forked chain state.

```sh
forge test --root contracts/red-packets -vv
forge coverage --root contracts/red-packets --report summary
forge fmt --root contracts/red-packets --check
```

Tests exercise normal and malicious mock tokens, exact receipts, scoped IDs,
expiry/amount/count validation, rollback, reentrancy, native rejection and 256
fuzz cases of equal-share funding conservation. `out/` and `cache/` are local
ignored build artifacts.
