import 'dart:convert';

import 'package:fast_base58/fast_base58.dart';

/// Extracts the serialized message expected by Solana getFeeForMessage.
/// Wallet Core returns a base58 transaction: short-u16 signature count,
/// 64 bytes per signature, then the message (legacy or versioned).
String solTransactionMessage(String signedTransaction) {
  if (signedTransaction.isEmpty || signedTransaction.length > 1700) {
    throw const FormatException('Invalid Solana transaction length');
  }
  final bytes = Base58Decode(signedTransaction);
  var count = 0;
  var offset = 0;
  while (true) {
    if (offset >= bytes.length || offset == 3) {
      throw const FormatException('Invalid Solana signature count');
    }
    final byte = bytes[offset];
    count |= (byte & 0x7f) << (7 * offset);
    offset++;
    if (byte < 128) {
      if (offset > 1 && byte == 0) {
        throw const FormatException('Noncanonical Solana signature count');
      }
      break;
    }
  }
  final messageOffset = offset + count * 64;
  if (count == 0 || count > 12 || messageOffset + 3 > bytes.length) {
    throw const FormatException('Truncated Solana transaction');
  }
  final headerOffset = messageOffset + (bytes[messageOffset] >= 128 ? 1 : 0);
  if (headerOffset >= bytes.length || bytes[headerOffset] != count) {
    throw const FormatException('Solana signer count mismatch');
  }
  return base64Encode(bytes.sublist(messageOffset));
}
