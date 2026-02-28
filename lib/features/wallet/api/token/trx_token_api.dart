// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:n42_wallet/features/models/message_model.dart';
import 'package:web3dart/web3dart.dart';

import 'token_api_base.dart';

/// Tron chain API methods
///
/// Provides balance, transaction, and gas fee methods
/// for Tron blockchain and TRC tokens.
mixin TrxTokenApiMixin on TokenApiBase {
  /// Helper: POST to TRX API, check code 200, extract data
  Future<MessageModel> _trxPost(
    String endpoint,
    Map<String, dynamic> params,
    dynamic Function(dynamic data) extractor,
  ) async {
    try {
      final a = await httpClient.post('${url}$endpoint', params: params, data: params, header: header);
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = extractor(a['data']);
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get gas price for Tron
  Future<MessageModel> getGasPriceTrx({bool isTest = false}) async {
    try {
      final params = <String, dynamic>{'net_mode': isTest ? 'test' : 'main'};
      final a = await httpClient.post('${url}v1/trx/gas/price', params: params, data: params, header: header);
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = hexToInt(a['data']['result'].toString());
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get transaction receipt for Tron
  Future<MessageModel> getTransactionReceiptTrx(String txHash, {bool isTest = false}) async {
    return _trxPost('v1/trx/transaction/receipt',
        {'tx_hash': txHash, 'net_mode': isTest ? 'test' : 'main'}, (d) => d);
  }

  /// Get latest block number for Tron
  Future<MessageModel> getLatestBlockNumberTrx({bool isTest = false}) async {
    return _trxPost('v1/trx/latest/block',
        {'net_mode': isTest ? 'test' : 'main'}, (d) => d);
  }

  /// Create Tron transaction
  Future<MessageModel> createTxTrx(
    String sendAddress, String toAddress, int amount, dynamic netMode,
  ) async {
    return _trxPost('v1/vipapi/onchainwallet/transaction', {
      'coin': 'trx', 'owner_address': sendAddress, 'to_address': toAddress,
      'visible': false, 'amount': amount,
    }, (d) => d['raw_data_hex']);
  }

  /// Send Tron transaction
  Future<MessageModel> sendTxTrx(String signHash, String netMode) async {
    try {
      final sign = json.decode(signHash) as Map<String, dynamic>;
      sign['visible'] = false;
      sign['net_mode'] = 'main';
      return _trxPost('v1/trx/broadcast/transaction', sign, (d) => d);
    } catch (e) {
      return createError(e.toString());
    }
  }
}
