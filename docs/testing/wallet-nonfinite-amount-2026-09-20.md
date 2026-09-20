# Reject non-finite bridge amounts

The legacy chat wallet bridge parsed `double` amounts but only rejected values <= 0. `NaN`, `Infinity` and an overflowing exponent (`1e9999`) bypassed this check and proceeded into token resolution. Three newly added cases failed against the old implementation; negative infinity was already rejected.

The bridge now checks `isFinite` before token resolution or sender selection. All 13 bridge rejection tests pass after the change. This is an input-validation fix; migration to precise asset-aware payments remains separate. No wallet signing, broadcasting or real funds were used in this regression.

Logs: `/tmp/n42-wallet-nonfinite-before.log` (3 expected failures), `/tmp/n42-wallet-nonfinite-after.log` (13 passed).
