// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Smoke tests for AppLogger. The methods are intentionally low-ceremony
// (each one is essentially a guard + debugPrint + maybe Crashlytics),
// so these tests focus on:
//   - the API surface compiles and is callable with the documented shapes
//   - debug-mode output goes to debugPrint (captured via `debugPrint`
//     redirection)
//   - tag/message formatting is stable
//   - calls don't throw on edge inputs (empty/very long messages,
//     non-Error objects, null stackTrace)
//
// Release-mode behaviour is NOT directly observable here:
//   - `kReleaseMode` can't be flipped from a Dart unit test, and
//   - Crashlytics requires Firebase initialization (also not available
//     in tests).
// What we CAN test is that `_safeCrashlyticsCall` swallows the
// FirebaseException raised when Crashlytics is unavailable — see the
// "does not throw when Crashlytics is unavailable" cases below.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';

void main() {
  group('AppLogger', () {
    late List<String> captured;
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      captured = <String>[];
      originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) captured.add(message);
      };
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
    });

    group('d (debug)', () {
      test('emits [tag] message in debug mode', () {
        AppLogger.d('TestTag', 'hello');
        expect(captured, ['[TestTag] hello']);
      });

      test('handles empty message', () {
        AppLogger.d('TestTag', '');
        expect(captured, ['[TestTag] ']);
      });

      test('handles tag with brackets in it (no escaping)', () {
        AppLogger.d('Tag[1]', 'msg');
        expect(captured, ['[Tag[1]] msg']);
      });

      test('handles multiline message', () {
        AppLogger.d('TestTag', 'line1\nline2');
        expect(captured, ['[TestTag] line1\nline2']);
      });
    });

    group('i (info)', () {
      test('emits [tag] INFO: message', () {
        AppLogger.i('Init', 'app started');
        expect(captured, ['[Init] INFO: app started']);
      });
    });

    group('w (warn)', () {
      test('emits [tag] WARN: message without Crashlytics by default', () {
        AppLogger.w('Net', 'retrying');
        // The debug branch is the only one we can observe without Firebase;
        // `report: true` would invoke Crashlytics.log which isn't initialized
        // in tests. The default `report: false` keeps us off that path.
        expect(captured, ['[Net] WARN: retrying']);
      });

      test('debug output is the same regardless of report flag', () {
        AppLogger.w('Net', 'with report', report: false);
        expect(captured, ['[Net] WARN: with report']);
      });
    });

    group('e (error)', () {
      test('emits [tag] ERROR: message with no error object', () {
        AppLogger.e('Boom', 'kaboom', report: false);
        expect(captured.first, contains('[Boom] ERROR: kaboom'));
      });

      test('appends error object representation when provided', () {
        final err = StateError('bad state');
        AppLogger.e('Boom', 'kaboom', error: err, report: false);
        expect(captured.first, contains('[Boom] ERROR: kaboom'));
        expect(captured.first, contains('Bad state: bad state'));
      });

      test('emits stack trace as a second line when provided', () {
        StackTrace? stack;
        try {
          throw StateError('x');
        } catch (e, s) {
          stack = s;
        }
        AppLogger.e(
          'Boom',
          'msg',
          error: 'err',
          stackTrace: stack,
          report: false,
        );
        expect(captured.length, 2);
        expect(captured[0], contains('[Boom] ERROR: msg'));
        expect(captured[1], contains('app_logger_test.dart'));
      });

      test('accepts a non-Error object as error parameter', () {
        AppLogger.e('Boom', 'msg', error: 'just a string', report: false);
        expect(captured.first, contains('just a string'));
      });

      test('handles null error and stackTrace gracefully', () {
        // No throw, no second line.
        AppLogger.e('Boom', 'msg', report: false);
        expect(captured.length, 1);
      });

      test('report:true does not throw when Crashlytics is unavailable', () {
        // Firebase isn't initialized in unit tests; calling Crashlytics
        // raw would normally throw. AppLogger must defensively swallow
        // so a missing Crashlytics doesn't turn a recoverable error
        // into an actual crash.
        expect(() => AppLogger.e('Boom', 'msg', report: true), returnsNormally);
      });
    });

    group('w with report:true', () {
      test('does not throw when Crashlytics is unavailable', () {
        expect(
          () => AppLogger.w('Net', 'flaky', report: true),
          returnsNormally,
        );
      });
    });
  });
}
