import 'dart:typed_data';

import 'package:wallet/wallet.dart' show EthereumAddress;
import 'package:web3dart/web3dart.dart'
    show encode, hexToBytes, keccak256, bytesToHex;

/// N42 Go PostQuantumTx.SigningHash: 0x05 || RLP(unsigned fields).
/// Initial implementation uses full public keys, empty access list, native value.
/// This signing preimage is NOT an eth_sendRawTransaction wire encoding.
final class FalconTransaction {
  FalconTransaction({
    required this.chainId,
    required this.nonce,
    required String recipient,
    required this.value,
    required this.gas,
    required this.tipCap,
    required this.feeCap,
    required Uint8List publicKey,
  }) : recipient = EthereumAddress.fromHex(
         recipient,
         enforceEip55: true,
       ).with0x,
       _publicKey = Uint8List.fromList(publicKey) {
    final max = (BigInt.one << 256) - BigInt.one;
    for (final n in [chainId, value, tipCap, feeCap]) {
      if (n < BigInt.zero || n > max) throw ArgumentError('Invalid uint256');
    }
    if (chainId == BigInt.zero ||
        chainId >= (BigInt.one << 64) ||
        tipCap >= (BigInt.one << 128) ||
        feeCap >= (BigInt.one << 128) ||
        value == BigInt.zero ||
        feeCap < tipCap ||
        feeCap == BigInt.zero ||
        nonce < BigInt.zero ||
        nonce >= (BigInt.one << 64) ||
        gas < BigInt.from(21000) ||
        gas >= (BigInt.one << 64) ||
        publicKey.length != 897 ||
        BigInt.parse(this.recipient.substring(2), radix: 16) == BigInt.zero) {
      throw ArgumentError('Invalid Falcon transaction');
    }
  }
  final BigInt chainId, nonce, value, gas, tipCap, feeCap;
  final String recipient;
  final Uint8List _publicKey;
  Uint8List get publicKey => Uint8List.fromList(_publicKey);
  Uint8List get signingPreimage => Uint8List.fromList([
    5,
    ...encode([
      chainId,
      nonce,
      tipCap,
      feeCap,
      gas,
      hexToBytes(recipient),
      value,
      Uint8List(0),
      <Object>[],
      0,
      0,
      _publicKey,
    ]),
  ]);

  /// Canonical N42 0x05 v1 wire form, admitted only after network activation.
  Uint8List encodeSigned(Uint8List signature) {
    if (signature.length != 666) {
      throw ArgumentError('Expected padded Falcon-512 signature');
    }
    return Uint8List.fromList([
      5,
      ...encode([
        chainId,
        nonce,
        tipCap,
        feeCap,
        gas,
        hexToBytes(recipient),
        value,
        Uint8List(0),
        <Object>[],
        0,
        0,
        _publicKey,
        signature,
      ]),
    ]);
  }

  Uint8List get digest => keccak256(signingPreimage);
  String get sender =>
      bytesToHex(keccak256(_publicKey).sublist(12), include0x: true);
  Map<String, Object> review() => {
    'type': '0x05',
    'algorithm': 'Falcon-512',
    'chainId': '$chainId',
    'sender': sender,
    'recipient': recipient,
    'valueWei': '$value',
    'nonce': '$nonce',
    'gas': '$gas',
    'maxPriorityFeePerGas': '$tipCap',
    'maxFeePerGas': '$feeCap',
    'maximumFeeWei': '${gas * feeCap}',
    'signingHash': bytesToHex(digest, include0x: true),
    'publicKey': bytesToHex(_publicKey, include0x: true),
    'pubKeyMode': 0,
  };
}
