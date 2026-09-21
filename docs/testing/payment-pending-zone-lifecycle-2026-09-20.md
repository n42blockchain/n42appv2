# Pending journal queue lifecycle fix — 2026-09-20

## Problem

The journal's static serialization tail retained its completed Future. Flutter widget tests run successive lifecycles in separate FakeAsync Zones; chaining work to a completed Future from an old Zone could leave later journal loads unscheduled, producing stuck activation and pumpAndSettle timeouts. This evidence does not establish widespread production payment failures.

## Fix

`LocalPaymentPendingStore._serial` now keeps only the in-flight queue tail. On success or failure, a completion marker releases the tail only if it is still the newest marker. With no in-flight predecessor, the next action starts through `Future.sync` in the current Zone. Concurrent instances remain serialized; older completions cannot clear a newer queue.

## Evidence

```sh
flutter test --no-pub test/features/payments/data/local_payment_pending_store_test.dart
```

**11/11 passed**, comprising all original 9 storage cases and 2 successive widget-Zone lifecycle regressions. Log: `/tmp/n42-pending-store-zone-tests.log`. The dependent transfer/host narrow suite subsequently passed 22/22, demonstrating that repeated page tests no longer stall.

Commit separately from transfer UI integration: the store file, its test file, and this document only. Suggested English subject: `fix: release completed pending journal queue futures`.
