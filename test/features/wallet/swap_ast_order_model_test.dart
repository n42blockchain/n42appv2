// Tests for SwapAstOrderModel (AST swap order entry).
// Pure Dart data class — no platform dependencies.
// Note: only fromJson (snake_case keys) — no toJson method.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_order_model.dart';

const _kFullJson = <String, dynamic>{
  'id': 42,
  'nft_amt_id': 7,
  'b_uuid': 'buyer-uuid-abc',
  'b_addr': '0xBuyerAddress',
  'order_num': 10.5,
  'order_price': 0.025,
  'pay_num': 0.2625,
  'pay_tx': '0xpayTxHash',
  'pay_state': 1,
  'order_state': 2,
  'order_tx': '0xorderTxHash',
  'expire': 1700999999,
  'type': 0,
  'created': 1700000000,
  'updated': 1700500000,
  'name': 'Test AST',
  'desc': 'Description here',
  'uri': 'https://icon.url/ast.png',
  'pay_chain': 'ETH',
  'pay_coin': 'USDT',
};

void main() {
  // ─────────────────────────────────────────────────
  // Default constructor
  // ─────────────────────────────────────────────────

  group('SwapAstOrderModel default constructor', () {
    test('all fields default to null', () {
      final model = SwapAstOrderModel();
      expect(model.id, isNull);
      expect(model.nftAmtId, isNull);
      expect(model.bUuid, isNull);
      expect(model.bAddr, isNull);
      expect(model.orderNum, isNull);
      expect(model.orderPrice, isNull);
      expect(model.payNum, isNull);
      expect(model.payTx, isNull);
      expect(model.payState, isNull);
      expect(model.orderState, isNull);
      expect(model.orderTx, isNull);
      expect(model.expire, isNull);
      expect(model.type, isNull);
      expect(model.created, isNull);
      expect(model.updated, isNull);
      expect(model.name, isNull);
      expect(model.desc, isNull);
      expect(model.uri, isNull);
      expect(model.payChain, isNull);
      expect(model.payCoin, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson — snake_case key mapping
  // ─────────────────────────────────────────────────

  group('SwapAstOrderModel.fromJson', () {
    test('parses all fields from complete map', () {
      final model = SwapAstOrderModel.fromJson(_kFullJson);
      expect(model.id, 42);
      expect(model.nftAmtId, 7);
      expect(model.bUuid, 'buyer-uuid-abc');
      expect(model.bAddr, '0xBuyerAddress');
      expect(model.orderNum, 10.5);
      expect(model.orderPrice, 0.025);
      expect(model.payNum, 0.2625);
      expect(model.payTx, '0xpayTxHash');
      expect(model.payState, 1);
      expect(model.orderState, 2);
      expect(model.orderTx, '0xorderTxHash');
      expect(model.expire, 1700999999);
      expect(model.type, 0);
      expect(model.created, 1700000000);
      expect(model.updated, 1700500000);
      expect(model.name, 'Test AST');
      expect(model.desc, 'Description here');
      expect(model.uri, 'https://icon.url/ast.png');
      expect(model.payChain, 'ETH');
      expect(model.payCoin, 'USDT');
    });

    test('all fields are null when map is empty', () {
      final model = SwapAstOrderModel.fromJson({});
      expect(model.id, isNull);
      expect(model.nftAmtId, isNull);
      expect(model.orderNum, isNull);
      expect(model.orderPrice, isNull);
      expect(model.payChain, isNull);
    });

    test('orderNum and orderPrice are parsed as double from num', () {
      final model = SwapAstOrderModel.fromJson({
        'order_num': 5, // int → double
        'order_price': 1.5, // double
        'pay_num': 7.5,
      });
      expect(model.orderNum, isA<double>());
      expect(model.orderNum, 5.0);
      expect(model.orderPrice, 1.5);
      expect(model.payNum, 7.5);
    });

    test('partial map with only essential fields', () {
      final model = SwapAstOrderModel.fromJson({
        'id': 99,
        'pay_chain': 'BTC',
        'pay_coin': 'BTC',
        'order_state': 0,
      });
      expect(model.id, 99);
      expect(model.payChain, 'BTC');
      expect(model.payCoin, 'BTC');
      expect(model.orderState, 0);
      expect(model.orderNum, isNull);
      expect(model.bUuid, isNull);
    });

    test('pay_state values are preserved as int', () {
      final model = SwapAstOrderModel.fromJson({'pay_state': 0});
      expect(model.payState, 0);
    });

    test('order_state = 2 (completed) is parsed', () {
      final model = SwapAstOrderModel.fromJson({'order_state': 2});
      expect(model.orderState, 2);
    });
  });
}
