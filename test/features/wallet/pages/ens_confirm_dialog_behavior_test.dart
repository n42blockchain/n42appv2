import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_confirm_dialog.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

const _ensName = 'alice.eth';
const _address = '0x1111111111111111111111111111111111111111';

class _DialogHarness extends StatefulWidget {
  const _DialogHarness();

  @override
  State<_DialogHarness> createState() => _DialogHarnessState();
}

class _DialogHarnessState extends State<_DialogHarness> {
  bool? result;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () async {
          result = await EnsConfirmDialog.show(
            context: context,
            ensName: _ensName,
            resolvedAddress: _address,
            tokenSymbol: 'ETH',
          );
          setState(() {});
        },
        child: const Text('Open ENS confirmation'),
      ),
    ),
  );
}

void main() {
  final clipboardCalls = <MethodCall>[];

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(const _DialogHarness()));
    await tester.tap(find.text('Open ENS confirmation'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  setUp(() {
    clipboardCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') clipboardCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('shows the ENS mapping and returns true only on confirmation', (
    tester,
  ) async {
    await open(tester);
    final context = tester.element(find.byType(EnsConfirmDialog));
    final l10n = S.of(context);

    expect(find.text(l10n.g_key_ens_detected), findsOneWidget);
    expect(find.text(_ensName), findsOneWidget);
    expect(find.text(_address), findsOneWidget);
    expect(find.text(l10n.g_key_ens_warning), findsOneWidget);
    expect(
      tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).dismissible,
      isFalse,
    );

    await tester.tap(find.text(l10n.g_key_ens_confirm_send));
    await tester.pumpAndSettle();
    expect(
      tester.state<_DialogHarnessState>(find.byType(_DialogHarness)).result,
      true,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('copy actions copy the exact ENS name and resolved address', (
    tester,
  ) async {
    await open(tester);
    final copies = find.byIcon(Icons.copy_rounded);

    await tester.tap(copies.first);
    await tester.pump();
    await tester.ensureVisible(copies.last);
    await tester.pumpAndSettle();
    await tester.tap(copies.last);
    await tester.pump();

    expect(clipboardCalls.map((call) => (call.arguments as Map)['text']), [
      _ensName,
      _address,
    ]);
    expect(
      find.text(S.of(tester.element(find.byType(EnsConfirmDialog))).g_key_119),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel returns false and resolving dialog can be dismissed', (
    tester,
  ) async {
    await open(tester);
    final l10n = S.of(tester.element(find.byType(EnsConfirmDialog)));
    await tester.tap(find.text(l10n.g_key_79));
    await tester.pumpAndSettle();
    expect(
      tester.state<_DialogHarnessState>(find.byType(_DialogHarness)).result,
      false,
    );

    final context = tester.element(find.byType(_DialogHarness));
    EnsResolvingDialog.show(context, _ensName);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(_ensName), findsOneWidget);
    EnsResolvingDialog.dismiss(context);
    await tester.pumpAndSettle();
    expect(find.byType(EnsResolvingDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
