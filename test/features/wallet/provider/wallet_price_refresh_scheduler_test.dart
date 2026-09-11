import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_price_refresh_scheduler.dart';

void main() {
  test('does not poll every minute; refreshes at five minutes', () {
    fakeAsync((async) {
      var calls = 0;
      final scheduler = WalletPriceRefreshScheduler(
        canRefresh: () => true,
        onRefresh: () async => calls++,
      )..start();
      async.elapse(const Duration(minutes: 4, seconds: 59));
      expect(calls, 0);
      async.elapse(const Duration(seconds: 1));
      expect(calls, 1);
      async.elapse(const Duration(minutes: 5));
      expect(calls, 2);
      scheduler.dispose();
    });
  });

  test(
    'skips hidden or background state without queuing catch-up requests',
    () {
      fakeAsync((async) {
        var visible = false;
        var calls = 0;
        final scheduler = WalletPriceRefreshScheduler(
          canRefresh: () => visible,
          onRefresh: () async => calls++,
        )..start();
        async.elapse(const Duration(minutes: 15));
        expect(calls, 0);
        visible = true;
        async.elapse(const Duration(minutes: 5));
        expect(calls, 1);
        scheduler.dispose();
      });
    },
  );

  test('does not overlap a pending refresh and resumes after it completes', () {
    fakeAsync((async) {
      final pending = Completer<void>();
      var calls = 0;
      final scheduler = WalletPriceRefreshScheduler(
        canRefresh: () => true,
        onRefresh: () {
          calls++;
          return calls == 1 ? pending.future : Future.value();
        },
      )..start();
      async.elapse(const Duration(minutes: 10));
      expect(calls, 1);
      pending.complete();
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 5));
      expect(calls, 2);
      scheduler.dispose();
    });
  });

  test('restart replaces the old timer and disposal stops future requests', () {
    fakeAsync((async) {
      var calls = 0;
      final scheduler = WalletPriceRefreshScheduler(
        canRefresh: () => true,
        onRefresh: () async => calls++,
      )..start();
      async.elapse(const Duration(minutes: 4));
      scheduler.start();
      async.elapse(const Duration(minutes: 4));
      expect(calls, 0);
      async.elapse(const Duration(minutes: 1));
      expect(calls, 1);
      scheduler.dispose();
      async.elapse(const Duration(hours: 1));
      expect(calls, 1);
    });
  });
  for (final failGate in [false, true]) {
    test(
      'reports ${failGate ? 'eligibility' : 'request'} error and retries at next interval',
      () {
        fakeAsync((async) {
          var fails = true;
          var calls = 0;
          final errors = <Object>[];
          final scheduler = WalletPriceRefreshScheduler(
            canRefresh: () {
              if (fails && failGate) throw StateError('gate');
              return true;
            },
            onRefresh: () async {
              calls++;
              if (fails) throw StateError('offline');
            },
            onError: (details) => errors.add(details.exception),
          )..start();
          async.elapse(const Duration(minutes: 5));
          expect(errors, hasLength(1));
          fails = false;
          async.elapse(const Duration(minutes: 4));
          expect(calls, failGate ? 0 : 1);
          async.elapse(const Duration(minutes: 1));
          expect(calls, failGate ? 1 : 2);
          scheduler.dispose();
        });
      },
    );
  }

  test(
    'disposing a pending scheduler prevents restart and late new requests',
    () {
      fakeAsync((async) {
        final pending = Completer<void>();
        var calls = 0;
        final scheduler = WalletPriceRefreshScheduler(
          canRefresh: () => true,
          onRefresh: () {
            calls++;
            return pending.future;
          },
        )..start();
        async.elapse(const Duration(minutes: 5));
        scheduler.dispose();
        scheduler.start();
        pending.complete();
        async.elapse(const Duration(hours: 1));
        expect(calls, 1);
        expect(async.pendingTimers, isEmpty);
      });
    },
  );
}
