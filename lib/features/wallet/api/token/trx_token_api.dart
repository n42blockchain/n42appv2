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
  /// Get gas price for Tron
  ///
  /// Returns the current gas price for the Tron network
  /// [isTest] - Use testnet
  Future<MessageModel> getGasPriceTrx({bool isTest = false}) async {
    try {
      final params = <String, dynamic>{
        'net_mode': isTest ? 'test' : 'main',
      };
      final a = await httpClient.post(
        '${url}v1/trx/gas/price',
        params: params,
        data: params,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          final BigInt value = hexToInt(a['data']['result'].toString());
          mm.data = value;
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
  ///
  /// Returns the transaction receipt for the given hash
  /// [txHash] - Transaction hash
  /// [isTest] - Use testnet
  Future<MessageModel> getTransactionReceiptTrx(
    String txHash, {
    bool isTest = false,
  }) async {
    try {
      final params = <String, dynamic>{
        'tx_hash': txHash,
        'net_mode': isTest ? 'test' : 'main',
      };
      final a = await httpClient.post(
        '${url}v1/trx/transaction/receipt',
        params: params,
        data: params,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get latest block number for Tron
  ///
  /// Returns the latest block information
  /// [isTest] - Use testnet
  Future<MessageModel> getLatestBlockNumberTrx({bool isTest = false}) async {
    try {
      final params = <String, dynamic>{
        'net_mode': isTest ? 'test' : 'main',
      };
      final a = await httpClient.post(
        '${url}v1/trx/latest/block',
        params: params,
        data: params,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Create Tron transaction
  ///
  /// Creates an unsigned transaction for TRX transfer
  /// [sendAddress] - Sender address
  /// [toAddress] - Recipient address
  /// [amount] - Amount in sun (1 TRX = 1,000,000 sun)
  /// [netMode] - Network mode ('main' or 'test')
  Future<MessageModel> createTxTrx(
    String sendAddress,
    String toAddress,
    int amount,
    dynamic netMode,
  ) async {
    try {
      final params = <String, dynamic>{
        'coin': 'trx',
        'owner_address': sendAddress,
        'to_address': toAddress,
        'visible': false,
        'amount': amount,
      };
      final a = await httpClient.post(
        '${url}v1/vipapi/onchainwallet/transaction',
        params: params,
        data: params,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data']['raw_data_hex'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Send Tron transaction
  ///
  /// Broadcasts a signed transaction to the Tron network
  /// [signHash] - Signed transaction JSON string
  /// [netMode] - Network mode ('main' or 'test')
  Future<MessageModel> sendTxTrx(String signHash, String netMode) async {
    try {
      final Map<String, dynamic> sign =
          json.decode(signHash) as Map<String, dynamic>;
      sign['visible'] = false;
      sign['net_mode'] = 'main';

      final a = await httpClient.post(
        '${url}v1/trx/broadcast/transaction',
        params: sign,
        data: sign,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }
}
