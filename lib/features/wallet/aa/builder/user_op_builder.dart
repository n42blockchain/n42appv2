// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

import '../core/aa_constants.dart';
import '../core/aa_errors.dart';
import '../models/user_operation.dart';
import '../models/smart_account.dart';
import '../models/paymaster_data.dart';
import 'calldata_builder.dart';

/// Builder for constructing UserOperations
///
/// Provides a fluent API for building UserOperations with proper
/// validation and encoding.
///
/// Supports both v0.7 and v0.8 EntryPoint specifications,
/// including EIP-7702 authorization for v0.8.
class UserOpBuilder {
  String? _sender;
  BigInt? _nonce;
  Uint8List? _initCode;
  Uint8List? _callData;
  BigInt _verificationGasLimit = BigInt.from(AAConstants.defaultVerificationGasLimit);
  BigInt _callGasLimit = BigInt.from(AAConstants.defaultCallGasLimit);
  BigInt _preVerificationGas = BigInt.from(AAConstants.defaultPreVerificationGas);
  BigInt _maxPriorityFeePerGas = BigInt.zero;
  BigInt _maxFeePerGas = BigInt.zero;
  Uint8List? _paymasterAndData;
  Uint8List? _signature;
  Uint8List? _eip7702Auth;

  /// Create a new UserOpBuilder
  UserOpBuilder();

  /// Create builder from existing UserOperation
  factory UserOpBuilder.fromUserOp(UserOperation userOp) {
    return UserOpBuilder()
      ..setSender(userOp.sender)
      ..setNonce(userOp.nonce)
      ..setInitCode(userOp.initCode)
      ..setCallData(userOp.callData)
      ..setGasLimits(
        verificationGasLimit: userOp.verificationGasLimit,
        callGasLimit: userOp.callGasLimit,
      )
      ..setPreVerificationGas(userOp.preVerificationGas)
      ..setGasFees(
        maxPriorityFeePerGas: userOp.maxPriorityFeePerGas,
        maxFeePerGas: userOp.maxFeePerGas,
      )
      ..setPaymasterAndData(userOp.paymasterAndData)
      ..setSignature(userOp.signature)
      ..setEIP7702Auth(userOp.eip7702Auth);
  }

  /// Set the sender (smart account) address
  UserOpBuilder setSender(String sender) {
    _sender = sender.toLowerCase();
    return this;
  }

  /// Set sender from SmartAccount
  UserOpBuilder setSenderFromAccount(SmartAccount account) {
    _sender = account.address.toLowerCase();
    return this;
  }

  /// Set the nonce
  UserOpBuilder setNonce(BigInt nonce) {
    _nonce = nonce;
    return this;
  }

  /// Set the init code for account deployment
  UserOpBuilder setInitCode(Uint8List? initCode) {
    _initCode = initCode;
    return this;
  }

  /// Set init code from factory address and call data
  UserOpBuilder setInitCodeFromFactory(String factoryAddress, Uint8List factoryCallData) {
    final factoryBytes = hexToBytes(factoryAddress.replaceFirst('0x', ''));
    _initCode = Uint8List(factoryBytes.length + factoryCallData.length);
    _initCode!.setAll(0, factoryBytes);
    _initCode!.setAll(factoryBytes.length, factoryCallData);
    return this;
  }

  /// Set the call data
  UserOpBuilder setCallData(Uint8List callData) {
    _callData = callData;
    return this;
  }

  /// Set call data for a simple ETH transfer
  UserOpBuilder setEthTransfer(String to, BigInt value) {
    _callData = CalldataBuilder.buildExecute(
      target: to,
      value: value,
      data: Uint8List(0),
    );
    return this;
  }

  /// Set call data for an ERC20 transfer
  UserOpBuilder setErc20Transfer({
    required String tokenAddress,
    required String to,
    required BigInt amount,
  }) {
    final transferData = CalldataBuilder.buildErc20Transfer(to: to, amount: amount);
    _callData = CalldataBuilder.buildExecute(
      target: tokenAddress,
      value: BigInt.zero,
      data: transferData,
    );
    return this;
  }

  /// Set call data for a batch of operations
  UserOpBuilder setBatchOperations(List<ExecuteCall> calls) {
    _callData = CalldataBuilder.buildExecuteBatch(calls);
    return this;
  }

  /// Set verification and call gas limits
  UserOpBuilder setGasLimits({
    BigInt? verificationGasLimit,
    BigInt? callGasLimit,
  }) {
    if (verificationGasLimit != null) {
      _verificationGasLimit = verificationGasLimit;
    }
    if (callGasLimit != null) {
      _callGasLimit = callGasLimit;
    }
    return this;
  }

  /// Set pre-verification gas
  UserOpBuilder setPreVerificationGas(BigInt preVerificationGas) {
    _preVerificationGas = preVerificationGas;
    return this;
  }

  /// Set gas fees (EIP-1559 style)
  UserOpBuilder setGasFees({
    required BigInt maxPriorityFeePerGas,
    required BigInt maxFeePerGas,
  }) {
    _maxPriorityFeePerGas = maxPriorityFeePerGas;
    _maxFeePerGas = maxFeePerGas;
    return this;
  }

  /// Set gas fees from gas price (legacy style)
  UserOpBuilder setGasPrice(BigInt gasPrice) {
    _maxPriorityFeePerGas = gasPrice;
    _maxFeePerGas = gasPrice;
    return this;
  }

  /// Set paymaster and data
  UserOpBuilder setPaymasterAndData(Uint8List? paymasterAndData) {
    _paymasterAndData = paymasterAndData;
    return this;
  }

  /// Set paymaster from PaymasterData
  UserOpBuilder setPaymaster(PaymasterData paymaster) {
    _paymasterAndData = paymaster.pack();
    return this;
  }

  /// Set the signature
  UserOpBuilder setSignature(Uint8List? signature) {
    _signature = signature;
    return this;
  }

  /// Set a dummy signature for gas estimation
  UserOpBuilder setDummySignature() {
    _signature = AAConstants.dummySignature;
    return this;
  }

  /// Set EIP-7702 authorization data (v0.8 only)
  ///
  /// This allows an EOA to temporarily delegate execution to a
  /// smart account implementation.
  UserOpBuilder setEIP7702Auth(Uint8List? authData) {
    _eip7702Auth = authData;
    return this;
  }

  /// Check if this builder is configured for EIP-7702
  bool get hasEIP7702Auth => _eip7702Auth != null && _eip7702Auth!.isNotEmpty;

  /// Apply a gas buffer multiplier to all gas fields
  UserOpBuilder applyGasBuffer(double multiplier) {
    final scale = BigInt.from((multiplier * 100).round());
    final hundred = BigInt.from(100);
    _verificationGasLimit = (_verificationGasLimit * scale) ~/ hundred;
    _callGasLimit = (_callGasLimit * scale) ~/ hundred;
    _preVerificationGas = (_preVerificationGas * scale) ~/ hundred;
    return this;
  }

  /// Validate required fields shared by build() and buildForEstimation()
  void _validateCore({String suffix = ''}) {
    final label = suffix.isEmpty ? '' : ' $suffix';
    if (_sender == null || _sender!.isEmpty) {
      throw UserOperationBuildError('Sender address is required$label');
    }
    if (_nonce == null) {
      throw UserOperationBuildError('Nonce is required$label');
    }
    if (_callData == null || _callData!.isEmpty) {
      throw UserOperationBuildError('Call data is required$label');
    }
  }

  /// Validate the builder state before building
  void _validate() {
    _validateCore();
    if (_maxFeePerGas == BigInt.zero) {
      throw UserOperationBuildError('Gas fees are required');
    }
    if (_callData!.length > AAConstants.maxCalldataSize) {
      throw UserOperationBuildError(
        'Call data exceeds maximum size',
        details: 'Max: ${AAConstants.maxCalldataSize}, Got: ${_callData!.length}',
      );
    }
  }

  /// Build the UserOperation
  UserOperation build() {
    _validate();

    return UserOperation(
      sender: _sender!,
      nonce: _nonce!,
      initCode: _initCode,
      callData: _callData!,
      accountGasLimits: PackedGasLimits.pack(_verificationGasLimit, _callGasLimit),
      preVerificationGas: _preVerificationGas,
      gasFees: PackedGasFees.pack(_maxPriorityFeePerGas, _maxFeePerGas),
      paymasterAndData: _paymasterAndData,
      signature: _signature,
      eip7702Auth: _eip7702Auth,
    );
  }

  /// Build UserOperation for gas estimation (with dummy signature).
  ///
  /// Unlike [build], this method:
  /// 1. Does **not** require gas fees to be set — estimation is the step that
  ///    determines those values, so requiring them would be circular.
  /// 2. Temporarily injects [AAConstants.dummySignature] without mutating the
  ///    builder's persistent state.  After this call, [build] will still use
  ///    the signature that was set before (or null if none was set).
  ///
  /// The caller must have set sender, nonce, and callData before calling this.
  UserOperation buildForEstimation() {
    // Minimal validation — gas fees are intentionally excluded.
    _validateCore(suffix: 'for estimation');

    // Temporarily replace signature without permanently mutating builder state.
    final savedSignature = _signature;
    _signature = AAConstants.dummySignature;
    try {
      // Inline UserOperation construction — avoids calling build() which
      // would enforce the _maxFeePerGas != 0 invariant (not yet known).
      return UserOperation(
        sender: _sender!,
        nonce: _nonce!,
        initCode: _initCode,
        callData: _callData!,
        accountGasLimits: PackedGasLimits.pack(_verificationGasLimit, _callGasLimit),
        preVerificationGas: _preVerificationGas,
        gasFees: PackedGasFees.pack(_maxPriorityFeePerGas, _maxFeePerGas),
        paymasterAndData: _paymasterAndData,
        signature: _signature,
        eip7702Auth: _eip7702Auth,
      );
    } finally {
      // Always restore — even if UserOperation constructor throws.
      _signature = savedSignature;
    }
  }

  /// Get estimated total gas
  BigInt get estimatedTotalGas {
    return _verificationGasLimit + _callGasLimit + _preVerificationGas;
  }

  /// Get estimated gas cost
  BigInt get estimatedGasCost {
    return estimatedTotalGas * _maxFeePerGas;
  }
}

/// Builder for creating UserOperations for specific use cases
class UserOpFactory {
  /// Create a UserOperation for ETH transfer
  static UserOpBuilder ethTransfer({
    required SmartAccount account,
    required BigInt nonce,
    required String to,
    required BigInt value,
    required BigInt maxFeePerGas,
    required BigInt maxPriorityFeePerGas,
    Uint8List? initCode,
  }) {
    return UserOpBuilder()
      ..setSenderFromAccount(account)
      ..setNonce(nonce)
      ..setInitCode(initCode)
      ..setEthTransfer(to, value)
      ..setGasFees(
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
      );
  }

  /// Create a UserOperation for ERC20 transfer
  static UserOpBuilder erc20Transfer({
    required SmartAccount account,
    required BigInt nonce,
    required String tokenAddress,
    required String to,
    required BigInt amount,
    required BigInt maxFeePerGas,
    required BigInt maxPriorityFeePerGas,
    Uint8List? initCode,
  }) {
    return UserOpBuilder()
      ..setSenderFromAccount(account)
      ..setNonce(nonce)
      ..setInitCode(initCode)
      ..setErc20Transfer(
        tokenAddress: tokenAddress,
        to: to,
        amount: amount,
      )
      ..setGasFees(
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
      );
  }

  /// Create a UserOperation for batch transactions
  static UserOpBuilder batchTransfer({
    required SmartAccount account,
    required BigInt nonce,
    required List<ExecuteCall> calls,
    required BigInt maxFeePerGas,
    required BigInt maxPriorityFeePerGas,
    Uint8List? initCode,
  }) {
    return UserOpBuilder()
      ..setSenderFromAccount(account)
      ..setNonce(nonce)
      ..setInitCode(initCode)
      ..setBatchOperations(calls)
      ..setGasFees(
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
      );
  }

  /// Create a UserOperation for contract interaction
  static UserOpBuilder contractCall({
    required SmartAccount account,
    required BigInt nonce,
    required String contractAddress,
    required Uint8List callData,
    BigInt? value,
    required BigInt maxFeePerGas,
    required BigInt maxPriorityFeePerGas,
    Uint8List? initCode,
  }) {
    final executeData = CalldataBuilder.buildExecute(
      target: contractAddress,
      value: value ?? BigInt.zero,
      data: callData,
    );

    return UserOpBuilder()
      ..setSenderFromAccount(account)
      ..setNonce(nonce)
      ..setInitCode(initCode)
      ..setCallData(executeData)
      ..setGasFees(
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
      );
  }
}
