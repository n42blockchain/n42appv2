// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';

import 'token_api_base.dart';

/// Bitcoin and UTXO-based chain API methods
///
/// Provides balance, UTXO, transaction, and gas fee methods
/// for Bitcoin and similar UTXO-based chains (LTC, DOGE, BCH, etc.)
mixin BtcTokenApiMixin on TokenApiBase {
  /// Get Bitcoin gas fee levels
  ///
  /// Returns fee rates for different priority levels (fast, medium, slow)
  Future<MessageModel> getGasFeeBtc({bool isTest = false}) async {
    try {
      if (isTest) {
        return await BtcApi(test: isTest).getGasfee();
      }

      final a = await httpClient.get(
        '${url}v1/blockchain/fee/byte',
        params: <String, dynamic>{},
        header: header,
      );

      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get balance for BTC-like chains
  ///
  /// [coinType] - Chain symbol (BTC, LTC, DOGE, etc.)
  /// [address] - Wallet address
  /// [returnDouble] - If true, returns balance as double; otherwise as BigInt
  Future<MessageModel> getBalanceBtc(
    String coinType,
    String address, {
    bool returnDouble = false,
  }) async {
    try {
      final a = await httpClient.get(
        '${url}v1/vipapi/account/balance?coin=${coinType.toLowerCase()}&addr=$address',
        params: <String, dynamic>{},
        header: header,
      );

      final mm = MessageModel();
      if (a['code'] == 200) {
        if (returnDouble) {
          mm.data = double.parse(a['data'].toString());
        } else {
          mm.data = ethToWeiString(a['data'].toString(), 8);
        }
      } else {
        mm.error = true;
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get UTXOs for BTC-like chains
  ///
  /// [coinType] - Chain symbol
  /// [address] - Wallet address
  /// [pageSize] - Number of UTXOs per page
  /// [pageNum] - Page number
  Future<MessageModel> getUTXOBtc(
    String coinType,
    String address, {
    int pageSize = 100,
    int pageNum = 1,
    bool isTest = false,
  }) async {
    try {
      if (isTest) {
        return await BtcApi(test: isTest).getUtxos(address);
      }

      final a = await httpClient.get(
        '${url}v1/vipapi/utxo/tx/list?coin=${coinType.toLowerCase()}&addr=$address&page=$pageNum&page_size=$pageSize',
        params: <String, dynamic>{},
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else if (a['code'] == 404) {
        mm.error = false;
        mm.data = [];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get transaction list for BTC-like chains
  ///
  /// [coinType] - Chain symbol
  /// [address] - Wallet address
  /// [pageSize] - Number of transactions per page
  /// [pageNum] - Page number
  Future<MessageModel> getTxListBtc(
    String coinType,
    String address, {
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    try {
      final a = await httpClient.get(
        '${url}v1/vipapi/address/tx/list?coin=${coinType.toLowerCase()}&addr=$address&page=$pageNum&page_size=$pageSize',
        params: <String, dynamic>{},
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else if (a['code'] == 404) {
        mm.error = false;
        mm.data = [];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Broadcast transaction for BTC-like chains
  ///
  /// [coinType] - Chain symbol
  /// [signHash] - Signed transaction hex
  Future<MessageModel> sendTxBtc(
    String coinType,
    String signHash, {
    bool isTest = false,
  }) async {
    try {
      if (isTest) {
        return await BtcApi(test: isTest).sendTxHttp(signHash);
      }

      final params = <String, dynamic>{
        'coin': coinType.toLowerCase(),
        'tx_hash': signHash,
      };

      final a = await httpClient.post(
        '${url}v1/vipapi/onchainwallet/rawtransaction',
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
}
