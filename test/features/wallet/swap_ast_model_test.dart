// Tests for SwapAstModel (AST swap asset entry).
// Pure Dart data class — no platform dependencies.
// Note: runtime fields (balance, price, load) are not serialized; they are
// initialised to sensible defaults and mutated in-memory.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';

const _kFullJson = <String, dynamic>{
  'id': 7,
  'name': 'AST Token',
  'desc': 'Automated swap token',
  'uri': 'https://icon.url/ast.png',
  'amt_num': 100,
  'pay_chain': 'ETH',
  'pay_coin': 'USDT',
  'pay_coin_contract': '0xdAC17F958D2ee523a2206206994597C13D831ec7',
  'pay_coin_decimal': 6,
  'pay_uuid': 'uuid-abc-123',
  'pay_addr': '0xSenderAddress',
  'type': 1,
  'del': 0,
  'created': 1700000000,
  'updated': 1700001000,
};

void main() {
  // ─────────────────────────────────────────────────
  // Positional constructor
  // ─────────────────────────────────────────────────

  group('SwapAstModel positional constructor', () {
    test('sets all db fields correctly', () {
      final model = SwapAstModel(
        7,
        'AST Token',
        'desc',
        'https://icon.url/ast.png',
        100,
        'ETH',
        'USDT',
        '0xcontract',
        6,
        'uuid-abc',
        '0xaddr',
        1,
        0,
        1700000000,
        1700001000,
      );
      expect(model.id, 7);
      expect(model.name, 'AST Token');
      expect(model.desc, 'desc');
      expect(model.uri, 'https://icon.url/ast.png');
      expect(model.amtNum, 100);
      expect(model.payChain, 'ETH');
      expect(model.payCoin, 'USDT');
      expect(model.payCoinContract, '0xcontract');
      expect(model.payCoinDecimal, 6);
      expect(model.payUuid, 'uuid-abc');
      expect(model.payAddr, '0xaddr');
      expect(model.type, 1);
      expect(model.del, 0);
      expect(model.created, 1700000000);
      expect(model.updated, 1700001000);
    });

    test('runtime fields initialise to defaults', () {
      final model = SwapAstModel(
        1,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
      );
      expect(model.balance, 0.0);
      expect(model.price, 0.0);
      expect(model.load, Load.finish);
    });

    test('runtime fields are mutable', () {
      final model = SwapAstModel(
        1,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
      );
      model.balance = 3.14;
      model.price = 2.71;
      model.load = Load.loading;
      expect(model.balance, 3.14);
      expect(model.price, 2.71);
      expect(model.load, Load.loading);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson — snake_case key mapping
  // ─────────────────────────────────────────────────

  group('SwapAstModel.fromJson', () {
    test('parses all fields from complete map', () {
      final model = SwapAstModel.fromJson(_kFullJson);
      expect(model.id, 7);
      expect(model.name, 'AST Token');
      expect(model.desc, 'Automated swap token');
      expect(model.uri, 'https://icon.url/ast.png');
      expect(model.amtNum, 100);
      expect(model.payChain, 'ETH');
      expect(model.payCoin, 'USDT');
      expect(
        model.payCoinContract,
        '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      );
      expect(model.payCoinDecimal, 6);
      expect(model.payUuid, 'uuid-abc-123');
      expect(model.payAddr, '0xSenderAddress');
      expect(model.type, 1);
      expect(model.del, 0);
      expect(model.created, 1700000000);
      expect(model.updated, 1700001000);
    });

    test('all db fields are null when map is empty', () {
      final model = SwapAstModel.fromJson({});
      expect(model.id, isNull);
      expect(model.name, isNull);
      expect(model.amtNum, isNull);
      expect(model.payChain, isNull);
      expect(model.payCoin, isNull);
      expect(model.payCoinContract, isNull);
    });

    test('runtime fields still default to initial values after fromJson', () {
      final model = SwapAstModel.fromJson(_kFullJson);
      expect(model.balance, 0.0);
      expect(model.price, 0.0);
      expect(model.load, Load.finish);
    });

    test('partial map with only pay_chain and pay_coin', () {
      final model = SwapAstModel.fromJson({
        'pay_chain': 'BTC',
        'pay_coin': 'BTC',
      });
      expect(model.payChain, 'BTC');
      expect(model.payCoin, 'BTC');
      expect(model.id, isNull);
      expect(model.amtNum, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // toJson — snake_case keys
  // ─────────────────────────────────────────────────

  group('SwapAstModel.toJson', () {
    test('includes all expected snake_case keys', () {
      final json = SwapAstModel.fromJson(_kFullJson).toJson();
      expect(
        json.keys,
        containsAll([
          'id',
          'name',
          'desc',
          'uri',
          'amt_num',
          'pay_chain',
          'pay_coin',
          'pay_coin_contract',
          'pay_coin_decimal',
          'pay_uuid',
          'pay_addr',
          'type',
          'del',
          'created',
          'updated',
        ]),
      );
    });

    test('values match model fields', () {
      final json = SwapAstModel.fromJson(_kFullJson).toJson();
      expect(json['id'], 7);
      expect(json['name'], 'AST Token');
      expect(json['amt_num'], 100);
      expect(json['pay_chain'], 'ETH');
      expect(json['pay_coin'], 'USDT');
      expect(json['pay_coin_decimal'], 6);
    });

    test('runtime fields (balance/price/load) are NOT included in toJson', () {
      final json = SwapAstModel.fromJson(_kFullJson).toJson();
      expect(json.containsKey('balance'), isFalse);
      expect(json.containsKey('price'), isFalse);
      expect(json.containsKey('load'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson / toJson roundtrip
  // ─────────────────────────────────────────────────

  group('SwapAstModel fromJson/toJson roundtrip', () {
    test('preserves all db fields', () {
      final original = SwapAstModel.fromJson(_kFullJson);
      final restored = SwapAstModel.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.amtNum, original.amtNum);
      expect(restored.payChain, original.payChain);
      expect(restored.payCoin, original.payCoin);
      expect(restored.payCoinContract, original.payCoinContract);
      expect(restored.payCoinDecimal, original.payCoinDecimal);
      expect(restored.payUuid, original.payUuid);
      expect(restored.payAddr, original.payAddr);
      expect(restored.type, original.type);
      expect(restored.del, original.del);
      expect(restored.created, original.created);
      expect(restored.updated, original.updated);
    });
  });
}
