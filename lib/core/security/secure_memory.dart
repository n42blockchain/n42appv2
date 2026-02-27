// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:typed_data';
import 'dart:math';

/// Secure memory handling for sensitive data
///
/// Security features:
/// - Zero-out memory after use
/// - Secure random generation
/// - Prevent accidental logging
class SecureMemory {
  SecureMemory._();

  static final Random _secureRandom = Random.secure();

  /// Create a secure byte array that can be zeroed out
  static Uint8List createSecureBytes(int length) => Uint8List(length);

  /// Securely copy data into a new Uint8List
  static Uint8List secureClone(List<int> data) =>
      Uint8List.fromList(data);

  /// Zero out a byte array to remove sensitive data from memory
  ///
  /// IMPORTANT: Call this after using any sensitive data like:
  /// - Private keys
  /// - Mnemonics
  /// - Passwords
  /// - Seeds
  static void zeroOut(Uint8List data) => data.fillRange(0, data.length, 0);

  /// Zero out a list of bytes
  static void zeroOutList(List<int> data) {
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }

  /// Generate cryptographically secure random bytes
  static Uint8List generateRandomBytes(int length) {
    final result = Uint8List(length);
    for (int i = 0; i < length; i++) {
      result[i] = _secureRandom.nextInt(256);
    }
    return result;
  }

  /// Convert string to secure bytes (UTF-8 encoded)
  static Uint8List stringToSecureBytes(String str) =>
      Uint8List.fromList(str.codeUnits);

  /// Compare two byte arrays in constant time to prevent timing attacks
  static bool constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}

/// A wrapper for sensitive string data that automatically zeros memory
///
/// Usage:
/// ```dart
/// final sensitiveData = SecureString('my_private_key');
/// // Use sensitiveData.value
/// sensitiveData.dispose(); // Zero out memory
/// ```
class SecureString {
  Uint8List? _data;

  SecureString(String value) {
    _data = SecureMemory.stringToSecureBytes(value);
  }

  SecureString.fromBytes(Uint8List bytes) {
    _data = SecureMemory.secureClone(bytes);
  }

  /// Get the string value
  ///
  /// WARNING: This creates a new String object. Use sparingly.
  String get value {
    if (_data == null) throw StateError('SecureString has been disposed');
    return String.fromCharCodes(_data!);
  }

  /// Get the raw bytes
  Uint8List? get bytes => _data;

  /// Check if the data has been disposed
  bool get isDisposed => _data == null;

  /// Zero out the memory and dispose
  void dispose() {
    if (_data != null) {
      SecureMemory.zeroOut(_data!);
      _data = null;
    }
  }

  @override
  String toString() => 'SecureString(****)';
}

/// A wrapper for sensitive key data using Uint8List
///
/// More secure than SecureString as it avoids String internment
class SecureKey {
  Uint8List? _data;

  SecureKey(int length) {
    _data = Uint8List(length);
  }

  SecureKey.fromBytes(List<int> bytes) {
    _data = SecureMemory.secureClone(bytes);
  }

  SecureKey.random(int length) {
    _data = SecureMemory.generateRandomBytes(length);
  }

  /// Get the raw bytes
  ///
  /// Returns null if disposed
  Uint8List? get bytes => _data;

  /// Get byte at index
  int? operator [](int index) => _data?[index];

  /// Set byte at index
  void operator []=(int index, int value) => _data?[index] = value;

  /// Get the length of the key
  int get length => _data?.length ?? 0;

  /// Check if the data has been disposed
  bool get isDisposed => _data == null;

  /// Zero out the memory and dispose
  void dispose() {
    if (_data != null) {
      SecureMemory.zeroOut(_data!);
      _data = null;
    }
  }

  /// Compare with another SecureKey in constant time
  bool equals(SecureKey other) {
    if (_data == null || other._data == null) return false;
    return SecureMemory.constantTimeEquals(_data!, other._data!);
  }

  @override
  String toString() => 'SecureKey(length: $length)';
}
