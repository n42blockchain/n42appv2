import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_field.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

const _recipient = '0x1234567890abcdef1234567890abcdef12345678';

Widget _app(Widget child) => ScreenUtilInit(
  designSize: const Size(360, 800),
  builder: (context, child) => MaterialApp(
    theme: ThemeAdapter.buildLight(ThemeAdapter.defaultAccent),
    localizationsDelegates: const [S.delegate],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(body: child),
  ),
  child: child,
);

void main() {
  testWidgets('validates an EVM address and trims surrounding whitespace', (
    tester,
  ) async {
    final controller = TextEditingController(text: '  $_recipient  ');
    addTearDown(controller.dispose);
    final validations = <(String?, bool)>[];

    await tester.pumpWidget(
      _app(
        EnsAddressField(
          controller: controller,
          coinType: 'ETH',
          senderAddress: '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          onAddressValidated: (address, isEns) =>
              validations.add((address, isEns)),
        ),
      ),
    );

    expect(validations, [(_recipient, false)]);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects malformed non-ENS text without starting resolution', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final validations = <(String?, bool)>[];

    await tester.pumpWidget(
      _app(
        EnsAddressField(
          controller: controller,
          coinType: 'ETH',
          senderAddress: '',
          onAddressValidated: (address, isEns) =>
              validations.add((address, isEns)),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '0x1234');
    await tester.pump();

    expect(validations, [(null, false)]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty input returns to idle and reports no address', (
    tester,
  ) async {
    final controller = TextEditingController(text: _recipient);
    addTearDown(controller.dispose);
    final validations = <(String?, bool)>[];
    final statuses = <EnsResolveStatus>[];

    await tester.pumpWidget(
      _app(
        EnsAddressField(
          controller: controller,
          coinType: 'ETH',
          senderAddress: '',
          onAddressValidated: (address, isEns) =>
              validations.add((address, isEns)),
          onEnsStatusChanged: (status, _) => statuses.add(status),
        ),
      ),
    );
    controller.clear();
    await tester.pump();

    expect(validations, [(_recipient, false)]);
    expect(statuses, [EnsResolveStatus.idle, EnsResolveStatus.idle]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows external error and caller supplied suffix action', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        EnsAddressField(
          controller: controller,
          coinType: 'ETH',
          senderAddress: '',
          errorText: 'Recipient is required',
          suffixIcons: [const Icon(Icons.qr_code_scanner)],
        ),
      ),
    );

    expect(find.text('Recipient is required'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
