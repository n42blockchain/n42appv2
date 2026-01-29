// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';

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

  /// Get token accounts by owner for Solana
  ///
  /// Returns all token accounts for a specific contract owned by the address
  /// [address] - Wallet address
  /// [contract] - Token contract address
  /// [isTest] - Use testnet
  Future<MessageModel> getTokenAccountsByOwnerSolana(
    String address,
    String contract, {
    bool isTest = false,
  }) async {
    try {
      final params = <String, dynamic>{
        'mint': contract,
        'net_mode': isTest ? 'test' : 'main',
        'pubkey': address,
      };
      final a = await httpClient.post(
        '${url}v1/sol/token/accounts/by/owner',
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
          mm.data = a['data']['result']['value'];
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get account info for Solana address
  ///
  /// Returns account data for the specified address
  /// [address] - Wallet address
  /// [isTest] - Use testnet
  Future<MessageModel> getAccountInfoSolana(
    String address, {
    bool isTest = false,
  }) async {
    try {
      final params = <String, dynamic>{
        'net_mode': isTest ? 'test' : 'main',
        'pubkey': address,
      };
      final a = await httpClient.post(
        '${url}v1/sol/account/info',
        params: params,
        data: params,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data']['result']['value']['data'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get recent blockhash for Solana
  ///
  /// Returns the most recent blockhash for transaction signing
  /// [isTest] - Use testnet
  Future<MessageModel> getRecentBlockhashSolana({bool isTest = false}) async {
    try {
      final params = <String, dynamic>{
        'net_mode': isTest ? 'test' : 'main',
      };
      final a = await httpClient.post(
        '${url}v1/sol/recent/block/hash',
        params: params,
        data: params,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data']['result']['value']['blockhash'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Send Solana transaction
  ///
  /// Broadcasts a signed transaction to the Solana network
  /// [signHash] - Signed transaction hash
  /// [netMode] - Network mode ('main' or 'test')
  Future<MessageModel> sendTxSolana(String signHash, String netMode) async {
    try {
      final params = <String, dynamic>{
        'net_mode': netMode,
        'tx_hash': signHash,
      };
      final a = await httpClient.post(
        '${url}v1/sol/tx/send',
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
          mm.data = a['data']['result'];
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get gas fee for Solana
  ///
  /// Returns the current fee calculator (lamports per signature)
  /// [isTest] - Use testnet
  Future<MessageModel> getGasPriceSolana({bool isTest = false}) async {
    try {
      final params = <String, dynamic>{
        'net_mode': isTest ? 'test' : 'main',
      };
      final a = await httpClient.post(
        '${url}v1/sol/fees',
        params: params,
        data: params,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = BigInt.from(
          a['data']['result']['value']['feeCalculator']['lamportsPerSignature'],
        );
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get transaction by hash for Solana
  ///
  /// Returns transaction information for the given hash
  /// [txHash] - Transaction signature
  /// [netMode] - Network mode ('main' or 'test')
  Future<MessageModel> getTransactionSolana(
    String txHash,
    String netMode,
  ) async {
    try {
      final params = <String, dynamic>{
        'net_mode': netMode,
        'tx_sign': txHash,
      };
      final a = await httpClient.post(
        '${url}v1/sol/transaction',
        params: params,
        data: params,
        header: header,
      );

      final mm = MessageModel.error();
      if (a['code'] == 0) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = a['data']['result']['meta']['status'];
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }
}
