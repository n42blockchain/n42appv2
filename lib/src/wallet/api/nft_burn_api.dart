// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// NFT 销毁 API
///
/// 支持 ERC721 和 ERC1155 标准的 NFT 销毁
class NftBurnApi {
  // 死亡地址（用于 ERC721 无 burn 函数的情况）
  static const String deadAddress = '0x000000000000000000000000000000000000dEaD';
  static const String zeroAddress = '0x0000000000000000000000000000000000000000';

  // ERC721 burn 函数签名
  static const String erc721BurnSelector = '0x42966c68'; // burn(uint256)
  static const String erc721TransferFromSelector = '0x23b872dd'; // transferFrom(address,address,uint256)
  static const String erc721SafeTransferFromSelector = '0x42842e0e'; // safeTransferFrom(address,address,uint256)

  // ERC1155 burn 函数签名
  static const String erc1155BurnSelector = '0xf5298aca'; // burn(address,uint256,uint256)
  static const String erc1155SafeTransferFromSelector = '0xf242432a'; // safeTransferFrom(address,address,uint256,uint256,bytes)

  /// 检查合约是否支持 burn 函数
  Future<bool> supportsBurn(String rpcUrl, String contractAddress) async {
    try {
      // 尝试调用 supportsInterface 检查 ERC721Burnable
      // 0x42966c68 是 burn(uint256) 的函数选择器
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_call',
        'params': [
          {
            'to': contractAddress,
            'data': '0x01ffc9a7${_padLeft('42966c68', 64)}', // supportsInterface(bytes4)
          },
          'latest'
        ],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );

      if (response['result'] != null) {
        final result = response['result'].toString();
        return result.endsWith('1'); // 返回 true 表示支持
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 估算 ERC721 销毁的 Gas
  Future<MessageModel> estimateErc721BurnGas({
    required String rpcUrl,
    required String contractAddress,
    required String ownerAddress,
    required String tokenId,
    bool useBurnFunction = false,
  }) async {
    try {
      String data;
      String toAddress;

      if (useBurnFunction) {
        // 使用 burn(uint256) 函数
        data = _buildErc721BurnData(tokenId);
        toAddress = contractAddress;
      } else {
        // 使用 transferFrom 转到死亡地址
        data = _buildErc721TransferData(ownerAddress, deadAddress, tokenId);
        toAddress = contractAddress;
      }

      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_estimateGas',
        'params': [
          {
            'from': ownerAddress,
            'to': toAddress,
            'data': data,
          }
        ],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );

      if (response['result'] != null) {
        final gasLimit = _hexToBigInt(response['result'].toString());
        // 增加 20% 安全边际
        final safeGasLimit = gasLimit * BigInt.from(120) ~/ BigInt.from(100);
        return MessageModel()
          ..error = false
          ..data = safeGasLimit;
      }

      // 默认 gas limit
      return MessageModel()
        ..error = false
        ..data = BigInt.from(100000);
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = BigInt.from(100000);
    }
  }

  /// 估算 ERC1155 销毁的 Gas
  Future<MessageModel> estimateErc1155BurnGas({
    required String rpcUrl,
    required String contractAddress,
    required String ownerAddress,
    required String tokenId,
    required BigInt amount,
    bool useBurnFunction = false,
  }) async {
    try {
      String data;

      if (useBurnFunction) {
        // 使用 burn(address,uint256,uint256) 函数
        data = _buildErc1155BurnData(ownerAddress, tokenId, amount);
      } else {
        // 使用 safeTransferFrom 转到死亡地址
        data = _buildErc1155TransferData(ownerAddress, deadAddress, tokenId, amount);
      }

      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_estimateGas',
        'params': [
          {
            'from': ownerAddress,
            'to': contractAddress,
            'data': data,
          }
        ],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );

      if (response['result'] != null) {
        final gasLimit = _hexToBigInt(response['result'].toString());
        final safeGasLimit = gasLimit * BigInt.from(120) ~/ BigInt.from(100);
        return MessageModel()
          ..error = false
          ..data = safeGasLimit;
      }

      return MessageModel()
        ..error = false
        ..data = BigInt.from(150000);
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = BigInt.from(150000);
    }
  }

  /// 构建 ERC721 销毁交易数据
  Future<MessageModel> buildErc721BurnTransaction({
    required String chainSymbol,
    required String contractAddress,
    required String ownerAddress,
    required String tokenId,
    required BigInt gasPrice,
    required BigInt gasLimit,
    required int nonce,
    required int chainId,
    bool useBurnFunction = false,
    BigInt? maxPriorityFeePerGas,
    BigInt? maxFeePerGas,
  }) async {
    try {
      String data;
      String toAddress;

      if (useBurnFunction) {
        data = _buildErc721BurnData(tokenId);
        toAddress = contractAddress;
      } else {
        data = _buildErc721TransferData(ownerAddress, deadAddress, tokenId);
        toAddress = contractAddress;
      }

      final txData = {
        'chainId': '0x${chainId.toRadixString(16)}',
        'nonce': '0x${nonce.toRadixString(16)}',
        'to': toAddress,
        'value': '0x0',
        'data': data,
        'gasLimit': '0x${gasLimit.toRadixString(16)}',
      };

      // EIP-1559 或 Legacy
      if (maxFeePerGas != null && maxPriorityFeePerGas != null) {
        txData['maxFeePerGas'] = '0x${maxFeePerGas.toRadixString(16)}';
        txData['maxPriorityFeePerGas'] = '0x${maxPriorityFeePerGas.toRadixString(16)}';
        txData['type'] = '0x2';
      } else {
        txData['gasPrice'] = '0x${gasPrice.toRadixString(16)}';
      }

      return MessageModel()
        ..error = false
        ..data = {
          'txData': txData,
          'rawData': data,
          'method': useBurnFunction ? 'burn' : 'transferFrom',
        };
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 构建 ERC1155 销毁交易数据
  Future<MessageModel> buildErc1155BurnTransaction({
    required String chainSymbol,
    required String contractAddress,
    required String ownerAddress,
    required String tokenId,
    required BigInt amount,
    required BigInt gasPrice,
    required BigInt gasLimit,
    required int nonce,
    required int chainId,
    bool useBurnFunction = false,
    BigInt? maxPriorityFeePerGas,
    BigInt? maxFeePerGas,
  }) async {
    try {
      String data;

      if (useBurnFunction) {
        data = _buildErc1155BurnData(ownerAddress, tokenId, amount);
      } else {
        data = _buildErc1155TransferData(ownerAddress, deadAddress, tokenId, amount);
      }

      final txData = {
        'chainId': '0x${chainId.toRadixString(16)}',
        'nonce': '0x${nonce.toRadixString(16)}',
        'to': contractAddress,
        'value': '0x0',
        'data': data,
        'gasLimit': '0x${gasLimit.toRadixString(16)}',
      };

      if (maxFeePerGas != null && maxPriorityFeePerGas != null) {
        txData['maxFeePerGas'] = '0x${maxFeePerGas.toRadixString(16)}';
        txData['maxPriorityFeePerGas'] = '0x${maxPriorityFeePerGas.toRadixString(16)}';
        txData['type'] = '0x2';
      } else {
        txData['gasPrice'] = '0x${gasPrice.toRadixString(16)}';
      }

      return MessageModel()
        ..error = false
        ..data = {
          'txData': txData,
          'rawData': data,
          'method': useBurnFunction ? 'burn' : 'safeTransferFrom',
        };
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取当前 nonce
  Future<int> getNonce(String rpcUrl, String address) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_getTransactionCount',
        'params': [address, 'pending'],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );

      if (response['result'] != null) {
        return _hexToBigInt(response['result'].toString()).toInt();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// 获取 Gas 价格
  Future<BigInt> getGasPrice(String rpcUrl) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_gasPrice',
        'params': [],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );

      if (response['result'] != null) {
        return _hexToBigInt(response['result'].toString());
      }
      return BigInt.from(5000000000); // 5 Gwei 默认
    } catch (e) {
      return BigInt.from(5000000000);
    }
  }

  /// 广播交易
  Future<MessageModel> broadcastTransaction(String rpcUrl, String signedTx) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_sendRawTransaction',
        'params': [signedTx],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );

      if (response['result'] != null) {
        return MessageModel()
          ..error = false
          ..data = response['result'].toString();
      } else if (response['error'] != null) {
        return MessageModel()
          ..error = true
          ..data = response['error']['message'] ?? 'Transaction failed';
      }

      return MessageModel.error()..data = 'Unknown error';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  // ============ Helper Methods ============

  /// 构建 ERC721 burn(uint256 tokenId) 调用数据
  String _buildErc721BurnData(String tokenId) {
    final tokenIdBigInt = BigInt.parse(tokenId);
    final tokenIdHex = _padLeft(tokenIdBigInt.toRadixString(16), 64);
    return '$erc721BurnSelector$tokenIdHex';
  }

  /// 构建 ERC721 transferFrom(address,address,uint256) 调用数据
  String _buildErc721TransferData(String from, String to, String tokenId) {
    final fromPadded = _padLeft(from.toLowerCase().replaceFirst('0x', ''), 64);
    final toPadded = _padLeft(to.toLowerCase().replaceFirst('0x', ''), 64);
    final tokenIdBigInt = BigInt.parse(tokenId);
    final tokenIdHex = _padLeft(tokenIdBigInt.toRadixString(16), 64);
    return '$erc721TransferFromSelector$fromPadded$toPadded$tokenIdHex';
  }

  /// 构建 ERC1155 burn(address,uint256,uint256) 调用数据
  String _buildErc1155BurnData(String account, String tokenId, BigInt amount) {
    final accountPadded = _padLeft(account.toLowerCase().replaceFirst('0x', ''), 64);
    final tokenIdBigInt = BigInt.parse(tokenId);
    final tokenIdHex = _padLeft(tokenIdBigInt.toRadixString(16), 64);
    final amountHex = _padLeft(amount.toRadixString(16), 64);
    return '$erc1155BurnSelector$accountPadded$tokenIdHex$amountHex';
  }

  /// 构建 ERC1155 safeTransferFrom(address,address,uint256,uint256,bytes) 调用数据
  String _buildErc1155TransferData(String from, String to, String tokenId, BigInt amount) {
    final fromPadded = _padLeft(from.toLowerCase().replaceFirst('0x', ''), 64);
    final toPadded = _padLeft(to.toLowerCase().replaceFirst('0x', ''), 64);
    final tokenIdBigInt = BigInt.parse(tokenId);
    final tokenIdHex = _padLeft(tokenIdBigInt.toRadixString(16), 64);
    final amountHex = _padLeft(amount.toRadixString(16), 64);
    // bytes data offset (160 = 5 * 32)
    final dataOffset = _padLeft('a0', 64);
    // bytes data length (0)
    final dataLength = _padLeft('0', 64);
    return '$erc1155SafeTransferFromSelector$fromPadded$toPadded$tokenIdHex$amountHex$dataOffset$dataLength';
  }

  String _padLeft(String str, int length) {
    return str.padLeft(length, '0');
  }

  BigInt _hexToBigInt(String hex) {
    if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    }
    if (hex.isEmpty) return BigInt.zero;
    return BigInt.parse(hex, radix: 16);
  }
}

/// NFT 销毁类型
enum NftBurnType {
  erc721,
  erc1155,
}

/// NFT 销毁请求
class NftBurnRequest {
  final String chainSymbol;
  final String contractAddress;
  final String ownerAddress;
  final String tokenId;
  final NftBurnType type;
  final BigInt? amount; // 仅 ERC1155 需要
  final String? tokenName;
  final String? tokenImage;

  NftBurnRequest({
    required this.chainSymbol,
    required this.contractAddress,
    required this.ownerAddress,
    required this.tokenId,
    required this.type,
    this.amount,
    this.tokenName,
    this.tokenImage,
  });
}

/// NFT 销毁结果
class NftBurnResult {
  final bool success;
  final String? txHash;
  final String? error;

  NftBurnResult({
    required this.success,
    this.txHash,
    this.error,
  });

  factory NftBurnResult.success(String txHash) {
    return NftBurnResult(success: true, txHash: txHash);
  }

  factory NftBurnResult.failure(String error) {
    return NftBurnResult(success: false, error: error);
  }
}
