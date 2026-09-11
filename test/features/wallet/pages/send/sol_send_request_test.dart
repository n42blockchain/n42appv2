import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/sol_send_request.dart';

void main() {
  late CoinModel account;
  late TransationRecordModel confirmed;
  setUp(() {
    account = CoinModel()
      ..address = 'sender'
      ..isTest = true
      ..privateKey = 'fixture'
      ..pathIndex = 2
      ..coin = {'coinType': 'SOL', 'decimals': 9, 'path': "m/44'/501'/0'"};
    confirmed = TransationRecordModel()
      ..from1 = 'sender'
      ..to1 = 'confirmed-recipient'
      ..isTest = 1
      ..contract = ''
      ..price = BigInt.parse('9007199254740993');
  });
  test('native UI request preserves lamports beyond double precision', () {
    final p = solSendRequest(account, confirmed);
    expect(p.valueWeiOverride, BigInt.parse('9007199254740993'));
    expect(p.tokenValueWeiOverride, isNull);
    expect(p.toAddress, 'confirmed-recipient');
    expect(p.isTest, isTrue);
    expect(p.privateKey, 'fixture');
    expect(p.sendMax, isFalse);
  });
  test('SPL UI request preserves exact token units and mint', () {
    account.coin['decimals'] = 6;
    confirmed.contract = 'test-mint';
    final p = solSendRequest(account, confirmed);
    expect(p.tokenValueWeiOverride, confirmed.price);
    expect(p.valueWeiOverride, isNull);
    expect(p.contractAddress, 'test-mint');
    expect(p.tokenDecimals, 6);
  });
  test('network changed during confirmation cannot sign', () {
    account.isTest = false;
    expect(() => solSendRequest(account, confirmed), throwsStateError);
  });
  test('account changed during confirmation cannot sign', () {
    account.address = 'other-sender';
    expect(() => solSendRequest(account, confirmed), throwsStateError);
  });
  test('mainnet flag remains explicit without testnet fallback', () {
    account.isTest = false;
    confirmed.isTest = 0;
    expect(solSendRequest(account, confirmed).isTest, isFalse);
  });
  test('parent supplies only path template, not key or account index', () {
    account.coin.remove('path');
    final parent = CoinModel()
      ..pathIndex = 99
      ..privateKey = 'wrong-key'
      ..coin = {'path': "m/44'/501'/0'/0'"};
    final p = solSendRequest(account, confirmed, parent: parent);
    expect(p.privateKey, 'fixture');
    expect(p.fromAddress, 'sender');
    expect(p.path, contains("2'"));
    expect(p.path, isNot(contains("99'")));
  });
  test('missing decimals uses SOL native precision', () {
    account.coin.remove('decimals');
    confirmed.price = BigInt.from(1000000000);
    expect(solSendRequest(account, confirmed).amount, 1);
  });
}
