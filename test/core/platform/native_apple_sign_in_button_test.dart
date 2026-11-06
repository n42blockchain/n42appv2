import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/platform/native_apple_sign_in_button.dart';

void main() {
  testWidgets(
    'native Apple taps use current callback and busy state disables control',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final messenger = tester.binding.defaultBinaryMessenger;
      int? viewId;
      final enabled = <bool>[];
      messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
        call,
      ) async {
        if (call.method == 'create') {
          final args = call.arguments as Map;
          expect(args['viewType'], 'n42.wallet/apple_sign_in_button');
          viewId = args['id'] as int;
          messenger.setMockMethodCallHandler(
            MethodChannel('n42.wallet/apple_sign_in_button/$viewId'),
            (call) async {
              if (call.method == 'setEnabled')
                enabled.add(call.arguments as bool);
              return null;
            },
          );
        }
        return null;
      });
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
        messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
        if (viewId != null)
          messenger.setMockMethodCallHandler(
            MethodChannel('n42.wallet/apple_sign_in_button/$viewId'),
            null,
          );
      });
      int taps = 0;
      Widget page(VoidCallback? callback) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 190,
            child: NativeAppleSignInButton(onPressed: callback),
          ),
        ),
      );
      Future<void> tap() async {
        final done = Completer<void>();
        await messenger.handlePlatformMessage(
          'n42.wallet/apple_sign_in_button/$viewId',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('pressed'),
          ),
          (_) => done.complete(),
        );
        await done.future;
      }

      await tester.pumpWidget(page(() => taps++));
      await tester.pump();
      expect(viewId, isNotNull);
      await tap();
      expect(taps, 1);
      await tester.pumpWidget(page(null));
      await tester.pump();
      expect(enabled.last, isFalse);
      await tap();
      expect(taps, 1);
      await tester.pumpWidget(page(() => taps += 10));
      await tester.pump();
      expect(enabled.last, isTrue);
      await tap();
      expect(taps, 11);
      await tester.pumpWidget(const SizedBox());
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
