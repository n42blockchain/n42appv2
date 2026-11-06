import 'dart:async';

import 'package:n42_wallet/features/wallet/api/chain_api/xlm_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class FakeStellarQuoteApi extends XlmApi {
  int fee = 100;
  int entries = 2;
  int sponsoring = 1;
  int sponsored = 1;
  String balance = '10';
  String liabilities = '1';
  String? wrongAccount;
  bool failed = false;
  bool malformed = false;
  Completer<void>? gate;
  final calls = <(String, bool)>[];
  @override
  Future<MessageModel> getAccount(String address, {bool isTest = false}) async {
    calls.add((address, isTest));
    final data = {
      'account_id': wrongAccount ?? address,
      'sequence': '7',
      'subentry_count': entries,
      'num_sponsoring': sponsoring,
      'num_sponsored': sponsored,
      'balances': [
        {
          'asset_type': 'native',
          'balance': balance,
          'selling_liabilities': liabilities,
        },
      ],
    };
    await gate?.future;
    if (failed) return MessageModel.error();
    return MessageModel()
      ..data = malformed ? <String, dynamic>{'account_id': address} : data;
  }

  @override
  Future<MessageModel> getLatestLedger({bool isTest = false}) async =>
      MessageModel()
        ..data = {
          '_embedded': {
            'records': [
              {'base_reserve_in_stroops': 5000000, 'base_fee_in_stroops': fee},
            ],
          },
        };
}
