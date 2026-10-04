import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_confirm_dialog.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

const _ensName = 'alice.eth';
const _resolvedAddress = '0x1234567890abcdef1234567890abcdef12345678';
const _preview = '0x12345678...12345678';

void main() {
  late List<String> copiedValues;

  setUp(() {
    copiedValues = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedValues.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('confirmation and cancellation return their explicit results', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await EnsConfirmDialog.show(
                  context: context,
                  ensName: _ensName,
                  resolvedAddress: _resolvedAddress,
                );
              },
              child: const Text('Open ENS confirmation'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open ENS confirmation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_key_ens_confirm_send));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('Open ENS confirmation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_key_79));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('shows ENS target and warning, and copies the full address', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => EnsConfirmDialog.show(
                context: context,
                ensName: _ensName,
                resolvedAddress: _resolvedAddress,
                tokenSymbol: 'ETH',
              ),
              child: const Text('Open ENS confirmation'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open ENS confirmation'));
    await tester.pumpAndSettle();

    expect(find.text(_ensName), findsOneWidget);
    expect(find.text(_preview), findsOneWidget);
    expect(find.text(_resolvedAddress), findsOneWidget);
    expect(find.text(S.current.g_key_ens_warning), findsOneWidget);
    expect(find.text(S.current.g_key_ens_confirm_title), findsOneWidget);

    final ensCopyIcon = find.byIcon(Icons.copy_rounded).first;
    await tester.ensureVisible(ensCopyIcon);
    await tester.tap(ensCopyIcon);
    await tester.pump();
    expect(copiedValues, [_ensName]);

    final copyIcon = find.byIcon(Icons.copy_rounded).last;
    await tester.ensureVisible(copyIcon);
    await tester.tap(copyIcon);
    await tester.pump();
    expect(copiedValues, [_ensName, _resolvedAddress]);
    expect(find.text(S.current.g_key_119), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resolving dialog presents progress and is explicitly closed', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    late BuildContext rootContext;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) {
            rootContext = context;
            return Scaffold(
              body: TextButton(
                onPressed: () => EnsResolvingDialog.show(context, _ensName),
                child: const Text('Resolve ENS'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Resolve ENS'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(S.current.g_key_ens_resolving), findsOneWidget);
    expect(find.text(_ensName), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(EnsResolvingDialog), findsOneWidget);

    EnsResolvingDialog.dismiss(rootContext);
    await tester.pumpAndSettle();
    expect(find.byType(EnsResolvingDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
