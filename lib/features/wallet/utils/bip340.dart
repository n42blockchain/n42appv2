import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

class Bip340 {
  final ECCurve_secp256k1 curve = ECCurve_secp256k1();
  late final ECPoint G = curve.G;
  late final BigInt n = curve.n;

  /// 将字节数组解码为 BigInt
  BigInt _decodeBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) | BigInt.from(bytes[i]);
    }
    return result;
  }

  /// 生成随机私钥
  BigInt generatePrivateKey() {
    final random = FortunaRandom();
    final secureRandom = Random.secure();
    final seed = Uint8List.fromList(List.generate(32, (_) => secureRandom.nextInt(256)));
    random.seed(KeyParameter(seed));

    BigInt key;
    do {
      key = _decodeBigInt(random.nextBytes(32)) % n;
    } while (key == BigInt.zero);
    return key;
  }

  /// 计算公钥
  ECPoint getPublicKey(BigInt privateKey) {
    return (G * privateKey)!;
  }

  /// 计算 SHA256 哈希
  BigInt hashMessage(Uint8List message) {
    final sha256 = SHA256Digest();
    return _decodeBigInt(sha256.process(message)) % n;
  }

  /// Schnorr 签名
  Uint8List schnorrSign(Uint8List message, BigInt privateKey) {
    if (privateKey <= BigInt.zero || privateKey >= n) {
      throw ArgumentError('Private key must be in range [1, n-1]');
    }
    final BigInt k = generatePrivateKey();
    final ECPoint R = (G * k)!;
    final ECPoint P = getPublicKey(privateKey);
    final e = hashMessage(Uint8List.fromList([...R.getEncoded(), ...P.getEncoded(), ...message]));
    final BigInt s = (k + e * privateKey) % n;
    return getWitnessSignature(hex.encode(R.getEncoded()), s.toRadixString(16));
  }

  /// 获取 Witness 签名数据
  Uint8List getWitnessSignature(String rHex, String sHex) {
    final Uint8List rBytes = Uint8List.fromList(hex.decode(rHex));
    final Uint8List rX = rBytes.sublist(1, 33); // x 坐标（去掉前缀字节）
    // Pad sHex to 64 hex chars (32 bytes) to ensure fixed-length signature
    final Uint8List sBytes = Uint8List.fromList(hex.decode(sHex.padLeft(64, '0')));
    return Uint8List.fromList([...rX, ...sBytes]);
  }

  /// Schnorr 验证
  bool schnorrVerify(ECPoint publicKey, Uint8List message, String rHex, String sHex) {
    final List<int> rDecoded;
    try {
      rDecoded = hex.decode(rHex);
    } catch (_) {
      return false;
    }
    final ECPoint? r = curve.curve.decodePoint(rDecoded);
    if (r == null || r.isInfinity) return false;

    final BigInt s;
    try {
      s = BigInt.parse(sHex, radix: 16);
    } catch (_) {
      return false;
    }
    if (s < BigInt.zero || s >= n) return false;

    final e = hashMessage(Uint8List.fromList([...r.getEncoded(), ...publicKey.getEncoded(), ...message]));
    final ECPoint? gsResult = G * s;
    final ECPoint? peResult = publicKey * e;
    if (gsResult == null || peResult == null) return false;
    final ECPoint? rPrime = gsResult - peResult;
    if (rPrime == null || rPrime.isInfinity) return false;
    return r == rPrime;
  }
}
