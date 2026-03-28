// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:web3dart/web3dart.dart';

import 'token_api_base.dart';

/// Net mode string from isTest flag.
String _netMode(bool isTest) => isTest ? 'test' : 'main';

/// Ethereum and EVM-compatible chain API methods
///
/// Provides balance, gas estimation, transaction, and nonce methods
/// for Ethereum and similar EVM chains (BSC, Polygon, Avalanche, etc.)
mixin EthTokenApiMixin on TokenApiBase {
  /// Get balance for ETH-like chains
  ///
  /// [coinType] - Chain symbol (ETH, BNB, MATIC, etc.)
  /// [address] - Wallet address
  /// [contract] - Contract address (empty for native token)
  /// [returnDouble] - If true, returns balance as double
  /// [isTest] - Use testnet
  /// [rpc] - Custom RPC URL
  Future<MessageModel> getBalanceEth(
    String coinType,
    String address,
    String contract, {
    bool returnDouble = false,
    bool isTest = false,
    String? rpc,
  }) async {
    try {
      if (rpc != null) {
        return await EthAPI.init(null, rpc, null).getBalance(address, contract);
      }

      final coin = coinType.toLowerCase();
      final netMode = _netMode(isTest);

      final String endpoint;
      final Map<String, dynamic> params;
      if (contract.isEmpty) {
        endpoint = '${url}v2/eth/balance';
        params = {
          'address': address, 'coin': coin, 'net_mode': netMode, 'tag': 'latest',
        };
      } else {
        endpoint = '${url}v2/eth/call';
        params = {
          'from': address, 'to': contract, 'coin': coin, 'net_mode': netMode, 'tag': 'latest',
        };
      }

      final response = await httpClient.post(endpoint, params: params, data: params, header: header);
      final mm = MessageModel.error();
      if (response['code'] == 200) {
        mm.error = false;
        String result = response['data']['result'];
        if (result == '0x') result = '0x0';
        mm.data = hexToInt(result);
      } else {
        mm.data = errorMessage(response['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get all token balances for an ETH address
  Future<MessageModel> getAllTokenBalanceEth(String coinType, String address) async {
    try {
      final response = await httpClient.get(
        '${url}v1/vipapi/eth-class/address/balance?coin=${coinType.toLowerCase()}&address=${address.toLowerCase()}',
        params: <String, dynamic>{},
        header: header,
      );

      final code = response['code'];
      final mm = MessageModel.error();
      switch (code) {
        case 0 || 1:
          mm.error = false;
          mm.data = response['data'];
        case 400 || 404:
          mm.error = false;
          mm.data = [];
        default:
          mm.data = errorMessage(code);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Estimate gas for ETH transaction
  Future<MessageModel> getGasEstimateEth(Map<String, dynamic> params) async {
    try {
      final a = await httpClient.post(
        '${url}v2/eth/estimate/gas',
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
          mm.data = hexToInt(a['data']['result']);
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Estimate gas for ETH transaction (V2 with more parameters)
  Future<MessageModel> getGasEstimateEthV2(
    String from,
    String to,
    BigInt gasPrice,
    BigInt value,
    BigInt gas,
    String coinType, {
    String contract = '',
    String data = '',
    bool isTest = false,
  }) async {
    // Special handling for TRX
    if (coinType == CoinType.TRX.name) {
      return TrxApi().getGasEstimateTrx(from, to, gasPrice, value, gas, contract: contract, isTest: isTest);
    }

    final gasPriceHex = '0x${gasPrice.toRadixString(16)}';
    final gasPriceKey = get1559WithChainSymbol(coinType) ? 'maxFeePerGas' : 'gasPrice';
    final gasHex = '0x${gas.toRadixString(16)}';
    final netMode = _netMode(isTest);

    final Map<String, dynamic> params;
    if (contract.isEmpty) {
      params = {
        'from': from, 'to': to, 'gas': gasHex,
        gasPriceKey: gasPriceHex, 'coin': coinType, 'net_mode': netMode,
        'id': AppGlobals.nextId,
        if (data.isNotEmpty) 'data': data,
      };
    } else {
      final toAddress = strip0x(to);
      final methodSig = bytesToHex(keccakAscii('transfer(address,uint256)')).substring(0, 8).toLowerCase();
      final valueHex = bytesToHex(padUint8ListTo32(unsignedIntToBytes(value)));
      params = {
        'from': from, 'to': contract, 'gas': gasHex,
        'data': '0x${methodSig}000000000000000000000000$toAddress$valueHex',
        gasPriceKey: gasPriceHex, 'coin': coinType, 'net_mode': netMode,
        'id': AppGlobals.nextId,
      };
    }

    return getGasEstimateEth(params);
  }

  /// Helper: POST to API with code 200 + error code check, extract result string
  Future<MessageModel> _postWithErrorCheck(
    String endpoint,
    Map<String, dynamic> params, {
    bool parseHex = false,
  }) async {
    final a = await httpClient.post('$url$endpoint', params: params, data: params, header: header);
    final mm = MessageModel.error();
    if (a['code'] == 200) {
      if (a['data']['error']['code'] != 0) {
        mm.data = a['data']['error']['message'];
      } else {
        mm.error = false;
        final result = a['data']['result'].toString();
        mm.data = parseHex ? hexToInt(result) : result;
      }
    } else {
      mm.data = errorMessage(a['code']);
    }
    return mm;
  }

  /// Get transaction count (nonce) for ETH address
  Future<MessageModel> getTransactionCountEth(
    String coinType,
    String address, {
    String netMode = 'main',
    String? rpc,
  }) async {
    try {
      if (rpc != null) return EthAPI.init(null, rpc, null).getTransactionCount(address);
      return _postWithErrorCheck('v2/eth/transaction/count', {
        'coin': coinType.toLowerCase(), 'hex_address': address, 'net_mode': netMode, 'tag': 'pending',
      }, parseHex: true);
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Send ETH transaction
  Future<MessageModel> sendTxEth(
    String coinType,
    String signHash,
    String netMode, {
    String? rpc,
  }) async {
    try {
      if (rpc != null) return EthAPI.init(null, rpc, null).sendTransaction(signHash);
      return _postWithErrorCheck('v2/eth/raw/transaction', {
        'coin': coinType, 'signed_tx': signHash, 'net_mode': netMode,
      });
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get transaction receipt
  Future<MessageModel> getTransactionReceiptEth(
    String coinType,
    String txHash, {
    bool isTest = false,
    String? rpc,
  }) async {
    try {
      if (rpc != null) return EthAPI.init(null, rpc, null).getTransactionReceipt(txHash);
      final params = <String, dynamic>{
        'tx_hash': txHash, 'coin': coinType, 'net_mode': _netMode(isTest),
      };
      final response = await httpClient.post('${url}v2/eth/transaction/receipt', params: params, data: params, header: header);
      final mm = MessageModel.error();
      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data'];
      } else {
        mm.data = errorMessage(response['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Get gas price for ETH chain
  Future<MessageModel> getGasPriceEth(
    String coinType, {
    bool isTest = false,
    String? rpc,
  }) async {
    try {
      if (rpc != null) return EthAPI.init(null, rpc, null).getGasPrice();
      return _postWithErrorCheck('v2/eth/gas/price', {
        'coin': coinType, 'net_mode': _netMode(isTest),
      }, parseHex: true);
    } catch (e) {
      return createError(e.toString());
    }
  }

  /// Resolve ENS domain to address
  Future<MessageModel> getEnsResolve(String domain) async {
    try {
      final response = await httpClient.get(
        '${url}v1/ens/resolve?domain=$domain',
        params: <String, dynamic>{},
        header: header,
      );

      final mm = MessageModel();
      if (response['code'] == 200) {
        mm.data = response['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(response['code']);
      }
      return mm;
    } catch (e) {
      return createError(e.toString());
    }
  }
}
