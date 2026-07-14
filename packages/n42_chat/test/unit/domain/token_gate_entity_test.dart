import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/token_gate_entity.dart';

void main() {
  test('maps supported EVM chain IDs to their native wallet symbol', () {
    expect(nativeTokenSymbolForChainId(1), 'ETH');
    expect(nativeTokenSymbolForChainId(10), 'OP');
    expect(nativeTokenSymbolForChainId(56), 'BNB');
    expect(nativeTokenSymbolForChainId(137), 'MATIC');
    expect(nativeTokenSymbolForChainId(42161), 'ARB');
  });
}
