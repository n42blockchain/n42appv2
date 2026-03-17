import 'dart:convert';

import 'package:web3dart/web3dart.dart';

String normalizeExportableKeystore(String keystoreJson) {
  final normalized = keystoreJson.trim();
  if (normalized.isEmpty) {
    throw const FormatException('Keystore is empty');
  }
  return normalized;
}

String decodeExportablePrivateKey(String encodedPrivateKey) {
  final normalized = encodedPrivateKey.trim();
  if (normalized.isEmpty) {
    throw const FormatException('Private key is empty');
  }

  final decoded = base64Decode(normalized);
  if (decoded.isEmpty) {
    throw const FormatException('Private key is empty');
  }

  return bytesToHex(decoded);
}
