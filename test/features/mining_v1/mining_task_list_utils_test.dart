import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_task_list_utils.dart';

void main() {
  test('parseMiningNumericValue supports hex and decimal strings', () {
    expect(parseMiningNumericValue('0x235'), BigInt.from(565));
    expect(parseMiningNumericValue('565'), BigInt.from(565));
  });

  test('buildPreviousMiningBlockCursor decrements hex cursor safely', () {
    expect(buildPreviousMiningBlockCursor('0x235'), '0x234');
    expect(buildPreviousMiningBlockCursor('1'), '0x0');
    expect(buildPreviousMiningBlockCursor('0x0'), isNull);
  });

  test('formatMiningBlockNumber renders decimal output for display', () {
    expect(formatMiningBlockNumber('0x235'), '565');
    expect(formatMiningBlockNumber(''), isEmpty);
  });
}
