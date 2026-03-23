import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

/// BTC 交易加密工具：WIF 解码、哈希计算、ECDSA 签名、DER 编码
class BtcTxCrypto {
  /// 解码 WIF 格式私钥为 BigInt
  BigInt decodeWif(String wif) {
    Uint8List decoded = base58Decode(wif);
    return BigInt.parse(hex.encode(decoded.sublist(1, 33)), radix: 16);
  }

  /// Base58 解码
  Uint8List base58Decode(String input) {
    const String alphabet =
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
    BigInt num = BigInt.zero;
    for (int i = 0; i < input.length; i++) {
      int charIndex = alphabet.indexOf(input[i]);
      if (charIndex == -1) {
        throw ArgumentError("Invalid Base58 character: ${input[i]}");
      }
      num = num * BigInt.from(58) + BigInt.from(charIndex);
    }

    List<int> bytes = hex.decode(num.toRadixString(16).padLeft(50, '0'));
    while (bytes.length < 38) {
      bytes.insert(0, 0);
    }
    return Uint8List.fromList(bytes);
  }

  /// 双重 SHA256 哈希
  Uint8List doubleSha256(Uint8List data) {
    return Uint8List.fromList(
        sha256.convert(sha256.convert(data).bytes).bytes);
  }

  /// 单次 SHA256 哈希
  Uint8List sha256s(List<int> data) {
    return Uint8List.fromList(sha256.convert(data).bytes);
  }

  /// 传统 ECDSA 签名（返回 DER 格式 + SIGHASH_ALL 后缀 0x01）
  Uint8List signWithPrivateKey(Uint8List txHash, BigInt privateKey) {
    final ECDomainParameters curve = ECDomainParameters('secp256k1');
    final ECPrivateKey ecPrivateKey = ECPrivateKey(privateKey, curve);
    final SecureRandom secureRandom = _secureRandom();

    final ParametersWithRandom privateKeyParams = ParametersWithRandom(
        PrivateKeyParameter<ECPrivateKey>(ecPrivateKey), secureRandom);

    final Signer signer = ECDSASigner(SHA256Digest());
    signer.init(true, privateKeyParams);

    ECSignature signature =
        signer.generateSignature(txHash) as ECSignature;

    // Bitcoin 规定 s 必须小于 n/2（低 s 值规范化）
    final BigInt nDiv2 = curve.n >> 1;
    if (signature.s.compareTo(nDiv2) > 0) {
      signature = ECSignature(signature.r, curve.n - signature.s);
    }

    final Uint8List derSignature = encodeDER(signature);
    return Uint8List.fromList([...derSignature, 0x01]);
  }

  /// 生成安全随机数
  SecureRandom _secureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seed = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seed)));
    return secureRandom;
  }

  /// 将 ECSignature 编码为 DER 格式
  Uint8List encodeDER(ECSignature signature) {
    List<int> rBytes = _bigIntToBytes(signature.r);
    List<int> sBytes = _bigIntToBytes(signature.s);

    // DER 规范：最高位为 1 时需要前置 0x00
    if (rBytes[0] & 0x80 != 0) rBytes = [0x00, ...rBytes];
    if (sBytes[0] & 0x80 != 0) sBytes = [0x00, ...sBytes];

    return Uint8List.fromList([
      0x30,
      rBytes.length + sBytes.length + 4,
      0x02,
      rBytes.length,
      ...rBytes,
      0x02,
      sBytes.length,
      ...sBytes,
    ]);
  }

  /// BigInt 转最小字节列表（去除前导零，保留至少 1 字节）
  List<int> _bigIntToBytes(BigInt value) {
    final Uint8List bytes =
        Uint8List.fromList(hex.decode(value.toRadixString(16).padLeft(64, '0')));
    final result = bytes.skipWhile((b) => b == 0).toList();
    return result.isEmpty ? [0] : result;
  }
}
