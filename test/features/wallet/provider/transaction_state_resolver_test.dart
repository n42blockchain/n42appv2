import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _FakeReceiptReader {
  MessageModel response = MessageModel();
  String? lastCoinType;
  String? lastTxHash;
  bool? lastIsTest;
  String? lastRpc;

  Future<MessageModel> getTransactionReceiptEth(
    String coinType,
    String txHash, {
    bool isTest = false,
    String? rpc,
  }) async {
    lastCoinType = coinType;
    lastTxHash = txHash;
    lastIsTest = isTest;
    lastRpc = rpc;
    return response;
  }
}

TransationRecordModel _record({
  String blockchainType = 'Ethereum',
  String? service,
  String? serviceTest,
  int isTest = 0,
}) {
  return TransationRecordModel()
    ..coin = {
      'blockchainType': blockchainType,
      'coinType': 'ETH',
      if (service != null) 'service': service,
      if (serviceTest != null) 'service_test': serviceTest,
    }
    ..txHash = '0xabc'
    ..isTest = isTest;
}

void main() {
  group('TransactionStateResolver EVM receipts', () {
    late _FakeReceiptReader api;
    late TransactionStateResolver resolver;

    setUp(() {
      api = _FakeReceiptReader();
      resolver = TransactionStateResolver(
        receiptReader: api.getTransactionReceiptEth,
      );
    });

    test(
      'maps custom-RPC success, revert, pending, and invalid statuses',
      () async {
        final record = _record(service: ' https://main-rpc.example/ ');

        api.response.data = {'status': '0x1'};
        expect(await resolver.resolveState(record), 1);
        expect(api.lastCoinType, 'ETH');
        expect(api.lastTxHash, '0xabc');
        expect(api.lastIsTest, isFalse);
        expect(api.lastRpc, 'https://main-rpc.example/');

        api.response.data = {'status': '0x0'};
        expect(await resolver.resolveState(record), 2);

        api.response.data = null;
        expect(await resolver.resolveState(record), 0);

        api.response.data = {'status': 'unexpected'};
        expect(await resolver.resolveState(record), 0);

        api.response = MessageModel.error();
        expect(await resolver.resolveState(record), 0);
      },
    );

    test(
      'uses test RPC and reports pending responses as unconfirmed',
      () async {
        final record = _record(
          service: 'https://main-rpc.example',
          serviceTest: ' https://test-rpc.example ',
          isTest: 1,
        );
        api.response.data = null;

        expect(await resolver.resolveState(record), 0);
        expect(api.lastIsTest, isTrue);
        expect(api.lastRpc, 'https://test-rpc.example');
      },
    );

    test(
      'uses TokenView error envelope when no custom RPC is configured',
      () async {
        final record = _record();

        api.response.data = {
          'error': {'code': 0},
          'result': {'status': '0x0'},
        };
        expect(await resolver.resolveState(record), 2);
        expect(api.lastRpc, isNull);

        api.response.data = {
          'error': {'code': -32000},
          'result': {'status': '0x1'},
        };
        expect(await resolver.resolveState(record), -1);
      },
    );

    test(
      'routes EVM-compatible chains through the same receipt resolver',
      () async {
        final record = _record(
          blockchainType: 'Harmony',
          service: 'https://harmony-rpc.example',
        );
        api.response.data = {'status': '0x1'};

        expect(await resolver.resolveState(record), 1);
        expect(api.lastRpc, 'https://harmony-rpc.example');
      },
    );
  });
}
