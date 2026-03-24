// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';

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

  factory AddressValidationResult.valid(
    String address, {
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
    return AddressValidationResult(isValid: false, errorMessage: error);
  }
}

/// Address type enumeration
enum AddressType { standard, contract, ens, multisig }

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
    bool isValidFormat = await Trustdart().validateAddress(
      coinType,
      cleanAddress,
    );

    if (isValidFormat) {
      // Layer 3: Self-transfer prevention
      if (_isSelfTransfer(cleanAddress, senderAddress)) {
        return AddressValidationResult.invalid('Cannot transfer to yourself');
      }

      return AddressValidationResult.valid(
        cleanAddress,
        type: AddressType.standard,
      );
    }

    // Layer 4: ENS resolution (for EVM compatible chains if allowed)
    // N42 链优先，然后是 ETH 和其他 EVM 兼容链
    if (allowEns &&
        EnsService.chainSupportsEns(coinType) &&
        EnsService.isEnsName(address)) {
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

  /// 将域名解析为地址，按协议自动分发：
  ///   .n42  → N42 Name Service
  ///   .sol  → Solana Name Service (SNS)
  ///   UD 后缀 → Unstoppable Domains
  ///   其他  → ETH ENS
  ///
  /// [domainName] - 域名（如 alice.eth / alice.sol / alice.crypto）
  /// [coinType]   - 目标链（影响 UD 多链解析的 ticker 选择）
  Future<String?> _resolveEns(String domainName, String coinType) async {
    try {
      final protocol = EnsService.detectProtocol(domainName);

      switch (protocol) {
        case DomainProtocol.n42:
          return _extractResolved(
            await _tokenViewApi.getN42EnsResolve(domainName),
          );

        case DomainProtocol.sns:
          return _extractResolved(
            await _tokenViewApi.getSnsResolve(domainName),
          );

        case DomainProtocol.unstoppableDomains:
          final ticker = _coinTypeToUdTicker(coinType);
          return _extractResolved(
            await _tokenViewApi.getUdResolve(domainName, ticker: ticker),
          );

        case DomainProtocol.ens:
        case DomainProtocol.unknown:
          // N42 链时先尝试 N42 NS
          if (coinType == CoinType.N.name) {
            final n42Result = _extractResolved(
              await _tokenViewApi.getN42EnsResolve(domainName),
            );
            if (n42Result != null) return n42Result;
          }
          return _extractResolved(
            await _tokenViewApi.getEnsResolve(domainName),
          );
      }
    } catch (_) {
      return null;
    }
  }

  /// 从 API 结果中提取已解析的地址，若失败则返回 null
  static String? _extractResolved(dynamic r) {
    if (!r.error && r.data != null) return r.data as String;
    return null;
  }

  /// 将 coinType 映射到 UD ticker（UD 多链记录中使用）
  static String? _coinTypeToUdTicker(String coinType) {
    const map = {
      'ETH': 'ETH',
      'N': 'ETH',
      'BNB': 'BNB',
      'MATIC': 'MATIC',
      'AVAX': 'AVAX',
      'FTM': 'FTM',
      'OP': 'ETH',
      'ARB': 'ETH',
      'SOL': 'SOL',
      'BTC': 'BTC',
      'TRX': 'TRX',
      'XRP': 'XRP',
    };
    return map[coinType.toUpperCase()];
  }

  /// Generate address preview for UI display
  ///
  /// Returns format like "0x1234...5678"
  static String getAddressPreview(
    String address, {
    int prefixLength = 6,
    int suffixLength = 4,
  }) {
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
