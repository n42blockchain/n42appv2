import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_record_helpers.dart';

void main() {
  group('resolveCoinContractForNetwork', () {
    test('uses testnet contract when available', () {
      final contract = resolveCoinContractForNetwork(
        coin: {'contract': '0xmain', 'contract_test': '0xtest'},
        isTest: true,
      );

      expect(contract, '0xtest');
    });

    test('falls back to mainnet contract when testnet contract is empty', () {
      final contract = resolveCoinContractForNetwork(
        coin: {'contract': '0xmain', 'contract_test': ''},
        isTest: true,
      );

      expect(contract, '0xmain');
    });
  });

  group('buildFallbackTransactionRecord', () {
    test('seeds transaction record from the current coin model', () {
      final coinModel = CoinModel()
        ..address = '0xwallet'
        ..addrType = 'segwit'
        ..isTest = true
        ..coin = {
          'coinType': 'USDT',
          'contract': '0xmain',
          'contract_test': '0xtest',
          'chainId': 1,
          'chainId_test': 2,
        };

      final record = buildFallbackTransactionRecord(coinModel, walletIndex: 7);

      expect(record.address, '0xwallet');
      expect(record.from1, '0xwallet');
      expect(record.addrType, 'segwit');
      expect(record.coinMiniName, 'USDT');
      expect(record.contract, '0xtest');
      expect(record.isTest, 1);
      expect(record.coinId, 2);
      expect(record.walletIndex, 7);
      expect(record.gasPrice, BigInt.zero);
      expect(record.gasPriceValue, BigInt.zero);
    });
  });

  group('populateTrxTransactionRecordFromInfo', () {
    test('hydrates native TRX transfers from toAddress and amount', () {
      final record = TransationRecordModel();

      populateTrxTransactionRecordFromInfo(
        record: record,
        transactionInfo: {'toAddress': 'TNativeTo', 'amount': '12345'},
      );

      expect(record.to1, 'TNativeTo');
      expect(record.price, BigInt.from(12345));
    });

    test('hydrates TRC20 transfers from trigger info', () {
      final record = TransationRecordModel()
        ..contract = 'old-contract'
        ..to1 = 'old-to'
        ..price = BigInt.zero;

      populateTrxTransactionRecordFromInfo(
        record: record,
        transactionInfo: {
          'toAddress': 'TNativeTo',
          'amount': '1',
          'trigger_info': {
            'contract_address': 'TTokenContract',
            'parameter': {'_to': 'TTokenTo', '_value': '67890'},
          },
        },
      );

      expect(record.contract, 'TTokenContract');
      expect(record.to1, 'TTokenTo');
      expect(record.price, BigInt.from(67890));
    });
  });
}
