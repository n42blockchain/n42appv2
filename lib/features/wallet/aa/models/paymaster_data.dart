// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

/// Paymaster types supported
enum PaymasterType {
  /// Verifying paymaster with off-chain signature
  verifying,

  /// ERC20 token paymaster
  erc20,

  /// Sponsorship paymaster (fully sponsored)
  sponsorship,

  /// Custom paymaster implementation
  custom,
}

/// Paymaster configuration and data
class PaymasterData {
  /// Paymaster contract address
  final String paymasterAddress;

  /// Type of paymaster
  final PaymasterType type;

  /// Verification data (signature, timestamp, etc.)
  final Uint8List? verificationData;

  /// Post-operation data
  final Uint8List? postOpData;

  /// Token address for ERC20 paymasters
  final String? tokenAddress;

  /// Maximum token amount to pay
  final BigInt? maxTokenAmount;

  /// Exchange rate (tokens per gas unit)
  final BigInt? exchangeRate;

  /// Validity period (validUntil, validAfter)
  final PaymasterValidity? validity;

  /// Sponsor name for display
  final String? sponsorName;

  /// Sponsor icon URL
  final String? sponsorIcon;

  PaymasterData({
    required this.paymasterAddress,
    required this.type,
    this.verificationData,
    this.postOpData,
    this.tokenAddress,
    this.maxTokenAmount,
    this.exchangeRate,
    this.validity,
    this.sponsorName,
    this.sponsorIcon,
  });

  /// Pack paymaster data for UserOperation
  Uint8List pack() {
    final addressBytes = hexToBytes(
      paymasterAddress.replaceFirst('0x', '').padLeft(40, '0'),
    );

    final verification = verificationData ?? Uint8List(0);
    final postOp = postOpData ?? Uint8List(0);

    // Format: paymaster address (20 bytes) + verification data + post-op data
    final packed = Uint8List(20 + verification.length + postOp.length);
    packed.setAll(0, addressBytes);
    packed.setAll(20, verification);
    packed.setAll(20 + verification.length, postOp);

    return packed;
  }

  /// Create from packed paymasterAndData bytes
  factory PaymasterData.fromPacked(Uint8List packed) {
    if (packed.isEmpty) {
      throw ArgumentError('Packed paymaster data cannot be empty');
    }

    if (packed.length < 20) {
      throw ArgumentError('Packed data too short for paymaster address');
    }

    final address = '0x${bytesToHex(packed.sublist(0, 20))}';
    final data = packed.length > 20 ? packed.sublist(20) : null;

    return PaymasterData(
      paymasterAddress: address,
      type: PaymasterType.custom,
      verificationData: data,
    );
  }

  factory PaymasterData.fromJson(Map<String, dynamic> json) {
    return PaymasterData(
      paymasterAddress: json['paymasterAddress'] as String,
      type: PaymasterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymasterType.custom,
      ),
      verificationData: _parseHexBytes(json['verificationData'] as String?),
      postOpData: _parseHexBytes(json['postOpData'] as String?),
      tokenAddress: json['tokenAddress'] as String?,
      maxTokenAmount: json['maxTokenAmount'] != null
          ? BigInt.parse(json['maxTokenAmount'] as String)
          : null,
      exchangeRate: json['exchangeRate'] != null
          ? BigInt.parse(json['exchangeRate'] as String)
          : null,
      validity: json['validity'] != null
          ? PaymasterValidity.fromJson(json['validity'] as Map<String, dynamic>)
          : null,
      sponsorName: json['sponsorName'] as String?,
      sponsorIcon: json['sponsorIcon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymasterAddress': paymasterAddress,
      'type': type.name,
      'verificationData': verificationData != null
          ? '0x${bytesToHex(verificationData!)}'
          : null,
      'postOpData': postOpData != null ? '0x${bytesToHex(postOpData!)}' : null,
      'tokenAddress': tokenAddress,
      'maxTokenAmount': maxTokenAmount?.toString(),
      'exchangeRate': exchangeRate?.toString(),
      'validity': validity?.toJson(),
      'sponsorName': sponsorName,
      'sponsorIcon': sponsorIcon,
    };
  }

  static Uint8List? _parseHexBytes(String? hex) {
    if (hex == null || hex == '0x' || hex.isEmpty) return null;
    return hexToBytes(hex.replaceFirst('0x', ''));
  }

  /// Check if paymaster data is valid (not expired)
  bool get isValid {
    if (validity == null) return true;
    return validity!.isValid;
  }

  /// Get display info for UI
  String get displayInfo {
    switch (type) {
      case PaymasterType.sponsorship:
        return sponsorName ?? 'Sponsored';
      case PaymasterType.erc20:
        return 'Pay with Token';
      case PaymasterType.verifying:
        return 'Verified Paymaster';
      case PaymasterType.custom:
        return 'Custom Paymaster';
    }
  }

  @override
  String toString() {
    return 'PaymasterData(address: $paymasterAddress, type: ${type.name})';
  }
}

/// Paymaster validity period
class PaymasterValidity {
  /// Valid after this timestamp (Unix seconds)
  final int validAfter;

  /// Valid until this timestamp (Unix seconds)
  final int validUntil;

  const PaymasterValidity({required this.validAfter, required this.validUntil});

  /// Check if currently valid
  bool get isValid {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= validAfter && now <= validUntil;
  }

  /// Time remaining until expiry in seconds
  int get remainingTime {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return validUntil - now;
  }

  /// Check if expired
  bool get isExpired => remainingTime <= 0;

  factory PaymasterValidity.fromJson(Map<String, dynamic> json) {
    return PaymasterValidity(
      validAfter: json['validAfter'] as int,
      validUntil: json['validUntil'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'validAfter': validAfter, 'validUntil': validUntil};
  }

  /// Create validity for a duration from now
  factory PaymasterValidity.forDuration(Duration duration) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return PaymasterValidity(
      validAfter: now,
      validUntil: now + duration.inSeconds,
    );
  }
}

/// ERC20 token info for paymaster
class PaymasterTokenInfo {
  /// Token contract address
  final String address;

  /// Token symbol
  final String symbol;

  /// Token decimals
  final int decimals;

  /// Current exchange rate (token amount per gas unit)
  final BigInt exchangeRate;

  /// Maximum gas that can be paid with this token
  final BigInt? maxGasAmount;

  const PaymasterTokenInfo({
    required this.address,
    required this.symbol,
    required this.decimals,
    required this.exchangeRate,
    this.maxGasAmount,
  });

  /// Calculate token amount for given gas amount
  BigInt calculateTokenAmount(BigInt gasAmount, BigInt gasPrice) {
    return gasAmount * gasPrice * exchangeRate ~/ BigInt.from(10).pow(18);
  }

  factory PaymasterTokenInfo.fromJson(Map<String, dynamic> json) {
    return PaymasterTokenInfo(
      address: json['address'] as String,
      symbol: json['symbol'] as String,
      decimals: json['decimals'] as int,
      exchangeRate: BigInt.parse(json['exchangeRate'] as String),
      maxGasAmount: json['maxGasAmount'] != null
          ? BigInt.parse(json['maxGasAmount'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'symbol': symbol,
      'decimals': decimals,
      'exchangeRate': exchangeRate.toString(),
      'maxGasAmount': maxGasAmount?.toString(),
    };
  }
}

/// Paymaster quote response from API
class PaymasterQuote {
  /// Paymaster data to use
  final PaymasterData paymasterData;

  /// Estimated gas cost in native token
  final BigInt estimatedGasCost;

  /// Estimated cost in paymaster token (for ERC20 paymaster)
  final BigInt? tokenCost;

  /// Token info if ERC20 paymaster
  final PaymasterTokenInfo? tokenInfo;

  /// Whether this quote is sponsored (free for user)
  final bool isSponsored;

  /// Quote expiry timestamp
  final DateTime expiresAt;

  const PaymasterQuote({
    required this.paymasterData,
    required this.estimatedGasCost,
    this.tokenCost,
    this.tokenInfo,
    this.isSponsored = false,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory PaymasterQuote.fromJson(Map<String, dynamic> json) {
    return PaymasterQuote(
      paymasterData: PaymasterData.fromJson(
        json['paymasterData'] as Map<String, dynamic>,
      ),
      estimatedGasCost: BigInt.parse(json['estimatedGasCost'] as String),
      tokenCost: json['tokenCost'] != null
          ? BigInt.parse(json['tokenCost'] as String)
          : null,
      tokenInfo: json['tokenInfo'] != null
          ? PaymasterTokenInfo.fromJson(
              json['tokenInfo'] as Map<String, dynamic>,
            )
          : null,
      isSponsored: json['isSponsored'] as bool? ?? false,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymasterData': paymasterData.toJson(),
      'estimatedGasCost': estimatedGasCost.toString(),
      'tokenCost': tokenCost?.toString(),
      'tokenInfo': tokenInfo?.toJson(),
      'isSponsored': isSponsored,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
