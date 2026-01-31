// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/crypto.dart';

import '../../core/aa_config.dart';
import '../../core/aa_constants.dart';
import '../../models/smart_account.dart';
import '../../builder/calldata_builder.dart';

/// SimpleAccount implementation from eth-infinitism
///
/// This is the reference implementation of an ERC-4337 smart account.
/// It provides basic functionality:
/// - Single owner
/// - Execute single and batch transactions
/// - Deposit and withdraw from EntryPoint
class SimpleAccountHelper {
  /// Factory address for SimpleAccount
  final String factoryAddress;

  /// EntryPoint address
  final String entryPointAddress;

  SimpleAccountHelper({
    required this.factoryAddress,
    required this.entryPointAddress,
  });

  /// Create from chain configuration
  factory SimpleAccountHelper.fromChain(String chainSymbol) {
    final config = AAConfig.getChainConfig(chainSymbol);
    if (config == null) {
      throw ArgumentError('Unsupported chain: $chainSymbol');
    }
    return SimpleAccountHelper(
      factoryAddress: config.simpleAccountFactory,
      entryPointAddress: config.entryPoint,
    );
  }

  /// Calculate the counterfactual address for a SimpleAccount
  ///
  /// This uses the CREATE2 formula with the factory's init code.
  String calculateAddress({
    required String owner,
    required BigInt salt,
  }) {
    // The address is calculated as:
    // CREATE2(factory, salt, keccak256(initCode))
    // where initCode = proxy creation code + implementation address + owner

    // Simplified calculation matching SimpleAccountFactory.getAddress
    final ownerBytes = _addressToBytes32(owner);
    final saltBytes = _bigIntToBytes32(salt);

    // Create the salt used by the factory
    // SimpleAccountFactory uses: keccak256(abi.encodePacked(owner, salt))
    final combinedSalt = Uint8List(64);
    combinedSalt.setAll(0, ownerBytes);
    combinedSalt.setAll(32, saltBytes);
    final hashedSalt = keccak256(combinedSalt);

    // CREATE2 address calculation
    // address = keccak256(0xff ++ factory ++ salt ++ initCodeHash)[12:]
    final factoryBytes = hexToBytes(factoryAddress.replaceFirst('0x', ''));

    // This is the init code hash for SimpleAccount proxy
    // In production, this should be fetched from the factory or computed from bytecode
    final initCodeHash = _getProxyInitCodeHash(owner);

    final data = Uint8List(85);
    data[0] = 0xff;
    data.setAll(1, factoryBytes);
    data.setAll(21, hashedSalt);
    data.setAll(53, initCodeHash);

    final addressHash = keccak256(data);
    return '0x${bytesToHex(addressHash.sublist(12))}';
  }

  /// Get the init code for first-time deployment
  Uint8List getInitCode({
    required String owner,
    required BigInt salt,
  }) {
    return CalldataBuilder.buildSimpleAccountInitCode(
      factoryAddress: factoryAddress,
      owner: owner,
      salt: salt,
    );
  }

  /// Build execute call data
  Uint8List buildExecute({
    required String target,
    required BigInt value,
    required Uint8List data,
  }) {
    return CalldataBuilder.buildExecute(
      target: target,
      value: value,
      data: data,
    );
  }

  /// Build executeBatch call data
  Uint8List buildExecuteBatch(List<ExecuteCall> calls) {
    return CalldataBuilder.buildExecuteBatch(calls);
  }

  /// Build deposit call data (add funds to account's deposit in EntryPoint)
  Uint8List buildAddDeposit() {
    // addDeposit() has no parameters
    // Function selector: 0x4a58db19
    return hexToBytes('4a58db19');
  }

  /// Build withdraw deposit call data
  Uint8List buildWithdrawDepositTo({
    required String withdrawAddress,
    required BigInt amount,
  }) {
    // withdrawDepositTo(address,uint256)
    // Function selector: 0x4d44560d
    final selector = hexToBytes('4d44560d');
    final addressEncoded = _addressToBytes32(withdrawAddress);
    final amountEncoded = _bigIntToBytes32(amount);

    final result = Uint8List(4 + 64);
    result.setAll(0, selector);
    result.setAll(4, addressEncoded);
    result.setAll(36, amountEncoded);

    return result;
  }

  /// Create a SmartAccount model
  SmartAccount createAccount({
    required String owner,
    BigInt? salt,
    String? label,
    int? chainId,
  }) {
    final accountSalt = salt ?? BigInt.zero;
    final address = calculateAddress(owner: owner, salt: accountSalt);

    final config = AAConfig.getChainConfig('ETH'); // Default to ETH
    final cid = chainId ?? config?.chainId ?? 1;

    return SmartAccount(
      address: address,
      type: SmartAccountType.simpleAccount,
      ownerAddress: owner,
      state: SmartAccountState.notDeployed,
      chainId: cid,
      salt: accountSalt,
      factoryAddress: factoryAddress,
      createdAt: DateTime.now(),
      label: label,
    );
  }

  // Helper methods

  Uint8List _addressToBytes32(String address) {
    final bytes = Uint8List(32);
    final addrBytes = hexToBytes(address.replaceFirst('0x', '').padLeft(40, '0'));
    bytes.setAll(12, addrBytes);
    return bytes;
  }

  Uint8List _bigIntToBytes32(BigInt value) {
    final bytes = Uint8List(32);
    final valueBytes = intToBytes(value);
    if (valueBytes.isNotEmpty && valueBytes.length <= 32) {
      bytes.setAll(32 - valueBytes.length, valueBytes);
    }
    return bytes;
  }

  Uint8List _getProxyInitCodeHash(String owner) {
    // This should be the keccak256 of the actual init code
    // For eth-infinitism SimpleAccountFactory, this is:
    // keccak256(type(ERC1967Proxy).creationCode ++ abi.encode(implementation, data))

    // Placeholder - in production, compute from actual bytecode
    // This varies based on the specific factory version
    return Uint8List(32);
  }
}

/// SimpleAccount function selectors
class SimpleAccountSelectors {
  SimpleAccountSelectors._();

  /// execute(address,uint256,bytes)
  static const String execute = '0xb61d27f6';

  /// executeBatch(address[],uint256[],bytes[])
  static const String executeBatch = '0x47e1da2a';

  /// addDeposit()
  static const String addDeposit = '0x4a58db19';

  /// withdrawDepositTo(address,uint256)
  static const String withdrawDepositTo = '0x4d44560d';

  /// getDeposit()
  static const String getDeposit = '0xc399ec88';

  /// owner()
  static const String owner = '0x8da5cb5b';

  /// entryPoint()
  static const String entryPoint = '0xb0d691fe';
}

/// SimpleAccount validation modes
enum SimpleAccountValidationMode {
  /// Owner signature validation
  ownerSignature,

  /// Session key validation (if supported)
  sessionKey,

  /// Passkey validation (if supported)
  passkey,
}

/// Gas constants for SimpleAccount operations
class SimpleAccountGasConstants {
  SimpleAccountGasConstants._();

  /// Gas for signature validation
  static const int signatureValidation = 50000;

  /// Gas for execute call overhead
  static const int executeOverhead = 30000;

  /// Gas for executeBatch per call
  static const int executeBatchPerCall = 25000;

  /// Additional gas for first transaction (deployment)
  static const int deploymentGas = AAConstants.accountDeploymentGas;

  /// Estimate gas for execute
  static BigInt estimateExecuteGas(int callDataLength) {
    return BigInt.from(executeOverhead + (callDataLength ~/ 16) * 68);
  }

  /// Estimate gas for executeBatch
  static BigInt estimateBatchGas(List<ExecuteCall> calls) {
    var total = executeOverhead;
    for (final call in calls) {
      total += executeBatchPerCall + (call.data.length ~/ 16) * 68;
    }
    return BigInt.from(total);
  }
}
