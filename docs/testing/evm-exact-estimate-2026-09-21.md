# EVM exact estimate regression — 2026-09-21

## Scope

`EvmSender` now resolves the applicable transaction value once before its
first RPC call. Native `valueWeiOverride`, ERC20 `tokenValueWeiOverride`, and
the legacy decimal conversion all feed the same integer used by gas
estimation, balance validation, and signing.

The existing native near-balance reconciliation remains intact: estimation
uses the requested value, then signing may reduce it to `balance - buffered
fee`. Raw calldata continues to carry a zero native value.

All explicit overrides and every legacy value selected for the transaction
must fit unsigned 256-bit range. A legacy value must also be finite and
non-negative. Invalid values stop before balance, gas, nonce, signing, or
broadcast work. When an applicable exact override exists, the legacy `double`
is display-only and may be non-finite.

## Verification

The focused test uses a local JSON-RPC fixture plus a recording signer. It
asserts the actual `eth_estimateGas` transaction and the signing payload for:

- native exact values above JavaScript's safe integer range;
- ERC20 exact values encoded in transfer calldata;
- the legacy decimal fallback;
- zero-value raw calldata;
- native send-max fee reconciliation; and
- negative, non-finite, and greater-than-uint256 rejection before RPC/signing.

Commands and full output are stored in:

- `flutter test test/features/wallet/api/sender/evm_sender_exact_amount_test.dart test/features/wallet/api/sender/evm_sender_fee_reservation_test.dart test/features/wallet/api/sender/evm_sender_chain_id_test.dart test/features/wallet/evm_msg_data_test.dart` — 22 tests passed; `/tmp/evm-exact-regression.log`.
- `flutter analyze --no-fatal-infos lib/features/wallet/api/sender/evm_sender.dart test/features/wallet/api/sender/evm_sender_exact_amount_test.dart` — no issues; `/tmp/evm-exact-analyze.log`.
