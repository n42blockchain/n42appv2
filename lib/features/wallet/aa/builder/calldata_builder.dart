// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

import '../core/aa_constants.dart';

/// Builder for encoding smart account call data
///
/// Provides methods for encoding common operations like transfers,
/// approvals, and batch executions.
class CalldataBuilder {
  CalldataBuilder._();

  // ==================== Execute Functions ====================

  /// Build execute call data for SimpleAccount
  ///
  /// Encodes: execute(address dest, uint256 value, bytes data)
  static Uint8List buildExecute({
    required String target,
    required BigInt value,
    required Uint8List data,
  }) {
    // Function selector: execute(address,uint256,bytes) = 0xb61d27f6
    final selector = hexToBytes(AAConstants.executeSelector.replaceFirst('0x', ''));

    // Encode parameters
    final targetEncoded = _encodeAddress(target);
    final valueEncoded = _encodeUint256(value);
    final dataEncoded = _encodeBytes(data);

    // Combine: selector + target + value + data
    final result = Uint8List(4 + 32 + 32 + dataEncoded.length);
    var offset = 0;

    result.setAll(offset, selector);
    offset += 4;

    result.setAll(offset, targetEncoded);
    offset += 32;

    result.setAll(offset, valueEncoded);
    offset += 32;

    result.setAll(offset, dataEncoded);

    return result;
  }

  /// Build executeBatch call data for SimpleAccount
  ///
  /// Encodes: executeBatch(address[] dest, uint256[] value, bytes[] data)
  static Uint8List buildExecuteBatch(List<ExecuteCall> calls) {
    if (calls.isEmpty) {
      throw ArgumentError('At least one call is required');
    }

    // Function selector: executeBatch(address[],uint256[],bytes[]) = 0x47e1da2a
    final selector = hexToBytes(AAConstants.executeBatchSelector.replaceFirst('0x', ''));

    // Encode arrays
    final targets = calls.map((c) => c.target).toList();
    final values = calls.map((c) => c.value).toList();
    final datas = calls.map((c) => c.data).toList();

    final targetsEncoded = _encodeAddressArray(targets);
    final valuesEncoded = _encodeUint256Array(values);
    final datasEncoded = _encodeBytesArray(datas);

    // Calculate offsets for dynamic arrays
    // Header: 3 offsets (each 32 bytes) = 96 bytes
    const headerSize = 96;
    final targetsOffset = BigInt.from(headerSize);
    final valuesOffset = targetsOffset + BigInt.from(targetsEncoded.length);
    final datasOffset = valuesOffset + BigInt.from(valuesEncoded.length);

    // Build result
    final totalSize = 4 + headerSize + targetsEncoded.length + valuesEncoded.length + datasEncoded.length;
    final result = Uint8List(totalSize);
    var offset = 0;

    result.setAll(offset, selector);
    offset += 4;

    result.setAll(offset, _encodeUint256(targetsOffset));
    offset += 32;

    result.setAll(offset, _encodeUint256(valuesOffset));
    offset += 32;

    result.setAll(offset, _encodeUint256(datasOffset));
    offset += 32;

    result.setAll(offset, targetsEncoded);
    offset += targetsEncoded.length;

    result.setAll(offset, valuesEncoded);
    offset += valuesEncoded.length;

    result.setAll(offset, datasEncoded);

    return result;
  }

  // ==================== ERC20 Functions ====================

  /// Build ERC20 transfer call data
  ///
  /// Encodes: transfer(address to, uint256 amount)
  static Uint8List buildErc20Transfer({
    required String to,
    required BigInt amount,
  }) {
    return _encodeAddressUint256Call(AAConstants.erc20TransferSelector, to, amount);
  }

  /// Build ERC20 approve call data
  ///
  /// Encodes: approve(address spender, uint256 amount)
  static Uint8List buildErc20Approve({
    required String spender,
    required BigInt amount,
  }) {
    return _encodeAddressUint256Call(AAConstants.erc20ApproveSelector, spender, amount);
  }

  // ==================== Factory Functions ====================

  /// Build createAccount call data for SimpleAccountFactory
  ///
  /// Encodes: createAccount(address owner, uint256 salt)
  static Uint8List buildCreateAccount({
    required String owner,
    required BigInt salt,
  }) {
    return _encodeAddressUint256Call(AAConstants.createAccountSelector, owner, salt);
  }

  /// Build getAddress call data for SimpleAccountFactory
  ///
  /// Encodes: getAddress(address owner, uint256 salt)
  static Uint8List buildGetAddress({
    required String owner,
    required BigInt salt,
  }) {
    return _encodeAddressUint256Call(AAConstants.getAddressSelector, owner, salt);
  }

  // ==================== EntryPoint Functions ====================

  /// Build getNonce call data for EntryPoint
  ///
  /// Encodes: getNonce(address sender, uint192 key)
  static Uint8List buildGetNonce({
    required String sender,
    BigInt? key,
  }) {
    return _encodeAddressUint256Call(AAConstants.getNonceSelector, sender, key ?? BigInt.zero);
  }

  // ==================== Init Code ====================

  /// Build init code for SimpleAccount deployment
  static Uint8List buildSimpleAccountInitCode({
    required String factoryAddress,
    required String owner,
    required BigInt salt,
  }) {
    final factoryBytes = hexToBytes(factoryAddress.replaceFirst('0x', ''));
    final createAccountData = buildCreateAccount(owner: owner, salt: salt);

    final result = Uint8List(factoryBytes.length + createAccountData.length);
    result.setAll(0, factoryBytes);
    result.setAll(factoryBytes.length, createAccountData);

    return result;
  }

  // ==================== Encoding Helpers ====================

  /// Encode a call with selector(address, uint256) pattern
  ///
  /// Common pattern used by ERC20 transfer/approve, factory createAccount/getAddress, etc.
  static Uint8List _encodeAddressUint256Call(String selectorHex, String address, BigInt value) {
    final selector = hexToBytes(selectorHex.replaceFirst('0x', ''));
    final result = Uint8List(4 + 64);
    result.setAll(0, selector);
    result.setAll(4, _encodeAddress(address));
    result.setAll(36, _encodeUint256(value));
    return result;
  }

  /// Encode an address to 32 bytes (left-padded)
  static Uint8List _encodeAddress(String address) {
    final bytes = hexToBytes(address.replaceFirst('0x', '').padLeft(40, '0'));
    final result = Uint8List(32);
    result.setAll(12, bytes); // Left-pad with 12 zeros
    return result;
  }

  /// Encode a uint256 to 32 bytes
  static Uint8List _encodeUint256(BigInt value) {
    final result = Uint8List(32);
    final valueBytes = intToBytes(value);
    final start = 32 - valueBytes.length;
    if (start >= 0 && valueBytes.length <= 32) {
      result.setAll(start, valueBytes);
    }
    return result;
  }

  /// Encode dynamic bytes with offset and length
  static Uint8List _encodeBytes(Uint8List data) {
    // Offset to data (always 32 for single bytes parameter after fixed params)
    final offset = _encodeUint256(BigInt.from(32));

    // Length of data
    final length = _encodeUint256(BigInt.from(data.length));

    // Data (padded to 32-byte boundary)
    final paddedLength = ((data.length + 31) ~/ 32) * 32;
    final paddedData = Uint8List(paddedLength);
    paddedData.setAll(0, data);

    // Combine: offset + length + paddedData
    final result = Uint8List(32 + 32 + paddedLength);
    result.setAll(0, offset);
    result.setAll(32, length);
    result.setAll(64, paddedData);

    return result;
  }

  /// Encode an array of addresses
  static Uint8List _encodeAddressArray(List<String> addresses) {
    // Length
    final length = _encodeUint256(BigInt.from(addresses.length));

    // Encode each address
    final addressesEncoded = Uint8List(addresses.length * 32);
    for (var i = 0; i < addresses.length; i++) {
      addressesEncoded.setAll(i * 32, _encodeAddress(addresses[i]));
    }

    // Combine
    final result = Uint8List(32 + addressesEncoded.length);
    result.setAll(0, length);
    result.setAll(32, addressesEncoded);

    return result;
  }

  /// Encode an array of uint256
  static Uint8List _encodeUint256Array(List<BigInt> values) {
    // Length
    final length = _encodeUint256(BigInt.from(values.length));

    // Encode each value
    final valuesEncoded = Uint8List(values.length * 32);
    for (var i = 0; i < values.length; i++) {
      valuesEncoded.setAll(i * 32, _encodeUint256(values[i]));
    }

    // Combine
    final result = Uint8List(32 + valuesEncoded.length);
    result.setAll(0, length);
    result.setAll(32, valuesEncoded);

    return result;
  }

  /// Encode an array of bytes
  static Uint8List _encodeBytesArray(List<Uint8List> bytesArray) {
    // Calculate total size
    var totalDataSize = 32; // Array length

    // Offsets header (one offset per element)
    totalDataSize += bytesArray.length * 32;

    // Each bytes element: length (32) + padded data
    final paddedLengths = <int>[];
    for (final data in bytesArray) {
      final paddedLength = ((data.length + 31) ~/ 32) * 32;
      paddedLengths.add(paddedLength);
      totalDataSize += 32 + paddedLength; // length + padded data
    }

    final result = Uint8List(totalDataSize);
    var offset = 0;

    // Array length
    result.setAll(offset, _encodeUint256(BigInt.from(bytesArray.length)));
    offset += 32;

    // Calculate and write offsets
    var dataOffset = bytesArray.length * 32; // Start after all offsets
    for (var i = 0; i < bytesArray.length; i++) {
      result.setAll(offset, _encodeUint256(BigInt.from(dataOffset)));
      offset += 32;
      dataOffset += 32 + paddedLengths[i]; // length + padded data
    }

    // Write each bytes element
    for (var i = 0; i < bytesArray.length; i++) {
      // Length
      result.setAll(offset, _encodeUint256(BigInt.from(bytesArray[i].length)));
      offset += 32;

      // Data (padded)
      result.setAll(offset, bytesArray[i]);
      offset += paddedLengths[i];
    }

    return result;
  }

  // ==================== Decoding Helpers ====================

  /// Decode an address from 32 bytes
  static String decodeAddress(Uint8List data) {
    if (data.length != 32) {
      throw ArgumentError('Address must be 32 bytes');
    }
    return '0x${bytesToHex(data.sublist(12))}';
  }

  /// Decode a uint256 from 32 bytes
  static BigInt decodeUint256(Uint8List data) {
    if (data.length != 32) {
      throw ArgumentError('Uint256 must be 32 bytes');
    }
    return bytesToInt(data);
  }

  /// Calculate function selector from signature
  static String getFunctionSelector(String signature) {
    final hash = keccak256(Uint8List.fromList(signature.codeUnits));
    return '0x${bytesToHex(hash.sublist(0, 4))}';
  }
}

/// Represents a single call in a batch execution
class ExecuteCall {
  /// Target contract address
  final String target;

  /// ETH value to send
  final BigInt value;

  /// Call data
  final Uint8List data;

  const ExecuteCall({
    required this.target,
    required this.value,
    required this.data,
  });

  /// Create an ETH transfer call
  factory ExecuteCall.ethTransfer(String to, BigInt amount) {
    return ExecuteCall(
      target: to,
      value: amount,
      data: Uint8List(0),
    );
  }

  /// Create an ERC20 transfer call
  factory ExecuteCall.erc20Transfer({
    required String token,
    required String to,
    required BigInt amount,
  }) {
    return ExecuteCall(
      target: token,
      value: BigInt.zero,
      data: CalldataBuilder.buildErc20Transfer(to: to, amount: amount),
    );
  }

  /// Create an ERC20 approve call
  factory ExecuteCall.erc20Approve({
    required String token,
    required String spender,
    required BigInt amount,
  }) {
    return ExecuteCall(
      target: token,
      value: BigInt.zero,
      data: CalldataBuilder.buildErc20Approve(spender: spender, amount: amount),
    );
  }

  /// Create a generic contract call
  factory ExecuteCall.contractCall({
    required String contract,
    required Uint8List data,
    BigInt? value,
  }) {
    return ExecuteCall(
      target: contract,
      value: value ?? BigInt.zero,
      data: data,
    );
  }

  @override
  String toString() {
    return 'ExecuteCall(target: $target, value: $value, dataLength: ${data.length})';
  }
}
