import 'dart:typed_data';
import 'package:eth_sig_util/util/bigint.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'dart:math';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

class Bip340{
  var curve = ECCurve_secp256k1();
  var G ;
  var n ;

  /// 生成随机私钥
  BigInt generatePrivateKey() {
    var random = FortunaRandom();
    var seed = Uint8List.fromList(List.generate(32, (_) => Random().nextInt(256)));
    random.seed(KeyParameter(seed));
    return decodeBigInt(random.nextBytes(32)) % n;
  }

  /// 计算公钥
  ECPoint getPublicKey(BigInt privateKey) {
    return G * privateKey;
  }

  /// 计算 SHA256 哈希
  BigInt hashMessage(Uint8List message) {
    var sha256 = SHA256Digest();
    return decodeBigInt(sha256.process(message)) % n;
  }

  /// Schnorr 签名
  Uint8List schnorrSign(Uint8List message,BigInt privateKey) {
    curve = ECCurve_secp256k1();
    G = curve.G;
    n = curve.n;
    // 生成随机数 k
    BigInt k = generatePrivateKey();
    ECPoint R = G * k;

    // 计算挑战 e = H(R || P || m)
    ECPoint P = getPublicKey(privateKey);
    var e = hashMessage(Uint8List.fromList([...R.getEncoded(), ...P.getEncoded(), ...message]));

    // 计算 s = k + e * d mod n
    BigInt s = (k + e * privateKey) % n;
    return getWitnessSignature(hex.encode(R.getEncoded()),s.toRadixString(16));
    /*return {
      'R': hex.encode(R.getEncoded()),
      's': s.toRadixString(16)
    };*/
  }
  /// 获取 Witness 签名数据
  Uint8List getWitnessSignature(String R_hex, String s_hex) {
    // 解析 R 并提取 x 坐标
    Uint8List R_bytes = Uint8List.fromList(hex.decode(R_hex));
    Uint8List R_x = R_bytes.sublist(1, 33); // 截取 x 坐标（去掉前缀字节）

    // 解析 s
    Uint8List s_bytes = Uint8List.fromList(hex.decode(s_hex));

    // 组合成 Witness 签名格式 (R_x || s)
    return Uint8List.fromList([...R_x, ...s_bytes]);
  }
  /// Schnorr 验证
  bool schnorrVerify(ECPoint publicKey, Uint8List message, String R_hex, String s_hex) {
    ECPoint R = curve.curve.decodePoint(hex.decode(R_hex))!;
    BigInt s = BigInt.parse(s_hex, radix: 16);

    // 计算挑战 e
    var e = hashMessage(Uint8List.fromList([...R.getEncoded(), ...publicKey.getEncoded(), ...message]));

    // 计算 R' = s * G - e * P
    ECPoint R_prime = (G * s)! - (publicKey * e)!;

    return R == R_prime;
  }
}
