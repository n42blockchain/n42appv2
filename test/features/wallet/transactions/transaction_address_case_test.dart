import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';

void main() {
  test(
    'transaction persistence preserves case-sensitive Solana and Tron recipients',
    () {
      for (final address in [
        'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
        'TJRabPrwbZy45sbavfcjinPJC18kjpRTv8',
        '0xAbCdEf0123456789aBcDeF0123456789AbCdEf01',
      ]) {
        final record = TransationRecordModel()
          ..from1 = address
          ..to1 = address;
        final stored = record.toMap();
        expect(stored['from1'], address);
        expect(stored['to1'], address);
        final restored = TransationRecordModel.fromMap(stored);
        expect(restored.from1, address);
        expect(restored.to1, address);
      }
    },
  );
}
