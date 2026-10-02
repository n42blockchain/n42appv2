import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/models/non_evm_fee_model.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_settings_page.dart';
import 'package:n42_wallet/features/wallet/pages/gas/non_evm_gas_settings_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

BigInt _gwei(int value) => BigInt.from(value) * BigInt.from(1000000000);

GasEstimateModel _estimate({bool eip1559 = true, int? baseFee = 20}) {
  GasOption option(int fee, int priority, int seconds) => eip1559
      ? GasOption.eip1559(
          maxPriorityFeePerGas: _gwei(priority),
          maxFeePerGas: _gwei(fee),
          baseFee: _gwei(baseFee ?? 20),
          estimatedSeconds: seconds,
        )
      : GasOption.legacy(gasPrice: _gwei(fee), estimatedSeconds: seconds);
  return GasEstimateModel(
    supportsEIP1559: eip1559,
    slow: option(25, 1, 180),
    standard: option(30, 2, 60),
    fast: option(40, 3, 15),
    baseFee: baseFee == null ? null : _gwei(baseFee),
    gasLimit: BigInt.from(21000),
    chainSymbol: 'ETH',
    decimals: 18,
    unit: 'ETH',
  );
}

NonEvmFeeModel _btc() => NonEvmFeeModel.forBtcLike(
  averageRateSatPerByte: 10,
  calcFeeByRate: (rate) => rate * 250,
);

String _speedLabel(int index) => [
  S.current.g_key_gas_slow,
  S.current.g_key_gas_standard,
  S.current.g_key_gas_fast,
][index];

void main() {
  Future<void> open(
    WidgetTester tester,
    Widget page,
    void Function(Object?) result,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result(
                await Navigator.of(
                  context,
                ).push<Object?>(MaterialPageRoute(builder: (_) => page)),
              );
            },
            child: const Text('Open fee settings'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open fee settings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> enter(WidgetTester tester, int index, String value) async {
    final field = find.byType(TextField).at(index);
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester) async {
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tap(tester, find.text(S.current.g_key_78));
  }

  for (final speed in GasSpeed.values) {
    testWidgets('EVM ${speed.name} selection returns its preset and fee', (
      tester,
    ) async {
      final original = _estimate();
      Object? result;
      await open(
        tester,
        GasSettingsPage(gasEstimate: original),
        (value) => result = value,
      );
      await tap(tester, find.text(_speedLabel(speed.index)).first);
      await confirm(tester);
      final selected = result as GasEstimateModel;
      expect(selected.selectedSpeed, speed);
      expect(
        selected.currentOption.effectiveGasPrice,
        _gwei([25, 30, 40][speed.index]),
      );
      expect(
        selected.currentTotalFee,
        _gwei([25, 30, 40][speed.index]) * BigInt.from(21000),
      );
      expect(find.byType(GasSettingsPage), findsNothing);
    });
  }

  testWidgets(
    'EIP-1559 custom fees return exact Wei values and preserve presets',
    (tester) async {
      final original = _estimate();
      Object? result;
      await open(
        tester,
        GasSettingsPage(gasEstimate: original),
        (value) => result = value,
      );
      await tap(tester, find.byType(Switch));
      expect(find.byType(TextField), findsNWidgets(3));
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        '21000',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        '2',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text,
        '30',
      );
      await enter(tester, 0, '45000');
      await enter(tester, 1, '1.1234567899');
      await enter(tester, 2, '32.987654321');
      await confirm(tester);
      final selected = result as GasEstimateModel;
      expect(selected.gasLimit, BigInt.from(45000));
      expect(
        selected.currentOption.maxPriorityFeePerGas,
        BigInt.from(1123456789),
      );
      expect(
        selected.currentOption.effectiveGasPrice,
        BigInt.from(32987654321),
      );
      expect(
        selected.currentTotalFee,
        BigInt.from(32987654321) * BigInt.from(45000),
      );
      expect(selected.baseFee, original.baseFee);
      expect(selected.slow, same(original.slow));
      expect(selected.fast, same(original.fast));
      expect(selected.chainSymbol, 'ETH');
      expect(selected.decimals, 18);
      expect(selected.unit, 'ETH');
    },
  );

  testWidgets('legacy custom gas price returns decimal Gwei converted to Wei', (
    tester,
  ) async {
    final original = _estimate(eip1559: false, baseFee: null);
    Object? result;
    await open(
      tester,
      GasSettingsPage(gasEstimate: original),
      (value) => result = value,
    );
    await tap(tester, find.text(_speedLabel(2)).first);
    await tap(tester, find.byType(Switch));
    expect(find.byType(TextField), findsNWidgets(2));
    await enter(tester, 0, '50000');
    await enter(tester, 1, '7.500000001');
    await confirm(tester);
    final selected = result as GasEstimateModel;
    expect(selected.supportsEIP1559, isFalse);
    expect(selected.selectedSpeed, GasSpeed.fast);
    expect(selected.gasLimit, BigInt.from(50000));
    expect(selected.currentOption.effectiveGasPrice, BigInt.from(7500000001));
    expect(
      selected.currentTotalFee,
      BigInt.from(7500000001) * BigInt.from(50000),
    );
    expect(selected.slow, same(original.slow));
    expect(selected.standard, same(original.standard));
  });

  testWidgets('disabling custom fees leaves preset selection available', (
    tester,
  ) async {
    Object? result;
    await open(
      tester,
      GasSettingsPage(gasEstimate: _estimate(), allowCustom: false),
      (value) => result = value,
    );
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text(S.current.g_key_gas_custom), findsNothing);
    await tap(tester, find.text(_speedLabel(0)).first);
    await confirm(tester);
    expect((result as GasEstimateModel).selectedSpeed, GasSpeed.slow);
  });

  testWidgets(
    'switching custom mode off discards edited fees on confirmation',
    (tester) async {
      Object? result;
      await open(
        tester,
        GasSettingsPage(gasEstimate: _estimate()),
        (value) => result = value,
      );
      await tap(tester, find.byType(Switch));
      await enter(tester, 2, '999');
      await tap(tester, find.byType(Switch));
      expect(find.byType(TextField), findsNothing);
      await confirm(tester);
      expect(
        (result as GasEstimateModel).currentOption.effectiveGasPrice,
        _gwei(30),
      );
    },
  );

  testWidgets('choosing a preset exits custom mode and restores its fields', (
    tester,
  ) async {
    Object? result;
    await open(
      tester,
      GasSettingsPage(gasEstimate: _estimate()),
      (value) => result = value,
    );
    await tap(tester, find.byType(Switch));
    await enter(tester, 0, '99999');
    await enter(tester, 2, '999');
    await tap(tester, find.text(_speedLabel(0)).first);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(find.byType(TextField), findsNothing);
    await tap(tester, find.byType(Switch));
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      '21000',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      '1',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text,
      '25',
    );
    await confirm(tester);
    expect(
      (result as GasEstimateModel).currentOption.effectiveGasPrice,
      _gwei(25),
    );
  });

  for (final baseFee in <int?>[null, 20, 30, 100]) {
    testWidgets('network status reflects base fee $baseFee', (tester) async {
      await open(
        tester,
        GasSettingsPage(gasEstimate: _estimate(baseFee: baseFee)),
        (_) {},
      );
      final label = baseFee == null || baseFee == 30
          ? S.current.g_key_gas_network_normal
          : baseFee == 20
          ? S.current.g_key_gas_network_idle
          : S.current.g_key_gas_network_busy;
      expect(find.text(label), findsOneWidget);
      if (baseFee != null) {
        expect(
          find.text(S.current.g_ui_base_fee_value('$baseFee')),
          findsOneWidget,
        );
      }
    });
  }

  for (final speed in NonEvmFeeSpeed.values) {
    testWidgets(
      'BTC ${speed.name} tier returns fee rate without mutating input',
      (tester) async {
        final original = _btc();
        Object? result;
        await open(
          tester,
          NonEvmGasSettingsPage(feeModel: original),
          (value) => result = value,
        );
        await tap(tester, find.text(_speedLabel(speed.index)).first);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '${[8, 10, 15][speed.index]}',
        );
        await confirm(tester);
        final selected = result as NonEvmGasResult;
        expect(selected.feeModel.selectedSpeed, speed);
        expect(selected.customFeeRate, isNull);
        expect(selected.effectiveFeeRate, [8, 10, 15][speed.index]);
        expect(
          selected.feeModel.currentFee,
          BigInt.from([8, 10, 15][speed.index] * 250),
        );
        expect(original.selectedSpeed, NonEvmFeeSpeed.standard);
      },
    );
  }

  testWidgets(
    'BTC zero custom rate blocks confirmation and positive edit recovers',
    (tester) async {
      Object? result;
      await open(
        tester,
        NonEvmGasSettingsPage(feeModel: _btc()),
        (value) => result = value,
      );
      await enter(tester, 0, '0');
      expect(find.text(S.current.g_key_t_43), findsWidgets);
      await confirm(tester);
      expect(result, isNull);
      expect(find.byType(NonEvmGasSettingsPage), findsOneWidget);
      await enter(tester, 0, '23');
      // The input hint remains; the visible error label must disappear.
      expect(find.text(S.current.g_key_t_43), findsOneWidget);
      await confirm(tester);
      final selected = result as NonEvmGasResult;
      expect(selected.customFeeRate, 23);
      expect(selected.effectiveFeeRate, 23);
      expect(selected.feeModel.selectedSpeed, NonEvmFeeSpeed.standard);
    },
  );

  testWidgets('BTC preset selection clears an invalid custom rate', (
    tester,
  ) async {
    Object? result;
    await open(
      tester,
      NonEvmGasSettingsPage(feeModel: _btc()),
      (value) => result = value,
    );
    await enter(tester, 0, '0');
    await tap(tester, find.text(_speedLabel(2)).first);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '15',
    );
    await confirm(tester);
    final selected = result as NonEvmGasResult;
    expect(selected.customFeeRate, isNull);
    expect(selected.effectiveFeeRate, 15);
  });

  testWidgets('fixed non-EVM fee omits custom controls and returns fixed fee', (
    tester,
  ) async {
    final original = NonEvmFeeModel.fixed(
      fee: BigInt.from(5000),
      chainSymbol: 'SOL',
      unit: 'SOL',
      decimals: 9,
    );
    Object? result;
    await open(
      tester,
      NonEvmGasSettingsPage(feeModel: original),
      (value) => result = value,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.text(S.current.g_key_gas_custom), findsNothing);
    await confirm(tester);
    final selected = result as NonEvmGasResult;
    expect(selected.feeModel.currentFee, BigInt.from(5000));
    expect(selected.feeModel.chainSymbol, 'SOL');
    expect(selected.customFeeRate, isNull);
  });
}
