import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_settings_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

GasEstimateModel _estimate() => GasEstimateModel(
  supportsEIP1559: false,
  slow: GasOption.legacy(
    gasPrice: BigInt.from(8_000_000_000),
    estimatedSeconds: 180,
  ),
  standard: GasOption.legacy(
    gasPrice: BigInt.from(10_000_000_000),
    estimatedSeconds: 60,
  ),
  fast: GasOption.legacy(
    gasPrice: BigInt.from(13_000_000_000),
    estimatedSeconds: 15,
  ),
  gasLimit: BigInt.from(21_000),
  chainSymbol: 'ETH',
  decimals: 18,
  unit: 'ETH',
);

void main() {
  testWidgets('confirm returns custom legacy gas values to the caller', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    GasEstimateModel? returnedEstimate;

    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                returnedEstimate = await Navigator.of(context)
                    .push<GasEstimateModel>(
                      MaterialPageRoute(
                        builder: (_) =>
                            GasSettingsPage(gasEstimate: _estimate()),
                      ),
                    );
              },
              child: const Text('Edit gas'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit gas'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(GasSettingsPage));
    final localizations = S.of(context);
    await tester.tap(find.text(localizations.g_key_gas_fast));
    await tester.tap(find.byType(Switch));
    await tester.pump();

    final inputs = find.byType(TextField);
    await tester.enterText(inputs.at(0), '30k000');
    await tester.enterText(inputs.at(1), '25.5 gwei');
    expect(tester.widget<TextField>(inputs.at(0)).controller!.text, '30000');
    expect(tester.widget<TextField>(inputs.at(1)).controller!.text, '25.5');
    await tester.tap(find.text(localizations.g_key_78));
    await tester.pumpAndSettle();

    expect(returnedEstimate, isNotNull);
    expect(returnedEstimate!.gasLimit, BigInt.from(30_000));
    expect(returnedEstimate!.selectedSpeed, GasSpeed.fast);
    expect(
      returnedEstimate!.currentOption.effectiveGasPrice,
      BigInt.from(25_500_000_000),
    );
  });
}
