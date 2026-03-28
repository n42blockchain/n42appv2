// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

import 'token_api_base.dart';

/// Solana chain API methods
///
/// Provides balance, account info, transaction, and gas fee methods
/// for Solana blockchain and SPL tokens.
mixin SolTokenApiMixin on TokenApiBase {
  /// Get balance for Solana address
  ///
  /// [coinType] - Chain symbol (SOL)
  /// [address] - Wallet address
  /// [contract] - Contract address (empty for native SOL)
  /// [returnDouble] - If true, returns balance as double
  /// [isTest] - Use testnet
  Future<MessageModel> getBalanceSolana(
    String coinType,
    String address,
    String contract, {
    bool returnDouble = false,
    bool isTest = false,
  }) async {
    try {
      dynamic a;
      if (contract.isEmpty) {
        final params = <String, dynamic>{
          'pubkey': address,
          'net_mode': isTest ? 'test' : 'main',
        };
        a = await httpClient.post(
          '${url}v1/sol/balance',
          params: params,
          data: params,
          header: header,
        );
      } else {
        final pubKey = await Trustdart().getPubKeySOL(address, contract);
        final params = <String, dynamic>{
          'pubkey': pubKey,
          'net_mode': isTest ? 'test' : 'main',
        };
        a = await httpClient.post(
          '${url}v1/sol/token/account/balance',
          params: params,
          data: params,
          header: header,
        );
      }

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (contract.isEmpty) {
          mm.error = false;
          final BigInt value = BigInt.from(a['data']);
          mm.data = value;
        } else {
          if (a['data']['error']['code'] != 0) {
            mm.data = a['data']['error']['message'];
          } else {
            mm.error = false;
            mm.data = BigInt.parse(
              a['data']['result']['value']['amount']?.toString() ?? '0',
            );
          }
        }
      } else {
        if (contract.isNotEmpty) {
          if (a['code'] == 500) {
            mm.error = false;
            mm.data = BigInt.zero;
          }
        } else {
          mm.data = errorMessage(a['code']);
        }
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Helper: POST to Solana API, check code 200, extract data via [extractor]
  Future<MessageModel> _solPost(
    String endpoint,
    Map<String, dynamic> params,
    dynamic Function(dynamic data) extractor, {
    int successCode = 200,
  }) async {
    try {
      final a = await httpClient.post(
        '$url$endpoint',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == successCode) {
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

  /// Helper: POST with inner error code check (data.error.code != 0 means failure)
  Future<MessageModel> _solPostWithErrorCheck(
    String endpoint,
    Map<String, dynamic> params,
    dynamic Function(dynamic data) extractor, {
    int successCode = 200,
  }) async {
    try {
      final a = await httpClient.post(
        '$url$endpoint',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == successCode) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = extractor(a['data']);
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get token accounts by owner for Solana
  Future<MessageModel> getTokenAccountsByOwnerSolana(
    String address,
    String contract, {
    bool isTest = false,
  }) async {
    return _solPostWithErrorCheck('v1/sol/token/accounts/by/owner', {
      'mint': contract,
      'net_mode': isTest ? 'test' : 'main',
      'pubkey': address,
    }, (d) => d['result']['value']);
  }

  /// Get account info for Solana address
  Future<MessageModel> getAccountInfoSolana(
    String address, {
    bool isTest = false,
  }) async {
    return _solPost('v1/sol/account/info', {
      'net_mode': isTest ? 'test' : 'main',
      'pubkey': address,
    }, (d) => d['result']['value']['data']);
  }

  /// Get recent blockhash for Solana
  Future<MessageModel> getRecentBlockhashSolana({bool isTest = false}) async {
    return _solPost('v1/sol/recent/block/hash', {
      'net_mode': isTest ? 'test' : 'main',
    }, (d) => d['result']['value']['blockhash']);
  }

  /// Send Solana transaction
  Future<MessageModel> sendTxSolana(String signHash, String netMode) async {
    return _solPostWithErrorCheck('v1/sol/tx/send', {
      'net_mode': netMode,
      'tx_hash': signHash,
    }, (d) => d['result']);
  }

  /// Get gas fee for Solana (lamports per signature)
  Future<MessageModel> getGasPriceSolana({bool isTest = false}) async {
    return _solPost(
      'v1/sol/fees',
      {'net_mode': isTest ? 'test' : 'main'},
      (d) => BigInt.from(
        d['result']['value']['feeCalculator']['lamportsPerSignature'],
      ),
    );
  }

  /// Get transaction by hash for Solana
  Future<MessageModel> getTransactionSolana(
    String txHash,
    String netMode,
  ) async {
    return _solPostWithErrorCheck(
      'v1/sol/transaction',
      {'net_mode': netMode, 'tx_sign': txHash},
      (d) => d['result']['meta']['status'],
      successCode: 0,
    );
  }
}
