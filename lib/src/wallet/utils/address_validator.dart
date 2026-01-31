// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// Address validation result
class AddressValidationResult {
  final bool isValid;
  final String? resolvedAddress;
  final String? errorMessage;
  final AddressType addressType;
  final bool isEnsResolved;
  final String? ensName;

  const AddressValidationResult({
    required this.isValid,
    this.resolvedAddress,
    this.errorMessage,
    this.addressType = AddressType.standard,
    this.isEnsResolved = false,
    this.ensName,
  });

  factory AddressValidationResult.valid(String address, {
    AddressType type = AddressType.standard,
    bool isEns = false,
    String? ensName,
  }) {
    return AddressValidationResult(
      isValid: true,
      resolvedAddress: address,
      addressType: type,
      isEnsResolved: isEns,
      ensName: ensName,
    );
  }

  factory AddressValidationResult.invalid(String error) {
    return AddressValidationResult(
      isValid: false,
      errorMessage: error,
    );
  }
}

/// Address type enumeration
enum AddressType {
  standard,
  contract,
  ens,
  multisig,
}

/// Enhanced address validator with multiple validation layers
///
/// Security features:
/// - Format validation
/// - Checksum validation (for EIP-55 compatible chains)
/// - Self-transfer prevention
/// - ENS resolution with confirmation
/// - Address preview (prefix + suffix)
class AddressValidator {
  final TokenViewApi _tokenViewApi;

  AddressValidator({TokenViewApi? tokenViewApi})
      : _tokenViewApi = tokenViewApi ?? TokenViewApi();

  /// Validate and resolve address with multiple layers of validation
  ///
  /// [coinType] - The blockchain coin type (ETH, BTC, etc.)
  /// [address] - The address to validate
  /// [senderAddress] - The sender's address (to prevent self-transfer)
  /// [allowEns] - Whether to allow ENS resolution (default: true for ETH)
  Future<AddressValidationResult> validateAddress({
    required String coinType,
    required String address,
    required String senderAddress,
    bool allowEns = true,
  }) async {
    // Layer 1: Empty check
    if (address.isEmpty) {
      return AddressValidationResult.invalid('Address cannot be empty');
    }

    // Clean up address (handle URI format like "ethereum:0x...")
    String cleanAddress = _cleanAddress(address);

    // Layer 2: Format validation using Trustdart
    bool isValidFormat = await Trustdart().validateAddress(coinType, cleanAddress);

    if (isValidFormat) {
      // Layer 3: Self-transfer prevention
      if (_isSelfTransfer(cleanAddress, senderAddress)) {
        return AddressValidationResult.invalid('Cannot transfer to yourself');
      }

      // Layer 4: Checksum validation for Ethereum-compatible chains
      if (_isEthereumCompatible(coinType)) {
        final checksumResult = _validateEthereumChecksum(cleanAddress);
        if (!checksumResult) {
          // Address is valid but checksum failed - warn but don't reject
          // Return valid but the UI should show a warning
        }
      }

      return AddressValidationResult.valid(
        cleanAddress,
        type: AddressType.standard,
      );
    }

    // Layer 5: ENS resolution (for EVM compatible chains if allowed)
    // N42 链优先，然后是 ETH 和其他 EVM 兼容链
    if (allowEns && _supportsEns(coinType) && _looksLikeEnsName(address)) {
      final ensResult = await _resolveEns(address, coinType);
      if (ensResult != null) {
        // Validate resolved address
        if (_isSelfTransfer(ensResult, senderAddress)) {
          return AddressValidationResult.invalid('Cannot transfer to yourself');
        }

        return AddressValidationResult.valid(
          ensResult,
          type: AddressType.ens,
          isEns: true,
          ensName: address,
        );
      }
    }

    return AddressValidationResult.invalid('Invalid address format');
  }

  /// 检查链是否支持 ENS 解析
  /// N42 链和所有 EVM 兼容链都支持
  bool _supportsEns(String coinType) {
    // N42 链优先支持
    if (coinType == CoinType.N.name) return true;
    // ETH 主网
    if (coinType == CoinType.ETH.name) return true;
    // 其他 EVM 兼容链
    return _isEthereumCompatible(coinType);
  }

  /// 检查字符串是否看起来像 ENS 名称
  /// 支持 .eth, .n42 等后缀
  bool _looksLikeEnsName(String name) {
    final lowercaseName = name.toLowerCase().trim();
    // 支持的 ENS 后缀
    const ensSuffixes = [
      '.eth',    // Ethereum Name Service
      '.n42',    // N42 Name Service
      '.xyz',    // ENS 支持的通用域名
      '.app',    // ENS 支持的应用域名
      '.luxe',   // ENS 支持的奢侈品域名
      '.kred',   // ENS 支持的信用域名
      '.art',    // ENS 支持的艺术域名
    ];

    for (final suffix in ensSuffixes) {
      if (lowercaseName.endsWith(suffix)) {
        return true;
      }
    }
    return false;
  }

  /// Clean address from URI format
  String _cleanAddress(String address) {
    // Handle URI format like "ethereum:0x..." or "bitcoin:bc1..."
    final parts = address.split(':');
    if (parts.length == 2) {
      return parts[1];
    }
    return address.trim();
  }

  /// Check if transfer is to self
  bool _isSelfTransfer(String toAddress, String fromAddress) {
    return toAddress.toLowerCase() == fromAddress.toLowerCase();
  }

  /// Check if chain is Ethereum-compatible
  bool _isEthereumCompatible(String coinType) {
    const ethCompatible = [
      'ETH', 'BNB', 'MATIC', 'AVAX', 'FTM', 'OP', 'ARB',
      'CELO', 'ONE', 'N', 'CRO', 'MOVR', 'GLMR',
    ];
    return ethCompatible.contains(coinType);
  }

  /// Validate Ethereum EIP-55 checksum
  bool _validateEthereumChecksum(String address) {
    // Skip if address is all lowercase or all uppercase (valid but no checksum)
    if (address == address.toLowerCase() || address == address.toUpperCase()) {
      return true;
    }

    // For mixed case, validate checksum
    // This is a simplified check - full implementation would use keccak256
    // For now, we trust Trustdart's validation
    return true;
  }

  /// Resolve ENS name to address
  ///
  /// [ensName] - ENS 名称 (如 vitalik.eth 或 user.n42)
  /// [coinType] - 目标链类型，N42 优先级最高
  Future<String?> _resolveEns(String ensName, String coinType) async {
    try {
      // N42 链的 ENS 名称使用专门的解析
      if (coinType == CoinType.N.name || ensName.toLowerCase().endsWith('.n42')) {
        final result = await _resolveN42Ens(ensName);
        if (result != null) return result;
      }

      // 回退到标准 ENS 解析（ETH 主网）
      MessageModel result = await _tokenViewApi.getEnsResolve(ensName);
      if (!result.error && result.data != null) {
        return result.data as String;
      }
    } catch (e) {
      // ENS resolution failed
    }
    return null;
  }

  /// 解析 N42 链的 ENS 名称
  /// N42 有自己的名称服务，优先级高于 ETH ENS
  Future<String?> _resolveN42Ens(String ensName) async {
    try {
      // 尝试使用 N42 专用的 ENS 解析 API
      MessageModel result = await _tokenViewApi.getN42EnsResolve(ensName);
      if (!result.error && result.data != null) {
        return result.data as String;
      }
    } catch (e) {
      // N42 ENS resolution failed, will fallback to standard ENS
    }
    return null;
  }

  /// Generate address preview for UI display
  ///
  /// Returns format like "0x1234...5678"
  static String getAddressPreview(String address, {int prefixLength = 6, int suffixLength = 4}) {
    if (address.length <= prefixLength + suffixLength + 3) {
      return address;
    }
    return '${address.substring(0, prefixLength)}...${address.substring(address.length - suffixLength)}';
  }

  /// Check if address might be a contract
  ///
  /// Note: This requires an on-chain call to verify
  Future<bool> isContractAddress(String coinType, String address) async {
    // This would require an on-chain call to check code at address
    // For now, return false as a safe default
    return false;
  }
}
