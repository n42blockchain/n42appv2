import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/services/coin_price_alert_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads no alerts when storage is absent', () async {
    expect(await CoinPriceAlertService.loadAll(), isEmpty);
  });

  test('saves and updates one alert without dropping other coins', () async {
    const bitcoin = CoinPriceAlertConfig(
      coinId: 'bitcoin',
      symbol: 'btc',
      name: 'Bitcoin',
      targetPrice: 70000,
      alertAbove: true,
      enabled: true,
    );
    const ether = CoinPriceAlertConfig(
      coinId: 'ethereum',
      symbol: 'eth',
      name: 'Ethereum',
      targetPrice: 4000,
      alertAbove: false,
      enabled: false,
      lastNotifiedMs: 123456,
    );

    await CoinPriceAlertService.save(bitcoin);
    await CoinPriceAlertService.save(ether);
    await CoinPriceAlertService.save(bitcoin.copyWith(targetPrice: 72000));

    final alerts = await CoinPriceAlertService.loadAll();
    expect(alerts.keys, containsAll(['bitcoin', 'ethereum']));
    expect(alerts['bitcoin']!.targetPrice, 72000);
    expect(alerts['bitcoin']!.alertAbove, isTrue);
    expect(alerts['ethereum']!.targetPrice, 4000);
    expect(alerts['ethereum']!.enabled, isFalse);
    expect(alerts['ethereum']!.lastNotifiedMs, 123456);
  });

  test(
    'removes only the requested alert and tolerates repeated removal',
    () async {
      await CoinPriceAlertService.save(
        const CoinPriceAlertConfig(
          coinId: 'bitcoin',
          symbol: 'btc',
          name: 'Bitcoin',
          targetPrice: 70000,
          alertAbove: true,
          enabled: true,
        ),
      );
      await CoinPriceAlertService.save(
        const CoinPriceAlertConfig(
          coinId: 'ethereum',
          symbol: 'eth',
          name: 'Ethereum',
          targetPrice: 4000,
          alertAbove: false,
          enabled: true,
        ),
      );

      await CoinPriceAlertService.remove('bitcoin');
      await CoinPriceAlertService.remove('bitcoin');

      final alerts = await CoinPriceAlertService.loadAll();
      expect(alerts.keys, ['ethereum']);
      expect(alerts['ethereum']!.targetPrice, 4000);
    },
  );

  test('fails closed when stored alert JSON is malformed', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('coinPriceAlerts', '{invalid');

    expect(await CoinPriceAlertService.loadAll(), isEmpty);
  });
}
